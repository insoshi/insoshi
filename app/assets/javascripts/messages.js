
// See: http://stackoverflow.com/questions/4551230/bind-jquery-ui-autocomplete-using-live
$(function() {
	$(".recipient_autocomplete:not(.ui-autocomplete-input)").live("focus", function (event) {
		$(this).autocomplete({
			source: function(request, response) {
		        $.ajax({
		            url: "/messages/recipients.json",
		            dataType: "json",
		            data: {
		            	term: request.term, 
		                limit: 15
		            },
		            success: function(data) {
		                response($.map(data, function(item) {
		                    return {
		                        label: item.person.name,
		                        value: item.person.name,
		                        link: item.person.to_param
		                    }
		                }))
		            }
		        })
		    },
		    select: function(event, ui) {
		    	$('#recipient_autocomplete').val(ui.item.label);
		    	$('#recipient_avatar').attr('href', "/people/" + ui.item.link).attr('title', ui.item.label);
		    	$('#new_message').attr('action', '/people/' + ui.item.link + '/messages');
		    	return false;
		    }
		});
	});

	function placeholder(){  
        $("input[type=text]").each(function(){  
            var phvalue = $(this).attr("placeholder");  
            if ($(this).val() == "") {  
	            $(this).val(phvalue);  
	        }  
        });  
    }  
    placeholder();
    $("input[type=text]").live('focus', function() {
        var phvalue = $(this).attr("placeholder");  
        if (phvalue == $(this).val()) {  
        	$(this).val("");  
        }  
    });  
    $("input[type=text]").live('blur', function() {
        var phvalue = $(this).attr("placeholder");  
        if ($(this).val() == "") {  
            $(this).val(phvalue);  
        }  
    });
});