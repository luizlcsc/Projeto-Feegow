<!--#include file="connect.asp"-->
<%
I = request.QueryString("I")
Action = request.QueryString("Action")
if Action="Recalc" then

    set ConvenioSQL = db.execute("SELECT ConvenioID FROM tissguiasadt where id="&I  )
    if not ConvenioSQL.eof then
        if not isnull(ConvenioSQL("ConvenioID")) then
            ConvenioID =ConvenioSQL("ConvenioID")
        end if
    end if

    if ConvenioID&"" ="" then
        ConvenioID = ref("gConvenioID")
    end if

    set convenio = db.execute("SELECT ValorFilme FROM convenios WHERE id = "&ConvenioID )
    ValorFilme = treatvalzero(convenio("ValorFilme"))

	Procedimentos = 0
	TaxasEAlugueis = 0
	Materiais = 0
	OPME = 0
	Medicamentos = 0
	GasesMedicinais = 0
	TotalGeral = 0
'	set procs = db.execute("select * from tissprocedimentossadt where GuiaID="&I)
'	while not procs.eof
'		Procedimentos = Procedimentos + procs("ValorTotal")
'	procs.movenext
'	wend
'	procs.close
	set procs=nothing
	db_execute("update tissguiasadt set TotalGeral=0 where id="&I)
	TotalGeral = Procedimentos+TaxasEAlugueis+Materiais+OPME+Medicamentos+GasesMedicinais
'	db_execute("update tissguiasadt set Procedimentos="&treatvalzero(Procedimentos)&", "&_ 
	db_execute("update tissguiasadt set "&_ 
	"Procedimentos=(select sum(ValorTotal) from tissprocedimentossadt where GuiaID="&I&"),"&_ 
	"GasesMedicinais=(select sum(ValorTotal) from tissguiaanexa where CD=1 and GuiaID="&I&"), "&_
	"Medicamentos=(select sum(ValorTotal) from tissguiaanexa where CD=2 and GuiaID="&I&"), "&_ 
	"Materiais=(select sum(ValorTotal) from tissguiaanexa where CD=3 and GuiaID="&I&"), "&_ 
	"TaxasEAlugueis=(select sum(ValorTotal) from tissguiaanexa where CD=7 and GuiaID="&I&"), "&_ 
	"OPME=(select sum(ValorTotal) from tissguiaanexa where CD=8 and GuiaID="&I&") "&_ 
	"where id="&I)
	set guia = db.execute("select * from tissguiasadt where id="&I)
'	response.Write("update tissguiasadt set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&I)
	db_execute("update tissguiasadt set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&I)
end if

set reg = db.execute("select * from tissguiasadt where id="&I)
if not reg.eof then
	Procedimentos = reg("Procedimentos")
	TaxasEAlugueis = reg("TaxasEAlugueis")
	Materiais = reg("Materiais")
	OPME = reg("OPME")
	Medicamentos = reg("Medicamentos")
	GasesMedicinais = reg("GasesMedicinais")
	TotalGeral = reg("TotalGeral")

	hiddenValores = ""

	if aut("valorprocedimentoguia")=0 then
        hiddenValores=" hidden "
	end if
	%>
	<table class="table table-striped <%=hiddenValores%>">
		<tr>
			<td width="25%"><%= quickField("currency", "Procedimentos", "Procedimentos", 12, Procedimentos, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "TaxasEAlugueis", "Taxas e Alugu&eacute;is", 12, TaxasEAlugueis, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "Materiais", "Materiais", 12, Materiais, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "OPME", "OPME", 12, OPME, "", "", " readonly") %></td>
		</tr>
		<tr>
			<td width="25%"><%= quickField("currency", "Medicamentos", "Medicamentos", 12, Medicamentos, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "GasesMedicinais", "Gases Medicinais", 12, GasesMedicinais, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "ValorFilme", "Valor Filme", 12, ValorFilme, "", "", " readonly") %></td>
			<td width="25%"><%= quickField("currency", "TotalGeral", "Total Geral", 12, TotalGeral, "", "", " readonly") %></td>
		</tr>
	</table>
	<%
end if
%>