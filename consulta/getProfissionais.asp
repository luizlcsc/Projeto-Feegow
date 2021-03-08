<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    tabela =    " CREATE temporary table if NOT EXISTS vw_executantes as                                                        "&chr(13)&_
                " 	select                                                                                                      "&chr(13)&_
                " 			2 tipo,                                                                                             "&chr(13)&_
                " 			concat('|2_',id,'|') as idIntegracao,                                                               "&chr(13)&_
                " 			id,                                                                                                 "&chr(13)&_
                " 			NomeFornecedor as nome                                                                              "&chr(13)&_
                " 		from fornecedores                                                                                       "&chr(13)&_
                " 		where sysActive=1 and Ativo='on'                                                                        "&chr(13)&_
                " 		union                                                                                                   "&chr(13)&_
                " 		select                                                                                                  "&chr(13)&_
                " 			8 tipo,                                                                                             "&chr(13)&_
                " 			concat('|8_',id,'|') as idIntegracao,                                                               "&chr(13)&_
                " 			id,                                                                                                 "&chr(13)&_
                " 			NomeProfissional as nome                                                                            "&chr(13)&_
                " 		from profissionalexterno                                                                                "&chr(13)&_
                " 		where sysActive=1                                                                                       "&chr(13)&_
                " 		union                                                                                                   "&chr(13)&_
                " 		select                                                                                                  "&chr(13)&_
                " 			4 tipo,                                                                                             "&chr(13)&_
                " 			concat('|4_',id,'|') as idIntegracao,                                                               "&chr(13)&_
                " 			id,                                                                                                 "&chr(13)&_
                " 			NomeFuncionario as nome                                                                             "&chr(13)&_
                " 		from funcionarios                                                                                       "&chr(13)&_
                " 		where sysActive=1                                                                                       "&chr(13)&_
                " 		and Ativo='on'                                                                                          "&chr(13)&_
                " 		and COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&req("unidades")&"',''),'|0|')),TRUE)     "&chr(13)&_
                " 		union                                                                                                   "&chr(13)&_
                " 		select                                                                                                  "&chr(13)&_
                " 			5 tipo,                                                                                             "&chr(13)&_
                " 			concat('|',id,'|') as idIntegracao,                                                                 "&chr(13)&_
                " 			id,                                                                                                 "&chr(13)&_
                " 			IF(NomeSocial IS NULL or NomeSocial ='', NomeProfissional , NomeSocial)                             "&chr(13)&_
                " 			NomeProfissional                                                                                    "&chr(13)&_
                " 		from profissionais                                                                                      "&chr(13)&_
                " 		where sysActive=1                                                                                       "&chr(13)&_
                " 		and Ativo='on'                                                                                          "&chr(13)&_
                " 		and COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('"&req("unidades")&"',''),'|0|')),TRUE)       "

    db.execute(tabela)   

    sql = "select  * from vw_executantes where nome like '%"&req("nome")&"%'"         
                
                
    response.write(recordToJSON(db.execute(sql)))
    %>