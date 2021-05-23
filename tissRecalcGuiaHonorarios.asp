<!--#include file="connect.asp"-->
<%
I = req("I")
Action = req("Action")
if Action="Recalc" then
	Procedimentos = 0
	TaxasEAlugueis = 0
	Materiais = 0
	OPME = 0
	Medicamentos = 0
	GasesMedicinais = 0
	TotalGeral = 0
'	set procs = db.execute("select * from tissprocedimentoshonorarios where GuiaID="&I)
'	while not procs.eof
'		Procedimentos = Procedimentos + procs("ValorTotal")
'	procs.movenext
'	wend
'	procs.close
	set procs=nothing
	TotalGeral = Procedimentos+TaxasEAlugueis+Materiais+OPME+Medicamentos+GasesMedicinais
'	db_execute("update tissguiahonorarios set Procedimentos="&treatvalzero(Procedimentos)&", "&_ 
	db_execute("update tissguiahonorarios set "&_ 
	"Procedimentos=(select sum(ValorTotal) from tissprocedimentoshonorarios where GuiaID="&I&") where id="&I)
	set guia = db.execute("select * from tissguiahonorarios where id="&I)
'	response.Write("update tissguiahonorarios set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&I)
end if

set reg = db.execute("select * from tissguiahonorarios where id="&I)
if not reg.eof then
	Procedimentos = reg("Procedimentos")
	%>
	<%= quickField("currency", "vProcedimentos", "Procedimentos", 12, Procedimentos, "", "", " readonly") %>
	<%
end if
%>