$( document ).live('rails_admin.dom_ready', function() {
	setTimeout(function() {
		CKEDITOR.replace( 'form[title]' );
		CKEDITOR.replace( 'form[text]' );
	},2000);
});