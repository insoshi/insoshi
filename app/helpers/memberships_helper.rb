module MembershipsHelper
  def membership_link(member, html_options = nil)
    unless (member.nil? || member.person.nil?)
      text = member.person.display_name
    else
      text = "(member left!)"
    end
    link_to(h(text), member, html_options)
  end
end
