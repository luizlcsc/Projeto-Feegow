<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title><%=request.querystring("FALAR")%></title>
</head>

<body>
<script language="JavaScript" type="text/javascript" src="http://vhss-d.oddcast.com/vhost_embed_functions_v2.php?acc=1024058&js=1"></script><script language="JavaScript" type="text/javascript">AC_VHost_Embed(1024058,300,400,'',1,1, 1808880, 0,1,0,'67269de5c98f6b86294e28a481244b95',9);</script>
<script language="JavaScript" type="text/javascript">
function vh_sceneLoaded(){
      //the scene begins playing, add actions here
	sayText('<%=request.querystring("FALAR")%>',5,6,2);
//	sayText('Silvio Maia, favor comparecer a recepção.',1,6,2);

}
</script>

<!--include file="conexaoAcessos.inc.asp"-->
<%
IP=request.ServerVariables("REMOTE_ADDR")
DataHora=now()
Referencia=request.ServerVariables("HTTP_REFERER")
Texto=request.QueryString("FALAR")

'lojadb_execute("insert into Acessos (IP,DataHora,Referencia,Texto) values ('"&IP&"','"&DataHora&"','"&Referencia&"','"&Texto&"')")
%>
</body>
</html>
