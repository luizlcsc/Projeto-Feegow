<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sql =   " INSERT INTO procedimentostabelasvalores                   "&chr(13)&_
            " (                                                         "&chr(13)&_
            "  ProcedimentoID,                                          "&chr(13)&_
            "  TabelaID,                                                "&chr(13)&_
            "  Valor,                                                   "&chr(13)&_
            "  RecebimentoParcial                                       "&chr(13)&_
            " )                                                         "&chr(13)&_
            " VALUES(                                                   "&chr(13)&_
            "     "&req("procedimento")&",                              "&chr(13)&_
            "     "&req("tabelaId")&",                                  "&chr(13)&_
            "     '"&req("valor")&"',                                   "&chr(13)&_
            "     '"&req("recebimento")&"'                              "&chr(13)&_
            " );                                                        "


    ' response.write(sql)
    db.execute(sql)
    lastIdCriado = getLastAdded("procedimentostabelasvalores")
    response.write("{success: true, id:"&lastIdCriado&"}")
%>