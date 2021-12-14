<!--#include file="../connect.asp"-->
<%
    IF ModoFranquia THEN
        db_execute("DELETE FROM sys_financialmovement WHERE TYPE = 'Pay' AND VALUE = 0;")
    END IF
%>
true