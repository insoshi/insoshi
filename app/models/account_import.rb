class AccountImport < ActiveRecord::Base
	belongs_to :person
	mount_uploader :file, DataUploader
  attr_accessible :file, :file_cache, :remove_file, :successful, :person_id, :as => :admin

  validates :person_id, :presence => true

  before_validation :import_people

  PERSON_ROWS = %w(first_name last_name address city state zip phone email)


  def name
    person ? person.display_name : '-'
  end

  protected

  	# Imports basic person info for non-business users.
  	# Required/expected fields are:
		# first_name
		# last_name
		# address
		# city
		# state
		# zip
		# email
  	def import_people
  		duplicate_emails = []
  		invalid_row_count = 0
  		# Iterate through to validate
  		CSV.foreach(file.path, col_sep: ",", headers: true) do |row|
  			
  			# Valid headers?
  			unless PERSON_ROWS.sort == row.headers.sort
  				errors[:base] << "Column headers are invalid. They should be: #{PERSON_ROWS.join(', ')}"
  				break
  			end

  			# Make sure there are no blanks or duplicate emails.
  			invalid_row_count += 1 unless valid_person_row?(row)
  			if row['email'] and Person.where(email: row['email'].downcase.strip).count > 0
  				duplicate_emails<< row['email']
  			end
  		end

  		if !errors[:base].empty? or duplicate_emails.size > 0 or invalid_row_count > 0
  			errors[:base] << "The following email addresses already exist: #{duplicate_emails.join(', ')}" unless duplicate_emails.empty?
  			errors[:base] << "Missing fields found. All fields are required." if invalid_row_count > 0
  		else

	  		# Okay, if we make it to here we can start creating the new users
	  		CSV.foreach(file.path, col_sep: ",", headers: true) do |row|
	  			pwd = random_pwd

	  			# Create the new person
	  			p = Person.new(
	            :name => [row['first_name'].strip, row['last_name'].strip].join(' '),
	            :phone => (row['phone'].blank? ? nil : row[5].gsub(/[^0-9]/i, '')),
	            :email => row['email'].strip,
	            :password => pwd,
	            :password_confirmation => pwd,
	            :zipcode => (row['zip'].blank? ? nil : row['zip'].gsub(/[^0-9]/i, ''))
	          )

	          p.org = false
	          p.email_verified = true
	          p.save!(:validate => false)

	          address = p.addresses.first || Address.new(:person => p)
	          address.name = 'personal'
	          address.address_line_1 = (row['address'].blank? ? nil : row['address'].strip)
	          address.city = (row['city'].blank? ? nil : row['city'].strip)
	          #address.county_id = (row[12].blank? ? nil : row[12].strip)
	          address.state = State.where(abbreviation: row['state'].upcase).first
	          address.zipcode_plus_4 = (row['zip'].blank? ? nil : row['zip'].gsub(/[^0-9]/i, ''))

	          address.save!(:validate => false)

	    			p.deliver_password_reset_instructions!
	    	end
	    	self.successful = true
	    end
    	# Optionally delete the carrierwave file after successful import?
  	end

  	def valid_person_row?(row)
  		valid = true
  		PERSON_ROWS.each do |field|
  			if row["#{field}"].blank?
  				valid = false
  				break
  			end
  		end
  		return valid
  	end

  	def random_pwd
  		(0...8).map { (65 + rand(26)).chr }.join
  	end
end
