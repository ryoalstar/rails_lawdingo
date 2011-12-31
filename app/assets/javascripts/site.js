 $('#outer_div').css({"margin":"20px auto","border":"solid #000 2px","padding":"2px"});
//functions to bring up and collapse the video chat screen for lawyer
function CloseCall()
{
    closecall();
}

function showFlash()
{
  $('#outer_div').css({"left":"12%"});
  //$('.mainc').css("display","none");
}

function closecall()
{
      $('#outer_div').css({"left":"-2000px"});
      //$('.maic').css("display","block");
}
/*----------------------------------------*/

function select_unselect_state(id) {
 if ($('#state_' + id).attr("checked") == "checked"){
   $('#lawyer_bar_memberships_attributes_' + id + '_state_id').val($('#state_' + id).val());
 }
 // else {
// alert(id);
 //   $('#lawyer_bar_memberships_attributes_' + id + '_state_id').val('');
 //   $('#lawyer_bar_memberships_attributes_' + id + '_bar_id').val('');
 // }

}


function setBarIds(){
  var states_barids = new Array();
  var form_data_status = false;
  $('#leveled_list_bar_ids').children().each(function(index){
    var self = $(this);
    var checked = false;
    var chkbox = self.find('input[type=checkbox]')

    if (chkbox.attr('checked') == 'checked')
    {
        var dv = self.find('div');
        var state = dv.attr('id');
        var inp = dv.find('input');
        barId = inp.attr('value');
        if (barId == "")
        {
          //alert("please enter barid for the selected state " + state);
          //form_data_status = false;
          states_barids[state] = barId;
          form_data_status = true;
        }
        else
        {
          states_barids[state] = barId;
          form_data_status = true;
        }
    }
  });
  if(form_data_status)
  {
    var states_barids_string = "<strong>Bar Memberships:</strong> ";
    for(key in states_barids)
    {
      states_barids_key_label = states_barids[key] ? "(Bar ID: " + states_barids[key] + ")" : '';

      if(states_barids_key_label) {
        states_barids_string += key + " " + states_barids_key_label + ", ";
      } else {
        states_barids_string += key + ", ";
      }
    }
    states_barids_string = states_barids_string.substring(0,states_barids_string.length-2);
    $('#barids_opener').hide();
    $('#barids_editor').show().css({'display': 'inline', 'margin-left': '0.5em'});
    $('#div_states_barids').html(states_barids_string);
    $('#div_states_barids').show().css('display', 'inline');
    close_dialogs();
  }
  else
  {
    alert("Please provide your barid for the states")
    return;
  }
}

function setPracticeAreas()
{
  var practice_area_string = "<strong>Practice Areas:</strong> ";
  var specialities_string = "";
  $('#leveled-list_practice_areas').children().each(function(index){
    var parent_list = $(this);
    var parent_checkbox = parent_list.find(':checkbox:first');
    if(parent_checkbox.attr('checked') == 'checked')
    {
      practice_area_string += parent_checkbox.data('name');
      var div = parent_list.find('div');
      var inner_ul = div.find('ul');
      specialities_string = "";
      inner_ul.children().each(function(index){
        var inner_list = $(this);
        var chkbox = inner_list.find('input[type=checkbox]')
        if(chkbox.attr('checked') == 'checked')
        {
          specialities_string +=chkbox.data('name') + ', '
        }
      });
      if(specialities_string != "")
      {
        specialities_string = specialities_string.substring(0,specialities_string.length-2);
        practice_area_string += '(' + specialities_string + ')';
      }
      practice_area_string += ', ';
    }
    });
  practice_area_string = practice_area_string.substring(0,practice_area_string.length-2);
  $('#practice_areas_opener').hide();
  $('#div_practice_areas').html(practice_area_string);
  $('#div_practice_areas').show().css('display', 'inline');
  $('#practice_areas_editor').show().css({'display': 'inline', 'margin-left': '0.5em'});
  close_dialogs();
}

function close_dialogs(){
    $('.dialog-window').hide();
    $('#dialog-overlay').hide();
}

