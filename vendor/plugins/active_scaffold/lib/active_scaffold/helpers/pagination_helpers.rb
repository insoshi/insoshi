module ActiveScaffold
  module Helpers
    module PaginationHelpers
      def pagination_ajax_link(page_number, params)
        url = url_for params.merge(:page => page_number)
        page_link = link_to_remote(page_number,
                  { :url => url,
                    :before => "addActiveScaffoldPageToHistory('#{url}', '#{controller_id}');",
                    :after => "$('#{loading_indicator_id(:action => :pagination)}').style.visibility = 'visible';",
                    :complete => "$('#{loading_indicator_id(:action => :pagination)}').style.visibility = 'hidden';",
                    :failure => "ActiveScaffold.report_500_response('#{active_scaffold_id}')",
                    :method => :get },
                  { :href => url_for(params.merge(:page => page_number)) })
      end

      def pagination_ajax_links(current_page, params, window_size)
        start_number = current_page.number - window_size
        end_number = current_page.number + window_size
        start_number = 1 if start_number <= 0
        if current_page.pager.infinite?
          offsets = [20, 100]
        else
          end_number = current_page.pager.last.number if end_number > current_page.pager.last.number
        end

        html = []
        unless start_number == 1
          last_page = 1
          html << pagination_ajax_link(last_page, params)
          if current_page.pager.infinite?
            offsets.reverse.each do |offset|
              page = current_page.number - offset
              if page < start_number && page > 1
                html << '..' if page > last_page + 1
                html << pagination_ajax_link(page, params)
                last_page = page
              end
            end
          end
          html << ".." if start_number > last_page + 1
        end

        start_number.upto(end_number) do |num|
          if current_page.number == num
            html << num
          else
            html << pagination_ajax_link(num, params)
          end
        end

        if current_page.pager.infinite?
          offsets.each do |offset|
            html << '..' << pagination_ajax_link(current_page.number + offset, params)
          end
        else
          html << ".." unless end_number >= current_page.pager.last.number - 1
          html << pagination_ajax_link(current_page.pager.last.number, params) unless end_number == current_page.pager.last.number
        end
        html.join(' ')
      end
    end
  end
end
