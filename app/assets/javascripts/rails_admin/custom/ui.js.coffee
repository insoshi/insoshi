#= require_tree .
#= require simplemde/dist/simplemde.min
#= require_self

$(document).on 'ready pjax:success', ->
  new SimpleMDE({ element: document.getElementById("offer_description") }) if $('#offer_description')
  new SimpleMDE({ element: document.getElementById("preference_login_intro") }) if $('#preference_login_intro')
  new SimpleMDE({ element: document.getElementById("preference_category_intro") }) if $('#preference_category_intro')

