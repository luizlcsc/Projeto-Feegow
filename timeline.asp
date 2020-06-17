<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" and request.ServerVariables("REMOTE_ADDR")<>"127.0.0.1" then
	on error resume next
end if

OcultarBtn=req("OcultarBtn")

if req("X")<>"" then
    if req("Tipo")="|Prescricao|" then
        'db_execute("delete from pacientesprescricoes where id="& req("X"))
        db_execute("update pacientesprescricoes set sysActive=-1 where id="& req("X"))
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
        db_execute("update pacientesdiag set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|AE|" then
        db_execute("update buiformspreenchidos set sysActive=-1 where id="& req("X"))
    end if
    if req("Tipo")="|L|" then
        db_execute("update buiformspreenchidos set sysActive=-1 where id="& req("X"))
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

.compartilhamentoSelect{
    background-color: #4198D5;
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

select case Tipo
    case ""

    case "|AE|", "|L|"
        if Tipo="|AE|" then
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
            </div>
            <div class="panel-body" style="overflow: inherit!important;">
                <div class="col-md-3">
                    <%
                        sqlBuiforms = "select Nome,id from buiforms where sysActive=1 and "& sqlForm &" order by Nome"
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
                            <button type="button" class="mt10 btn btn-primary btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                <i class="fa fa-plus"></i> <%=rotuloBotao %>
                                <span class="caret ml5"></span>
                            </button>
                            <ul class="dropdown-menu" role="menu">
                                <%

			                while not forms.eof
				                if autForm(forms("id"), "IN", "") then
                                %>
                                <li  <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%>><a  <% if EmAtendimento=1 then%>
                                href="#" onclick="iPront('<%=replace(Tipo, "|", "") %>', '<%=PacienteID%>', '<%=forms("id")%>', 'N', '');" <% end if %>><i class="fa fa-plus"></i> <%=forms("Nome")%></a></li>
                                <%
				                end if
			                forms.movenext
			                wend
			                forms.close
			                set forms = nothing
			                if aut("buiformsI") and session("Banco")<>"clinic522" then
                                %>
                                <li class="divider"></li>
                                <li><a href="./?P=buiforms&Pers=Follow"><i class="fa fa-cog"></i> Gerenciar modelos de <%=lcase(subTitulo) %></a></li>
                                <%
			                end if
                                %>
                            </ul>
                        </div>
                    <% else %>
                        <button type="button" class="btn btn-primary btn-block" <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%> <% if EmAtendimento=1 then%> onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, <%= idFormUnico %>, 'N', '');"<% end if %>><i class="fa fa-plus"></i> <%= nomeFormUnico %></button>
                    <% end if %>
                </div>
                <%
                    if tipo="|L|" then
		                formTipo = " and ( bf.Tipo IN (3,4,0) OR ISNULL(bf.Tipo) )"
	                else
		                formTipo = " and bf.Tipo IN(1,2)"
	                end if

                set exe = db.execute("select * from buiformspreenchidos bfp join buiforms bf on bf.id=bfp.ModeloID where bfp.sysActive <> 1 "&formTipo &" and bfp.PacienteID="&pacienteID)
                restoreVisible = "none"
                if not exe.eof then
                    restoreVisible = "block"
                end if

                %>
                    <div class="col-md-3 col-xs-12">
                        <a type="button" class="btn btn-block mb10 mt10 btn-system pull-right" id="restoreForm" style="display: <%=restoreVisible%>;"><i class="fa fa-external-link"></i> Restaurar Formulário</a>
                    </div>
                <%
                if not isnull(Nascimento) and not isnull(Sexo) and isdate(Nascimento) and isnumeric(Sexo) then
                    if datediff("yyyy", Nascimento, date())<15 and Sexo<>0 then
                    %>
                    <a class="btn btn-info mt10" href="javascript:curva(<%= PacienteID %>)"><i class="fa fa-bar-chart"></i> Curvas de Evolução</a>
                    <%
                    end if
                end if

                if Tipo = "|L|" then
                    De = DateAdd("d", -7, date())
                %>
                <div class="col-md-3">
                    <a type="button" class="btn btn-system" href="./?P=Laudos&PacienteID=<%=PacienteID%>&De=<%=De%>&Pers=1" target="_blank"><i class="fa fa-external-link"></i> Ir para Laudos</a>
                </div>
                 <%
                end if
                %>
            </div>
        </div>
        <%
    case "|Diagnostico|"
        subTitulo = "Diagnósticos"
        %>
        <div class="panel timeline-add">
            <div class="panel-heading">
                <span class="panel-title"> <%=subTitulo %>
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-3">
                    <button type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else %>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, 'N', '');" <%end if%>>
                        <i class="fa fa-plus"></i> Inserir Diagnóstico
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
            </div>
            <%
            if aut("prescricoesI") then
            %>
            <div class="panel-body" style="overflow: inherit!important;">
                <div class="col-md-5">
                <%
                set memed = db.execute("select * from memed_tokens where sysUser ="&session("User"))

                if not memed.eof then
                if memed("sysActive") = 1 then
                %>
                <div class="col-md-8">
                                <button id="AbrirMemed" disabled type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else%>" onclick="openMemed()"<%end if%>>
                                    <i class="fa fa-plus"></i> Inserir Prescrição
                                </button>
                </div>
                                <div class="col-md-4">
                                <button style="float: right" class="btn btn-danger" type="button" onclick="updateMemedStatus('0')">Desativar memed</button>
                                </div>
                <%
                else
                %>
                <div class="col-md-8">
                <button  type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                    <i class="fa fa-plus"></i> Inserir Prescrição
                </button>
                </div>
                <div class="col-md-4">
                <button style="float: right" class="btn btn-success" type="button" onclick="updateMemedStatus('1')">Ativar memed</button>
                </div>
                <%end if%>

