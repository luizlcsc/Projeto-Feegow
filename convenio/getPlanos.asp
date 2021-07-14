<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../Classes/StringFormat.asp"-->
<% 
    response.Charset="utf-8" 
    
    sql =   " select id,NomePlano           "&chr(13)&_
            " from conveniosplanos c        "&chr(13)&_
            " where sysActive = 1           "&chr(13)&_
            " and NomePlano is not null     "&chr(13)&_
            " and NomePlano <> ''           "&chr(13)&_
            " and ConvenioID ="&req("convenio")

    response.write(recordToJSON(db.execute(sql)))
%>