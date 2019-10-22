<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
Tela = req("Tela")
TreinamentoID = req("TreinamentoID")
set vca = db.execute("select id from treinamentosmemo where TreinamentoID="& TreinamentoID &" and Tipo='"& Tipo &"' and Tela="& Tela &"")
if vca.eof then
    if ref("M")<>"" then
        db.execute("insert into treinamentosmemo (TreinamentoID, Tipo, Tela, Memo, Hora) values ("& TreinamentoID &", '"& Tipo &"', '"& Tela &"', '"& ref("M") &"', NOW())")
    end if
else
    db.execute("update treinamentosmemo set Memo='"& ref("M") &"', Hora=NOW() where id="& vca("id"))
end if
%>