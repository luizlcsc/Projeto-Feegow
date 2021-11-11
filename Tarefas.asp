<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="Classes/Connection.asp"-->
<%

if req("Helpdesk") <> "" then
    set dblicense = newConnection("clinic5459", "")
end if

on error resume next

if req("I")="N" and req("Helpdesk")="1" then
    sqlVie = "select id, sysUser, sysActive from tarefas where sysUser="&session("User")&" and sysActive=0"
    set vie = dblicense.execute(sqlVie)
    if vie.eof then
        dblicense.execute("insert into tarefas (sysUser, sysActive) values ("&session("User")&", 0)")
        set vie = dblicense.execute(sqlVie)
    end if

    response.Redirect("?P=tarefas&I="&vie("id")&"&Pers=1&Helpdesk=1")
end if
%>
<script src="assets/js/estrela.js" type="text/javascript"></script>

<script>
    function saveTarefa() {
        let Solicitantes = "";
        let frm = $("#frm").serialize();
        let titulo = $("#Titulo").val();
        let para = $("#Para").val();

        if (titulo === "" || para === null) {
            new PNotify({
                title: 'ERRO!',
                text: 'Preencha o "Título" e ao menos uma opção no "Para".',
                type: 'danger',
                delay:3000
            });
        } else {
            $("input[name^=Solicitante]").each(function () {
                Solicitantes += "," + $(this).val();
            });


            $.post("save.asp?I=<%=req("I")%><% if req("Helpdesk") <> "" then response.write("&Helpdesk=1") end if%>", frm+"&Solicitantes="+Solicitantes, function(data){
                eval(data);
            });

            if ($("#msgInteracao").val('') !== "") {
                $("#msgInteracao").val('');
                $("#btnInteracao").html("<center><i class='far fa-circle-o-notch fa-spin'></i></center>");

                $.post("TarefasInteracoes.asp?I=<%=req("I")%><% if req("Helpdesk") <> "" then response.write("&Helpdesk=1") end if%>", frm, function(data){
                    $("#interacoes").html(data);
                    $("#btnInteracao").html("<i class='far fa-send'></i> Enviar");
                })
            }

            return false;
        }

    }
</script>
<style>
.scroller, .scroller * {
    -webkit-user-select: auto !important;
    -moz-user-select: auto !important;
    -ms-user-select: auto !important;
    user-select: auto !important;
}

.scroller-navbar {
    max-height: 500px !important;
}

.panel .mn {
    width: 98.5%;
    margin: 0 auto !important;
}
.table-layout > aside {
    display: initial !important;
}
</style>
<form id="frm">
<%


permissoesSession = db.execute("SELECT Permissoes FROM sys_users WHERE id = "&session("User"))
if instr(permissoesSession("Permissoes"), "[15]") > 0 then
    PermissaoSucesso = 1
else
    PermissaoSucesso = 0
end if

tabela = "tarefas"

if req("Helpdesk") <> "" then

    esconderHelpdesk = " style='display:none;' "
    set reg = dblicense.execute("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara, tt.Descricao AS TipoDescricao, tp.Prioridade AS PrioridadeDescricao from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara LEFT JOIN tarefastipos tt ON tt.id = t.Tipo LEFT JOIN cliniccentral.tarefasprioridade tp ON tp.id = t.Urgencia where t.id="&req("I"))
    'response.write("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara, tt.Descricao AS TipoDescricao from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara LEFT JOIN tarefastipos tt ON tt.id = t.Tipo where t.id="&req("I"))
else
    esconderHelpdesk = ""
    call insertRedir(tabela, req("I"))
    set reg = db.execute("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara where t.id="&req("I"))
end if

'set reg = db.execute("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara where t.id="&req("I"))
'response.write("select t.*, tsDe.Classe ClasseDe, tsPara.Classe ClassePara from "&tabela&" t  LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara where t.id="&req("I"))

if reg("De")=0 then
    De = session("User")
    DtAbertura = date()
    HrAbertura = time()
else
    De = reg("De")
    Para = reg("Para")
    DtAbertura = reg("DtAbertura")
    HrAbertura = ft(reg("HrAbertura"))
end if

if De=session("User") then
    Subtitulo = "recebida"
else
    Subtitulo = "enviada"
