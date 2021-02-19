<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../Classes/StringFormat.asp"-->
<% 
    response.Charset="utf-8" 
    
    sql =   " select                                                    "&chr(13)&_
            " 	mc.id,                                                  "&chr(13)&_
            " 	GROUP_CONCAT(mc.id) as idDelete,                        "&chr(13)&_
            " 	mc.produtoPrescrito,                                    "&chr(13)&_
            " 	p.NomeProduto as produtoPrescritoNome,                  "&chr(13)&_
            " 	mc.produtoReferencia,                                   "&chr(13)&_
            " 	p2.NomeProduto as produtoReferenciaNome,                "&chr(13)&_
            " 	GROUP_CONCAT(DISTINCT mc.convenioID) as convenios,      "&chr(13)&_
            " 	GROUP_CONCAT(DISTINCT c.NomeConvenio) as conveniosnomes,"&chr(13)&_
            " 	GROUP_CONCAT(mc.planoID) as planos,                     "&chr(13)&_
            " 	GROUP_CONCAT(cp.NomePlano) as planosNomes               "&chr(13)&_
            " from medicamentos_convenio mc                             "&chr(13)&_
            " join produtos p on p.id = mc.produtoPrescrito             "&chr(13)&_
            " join produtos p2 on p2.id = mc.produtoReferencia          "&chr(13)&_
            " join convenios c on c.id = mc.convenioID                  "&chr(13)&_
            " left join conveniosplanos cp on cp.id = mc.planoID        "&chr(13)&_
            " group by produtoPrescrito ,produtoReferencia              "

    response.write(recordToJSON(db.execute(sql)))
%>