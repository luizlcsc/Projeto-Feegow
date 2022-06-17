<%
if TypeName(dbc)="Connection" then
 dbc.close
 Set dbc = nothing
end if
if TypeName(db)="Connection" then
 db.close
 Set db = nothing
end if
%>