end if

if req("Helpdesk") <> "" then
    set cc = dblicense.execute("select CentroCustoID from "&session("Table")&" where id="& session("idInTable"))
else
    set cc = db.execute("select CentroCustoID from "&session("Table")&" where id="& session("idInTable"))
end if

if not cc.eof then
    CentroCustoID = cc("CentroCustoID")
end if

PermitirV = aut("tarefasgerenciarV")
PermitirA = aut("tarefasgerenciarA")
PermitirI = aut("tarefasgerenciarI")



if req("Helpdesk") <> "" then
    set dadosHelpdesk = dblicense.execute("SELECT * FROM tarefas WHERE sysUser = "&session("User")&" AND sysActive = 0 order by id desc LIMIT 1")
    if dadosHelpdesk.EOF then
        dblicense.execute("INSERT INTO tarefas (sysUser, sysActive) VALUES ("&session("User")&", 0)")
        set dadosHelpdesk = dblicense.execute("SELECT * FROM tarefas WHERE sysUser = "&session("User")&" AND sysActive = 0 order by id desc LIMIT 1")
    end if

    idHelpdesk = dadosHelpdesk("id")
end if

%>
<input type="hidden" name="P" value="tarefas" />
<input type="hidden" name="I" value="<%= req("I") %>" />
<input type="hidden" name="De" value="<%= De %>" />
<input type="hidden" name="DtAbertura" value="<%= DtAbertura %>" />
<input type="hidden" name="HrAbertura" value="<%= HrAbertura %>" />

<script>
function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R=tarefas&I=<%= req("I")%>', function(data){$('#modal').html(data);})}

$(".crumb-active a").html("Controle de Tarefas");
$(".crumb-icon a span").attr("class", "far fa-tasks");
$(".crumb-link").removeClass("hidden").html("<%=subtitulo%>");
<%
    btnIncluir = ""
    if PermitirI = 1 then
        if req("Helpdesk") <> "" then
            btnIncluir = " <a title='Novo' href='?P=tarefas&Pers=1&I="&idHelpdesk&"&Helpdesk=1' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
        else
            btnIncluir = " <a title='Novo' href='?P=tarefas&Pers=1&I=N' class='btn btn-sm btn-default'><i class='far fa-plus'></i></a> "
        end if
    end if
%>
<% if req("Helpdesk") <> "" then %>
    $("#rbtns").html("<a title=\"Lista\" href=\"?P=listatarefas&Pers=1&Helpdesk=1\" class=\"btn btn-sm btn-default\"><i class=\"far fa-list\"></i></a> <%=btnIncluir%>");
<% else %>
    $("#rbtns").html("<a title=\"Lista\" href=\"?P=listatarefas&Pers=1\" class=\"btn btn-sm btn-default\"><i class=\"far fa-list\"></i></a> <a title=\"Histórico de Alterações\" href=\"javascript:log()\" class=\"btn btn-sm btn-default hidden-xs\"><i class=\"far fa-history\"></i></a><%=btnIncluir%>");
<% end if %>
</script>

