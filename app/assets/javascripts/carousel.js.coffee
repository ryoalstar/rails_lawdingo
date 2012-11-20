jQuery(document).ready ->
  jQuery('#mycarousel').jcarousel 
    wrap: 'circular'
    auto: 3
    scroll: 1
    itemLoadCallback: 
      onBeforeAnimation: (carousel, state) -> 
        JCcontainer = carousel.clip.context
        jQuery(JCcontainer).fadeOut()
      onAfterAnimation: (carousel, state) ->
        JCcontainer = carousel.clip.context
        jQuery(JCcontainer).fadeIn()

