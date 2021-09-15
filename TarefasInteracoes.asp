<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<!--#include file="Classes/Arquivo.asp"-->
<link rel="stylesheet" href="assets/css/timeline.css" />

<div class="timeline timeline-line-solid">
    <span class="timeline-label">
        <span class="label">Interações</span>
    </span>

<%

if req("Helpdesk")<>"" then
    set dblicense = newConnection("clinic5459", "")
end if
if ref("msgInteracao")<>"" then
    Publico = 1
    if ref("Publico") <> "on" then
        Publico = 0
    end if

    sqlInsert = "insert into tarefasmsgs (TarefaID, data, hora, desession, para, msg, Publico) values ("&req("I")&", curdate(), curtime(), "&session("User")&", NULL, '"&ref("msgInteracao")&"', "&Publico&")"

    if req("Helpdesk")<>"" then
        dblicense.execute(sqlInsert)
    else
        db_execute(sqlInsert)
    end if
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

if req("Helpdesk") <> "" then
    set descricao = dblicense.execute("select t.ta AS descricao, t.sysActive from tarefas t where t.id="&req("I"))
else
    set descricao = db.execute("select t.ta AS descricao, t.sysActive from tarefas t where t.id="&req("I"))
end if

if not descricao.eof then
    sysActive = descricao("sysActive")
    descricao = descricao("descricao")
else
    descricao = ""
end if

if req("Helpdesk") <> "" then
    set ints = dblicense.execute("SELECT * FROM (SELECT m.*, lu.Nome,  lu.Nome Nome2, u.Table, coalesce(p.Foto,f.Foto) FotoUsuario, p.Foto Fotop, f.Foto Fotof, TRUE AS Interacao FROM tarefasmsgs m LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = m.desession LEFT JOIN sys_users u ON u.id=m.desession LEFT JOIN profissionais p ON p.id=u.idInTable LEFT JOIN funcionarios f ON f.id=u.idInTable WHERE m.TarefaID="&req("I")&" AND m.Publico=1 UNION SELECT  l.id, l.TarefaID, NULL AS RequisicaoID, DATE(l.DataHora) AS DATA, TIME(l.DataHora) AS hora, NULL AS desession, NULL AS para, CONCAT(p.NomeProfissional, ' alterou o status de ', IF(l.DePara = 'De', 'origem ', 'destino '), '<span class=''text-', sa.Classe, '''>', l.StatusAnterior, '</span>', ' <i class=''far fa-arrow-circle-right''></i> ', '<span class=''text-', sd.Classe, '''>', l.StatusAtual, '</span>') AS msg, 0 AS Publico, NULL AS DHUp, p.NomeProfissional, f.NomeFuncionario, u.Table, coalesce(p.Foto,f.Foto) FotoUsuario,p.Foto AS Fotop, f.Foto AS Fotof, FALSE AS Interacao FROM tarefastatus_log l LEFT JOIN sys_users u ON u.id=l.UsuarioID LEFT JOIN profissionais p ON p.id=u.idInTable LEFT JOIN funcionarios f ON f.id=u.idInTable LEFT JOIN cliniccentral.tarefasstatus sa ON sa.id = l.StatusAnterior LEFT JOIN cliniccentral.tarefasstatus sd ON sd.id = l.StatusAtual WHERE l.TarefaID="&req("I")&") t ORDER BY DATA DESC, hora DESC")
    'response.write("SELECT * FROM (SELECT m.*, lu.Nome NomeProfissional, lu.Nome NomeFuncionario, u.Table, p.Foto Fotop, f.Foto Fotof, TRUE AS Interacao FROM tarefasmsgs m LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id = m.desession LEFT JOIN sys_users u ON u.id=m.desession LEFT JOIN profissionais p ON p.id=u.idInTable LEFT JOIN funcionarios f ON f.id=u.idInTable WHERE m.TarefaID="&req("I")&" UNION SELECT  l.id, l.TarefaID, NULL AS RequisicaoID, DATE(l.DataHora) AS DATA, TIME(l.DataHora) AS hora, NULL AS desession, NULL AS para, CONCAT(p.NomeProfissional, ' alterou o status de ', IF(l.DePara = 'De', 'origem ', 'destino '), '<span class=''text-', sa.Classe, '''>', l.StatusAnterior, '</span>', ' <i class=''far fa-arrow-circle-right''></i> ', '<span class=''text-', sd.Classe, '''>', l.StatusAtual, '</span>') AS msg, 0 AS Publico, NULL AS DHUp, p.NomeProfissional, f.NomeFuncionario, u.Table, coalesce(p.Foto,f.Foto) FotoUsuario, p.Foto AS Fotop, f.Foto AS Fotof, FALSE AS Interacao FROM tarefastatus_log l LEFT JOIN sys_users u ON u.id=l.UsuarioID LEFT JOIN profissionais p ON p.id=u.idInTable LEFT JOIN funcionarios f ON f.id=u.idInTable LEFT JOIN cliniccentral.tarefasstatus sa ON sa.id = l.StatusAnterior LEFT JOIN cliniccentral.tarefasstatus sd ON sd.id = l.StatusAtual WHERE l.TarefaID="&req("I")&") t ORDER BY DATA DESC, hora DESC")
