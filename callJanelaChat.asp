<!--#include file="connect.asp"-->
<%
chatID=request.QueryString("ChatID")
De=request.QueryString("ChatID")
Para=session("User")
%>
<!--#include file="janelaChat.asp"-->
<script type="text/javascript">
jQuery(function($) {
	$('.slim-scroll').each(function () {
		var $this = $(this);
		// $('#audioNotificacao').trigger('play');
		$this.slimScroll({
			height: $this.data('height') || 100,
			railVisible:true
		});
	});
});
$("#frm<%=ChatID%>").submit(function(){
   let cxMsg = $("#frm<%=ChatID%> input.cx-mensagem")
   if(cxMsg.val()=="")return false;
	let dados =  $(this).serialize();
	cxMsg.val('');
	
	$.ajax({
		type:"POST",
		url:"saveChat.asp",
		data:dados,
		success:function(data){
			eval(data);
		}
	});
	return false;
});
$("#body_<%=ChatID%>").slimScroll({ scrollTo: '9000000' });
</script>