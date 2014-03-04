namespace :preferences do
  desc "Initializes the default picture for existing groups"
  task :default_picture => :environment do
    Preference.all.each do |preference|
      if preference.photos.where(:picture_for => 'profile').first.nil?
        photo = preference.photos.new(:picture_for => 'profile')
        photo.picture = File.open(File.join(Rails.root, 'public/images/default.png'))
        photo.save!
      end
      # default group picture
      if preference.photos.where(:picture_for => 'group').first.nil?
        photo = preference.photos.new(:picture_for => 'group')
        photo.picture = File.open(File.join(Rails.root, 'public/images/g_default.png'))
        photo.save!
      end
    end
  end

end
