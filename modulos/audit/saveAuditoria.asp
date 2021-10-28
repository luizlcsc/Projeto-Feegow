<!--#include file="./../../connect.asp"-->
<%
ItemID = ref("Auditoria_ItemID")
StatusID = ref("Auditoria_StatusID")
Notas = ref("Auditoria_Notas")
Acao = ref("Auditoria_Acao")

set ItemSQL = db.execute("SELECT id FROM auditoria_itens WHERE id="&ItemID)

if not ItemSQL.eof then
    sql = "INSERT INTO auditoria (ItemAuditoriaID, Acao, StatusID, Notas, sysUser)" &_
              " VALUES ("&ItemID&", '"&Acao&"', "&treatvalzero(StatusID)&", '"&Notas&"', "&session("User")&")"

    db.execute(sql)
    db.execute("UPDATE auditoria_itens SET Explanacao='"&Notas&"', StatusID="&statusId&" WHERE id="&ItemID)

end if

%>OK