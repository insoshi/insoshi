$( document ).ready(function() {
    $( document ).on('mousedown', '.save-action', function(e) {
       for (instance in CKEDITOR.instances)  {
           var editor = CKEDITOR.instances[instance];
           if (editor.checkDirty()) {
               editor.updateElement();
           };
       };
       return true;
    });
});