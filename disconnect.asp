<%
dd(TypeName(dbc))
if TypeName(dbc)="Object" then
 dbc.close
 Set dbc = nothing
end if
if TypeName(db)="Object" then
 db.close
 Set db = nothing
end if
%>