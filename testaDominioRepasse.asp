<!--#include file="connect.asp"-->
<%
ProfissionalID=665
ProcedimentoID=4
UnidadeID=9
TabelaID=124
EspecialidadeID=40

Dominio = dominioRepasse("|P|", ccur(ProfissionalID), ProcedimentoID, UnidadeID, TabelaID, EspecialidadeID)
response.write(Dominio)
%>