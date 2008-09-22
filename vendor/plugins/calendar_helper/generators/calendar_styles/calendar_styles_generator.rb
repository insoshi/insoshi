class CalendarStylesGenerator < Rails::Generator::Base  

  def manifest
    record do |m|
      calendar_themes_dir = "public/stylesheets/calendar"
      m.directory calendar_themes_dir

      # Copy files
      %w(red blue grey).each do |dir|
        m.directory File.join(calendar_themes_dir, dir)
        m.file File.join("#{dir}/style.css"), File.join(calendar_themes_dir, "#{dir}/style.css")
      end

      # Dir.read("vendor/public/calendar_helper/generators/calendar_styles/templates").each do |dir|
#         m.file "orig", File.join(calendar_themes_dir, dir.name, "some_file.css")
#       end

    end
  end
end
