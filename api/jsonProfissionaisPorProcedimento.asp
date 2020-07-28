<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<%

function decodeArrayPipe(arrayString)
    resultDecodeArrayBarraEmPe=replace(arrayString&"", "|", "")

    if resultDecodeArrayBarraEmPe&"" = "" then
        resultDecodeArrayBarraEmPe="NULL"
    end if

    decodeArrayPipe=resultDecodeArrayBarraEmPe
end function

procedimento_id=req("procedimento_id")
tipo_executantes=req("tipo_executantes")

set ExecutantesDoProcedimentoSQL = db.execute("SELECT SomenteEspecialidades, OpcoesAgenda,SomenteProfissionaisExterno, SomenteFornecedor, SomenteProfissionais FROM procedimentos WHERE id="&procedimento_id)

if not ExecutantesDoProcedimentoSQL.eof then
    AnulaWhereSql = ""
    SomenteProfissionais = decodeArrayPipe(ExecutantesDoProcedimentoSQL("SomenteProfissionais"))
    SomenteFornecedor = decodeArrayPipe(ExecutantesDoProcedimentoSQL("SomenteFornecedor"))
    SomenteProfissionaisExterno = decodeArrayPipe(ExecutantesDoProcedimentoSQL("SomenteProfissionaisExterno"))
    SomenteEspecialidades = decodeArrayPipe(ExecutantesDoProcedimentoSQL("SomenteEspecialidades"))
    OpcoesAgenda = ExecutantesDoProcedimentoSQL("OpcoesAgenda")&""

    if OpcoesAgenda<>"3" and OpcoesAgenda<>"4" then
        AnulaWhereSql = " or 1=1 "
    end if

    sqlExecutantes = "SELECT DISTINCT ID, AssociacaoID ,NomeProfissional FROM ("&_
      "SELECT NomeProfissional, '5' AssociacaoID, id ID FROM profissionais WHERE (id IN ("&SomenteProfissionais&") "&AnulaWhereSql&") AND NomeProfissional!='' AND sysActive=1  AND Ativo='on' UNION ALL "&_

      "SELECT prof.NomeProfissional, '5' AssociacaoID, prof.id ID FROM profissionais prof LEFT JOIN profissionaisespecialidades pe ON pe.id=prof.id "&_
      "WHERE (pe.EspecialidadeID IN ("&SomenteEspecialidades&") OR prof.EspecialidadeID IN ("&SomenteEspecialidades&")  "&AnulaWhereSql&" ) UNION ALL "&_

      "SELECT NomeProfissional, '8' AssociacaoID, id ID FROM profissionalexterno WHERE (id IN ("&SomenteProfissionaisExterno&") "&AnulaWhereSql&") AND sysActive=1 AND Ativo='on' UNION ALL "&_

      "SELECT NomeFornecedor, '2' AssociacaoID, id ID FROM fornecedores WHERE (id IN ("&SomenteFornecedor&") "&AnulaWhereSql&") AND NomeFornecedor!='' AND sysActive=1  AND Ativo='on' "&_
      ") t WHERE AssociacaoID IN ("&tipo_executantes&") ORDER BY NomeProfissional "

    set ExecutantesSQL = db.execute(sqlExecutantes)

    response.write(responseJson(recordToJSON(ExecutantesSQL)))
end if

%>