$ ->
  $('area', '#court').click ->
    alert $(this).attr('title')