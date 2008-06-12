// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {
  // sets up the Profile page tabs
  $("#tabCol > ul").tabs();

  // sets up the hover image for activity feed items	
  $(".imgHoverMarker").tooltip({
	showURL: false,
	bodyHandler: function() {
	  var i = $(this).children()[0]
	  var imgsrc = $(i).attr('src');
	  return $('<img src="'+imgsrc+'" />');
	}
  });

  $('input,textarea').focus( function() {
	$(this).css('border-color', '#006699');
  });
  $('input,textarea').blur( function() {
	$(this).css('border-color','#ccc');
  });

/*  $('#tContacts div.pagination a').livequery('click', function() {
    $('#contacts_grid').load(this.href);
    return false;
  });

  // Setup Rails so ajax requests trigger the wants.js block in respond_to
  // http://ozmm.org/posts/$_and_respond_to.html
  $.ajaxSetup({ 
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")} 
  });*/
});

/*document.observe("dom:loaded", function() {
  var container = $(document.body)

  container.observe('click', function(e) {
    var el = e.element()
    if (el.match('.pagination a')) {
      new Ajax.Request(el.href, { method: 'get' })
      e.stop()
    }
  })
})*/