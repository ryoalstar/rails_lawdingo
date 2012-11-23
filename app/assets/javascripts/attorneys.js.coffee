jQuery ->
  $("a.practice_area_name").live 'click', () ->
    $.cookie('practice_area', $(this).attr('data-practice-area'), { expires: 30, path: "/" })
  $("a.only_for_client").live 'click', () ->
    alert "Sorry, only clients can contact lawyers; lawyers can't contact other lawyers."
