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

        var dialog_div = $( $(this).attr('href') );
        var close = $('<div class="dialog-close"></div>');
        close.click( close_dialogs );
        dialog_div.append( close );
        $('#dialog-overlay').click( function(){
            $('.dialog-window').hide();
            $(this).hide();
        });

        this.click( function(){
            var l_id = $(this).data('l_id');
            var fullname = $(this).data('fullname');
            $("#overlay_user_name").html('You\'ve reached attorney ' + fullname);
            $("#current_lid").val(l_id);
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

