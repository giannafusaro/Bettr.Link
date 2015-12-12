# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $('#link_url').focusout ->

    if $('#link_url').val()
      $.ajax
        url: "/parse/?url=#{encodeURIComponent($('#link_url').val())}"
        beforeSend: ->
          $('#status').text('Loading...')
        success: (data) ->
          $('#status').text('')
          console.log(data)
          large = 4
          for item in data.frequent_words
           for key, value of item
            $('ul#tag-options')
            .append """
              <li class='tag-option' style='font-size:#{value}em' >
                #{JSON.stringify(key)[1..-2]}
              </li>
            """
            .css 'display', 'flex'
