<!--#include file="connect.asp"-->

<%
TarefaID = req("I")
emExec = 0
Acao = ref("A")

if req("Helpdesk") = "" then


sqlExecutando = db.execute("SELECT COUNT(id) AS qtdExecutando FROM tarefasexecucao WHERE sysUser = "&session("User")&" AND Fim IS NULL")
qtdExecutando = sqlExecutando("qtdExecutando")
bloqueado = 0

if qtdExecutando <> "0" then
    bloqueado = 1
    idExecutando = db.execute("SELECT TarefaID FROM tarefasexecucao WHERE sysUser = "&session("User")&" AND Fim IS NULL LIMIT 1")
    idExecutando = idExecutando("TarefaID")
end if

if Acao="TXT" then
    db.execute("UPDATE tarefasexecucao SET Texto='"& ref("Texto") &"' WHERE ISNULL(Fim) AND TarefaID="& TarefaID &" AND sysUser="& session("User"))
end if
if Acao = "GO" then
    db.execute("insert into tarefasexecucao set TarefaID="& TarefaID &", sysUser="& session("User"))
end if
if Acao = "STOP" then
    db.execute("UPDATE tarefasexecucao set Fim=NOW() WHERE ISNULL(Fim) AND TarefaID="& TarefaID &" AND sysUser="& session("User"))
    bloqueado = 0
end if

set exe = db.execute("select te.*, lu.Nome from tarefasexecucao te LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=te.sysUser where te.TarefaID="& TarefaID)
while not exe.eof
    if isnull(exe("Fim")) then
        tit = "Em execução desde "& exe("Inicio")
        if exe("sysUser")=session("User") then
            emExec = 1
            TextoTextarea = exe("Texto")
            Texto = ""
        end if
    else
        tit =  exe("Inicio")&" - "& exe("Fim")
        Texto = exe("Texto")
    end if
    %>
    <div class="row">
        <b><%= nameInTable(exe("sysUser")) &" - "& tit%></b>
        <br />
        &nbsp; &nbsp; <em><%= Texto %></em>
    </div>
    <%
exe.movenext
wend
exe.close
set exe=nothing


%>
<hr class="short alt" />
<%
if emExec=1 then
    %>
    <textarea class="form-control" id="TextoExecucao"  placeholder="Descrição da execução"><%= TextoTextarea %></textarea>
    <button title="Parar execução" onclick="executarTarefa('STOP')" class="btn btn-danger btn-gradient btn-block" type="button"><i class="far fa-stop"></i> Parar execução</button>
    <%
else
    if bloqueado = 0 then
    %>
    <button title="Executar tarefa" onclick="executarTarefa('GO')" class="btn btn-system btn-gradient btn-block" type="button"><i class="far fa-play"></i> Executar tarefa</button>
    <%
    else
    %>
    <a class="btn-link" target="_blank" href="./?P=Tarefas&I=<%=idExecutando%>&Pers=1"><p class="text-center text-info">Você já possui uma tarefa em execução. Clique aqui para ir até ela.</p></a>
    <button title="Executar tarefa" disabled onclick="executarTarefa('GO')" class="btn btn-system btn-gradient btn-block" type="button"><i class="far fa-play"></i> Executar tarefa</button>
    <%
    end if
end if
%>
<hr class="short alt" />

<script type="text/javascript">
$("#TextoExecucao").change(function(){
    executarTarefa('TXT');
});
</script>
<%
end if

%>