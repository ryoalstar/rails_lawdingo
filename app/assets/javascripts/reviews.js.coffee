jQuery ->
  ($ "#rating_stars").raty(
    path: "/assets/raty"
    hintList: ['', '', '', '', '', '']
    click: (score, event) -> 
      ($ "input#review_rating").val(score)
  )

  ($ "ul.reviews .review .rating").raty(
    path: "/assets/raty"
    readOnly: true
    start: -> ($ this).data("score")
  )