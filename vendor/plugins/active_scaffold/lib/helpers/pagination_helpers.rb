module ActiveScaffold
  module Helpers
    module Pagination
      def pagination_ajax_link(page_number, params)
        page_link = link_to_remote(page_number,
                  { :url => params.merge(:page => page_number),
                    :after => "$('#{loading_indicator_id(:action => :pagination)}').style.visibility = 'visible';",
                    :complete => "$('#{loading_indicator_id(:action => :pagination)}').style.visibility = 'hidden';",
                    :update => active_scaffold_content_id,
                    :failure => "ActiveScaffold.report_500_response('#{active_scaffold_id}')",
                    :method => :get },
                  { :href => url_for(params.merge(:page => page_number)) })
      end

      def pagination_ajax_links(current_page, params)
        start_number = current_page.number - 2
        end_number = current_page.number + 2
        start_number = 1 if start_number <= 0
        end_number = current_page.pager.last.number if end_number > current_page.pager.last.number

        html = []
        html << pagination_ajax_link(1, params) unless current_page.number <= 3
        html << ".." unless current_page.number <= 4
        start_number.upto(end_number) do |num|
          if current_page.number == num
            html << num
          else
            html << pagination_ajax_link(num, params)
          end
        end
        html << ".." unless current_page.number >= current_page.pager.last.number - 3
        html << pagination_ajax_link(current_page.pager.last.number, params) unless current_page.number >= current_page.pager.last.number - 2
        html.join(' ')
      end
    end
  end
end