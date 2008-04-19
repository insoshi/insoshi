module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    links = options[:links] || people
    destroy = options[:destroy] || false
    captions = options[:captions]
    images = people.zip(links).map do |person, link|
               image_link(person, :link => link, :image => image)
             end
    if captions.nil?
      images
    else
      captions = captions.zip(links).map { |c, l| link_to(c, l) } 
      captions = captions.zip(breakup_links(people)).map { |c, l| c << l } if destroy
      captioned(images, captions)
    end
  end
  
  def breakup_links(people)
    a = people.map { |p| " | " << link_to("break up", current_person.connections.find_by_contact_id(p), :method => :delete, :confirm => "Do you want to break up with #{p.name}?") }
  end

  # Return a person's image link.
  def image_link(person, options = {})
    link = options[:link] || person
    image = options[:image] || :icon
    link_to(image_tag(person.send(image)), link)
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