<div class="row" style="margin-top: 10px;">
    <div class="col-md-4">
        <div class="panel">

            <div class="panel-heading">
            <%
                if reg("sysActive")=0 then
                    disabled=""'por enquanto nao usa
                    DtPrazo = date()
                    HrPrazo = "18:00"
                    Solicitantes = req("Solicitantes")
                    TempoEstimado = 1
                    TipoEstimado="60"
                else
                    DtPrazo = reg("DtPrazo")
                    HrPrazo = ft(reg("HrPrazo"))
                    Solicitantes = reg("Solicitantes")
                    if reg("TempoEstimado") then
                        TempoEstimado = replace(reg("TempoEstimado"), ",", ".")
                    else
                        TempoEstimado = 0
                    end if
                    TipoEstimado = reg("TipoEstimado")
                end if

                SET vTarefapai = db.execute(" SELECT TarefaPaiID from Tarefas where id="&req("I")&" AND TarefaPaiID>0 ")
                    if not vTarefapai.eof then
                        relacionadaTarefaPaiHTML = ", vinculada a tarefa <strong><a href='?P=tarefas&I="&vTarefapai("TarefaPaiID")&"&Pers=1'>#"&vTarefapai("TarefaPaiID")&"</a></strong>"
                    end if
                vTarefapai.close
                set vTarefapai = nothing
                %>
                    <span class="panel-title"> Tarefa  <strong>#<%= req("I") %></strong><%=relacionadaTarefaPaiHTML%></span>
                <%
                %>
                    <span class="panel-controls">
                        <%if De=session("User") or reg("sysUser")=session("User") or PermitirA=1 then %>

                                <button class="btn btn-sm btn-primary" id="save" type="button" onclick="saveTarefa()" <% if req("Helpdesk") <> "" AND reg("sysActive") = 1 then response.write("style='display:none'") end if %>>
                                    <i class="far fa-save"></i> <strong>SALVAR</strong>
                                </button>
                        <%end if %>
                    </span>
            </div>
            <div class="panel-body">
                <div class="row">
                    <% if req("Helpdesk") <> "" then %>
                        <% if not isnull(reg("Tipo")) then %>
                            <%= quickfield("text", "Tipo", "", 6, reg("Tipo"), "", "", " style='display:none' ") %>
                            <div class="col-md-6">
                                <label>Tipo</label>
                                <p><%=reg("TipoDescricao")%></p>
                            </div>
                        <% end if %>
                    <% end if %>
                    <%=quickfield("simpleSelect", "Tipo", "Tipo", 6, cstr(reg("Tipo")&""), "select '0' id, 'Sem Tipo' Descricao UNION ALL  select id, Descricao from tarefastipos order by id", "Descricao", " semVazio") %>
                    <%
                        projetoAux = reg("ProjetoID")
                        projetoAuxQuery = ""
                        if not isnull(projetoAux) then
                            projetoAuxQuery = " OR id IN ("&reg("ProjetoID")&") "
                        end if

                        if PermissaoSucesso = 1 AND reg("Urgencia") <> 6 then
                            whereAux = " WHERE id NOT IN (6) "
                        end if

                        if PermissaoSucesso = 1 AND instr(Para, "|-1|") = 0 then
                            CentroCustoSQLAux = " AND cc.id NOT IN (1) "
                        end if
                     %>

                     <% if req("Helpdesk") <> "" then %>
                         <% if not isnull(reg("Urgencia")) then %>
                             <%= quickfield("text", "Urgencia", "", 6, reg("Urgencia"), "", "", " style='display:none' ") %>
                             <div class="col-md-6">
                                 <label>Prioridade</label>
                                 <p><%=reg("PrioridadeDescricao")%></p>
                             </div>
                         <% end if %>
                    <% else %>
                        <%=quickfield("simpleSelect", "Urgencia", "Prioridade", 6, cstr(reg("Urgencia")&""), "select id, Prioridade from cliniccentral.tarefasprioridade "& whereAux &" order by id", "Prioridade", " semVazio no-select2 ") %>
                     <% end if %>


                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<%=Para%>" id="Para" name="Para">
                        <%'=Para%>

                    <% else %>
                        <%=quickField("multiple", "Para", "Para", 6, Para, "select su.id, t.Nome from (	select id, NomeProfissional Nome, 'profissionais' Tipo from profissionais where ativo='on'	UNION ALL	select id, NomeFuncionario, 'funcionarios' from funcionarios where ativo='on') t INNER JOIN sys_users su ON (su.idInTable=t.id AND lcase(su.`Table`)=t.Tipo)  UNION ALL select cc.id*(-1), concat('&raquo; ', cc.NomeCentroCusto) from centrocusto cc where cc.sysActive=1 "& CentroCustoSQLAux &" order by Nome", "Nome", " required")%>
                    <% end if %>

                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<%=reg("ProjetoID")%>" id="ProjetoID" name="ProjetoID">
                        <input type="hidden" value="<%=reg("CategoriaID")%>" id="SprintID" name="SprintID">
                        <input type="hidden" value="<%=reg("SprintID")%>" id="SprintID" name="SprintID">
                    <% else %>
                        <%=quickfield("simpleSelect", "ProjetoID", "Projeto", 6, cstr(reg("ProjetoID")&""), "SELECT '0' AS id, '- NÃO SE APLICA -' AS Titulo UNION (SELECT id, Titulo FROM projetos WHERE StatusID NOT IN (3, 4) "&projetoAuxQuery&" ORDER BY Titulo)", "Titulo", " semVazio ") %>
                        &nbsp
                        <%=quickfield("simpleSelect", "CategoriaID", "Categoria", 6, cstr(reg("CategoriaID")&""), "SELECT * FROM tarefa_categoria WHERE PaiID != 0 AND sysActive=1 ", "NomeCategoria", "") %>
                        <%=quickfield("simpleSelect", "SprintID", "Sprint", 6, cstr(reg("SprintID")&""), "SELECT '0' AS id, '- NÃO SE APLICA -' AS Descricao UNION (SELECT id, Descricao FROM sprints WHERE StatusID NOT IN (3, 4) "&projetoAuxQuery&" ORDER BY Descricao)", "Descricao", " semVazio ") %>
                    <% end if %>

                    <%

                        exibeDadosEstimativa = " disabled "
                        if (reg("sysUser") = session("user")) OR (PermitirA = 1) then
                            exibeDadosEstimativa = " "
                        end if
                    %>

                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<%=DtPrazo%>" id="DtPrazo" name="DtPrazo" autocomplete="off" class="form-control input-mask-date" data-date-format="dd/mm/yyyy">
                    <% else %>
                        <%=quickField("datepicker", "DtPrazo", "Data Prazo", 6, DtPrazo, "", "", " "& disabled &" ")%>
                    <% end if %>

                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<%=HrPrazo%>" id="HrPrazo" name="HrPrazo">
                    <% else %>
                        <%=quickField("timepicker", "HrPrazo", "Hora Prazo", 6, HrPrazo, "", "", " "& disabled &" ")%>
                    <% end if %>

                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<% if not isnull(reg("TempoEstimado")) then response.write(replace(reg("TempoEstimado"), ",", ".")) else response.write(0) end if%>" id="TempoEstimado" name="TempoEstimado">
                    <% else %>
                        <%=quickField("number", "TempoEstimado", "Tempo Estimado", 6, TempoEstimado, "", "", " min='0' step='0.01' "&exibeDadosEstimativa)%>
                    <% end if %>

                    <% if req("Helpdesk") <> "" then %>
                        <input type="hidden" value="<%=reg("TipoEstimado")%>" id="TipoEstimado" name="TipoEstimado">
                    <% else %>
                        <%=quickfield("simpleSelect", "TipoEstimado", "Tipo Estimado", 6, TipoEstimado, "select '1' id, 'Minutos' Tipo UNION SELECT '60', 'Horas' UNION SELECT '1440', 'Dias'", "Tipo", " semVazio no-select2 "&exibeDadosEstimativa)%>
                        <% if (reg("sysUser") <> session("user")) AND (session("admin") <> 1) then %>
                            <input type="hidden" value="<% if not isnull(reg("TempoEstimado")) then response.write(replace(reg("TempoEstimado"), ",", ".")) else response.write(0) end if%>" id="TempoEstimado" name="TempoEstimado">
                            <input type="hidden" value="<%=reg("TipoEstimado")%>" id="TipoEstimado" name="TipoEstimado">
                        <% end if %>
                    <% end if %>
                </div>



