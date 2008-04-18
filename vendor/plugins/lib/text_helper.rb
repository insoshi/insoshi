

module ActionView::Helpers::TextHelper

  def truncate_words(text, nubmer_of_words = 30, truncate_string = "..." ) 
    return '' if text.blank?
    words = text.split 
    words.length > nubmer_of_words ? close_open_html_tags(words[0...nubmer_of_words].join(" ") + truncate_string) : close_open_html_tags(text) 
  end 

  # If +html_text+ contains open html tags, they will be closed. 
  # 
  #   close_open_html_tags("<p>Hello, world.") 
  #    => <p>Hello, world.</p> 
  def close_open_html_tags(html_text) 
    h1 = {} 
    h2 = {} 
    html_text.scan(/\<([^\>\s\/]+)[^\>\/]*?\>/).each { |t| h1[t[0]] ? h1[t[0]] += 1 : h1[t[0]] = 1 } 
    html_text.scan(/\<\/([^\>\s\/]+)[^\>]*?\>/).each { |t| h2[t[0]] ? h2[t[0]] += 1 : h2[t[0]] = 1 } 
    h1.each {|k,v| html_text += "</#{k}>" * (h1[k] - h2[k].to_i) if h2[k].to_i < v } 
    return html_text 
  end

end