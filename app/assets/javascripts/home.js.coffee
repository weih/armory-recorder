# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
    $('#character_server').chosen()

    $("#new_character").submit ->
      $('#search_char').button('loading')
      # $("#search_char").val("查询中...")