<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    GrupoID = req("GrupoID")
    TipoTabela = req("Tipo")



    sql =   " select                                                "&chr(13)&_
            " 	p.id,                                               "&chr(13)&_
            " 	p.NomeProcedimento,                                 "&chr(13)&_
            " 	p.Valor,                                            "&chr(13)&_
            " 	IF(p.PermiteAlteracaoDePrecoPelasUnidades!='S'      "&chr(13)&_
            "   AND 'V'='"&TipoTabela&"'                            "&chr(13)&_
            "   AND '"&session("UnidadeID")&"'<>0,0,1)              "&chr(13)&_
            "   PermiteAlteracao,                                   "&chr(13)&_
            " 	ptv.Valor ValorTabela,                              "&chr(13)&_
            " 	p.TipoProcedimentoID,                               "&chr(13)&_
            " 	TipoProcedimento,                                   "&chr(13)&_
            " 	ptv.RecebimentoParcial,                             "&chr(13)&_
            " 	"&req("tabelaId")&" TabelaID                        "&chr(13)&_
            " from                                                  "&chr(13)&_
            " 	procedimentos p                                     "&chr(13)&_
            " left join TiposProcedimentos on                       "&chr(13)&_
            " 	TiposProcedimentos.id = p.TipoProcedimentoID        "&chr(13)&_
            " left join procedimentostabelasvalores ptv on          "&chr(13)&_
            " 	(ptv.ProcedimentoID = p.id                          "&chr(13)&_
            " 	and ptv.TabelaID = "& req("tabelaId") &")           "&chr(13)&_
            " where                                                 "&chr(13)&_
            " 	sysActive = 1                                       "&chr(13)&_
            " 	and ativo = 'on'                                    "

    if req("nome") <> "" Then
        sql =  sql + " 	and p.NomeProcedimento like '%"&req("nome")&"%'     "
    End if

    if GrupoID<>"" and GrupoID&""<>"0" then
        sql = sql + " AND p.GrupoID IN ("&GrupoID&")"
    end if

    sql =  sql & franquiaUnidade(" AND p.id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&")")
    sql =  sql & " order by                                              "&chr(13)&_
                 " NomeProcedimento   desc             limit 100         "

    response.write(recordToJSON(db.execute(sql)))
    %>