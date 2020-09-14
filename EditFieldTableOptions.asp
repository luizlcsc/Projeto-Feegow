<!--#include file="connect.asp"-->
<%
CampoID = req("CampoID")
Acao = req("A")
txt = req("Txt")
Coluna = req("Col")
ID = req("I")

if Acao="I" then
    db.execute("insert into buiopcoescampos set CampoID="& CampoID &", Valor='"& Coluna &"'")
elseif Acao="A" then
    db.execute("update buiopcoescampos set Nome='"& txt &"' where ID="& ID)
elseif Acao="X" then
    db.execute("delete from buiopcoescampos where ID="& ID )
end if

set ops = db.execute("select * from buiopcoescampos where CampoID="& CampoID &" and Valor='"& Coluna &"'")
while not ops.eof
    %>
    <%= quickfield("text", "o"& ops("id"), "", 12, "", "", "", "") %>
    <%
ops.movenext
wend
ops.close
set ops = nothing
%>