 $('#outer_div').css({"border":"solid #000 2px","padding":"2px"});
 var messageString = "";
 var isOverlayOpen = false;
//functions to bring up and collapse the video chat screen for lawyer

function CloseCall()
{
    closecall();
}
function equalHeight(group) {
    tallest = 0;
    group.each(function() {
       thisHeight = $(this).height();
       if(thisHeight > tallest) {
          tallest = thisHeight;
       }
    });
    group.height(tallest);
  }
  $(window).load(function() {
    $('.row').each(function(){
      equalHeight($(this).find(".row_block"));
    });
    equalHeight($('.profile').find(".same_height"));
  });
function notifyUser(msg)
{
  if(!msg.search("ErrorMessage")){
    $.prompt(msg)
  }
}

function showFlash()
{
  // Centering video chat box wrapper
  $('#outer_div').css({
    "position": "absolute",
    "top": "62px",
    "left": "50%",
    "width": "960px",
    "height": "800px",
      "margin-left": "-480px"
  });
  //$('.mainc').css("display","none");
}

function updateFlash()
{
   var movie = swfobject.getObjectById('mySwf');
   movie.startPaidSession();
}

function cancelPaidSession()
{
  var movie = swfobject.getObjectById('mySwf');
  movie.cancelPaidSession();
}


function openPaymentDialog(username, caller)
{
  formatMessage(caller, username);
  $('.dialog-window').show();
  $('#dialog-overlay').show();
  var close = $('<div class="dialog-close"></div>');
  close.click( postponePayment );
  $('.dialog-window').append( close );
}

function postponePayment()
{
  close_dialogs();
  cancelPaidSession();
}

function formatMessage(caller,username)
{
  if(parseInt(caller) == 1)
  {
    messageString = "To start a paid session, you will need to have payment information on file";
  }
  else
  {
      messageString = "Attorney "+ username + " is requesting a paid session. To confirm this, you will need to have payment info on file";
  }
  $('.paid_model_header').html(messageString);
  isOverlayOpen = true;
}

function closecall()
{
      $('#outer_div').css({"left":"-2000px"});
      //$('.maic').css("display","block");
}
/*----------------------------------------*/

function select_unselect_state(id) {
  if ($('#state_' + id).is(":checked"))
    $('#lawyer_bar_memberships_attributes_' + id + '_state_id').val($('#state_' + id).val());
  else
    $('#lawyer_bar_memberships_attributes_' + id + '_state_id').val('');
}

function setBarIds() {
	var states_barids = new Array();
	var form_data_status = false;
	$('#leveled_list_bar_ids input[type=checkbox]:checked').each(function(index) {
		var dv = $(this).nextAll('div.sub');
		var state = dv.attr('id');
		states_barids[state] = $(this).val();
		form_data_status = true;
	});

	if (form_data_status) {
		var states_barids_string = "";
		for (key in states_barids) {
			states_barids_key_label = states_barids[key] ? key + " (Bar ID: " + states_barids[key] + ")" : '';
			states_barids_string += "<li>" + states_barids_key_label + "</li>"
		}
		$('#barids_opener').hide();
		$('#div_states_barids .bar_list').html(states_barids_string);
		$('#div_states_barids').show().css('display', 'inline');
	}
	$('.profile').find(".same_height").css('height', 'auto')
	equalHeight($('.profile').find(".same_height"));
	close_dialogs();
}

function setPracticeAreas() {
	var practice_list_string = practice_area_string = '';
	var specialities = [];
	$('#leveled-list_practice_areas input.parent-area[type=checkbox]:checked').each(function() {
		practice_area_string = $(this).data('name');
		specialities = [];
		$(this).nextAll('div.sub').find('input[type=checkbox]:checked').each(function() {
			specialities.push($(this).data('name'));
		})
		if (specialities.length > 0)
			practice_area_string += ' (' + specialities.join(', ') + ')';
		practice_area_string = "<li>" + practice_area_string + "</li>";
		practice_list_string += practice_area_string;
	});

	$('#practice_areas_opener').hide();
	$('#div_practice_areas .pa_list').html(practice_list_string);
	$('#div_practice_areas').show().css('display', 'inline');
	$('.profile').find(".same_height").css('height', 'auto')
	equalHeight($('.profile').find(".same_height"));
	close_dialogs();
}

