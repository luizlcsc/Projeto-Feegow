<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    ' entrada
    ' tabelaNome
    ' inicio
    ' fim
    ' tabelasParticulares
    ' profissionais
    ' especialidades
    ' unidades
    ' tipo
    ' valor
    ' recebimento
    ' procedimento

    procedimentostabelas =  " INSERT INTO procedimentostabelas(             "&chr(13)&_
                            " NomeTabela,                                   "&chr(13)&_
                            " Inicio,                                       "&chr(13)&_
                            " Fim,                                          "&chr(13)&_
                            " TabelasParticulares,                          "&chr(13)&_
                            " Profissionais,                                "&chr(13)&_
                            " Especialidades,                               "&chr(13)&_
                            " Unidades,                                     "&chr(13)&_
                            " Tipo,                                         "&chr(13)&_
                            " ConvenioID,                                   "&chr(13)&_
                            " sysUser,                                      "&chr(13)&_
                            " sysActive                                     "&chr(13)&_
                            " )                                             "&chr(13)&_
                            " VALUES(                                       "&chr(13)&_
                            " '"&req("tabelaNome")&"',                      "&chr(13)&_
                            " '"&req("inicio")&"',                          "&chr(13)&_
                            " '"&req("fim")&"',                             "&chr(13)&_
                            " '"&req("tabelasParticulares")&"',             "&chr(13)&_
                            " '"&req("profissionais")&"',                   "&chr(13)&_
                            " '"&req("especialidades")&"',                  "&chr(13)&_
                            " '"&req("unidades")&"',                        "&chr(13)&_
                            " '"&req("tipo")&"',                            "&chr(13)&_
                            " NULL,                                         "&chr(13)&_
                            " "&Session("User")&",                          "&chr(13)&_
                            " 1                                             "&chr(13)&_
                            " );                                            "

    ' response.write(procedimentostabelas)
    db.execute(procedimentostabelas)

    ' retorna o ultimo id 

    lastId = getLastAdded("procedimentostabelas")

    idProcedimento =    " select id                                                 "&chr(13)&_
                        " from procedimentos p                                      "&chr(13)&_
                        " where p.NomeProcedimento like '%"&req("procedimento")&"%'   "
    
    set sql = db.execute(idProcedimento)
            if not sql.eof then
                idProcedimento = sql("id")
            end if


    procedimentostabelasvalores =   " INSERT INTO procedimentostabelasvalores(              "&chr(13)&_
                                    " ProcedimentoID,                                       "&chr(13)&_
                                    " TabelaID,                                             "&chr(13)&_
                                    " Valor,                                                "&chr(13)&_
                                    " RecebimentoParcial                                    "&chr(13)&_
                                    " )                                                     "&chr(13)&_
                                    " VALUES(                                               "&chr(13)&_
                                    " "&idProcedimento&",                                   "&chr(13)&_
                                    " "&lastId&",                                           "&chr(13)&_
                                    " '"&req("valor")&"',                                   "&chr(13)&_
                                    " '"&req("recebimento")&"'                              "&chr(13)&_
                                    " );                                                    "


    ' response.write(procedimentostabelasvalores)
    db.execute(procedimentostabelasvalores)
    lastIdCriado = getLastAdded("procedimentostabelasvalores")
    response.write("{success: true, id:"&lastIdCriado&"}")



%>