<%
qTarefasDependenciasSQL = "SELECT * from tarefas_dependencias where TarefaID="&req("I")

set qTarefasDependencias = db.execute(qTarefasDependenciasSQL)
if  qTarefasDependencias.eof then

 
else
    while not qTarefasDependencias.eof

    tarEsp_id = qTarefasDependencias("id")
    tarEsp_prazo = qTarefasDependencias("prazo")
    tarEsp_finalizada = qTarefasDependencias("finalizada")&""


    tarEsp_responsaveis = qTarefasDependencias("responsaveis")&""
    tarEsp_responsaveis = replace(tarEsp_responsaveis,"|","")
    usuariosArray=Split(tarEsp_responsaveis,",")
    for each usuarioId in usuariosArray
        
        vUsuarioNomeSQL = "select Nome from cliniccentral.licencasusuarios where id = "&usuarioId
        'response.write("<pre>"&vUsuarioNomeSQL&"</pre>")
        set vUsuarioNome = db.execute(vUsuarioNomeSQL)
        if vUsuarioNome.eof then
            responsavelNome = "<i class='far fa-user' style='font-size:20px' data-original-title='Indefinido' data-toggle='tooltip' data-placement='top'></i> "
        else
            responsavelNome = "<i class='far fa-user' style='font-size:20px' data-original-title='"&vUsuarioNome("Nome")&"' data-toggle='tooltip' data-placement='top'></i> "
        end if

        vUsuarioNome.close
        set vUsuarioNome = nothing

        if responsavelNomeHTML = "" then
            responsavelNomeHTML = responsavelNome
        else

            responsavelNomeHTML = responsavelNomeHTML&responsavelNome

        end if
        
        'response.write(x & "<br />")
    next
    
    if qTarefasDependencias("dependencia")&"" = "" then
        tarEsp_especialidade = "Indefinido"
    else
        tarEsp_especialidade = qTarefasDependencias("dependencia")
    end if
    if tarEsp_finalizada="" then
        icoFinalizado = "<i class='far fa-times' style='color:#ff500069'></i>"
    else
        icoFinalizado = "<i class='far fa-check' style='color:#379c0087'></i>"
    end if

    dependenciasLista = "<tr>"_
    &"  <td width='20'>"&icoFinalizado&"</td>"_
    &"  <td><input type='checkbox' name='dep' class='input_depRemove' value='"&tarEsp_id&"'> <a href='#' class='dependencia' id='"&tarEsp_id&"' onclick='openComponentsModal(`tarefasDependencias.asp?depId=${this.id}`, true, `Editar dependência`, true, depAcaoEdit);'><i class='far fa-edit'></i> "&tarEsp_especialidade&"</a></td>"_
    &"  <td width='150'>"&responsavelNomeHTML&"</td>"_
    &"  <td width='70'>"&tarEsp_prazo&"</td>"_
    &"</tr>"

    if dependenciasListaHTML="" then
        dependenciasListaHTML = dependenciasLista
    else
        dependenciasListaHTML = dependenciasListaHTML&dependenciasLista
    end if

    responsavelNomeHTML = ""
    qTarefasDependencias.movenext
    wend
    qTarefasDependencias.close
    set qTarefasDependencias = nothing
