module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    links = options[:links] || people
    destroy = options[:destroy] || false
    send_message = options[:send_message] || false
    captions = options[:captions]
    images = people.zip(links).map do |person, link|
               image_link(person, :link => link, :image => image)
             end
    if captions.nil?
      images
    else
      captions = captions.zip(links).map { |c, l| link_to(c, l) } 
      captioned_images = captioned(images, captions)
      if destroy
        captioned(captioned_images,break_up_links(people))
      end
      if send_message
        captioned(captioned_images,message_links(people))
      end
      captioned_images
    end
  end
  
  def break_up_links(people)
    people.map { |p| link_to("break up", current_person.connections.find_by_contact_id(p), :method => :delete, :confirm => "Do you want to break up with #{p.name}?") }
  end
  
  def message_links(people)
    people.map { |p| email_link(p)}
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
