<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
	on error resume next
end if

OcultarBtn=req("OcultarBtn")
FormularioNaTimeline=getConfig("FormularioNaTimeline")


if req("X")<>"" then
    if req("Tipo")="|Prescricao|" then
        'db_execute("delete from pacientesprescricoes where id="& req("X"))
        db_execute("update pacientesprescricoes set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|PedidosSADT|" then
        db_execute("update pedidossadt set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Atestado|" then
        'db_execute("delete from pacientesatestados where id="& req("X"))
        db_execute("update pacientesatestados set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Pedido|" then
        'db_execute("delete from pacientespedidos where id="& req("X"))
        db_execute("update pacientespedidos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Diagnostico|" then
        'db_execute("delete from pacientespedidos where id="& req("X"))
        db_execute("update pacientesdiagnosticos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Protocolos|" then
        'db_execute("update pacientesdiag set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|AE|" then
        db_execute("update buiformspreenchidos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|L|" then
        db_execute("update buiformspreenchidos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Protocolos|" then
        db_execute("update pacientesprotocolos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|Tarefas|" then
        db_execute("delete from tarefasmsgs where id="& req("X"))
    end if
end if


%>
<style type="text/css">
.timeline-item{
    margin-left:25px;
}
#timeline.timeline-single .timeline-icon {
    left: -19px !important;
}
.timeline-item-inativo *{
    color: #fff!important;
}
.timeline-item-inativo code{
    color: #c7254e!important;
}
.inativo-marca{
    width: 100%;
    height: 80%;
    background-color: rgba(173,173,173,0.57);
    position:absolute;
    z-index: 999;
    margin-bottom: 30px;
    font-size: 55px;
    font-weight: 700;
    text-align: center;
}
.timeline-item-inativo .panel-body{
    background-color:#c5c5c5 ;
}
.timeline-item-inativo .panel-heading{
    background-color:#9a9a9a
}
#folha{
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 760px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #fff;
		position:relative;
}
.campos{
		position:absolute;
		margin: 0;
		border: 2px dotted #fff;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
}
.lembrar{
	position:absolute;
	right:0;
	display:none;
}
.campos:hover .lembrar{
	display:block;
}
.campo:hover .lembrar{
	display:block;
}
.gridster .gs-w {
    cursor:default!important;
}
@media print{
    .panel-controls{
        display: none;
    }
    #timeline.timeline-single .timeline-icon{
        background-color: #EEEEEE;
        border-radius: 50%;
        height: 35px;
        width: 35px;
        z-index: 99;
    }
}
.btn-primary.disabled{
    pointer-events:auto;
}

.dropdown-item-selected{
    background-color: #4198D5;
    color: #FFFFFF !important;
    border-radius: 6px;
}



.dropdown-item-selected i{
    color: #FFFFFF !important;
}

.tooltip-inner {
  text-align: left;
}

/* ======= loading ========= */
.load-wrapp {
    width: 200px;
    height: 100px;
}

.load-wrapp p {padding: 0 0 20px;}
.load-wrapp:last-child {margin-right: 0;}

.line {
    display: inline-block;
    width: 15px;
    height: 15px;
    border-radius: 15px;
    background-color: #4b9cdb;
}

.load-3 .line:nth-last-child(1) {animation: loadingC .6s .1s linear infinite;}
.load-3 .line:nth-last-child(2) {animation: loadingC .6s .2s linear infinite;}
.load-3 .line:nth-last-child(3) {animation: loadingC .6s .3s linear infinite;}

@keyframes loadingC {
    0 {transform: translate(0,0);}
    50% {transform: translate(0,15px);}
    100% {transform: translate(0,0);}
}

#btn-config-prescricao .error-badge {
    display: none;
    position: absolute; 
    width: 7px; 
    height: 7px; 
    border-radius: 50%; 
    background-color: #EE5253; 
    top:13px; 
    right:10px
}

#btn-config-prescricao .fa-spin {
    display: none;
}
#btn-config-prescricao.loading .fa-spin {
    display: inline-block;
}
#btn-config-prescricao.loading .fa-cog {
    display: none;
}
#btn-config-prescricao.error .error-badge {
    display: block;
}
</style>


<div class="row">
    <div class="col-xs-12">
        <%
'on error resume next


PacienteID = req("PacienteID")
loadMore = 0
MaximoLimit = 20
Tipo = req("Tipo")
ComEstilo = req("ComEstilo")

set PacienteSQL = db.execute("SELECT NomePaciente, Nascimento, Sexo FROM pacientes WHERE id = "&PacienteID)
NomePaciente = PacienteSQL("NomePaciente")
Nascimento = PacienteSQL("Nascimento")
Sexo = PacienteSQL("Sexo")
%>
<h2 class="visible-print"><%=NomePaciente%></h2>
<%

EmAtendimento = 0
if session("Atendimentos")<>"" then
    EmAtendimento = 1
end if

