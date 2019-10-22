<!--#include file="connect.asp"-->
<%
ProcedimentoID = req("I")
Acao = req("A")
TipoAcao = req("TA")
eI = ref("eI")

if TipoAcao="P" then'particular
    sql = "update procedimentosequipeparticular set Funcao='"&ref("Funcao")&"', Valor="&treatvalzero(ref("Valor"))&", TipoValor='"&ref("TipoValor")&"', ContaPadrao='"&ref("ContaPadrao")&"', TabelasPermitidas='"&ref("TabelasPermitidas[]")&"' WHERE id="&eI
    'response.write(sql)
    db_execute(sql)
end if

if TipoAcao="C" then'convenio
    sql = "update procedimentosequipeconvenio set Funcao="&ref("Funcao")&", Valor="&treatvalzero(ref("Valor"))&", TipoValor='"&ref("TipoValor")&"', ContaPadrao='"&ref("ContaPadrao")&"' WHERE id="&eI
    'response.write(sql)
    db_execute(sql)
end if
%>