else
    set ints = db.execute("SELECT * FROM (SELECT m.*, COALESCE(p.NomeProfissional, f.NomeFuncionario, lu.Nome)Nome, u.Table, coalesce(p.Foto,f.Foto) FotoUsuario, p.Foto Fotop, f.Foto Fotof, TRUE AS Interacao " &_
                          "FROM tarefasmsgs m " &_
                          "LEFT JOIN sys_users u ON u.id=m.desession " &_
                          "LEFT JOIN profissionais p ON p.id=u.idInTable AND u.`Table`='profissionais' "&_
                          "LEFT JOIN funcionarios f ON f.id=u.idInTable AND u.`Table`='funcionarios' "&_
                          "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=m.desession "&_
                          "WHERE m.TarefaID="&req("I")&" "&_
                          "UNION "&_
                          "SELECT  l.id, l.TarefaID, NULL AS RequisicaoID, DATE(l.DataHora) AS DATA, TIME(l.DataHora) AS hora, "&_
                          "NULL AS desession, NULL AS para, CONCAT(p.NomeProfissional, ' alterou o status de ', IF(l.DePara = 'De', 'origem ', 'destino '), "&_
                          "'<span class=''text-', sa.Classe, '''>', l.StatusAnterior, '</span>', ' <i class=''far fa-arrow-circle-right''></i> ', "&_
                          "'<span class=''text-', sd.Classe, '''>', l.StatusAtual, '</span>') AS msg, 0 AS Publico, NULL AS DHUp, "&_
                          "COALESCE(p.NomeProfissional, f.NomeFuncionario, lu.Nome)Nome, u.Table,coalesce(p.Foto,f.Foto) FotoUsuario, p.Foto AS Fotop, f.Foto AS Fotof, FALSE AS Interacao "&_
                          "FROM tarefastatus_log l "&_
                          "LEFT JOIN sys_users u ON u.id=l.UsuarioID "&_
                          "LEFT JOIN profissionais p ON p.id=u.idInTable AND u.`Table`='profissionais' "&_
                          "LEFT JOIN funcionarios f ON f.id=u.idInTable AND u.`Table`='funcionarios' "&_
                          "LEFT JOIN cliniccentral.tarefasstatus sa ON sa.id = l.StatusAnterior "&_
                          "LEFT JOIN cliniccentral.tarefasstatus sd ON sd.id = l.StatusAtual "&_
                          "LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=l.UsuarioID "&_
                          "WHERE l.TarefaID="&req("I")&") t ORDER BY DATA DESC, hora DESC")
end if

'response.write("select m.*, p.NomeProfissional, f.NomeFuncionario, u.Table, coalesce(p.Foto,f.Foto) FotoUsuario, p.Foto Fotop, f.Foto Fotof from tarefasmsgs m LEFT JOIN sys_users u on u.id=m.desession LEFT JOIN profissionais p on p.id=u.idInTable LEFT JOIN funcionarios f on f.id=u.idInTable where m.TarefaID="&req("I")&" order by m.data DESC, m.hora DESC")

if (ints.eof AND descricao = "") then
    response.write("<span class='timeline-label'><span class='label'>Nenhuma interação neste chamado.</span></span>")
else
    if req("Helpdesk") <> "" then
        size = dblicense.execute("SELECT COUNT(*) AS qtd FROM tarefasmsgs m WHERE m.TarefaID="&req("I"))
    else
        size = db.execute("SELECT COUNT(*) AS qtd FROM tarefasmsgs m WHERE m.TarefaID="&req("I"))
    end if
    size = CInt(size("qtd"))
    atual = 1

    while not ints.eof
        Foto = ints("FotoUsuario")
        Nome = ints("Nome")

        if isnull(Foto) or Foto="" then
            Foto = "./assets/img/user.png"
        else
            if req("Helpdesk")<>"" then
                L = 5459
            else
                L = replace(session("Banco"), "clinic", "")
            end if

            Foto = getFileUrlWithCustomDB(Foto, "Perfil", L)
        end if
        Publico = ints("Publico")
        MsgPublico = "Público"
        if Publico = "0" then
            MsgPublico = "Privado"
        end if

        %>
        <% if ints("Interacao") = "1" then %>
        <div class="timeline-item">
            <div class="timeline-event">
                <div class="widget has-shadow">
                    <div class="widget-header d-flex align-items-center">
                        <div class="time-right" style="top:10%;"><%=ints("data")&" "&formatdatetime(ints("hora"), 4)%>&nbsp;&nbsp;&nbsp;</div>
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
                    <div class="widget-body">
                        <div class="row">
                        <%
                          set imgs = db.execute("SELECT * FROM arquivos WHERE TarefaId="&req("I"))

                            while not imgs.eof
                            %>
                                <div class="col-md-4">
                                   <div class="thumbnail">
                                      <a href="<%=arqEx(imgs("NomeArquivo"),"FEEGOW-SCREENSHOT")%>" target="new"><img src="<%=arqEx(imgs("NomeArquivo"),"FEEGOW-SCREENSHOT")%>"></a>
                                  </div>
                              </div>

                            <%
                                imgs.movenext
                            wend

                        %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <% else %>

        <span class="timeline-label" style="margin-bottom:40px">
            <span class="label" style="background-color:#FAFAFA;color:#666">
                <span class="" style="position:relative;top:10%;font-weight: initial;">
                    <span class="user-image">
                        <img class="rounded-circle" style="width: 25px;height: 25px" src="<%=Foto %>">
                    </span>
                    <%=ints("msg") %>
                    <div class="time-right" style="left:80%;bottom:150%"><%=ints("data")&" "&formatdatetime(ints("hora"), 4)%>&nbsp;&nbsp;&nbsp;</div>
                </span>
            </span>
        </span>

        <% end if %>
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