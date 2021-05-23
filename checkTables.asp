<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8"
    tabelaAtual = req("I")

    ' tabelaAtual= "603800"

    sql =   " SELECT t2.id, t2.NomeTabela                                                                                                                                                                                    "&chr(13)&_
            "   FROM procedimentostabelas t1,procedimentostabelas t2                                                                                                                                                         "&chr(13)&_
            " WHERE t1.id = "&tabelaAtual&"                                                                                                                                                                                  "&chr(13)&_
            " AND t1.id <> t2.id                                                                                                                                                                                             "&chr(13)&_
            " AND NOW() BETWEEN t1.Inicio AND t1.Fim                                                                                                                                                                         "&chr(13)&_
            " AND NOW() BETWEEN t2.Inicio AND t2.Fim                                                                                                                                                                         "&chr(13)&_
            " AND (t1.Unidades = t2.Unidades OR NULLIF(t1.Unidades,'') IS NULL OR NULLIF(t2.Unidades,'') OR cliniccentral.overlap(t2.Unidades,t1.Unidades))                                                                  "&chr(13)&_
            " AND (t1.profissionais = t2.profissionais OR NULLIF(t1.profissionais,'') IS NULL OR NULLIF(t2.profissionais,'') OR cliniccentral.overlap(t2.profissionais,t1.profissionais))                                    "&chr(13)&_
            " AND (t1.Especialidades = t2.Especialidades OR NULLIF(t1.Especialidades,'') IS NULL OR NULLIF(t2.Especialidades,'') OR cliniccentral.overlap(t2.Especialidades,t1.Especialidades))                              "&chr(13)&_
            " AND (t1.TabelasParticulares = t2.TabelasParticulares OR NULLIF(t1.TabelasParticulares,'') IS NULL OR NULLIF(t2.TabelasParticulares,'') OR cliniccentral.overlap(t2.TabelasParticulares,t1.TabelasParticulares))"&chr(13)&_
            " AND (t1.Convenios = t2.Convenios OR NULLIF(t1.Convenios,'') IS NULL OR NULLIF(t2.Convenios,'') OR cliniccentral.overlap(t2.Convenios,t1.Convenios))                                                            "&chr(13)&_
            " AND t1.sysActive = 1                                                                                                                                                                                           "&chr(13)&_
            " AND t2.sysActive = 1;                                                                                                                                                                                          "

    response.write(recordToJSON(db.execute(sql)))

%>