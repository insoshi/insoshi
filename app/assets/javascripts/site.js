$(document).ready(function(){
  // Style all submit buttons for UI consistency
  $('input[type=submit]').not('.button').addClass('button');
  $(document).bind('ajaxComplete', function() { 
    $('input[type=submit]').not('.button').addClass('button');  
  });
});


jQuery(document).ready(function() {
  jQuery("abbr.timeago").timeago();
});
