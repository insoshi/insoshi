module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    links = options[:links] || people
    people.zip(links).map do |person, link|
      link_to(image_tag(person.send(image)), link)
    end
  end
end