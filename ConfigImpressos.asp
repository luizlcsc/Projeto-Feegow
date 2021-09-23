<!--#include file="connect.asp"-->
<style>
.sortable, .sortable2{
    padding: 10px;
}
.sortable2 li, .sortable li{
  margin: 5px;
  padding: 5px;
  font-size:16px;
}
.sortable-placeholder {
    height: 20px;
    display: block;
}
</style>

<div class="widget-box transparent">
  <div class="widget-header widget-header-flat">
          <h4><i class="far fa-<%=dIcone(lcase(req("P")))%> blue"></i> CONFIGURAÇÃO DE IMPRESSOS</h4>
  </div>
</div>

<%

function CreateCamposRecibo(tipoRecibo)
    sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='"&tipoRecibo&"'"
   set exec = db.execute(sqlvar)
    if exec.eof then
        set camposResult = db.execute("select * from cliniccentral.recibo_campos_modelo")
        while not camposResult.eof
	       db_execute("insert into recibo_campos (campoId,tipo,ordem,exibir,sysUser) values ("&camposResult("id")&",'"&tipoRecibo&"','0','N','"&session("User")&"')")
	       'response.write("insert into recibo_campos (campoId,tipo,ordem,exibir,sysUser) values ("&camposResult("id")&",'"&tipoRecibo&"','0','N','"&session("User")&"')")
            camposResult.movenext
        wend
        camposResult.close
    end if
end function

'CamposRecibo = array("Quantidade","Senha", "Subtotal", "Total", "Desconto", "Valor Unitario", "Valor pago", "Valor pendente", "Descricao")
'verifica se tem campos do recibo
    

'on error resume next
set reg = db.execute("select * from Impressos")
if not reg.EOF then
	Cabecalho = reg("Cabecalho")
	Rodape = reg("Rodape")
	Prescricoes = reg("Prescricoes")
	Atestados = reg("Atestados")
	PedidosExame = reg("PedidosExame")
	Recibos = reg("Recibos")
	RecibosIntegrados = reg("RecibosIntegrados")
	RecibosIntegradosAPagar = reg("RecibosIntegradosAPagar")
	Agendamentos = reg("Agendamentos")
	CabecalhoProposta = reg("CabecalhoProposta")
	RodapeProposta = reg("RodapeProposta")
'	ItensProposta = reg("ItensProposta")
    Protocolo = reg("Protocolo")
    LaudosProtocolo = reg("LaudosProtocolo")
    EtiquetaAgendamento = reg("EtiquetaAgendamento")
    TermoCancelamento = reg("TermoCancelamento")
    ReciboHonorarioMedico = reg("ReciboHonorarioMedico")
    RPSModelo = reg("RPSModelo")
end if

    'PARAMETROS MODAL TAGS - include tags.asp
    RecursoTag = ""
