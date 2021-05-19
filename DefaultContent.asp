<!--#include file="connect.asp"-->
<!--#include file="DefaultForm.asp"-->
<form method="post" action="">
<input type="hidden" name="E" value="E" />
<%
call DefaultForm(req("P"), req("I"))
%>
</form>