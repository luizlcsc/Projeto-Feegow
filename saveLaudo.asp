<!--#include file="connect.asp"-->
<%
Texto = ref("Texto")
StatusID = ref("StatusID")
Obs = ref("ObsEntrega")
Receptor = ref("Receptor")
LaudoID = req("L")
ProfissionalID = ref("ProfissionalID")
Tipo = req("T")
Restritivo = ref("Restritivo")
Entrega = ref("DataEntrega") &" "& ref("HoraEntrega")

if Tipo="Texto" then
    db.execute("update laudos set Texto='"& Texto &"' where id="& LaudoID)
elseif Tipo="StatusID" then
    if lcase(session("Table"))="profissionais" then
        sqlProfissional = ", ProfissionalID="& session("idInTable")
    end if
    db.execute("update laudos set StatusID="& StatusID &sqlProfissional&" where id="& LaudoID)
    db.execute("insert into laudoslog (LaudoID, sysUser, StatusID) values ("& LaudoID &", "& session("User") &", "& StatusID &")")
elseif Tipo="ProfissionalID" then
    db.execute("update laudos set ProfissionalID="& ProfissionalID &" where id="& LaudoID)
    db.execute("insert into laudoslog (LaudoID, sysUser, Obs) values ("& LaudoID &", "& session("User") &", 'Profissional alterado "&ProfissionalID&"')")
elseif Tipo="Restritivo" then
    db.execute("update laudos set Restritivo="& treatvalzero(Restritivo) &" where id="& LaudoID)
    db.execute("insert into laudoslog (LaudoID, sysUser, Restritivo) values ("& LaudoID &", "& session("User") &", "& treatvalzero(Restritivo) &")")
elseif Tipo="Entrega" then
    db.execute("update laudos set Entregue=1 where id="& LaudoID)
    db.execute("insert into laudoslog (LaudoID, sysUser, Entregue, Receptor, Obs, DataHora) values ("& LaudoID &", "& session("User") &", 1, '"& Receptor &"', '"& Obs &"', "& mydatetime(Entrega) &")")
    %>
    $("#modal-table").modal("hide");
    <%
end if

%>

new PNotify({
    title: 'SUCESSO!',
    text: 'Dados do laudo alterados.',
    type: 'success',
    delay: 3000
});
