$(document).ready ->

  $('input.signup').focusout ->
    $(@).toggleClass('filled', (@.value.length != 0))
