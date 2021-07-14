<%
sServidor = "192.168.193.45"

LicencaID = 522
ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server="& sServidor &";Database=clinic"& LicencaID &";uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
Set db = Server.CreateObject("ADODB.Connection")
db.Open ConnString

dh = "2018-10-11 00:00:01"

set tmod = db.execute("select i.table_name, i.update_time from information_schema.tables i where i.table_schema='clinic"& LicencaID &"' and i.update_time>'"& dh &"' LIMIT 15")
while not tmod.eof
    Colunas = ""
    %>
    <%= tmod("table_name") &"_"& tmod("update_time") &"<br>" %>
    <%
    set pcols = db.execute("select i.column_name from information_schema.columns i where i.table_schema='clinic"& LicencaID &"' and i.table_name='"& tmod("table_name") &"'")
    while not pcols.eof
        Colunas = Colunas & ", "& pcols("column_name")
    pcols.movenext
    wend
    pcols.close
    set pcols = nothing
    Colunas = right(Colunas, len(Colunas)-2)
    %>
    <%= Colunas &"<br>" %>
    <%

    spl = split(Colunas, ", ")
    set dados = db.execute("select * from `clinic"& LicencaID &"`.`"& tmod("table_name") &"` where DHUp>='"& dh &"'")
    while not dados.eof
        
        sqlV = ""
        for i=0 to ubound(spl)
            sqlV = sqlV & ", '"& dados(""&spl(i)&"") &"'"
        next
        sqlV = right(sqlV, len(sqlV)-2)
        sql = "replace into `clinic"& LicencaID &"`.`"& tmod("table_name") &"` ("& Colunas &") values ("& sqlV &")"
        
        response.write( sql &"<hr>" )
    dados.movenext
    wend
    dados.close
    set dados = nothing
tmod.movenext
wend
tmod.close
set tmod = nothing
%>