set ConfigIniciarAtendimentoSQL = db.execute("SELECT ObrigarIniciarAtendimento FROM sys_config WHERE id=1")
if not ConfigIniciarAtendimentoSQL.eof then
    if ConfigIniciarAtendimentoSQL("ObrigarIniciarAtendimento")<>1 then
        EmAtendimento=1
    end if
end if
InserirDinamico = ""

if FormularioNaTimeline then
    InserirDinamico = "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|"
end if

select case Tipo
    case ""

    case "|AE|", "|L|", InserirDinamico
        if Tipo="|AE|" OR Tipo=InserirDinamico then
            subTitulo = "Anamneses e Evoluções"
            rotuloBotao = "Inserir Anamnese / Evolução"
            sqlForm = " Tipo IN(1,2) "
        else
            subTitulo = "Laudos e Formulários"
            rotuloBotao = "Inserir Laudo / Formulário"
            sqlForm = " ( Tipo IN (3,4,0) OR ISNULL(Tipo) ) "
        end if

        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title "> <%=subTitulo %>
                </span>

                <div class="panel-controls">
                    <%
                    set exe = db.execute("select * from buiformspreenchidos bfp join buiforms bf on bf.id=bfp.ModeloID where bfp.sysActive <> 1 "&formTipo &" and bfp.PacienteID="&pacienteID)
                    restoreVisible = "none"
                    if not exe.eof then
                        restoreVisible = "inline"
                    end if

                    %>
                    <button type="button" class="btn btn-default hidden-xs" id="restoreForm" style="display: <%=restoreVisible%>;"><i class="far fa-history"></i> Restaurar Formulário</button>
                    <%
                    if not isnull(Nascimento) and not isnull(Sexo) and isdate(Nascimento) and isnumeric(Sexo) and (Sexo=1 or Sexo=2) then
                    %>
                        <button class="btn btn-info hidden-xs" type="button" onclick="curva(<%= PacienteID %>)"><i class="far fa-bar-chart"></i> Curvas de Evolução</button>
                    <%
                    end if

                    if Tipo = "|L|" then
                        De = DateAdd("d", -7, date())
                    %>
                        <button type="button" class="btn btn-system" onclick="javascript:location.href='./?P=Laudos&PacienteID=<%=PacienteID%>&De=<%=De%>&Pers=1'" ><i class="far fa-external-link"></i> Ir para Laudos</button>
                     <%
                    end if
                    %>
                </div>

            </div>
            <div class="panel-body" style="overflow: inherit!important;">

                <div class="col-md-3">
                        <%
                         if False then
                             set UltimosFormsSQL = db.execute("SELECT GROUP_CONCAT(DISTINCT ModeloID) modelos FROM ( "&_
                             "SELECT bp.ModeloID, COUNT(bp.id) qtd from buiformspreenchidos bp join buiforms b on b.id=ModeloID WHERE bp.DataHora >= DATE_SUB(NOW(), INTERVAL 30 DAY) and bp.sysUser="&session("User")&" and   "&sqlForm&"  "&_
                             "GROUP BY bp.ModeloID "&_
                             "ORDER BY qtd desc "&_
                             "LIMIT 5 "&_
                             ")t ")

                            if not UltimosFormsSQL.eof then
                                favoritos = UltimosFormsSQL("modelos")
                                if favoritos<> "" then
                                    sqlOrderFavoritos = " IF(id in ("&favoritos&"),0,1),"
                                end if
                            end if
                        end if


                        sqlBuiforms = "select Nome,id from buiforms where sysActive=1 and "& sqlForm &" order by "&sqlOrderFavoritos&" Nome"
                        nForms = 0
			            set forms = db.execute(sqlBuiforms)
			            while not forms.eof
				            if autForm(forms("id"), "IN", "") then
                                nForms = nForms+1
                                idFormUnico = forms("id")
                                nomeFormUnico = forms("Nome")
                            end if
			            forms.movenext
			            wend
			            forms.close
			            set forms = nothing

			            set forms = db.execute(sqlBuiforms)

                        if nForms<>1 then %>
                        <div class="btn-group btn-block">
                            <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                <i class="far fa-plus"></i> <%=rotuloBotao %>
                                <span class="caret ml5"></span>
                            </button>
                            <ul class="dropdown-menu" role="menu">
                                <%

			                while not forms.eof
				                if autForm(forms("id"), "IN", "") then

				                    badgeFavorito = ""

				                    if instr(favoritos, forms("id")) then
				                        badgeFavorito = " <i class='fas fa-star text-warning'></i>"
                                    end if

                                %>
                                <li  <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%>><a  <% if EmAtendimento=1 then%>
                                href="#" onclick="iPront('<%=replace(Tipo, "|", "") %>', '<%=PacienteID%>', '<%=forms("id")%>', 'N', '');" <% end if %>><i class="far fa-plus"></i> <%=forms("Nome")%> <%=badgeFavorito%></a> </li>
                                <%
				                end if
			                forms.movenext
			                wend
			                forms.close
			                set forms = nothing
			                if aut("buiformsI") and session("Banco")<>"clinic522" then
                                %>
                                <li class="divider"></li>
                                <li><a href="./?P=buiforms&Pers=Follow"><i class="far fa-cog"></i> Gerenciar modelos de <%=lcase(subTitulo) %></a></li>
                                <%
			                end if
                                %>
                            </ul>
                        </div>
                        
                    <% else %>
                        <button type="button" class="btn btn-primary btn-block" <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%> <% if EmAtendimento=1 then%> onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, <%= idFormUnico %>, 'N', '');"<% end if %>><i class="far fa-plus"></i> <%= nomeFormUnico %></button>
                    <% end if %>
                </div>
                <%
                    if tipo="|L|" then
		                formTipo = " and ( bf.Tipo IN (3,4,0) OR ISNULL(bf.Tipo) )"
	                else
		                formTipo = " and bf.Tipo IN(1,2)"
	                end if
                %>
            </div>
        </div>
        <%
    case "|Diagnostico|"
        subTitulo = "Diagnósticos"
        %>
        <script>
            window.addEventListener("message", function(e) {
                  if(e.data === "closeModal") {
                      $("#modal-calculator").modal("hide");
                  }

                  if(e.data === "reloadPage") {
                      window.location.reload();
                  }
            });