$(function(){

    $.fn.carousel = function(){
        if( this==null || this=='undefined' || this.length<=0 ) return;

        var self = this;
        self.current_image = 0;

        self.images = [];
        $.ajax( self.attr('dataurl'), {
            data:{'p':self.current_image++},
            dataType:'json',
            success:function( data, stat, ob ){ self.images = data; }
        });

        function goto_image( i ){
            self.current_image = i;
            self.find('.carousel-image img').attr('src', self.images[self.current_image]['url']);
            self.find('.carousel-image img').attr('alt', self.images[self.current_image]['title']);
            self.find('.carousel-description h4').html( self.images[self.current_image]['title'] );
            self.find('.carousel-description span').html( self.images[self.current_image]['description'] );
        }

        function next_image(){ goto_image( self.current_image<self.images.length-1? self.current_image+1: 0 ) }
        function prev_image(){ goto_image( self.current_image>0? self.current_image-1: self.images.length-1 ) }


        var cont = $('<div class="controls"></div>');
        var prev = $('<a class="prev icn">prev</a>'); prev.click( prev_image );
        var next = $('<a class="next icn">next</a>'); next.click( next_image );
        var play  = $('<a class="play icn">play</a>'); play.click( function(){
            self.interv = setInterval( next_image, 5000 );
            play.css('display','none');
            pause.css('display','inline-block');
        });
        var pause = $('<a class="pause icn">pause</a>'); pause.click( function(){
            clearInterval( self.interv );
            play.css('display','inline-block');
            pause.css('display','none');
        });

        cont.append( prev );
        cont.append( pause );
        cont.append( play );
        cont.append( next );
        self.find('.carousel-image').append(cont);

        self.interv = setInterval( next_image, 5000 );
    }

    $.fn.dialog = function( ){
        
        this.each( function(){
            var dialog_div = $( $(this).attr('href') );
            var close = $('<div class="dialog-close"></div>');
            close.click( close_dialogs );
            dialog_div.append( close );
        });
        
        $('#dialog-overlay').click( function(){
            $('.dialog-window').hide();
            $(this).hide();
        });
        
        this.click( function(){
            $('#dialog-overlay').show();
            $( $(this).attr('href') ).show();
            return false;
        });
    
    };

    $.fn.leveled_list = function(){
        this.children().each(function(){
            var self = $(this);
            self.children('.sub').hide();
            self.children('input[type=checkbox]').click( function(){
                if( $(this).attr('checked') == 'checked' ){
                    self.children('.sub').show();
                }else{
                    self.children('.sub').hide();
                }
            });
        });
    };

    $.fn.placeholder = function(){
        this.each(function(){
            var self = $(this);

            if( 'placeholder' in $('<input>')[0] ) return;

            var rep = this.tagName.toLowerCase()=='textarea'?$('<textarea></textarea>'):$('<input type="text">');
            rep.val( self.attr('placeholder') );
            rep.attr( 'class', self.attr('class') );
            rep.addClass( 'dummy-input' );
            rep.insertAfter( self );
            self.hide();

            rep.bind('focus', function(){
                rep.hide();
                self.show();
               self.focus();
            });

            self.bind('blur', function(){
                if( self.val().length<=0 ){
                    self.hide();
                    rep.show();
                }
            });
        });
    };

    $('.button')
        .bind( 'mousedown', function(){ $(this).addClass('pressed');    })
        .bind( 'mouseup',   function(){ $(this).removeClass('pressed'); })
        .bind( 'mouseout',  function(){ $(this).removeClass('pressed'); });

    $('.dialog-opener').dialog();
    $('.leveled-list').leveled_list();

    $('.image-carousel').carousel();

    $('input[placeholder]').placeholder();
    $('textarea[placeholder]').placeholder();

    $(document).keyup(function(e) {
        if (e.keyCode == 27) close_dialogs();
    });

});

jQuery.fn.center = function () {
  this.css({"position": "absolute", "margin": "0"});
  this.css("top", (($(window).height() - this.outerHeight()) / 2) + $(window).scrollTop() + "px");
  this.css("left", (($(window).width() - this.outerWidth()) / 2) + $(window).scrollLeft() + "px");
  return this;
}