%>
<form method="post" action="" id="formImpressos">
    <div class="tabbable panel">
        <div class="tab-content panel-body">
            <div id="divPapelTimbrado" class="tab-pane in active">
            </div>

            <div id="divPrescricoes" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-Prescricoes" onClick="saveImpressos('Prescricoes');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "Prescricoes", "Layout das Prescri&ccedil;&otilde;es", 9, Prescricoes, "400", "", "")
                    RecursoTag = "Prescricoes"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divAtestados" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-Atestados" onClick="saveImpressos('Atestados');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                    
                <div class="row">
					<%
                    call quickField("editor", "Atestados", "Layout dos Atestados", 9, Atestados, "400", "", "")
                    RecursoTag = "Atestados"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divPedidos" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-PedidosExame" onClick="saveImpressos('PedidosExame');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "PedidosExame", "Layout dos Pedidos de Exame", 9, PedidosExame, "400", "", "")
                    RecursoTag = "PedidosExame"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divProtocolo" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-Protocolo" onClick="saveImpressos('Protocolo');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "Protocolo", "Layout dos Protocolos", 9, Protocolo, "400", "", "")
                    RecursoTag = "paciente"
                    %>
                    <!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divRecibos" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-Recibos" onClick="saveImpressos('Recibos');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "Recibos", "Layout dos Recibos", 9, Recibos, "400", "", "")
                    RecursoTag = "Recibos"
                    %>
                    <!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divRecibosIntegrados" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-RecibosIntegrados" onClick="saveImpressos('RecibosIntegrados');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "RecibosIntegrados", "Layout dos Recibos Integrados &agrave;s Contas a Receber", 9, RecibosIntegrados, "400", "", "")
                    RecursoTag = "RecibosIntegrados"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
                <div class="row mt10">
                    <div class="panel col-md-5">
                        <div class="panel-heading">
                            <span class="panel-title">Selecione os campos que serão visiveis no recibo</span>
                        </div>
                        <div class="panel-body p7 ">
                        <div class="row">
                            <ol class="sortable list-group">
                            <%
                            CreateCamposRecibo("RecibosIntegrados")
                            sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='RecibosIntegrados' order by rc.ordem"
                            set CamposRecibo = db.execute(sqlvar)
                            if not CamposRecibo.eof then
                                While not CamposRecibo.eof
                                    disabled=""
                                    ordem = CamposRecibo("ordem")
                                    if CamposRecibo("exibir")="N" then
                                        disabled = "disabled"
                                        ordem = 0
                                    end if
                                %>
                                    <li class="list-group-item" >
                                        <input type="hidden" value="<%=ordem%>" id="ordem<%=CamposRecibo("campoId")%>" class="sortable-number">
                                        <div class="row">
                                            <div class="col-md-1">
                                                <span class="far fa-sort"></span>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="checkbox-primary checkbox-custom">
                                                    <input type="checkbox" name="campos_recibo"
                                                        id="campo<%=CamposRecibo("campoId")%>" value="<%=CamposRecibo("campoId")%>"
                                                        <% if CamposRecibo("exibir")="S" then response.write("checked") end if %>
                                                       >
                                                    <label for="campo<%=CamposRecibo("campoId")%>">
                                                        <small><%=CamposRecibo("nome")%></small>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    </li>
                                <%
                                CamposRecibo.movenext
                                wend
                                CamposRecibo.close
                            end if
                            %>
                            </ol>
                        </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="divRecibosIntegradosAPagar" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-RecibosIntegradosAPagar" onClick="saveImpressos('RecibosIntegradosAPagar');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "RecibosIntegradosAPagar", "Layout dos Recibos Integrados &agrave;s Contas a Pagar", 9, RecibosIntegradosAPagar, "400", "", "")
                    RecursoTag = "RecibosIntegradosAPagar"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
                <div class="row mt10">
                    <div class="panel col-md-5">
                        <div class="panel-heading">
                            <span class="panel-title">Selecione os campos que serão visiveis no recibo</span>
                        </div>
                        <div class="panel-body p7 ">
                        <div class="row">
                            <ol class="sortable2 list-group">
                            <%
                            CreateCamposRecibo("RecibosIntegradosAPagar")
                            sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='RecibosIntegradosAPagar' order by rc.ordem"
                            set CamposReciboApagar = db.execute(sqlvar)
                            if not CamposReciboApagar.eof then
                                While not CamposReciboApagar.eof
                                    disabled=""
                                    ordem = CamposReciboApagar("ordem")
                                    if CamposReciboApagar("exibir")="N" then
                                        disabled = "disabled"
                                        ordem = 0
                                    end if
                                %>
                                    <li class="list-group-item" >
                                        <input type="hidden" value="<%=ordem%>" id="ordemP<%=CamposReciboApagar("campoId")%>" class="sortable-number">
                                        <div class="row">
                                            <div class="col-md-1">
                                                <span class="far fa-sort"></span>
                                            </div>
                                            <div class="col-md-6">
                                                <div class="checkbox-primary checkbox-custom">
                                                    <input type="checkbox" name="campos_recibo_apagar"
                                                        id="campoP<%=CamposReciboApagar("campoId")%>" value="<%=CamposReciboApagar("campoId")%>"
                                                        <% if CamposReciboApagar("exibir")="S" then response.write("checked") end if %>
                                                        >
                                                    <label for="campoP<%=CamposReciboApagar("campoId")%>">
                                                        <small><%=CamposReciboApagar("nome")%></small>
                                                    </label>
                                                </div>
                                            </div>
                                        </div>
                                    </li>
                                <%
                                CamposReciboApagar.movenext
                                wend
                                CamposReciboApagar.close
                            end if
                            %>
                            </ol>
                        </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="divAgendamentos" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-Agendamentos" onClick="saveImpressos('Agendamentos');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="row">
					<%
                    call quickField("editor", "Agendamentos", "Layout da impressão dos agendamentos", 9, Agendamentos, "400", "", "")
                    RecursoTag = "Agendamentos"
                    %>
					<!--#include file="Tags.asp"-->
                </div>
            </div>

            <div id="divPropostas" class="tab-pane">
                <div class="clearfix form-actions">
                    <div class="col-md-3">
                        <button id="btn-Propostas" onClick="saveImpressos('Propostas');" type="button" class="btn btn-success">Salvar</button>
                    </div>
                </div>
                <div class="row">
					<%
                    call quickField("editor", "CabecalhoProposta", "Layout padrão do topo da proposta", 9, CabecalhoProposta, "250", "", "")
                    RecursoTag = "CabecalhoProposta"
                    %>
					<div class="col-md-3">
                        <!--#include file="Tags.asp"-->
                    </div>
                </div>
                <div class="row">
					<% call quickField("editor", "RodapeProposta", "Layout padrão da parte inferior das propostas", 9, RodapeProposta, "250", "", "") %>
                </div>
                <br />
                <div class="row">
					<%
                    call quickField("editor", "ItensProposta", "Layout dos itens contidos nesta proposta", 9, ItensProposta, "250", "", "")
                    RecursoTag = "ItensProposta"
                    %><br />
                    <div class="col-md-3">
                        <!--#include file="Tags.asp"-->
                    </div>
                </div>
            </div>
            <div class="tab-pane" id="divProcedimentos">
                Carregando...
            </div>
            <div class="tab-pane" id="divContratos">
                Carregando...
            </div>

            <div class="tab-pane" id="divLaudos">
                Carregando...
            </div>

            <div class="tab-pane" id="divEncaminhamentos">
                Carregando...
            </div>

            <div id="divLaudosProtocolo" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-LaudosProtocolo" onClick="saveImpressos('LaudosProtocolo');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="col-md-9">
                    <div class="row">
                        <%
                        call quickField("editor", "LaudosProtocolo", "Layout do Protocolo dos Laudos", 12, LaudosProtocolo, "500", "", "")
                        RecursoTag = "LaudosProtocolo"
                        %>
                    </div>
                </div>
                <div class="col-md-3">
                    <!--#include file="Tags.asp"-->
                </div>
            </div>


            <div id="divEtiquetaAgendamento" class="tab-pane">
                    <div class="clearfix form-actions">
                        <div class="col-md-3">
                            <button id="btn-EtiquetaAgendamento" onClick="saveImpressos('EtiquetaAgendamento');" type="button" class="btn btn-success">Salvar</button>
                        </div>
                    </div>
                <div class="col-md-9">
                    <div class="row">
                        <%
                        call quickField("editor", "EtiquetaAgendamento", "Layout da Etiqueta dos Agendamentos", 12, EtiquetaAgendamento, "500", "", "")
                        RecursoTag = "EtiquetaAgendamento"
                        %>
                    </div>
                </div>
                <div class="col-md-3">
                    <!--#include file="Tags.asp"-->
                </div>
            </div>

            <!-- Termo de Cancelamento-->

            <div id="divTermoCancelamento" class="tab-pane">
                <div class="clearfix form-actions">
                    <div class="col-md-3">
                        <button id="btn-TermoCancelamento" onClick="saveImpressos('TermoCancelamento');" type="button" class="btn btn-success">Salvar</button>
                    </div>
                </div>
            <div class="col-md-9">
                <div class="row">
                    <%
                    call quickField("editor", "TermoCancelamento", "Layout do Termo de Cancelamento", 12, TermoCancelamento, "500", "", "")
                    RecursoTag = "TermoCancelamento"
                    %>
                </div>
            </div>
            <div class="col-md-3">
                <!--#include file="Tags.asp"-->
            </div>
        </div>

            <!--   ****************   -->

            <!-- Recibo de honorário Médico-->

            <div id="divRecibosHM" class="tab-pane">
                <div class="clearfix form-actions">
                    <div class="col-md-3">
                        <button id="btn-ReciboHM" onClick="saveImpressos('ReciboHonorarioMedico');" type="button" class="btn btn-success">Salvar</button>
                    </div>
                </div>
            <div class="col-md-9">
                <div class="row">
                    <%
                    call quickField("editor", "ReciboHonorarioMedico", "Layout do Recibo de Honorário Médico", 12, ReciboHonorarioMedico, "500", "", "")
                    RecursoTag = "ReciboHonorarioMedico"
                    %>
                </div>
            </div>
            <div class="col-md-3">
                <!--#include file="Tags.asp"-->
            </div>
        </div>

            <!--   ****************   -->
         <!-- RPS-->

            <div id="divRecibosRPS" class="tab-pane">
                <div class="clearfix form-actions">
                    <div class="col-md-3">
                        <button id="btn-RPSModelo" onClick="saveImpressos('RPSModelo');" type="button" class="btn btn-success">Salvar</button>
                    </div>
                </div>
            <div class="col-md-9">
                <div class="row">
                    <%
                    call quickField("editor", "RPSModelo", "Layout do RPS", 12, RPSModelo, "500", "", "")
                    RecursoTag = "RPSModelo"
                    %>
                </div>
            </div>
            <div class="col-md-3">
                <!--#include file="Tags.asp"-->
            </div>
        </div>

            <!--   ****************   -->

        </div>
    </div>
