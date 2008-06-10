##
# Jeff Smick rocks.
#
%w(rubygems mongrel mofo cgi).each { |r| require r }
Hpricot.buffer_size = 5242880
Mofo.timeout = 10

class TryMofo < Mongrel::HttpHandler
  def html
    @html ||= File.read('template.html')
  end

  def process(request, response)
    response.start(200) do |headers, output|
      headers['Content-Type'] = 'text/html'
      output.write request.params['REQUEST_METHOD'].upcase == 'POST' ? serve_post_request(request) : html
    end
  end

  def serve_post_request(request)
    Microformat.find(:all => target(request.body.read)).inject('') do |html, mofo|
      html << "<dl><dt><h3>#{mofo.class}</h3></dt><dd>"
      html << properties(mofo)
      html << "</dd></dl>"
      html << "<br/>"
    end rescue ''
  end

  def target(text)
    text[/^text:/] ? { :text => text.sub('text:','') } : clean_url(text)
  end

  def clean_url(url)
    'http://' + url.sub('http://','')
  end

  def properties(mofo)
    return mofo.to_yaml unless mofo.respond_to? :properties
    props = mofo.properties.map do |property| 
      "<li><strong>#{property}</strong>: #{show_property(mofo.__send__(property))}</li>" 
    end
    "<ul>#{props.join('')}</ul>"
  end

  def show_property(prop)
    if prop.is_a? Microformat
      properties(prop)
    else
      CGI.escapeHTML(prop.to_s)
    end
  end
end

port = 9010 

config = Mongrel::Configurator.new :host => "0.0.0.0" do
  listener :port => port do
    uri '/',   :handler => TryMofo.new
    uri '/js', :handler => Mongrel::DirHandler.new('.', false)
#    daemonize :cwd => '.', :log_file => 'trymofo.log'
  end
  run
end

puts "=> Running at #{port}..."
config.join
