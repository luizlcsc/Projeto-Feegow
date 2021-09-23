<!--#include file="./connect.asp"-->
<!--#include file="./Classes/Json.asp"-->
<!--#include file="./Classes/StringFormat.asp"-->

<%
searchTerm          = req("searchTerm")&""
searchTable         = req("searchTable")&""
searchFilter        = req("searchFilter")&""
searchFilterValue   = req("searchFilterValue")&""

'PREPARA PARAMETROS PARA MONTAR O SQL
SELECT CASE searchTable
    CASE "bProcedimentoID", LCASE("procedimentoid")
        TableSQL    = "Procedimentos"
        ColumnName  = "NomeProcedimento"
            
        if searchFilter&""<>"" then
            whereSQL = " AND GrupoID = 162"
        end if

    CASE "bGrupoID", LCASE("procedimentosgruposid")
        TableSQL = "procedimentosgrupos"
        ColumnName  = "NomeGrupo"

END SELECT
'FILTRO PADRÃO PARA BUSCA
if searchTerm<>"" then
    '<CORRESPONSENCIA EXATA NO INÍCIO OU FIM PARA CASOS ESPECÍFICOS>
    if LEFT(searchTerm,1)<>"[" then
        searchTerm = "%"&searchTerm
    end if
    if RIGHT(searchTerm,1)<>"]" then
        searchTerm = searchTerm&"%"
    end if
    searchTerm = RemoveCaracters(searchTerm,"][")
    '</CORRESPONSENCIA EXATA NO INÍCIO OU FIM PARA CASOS ESPECÍFICOS>

    whereSearchSQL = " AND (id='"&searchTerm&"' OR "&ColumnName&" LIKE '"&searchTerm&"') "
end if
'FILTRO SQL - **OBRIGATÓRIO O PADRÃO id, tabela AS text**
Select Case TableSQL

    Case "Procedimentos"
        sql =   " SELECT id, NomeProcedimento as text   "&chr(13)&_
                " FROM procedimentos                    "&chr(13)&_
                " WHERE sysActive=1 AND ativo = 'on'    "&chr(13)&_
                whereSearchSQL&whereSQL                 &chr(13)&_
                " LIMIT 0,20    "
    
    Case "procedimentosgrupos"
        sql = "SELECT id, NomeGrupo as text "   &chr(13)&_
              "FROM procedimentosgrupos "       &chr(13)&_
              "WHERE sysActive=1 "              &chr(13)&_
              whereSearchSQL&whereSQL           &chr(13)&_
              "ORDER BY NomeGrupo LIMIT 0,10"

End Select
'response.write(sql)
if sql&""<>"" then
    set jsonSQL = db.execute(sql)
        responseJson(recordToJSON(jsonSQL))
end if

%>