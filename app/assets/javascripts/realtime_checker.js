var g_realtime_checker = 0;
var g_realtime_xhr = 0;
$(function(){
	if(g_realtime_checker==0){
		g_realtime_checker=setInterval(function(){
			if(g_realtime_xhr) g_realtime_xhr.abort();
			g_realtime_xhr = $.ajax({
			        url: "/UpdateOnlineStatus",
			        type:'post',
			        cache:false,
			        success: function(response){
			        	if(is_lawyer && response.call_status == "invite_video_chat"){
			        		//if(typeof(is_chat_session_page)=="undefined"){
			        			window.location = "/users/"+lawyer_id+"/chat_session";
			        		//}
			        		
			        	}
			        }
			});
		},10000);
	}
	
});