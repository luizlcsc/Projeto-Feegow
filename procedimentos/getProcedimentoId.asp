<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"

    sql =   " select id  procedimentos                                      "&chr(13)&_
            " from procedimentos                                            "&chr(13)&_
            " where NomeProcedimento like '"&req("procedimento")&"'         "    


    response.write(recordToJSON(db.execute(sql)))
%>