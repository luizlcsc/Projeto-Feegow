<%


function getProfissionaisSqlQuickField()
   sqlProfissionais = " select id, NomeProfissional as nome,profissionais.Unidades                      "&chr(13)&_
                   " from profissionais                                                                 "&chr(13)&_
                   " where sysActive = 1                                                                "&chr(13)&_
                   "   and ativo = 'on'                                                                 "&chr(13)&_
                   " UNION ALL                                                                          "&chr(13)&_
                   " select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor') as nome,null      "&chr(13)&_
                   " from fornecedores                                                                  "&chr(13)&_
                   " where sysActive = 1                                                                "&chr(13)&_

                   "   and Ativo = 'on'                                                                 "&chr(13)&_
                   " UNION ALL                                                                          "&chr(13)&_
                   " (select concat('8_', id), concat(NomeProfissional, ' - Externo') as nome,null      "&chr(13)&_
                   "  from profissionalexterno                                                          "&chr(13)&_
                   "  where sysActive = 1                                                               "&chr(13)&_
                   "  order by NomeProfissional                                                         "&chr(13)&_
                   "  limit 1000)                                                                       "

    getProfissionaisSqlQuickField = "SELECT * FROM ("&sqlProfissionais&") AS t WHERE TRUE "&franquia(" and  COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")
end function


function getTabelasParticularesSQLQuickField()
    sqlTabelasParticulares = "select id, NomeTabela as nome,Unidades from tabelaparticular where  sysActive=1 order by NomeTabela"
    getTabelasParticularesSQLQuickField = "SELECT * FROM ("&sqlTabelasParticulares&") AS t WHERE true"&franquiaUnidade(" AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),true) ")
end function

function getTabelasConveniosSQLQuickField()
    sqlTabelasConvenios = "SELECT id, nomeconvenio as nome, Unidades FROM convenios WHERE sysactive  = 1 order by nomeconvenio"
    getTabelasConveniosSQLQuickField = "SELECT * FROM ("&sqlTabelasConvenios&") as t where true "
end function

'QUERYS PADRÃO PARA O QUICKFIELD MODAL - Ref. Configurações > Regras de Repasse (frmRL.asp)
'VALORES COMPATÍVEIS:  id,nome
function getSQLQuickField(Tabela,Coluna,ID,Condicoes)
    Select Case Tabela
        Case "Unidades"
            sql = "SELECT id,NomeFantasia AS nome FROM vw_unidades where sysActive=1 "&franquiaUnidade("AND id = [UnidadeID]")
        Case "ProcedimentosGrupos"
            sql = "SELECT CONCAT('-',id) AS id,NomeGrupo AS nome FROM procedimentosgrupos WHERE sysActive=1"
        Case "Procedimentos"
            sql = "SELECT id,NomeProcedimento AS nome FROM procedimentos where sysActive=1 and ativo='on'"&franquiaUnidade(" AND ID IN( (SELECT idOrigem FROM registros_importados_franquia WHERE unidade = '"&session("UnidadeID")&"' AND tabela = 'procedimentos')) ")
        Case "Especialidades"
            sql = "SELECT CONCAT('-',id) AS id, especialidade AS nome FROM  especialidades where sysActive=1 and id*(-1)"
            if Condicoes="id+" then
                sql = replace(replace(sql,"CONCAT('-',id) AS id","id")," and id*(-1)","")
            end if
        Case "ProfissionaisGrupos"
            sql = "SELECT id,NomeGrupo AS nome FROM profissionaisgrupos where sysActive=1"
        Case "Profissionais"
            sql = "SELECT id,NomeProfissional AS nome FROM profissionais where sysActive=1 and ativo='on'"&franquiaUnidade(" AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),true) ")
        Case "SomenteProfissionais"
            sql = "SELECT id,IF(id<0,CONCAT('<span class=""badge"">',NomeProfissional,'</span>'),NomeProfissional) AS nome FROM (select id, NomeProfissional "&franquiaUnidade(", 0 hidden")&"  from profissionais where ativo='on' UNION ALL SELECT id*-1 id, NomeEquipamento NomeProfissional "&franquiaUnidade(", NOT (UnidadeID = "&session("UnidadeID")&") as hidden ")&" FROM equipamentos WHERE Ativo='on' and sysActive=1)t "
        Case "SomenteEspecialidades"
            sql = "SELECT id, especialidade AS nome FROM  especialidades where sysActive=1"
        Case "Usuarios"
            if Condicoes<>false then 'FILTRA PROFISSIONAIS POR TIPO
                Select Case Condicoes
                    Case "profissionais"
                        ColunaNome = "NomeProfissional"
                        TabelaJoin = " LEFT JOIN profissionais AS Cond ON Cond.id=u.idInTable "&chr(13)
                    Case "funcionarios"
                        ColunaNome = ""
                        TabelaJoin = " LEFT JOIN funcionarios AS Cond ON Cond.id=u.idInTable "&chr(13)
                End Select

                sql = " SELECT u.id, Cond."&ColunaNome&" AS nome             "&chr(13)&_
                      " FROM sys_users AS u                                   "&chr(13)&_
                      TabelaJoin&" WHERE Cond.sysActive=1                                "
            else 'PEGA TODOS OS USUÁRIOS ATIVOS

                sql=" SELECT id, Nome                                                                      "&chr(13)&_
                    " FROM cliniccentral.licencasusuarios                                                  "&chr(13)&_
                    " WHERE LicencaID=8854 AND Email NOT LIKE '' AND Nome NOT LIKE '' AND Senha NOT LIKE ''"&chr(13)&_
                    " ORDER BY Nome                                                                        "

            end if
        Case "Cid10"
            sql = "SELECT id, Codigo AS codigo, Descricao AS nome FROM cliniccentral.cid10"
    End Select
    
    getSQLQuickField = "SELECT * FROM ("&sql&") AS t WHERE true"

end function

function FieldExists(ByVal rs, ByVal fieldName) 
    On Error Resume Next
    FieldExists = rs.Fields(fieldName).name <> ""
    If Err <> 0 Then FieldExists = False
    Err.Clear
end function



%>