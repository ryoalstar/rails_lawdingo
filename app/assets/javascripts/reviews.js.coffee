jQuery ->
  ($ "#rating_stars").raty(
    path: "/assets/raty"
    hintList: ['', '', '', '', '', '']
    click: (score, event) -> 
      ($ "input#review_rating").val(score)
  )
