﻿<!--#include file="connect.asp"-->
<%
Operation=req("Operation")
I=req("I")
Pers=req("Pers")
Table=req("P")
Identifier=req("Identifier")

IDToRedirect = 0

NextOrPrevious = ""

if Operation="Next" then
    NextOrPrevious = ">"
    Order = "asc"
else
    NextOrPrevious = "<"
    Order = "desc"
end if
sql = "select (select id from `"&Table&"` where `"&Identifier&"`"&NextOrPrevious&"r.`"&Identifier&"` and sysActive=1 order by `"&Identifier&"` "&Order&" limit 1) redirId " &_
                                   "FROM `"&Table&"` r WHERE r.id="&treatvalzero(I)

set RedirectSQL = db.execute(sql)
if not RedirectSQL.eof then
    IDToRedirect= RedirectSQL("redirId")

    if not isnull(IDToRedirect) then
        Response.Redirect("./?P="&Table&"&Pers="&Pers&"&I="&IDToRedirect)
        Response.End
    end if
end if

Response.Redirect("./?P="&Table&"&Pers=Follow")

%>