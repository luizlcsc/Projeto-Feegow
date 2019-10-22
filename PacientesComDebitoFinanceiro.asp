<%@LANGUAGE="VBSCRIPT" CODEPAGE="1252"%>
<% Response.Charset="ISO-8859-1" %>
<style>
body, tr, td {
cursor:default;
}
</style>
<!--#include file="conexao.inc.asp"-->
<!--#include file="testeFuncao.asp"-->

<table border="0" width="100%" bgcolor="#EEEEEE" cellpadding="1" cellspacing="1">
<tr><th><div align="center">PACIENTE</div></th><th><div align="center">D&Eacute;BITO TOTAL</div></th></tr>
<%
DataHoje=day(date())&"/"&month(date())&"/"&year(date())
DataHoje=JunDatSp(DataHoje)

set p=lojadb.execute("select * from ContasCentral where Tabela like 'Paciente' order by Nome")
c=0
debitoTotal=0
while not p.eof
		CtaDeb=p("id")
		set m=lojadb.execute("select * from Movimentacao where (ContaDebito="&CtaDeb&" or ContaCredito="&CtaDeb&") and Data <= "&ccur(DataHoje)&"")
		SaldoTotal=0
		while not m.eof
		
		Valor=ccur(m("Valor"))
		
		if (m("Forma")="2" and m("StaCheque")=3) or (m("Forma")<>"2") or (isNull(m("Forma"))) then
			if m("ContaCredito")=CtaDeb then
				SaldoTotal=ccur(SaldoTotal)-ccur(Valor)
			else
				SaldoTotal=ccur(SaldoTotal)+ccur(Valor)
			end if
		end if
		
		m.movenext
		wend
		m.close
		set m=nothing
		
		if SaldoTotal>0 then
		%><tr bgcolor="#FFFFFF" onclick="location.href='EdiPaciente.asp?lid=<%=p("ContaID")%>';">
        		<td><div align="left"><%=p("Nome")%></div></td><td><div align="right">R$ <%=exiVal(formatNumber(SaldoTotal,2))%></div></td>
          </tr>
		<%
		c=c+1
		debitoTotal=debitoTotal+SaldoTotal
		end if
p.moveNext
wend
p.close
set p=nothing
%>
</table>
<br />
<em><%=c%> paciente(s) com d&eacute;bito financeiro.<br />
R$ <%=ExiVal(formatNumber(debitoTotal,2))%> em d&eacute;bitos.</em>