<!--#include file="Connection.asp"-->
<!--#include file="Query.asp"-->
<!--#include file="Environment.asp"-->
<%

function ExecuteAllServers(sql)
    sqlServers = "select * from cliniccentral.db_servers where Active=1 and isMain=1 and Env='"&getEnv("FC_APP_ENV","local")&"'"

    set AllServers = db.execute(sqlServers)
    valueToReturn = Null

    if not AllServers.eof then
        while not AllServers.eof
            isMain = AllServers("IsMain")

            set dbNew = newConnection("",AllServers("DNS"))
            dbNew.execute(sql)

            if isMain then
                sqlCommandSplit = split(sql, " ")
                sqlCommand = sqlCommandSplit(0)

                if lcase(sqlCommand)="insert" then
                    valueToReturn=getLastId()
                end if
            end if

       	AllServers.movenext
        wend
        AllServers.close
        
    end if
    ExecuteAllServers= valueToReturn
end function
%>