</script>
        <!-- Modal tnm -->
        <div class="modal fade" id="modal-calculator" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div class="modal-dialog" style="  width: 100%;
                                             height: 100%;
                                             padding: 0;">
            <div class="modal-content" style="  height: 100%;
                                                border-radius: 0;">
              <div class="modal-body" id="modal-calculator-content" style="height: 100%;
                                                                                                                           border-radius: 0;">
              </div>
            </div>
          </div>
        </div>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-4">
                    <button type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else %>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, 'N', '');" <%end if%>>
                        <i class="far fa-plus"></i> Inserir Diagnóstico
                    </button>
                </div>
            </div>
        </div>
        <%
    case "|Prescricao|"
        subTitulo = "Prescrições"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %> </span>
                <% if aut("prescricoesI") and getConfig("MemedHabilitada")=1 then %>
                    <span class="panel-controls">
                        <button id="btn-config-prescricao" class="btn btn-default" onclick="openConfigMemed()">
                            <i class="far fa-cog"></i>
                            <i class="far fa-circle-notch fa-spin"></i>
                            <span class="error-badge">&nbsp;</span>
                        </button>
                    </span>
                    <script>
                    if (memedError) {
                        $('#btn-config-prescricao').addClass('error');
                    }
                    if (memedLoading) {
                        $('#btn-config-prescricao').addClass('loading');
                    }
                </script>
                <% end if %>
            </div>
            <%

            prescricaoDefault = "memed"
            memedHabilitada = getConfig("MemedHabilitada")=1

            if aut("prescricoesI") then
                prescricaoMemed = getConfig("MemedHabilitada")=1

                set DefaultPrescriptionModeSQL = db.execute("SELECT coalesce(COUNT(id),0) qtd  FROM pacientesprescricoes WHERE sysUser="&session("User")&" AND DATA BETWEEN date_sub(curdate(),INTERVAL 10 day)  and CURDATE() and MemedID is null;")

                if not DefaultPrescriptionModeSQL.eof then
                    qtdPrescricaoClassica = ccur(DefaultPrescriptionModeSQL("qtd"))
                    if isnumeric(qtdPrescricaoClassica) then
                        if qtdPrescricaoClassica > 15 then
                            prescricaoDefault="feegow"
                            %>
<script >
setMemedError("Prescrição clássica ativa.")
</script>
                            <%
                        end if
                    end if
                end if
            %>
                <div class="panel-body" style="overflow: inherit!important;">
                    <div class="row">
                        <div class="col-md-3">
                            <% if memedHabilitada and prescricaoDefault="feegow" then %>
                                <div class="btn-group col-md-12">
                                <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <i class="far fa-plus"></i> Inserir Prescrição
                                    <span class="caret ml5"></span>
                                </button>
                                <ul class="dropdown-menu" role="menu">
                                    <li><a href="#" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="far fa-plus"></i> Prescrição Clássica</a></li>
                                    <li><a href="javascript:openMemed('prescricao');"><i class="far fa-plus"></i> Prescrição Memed <span class="label label-system label-xs fleft">Novo</span></a></li>
                                </ul>
                            </div>

                            <% else
                                if prescricaoDefault="memed" then
                            %>
                                <button  type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right" <%else%>" onclick="openMemed('prescricao');"<%end if%>>
                                    <i class="far fa-plus"></i> Inserir Prescrição
                                </button>
                            <% else %>
                                <button  type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right" <%else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                                    <i class="far fa-plus"></i> Inserir Prescrição
                                </button>
                            <% end if %>
                            <% end if %>
                        </div>
                    </div>
                </div>
            <% end if %>
        </div>
        <%
    case "|Atestado|"
        subTitulo = "Textos e Atestados"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <%
            if aut("atestadosI")=1 then
            %>
            <div class="panel-body" style="overflow: inherit!important;">
                <div class="col-md-4">
                    <!--button type="button" class="btn btn-primary dropdown-toggle<% if EmAtendimento=0 then %> disabled" data-toggle="dropdown" title="Inicie um atendimento." aria-expanded="false" data-placement="right" <% else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                        <i class="far fa-plus"></i> Inserir Texto / Atestado
                    </button-->

                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <i class="far fa-plus"></i> Inserir
                        <span class="caret ml5"></span>
                    </button>
                    <ul class="dropdown-menu disabled" role="menu">
                        <li><a href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="far fa-plus"></i> Texto / Atestado</a></li>
                        <li><a class="disabled hidden"><i class="far fa-plus"></i> ASO</a></li>
                    </ul>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%
    case "|Tarefas|"
        subTitulo = "Tarefas"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <%
            if aut("atestadosI")=1 then
            %>
            <div class="panel-body" style="overflow: inherit!important;">
                <div class="col-md-4">
                    <ul class="dropdown-menu disabled" role="menu">
                        <li><a href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="far fa-plus"></i> Tarefas</a></li>
                        
                    </ul>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%

    case "|AsoPaciente|"
