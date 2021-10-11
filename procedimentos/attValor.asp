<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sql =   " UPDATE procedimentostabelasvalores                                            "&chr(13)&_
            " SET Valor='"&req("valor")&"' , RecebimentoParcial='"&req("recebimento")&"'    "&chr(13)&_
            " WHERE id='"&req("tabelaId")&"';                                               "

    db.execute(sql)
    ' response.write(sql)
    response.write(true)

%>

            