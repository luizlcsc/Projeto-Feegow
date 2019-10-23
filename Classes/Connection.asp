<%
'Arquivo de conexão
function newConnection(customDatabase, customHost)
    set shellExec = createobject("WScript.Shell")
    Set objSystemVariables = shellExec.Environment("SYSTEM")
    MySQLDriver			   = objSystemVariables("FC_MYSQL_DRIVER")
    MySQLServer	 		   = objSystemVariables("FC_MYSQL_HOST")
    MySQLDB		 		   = objSystemVariables("FC_MYSQL_DATABASE")
    MySQLUser	 		   = objSystemVariables("FC_MYSQL_USER")
    MySQLPassword		   = objSystemVariables("FC_MYSQL_PASSWORD")

    if customDatabase<>"" then
        MySQLDB=customDatabase
    end if

    if customHost<>"" then
        MySQLServer=customHost
    end if

    ConnString = "Driver={"&MySQLDriver&"};Server="&MySQLServer&";Database="&MySQLDB&";uid="&MySQLUser&";pwd="&MySQLPassword&";"
    Set dbConnection = Server.CreateObject("ADODB.Connection")
    dbConnection.Open ConnString

    set newConnection = dbConnection
end function
%>