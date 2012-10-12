jQuery ->
  $("a.practice_area_name").live 'click', () ->
    $.cookie('practice_area', $(this).attr('data-practice-area'), { expires: 30, path: "/" })
  