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
});
