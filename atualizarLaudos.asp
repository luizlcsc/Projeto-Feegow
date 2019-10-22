<!--#include file="connect.asp"-->
<%

id = ref("I")
status = ref("status")

status = Replace(status,"|","")

Tabela = ref("T")
PacienteID=ref("Pac")
IDTabela=ref("IDT")
ProcedimentoID = ref("Proc")
DataExecucao=ref("E")

if id<>"" then

    sql = "update laudos set StatusID = "&status&" where id = "&id

    db.execute("insert into laudoslog (LaudoID, sysUser, StatusID) values ("& id &", "& session("User") &", "& status &")")
    db_execute(sql)
else
    sql = "insert into laudos(PacienteID, ProcedimentoID, Tabela, IDTabela, FormID, PrevisaoEntrega, StatusID, Restritivo, Entregue, DHUp) values("&PacienteID&", "&ProcedimentoID&", '"&Tabela&"', "&IDTabela&", 0, now(), "&status&",0,0,now() )"
    db_execute(sql)
end if

%>
showMessageDialog("Laudo salvo com sucesso", "success")
