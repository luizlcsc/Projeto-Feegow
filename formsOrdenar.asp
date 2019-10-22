<!--#include file="connect.asp"-->
<%
Ordem = ref("ordem")
splOrdem = split(Ordem, ";")
novaOrdem = 0
for i=1 to ubound(splOrdem)
	splPar = split(splOrdem(i), "|")
	novaOrdem = novaOrdem+1
	db_execute("update buicamposforms set Linhas="&splPar(1)&", Colunas="&splPar(2)&", pLeft="&splPar(3)&", pTop="&splPar(4)&" where id="&splPar(0))
'	db_execute("update buicamposforms set Ordem="&novaOrdem&", Linhas="&splPar(1)&", Colunas="&splPar(2)&", pLeft="&splPar(3)&", pTop="&splPar(4)&" where id="&splPar(0))
'	id|data-sizey|data-sizex|data-col|data-row
next



'gridster.resize_widget($("#80"), "1", "1")
%>