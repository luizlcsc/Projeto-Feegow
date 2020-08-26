<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<% 
    response.Charset="utf-8" 

    tipo = ref("tipo")
    dose = ref("dose")
    obs = ref("obs")
    id = ref("id")

    remover = ""
    if tipo = "R" then
    remover = "sysActive=-1,"
    end if

    sql = "UPDATE pacientesprotocolosmedicamentos SET DoseMedicamento="&dose&", "&remover&" Obs='"&obs&"' WHERE id="&id

    db.execute(sql)

    response.write(true)
%>