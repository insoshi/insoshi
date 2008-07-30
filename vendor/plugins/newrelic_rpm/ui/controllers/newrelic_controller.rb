require 'newrelic/agent'
require 'google_pie_chart'
require 'active_record'
require 'transaction_analysis'

class NewrelicController < ActionController::Base
  include NewrelicHelper
  
  # do not include any filters inside the application since there might be a conflict
  if respond_to? :filter_chain
    filters = filter_chain.collect do |f|
      if f.respond_to? :filter
        # rails 2.0
        f.filter
      elsif f.respond_to? :method
        # rails 2.1
        f.method
      else
        fail "Unknown filter class. Please send this exception to support@newrelic.com"
      end
    end
    skip_filter filters
  end
  
  # for this controller, the views are located in a different directory from
  # the application's views.
  view_path = File.join(File.dirname(__FILE__), '..', 'views')
  if public_methods.include? 'append_view_path' # rails 2.1+
    self.append_view_path view_path
  elsif public_methods.include? "view_paths"   # rails 2.0+
    self.view_paths << view_path
  else                                      # rails <2.0
    self.template_root = view_path
  end
  
  layout "default"
  
  write_inheritable_attribute('do_not_trace', true)
  
  def css
    forward_to_file '/newrelic/stylesheets/', 'text/css'
  end
  
  def image
    forward_to_file '/newrelic/images/', params[:content_type]
  end
  
  def javascript
    forward_to_file '/newrelic/javascript/', 'text/javascript'
  end
  
  def forward_to_file(root_path = nil, content_type = nil)
    if root_path &&  file = params[:file]
      full_path = root_path + file
      render :file => full_path, :use_full_path => true, :content_type => content_type
    else
      render :nothing => true, :status => 404
    end
  end
  
  def index
    get_samples
  end
  
  def show_sample_detail
    show_sample_data
  end
  
  def show_sample_summary
    show_sample_data
  end
  
  def show_sample_sql
    show_sample_data
  end
  
  
  def explain_sql
    get_segment
    
    render :action => "sample_not_found" and return unless @sample 

    @sql = @segment[:sql]
    @trace = @segment[:backtrace]
    
    if NewRelic::Agent.agent.record_sql == :obfuscated  
      @obfuscated_sql = @segment.obfuscated_sql
    end
    
    explanations = @segment.explain_sql
    if explanations
      @explanation = explanations.first 
    
      @row_headers = [
        nil,
        "Select Type",
        "Table",
        "Type",
        "Possible Keys",
        "Key",
        "Key Length",
        "Ref",
        "Rows",
        "Extra"
      ];
    end
  end
  
  # show the selected source file with the highlighted selected line
  def show_source
    filename = params[:file]
    line_number = params[:line].to_i
    
    file = File.new(filename, 'r')
    @source = ""

    @source << "<pre>"
    file.each_line do |line|
      # place an anchor 6 lines above the selected line (if the line # < 6)
      if file.lineno == line_number - 6
        @source << "</pre><pre id = 'selected_line'>"
        @source << line.rstrip
        @source << "</pre><pre>"
       
      # highlight the selected line
      elsif file.lineno == line_number
        @source << "</pre><pre class = 'selected_source_line'>"
        @source << line.rstrip
        @source << "</pre><pre>"
      else
        @source << line
      end
    end
  end
  
private 
  def show_sample_data
    get_sample
    
    render :action => "sample_not_found" and return unless @sample 
    
    @request_params = @sample.params[:request_params] || {}
    controller_metric = @sample.root_segment.called_segments.first.metric_name
    
    controller_segments = controller_metric.split('/')
    @sample_controller_name = controller_segments[1..-2].join('/').camelize+"Controller"
    @sample_action_name = controller_segments[-1].underscore
    
    render :action => :show_sample
  end
  
  def get_samples
    @samples = NewRelic::Agent.instance.transaction_sampler.get_samples.select do |sample|
      sample.params[:path] != nil
    end
    
    @samples = @samples.reverse
  end
  
  def get_sample
    get_samples
    sample_id = params[:id].to_i
    @samples.each do |s|
      if s.sample_id == sample_id
        @sample = stripped_sample(s)
        return 
      end
    end
  end
  
  def get_segment
    get_sample
    return unless @sample
    
    segment_id = params[:segment].to_i
    @segment = @sample.find_segment(segment_id)
  end
end


