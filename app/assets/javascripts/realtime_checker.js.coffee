g_realtime_checker = g_realtime_xhr = 0;
class RealtimeChecker

  initialize : ()->
    @updateOnlineStatus()
     
  updateOnlineStatus: ->
    if g_realtime_checker==0 && typeof lawyer_id != 'undefined'
      g_realtime_checker = setInterval(() -> 
          if (window.location != "/users/"+lawyer_id+"/chat_session")
            g_realtime_xhr = $.ajax
              url: "/UpdateOnlineStatus",
              type:'post',
              cache:false,
              data:'op=get_call_status&lawyer_id='+lawyer_id+'&call_mode=',
              success: (response) ->
                if (window.location != "/users/"+lawyer_id+"/chat_session")
                  window.location = "/users/"+lawyer_id+"/chat_session" if is_lawyer && response == "invite_video_chat"
  
        15000
      )  

this.RealtimeChecker = new RealtimeChecker()
