#= require_tree .
#= require simplemde/dist/simplemde.min
#= require_self

$(document).ready ->
  new SimpleMDE({ element: document.getElementById("offer_description") }) if $('#offer_description')
