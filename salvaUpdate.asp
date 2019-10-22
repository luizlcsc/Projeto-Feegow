  <meta http-equiv="refresh" content="5">
<%
on error resume next

dim fs,f
set fs=Server.CreateObject("Scripting.FileSystemObject")

response.Write( time() &"<br>")



Servidores = array(43, 45)
for i=0 to ubound(Servidores)

    Servidor = Servidores(i)

    ConnString = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193."& Servidor &";Database=clinic105;uid=root;pwd=pipoca453;"
    Set dbServ = Server.CreateObject("ADODB.Connection")
    dbServ.Open ConnString

    Banco = ""
    set gt = dbServ.execute("select * from cliniccentral.updates order by banco, id limit 200")
    idsApagar = ""
    while not gt.eof
        idsApagar = idsApagar & gt("id")&", "
        if Banco<>gt("Banco") then
            Banco = gt("Banco")
            set f=fs.OpenTextFile("c:\inetpub\wwwroot\feegowclinic\updates\"& Banco &".sql", 8, 1)
            ConnStringLocal = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193.34;Database="& Banco &";uid=usr2;pwd=pipoca453;"
            Set dbLocal = Server.CreateObject("ADODB.Connection")
            dbLocal.Open ConnStringLocal
        end if
        codigoSQL = gt("codigoSQL")
        f.WriteLine( codigoSQL &";" )
        dbLocal.Execute( codigoSQL )
'        response.write("<br>"& Banco &" :: "& codigoSQL &"<br>")
    gt.movenext
    wend
    gt.close
    set gt = nothing
    dbServ.execute("delete from cliniccentral.updates where id in ("& idsApagar &" 0)")
    response.write("delete from cliniccentral.updates where id in ("& idsApagar &" 0) <br>")
next

f.close
set f=nothing
set fs=nothing

response.Write( time() )
%>
