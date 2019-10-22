<!--#include file="connect.asp"-->
<%
set ap = db.execute("select * from atendimentosprocedimentos where rdValorPlano='P' order by AtendimentoID, ValorPlano desc")
while not ap.EOF
	if ap("AtendimentoID")=AtendimentoID then
		if ap("ValorPlano")=0 and ValorPlano<>0 then
			db_execute("update atendimentosprocedimentos set ValorPlano="&treatvalnull(ValorPlano)&" where id="&ap("id"))
		end if
	else
		ValorPlano = ap("ValorPlano")
	end if
	AtendimentoID = ap("AtendimentoID")
ap.movenext
wend
ap.close
set ap=nothing
%>