%>

<div class="panel timeline-add">
    <div class="panel-heading">
        <span class="panel-title">Medicina Ocupacional</span>
    </div>
    <div class="panel-body" style="padding: 15px">
        <div class="row">
            <div id="divAso">
            </div>
        </div>
    </div>
</div>

<script>
    $(document).ready(function(){

        $.post("AsoPaciente.asp",{PacienteID:<%=pacienteID%>},function(data){
            $("#divAso").html(data);
        });
    });
</script>
<%
    case "|VacinaPaciente|"

        subTitulo = "Vacinas"
%>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"><%=subTitulo %></span>
            </div>
             <div class="panel-body" style="overflow: inherit!important;">
             <div class="row">
        <div class="bs-component">
            <div class="panel">
                <div class="panel-heading">
                    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab">
                        <li class="active">
                            <a data-toggle="tab" href="#Pendentes">
                                <i class="far fa-exclamation-circle bigger-110"></i>
                                Pendentes
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Aplicadas">
                                <i class="far fa-check bigger-110"></i>
                                Finalizadas
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Canceladas">
                                <i class="far fa-user-times bigger-110"></i>
                                Canceladas
                            </a>
                        </li>
                        <li class="pull-right">
<%
                            if aut("vacinapacienteI")=1 then
%>

                                <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <i class="far fa-plus"></i> Inserir
                                    <span class="caret ml5"></span>
                                </button>
                                <ul class="dropdown-menu" role="menu">
<%
                                    set tiposVacina = db.execute("SELECT id, NomeTipoVacina AS descricao FROM cliniccentral.vacina_tipo ORDER BY 2")

                                    while not tiposVacina.EOF
%>
                                        <li <% if EmAtendimento=0 then %>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%end if%>><a <% if EmAtendimento=1 then %>href="javascript:modalVacinaPaciente('VacinaPaciente.asp', <%=PacienteID%>, '<%= tiposVacina("id")%>', '', '');"<%end if%>><i class="far fa-plus"></i> <%= tiposVacina("descricao")%></a></li>
<%
                                        tiposVacina.movenext
                                    wend
                                        tiposVacina.close
                                        set tiposVacina = nothing
%>
                                </ul>
<%
                            end if
                            %>

                        </li>
                    </ul>
                <div>
            </div>
        </div>
        <div class="panel-body" style="overflow: inherit!important;">
            <div class="tab-content pn br-n">
                <div id="Pendentes" class="tab-pane active widget-box transparent">
                </div>
                <div id="Aplicadas" class="tab-pane">
                </div>
                <div id="Canceladas" class="tab-pane">
                </div>
            </div>
        </div>
        </div>
    </div>
<script>

$(document).ready(function(){
    carregaAbaVacina('Pendentes','<%=PacienteID%>');
    carregaAbaVacina('Aplicadas','<%=PacienteID%>');
    carregaAbaVacina('Canceladas','<%=PacienteID%>');
});

function carregaAbaVacina(aba,pacienteID) {

    $.post("VacinaPacienteLista.asp",{aba:aba,Status:aba,PacienteID:pacienteID},function(data){
        $("#"+aba).html(data);
    });
}