end if


%>

                <div class="row" style="margin-top: 30px;">
                    <%if session("banco")="clinic5459" then%>
                    <div class="col-md-12">
                        <div class="panel">
                            <div class="panel-heading">
                                <span class="panel-title">Dependências</span>
                                <span class="panel-controls">
                                    <button class="btn btn-sm btn-success" type="button" onclick="openComponentsModal('tarefasDependencias.asp', true, 'Adicionar dependência', true, depAcaoNew)">
                                        <i class="far fa-plus"></i>
                                    </button>
                            
                                </span>
                            </div>
                            <div class="panel-body">
                                <table class="table" id="">
                                    <thead>
                                        <tr>
                                            <th></th>
                                            <th>Dependência</th>
                                            <th>Atribuída</th>
                                            <th>Prazo</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%=dependenciasListaHTML%>
                                        <tr>
                                            <td></td>
                                            <td colspan="3">
                                                <button type="button" class="depRemove btn btn-xs btn-danger"><i class='far fa-times'></i> Remover itens</button>
                                            </td>
                                        </tr>
                                    </tbody>
                                 </table>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-12">
                        <div class="panel">
                            <div class="panel-heading">
                                <span class="panel-title">Tarefas relacionadas</span>
                            </div>
                            <div class="panel-body">
                                <%
                                set vtarefasFilho = db.execute("select id,titulo from tarefas Where TarefaPaiID="&req("I")&" order by titulo ASC")
                                if vtarefasFilho.eof then
                                    tarefasFilhosHTML = "<tr>"_
                                    &"  <td colspan='3'><i>Nenuma tarefa foi vinculada neste chamado</i></td>"_
                                    &"</tr>"
                                    
                                else
                                while not vtarefasFilho.eof

                                    tarefaFilho_id      = vtarefasFilho("id")
                                    tarefaFilho_titulo  = vtarefasFilho("titulo")

                                    tarefasFilhos = "<tr>"_
                                    &"    <td><input type='checkbox' name='record' class='tarefasFilhoRemove' value='"&tarefaFilho_id&"'></td>"_
                                    &"    <td><a class='btn btn-xs btn-primary' href='./?P=tarefas&Pers=1&I="&tarefaFilho_id&"' target='_blank'><i class='far fa-edit'> </i> #"&tarefaFilho_id&"</a></td>"_
                                    &"    <td>"&tarefaFilho_titulo&"</td>"_
                                    &"</tr>"

                                    if tarefasFilhosHTML="" then
                                        tarefasFilhosHTML = tarefasFilhos
                                    else
                                        tarefasFilhosHTML = tarefasFilhosHTML&tarefasFilhos
                                    end if

                                vtarefasFilho.movenext
                                wend
                                vtarefasFilho.close
                                set vtarefasFilho = nothing
                                end if


                                %>   
                                <div class="col-md-11">
                                    <%=selectInsert("Associar a este chamado", "tarefaFilhoBusca", "", "tarefas", "Titulo", "", "", "")%>
                                </div>
                                <div class="col-md-1 text-right">
                                    <br>
                                    <button type="button" class="btn btn-sm btn-success" id="tarefaFilhoAdd"><i class="far fa-plus"></i></button>
                                </div>

                                <div class="col-md-12" style="max-height:300px; overflow:auto;">
                                <table class="table" id="tarefasFilho">
                                    <thead>
                                        <tr>
                                            <th width="20"></th>
                                            <th width="80">Protocolo</th>
                                            <th>Título</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%=tarefasFilhosHTML%>
                                    </tbody>
                                </table>
                                <button type="button" class="tarefaFilhoRemove btn btn-xs btn-danger"><i class='far fa-times'></i> Remover itens</button>
                                </div>
                            </div>
                        </div>
                        
                        
                    </div>
                    <%end if%>

                </div>

                <hr>
                <div class="panel" style="margin-top: 30px;" <% if req("Helpdesk") <> "" then response.write("hidden") end if%>>
                    <div class="panel-heading">
                        <span class="panel-title">Solicitantes</span>
                        <span class="panel-controls">
                            <button type="button" class="btn btn-xs btn-success mn" onclick="tsol('I');"><i class="far fa-plus"></i></button>
                        </span>
                    </div>
                    <div class="panel-body">
                        <div class="row">
                          <div class="col-md-12" id="TarefasSolicitantes">
                          <%
                          if req("I")<>"N" then
                          %>
                              <% server.execute("TarefasSolicitantes.asp") %>
                          <%
                          end if
                          %>
                          </div>
                        </div>
                    </div>
                </div>


                <%if reg("sysActive")=1 then %>
                <br>
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title"><i class="far fa-star-o blue"></i> Status desta Tarefa</span>
                    </div>

                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-12" id="tarefasExecucao">
                                <% server.Execute("tarefasExecucao.asp") %>
                            </div>
                        </div>
                        <div class="row">
                            <%
                            UserID1=session("User")
                            UserID2=0

                            set UserAlternativoMultiLicencaSQL = db.execute("SELECT lu2.id FROM cliniccentral.licencasusuarios lu "&_
                                                                            "INNER JOIN cliniccentral.licencasusuarios lu2 ON lu2.Email = lu.Email AND lu2.LicencaID!=lu.Email "&_
                                                                            "WHERE lu.id="&UserID1&" AND lu2.LicencaID="&replace(session("Banco"),"clinic",""))
                            if not UserAlternativoMultiLicencaSQL.eof then
                                UserID2=UserAlternativoMultiLicencaSQL("id")
                            end if

                            if reg("De")=UserID1 or reg("De")=UserID2 then
                                %>
                                <%=quickfield("simpleSelect", "staDe", "Segundo você", 4, reg("staDe"), "select id, De from cliniccentral.tarefasstatus where not isnull(De)", "De", "") %>
                                <%
                            else
                                %>
                                <div class="col-md-4">
                                    <label>Segundo o remetente</label><br />
                                    <div class="label label-xlg btn-block arrowed-in arrewed-in-right label-<%=reg("classeDe") %>"><%=reg("staDe") %></div>
                                    <input type="hidden" name="staDe" value="<%=reg("staDe") %>" />
                                </div>
                                <%
                            end if
                            if instr(Para, "|"& UserID1 &"|")>0 or instr(Para, "|"& UserID2 &"|")>0 or instr(Para, "|-"& CentroCustoID &"|")>0 then
                                descPara = "Segundo o recebedor"
                                %>
                                <%=quickfield("simpleSelect", "staPara", descPara, 4, reg("staPara"), "select id, Para from cliniccentral.tarefasstatus where not isnull(Para)", "Para", "") %>
                                <%
                            else
                                descPara = "Segundo você"
                                    %>
                                    <div class="col-md-4">
                                        <label><%=descPara %></label><br />
                                        <div class="label label-xlg btn-block arrowed-in arrowed-in-right label-<%=reg("classePara") %>"> <%=reg("staPara") %></div>
                                        <input type="hidden" name="staPara" value="<%=reg("staPara") %>" />
                                    </div>
                                    <%
                            end if
                            %>
                            <input type="hidden" id="AvaliacaoNota" name="AvaliacaoNota" value="<%=reg("AvaliacaoNota") %>" />
                            <div class="col-md-4">
                                <label>Nota</label><br />
                                <div class="row lead">
                                    <div class="col-md-12 blue">
                                        <span style="cursor:pointer" id="stars-existing" class="starrr" data-rating='<%=reg("AvaliacaoNota") %>'></span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <%else %>
                <input type="hidden" name="staDe" value="Enviada" />
                <input type="hidden" name="staPara" value="Pendente" />
                <%end if %>

            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="panel">
            <div class="panel-body">
                <div class="row">
                    <div style="margin-top: 10px;float: right">
                        <% if not isnull(reg("DtAbertura")) then %>
                                <span class="text-primary">
                                    <strong>Tarefa criada por <%=nameInTable(reg("De")) %> - <%=reg("DtAbertura") &" às "& ft(reg("HrAbertura")) %>&nbsp;&nbsp;</strong>
                                </span>
                        <% end if %>
                    </div>
                    <div class="col-md-12">
                        <% if req("Helpdesk") <> "" then %>
                            <% if not isnull(reg("Titulo")) then %>
                                <%= reg("Titulo") %>
                                <%= quickfield("text", "Titulo", "", 12, reg("Titulo"), "", "", " style='display:none' ") %>
                            <% else %>
                                <%= quickfield("text", "Titulo", "Título", 12, reg("Titulo"), "", "", "") %>
                            <% end if %>
                        <% else %>
                            <%= quickfield("text", "Titulo", "Título", 12, reg("Titulo"), "", "", " "& disabled &" required") %>
                        <% end if
                         %>
                    </div>
                </div>
                <hr class="short alt" />
                <div class="row" style="margin: 5px">
                    <div class="col-md-1">
                        <div <% if req("Helpdesk") <> "" then response.write("hidden") end if %>>
                            <label>Público</label>
                            <div class="switch">
                                <input type="checkbox" name="Publico" id="Publico" <% if req("Helpdesk") <> "" then response.write("checked") end if %>>
                                <label for="Publico"></label>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-10"></div>
                    <div class="col-md-1" style="margin-top: 20px; right: 1%;">
                        <button type="button" id="btnInteracao" class="btn btn-sm btn-success" onclick="saveTarefa()"><i class="far fa-send"></i> Enviar</button>
                    </div>
                </div>
                <div class="row" style="margin: 10px;" >
                    <textarea hidden id="ta" name="ta"><%=reg("ta")%></textarea>
                    <%=quickField("editor", "msgInteracao", "", 12, "", "200", "", " "&disabled&" ")%>
                </div>
                <hr class="short alt" />
                <div id="interacoes" class="tab-pane chat-widget active" role="tabpanel">
                    <%server.Execute("TarefasInteracoes.asp") %>
                </div>
                <hr class="short alt" />
                <div class="row">
                <div class="col-md-12">
                    <h3>Imagens/Arquivos/Evidências</h3>
                </div>
                    <div class="col-md-12">
                       <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?tarefaId=<%=req("I")%>&Tipo=I&Pasta=feegow-screenshot"></iframe>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>


