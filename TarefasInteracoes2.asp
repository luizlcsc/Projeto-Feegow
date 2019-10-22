<!--#include file="connect.asp"-->
<link rel="stylesheet" href="assets/css/timeline.css" />

<div class="timeline timeline-line-solid">
    <span class="timeline-label">
        <span class="label">Interações</span>
    </span>

<%
if ref("msgInteracao")<>"" then
    Publico = 1
    if ref("Publico") <> "on" then
        Publico = 0
    end if
    db_execute("insert into tarefasmsgs (TarefaID, data, hora, desession, para, msg, Publico) values ("&req("I")&", curdate(), curtime(), "&session("User")&", NULL, '"&ref("msgInteracao")&"', "&Publico&")")
end if

TabelaNome = session("Table")
Select Case TabelaNome
  Case "contas"
    TabelaID = 1
  Case "fornecedor"
    TabelaID = 2
  Case "paciente"
    TabelaID = 3
  Case "funcionarios"
    TabelaID = 4
  Case "profissionais"
    TabelaID = 5
  Case "convenios"
    TabelaID = 6
  Case "caixa"
    TabelaID = 7
  Case "profissional externo"
    TabelaID = 8
  Case else
    TabelaID = 0
End Select

visualizando = TabelaID&"_"&session("idInTable")

set descricao = db.execute("select t.ta AS descricao, t.sysActive from tarefas t where t.id="&req("I"))

if not descricao.eof then
    sysActive = descricao("sysActive")
    descricao = descricao("descricao")
else
    descricao = ""
end if

set ints = db.execute("select m.*, p.NomeProfissional, f.NomeFuncionario, u.Table, p.Foto Fotop, f.Foto Fotof from tarefasmsgs m LEFT JOIN sys_users u on u.id=m.desession LEFT JOIN profissionais p on p.id=u.idInTable LEFT JOIN funcionarios f on f.id=u.idInTable where m.TarefaID="&req("I")&" order by m.data DESC, m.hora DESC")

if (ints.eof AND descricao = "") then
    response.write("<span class='timeline-label'><span class='label'>Nenhuma interação neste chamado.</span></span>")
else
    size = db.execute("SELECT COUNT(*) AS qtd FROM tarefasmsgs m WHERE m.TarefaID="&req("I"))
    size = CInt(size("qtd"))
    atual = 1

    while not ints.eof
        if lcase(ints("Table")&"")="profissionais" then
            Nome = ints("NomeProfissional")
            Foto = ints("Fotop")
        elseif lcase(ints("Table")&"")="funcionarios" then
            Nome = ints("NomeFuncionario")
            Foto = ints("Fotof")
        end if
        if isnull(Foto) or Foto="" then
            Foto = "/assets/img/user.png"
        else
            Foto = "/uploads/"&replace(session("Banco"), "clinic", "")&"/Perfil/"&Foto
        end if
        %>
        <div class="timeline-item">
            <div class="timeline-event">
                <div class="widget has-shadow">
                    <div class="widget-header d-flex align-items-center">
                        <div class="user-image">
                            <img class="rounded-circle" src="<%=Foto %>">
                        </div>
                        <div class="d-flex flex-column mr-auto">
                            <div class="title">
                                <span class="username"><%=Nome %></span>
                            </div>
                        </div>
                    </div>
                    <div class="widget-body <%if (descricao="" OR isnull(descricao)) AND size = atual then response.write(" alert-primary ") end if %>">
                        <p><%=ints("msg") %></p>
                    </div>
                </div>
                <div class="time-right"><%=ints("data")&" "&formatdatetime(ints("hora"), 4) %></div>
            </div>
        </div>
        <%
    atual = atual + 1
    ints.movenext
    wend
    ints.close
    set ints=nothing
end if
%>
<% if descricao <> "" then %>

    <div class="timeline-item">
        <div class="timeline-event">
            <div class="widget has-shadow">
                <div class="alert alert-primary" role="alert">
                <%=descricao%>
                </div>
            </div>
        </div>
    </div>



<% end if%>
</div>