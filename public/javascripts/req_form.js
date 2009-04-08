/*
 *
 */

jQuery(function($) { 

  function processPerson( n, peep ) {
    var previous_node_id = ( n == 0 ) ? "#followMe" : "#peep" + (n-1);
    if( "default_icon.png" == peep.icon )
    {
      peep.icon = "/images/" + peep.icon;
    }
    $("<div id=\"peep" + n + "\" style=\"float: left;\"></div>").insertAfter(previous_node_id);
    $('#peep' + n).html("<img src=\"" + peep.icon + "\" title=\"" + peep.name + "\"</>");
  }

  $("#req_due_date").datepicker({
buttonImage: "/images/calendar.gif",
buttonImageOnly: true
    });
  $("#req_category_ids").change( 
    function(){ var category_id = $(this).val();
                $.getJSON( '/categories/' + category_id, '', function(data){peeps = data.category.people;$.each(peeps,processPerson);});
              });
});
