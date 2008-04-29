module ActivityLogger
  def add_activities(options = {})
    person = options[:person]
    include_person = options[:include_person]
    activity = options[:activity] ||
               Activity.create!(:item => options[:item], :person => person)
    person.contacts.each { |c| c.activities << activity }
    person.activities << activity if include_person
  end
end