<script >

    function updateMemedStatus(status) {
        postUrl("prescription/memed/update-memed-status", {
            sys_active: status,
            professionalId: "<%=session("idInTable")%>"
        }, function () {
            location.reload();
        })
    }

    function toogleDisabledBtn($selector){
        $selector.prop("disabled", !$selector.prop("disabled"));
    }

    $(document).ready(function() {
        var $btnAbrirMemed = $("#AbrirMemed");

        setTimeout(function() {
          toogleDisabledBtn($btnAbrirMemed);
        }, 500);

        $btnAbrirMemed.click(function() {
            toogleDisabledBtn($btnAbrirMemed);

            setTimeout(function() {
              toogleDisabledBtn($btnAbrirMemed);
            }, 500);
        });
    });

 

</script>
<%
else
%>

                <div class="col-md-8">
                <button  type="button" class="btn btn-primary btn-block<% if EmAtendimento=0 then %> disabled" data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%else%>" onclick="iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"<%end if%>>
                    <i class="fa fa-plus"></i> Inserir Prescrição
                </button>
                </div>
                <% end if %>
                </div>

                <%
                if memed.eof and session("Table")="profissionais" then
                %>

                <div class="col-md-9 mt10">
                    <div class="alert alert-default">
                        <strong >Novidade!</strong>  Agora está disponível a prescrição Memed. <a target="_blank" href="?P=profissionais&I=<%=session("idInTable")%>&Pers=1">Vá no seu perfil</a> e clique na aba <i>Integração Memed</i>.
                    </div>
                </div>

                <%
                end if
                %>
            </div>
            <%
            end if
            %>
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
                        <i class="fa fa-plus"></i> Inserir Texto / Atestado
                    </button-->

                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <i class="fa fa-plus"></i> Inserir
                        <span class="caret ml5"></span>
                    </button>
                    <ul class="dropdown-menu disabled" role="menu">
                        <li><a href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="fa fa-plus"></i> Texto / Atestado</a></li>
                        <li><a class="disabled hidden"><i class="fa fa-plus"></i> ASO</a></li>
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
                                <i class="fa fa-exclamation-circle bigger-110"></i>
                                Pendentes
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Aplicadas">
                                <i class="fa fa-check bigger-110"></i>
                                Finalizadas
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Canceladas">
                                <i class="fa fa-user-times bigger-110"></i>
                                Canceladas
                            </a>
                        </li>
                        <li class="pull-right">
<%
                            if aut("vacinapacienteI")=1 then
%>

                                <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <i class="fa fa-plus"></i> Inserir
                                    <span class="caret ml5"></span>
                                </button>
                                <ul class="dropdown-menu" role="menu">
<%
                                    set tiposVacina = db.execute("SELECT id, NomeTipoVacina AS descricao FROM cliniccentral.vacina_tipo ORDER BY 2")

                                    while not tiposVacina.EOF