function modalVacinaPaciente(pagina, valor1, valor2, valor3, valor4) {

    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)

    $.post(pagina, { valor1: valor1,
                     valor2: valor2,
                     valor3: valor3,
                     valor4: valor4},
                     function (data) {
                        $("#modal").html(data)
                     }
    );

    $("#modal").addClass("modal-lg");
}
</script>
<%
    case "|Pedido|"
        subTitulo = "Pedidos de Exame"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
                <% if aut("pedidosexamesI")=1 and getConfig("MemedHabilitada")=1 then %>
                <span class="panel-controls">
                    <button id="btn-config-prescricao" class="btn btn-default" onclick="openConfigMemed()">
                        <i class="far fa-cog"></i>
                        <i class="far fa-circle-notch fa-spin"></i>
                        <span class="error-badge">&nbsp;</span>
                    </button>
                </span>
                <script>
                    if (memedError) {
                        $('#btn-config-prescricao').addClass('error');
                    }
                    if (memedLoading) {
                        $('#btn-config-prescricao').addClass('loading');
                    }
                </script>
                <% end if %>
            </div>
            <%
            if aut("pedidosexamesI")=1 then
            IntegracaoUnimedLondrina = recursoAdicional(12)

            %>
            <div class="panel-body">
                <div class="row">
                    <div class="btn-group col-md-3">
                        <button type="button" class="btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="far fa-plus"></i> Inserir Pedido de Exame
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <%
                            if IntegracaoUnimedLondrina<>4 then%>
                                    <li><a href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="far fa-plus"></i> Pedido Padrão</a></li>
                                <%

                            end if
                            set AtendeConvenioSQL = db.execute("SELECT COUNT(id)n FROM convenios WHERE sysActive=1 HAVING n>=1")
                            if not AtendeConvenioSQL.eof then
                                %>
                                <li ><a href="javascript:iPront('<%=replace("PedidosSADT", "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="far fa-plus"></i> Pedido em Guia de SP/SADT</a></li>
                                <li ><a <% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right" <%else%>" onclick="openMemed(true)" <%end if%>href="javascript:openMemed(true)"><i class="far fa-plus"></i> Pedido Memed <span class="label label-system label-xs fleft">Novo</span></a></li>
                                <%
                            end if
                            %>
                        </ul>
                    </div>
                    <%
                    if IntegracaoUnimedLondrina=4 or session("Banco")="clinic100000" then
                    %>
                        <div class="col-md-offset-3 col-md-3">
                            <button type="button" class="btn btn-system" onclick="importarDadosUnimed()">
                                <i class="far fa-download"></i> Importar Exames - Unimed
                            </button>
                        </div>
                        <script >

                        function importarDadosUnimed() {
                            openComponentsModal("ImportaLaudosUnimed.asp", {PacienteID: '<%=PacienteID%>'}, "Importar Exames - Unimed Londrina", true, false);
                        }

                        </script>
                        <%
                    end if
                    %>
                </div>
            </div>
            <%
            end if
            %>
        </div>
        <%
    case "|ResultadosExames|"
        %><!--#include file="ResultadosExames.asp"--><%
    case "|Protocolos|"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> Protocolos
                </span>
            </div>
            <%if lcase(session("table"))="profissionais" then%>
            <div class="panel-body">
                <div class="col-md-12">
                    <div class="btn-group col-md-3">
                        <button  type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                            <i class="far fa-plus"></i> Inserir Protocolo
                        </button>
                    </div>
                </div>
            </div>
            <%end if%>
         </div>
         <%
    case "|ProdutosUtilizados|"
        %><!--#include file="ProdutosUtilizados.asp"--><%
    case "|AssinaturaDigital|"
        %><!--#include file="AssinaturaDigital.asp"--><%
    case "|Imagens|"
        if ComEstilo <> "S" then
        %>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-camera"></i> Imagens do Paciente</span>
    </div>
    <div id="divImagens" class="panel-body pn">
        <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Imagens&Tipo=I"></iframe>
    </div>
</div>

<link rel="stylesheet" href="assets/css/colorbox.css" />
<link rel="stylesheet" href="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.css">
<link type="text/css" href="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.css" rel="stylesheet">

<style type="text/css">
.tools {
    background-color: #fff;
    padding: 10px;
    position: absolute;
    z-index: 10;
    width: 100%;
    opacity: 0;
    transition: opacity 300ms;
    transition-timing-function: ease-in-out;
}

.tools-b {
    bottom:0;
}

.mix:hover .tools {
    opacity: 0.93;
}

#avpw_powered_branding{
	display:none!important;
	visibility:hidden!important;
}


#tui-image-editor {
  .tui-image-editor {
    top: 0px !important;
  }
}
</style>

<div id='injection_site'></div>
<form id="frmComparar">
<div id="ImagensPaciente">
<% if getConfig("NovaGaleria") = "1" then
 server.execute("Imagens.asp")
 %>
       <div class="galery-ajax"></div>
       <script>
        fetch("ImagensNew.asp?PacienteID=<%=req("PacienteID")%>")
        .then(data => data.text())
        .then(data => {
           $(".galery-ajax").html(data);
           $("[value='A']").parent().remove();
        });
       </script>
<% ELSE %>
    <%server.execute("Imagens.asp")%>
<% END IF %>
</div>
</form>


<!-- image editor -->
<script type="text/javascript">
    function launchEditor(id, src) {
        openComponentsModal(
            "ImageEditor.asp",
            {
                nomeImagem: id,
                urlImagem: src
            },
            false, 
            true, 
            function(){
                let dataImage = imageEditor.toDataURL();

                newSaveImage(dataImage, id, "arquivos");
                closeComponentsModal();
            },
            "lg",
            'auto'
        );
    };


    function uploadImage(form) {
        data = {
           url: domain + '/api/image/uploadAnyFile?tk='+localStorage.getItem('tk'),
            type: 'POST',
            processData: false,
           contentType: false,
           data: $(form).serialize(),
           mimeType: 'multipart/form-data',
       }

        response = jQuery.ajax(data);
    }


        function newSaveImage(base64,id = 'auto', table='pacientes'){
            if(id === 'auto'){
                id="<%=req("I")%>";
            }
            let objctImg = new FormData();
            objctImg.append('Tipo', 'I');
            objctImg.append('L', '<%=LicenseId%>');
            objctImg.append('userId', '<%=session("User")%>');
            objctImg.append('files[]', content);
            objctImg.append('Pasta', 'Imagens');

            uploadImage(objctImg);
        }

