<!--#include file="connect.asp"-->
<%

id = ref("id")
cd = ref("CD")
value = ref("value")

if cd="D" then
    db.execute("UPDATE sys_financialexpensetype SET Name='"&value&"' WHERE id="&id)
elseif cd="C" then
    db.execute("UPDATE sys_financialincometype SET Name='"&value&"' WHERE id="&id)
end if
%>