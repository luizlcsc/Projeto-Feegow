<%

Servidores = array(1, 2, 3)
for i=0 to ubound(Servidores)

    Servidor = Servidores(i)

    ConnString = "Driver={MySQL ODBC 8.0 ANSI Driver};Server=dbfeegow0"& Servidores(i) &".cyux19yw7nw6.sa-east-1.rds.amazonaws.com;Database=cliniccentral;uid=root;pwd=pipoca453;"
    Set dbServ = Server.CreateObject("ADODB.Connection")
    dbServ.Open ConnString

        %>
        <h4>Servidor <%= Servidor %></h4>
        <%
    pNULL = 0
    pNOTNULL = 0

    set procs = dbServ.execute("SELECT `ID`, `USER`, `HOST`, `DB`, `COMMAND`, `TIME`, `STATE`, LEFT(`INFO`, 51200) AS `Info` FROM `information_schema`.`PROCESSLIST`")
    while not procs.eof
        if isnull(procs("Info")) then
            pNULL = pNULL+1
        else
            pNOTNULL = pNOTNULL+1
        end if
    procs.movenext
    wend
    procs.close
    set procs=nothing
    
    %>
    Livres:<%= pNULL %><br />
    Executando: <%= pNOTNULL %>
    <%
next
%>