/*
 *
 */
$(function(){$("#bid_expiration_date").datepicker({buttonImage:"/images/calendar.gif",buttonImageOnly:!0}),$.ajaxSetup({beforeSend:function(e){e.setRequestHeader("Accept","text/javascript")}}),$("#new_bid").submit(function(){return $("span.wait").show(),$.post($(this).attr("action"),$(this).serialize(),null,"script"),!1})});