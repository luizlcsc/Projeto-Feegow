<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->

<% 
    response.Charset="utf-8"
    sql =   " SELECT            "&chr(13)&_
            " 	id,             "&chr(13)&_
            " 	NomeProduto,    "&chr(13)&_
            " 	TipoProduto     "&chr(13)&_
            " FROM produtos     "&chr(13)&_
            " where sysActive = 1"
    
    if req("id") <> "" then
        sql = sql& " and id = "&req("id")
    end if
    
    sql = sql&  " order by NomeProduto"
                      
    ' response.write(sql)

    response.write(recordToJSON(db.execute(sql)))
%> 