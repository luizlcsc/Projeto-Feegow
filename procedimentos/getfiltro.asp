<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"
    response.write("[]")
    response.end

    table = " CREATE temporary table if NOT EXISTS vw_executantes as                                "&chr(13)&_
            " select                                                                                "&chr(13)&_
            " 			2 tipo,                                                                     "&chr(13)&_
            " 			concat('|2_',id,'|') as idIntegracao,                                       "&chr(13)&_
            " 			id,                                                                         "&chr(13)&_
            " 			NomeFornecedor as nome                                                      "&chr(13)&_
            " 		from fornecedores                                                               "&chr(13)&_
            " 		where sysActive=1 and Ativo='on'                                                "&chr(13)&_
            " 		union                                                                           "&chr(13)&_
            " 		select                                                                          "&chr(13)&_
            " 			8 tipo,                                                                     "&chr(13)&_
            " 			concat('|8_',id,'|') as idIntegracao,                                       "&chr(13)&_
            " 			id,                                                                         "&chr(13)&_
            " 			NomeProfissional as nome                                                    "&chr(13)&_
            " 		from profissionalexterno                                                        "&chr(13)&_
            " 		where sysActive=1                                                               "&chr(13)&_
            " 		union                                                                           "&chr(13)&_
            " 		select                                                                          "&chr(13)&_
            " 			4 tipo,                                                                     "&chr(13)&_
            " 			concat('|4_',id,'|') as idIntegracao,                                       "&chr(13)&_
            " 			id,                                                                         "&chr(13)&_
            " 			NomeFuncionario as nome                                                     "&chr(13)&_
            " 		from funcionarios                                                               "&chr(13)&_
            " 		where sysActive=1  and Ativo='on'                                               "&chr(13)&_
            " 		union                                                                           "&chr(13)&_
            " 		select                                                                          "&chr(13)&_
            " 			5 tipo,                                                                     "&chr(13)&_
            " 			concat('|',id,'|') as idIntegracao,                                         "&chr(13)&_
            " 			id,                                                                         "&chr(13)&_
            " 			IF(NomeSocial IS NULL or NomeSocial ='', NomeProfissional , NomeSocial)     "&chr(13)&_
            " 			NomeProfissional                                                            "&chr(13)&_
            " 		from profissionais                                                              "&chr(13)&_
            " 		where sysActive=1 and Ativo='on'                                                "
    db.execute(table)

    table2 = " CREATE temporary table if NOT EXISTS vw_executantes2 as                              "&chr(13)&_
             " select * FROM vw_executantes                                                          "

    db.execute(table2)

    sql = " select  pt.id,                                                                                                                                                                                                          "&chr(13)&_
        " 		pt.NomeTabela,                                                                                                                                                                                                      "&chr(13)&_
        " 		ptv.id as idTabelaValor,                                                                                                                                                                                            "&chr(13)&_
        " 		pt.inicio,                                                                                                                                                                                                          "&chr(13)&_
        " 		pt.fim,                                                                                                                                                                                                             "&chr(13)&_
        " 		ptv.Valor,                                                                                                                                                                                                          "&chr(13)&_
        " 		ptv.RecebimentoParcial,                                                                                                                                                                                              "&chr(13)&_
        " 		pt.Tipo,                                                                                                                                                                                                            "&chr(13)&_
        " 		ptv.RecebimentoParcial,                                                                                                                                                                                             "&chr(13)&_
        " 		(select group_concat(nomeTabela) from tabelaparticular tabelas where pt.TabelasParticulares like concat( '%|',tabelas.id,'|%')) as tabelasParticulares,                                                             "&chr(13)&_
        " 		(select group_concat(id) from tabelaparticular tabelas where pt.TabelasParticulares like concat( '%|',tabelas.id,'|%')) as tabelasParticularesId,                                                                   "&chr(13)&_
        " 	    (select group_concat(nomefantasia) from vw_unidades where pt.Unidades like concat( '%|',vw_unidades.id,'|%')) as unidades,                                                                                          "&chr(13)&_
        " 	    (select group_concat(id) from vw_unidades where pt.Unidades like concat( '%|',vw_unidades.id,'|%')) as unidadesId,                                                                                                  "&chr(13)&_
        " 	    (select coalesce(group_concat(' ',especialidade ORDER BY especialidade ASC),'Todos') from especialidades e where pt.Especialidades like concat( '%|',e.id,'|%') order by especialidades desc )as especialidades,    "&chr(13)&_
        " 	    (select group_concat(' ',id ORDER BY especialidade ASC) from especialidades e where pt.Especialidades like concat( '%|',e.id,'|%') order by especialidades desc )as especialidadesId,                               "&chr(13)&_
        " 	    p.NomeProcedimento ,                                                                                                                                                                                                "&chr(13)&_
        " 	    p.id as procedimentoId ,                                                                                                                                                                                            "&chr(13)&_
        " 	    (select coalesce(group_concat(' ',nome),'Todos') from vw_executantes where pt.Profissionais like concat( '%',vw_executantes.idIntegracao,'%')) as profissionais,                                                    "&chr(13)&_
        " 	    (select group_concat(idIntegracao) from vw_executantes2 where pt.Profissionais like concat( '%',vw_executantes2.idIntegracao,'%')) as profissionaisId                                                               "&chr(13)&_
        " FROM procedimentostabelas pt                                                                                                                                                                                              "&chr(13)&_
        " join procedimentostabelasvalores ptv                                                                                                                                                                                      "&chr(13)&_
        " 	on ptv.TabelaID = pt.id                                                                                                                                                                                                 "&chr(13)&_
        " join procedimentos p                                                                                                                                                                                                      "&chr(13)&_
        " 	on p.id = ptv.ProcedimentoID                                                                                                                                                                                            "&chr(13)&_
        " where                                                                                                                                                                                                                     "&chr(13)&_
        " 	coalesce(pt.tipo = nullif('"&req("tipo")&"',''),true)                                                                                                                                                                   "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        " 	coalesce(cliniccentral.overlap(pt.Unidades ,nullif('"&req("unidades")&"','')),true)                                                                                                                                     "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        " 	coalesce(cliniccentral.overlap(pt.TabelasParticulares ,nullif('"&req("tabelas")&"','')),true)                                                                                                                           "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        " 	coalesce(cliniccentral.overlap(pt.Especialidades ,nullif('"&req("especialidades")&"','')),true)                                                                                                                         "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        " 	coalesce(ptv.id = nullif('"&req("tabelaPreco")&"',''),true)                                                                                                                                       "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        "   coalesce(pt.sysActive = nullif('"&req("status")&"',''),true)                                                                                                                                                            "&chr(13)&_
        " and                                                                                                                                                                                                                       "&chr(13)&_
        "   coalesce(p.NomeProcedimento like nullif('"&req("procedimento")&"',''),true)                                                                                                                                             "&chr(13)&_
        "  group by pt.id                                                                                                                                                                                                           "

    ' response.write(sql)

    response.write(recordToJSON(db.execute(sql)))

%>