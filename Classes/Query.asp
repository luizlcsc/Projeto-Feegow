<!--#include file="./../connect.asp"-->
<%
function getLastId()
    set LastIDSQL = db.execute("SELECT LAST_INSERT_ID() AS id")

    getLastId=LastIDSQL("id")
end function
%>
