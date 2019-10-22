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
		<h2 class="text-center no-padding no-margin">Fechamento de Caixa <br />
<small>
      <%
	  if De=Ate then
	  	response.Write( De )
	  else
		response.Write("De "&De&" a "&Ate)
	  end if
	  %>
	  </small></h2>
    </div>
    <%
	TotalGeral = 0
	set units = db.execute("select id, UnitName from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia from empresa order by id")
	while not units.eof
		UnidadeID = units("id")
		if (instr(session("Unidades"), "|"&UnidadeID&"|")>0 or session("Admin")=1) and (instr(req("Unidades"), "|"&UnidadeID&"|") or request.QueryString("Unidades")="") then
			%>
            <!--#include file="FechamentoConteudo.asp"-->
        	<%
		end if
	units.movenext
	wend
	units.close
	set units=nothing
	%>
    <h2 class="text-center">Total geral: R$ <%=formatnumber(TotalGeral, 2)%></h2>
</div>