#
# @author     Ziyan-Junaideen <jdeen-solutions@outlook.com>
# @class      LinksOnNewWindow
# @classdesc  LinksOnNewWindow when intilized will scan the document for contianers
#             with the data attribute data-links-new-window='true' and converts all
#             links in that window to open in a new window.
#             
#             On AJAX complete it will re eavaluate the links as
# @example    
#   <div data-links-new-window="true">
#     <a href="http://www.bing.com">
#       Bing it!
#     </a>
#   </div>
#   
# @requires   jQuery
# @version    0.1.1
# 
# @todo       Ability to skip a link within a considered container
# @todo       May be a good idea to tag a dom that its `processed` incase a rouge 
#             jQuery action ajax or PJAX coudl tirgger an unnecessary re-processing     
#                    
class window.LinksOnNewWindow
  constructor: () ->
    console.log "Initilizing links on new window!" if console && console.log 
    @bind()
    @process()

  bind: () ->
    self = @

    # AJAX Loading ~ may be there are links / html comming in the content
    $(document).ajaxComplete () ->
      self.process()

    # PJAX Loading - TODO - Test ( written looking at the documentation of PJAX )
    # NOTE: Commented as not required for `oscurrency` by VRL
    # $(document).on 'pjax:end', () ->
    #   self.process()
    return

  process: () ->
    containers = $('[data-links-new-window="true"]')
    console.log containers
    for container in containers
      console.log $( 'a', container )
      $( 'a', container ).attr('target', '_blank')
    return

# Trigger the class when the DOM is ready, from there on ward
$(document).ready () ->
  window.links_on_new_window = new LinksOnNewWindow()
  return