/*
 *
 */
$(function() { 

  function processPerson( n, peep ) {
    if( peep.deactivated )
    {
      return;
    }

    // make sure this peep isn't already on list
    //
    for(var k = 0; k < OSCURRENCY.peeps.length; k++)
    {
      if(peep.id == OSCURRENCY.peeps[k].id)
      {
        return;
      }
    }

    if( peep.notifications )
    {
      var previous_node_id = ( OSCURRENCY.peeps.length == 0 ) ? "#followMe" : "#peep" + OSCURRENCY.peeps[OSCURRENCY.peeps.length-1].id;

      OSCURRENCY.peeps.push(peep);

      if( "default_icon.png" == peep.icon )
      {
        peep.icon = "/images/" + peep.icon;
      }
      $("<div id=\"peep" + peep.id + "\" class=\"peepnode\" style=\"float: left;\"></div>").insertAfter(previous_node_id);
      $('#peep' + peep.id).html("<img src=\"" + peep.icon + "\" title=\"" + peep.name + "\"</>");
    }
  }

  function processJSONResponse(data) {
    OSCURRENCY.category_people[OSCURRENCY.i] = data.category.people;
    OSCURRENCY.i++;
    if( OSCURRENCY.category_ids.length == OSCURRENCY.i )
    {
      $('.thinking').remove();
      for(var j = 0; j < OSCURRENCY.category_ids.length; j++)
      {
        $.each(OSCURRENCY.category_people[j],processPerson);
      }
    }
    else
    {
      $.getJSON( '/categories/' + OSCURRENCY.category_ids[OSCURRENCY.i], '', processJSONResponse);
    }
  }

  $("#req_due_date").datepicker({
buttonImage: "/images/calendar.gif",
buttonImageOnly: true
    });

  $("#req_category_ids").change( 
    function(){ $("<div class=\"thinking\"></div>").insertAfter("#followMe");
                OSCURRENCY.category_ids = $(this).val();
                OSCURRENCY.category_people = [];
                $('.peepnode').remove();
                OSCURRENCY.i = 0; // category counter
                OSCURRENCY.peeps = [];
                $.getJSON( '/categories/' + OSCURRENCY.category_ids[OSCURRENCY.i], '', processJSONResponse);
              });
});