function close_dialogs(){
    $('.dialog-window').hide();
    $('#dialog-overlay').hide();
}
$(document).ready(function() {
  $('.dialog-close').click( function(){ close_dialogs() });
  $(function(){

    $.fn.dialog = function( ){

        var dialog_div = $( $(this).attr('href') );
        var close = $('<div class="dialog-close"></div>');
        close.click( close_dialogs );
        dialog_div.append( close );

        $('#dialog-overlay').click( function(){
            $('.dialog-window').hide();
            $(this).hide();
            if(isOverlayOpen) postponePayment();
        });

        this.live("click", function(){
            $('#dialog-overlay').show();
            $( $(this).attr('href') ).show();
            if($(this).attr("data-l-id") != undefined){
                $("div#schedule_session span.lawyer_name").html($(this).attr("data-fullname"));
                $(".current_selected_lawyer").val($(this).attr("data-l-id"));
            }
        });

    };

    $.fn.leveled_list = function(){
        this.children().each(function(){
            var self = $(this);
            self.children('.sub').hide();
            self.children('.sub.filled').show();
            self.children('input[type=checkbox]').click( function(){
                if( $(this).attr('checked') == 'checked' ){
                    self.children('.sub').show();
                }else{
                    self.children('.sub').hide();
                }
            });
        });
    };

    (function($){
      //feature detection
      var hasPlaceholder = 'placeholder' in document.createElement('input');

      //sniffy sniff sniff -- just to give extra left padding for the older
      //graphics for type=email and type=url
      var isOldOpera = $.browser.opera && $.browser.version < 10.5;

      $.fn.placeholder = function(options) {
        //merge in passed in options, if any
        var options = $.extend({}, $.fn.placeholder.defaults, options),
        //cache the original 'left' value, for use by Opera later
        o_left = options.placeholderCSS.left;

        //first test for native placeholder support before continuing
        //feature detection inspired by ye olde jquery 1.4 hawtness, with paul irish
        return (hasPlaceholder) ? this : this.each(function() {
      	  //TODO: if this element already has a placeholder, exit

          //local vars
          var $this = $(this),
              inputVal = $.trim($this.val()),
              inputWidth = $this.width(),
              inputHeight = $this.height(),

              //grab the inputs id for the <label @for>, or make a new one from the Date
              inputId = (this.id) ? this.id : 'placeholder' + (+new Date()),
              placeholderText = $this.attr('placeholder'),
              placeholder = $('<span class="placeholder_text"'+'>'+ placeholderText + '</span>');

          //stuff in some calculated values into the placeholderCSS object
          options.placeholderCSS['width'] = inputWidth;
          options.placeholderCSS['height'] = inputHeight;
          options.placeholderCSS['color'] = options.color;

          // adjust position of placeholder
          options.placeholderCSS.left = (isOldOpera && (this.type == 'email' || this.type == 'url')) ?
             '11%' : o_left;
          placeholder.css(options.placeholderCSS);

          //place the placeholder
          $this.wrap(options.inputWrapper);
          $this.attr('id', inputId).after(placeholder);

          //if the input isn't empty
          if (inputVal){
            placeholder.hide();
          };

          //hide placeholder on focus
          $this.focus(function(){
            if (!$.trim($this.val())){
              placeholder.hide();
            };
          });

          //show placeholder if the input is empty
          $this.blur(function(){
            if (!$.trim($this.val())){
              placeholder.show();
            };
          });
        });
      };

      //expose defaults
      $.fn.placeholder.defaults = {
        //you can pass in a custom wrapper
        inputWrapper: '<span style="position:relative; display:block;"></span>',

        //more or less just emulating what webkit does here
        //tweak to your hearts content
        placeholderCSS: {
          'font':'16px',
          'color':'#a8a8a8',
          'position': 'absolute',
          'left':'5%',
          'top':'8px',
          'overflow-x': 'hidden',
          'overflow-y': 'hidden',
    			'display': 'block'
        }
      };
    })(jQuery);

    $('.button')
        .bind( 'mousedown', function(){ $(this).addClass('pressed');    })
        .bind( 'mouseup',   function(){ $(this).removeClass('pressed'); })
        .bind( 'mouseout',  function(){ $(this).removeClass('pressed'); });

    $('.dialog-opener').dialog();
    $('.leveled-list').leveled_list();

    //if (Browser.Version() != 9) {
      $('input[placeholder]').placeholder();
      $('textarea[placeholder]').placeholder();
    //} 
    $(document).keyup(function(e) {
        if (e.keyCode == 27) close_dialogs();
        //if (isOverlayOpen) postponePayment();
    });

  });
});
jQuery.fn.center = function () {
  this.css({"position": "fixed", "margin": "0"});
  this.css("margin-top", ((this.outerHeight()) / 2 * (-1)) + "px");
  this.css("margin-left", ((this.outerWidth()) / 2 * (-1)) + "px");
  this.css("top", "50%");
  this.css("left", "50%");
  return this;
}

$(document).ready(function() {
  $('body.users.show.logged-in .dialog-window').center();
  if($('div.load-more a').length){
    $(window).scroll(function () {
      if($('div.load-more a').length){
        var eTop = $('div.load-more a').offset().top;
        var offset = eTop - $(window).scrollTop();
        if(offset < 1000){
          $("div.load-more a").click();
        }
      }
    });
  }

  // Iphone style for checkbox
  $('#lawyer_is_online').iphoneStyle({
    checkedLabel: 'Available',
    uncheckedLabel: 'Unavailable',
    onChange: function(elem, value) {
      if($(elem)[0].checked==false)
        $.post("/UpdateOnlineStatus", { op: "set_online_status", is_online: false } );
      else
        $.post("/UpdateOnlineStatus", { op: "set_online_status", is_online: true } );
    }
  });

  $('#is_available_by_phone').iphoneStyle({
    checkedLabel: 'Available',
    uncheckedLabel: 'Unavailable',
    onChange: function(elem, value) {
      if($(elem)[0].checked==false)
        $.post("/UpdateOnlineStatus", { op: "set_phone_status", is_available_by_phone: false } );
      else
        $.post("/UpdateOnlineStatus", { op: "set_phone_status", is_available_by_phone: true } );
    }
  });

});

String.prototype.nl2br = function()
{
	return this.replace(/\n/g, "<br />");
}

String.prototype.strip_tags = function()
{
	return this.replace(/<(?:.|\n)*?>/gm, '');
}


