<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
<script type="text/javascript" src="assets/js/jquery.min.js"></script>

<!--#include file="connect.asp"-->

<%server.Execute(request.QueryString("SP")&".asp") %>

<script type="text/javascript">
    function constante(){
        $.ajax({
            type:"POST",
            url:"constante.asp?P=<%=req("P")%>&SP=<%=req("SP")%>",
            success:function(data){
                eval(data);
            }
    });
    }
    setTimeout(function(){constante()}, 1500);
    setInterval(function(){constante()}, 6500);
</script>