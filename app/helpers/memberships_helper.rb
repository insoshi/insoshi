module MembershipsHelper
  def membership_link(member, html_options = nil)
    text = member.person.name
    link_to(h(text), member, html_options)
  end
end
