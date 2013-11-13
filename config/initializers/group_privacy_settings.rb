Group.all.each do |group|
  if group.privacy_setting.nil?
    p = PrivacySetting.new
    p.group = group
    p.save
  end
end
