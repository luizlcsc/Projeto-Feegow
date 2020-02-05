
<!--#include file="Connection.asp"-->
<%

function ExecuteAllServers(sql)
    set AllServers = db.execute("select * from cliniccentral.servers where sysActive=1")

    if not AllServers.eof then
        while not AllServers.eof
            set dbNew = newConnection("",AllServers("Server"))
            dbNew.execute(sql)

       	AllServers.movenext
        wend
        AllServers.close
        
    end if 
end function
%>