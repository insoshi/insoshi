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