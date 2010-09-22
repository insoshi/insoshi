/*
 *
 */

$(function() {
  $("#bid_expiration_date").datepicker({
buttonImage: "/images/calendar.gif",
buttonImageOnly: true
    });

  $.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
    });

  $("#new_bid").submit(function(){
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
  });
});
