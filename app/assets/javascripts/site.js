$(document).ready(function(){
  $('#sfmenu li ul').css({
    display: "none",
    left: "auto"
  });
  $('#sfmenu li').hover(function() {
    $(this)
      .find('ul')
      .stop(true, true)
      .slideDown('fast');
  }, function() {
    $(this)
      .find('ul')
      .stop(true,true)
      .fadeOut('fast');
  });

  // Style all submit buttons for UI consistency
  $('input[type=submit]').not('.button').addClass('button');
  $(document).bind('ajaxComplete', function() { 
    $('input[type=submit]').not('.button').addClass('button');  
  });
});
