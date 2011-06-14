/*
 *
 */

$(function() {
  $("#tabs").tabs();
  // render jquery tabs - they are created with "display: none" to prevent FOUC
  $('ul.ui-tabs-nav').show();
});
