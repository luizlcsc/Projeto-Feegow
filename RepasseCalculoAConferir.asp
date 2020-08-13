<%
Forma = reqf("Forma")
if instr(Forma, "|0|") then
    server.execute("RepasseCalculoAConferirParticular.asp")
end if

if Forma<>"" and Forma<>"|0|" then
    server.execute("RepasseCalculoAConferirConvenio.asp")
end if
%>