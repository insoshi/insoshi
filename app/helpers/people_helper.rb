module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    people.map { |person| link_to(image_tag(person.send(image)), person) }
  end
end