<script type="text/javascript">

function depAcaoNew(data){
    var $formDependencias = $("#form-components").serialize();
    $.ajax({
        method: "POST",
        url: "TarefasSave.asp?acao=a&ref=dep&I=<%=req("I")%>",
        data: $formDependencias,
            success:function(data){
			eval(data);
        }
    });     
}

var tarDepEditItem = null;
var tarDepEdit = $('.dependencia').click(function(valor){
    tarDepEditItem = this.id;
    //alert(tarDepEditItem);
});

function depAcaoEdit(data){
    //console.log(tarDepEditItem);
    var $formDependencias = $("#form-components").serialize();

    $.ajax({
        method: "POST",
        url: "TarefasSave.asp?acao=e&ref=dep&I=<%=req("I")%>&v="+tarDepEditItem,
        data: $formDependencias,
            success:function(data){
			eval(data);
        }
    });     
}



//  TAREFAS VINCULADAS INICIO
/*
    function tarefaFilhoRemove(valor) {
        if (confirm("Deseja desvincular esta tarefa?")) {
            document.getElementById(valor).value = valor;
            var tb = 'tb'+valor;
            data : $.post( "TarefasSave.asp?acao=r&ref=<%'=req("I")%>&v="+valor);
            $('tr').remove('#'+tb);
            
        }
    }
*/
$(document).ready(function(){


    // Find and remove selected table rows
    $(".depRemove").click(function(){
        var depRemoveSel = $("input:checkbox[name=input_depRemove]:checked")
        .toArray()
        .map(function(reg){
            
            return $(reg).val();
        });
        data : $.post("TarefasSave.asp?acao=r&ref=<%=req("I")%>&v="+depRemoveSel);

        $("table tbody").find('input[name="input_depRemove"]').each(function(){
            if($(this).is(":checked")){
                $(this).parents("tr").remove();
            }
        });

    });


    $("#tarefaFilhoAdd").click(function(){
        var protocolo = $("#tarefaFilhoBusca").val();
        //var titulo    = $("#tarefaFilhoBusca").select2('data');
        var titulo    = $("#tarefaFilhoBusca").select2('data')[0]['full_name'];

        var markup = "<tr><td><input type='checkbox' name='record' class='tarefasFilhoRemove' value='"+protocolo+"'></td><td><a  class='btn btn-xs btn-primary' href='./?P=tarefas&Pers=1&I='><i class='far fa-edit'> </i> #" + protocolo + "</a></td><td> "+ titulo +" </td></tr>";
        $("table tbody").append(markup);
        //console.log(protocolo);
        data : $.post( "TarefasSave.asp?acao=a&ref=<%=req("I")%>&v="+protocolo);
    });
    
    // Find and remove selected table rows
    $(".tarefaFilhoRemove").click(function(){
        var tarefaFilhoRemoveSel = $("input:checkbox[name=record]:checked")
        .toArray()
        .map(function(reg){
            
            return $(reg).val();
        });
        data : $.post("TarefasSave.asp?acao=r&ref=<%=req("I")%>&v="+tarefaFilhoRemoveSel);

        //console.log(val(tarefaFilhoRemoveSel));
        $("table tbody").find('input[name="record"]').each(function(){
            if($(this).is(":checked")){
                $(this).parents("tr").remove();
            }
        });

    });
});  
//  TAREFAS VINCULADAS FIM

