<!--#include file="connect.asp"-->
<%
id = request.QueryString("id")'variavel de acordo com o tipo
tipo = request.QueryString("tipo")
ProcedimentoID = ref("ProcedimentoID")
PacienteID = ref("PacienteID")
FormaPagto = request.QueryString("FormaPagto")'Particular ou Convenio

if tipo="select-ProcedimentoID" then
	ProcedimentoID = id
	set proc = db.execute("select * from procedimentos where id="&ProcedimentoID)
	if not proc.EOF then
		ObrigarTempo = proc("ObrigarTempo")
		TempoProcedimento = proc("TempoProcedimento")
		Valor = formatnumber(proc("Valor"),2)
		%>
		 $("#inf-Valor").val('<%=Valor%>');
		<%
	end if
end if
%>