<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<!--#include file="../Classes/StringFormat.asp"-->
<% 
    response.Charset="utf-8"

    
    unidades = converteEncapsulamento("|,",session("Unidades"))   
    
    sql =   " select id, NomeConvenio                                                       "&chr(13)&_
            " from convenios                                                                "&chr(13)&_
            " where sysActive = 1                                                           "&chr(13)&_
            " and                                                                           "&chr(13)&_
            " 	coalesce(cliniccentral.overlap(Unidades ,nullif('"&unidades&"','')),true)   " 

    response.write(recordToJSON(db.execute(sql)))
%>