%>
                                        <li <% if EmAtendimento=0 then %>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<%end if%>><a <% if EmAtendimento=1 then %>href="javascript:modalVacinaPaciente('VacinaPaciente.asp', <%=PacienteID%>, '<%= tiposVacina("id")%>', '', '');"<%end if%>><i class="fa fa-plus"></i> <%= tiposVacina("descricao")%></a></li>
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
    $("#modal").html("Carregando...");

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
            </div>
            <%
            if aut("pedidosexamesI")=1 then
            IntegracaoUnimedLondrina = recursoAdicional(12)

            %>
            <div class="panel-body">
                <div class="col-md-12">
                    <div class="btn-group col-md-3">
                        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                            <i class="fa fa-plus"></i> Inserir Pedido de Exame
                            <span class="caret ml5"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <%if IntegracaoUnimedLondrina<>4 then%>
                            <li><a href="javascript:iPront('<%=replace(Tipo, "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="fa fa-plus"></i> Pedido Padrão</a></li>
                            <%
                            end if
                            set AtendeConvenioSQL = db.execute("SELECT COUNT(id)n FROM convenios WHERE sysActive=1 HAVING n>=1")
                            if not AtendeConvenioSQL.eof then
                                %>
                                <li ><a href="javascript:iPront('<%=replace("PedidosSADT", "|", "") %>', <%=PacienteID%>, 0, '', '');"><i class="fa fa-plus"></i> Pedido em Guia de SP/SADT</a></li>
                                <%
                            end if
                            %>
                        </ul>
                    </div>
                    <%
                    if IntegracaoUnimedLondrina=4 or session("Banco")="clinic100000" then
                    %>
                        <div class="col-md-offset-7 col-md-2">
                            <button type="button" class="btn btn-system" onclick="importarDadosUnimed()">
                                <i class="fa fa-download"></i> Importar Exames - Unimed
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
    case "|ProdutosUtilizados|"
        %><!--#include file="ProdutosUtilizados.asp"--><%
    case "|AssinaturaDigital|"
        %><!--#include file="AssinaturaDigital.asp"--><%
    case "|Imagens|"
        if ComEstilo <> "S" then
        %>

<div class="panel">
    <div class="panel-heading">
        <span class="panel-title"><i class="fa fa-camera"></i> Imagens do Paciente</span>
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
                newSaveImage(dataImage);
                closeComponentsModal();
            },
            "lg",
            'auto'
        );
    };

    function newSaveImage(base64){
        $.post("https://clinic7.feegow.com.br/imagesave.php?IP=<%=sServidor%>&PacienteID=<%=req("PacienteID")%>&B=<%=session("Banco")%>", 
            {
                data: base64
            }, 
            function(data){
                console.log(data);
                atualizaAlbum(0);
        });
    };

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
                <span class="panel-title"><i class="fa fa-file"></i> Arquivos do Paciente</span>
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
    if instr("|ProdutosUtilizados|AssinaturaDigital|ResultadosExames|AsoPaciente|VacinaPaciente|Arquivos|Imagens|", Tipo) = 0 then
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
    <div class="col-xs-12">
        <div id="timeline" class="timeline-single mt30 ">
            <!--#include file="timelineload.asp"-->
        </div>
        <div class="load-wrapp col-xs-6 col-xs-offset-6 ">
            <div class="load-3">
                <div class="line"></div>
                <div class="line"></div>
                <div class="line"></div>
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

    $('[data-toggle="tooltip"]').tooltip();
    function iPront(t, p, m, i, a) {
        $("#modal-form .panel").html("<center><i class='fa fa-2x fa-circle-o-notch fa-spin'></i></center>");
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
        $.get("iPront.asp?t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
            $("#modal-form .panel").html(data);
        })
    }

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
            openModal(data, "Lita de formulário não salvos", true, false);
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
        let ProfissionalID = '<%=req("ProfessionalID")%>';
        var Carregando = false
        $(".load-wrapp").hide();

        scroll(0,0);

        $(window).scroll(function() {
            let tamanhoMaximo = $(document).height() - $(window).height();
            let scrollPosition = $(window).scrollTop();
            let isEnd = ( (scrollPosition + 50 ) >= tamanhoMaximo);

            if(isEnd && !Carregando){
                $(".timeline-item").slice(loadMore,steps).fadeIn(3000);
                newloadMore = loadMore+steps;
                if(!final){
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
                            $("#timeline").append("</div></div><div class='timeline-divider'><div class='divider-label'>Não há mais registros</div></div>");
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