begin
Group.all.each do |group|
  if group.privacy_setting.nil?
    p = PrivacySetting.new
    p.group = group
    p.save
  end
end
rescue
  # Rescue from the error raised upon first migrating
  nil
end
