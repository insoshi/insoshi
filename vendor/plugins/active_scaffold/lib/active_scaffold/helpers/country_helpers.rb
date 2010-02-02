I18n.load_path << File.dirname(__FILE__) + '/../../../lib/active_scaffold/locale/en-countries.yml'

module ActiveScaffold
  module Helpers
    module CountryHelpers
      # Return select and option tags for the given object and method, using country_options_for_select to generate the list of option tags.
      def country_select(object, method, priority_countries = nil, options = {}, html_options = {})
        ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end

      def usa_state_select(object, method, priority_states = nil, options = {}, html_options = {})
        ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_usa_state_select_tag(priority_states, options, html_options)
      end

      # Returns a string of option tags for pretty much any country in the world. Supply a country name as +selected+ to
      # have it marked as the selected option tag. You can also supply an array of countries as +priority_countries+, so
      # that they will be listed above the rest of the (long) list.
      #
      # NOTE: Only the option tags are returned, you have to wrap this call in a regular HTML select tag.
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_options = ""

        if priority_countries
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

        return country_options + options_for_select(COUNTRIES.collect {|country| [I18n.t("countries.#{country}"), country]}, selected)
      end

      # Returns a string of option tags for the states in the United States. Supply a state name as +selected to
      # have it marked as the selected option tag. Included also is the option to set a couple of +priority_states+ 
      # in case you want to highligh a local area
      # NOTE: Only the option tags are returned from this method, wrap it in a <select>
      def usa_state_options_for_select(selected = nil, priority_states = nil)
        state_options = ""
        if priority_states
          state_options += options_for_select(priority_states, selected)
          state_options += "<option>-------------</option>\n"
        end

        if priority_states && priority_states.include?(selected)
          state_options += options_for_select(USASTATES - priority_states, selected)
        else
          state_options += options_for_select(USASTATES, selected)
        end

        return state_options
      end
            # All the countries included in the country_options output.
            COUNTRIES = [
      :afghanistan,                                    
      :aland_islands,                                  
      :albania,                                        
      :algeria,                                        
      :american_samoa,                                 
      :andorra,                                        
      :angola,                                         
      :anguilla,                                       
      :antarctica,                                     
      :antigua_and_barbuda,                            
      :argentina,                                      
      :armenia,                                        
      :aruba,                                          
      :australia,                                      
      :austria,                                        
      :azerbaijan,                                     
      :bahamas,                                        
      :bahrain,                                        
      :bangladesh,                                     
      :barbados,                                       
      :belarus,                                        
      :belgium,                                        
      :belize,                                         
      :benin,                                          
      :bermuda,                                        
      :bhutan,                                         
      :bolivia,                                        
      :bosnia_and_herzegowina,                         
      :botswana,                                       
      :bouvet_island,                                  
      :brazil,                                         
      :british_indian_ocean_territory,                 
      :brunei_darussalam,                              
      :bulgaria,                                       
      :burkina_faso,                                   
      :burundi,                                        
      :cambodia,                                       
      :cameroon,                                       
      :canada,                                         
      :cape_verde,                                     
      :cayman_islands,                                 
      :central_african_republic,                       
      :chad,                                           
      :chile,                                          
      :china,                                          
      :christmas_island,                               
      :cocos_keeling_islands,                        
      :colombia,                                       
      :comoros,                                        
      :congo,                                          
      :congo_the_democratic_republic_of_the,           
      :cook_islands,                                   
      :costa_rica,                                     
      :cote_divoire,                                  
      :croatia,                                        
      :cuba,                                           
      :cyprus,                                         
      :czech_republic,                                 
      :denmark,                                        
      :djibouti,                                       
      :dominica,                                       
      :dominican_republic,                             
      :ecuador,                                        
      :egypt,                                          
      :el_salvador,                                    
      :equatorial_guinea,                              
      :eritrea,                                        
      :estonia,                                        
      :ethiopia,                                       
      :falkland_islands_malvinas,                      
      :faroe_islands,                                  
      :fiji,                                           
      :finland,                                        
      :france,                                         
      :french_guiana,                                  
      :french_polynesia,                               
      :french_southern_territories,                    
      :gabon,                                          
      :gambia,                                         
      :georgia,                                        
      :germany,                                        
      :ghana,                                          
      :gibraltar,                                      
      :greece,                                         
      :greenland,                                      
      :grenada,                                        
      :guadeloupe,                                     
      :guam,                                           
      :guatemala,                                      
      :guernsey,                                       
      :guinea,                                         
      :guinea_bissau,                                  
      :guyana,                                         
      :haiti,                                          
      :heard_and_mcdonald_islands,                     
      :holy_see_vatican_city_state,                    
      :honduras,                                       
      :hong_kong,                                      
      :hungary,                                        
      :iceland,                                        
      :india,                                          
      :indonesia,                                      
      :iran_islamic_republic_of,                       
      :iraq,                                           
      :ireland,                                        
      :isle_of_man,                                    
      :israel,                                         
      :italy,                                          
      :jamaica,                                        
      :japan,                                          
      :jersey,                                         
      :jordan,                                         
      :kazakhstan,                                     
      :kenya,                                          
      :kiribati,                                       
      :korea_democratic_peoples_republic_of,          
      :korea_republic_of,                              
      :kuwait,                                         
      :kyrgyzstan,                                     
      :lao_peoples_democratic_republic,               
      :latvia,                                         
      :lebanon,                                        
      :lesotho,                                        
      :liberia,                                        
      :libyan_arab_jamahiriya,                         
      :liechtenstein,                                  
      :lithuania,                                      
      :luxembourg,                                     
      :macao,                                          
      :macedonia_the_former_yugoslav_republic_of,      
      :madagascar,                                     
      :malawi,                                         
      :malaysia,                                       
      :maldives,                                       
      :mali,                                           
      :malta,                                          
      :marshall_islands,                               
      :martinique,                                     
      :mauritania,                                     
      :mauritius,                                      
      :mayotte,                                        
      :mexico,                                         
      :micronesia_federated_states_of,                 
      :moldova_republic_of,                            
      :monaco,                                         
      :mongolia,                                       
      :montenegro,                                     
      :montserrat,                                     
      :morocco,                                        
      :mozambique,                                     
      :myanmar,                                        
      :namibia,                                        
      :nauru,                                          
      :nepal,                                          
      :netherlands,                                    
      :netherlands_antilles,                           
      :new_caledonia,                                  
      :new_zealand,                                    
      :nicaragua,                                      
      :niger,                                          
      :nigeria,                                        
      :niue,                                           
      :norfolk_island,                                 
      :northern_mariana_islands,                       
      :norway,                                         
      :oman,                                           
      :pakistan,                                       
      :palau,                                          
      :palestinian_territory_occupied,                 
      :panama,                                         
      :papua_new_guinea,                               
      :paraguay,                                       
      :peru,                                           
      :philippines,                                    
      :pitcairn,                                       
      :poland,                                         
      :portugal,                                       
      :puerto_rico,                                    
      :qatar,                                          
      :reunion,                                        
      :romania,                                        
      :russian_federation,                             
      :rwanda,                                         
      :saint_barthelemy,                               
      :saint_helena,                                   
      :saint_kitts_and_nevis,                          
      :saint_lucia,                                    
      :saint_pierre_and_miquelon,                      
      :saint_vincent_and_the_grenadines,               
      :samoa,                                          
      :san_marino,                                     
      :sao_tome_and_principe,                          
      :saudi_arabia,                                   
      :senegal,                                        
      :serbia,                                         
      :seychelles,                                     
      :sierra_leone,                                   
      :singapore,                                      
      :slovakia,                                       
      :slovenia,                                       
      :solomon_islands,                                
      :somalia,                                        
      :south_africa,                                   
      :south_georgia_and_the_south_sandwich_islands,   
      :spain,                                          
      :sri_lanka,                                      
      :sudan,                                          
      :suriname,                                       
      :svalbard_and_jan_mayen,                         
      :swaziland,                                      
      :sweden,                                         
      :switzerland,                                    
      :syrian_arab_republic,                           
      :taiwan_province_of_china,                       
      :tajikistan,                                     
      :tanzania_united_republic_of,                    
      :thailand,                                       
      :timor_leste,                                    
      :togo,                                           
      :tokelau,                                        
      :tonga,                                          
      :trinidad_and_tobago,                            
      :tunisia,                                        
      :turkey,                                         
      :turkmenistan,                                   
      :turks_and_caicos_islands,                       
      :tuvalu,                                         
      :uganda,                                         
      :ukraine,                                        
      :united_arab_emirates,                           
      :united_kingdom,                                 
      :united_states,                                  
      :united_states_minor_outlying_islands,           
      :uruguay,                                        
      :uzbekistan,                                     
      :vanuatu,                                        
      :venezuela,                                      
      :viet_nam,                                       
      :virgin_islands_british,                         
      :virgin_islands_us,                              
      :wallis_and_futuna,                              
      :western_sahara,                                 
      :yemen,                                          
      :zambia,                                         
      :zimbabwe] unless const_defined?("COUNTRIES")


    	USASTATES = [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["Arkansas", "AR"], ["California", "CA"], ["Colorado", "CO"], ["Connecticut", "CT"], ["Delaware", "DE"], ["District of Columbia", "DC"], ["Florida", "FL"], ["Georgia", "GA"], ["Hawaii", "HI"], ["Idaho", "ID"], ["Illinois", "IL"], ["Indiana", "IN"], ["Iowa", "IA"], ["Kansas", "KS"], ["Kentucky", "KY"], ["Louisiana", "LA"], ["Maine", "ME"], ["Maryland", "MD"], ["Massachusetts", "MA"], ["Michigan", "MI"], ["Minnesota", "MN"], ["Mississippi", "MS"], ["Missouri", "MO"], ["Montana", "MT"], ["Nebraska", "NE"], ["Nevada", "NV"], ["New Hampshire", "NH"], ["New Jersey", "NJ"], ["New Mexico", "NM"], ["New York", "NY"], ["North Carolina", "NC"], ["North Dakota", "ND"], ["Ohio", "OH"], ["Oklahoma", "OK"], ["Oregon", "OR"], ["Pennsylvania", "PA"], ["Rhode Island", "RI"], ["South Carolina", "SC"], ["South Dakota", "SD"], ["Tennessee", "TN"], ["Texas", "TX"], ["Utah", "UT"], ["Vermont", "VT"], ["Virginia", "VA"], ["Washington", "WA"], ["Wisconsin", "WI"], ["West Virginia", "WV"], ["Wyoming", "WY"]] unless const_defined?("USASTATES")

      class ActionView::Helpers::InstanceTag #:nodoc:
        include CountryHelpers

        def to_country_select_tag(priority_countries, options, html_options)
          html_options = html_options.stringify_keys
          add_default_name_and_id(html_options)
          value = value(object)
          content_tag("select",
            add_options(
              country_options_for_select(value, priority_countries),
              options, value
            ), html_options
          )
        end

        def to_usa_state_select_tag(priority_states, options, html_options)
          html_options = html_options.stringify_keys
          add_default_name_and_id(html_options)
          value = value(object) if method(:value).arity > 0
          if html_options[:name.to_s].include?('search')
            html_options[:name.to_s] << '[]' 
            html_options[:multiple] = true
            options[:include_blank] = true
          end
          content_tag("select", add_options(usa_state_options_for_select(value, priority_states), options, value), html_options)
        end
      end
    end
    
    module FormColumnHelpers
      def active_scaffold_input_country(column, options)
        priority = ["United States"]
        select_options = {:prompt => as_(:_select_)}
        select_options.merge!(options)
        country_select(:record, column.name, column.options[:priority] || priority, select_options, column.options)
      end

      def active_scaffold_input_usa_state(column, options)
        select_options = {:prompt => as_(:_select_)}
        select_options.merge!(options)
        select_options.delete(:size)
        options.delete(:prompt)
        options.delete(:priority)
        usa_state_select(:record, column.name, column.options[:priority], select_options, column.options.merge!(options))
      end
    end
  end
end