$(document).ready(function() {

        <%if session("User")=reg("De") then %>
    $('#stars-existing').on('starrr:change', function(e, value){
        $('#AvaliacaoNota').val(value);
    });
        <%end if%>
});

function tsol(A) {
    var Solicitantes = "";
    $("input[name^=Solicitante]").each(function () {
        Solicitantes += "," + $(this).val();
    });
    $.post("TarefasSolicitantes.asp?I=<%=req("I")%>&A="+ A, { Solicitantes: Solicitantes }, function (data) {
        $("#TarefasSolicitantes").html(data);
    });
}


$("#staDe, #staPara").change(function(){
    $.get("tarefaSave.asp?I=<%=req("I")%>&onlySta="+$(this).attr("id")+"&Val="+$(this).val(), function(data){
        eval(data);

        let frm = $("#frm").serialize();
        $.post("TarefasInteracoes.asp?I=<%=req("I")%>", frm, function(data){
            $("#interacoes").html(data);
        })
    });
});

function executarTarefa(A){
    $.post("tarefasexecucao.asp?I=<%=req("I")%>", {A: A, Texto: $('#TextoExecucao').val()}, function (data) {
        $("#tarefasExecucao").html(data);
    });
}
</script>
<!--    </div>-->
<!--</div>-->
</form>