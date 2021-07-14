<%
LocalTime = req("LocalTime")
if session("DifTempo")="" and LocalTime="" then
	%>
	<script language="javascript">
	var currDate = new Date();
	var segundos = currDate.getSeconds();
	var minutos = currDate.getMinutes();
	var horas = currDate.getHours()
	var HoraLocal = horas+":"+minutos+":"+segundos;
	//alert('<%=TempoDist%>');
	location.href='ajustaHora.asp?LocalTime='+HoraLocal;
</script>
<%
end if

if LocalTime<>"" then
	DifTempo = datediff("s", time(), LocalTime)
	session("DifTempo") = DifTempo
	response.Redirect("ajustaHora.asp")
end if

'response.Write(session("DifTempo"))
%>