require 'pathname'

module NewrelicHelper
  
  # return the host that serves static content (css, metric documentation, images, etc)
  # that supports the desktop edition.
  def server
    NewRelic::Agent.instance.config['desktop_server'] || "http://rpm.newrelic.com"
  end
  
  # return the sample but post processed to strip out segments that normally don't show
  # up in production (after the first execution, at least) such as application code loading
  def stripped_sample(sample = @sample)
    if session[:newrelic_strip_code_loading] || true
      sample.omit_segments_with('(Rails/Application Code Loading)|(Database/.*/.+ Columns)')
    else
      sample
    end
  end
  
  # return the highest level in the call stack for the trace that is not rails or 
  # newrelic agent code
  def application_caller(trace)
    trace.each do |trace_line|
      file = file_and_line(trace_line).first
      unless exclude_file_from_stack_trace?(file, false)
        return trace_line
      end
    end
    trace.last
  end
  
  def application_stack_trace(trace, include_rails = false)
    trace.reject do |trace_line|
      file = file_and_line(trace_line).first
      exclude_file_from_stack_trace?(file, include_rails)
    end
  end
  
  def agent_views_path(path)
    path
  end
  
  def url_for_metric_doc(metric_name)
    "#{server}/metric_doc?metric=#{CGI::escape(metric_name)}"
  end
  
  def url_for_source(trace_line)
    file, line = file_and_line(trace_line)
    
    begin
      file = Pathname.new(file).realpath
    rescue Errno::ENOENT
      # we hit this exception when Pathame.realpath fails for some reason; attempt a link to
      # the file without a real path.  It may also fail, only when the user clicks on this specific
      # entry in the stack trace
    rescue 
      # catch all other exceptions.  We're going to create an invalid link below, but that's okay.
    end
      
    if using_textmate?
      "txmt://open?url=file://#{file}&line=#{line}"
    else
      url_for :action => 'show_source', :file => file, :line => line, :anchor => 'selected_line'
    end
  end
  
  def write_segment_label(segment)
    if segment[:backtrace] && (source_url = url_for_source(application_caller(segment[:backtrace])))
      link_to segment.metric_name, source_url
    else
      segment.metric_name
    end
  end

  
  def link_to_source(trace)
    image_url = "#{server}/images/"
    image_url << (using_textmate? ? "textmate.png" : "file_icon.png")
    
    link_to image_tag(image_url), url_for_source(application_caller(trace))
  end
  
  def timestamp(segment)
    sprintf("%1.3f", segment.entry_timestamp)
  end
  
  def format_timestamp(time)
    time.strftime("%H:%M:%S") 
  end

  def colorize(value, yellow_threshold = 0.05, red_threshold = 0.15)
    if value > yellow_threshold
      color = (value > red_threshold ? 'red' : 'orange')
      "<font color=#{color}>#{value.to_ms}</font>"
    else
      "#{value.to_ms}"
    end
  end
  
  def expanded_image_path()
    url_for(:controller => :newrelic, :action => :image, :file => '16-arrow-down.png')
  end
  
  def collapsed_image_path()
    url_for(:controller => :newrelic, :action => :image, :file => '16-arrow-right.png')
  end
  
  def explain_sql_url(segment)
    url_for(:action => :explain_sql, 
      :id => @sample.sample_id, 
      :segment => segment.segment_id)
  end
  
  def line_wrap_sql(sql)
    sql.gsub(/\,/,', ').squeeze(' ')
  end
  
  def render_sample_details(sample)
    @indentation_depth=0
    # skip past the root segments to the first child, which is always the controller
    first_segment = sample.root_segment.called_segments.first
    
    # render the segments, then the css classes to indent them
    render_segment_details(first_segment) + render_indentation_classes(@indentation_depth)
  end
  
  # the rows logger plugin disables the sql tracing functionality of the NewRelic agent -
  # notify the user about this
  def rows_logger_present?
    File.exist?(File.join(File.dirname(__FILE__), "../../../rows_logger/init.rb"))
  end
  
  def expand_segment_image(segment, depth)
    if depth > 0
      if !segment.called_segments.empty?
        row_class =segment_child_row_class(segment)
        link_to_function(tag('img', :src => collapsed_image_path, :id => "image_#{row_class}",
            :class_for_children => row_class, 
            :class => (!segment.called_segments.empty?) ? 'parent_segment_image' : 'child_segment_image'), 
            "toggle_row_class(this)")
      end
    end
  end
  
  def segment_child_row_class(segment)
    "segment#{segment.segment_id}"
  end
  
  def summary_pie_chart(sample, width, height)
    pie_chart = GooglePieChart.new
    pie_chart.color, pie_chart.width, pie_chart.height = '6688AA', width, height
    
    chart_data = sample.breakdown_data(6)
    chart_data.each { |s| pie_chart.add_data_point s.metric_name, s.exclusive_time.to_ms }
    
    pie_chart.render
  end
  
  def segment_row_classes(segment, depth)
    classes = []
    
    classes << "segment#{segment.parent_segment.segment_id}" if depth > 1 
  
    classes << "view_segment" if segment.metric_name.starts_with?('View')
    classes << "summary_segment" if segment.is_a?(NewRelic::TransactionSample::CompositeSegment)

    classes.join(' ')
  end

  # render_segment_details should be called before calling this method
  def render_indentation_classes(depth)
    styles = [] 
    (1..depth).each do |d|
      styles <<  ".segment_indent_level#{d} { display: inline-block; margin-left: #{(d-1)*20}px }"
    end
    content_tag("style", styles.join(' '))    
  end
  
  def sql_link_mouseover_options(segment)
    { :onmouseover => "sql_mouse_over(#{segment.segment_id})", :onmouseout => "sql_mouse_out(#{segment.segment_id})"}
  end
  
  def explain_sql_links(segment)
    if segment[:sql_obfuscated] || segment[:sql]
      link_to 'SQL', explain_sql_url(segment), sql_link_mouseover_options(segment)
    else
      links = []
      segment.called_segments.each do |child|
        if child[:sql_obfuscated] || child[:sql]
          links << link_to('SQL', explain_sql_url(child), sql_link_mouseover_options(child))
        end
      end
      links[0..1].join(', ') + (links.length > 2?', ...':'')
    end
  end
  
private
  def file_and_line(stack_trace_line)
    stack_trace_line.match(/(.*):(\d+)/)[1..2]
  end
  
  def using_textmate?
    # For now, disable textmate integration
    false
  end
  

  def render_segment_details(segment, depth=0)
    
    @indentation_depth = depth if depth > @indentation_depth
    repeat = nil
    if segment.is_a?(NewRelic::TransactionSample::CompositeSegment)
      html = ''
    else
      repeat = segment.parent_segment.detail_segments.length if segment.parent_segment.is_a?(NewRelic::TransactionSample::CompositeSegment)
      html = render(:partial => agent_views_path('segment'), :object => segment, :locals => {:indent => depth, :repeat => repeat})
      depth += 1
    end
    
    segment.called_segments.each do |child|
      html << render_segment_details(child, depth)
    end
    
    html
  end
    
  def exclude_file_from_stack_trace?(file, include_rails)
    is_agent = file =~ /\/newrelic\/agent\//
    return is_agent if include_rails
    
    is_agent ||
      file =~ /\/active(_)*record\// ||
      file =~ /\/action(_)*controller\// ||
      file =~ /\/activesupport\// ||
      file =~ /\/actionpack\//
  end
  
  def show_view_link(title, page_name)
    link_to_function("[#{title}]", "show_view('#{page_name}')");
  end
end
