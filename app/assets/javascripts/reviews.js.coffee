jQuery ->
  ($ "#rating_stars").raty(
    path: "/assets/raty"
    click: (score, event) -> 
      ($ "input#review_rating").val(score)
  )
