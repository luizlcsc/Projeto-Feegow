<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
De = req("De")
Ate = req("Ate")

if De="" or Ate="" then
	De = date()
	Ate = date()
end if
	%>

<div class="container">
    <div class="page-header">
		<h3 class="text-center no-padding no-margin">Financeiro Sint&eacute;tico <br />
<small>De <%=De%> a <%=Ate%></small></h3>
	</div>
    <%
	TotalGeral = 0
	set units = db.execute("select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia from empresa order by id")
	while not units.eof
		UnidadeID = units("id")
		if (instr(session("Unidades"), "|"&UnidadeID&"|")>0 or session("Admin")=1) and (instr(req("Unidades"), "|"&UnidadeID&"|") or request.QueryString("Unidades")="") then
			%>
            <!--#include file="FinanceiroSinteticoConteudo.asp"-->
        	<%
		end if
	units.movenext
	wend
	units.close
	set units=nothing
	%>
    <h2 class="text-center">Total geral: R$ <%=formatnumber(TotalGeral, 2)%></h2>
</div>