</form>

<script type="text/javascript">
function saveImpressos(tipo){
	$("#btn-"+tipo).html('salvando');
    $("#btn-"+tipo).attr('disabled', 'disabled');

    var listcampos =  null;
    var ordemName = "";
    var camposnames ="";
    var ordens ="";
    visiveis = "";

    if(tipo == "RecibosIntegrados"){
        listcampos =  document.getElementsByName("campos_recibo");
        ordemName = "ordem";
    }
    else if (tipo == "RecibosIntegradosAPagar"){
        listcampos =  document.getElementsByName("campos_recibo_apagar");
        ordemName = "ordemP";
    }

    if(tipo == "RecibosIntegrados" || tipo == "RecibosIntegradosAPagar"){
        for (i=0;i<listcampos.length;i++)
        {
            camposnames += listcampos[i].value;
            ordens += (i+1);
            visiveis += listcampos[i].checked?"S":"N";

            if( camposnames.length>0 && (i+1)<listcampos.length){
                camposnames += "|";
                ordens += "|";
                visiveis += "|";
            }
        }
    }

    if (tipo == "TermoCancelamento"){

    }

    $.post("saveImpressos.asp?Tipo="+tipo,{
		   Cabecalho: $("#Cabecalho").val(),
		   Rodape: $("#Rodape").val(),
		   Prescricoes: $("#Prescricoes").val(),
		   Atestados: $("#Atestados").val(),
		   Recibos: $("#Recibos").val(),
		   RecibosIntegrados: $("#RecibosIntegrados").val(),
		   RecibosIntegradosAPagar: $("#RecibosIntegradosAPagar").val(),
		   Agendamentos: $("#Agendamentos").val(),
		   PedidosExame: $("#PedidosExame").val(),
		   CabecalhoProposta: $("#CabecalhoProposta").val(),
		   ItensProposta: $("#ItensProposta").val(),
		   RodapeProposta: $("#RodapeProposta").val(),
		   LaudosProtocolo: $("#LaudosProtocolo").val(),
		   Protocolo: $("#Protocolo").val(),
           EtiquetaAgendamento: $("#EtiquetaAgendamento").val(),
           TermoCancelamento:$("#TermoCancelamento").val(),
           ReciboHonorarioMedico:$("#ReciboHonorarioMedico").val(),
           RPSModelo:$("#RPSModelo").val(),
           CamposRecibos: camposnames,
           Ordem : ordens,
           Visiveis : visiveis,

		   },function(data,status){
			  $("#btn-"+tipo).html('<i class="far fa-save"></i> Salvar');
			  $("#btn-"+tipo).removeAttr('disabled');
			  eval(data);
    });
}
$(document).ready(function(){
    ajxContent('papeltimbrado', '', 'Follow', 'divPapelTimbrado');

    $(".sortable ").sortable({
        placeholder: "sortable-placeholder",
        helper: 'clone',
        sort: function(e, ui) {
            $(ui.placeholder).html(Number($(".sortable > li:visible").index(ui.placeholder)) + 1);
        },
        update: function(event, ui) {
            var $lis = $(this).children('li');
            $lis.each(function() {
                var $li = $(this);
                var newVal = $(this).index() + 1;
                $(this).children('.sortable-number').val(newVal);
                $(this).children('#item_display_order').val(newVal);
            });
        }
    });

    $(".sortable2 ").sortable({
        placeholder: "sortable-placeholder",
        helper: 'clone',
        sort: function(e, ui) {
            $(ui.placeholder).html(Number($(".sortable2 > li:visible").index(ui.placeholder)) + 1);
        },
        update: function(event, ui) {
            var $lis = $(this).children('li');
            $lis.each(function() {
                var $li = $(this);
                var newVal = $(this).index() + 1;
                $(this).children('.sortable-number').val(newVal);
                $(this).children('#item_display_order').val(newVal);
            });
        }
    });
$(".sortable .sortable2").disableSelection();


});

<!--#include file="jQueryFunctions.asp"-->
</script>


