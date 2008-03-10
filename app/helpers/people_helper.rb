module PeopleHelper

  def image_links(people, options = {})
    image = options[:image] || :icon
    links = options[:links] || people
    captions = options[:captions]
    images = people.zip(links).map do |person, link|
               link_to(image_tag(person.send(image)), link)
             end
    if captions.nil?
      images
    else
      captions = captions.zip(links).map { |c, l| link_to(c, l) } 
      captioned(images, captions)
    end
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