</script>

<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/3.6.0/fabric.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui.code-snippet/v1.5.0/tui-code-snippet.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.3/FileSaver.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.js"></script>
      

        <%
    end if
    case "|Arquivos|"
        if ComEstilo <> "S" then
        %>

        <div class="panel">
            <div class="panel-heading">
                <span class="panel-title"><i class="far fa-file"></i> Arquivos do Paciente</span>
            </div>
            <div class="panel-body pn">
                <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Arquivos&Tipo=A"></iframe>
            </div>
        </div>
        <div id="ArquivosPaciente">
        <% IF getConfig("NovaGaleria") = "1" THEN
         server.execute("Imagens.asp")
         %>
               <div class="galery-ajax"></div>
               <script>
                fetch("ImagensNew.asp?PacienteID=<%=req("PacienteID")%>")
                .then(data => data.text())
                .then(data => {
                   $(".galery-ajax").html(data);
                   $("[value='I']").parent().remove();
                });
               </script>
        <% ELSE %>
            <%server.execute("Arquivos.asp") %>
        <% END IF %>
        </div>
        <%
        end if
end select
    
%>



    </div>

    <div class="col-xs-12" id="divCurvas"></div>
    <script type="text/javascript">
        function curva(){
            $.get("frmCurva.asp?P=<%= PacienteID %>", function(data){ $("#divCurvas").html(data) })
        }
    </script>

    <%
    if req("Tipo")="|L|" then
    %>
    <div class="col-xs-12">
        <div class="row">
            <div class="col-md-4 col-md-offset-4"></div>
        <%
        qProfissionalLaudadorSQL =  " SELECT p.id,p.NomeProfissional FROM profissionais p"&chr(13)&_
                                    " WHERE p.sysActive=1 AND Ativo= 'on'                "&chr(13)&_
                                    " ORDER BY p.NomeProfissional ASC                    "

        if session("Table")="profissionais" then
            valorCheck = session("idInTable")
        end if
        response.write(quickfield("select", "ProfissionalLaudadorID", "Profissional Laudador", 4, valorCheck, qProfissionalLaudadorSQL, "NomeProfissional", ""))
        %>
    <%
    elseif instr("|ProdutosUtilizados|AssinaturaDigital|ResultadosExames|AsoPaciente|VacinaPaciente|Arquivos|Imagens|", Tipo) = 0 and getConfig("FiltrarProfissionaisProntuario")=1 then
    %>
    <div class="col-xs-12">
        <div class="row">
            <div class="col-md-4 col-md-offset-4"></div>
            <div class="col-md-4">
                <%=quickfield("simpleSelect", "Profissionais", "", 4, req("ProfessionalID"), "select '0' as id,'Todos os profissionais' as NomeProfissional, 0 as ordem union select id, NomeProfissional, 1 as ordem from profissionais where ativo='on' and sysActive=1 order by ordem, NomeProfissional", "NomeProfissional", " semVazio onchange='professionalFilter(this.value,"""&Tipo&""","&PacienteID&");'" ) %>
            </div>
        </div>
    </div>  
    <%
    end if
    ProfessionalID = req("ProfessionalID")
    %>
    <div id="divProtocolo">
    </div>

    <div class="col-xs-12">
        <div id="timeline" class="timeline-single mt30 ">
            <!--#include file="timelineload.asp"-->
        </div>
        <%if req("SemLimit") <> "S" then%>
            <div class="load-wrapp col-xs-6 col-xs-offset-6 ">
                <div class="load-3">
                    <div class="line"></div>
                    <div class="line"></div>
                    <div class="line"></div>
                </div>
            </div>
        <%end if%>
    </div>  

    <div id="ModalInativarCampoJustificativa" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <form id="InativarRegistroTimelineForm">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title"><span class="btn-inativar-ativar"></span> registro</h4>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                        <div class="col-md-12">
                            <label for="Justificativa">Justificativa</label>
                            <textarea required name="Justificativa" id="Justificativa" cols="30" rows="10" class="form-control"></textarea>
                        </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
                        <button class="btn btn-primary btn-inativar-ativar">Inativar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

</div>
 

</div>

</div>
<%
If Err.Number <> 0 Then
    db.execute("INSERT INTO cliniccentral.exceptions (Message, File, LicencaID, UsuarioID, Linha, Metadata) VALUES ('"&Err.Description&"', '"&Request.ServerVariables("SCRIPT_NAME")&"', '"&replace(session("Banco"), "clinic","")&"', "&session("User")&", 0, "&PacienteID&")")
End If

%>
<script type="text/javascript">

LocalStorageRestoreHabilitar();
    function handleFormOpenError(t, p, m, i, a, FormID, CampoID){
            showMessageDialog("Ocorreu um erro ao abrir este registro. Tente novamente mais tarde.");

            gtag('event', 'erro_500', {
                'event_category': 'erro_prontuario',
                'event_label': "Erro ao abrir prontuário. Dados: " + JSON.stringify([t, p, m, i, a, FormID, CampoID]),
            });
    }

    $('[data-toggle="tooltip"]').tooltip();

    <%
    IF FormularioNaTimeline THEN
    %>
    function iPront(t, p, m, i, a, FormID, CampoID) {
        if (t == 'AE' || t == 'PrescricaoAELDiagnosticoAtestadoImagensArquivosPedido') {
            $(".timeline-add").slideUp();
            divAff = "#divProtocolo";
            scr = "protocolo";
        } else if (t == 'L') {
            mfpform('#modal-form');
            divAff = "#modal-form .panel";
            scr = "iPront";
        }else{
            //mfp('#modal-form');
            $("#modal-table").modal("show");
            divAff = "#modal";
            scr = "iPront";
        }
        var pl = $("#ProfissionalLaudadorID").val();
        $(divAff).html("<center class='modal-pre-loading'><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
        $.get(scr + ".asp?pl=" + pl + "&t=" + t + "&p=" + p + "&m=" + m + "&i=" + i + "&a=" + a + "&FormID=" + FormID + "&CampoID=" + CampoID, function (data) {
            $(divAff).html(data);
        }).fail(function (data){
            handleFormOpenError(t, p, m, i, a, FormID, CampoID);
        });
    }

    <%
    ELSE
    %>
        function iPront(t, p, m, i, a, FormID, CampoID) {
            $("#modal-form .panel").html("<center class='modal-pre-loading'><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
            if(t=='AE'||t=='L'){
                try{
                    $.magnificPopup.open({
                            removalDelay: 500,
                            closeOnBgClick:false,
                            modal: true,
                            items: {
                                src: '#modal-form'
                            },
                            // overflowY: 'hidden', //
                            callbacks: {
                                beforeOpen: function(e) {
                                    this.st.mainClass = "mfp-zoomIn";
                                }
                            }
                        });
                }catch (e) {
                    alert(e)

                }
            }else{
                mfp('#modal-form');
            }
            var pl = $("#ProfissionalLaudadorID").val();
            $.get("iPront.asp?pl=" + pl + "&t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
                $("#modal-form .panel").html(data);
            }).fail(function (data){
                handleFormOpenError(t, p, m, i, a, FormID, CampoID);
                $("#modal-form").magnificPopup("close");
            });
        }
    <%
    END IF
    %>

var $modalInativar = $("#ModalInativarCampoJustificativa");

var ativo;
var $item;
var RecursoID;
var Recurso;

function toogleInativarRegistroTimeline(el) {
    console.log('aqui', el);
    ativo = $(el).is(":checked");
    $item = $(el).parents(".timeline-item");
    RecursoID = $(el).data("recurso-id");
    Recurso = $(el).data("recurso");
    var $submit = $(".btn-inativar-ativar");

    if(ativo){
        $submit.html("Ativar");
    }else{
        $submit.html("Inativar");
    }

    $modalInativar.modal("show");
}

$("#InativarRegistroTimelineForm").submit(function() {
    var $body = $item.find(".panel-body");

    var Justificativa = $("#Justificativa").val();
    if(ativo){
        $item.removeClass("timeline-item-inativo");
        $item.find(".inativo-marca").remove();
    }else{
        $body.before("<div class='inativo-marca'>INATIVO!</div>");
        $item.addClass("timeline-item-inativo")
    }

    $.post("InativaRegistroTimeline.asp", {Motivo:Justificativa,PacienteID:'<%=PacienteID%>',RecursoID:RecursoID,Recurso:Recurso,Valor:(ativo?1:-1)},function(data) {
        setTimeout(function() {
            eval(data);
        }, 200);
    });
    $modalInativar.modal("hide");
    $("#Justificativa").val("");
    return false;
});


function sendWorklist(ProcedimentoID, FormID){
    $.get("../feegow_components/diagnext/newworklist", {
        p:ProcedimentoID, i:FormID, u:<%=session("UnidadeID")%>, user:<%=session("User")%>
    });
}


function modalInsuranceAttachments(pacienteID, exameID){
    $.post("modalInsuranceAttachments.asp",{
		   PacienteID:pacienteID,
		   ExameID:exameID

		   },function(data){
        $("#modal").html(data);
        $("#modal-table").modal("show");
    });
}

$("#restoreForm").click(function() {
    $.get("restoreForms.asp",
    {
        tipo: '<%=Tipo%>',
        pacienteID:'<%=PacienteID%>'
    }
    , function (data) {
        if(data.length > 0) {
            openModal(data, "Lista de formulário não salvos", true, false);
        }
    });
});

function reloadTimeline(){
    pront('timeline.asp?PacienteID=<%=PacienteID%>&Tipo=<%=Tipo%>');
}

function saveCompartilhamento(tipoCompartilhamento, tipoDocumento, idDocumento, idProfissional )
{
    $.post("SaveCompartilhamento.asp?T=arquivo",{
           CompartilhamentoID: tipoCompartilhamento,
           DocumentoTipo:tipoDocumento,
           DocumentoID:idDocumento,
           ProfissionalID:idProfissional
		   },function(data,status){
             eval(data);
            if (status == "success"){
                showMessageDialog("Salvo com sucesso", "success");
                reload();
            }else{
                showMessageDialog("Erro ao Salvar alterações tente novamente mais tarde", "danger");
            }
    });
}

function compartilhamentoRestrito(tipoDocumento, idDocumento, idProfissional)
{
    $.post("ModalProfissionais.asp",{
           DocumentoTipo:tipoDocumento,
           DocumentoID:idDocumento,
           ProfissionalID:idProfissional
		   },function(data,status){
               openModal(data, "Selecione os profissionais", true, false,"md");
           });
}

function LocalStorageRestoreHabilitar()
{
        var local = localStorage.getItem("logForms");
        var ret = JSON.parse(local);

        var tipo = '<%=replace(Tipo, "|","")%>';
        var pacienteID ='<%=PacienteID%>';

        if(local!=null)
        {
            var element = ret.findIndex(function(elem,index){
                return (elem.pacienteID == pacienteID && elem.tipo == tipo);
            });

            if(element>=0)
            {
                $("#restoreForm").show();
            }
        }
}

function reload()
{
    pront("timeline.asp?PacienteID=<%=PacienteID%>&Tipo=<%=Tipo%>");
}

function excluirSerie(id) {
    $.post("SaveVacinaPaciente.asp",{
        Tipo: "Exclusao",
        Id: id
    }, function(data,status){
        getUrl("vaccine-interaction/remove-queue", {pacienteSerieId: id})
        reload();
    });

}

   function professionalFilter(professionalID,tipo,PacienteId)
    {
        var L= '<%=session("Banco")%>';
        var prof = "";
        if(professionalID!=="0")
        {
            prof = "&ProfessionalID="+professionalID
        }

        pront("timeline.asp?L="+L+"&PacienteID="+PacienteId+"&Tipo="+tipo+prof);
    }

    $(document).ready(function() {
        try{

        var final = false;
        let loadMore = 0;
        let steps = parseInt('<%=MaximoLimit%>');
        let tipoarquivo = '<%=Tipo%>';
        let ProfissionalID = ($("#Profissionais").val()==0?'':$("#Profissionais").val());
        var Carregando = false;
        $(".load-wrapp").hide();

        scroll(0,0);

        $(window).scroll(function() {
            let tamanhoMaximo = $(document).height() - $(window).height();
            let scrollPosition = $(window).scrollTop();
            let isEnd = ( (scrollPosition + 50 ) >= tamanhoMaximo);

            if(isEnd && !Carregando){
                $(".timeline-item").slice(loadMore,steps).fadeIn(3000);
                newloadMore = loadMore+steps;
                if(!final && !Carregando){
                    Carregando = true;
                    $(".load-wrapp").show();
                    $.get("timelineloadmore.asp",{
                        Tipo: tipoarquivo,
                        PacienteID:'<%=PacienteID%>',
                        loadMore : newloadMore,
                        ProfissionalID:ProfissionalID
                    }).done(function(data) {
                        if(data!==""){
                                $("#timeline").append(data);
                                loadMore+=steps;
                        } else
                        {
                            final = true;

                            if($(".no-more-registers").length <= 0){
                                $("#timeline").append("</div></div><div class='timeline-divider'><div class='divider-label no-more-registers'>Não há mais registros</div></div>");
                            }
                        }
                    }).fail(function(data) {
                        console.log(data);
                    }).always(function(){
                        Carregando = false;
                        $(".load-wrapp").hide();

                    });
                }
            }
        });
        }catch (e) {
          console.log("ocorreu um erro:" + e)
        }
    });



<!--#include file="jQueryFunctions.asp"-->
</script>
<script>
function prontPrint(tipo, id){
    let url ="";

    switch (tipo.toLocaleLowerCase()) {
        case "prescricao":
            url = domain+"print/prescription/";
            break;
        case "atestado":
            url = domain+"print/medical-certificate/";
            break;
        case "pedido":
            url = domain+"print/exam-request/";
            break;
        case "diagnostico":
            url = domain+"print/diagnostico/";
            break;
        case "protocolos":
            url = domain+"print/protocol/";
            break;
        //case "AE","L":
            //url = domain+"print/prescription/";
        // break;
    }
    
    let src = `${url+id}?showPapelTimbrado=1&showCarimbo=1&assinaturaDigital=1&tk=${localStorage.getItem("tk")}`;
    openModal(`
        <iframe width="100%" height="800px" src="${src}" frameborder="0"></iframe>`,
        "",
        true,
        false,
        "modal-lg");
}

</script>
