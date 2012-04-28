
$(document).ready(function(){
	$('.avatar img, .image-carousel img').each(function(){
		var imgsrc = $(this).attr('src');
		var imgcheck = imgsrc.width;


		$(this).live("error", function() {
		  $(this).attr('src', '/assets/profile_m.gif');
		});
	});
	
	$("input[name='practice_area']").imageTick({
		tick_image_path: "/assets/radio_selected.png",
		no_tick_image_path: "/assets/radio.png",
		image_tick_class: "radios"
	});   	
	$("span.video.online").live('mouseover', function(){
	  $(this).nextAll(".video_chat.tooltip.online").fadeIn('slow');
	});
	$("span.video.online").live('mouseout', function(){
	  $(this).nextAll(".video_chat.tooltip.online").fadeOut('slow');
	});
	$("span.voice.online").live('mouseover', function(){
	  $(this).nextAll(".voice_chat.tooltip.online").fadeIn('slow');
	});
	$("span.voice.online").live('mouseout', function(){
	  $(this).nextAll(".voice_chat.tooltip.online").fadeOut('slow');
	});
	
	$("span.video.offline").live('mouseover', function(){
	  $(this).nextAll(".video_chat.tooltip.offline").fadeIn('slow');
	});
	$("span.video.offline").live('mouseout', function(){
	  $(this).nextAll(".video_chat.tooltip.offline").fadeOut('slow');
	});
	$("span.voice.offline").live('mouseover', function(){
	  $(this).nextAll(".voice_chat.tooltip.offline").fadeIn('slow');
	});
	$("span.voice.offline").live('mouseout', function(){
	  $(this).nextAll(".voice_chat.tooltip.offline").fadeOut('slow');
	});  	

	
	
	$(".free").live('mouseenter', function(){
			$(".button_tooltip").hide();
	    $(this).nextAll(".button_tooltip").show();
	});
/*	$(".free").live('mouseout', function(){
		  $(this).nextAll(".button_tooltip:visible").hide();
	});*/
	/*$(".button_tooltip *").live('mouseover', function() {
		$(this).parent().show();
	})*/
	
	$(".button_tooltip").live('mouseleave', function() {
			$(this).hide();
	});
	$( "#slider-range-min" ).slider({
	  range: "min",
    value: 37,
    min: 1,
    max: 700,
    slide: function( event, ui ) {
      $( "#amount" ).val( "$" + ui.value );
  }
  });
  $( "#free_minutes_slider" ).slider({
    range: "min",
    value: 2,
    min: 1,
    max: 8,
    slide: function( event, ui ) {
      $( "#minutes" ).val( "$" + ui.value );
    }
  });
  $( "#minutes" ).val( "$" + $( "#free_minutes_slider" ).slider( "value" ) );
  
  $( "#minimum_client_rating" ).slider({
    range: "min",
    value: 2,
    min: 1,
    max: 5,
    slide: function( event, ui ) {
      $( "#client_rating" ).val( "$" + ui.value );
    }
  });
  $( "#client_rating" ).val( "$" + $( "#minimum_client_rating" ).slider( "value" ) );
  
  $( "#hourly_rate" ).slider({
    range: true,
    values: [ 2, 3 ],
    min: 1,
    max: 4,
    slide: function( event, ui ) {
      $( "#hourly_rate_in" ).val( "$" + ui.value );
    }
  });
  $( "#hourly_rate_in" ).val( "$" + $( "#hourly_rate" ).slider( "value" ) );   
  
  $( "#law_school_quality" ).slider({
    range: "min",
    value: 2,
    min: 1,
    max: 4,
    slide: function( event, ui ) {
      $( "#law_school" ).val( "$" + ui.value );
    }
  });
  $( "#law_school" ).val( "$" + $( "#law_school_quality" ).slider( "value" ) );     
});