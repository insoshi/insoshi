module ActionView
	module Helpers
		
		module PrototypeHelper

			unless const_defined? :JQUERY_VAR
				JQUERY_VAR = '$'
			end
					
			unless const_defined? :JQCALLBACKS
				JQCALLBACKS = Set.new([ :beforeSend, :complete, :error, :success ] + (100..599).to_a)
				AJAX_OPTIONS = Set.new([ :before, :after, :condition, :url,
												 :asynchronous, :method, :insertion, :position,
												 :form, :with, :update, :script ]).merge(JQCALLBACKS)
			end
			
			def periodically_call_remote(options = {})
				frequency = options[:frequency] || 10 # every ten seconds by default
				code = "setInterval(function() {#{remote_function(options)}}, #{frequency} * 1000)"
				javascript_tag(code)
			end
			
			def remote_function(options)
				javascript_options = options_for_ajax(options)

				update = ''
				if options[:update] && options[:update].is_a?(Hash)
					update  = []
					update << "success:'#{options[:update][:success]}'" if options[:update][:success]
					update << "failure:'#{options[:update][:failure]}'" if options[:update][:failure]
					update  = '{' + update.join(',') + '}'
				elsif options[:update]
					update << "'#{options[:update]}'"
				end

				function = "#{JQUERY_VAR}.ajax(#{javascript_options})"

				function = "#{options[:before]}; #{function}" if options[:before]
				function = "#{function}; #{options[:after]}"  if options[:after]
				function = "if (#{options[:condition]}) { #{function}; }" if options[:condition]
				function = "if (confirm('#{escape_javascript(options[:confirm])}')) { #{function}; }" if options[:confirm]
				return function
			end
			
			class JavaScriptGenerator
				module GeneratorMethods
					
					def insert_html(position, id, *options_for_render)
						insertion = position.to_s.downcase
						insertion = 'append' if insertion == 'bottom'
						insertion = 'prepend' if insertion == 'top'
						call "#{JQUERY_VAR}(\"##{id}\").#{insertion}", render(*options_for_render)
					end
					
					def replace_html(id, *options_for_render)
						insert_html(:html, id, *options_for_render)
					end
					
					def replace(id, *options_for_render)
						call "#{JQUERY_VAR}(\"##{id}\").replaceWith", render(*options_for_render)
					end
					
					def remove(*ids)
						call "#{JQUERY_VAR}(\"##{ids.join(',#')}\").remove"
					end
					
					def show(*ids)
						call "#{JQUERY_VAR}(\"##{ids.join(',#')}\").show"
					end
					
					def hide(*ids)
						call "#{JQUERY_VAR}(\"##{ids.join(',#')}\").hide"
					end

					def toggle(*ids)
						call "#{JQUERY_VAR}(\"##{ids.join(',#')}\").toggle"
					end
					
				end
			end
			
		protected
			def options_for_ajax(options)
				js_options = build_callbacks(options)
				
				url_options = options[:url]
				url_options = url_options.merge(:escape => false) if url_options.is_a?(Hash)
				js_options['url'] = "'#{url_for(url_options)}'"
				js_options['async'] = options[:type] != :synchronous       
				js_options['type'] = options[:method] ? method_option_to_s(options[:method]) : ( options[:form] ? "'post'" : nil )
				js_options['dataType'] = options[:datatype] ? "'#{options[:datatype]}'" : (options[:update] ? nil : "'script'")
				
				if options[:form]
					js_options['data'] = "#{JQUERY_VAR}.param(#{JQUERY_VAR}(this).serializeArray())"
				elsif options[:submit]
					js_options['data'] = "#{JQUERY_VAR}(\"##{options[:submit]} :input\").serialize()"
				elsif options[:with]
					js_options['data'] = options[:with].gsub("Form.serialize(this.form)","#{JQUERY_VAR}.param(#{JQUERY_VAR}(this.form).serializeArray())")
				end
				
				if options[:method]
					if method_option_to_s(options[:method]) == "'put'" || method_option_to_s(options[:method]) == "'delete'"
						js_options['type'] = "'post'"
						if js_options['data']
							js_options['data'] << " + '&"
						else
							js_options['data'] = "'"
						end
						js_options['data'] << "_method=#{options[:method]}'"
					end
				end
				
				if respond_to?('protect_against_forgery?') && protect_against_forgery?
					if js_options['data']
						js_options['data'] << " + '&"
					else
						js_options['data'] = "'"
					end
					js_options['data'] << "#{request_forgery_protection_token}=' + encodeURIComponent('#{escape_javascript form_authenticity_token}')"
				end
			
				options_for_javascript(js_options.reject {|key, value| value.nil?})
			end
			
			def build_update_for_success(html_id, insertion=nil)
				insertion = build_insertion(insertion)
				"#{JQUERY_VAR}('##{html_id}').#{insertion}(request);"
			end

			def build_update_for_error(html_id, insertion=nil)
				insertion = build_insertion(insertion)
				"#{JQUERY_VAR}('##{html_id}').#{insertion}(request.responseText);"
			end

			def build_insertion(insertion)
				insertion ||= 'html'
				insertion = 'append' if insertion == 'bottom'
				insertion = 'prepend' if insertion == 'top'
				insertion.downcase
			end

			def build_observer(klass, name, options = {})
				if options[:with] && (options[:with] !~ /[\{=(.]/)
					options[:with] = "'#{options[:with]}=' + value"
				else
					options[:with] ||= 'value' unless options[:function]
				end

				callback = options[:function] || remote_function(options)
				javascript  = "#{JQUERY_VAR}(\"##{name}\").delayedObserver("
				javascript << "#{options[:frequency] || 0}, "
				javascript << "function(element, value) {"
				javascript << "#{callback}}"
				#javascript << ", '#{options[:on]}'" if options[:on]
				javascript << ")"
				javascript_tag(javascript)
			end
			
			def build_callbacks(options)
				callbacks = {}
				options[:beforeSend] = '';
				[:uninitialized,:loading,:loaded].each do |key|
					options[:beforeSend] << (options[key].last == ';' ? options.delete(key) : options.delete(key) << ';') if options[key]
				end
				options.delete(:beforeSend) if options[:beforeSend].blank?
				options[:error] = options.delete(:failure) if options[:failure]
				if options[:update]
					if options[:update].is_a?(Hash)
						options[:update][:error] = options[:update].delete(:failure) if options[:update][:failure]
						if options[:update][:success]
							options[:success] = build_update_for_success(options[:update][:success], options[:position]) << (options[:success] ? options[:success] : '')
						end
						if options[:update][:error]
							options[:error] = build_update_for_error(options[:update][:error], options[:position]) << (options[:error] ? options[:error] : '')
						end
					else
						options[:success] = build_update_for_success(options[:update], options[:position]) << (options[:success] ? options[:success] : '')
					end
				end
				options.each do |callback, code|
					if JQCALLBACKS.include?(callback)
						callbacks[callback] = "function(request){#{code}}"
					end
				end
				callbacks
			end
			
		end
		
		class JavaScriptElementProxy < JavaScriptProxy #:nodoc:
			def initialize(generator, id)
				@id = id
				super(generator, "#{JQUERY_VAR}(\"##{id}\")")
			end
			
			def replace_html(*options_for_render)
				call 'html', @generator.send(:render, *options_for_render)
			end

			def replace(*options_for_render)
				call 'replaceWith', @generator.send(:render, *options_for_render)
			end
			
			def value()
				call 'val()'
			end

			def value=(value)
				call 'val', value
			end
			
		end
		
		class JavaScriptElementCollectionProxy < JavaScriptCollectionProxy #:nodoc:\
			def initialize(generator, pattern)
				super(generator, "#{JQUERY_VAR}(#{pattern.to_json})")
			end
		end
		
		module ScriptaculousHelper
			
			unless const_defined? :JQUERY_VAR
				JQUERY_VAR = ActionView::Helpers::PrototypeHelper::JQUERY_VAR
			end
			
			unless const_defined? :TOGGLE_EFFECTS
				TOGGLE_EFFECTS = [:toggle_appear, :toggle_slide, :toggle_blind]
			end
			
			unless const_defined? :SCRIPTACULOUS_EFFECTS
				SCRIPTACULOUS_EFFECTS = {
					:appear => {:method => 'fade', :options => {:mode => 'show'}},
					:blind_down => {:method => 'blind', :options => {:direction => 'vertical', :mode => 'show'}},
					:blind_up => {:method => 'blind', :options => {:direction => 'vertical', :mode => 'hide'}},
					:blind_right => {:method => 'blind', :options => {:direction => 'horizontal', :mode => 'show'}},
					:blind_left => {:method => 'blind', :options => {:direction => 'horizontal', :mode => 'hide'}},
					:bounce_in => {:method => 'bounce', :options => {:direction => 'up', :mode => 'show'}},
					:bounce_out => {:method => 'bounce', :options => {:direction => 'up', :mode => 'hide'}},
					:drop_in => {:method => 'drop', :options => {:direction => 'up', :mode => 'show'}},
					:drop_out => {:method => 'drop', :options => {:direction => 'down', :mode => 'hide'}},
					:fold_in => {:method => 'fold', :options => {:mode => 'hide'}},
					:fold_out => {:method => 'fold', :options => {:mode => 'show'}},
					:grow => {:method => 'scale', :options => {:mode => 'show'}},
					:shrink => {:method => 'scale', :options => {:mode => 'hide'}},
					:slide_down => {:method => 'slide', :options => {:direction => 'up', :mode => 'show'}},
					:slide_up => {:method => 'slide', :options => {:direction => 'up', :mode => 'hide'}},
					:slide_right => {:method => 'slide', :options => {:direction => 'left', :mode => 'show'}},
					:slide_left => {:method => 'slide', :options => {:direction => 'left', :mode => 'hide'}},
					:squish => {:method => 'scale', :options => {:origin => '["top","left"]', :mode => 'hide'}},
					:switch_on => {:method => 'clip', :options => {:direction => 'vertical', :mode => 'show'}},
					:switch_off => {:method => 'clip', :options => {:direction => 'vertical', :mode => 'hide'}}
				}
			end
			
			def visual_effect(name, element_id = false, js_options = {})
				element = element_id ? element_id : "this"
				
				if SCRIPTACULOUS_EFFECTS.has_key? name.to_sym
					effect = SCRIPTACULOUS_EFFECTS[name.to_sym]
					name = effect[:method]
					js_options = js_options.merge effect[:options]
				end
				
				[:color, :direction, :mode].each do |option|
					js_options[option] = "\"#{js_options[option]}\"" if js_options[option]
				end
				
				if js_options.has_key? :duration
					speed = js_options.delete :duration
					speed = (speed * 1000).to_i unless speed.nil?
				else
					speed = js_options.delete :speed
				end
				
				#if TOGGLE_EFFECTS.include? name.to_sym
				#  "Effect.toggle(#{element},'#{name.to_s.gsub(/^toggle_/,'')}',#{options_for_javascript(js_options)});"
				
				javascript = "#{JQUERY_VAR}(\"##{element_id}\").effect(\"#{name.to_s.downcase}\""
				javascript << ",#{options_for_javascript(js_options)}" unless speed.nil? && js_options.empty?
				javascript << ",#{speed}" unless speed.nil?
				javascript << ")"
				
			end
			
			def sortable_element_js(element_id, options = {}) #:nodoc:
				#convert similar attributes
				options[:items] = options[:only] if options[:only]
				
				if options[:onUpdate] || options[:url]
					options[:with] ||= "#{JQUERY_VAR}(this).sortable('serialize')"
					options[:onUpdate] ||= "function(){" + remote_function(options) + "}"
				end
				
				options.delete_if { |key, value| PrototypeHelper::AJAX_OPTIONS.include?(key) }
				options[:update] = options.delete(:onUpdate) if options[:onUpdate]
				
				[:handle].each do |option|
					options[option] = "'#{options[option]}'" if options[option]
				end
				
				options[:containment] = array_or_string_for_javascript(options[:containment]) if options[:containment]
				options[:items] = array_or_string_for_javascript(options[:items]) if options[:items]
	
				%(#{JQUERY_VAR}("##{element_id}").sortable(#{options_for_javascript(options)});)
			end
			
			def draggable_element_js(element_id, options = {})
				%(#{JQUERY_VAR}("##{element_id}").draggable(#{options_for_javascript(options)});)
			end
			
			def drop_receiving_element_js(element_id, options = {})
				#convert similar options
				options[:hoverClass] = options.delete(:hoverclass) if options[:hoverclass]
				options[:drop] = options.delete(:onDrop) if options[:onDrop]
				
				if options[:drop] || options[:url]
					options[:with] ||= "'id=' + encodeURIComponent(#{JQUERY_VAR}(ui.draggable).attr('id'))"
					options[:drop] ||= "function(ev, ui){" + remote_function(options) + "}"
				end
				
				options.delete_if { |key, value| PrototypeHelper::AJAX_OPTIONS.include?(key) }

				options[:accept] = array_or_string_for_javascript(options[:accept]) if options[:accept]    
				options[:hoverClass] = "'#{options[:hoverClass]}'" if options[:hoverClass]
				
				%(#{JQUERY_VAR}("##{element_id}").droppable(#{options_for_javascript(options)});)
			end
			
		end
		
	end
end
