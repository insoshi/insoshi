module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    links = options[:links] || people
    captions = options[:captions]
    images = people.zip(links).map do |person, link|
               image_link(person, :link => link, :image => image)
             end
    if captions.nil?
      images
    else
      captions = captions.zip(links).map { |c, l| link_to(c, l) } 
      captioned(images, captions)
    end
  end

  # Return a person's image link.
  def image_link(person, options = {})
    link = options[:link] || person
    image = options[:image] || :icon
    image_options = { :title => h(person.name), :alt => h(person.name) }
    unless options[:image_options].nil?
      image_options.merge!(options[:image_options]) 
    end
    link_options =  { :title => h(person.name) }
    unless options[:link_options].nil?                    
      link_options.merge!(options[:link_options])
    end
    content = image_tag(person.send(image), image_options)
    # This is a hack needed for the way the designer handled rastered images
    # ('vcard' class).
    if options[:vcard]
      content = %(#{content}#{content_tag(:span, h(person.name), 
                                                 :class => "fn" )})
    end
    link_to(content, link, link_options)
  end

  def person_link(text, person = nil)
    if person.nil?
      person = text
      text = person.name
    end
    # We normally write link_to(..., person) for brevity, but that breaks
    # activities_helper_spec due to an RSpec bug.
    link_to(h(text), person_path(person))
  end
  
  private
    
    # Make captioned images.
    def captioned(images, captions)
      images.zip(captions).map do |image, caption|
        markaby do
          image << div { caption }
        end
      end
    end
end