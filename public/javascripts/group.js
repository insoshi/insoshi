$(function() {
  $("#tabs").tabs({
    fx: {}
    });

  $("input#bid_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $("input#req_due_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $("input#offer_expiration_date").live('focus', function() {
    $(this).datepicker({
      buttonImage: "/images/calendar.gif",
      buttonImageOnly: true
      });
    });

  $.ajaxSetup({
    'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
    });

  $("#new_bid").live('submit',function(){
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
  });

  $(".edit_bid").live('submit',function(){
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
  });

  $('#new_req, #new_offer, #new_topic, #new_post, #new_exchange, #new_wall_post').live('submit',function() {
    $('span.wait').show();
    $.post($(this).attr('action'),$(this).serialize(),null,'script');
    return false;
    });

  $('.add_to_memberships').live('click', function() {
      id_name = $(this).children('a').attr('id');
      $(this).parent().children('.wait').show();
      $(this).hide();
      var data = (id_name == 'leave_group') ? {'_method': 'delete'} : {};
      $.post($(this).children('a').attr('href'),data,null,'script');
      return false;
    });

  $('a.pay_now').live('click', function() {
    $('span.wait').show();
    $.getScript(this.href);
    return false;
    });

  $('.pagination a').live('click',function() {
    $('span.wait').show();
    $.getScript(this.href);
    return false;
    });

  $('a[href=#forum]').bind('click',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=forum');
    $('#forum_form').html('');
    });

  $('a[href=#requests]').bind('click',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=requests');
    });

  $('a[href=#offers]').bind('click',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=offers');
    });

  $('a[href=#exchanges]').bind('click',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=exchanges');
    });

  $('a[href=#people]').bind('click',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=people');
    });

  $('.category_filter #req_category_ids').live('change',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=requests&category_id='+this.value);
    });

  $('.category_filter #offer_category_ids').live('change',function() {
    $('span.wait').show();
    $.getScript(document.location.href+'?tab=offers&category_id='+this.value);
    });

  $('a.show-follow').live('click',function() {
    $('span.wait').show();
    $.getScript(this.href);
    return false;
    });
});
