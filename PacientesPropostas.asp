<!--#include file="connect.asp"-->
<%if req("PacienteID")="" then %>
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Edição de Proposta");
    $(".crumb-icon a span").attr("class", "fa fa-files-o");
</script>
<%end if %>
<style type="text/css">
.proposta-item-procedimentos  span.select2-selection.select2-selection--single {
    height: 30px!important;
    font-size: 11px;
}

.PropostaDesconto{
    border-right: 0!important;
}

.proposta-item-procedimentos > td {
    padding: 3px!important;
}
.duplo>tbody>tr:nth-child(4n+1)>td,
.duplo>tbody>tr:nth-child(4n+2)>td
{    background-color: #f9f9f9;
}
.duplo>tbody>tr:nth-child(4n+3)>td,
.duplo>tbody>tr:nth-child(4n+4)>td
{    background-color: #ffffff;
}

#TabelaID{
   /*margin-top: 25px;*/
}


.modal-lg{
    width:70%!important
}

.select2-container{
    /*width: 150px!important;*/
}
</style>
<% IF req("PacienteID")="" THEN %>
<script src="<%=componentslegacyurl%>/assets/feegow-theme/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>
<% END IF %>
<%
tableName = "propostas"
CD = req("T")

Titulo = "EDIÇÃO DE PROPOSTA"

PropostaID = req("PropostaID")
if PropostaID="N" then
	sqlVie = "select * from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, Valor) values ("&session("User")&", 0, 0)")
		set vie = db.execute(sqlVie)
	end if
	if req("PacienteID")<>"" then
		response.Redirect("PacientesPropostas.asp?PropostaID="&vie("id")&"&PacienteID="&req("PacienteID")&"&Pers=1")
	else
		response.Redirect("./?P=PacientesPropostas&PropostaID="&vie("id")&"&Pers=1")
	end if
else
	set data = db.execute("select * from "&tableName&" where id="&PropostaID)
	if data.eof then
		if req("PacienteID")<>"" then
			response.Redirect("PacientesPropostas.asp?P=Propostas&PacienteID="&req("PacienteID")&"&PropostaID=N&Pers=1")
		else
			response.Redirect("./?P=PacientesPropostas&PropostaID="&req("PropostaID")&"&Pers=1")
		end if
	end if
end if


TituloItens = "Itens da Proposta"
TituloOutros = "Outras Despesas"
TituloPagamento = "Forma de Pagamento"

if lcase(session("table"))="profissionais" then
    ProfissionalID = session("idInTable")
end if

if data("sysActive")=1 then
	PacienteID = data("PacienteID")
	TabelaID = data("TabelaID")
	TituloItens = data("TituloItens")
	TituloOutros = data("TituloOutros")
	TituloPagamento = data("TituloPagamento")
	ObservacoesProposta = data("ObservacoesProposta")
	Internas = data("Internas")
	StaID = data("StaID")
	DataProposta = data("DataProposta")
	DescontoTotal = data("Desconto")
	Cabecalho = data("Cabecalho")
	ProfissionalID = data("ProfissionalID")
	User = nameInTable(data("sysUser"))
else
	PacienteID = req("PacienteID")
	TabelaID=0
	set tabPac = db.execute("select Tabela from pacientes where id="&treatvalzero(PacienteID))
	if not tabPac.eof then
	    TabelaID = tabPac("Tabela")
    end if
	DataProposta = date()
	set pultit = db.execute("select TituloItens, TituloOutros, TituloPagamento from propostas where sysActive=1 and not isnull(TituloItens) and not TituloItens='' order by id desc limit 1")
	if not pultit.eof then
		TituloItens = pultit("TituloItens")
		if not isnull(pultit("TituloOutros")) and pultit("TituloOutros")<>"" then
			TituloOutros = pultit("TituloOutros")
		end if
		if not isnull(pultit("TituloPagamento")) and pultit("TituloPagamento")<>"" then
			TituloPagamento = pultit("TituloPagamento")
		end if
	end if
    ObservacoesProposta = ""
end if

'desabilitar conta edicao de conta
if StaID&"" = "5" then
    desabilitarProposta =" disabled "
    escondeProposta = " hidden "
end if
%>
<div class="row col-md-12">
    <br />


                <%
                if req("PacienteID")&"" <> "" then
                    set PropostaEmAbertoSQL = db.execute("SELECT id FROM propostas WHERE PacienteID="&treatvalzero(req("PacienteID"))&" AND id<>"&PropostaID&" AND StaID IN (1, 4)")

                    if not PropostaEmAbertoSQL.eof then
                    %>
    <div class="alert alert-warning">
        <strong>Atenção! </strong> Este paciente já possui uma proposta em aberto.
    </div>
                    <%
                    end if
                end if


                %>

              <form id="frmProposta" action="" method="post">
              <input type="hidden" id="temregradesconto" name="temregradesconto" value="0">
              <div class="panel">
 		            
                    <div class="panel-heading <%
                        if req("PacienteID")="" then 
                            response.write("hidden")
                            linkLista = "location.href='?P=buscaPropostas&Pers=1'"
                            reload = "true"
                        else
                            linkLista = "ajxContent('ListaPropostas&PacienteID="&req("PacienteID")&"', '', '1', 'pront')"
                            reload = "false"

                        end if %> ">
                        <span class="panel-title">
                            <i class="fa fa-files-o"></i> Edição de Proposta
                        </span>
                        <span class="panel-controls" id="btnsProposta">
                            <%call odonto()%>
<!--<a title="Histórico de Alterações" href="javascript:log()" class="btn btn-sm btn-default hidden-xs"><i class="fa fa-history"></i></a>-->
                            <% if session("Odonto")=1 then %>
                                <button type="button" class="btn btn-system btn-sm" id="btn-abrir-modal-odontograma" <%=desabilitarProposta%>> <span class="imoon imoon-grin2"></span> Odontograma </button>
                            <% end if %>
                            <button type="button" class="btn btn-sm " id="ListaProposta" onclick="<%=linkLista %>" title="Listas Propostas"><i class="fa fa-list"></i></button>
                            <button type="button" class="btn btn-sm" title="Duplicar Proposta" onclick="window.location.href = '?P=DuplicarPacientesPropostas&Pers=1&PropostaID=<%=req("PropostaID")%>'"><i class="fa fa-copy"></i> Duplicar Proposta</button>
                            <button type="button" class="btn btn-sm" onclick="log()" title="Histórico de Alterações"><i class="fa fa-history"></i></button>
                            <button type="button" onclick="imprimirProposta()" class="btn btn-info btn-sm" title="Imprimir"><i class="fa fa-print"></i></button>
                            <button onclick="propostaSave(<%=reload%>)" type="button" class="btn btn-primary btn-sm "><i class="fa fa-save"></i> SALVAR</button>
                        </span>
                        <%if req("PacienteID")="" then %>
                        <script type="text/javascript">
                            $("#rbtns").html($("#btnsProposta").html());
                            $("#btnsProposta").html("");

                            function log(){
                                $('#modal-table').modal('show');
                                $.get('DefaultLog.asp?R=propostas&I=<%=PropostaID%>', function(data){
                                    $('#modal').html(data);
                                })
                            }

                            function duplicarProposta(arg) {
                                $.get("printEtiqueta.asp?ProdutoID="+ ProdutoID, function (data) {
                                    $("#modal-table").modal("show");
                                    $(".modal-content").html(data);
                                });
                            }

                        </script>
                        <% End If %>
                    </div>
			            
		            
                  <div class="panel-body">
                    <div class="row">
                          <div class="col-md-4">
                              <%
                        if req("PacienteID")="" then
                              %>
                              <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
                              <%
                            pula = "<label>&nbsp;</label><br>"
                        else
                              %>
                              <%= selectInsert("Paciente", "PacienteID", req("PacienteID"), "pacientes", "NomePaciente", "disabled", "", "") %>
                              <input type="hidden" name="PacienteID" id="PacienteID" value="<%=PacienteID%>">
                              <%
                        end if
                              %>
                          </div>
                       <%= quickField("simpleSelect", "TabelaID", "Tabela", 4, TabelaID, "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' order by NomeTabela", "NomeTabela", desabilitarProposta ) %>
                       <%= quickField("datepicker", "DataProposta", "Data da Proposta", 4, DataProposta, "", "", desabilitarProposta) %>
                                                   </div>
                <div class="row" style="margin-top: 10px">

                                                  <script>
                                                        function changeStaID(){
                                                           if($("#StaID").val() == 3){
                                                               $(".motivo").removeClass("hidden");
                                                               $("#MotivoID").removeAttr("readonly");
                                                               $("#MotivoID").removeAttr("disabled");
                                                               return;
                                                           }
                                                           $(".motivo").addClass("hidden");
                                                           $("#MotivoID").attr("readonly","readonly");
                                                           $("#MotivoID").attr("disabled","disabled");
                                                        }

                                                        $(function() {
                                                             changeStaID();
                                                             $("#StaID").on("change",()=>{changeStaID();})
                                                        });

                                                  </script>
                                                  <div class="col-md-4">
                                                     <label>Profissional</label>
                                                     <%

                                                      if getconfig("profissionalsolicitanteobrigatorioproposta")=1 then
                                                          SolicitanteRequired = " required empty "
                                                      end if

                                                      response.write(quickField("simpleSelect", "ProfissionalID", "", 4, ProfissionalID, "select * from profissionais WHERE Ativo='on' AND sysActive = 1 order by id", "NomeProfissional", SolicitanteRequired))

                                                      %>
                                                 </div>
                                                   <div class="col-md-4">
                                                       <label>Status</label>
                                                       <%= quickField("simpleSelect", "StaID", "", 4, StaID, "select * from propostasstatus order by id", "NomeStatus", "semVazio") %>
                                                   </div>
                                                   <div class="col-md-4 hidden motivo">
                                                        <label>Motivo</label>
                                                        <%= quickField("simpleSelect", "MotivoID", "", 4, MotivoID, "select * from propostasmotivostatus WHERE status = 3 order by id", "descricao", "semVazio") %>
                                                        </div>
</div>
                         <div class="row">
                             <div class="col-md-12 text-right">
                                 <%=pula%>
                                  <!-- <a id="btn-gerar-contrato" href="?P=GerarContrato&Pers=1&PropostaID=<%=req("PropostaID")%>&ProfissionalSolicitante=<%=ProfissionalID %>" class="btn btn-default">Gerar contrato</a>-->
                                  <%
                                  if isnull(data("InvoiceID")) then
                                    %>
                                    <button id="btn-gerar-contrato" class="btn btn-default" onclick="GerarContrato()" type="button"> Gerar contrato </button>
                                    <%
                                  else
                                    %>
                                    <a target="_blank" href="?P=invoice&I=<%=data("InvoiceID")%>&A=&Pers=1&T=C&Ent=" id="btn-gerar-contrato" class="btn btn-default" type="button"> <i class="fa fa-external-link"></i> Abrir conta</a>
                                    <%
                                  end if
                                  %>
                             </div>
                         </div> 
                  </div>
              </div>

            <div class="row">
                <div class="col-md-12">
                    <div class="msgDescontoPendente">

                    </div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-editbox" style="display:block">
                    <input class="form-control dadoProposta" name="TituloItens" id="TituloItens" value="<%=TituloItens%>" style="color: #4383b4;" <%=desabilitarProposta%>>
                </div>
                <div class="panel-body">
                    <div class="col-xs-9">
                        <%server.Execute("PropostaItens.asp")%>
                    </div>
                    <div class="col-xs-3 pn <%=escondeProposta%>">

                        <div class="panel mn">
                          <div class="panel-menu">
                                <div class="input-group">
                                    <input id="FiltroProItens" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar procedimento..." type="text">
                                    <span class="input-group-btn">
                                        <button class="btn btn-sm btn-default" onclick="ListaProItens($('#FiltroProItens').val(), '', '')" type="button">
                                            <i class="fa fa-filter icon-filter bigger-110"></i>
                                            Buscar
                                        </button>
                                    </span>
                                </div>
                          </div>
                          <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                            <table class="table mbn tc-icon-1 tc-med-2" >
                              <tbody id="ListaProItens">

                              </tbody>
                            </table>

                          </div>
                        </div>
                    </div>
                </div>
            </div>


<div id="permissaoTabelaProposta" class="modal fade" role="dialog">
  <div class="modal-dialog">

    <!-- Modal content-->
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">Permissão para uso de Tabela</h4>
      </div>
      <div class="modal-body">
        <div class="col-md-4">
            <p>Selecione um usuário abaixo que tenha  permissão: 
                </p>      
              
        </div>        
            <div class="col-md-6">
                <label style="" class="error_msg"></label><br>
                <label>Senha do Usuário</label>
                <input type="hidden" autocomplete="off"  id="desconto-password" name="desconto-password" class="form-control">
            </div>

        <div class="col-md-12 tabelaParticular" style="color:#000;">
        
             
        </div>
        </div>
       
        <div class="modal-footer" style="margin-top:13em;">
                <button type="button" class="btn btn-default fechar" data-dismiss="modal" >Fechar</button>                
                <button type="button" class="btn btn-info confirmar"    >Confirmar</button>
       
         </div>

  </div>
</div>
</div>


            <div class="panel">
                <div class="panel-editbox" style="display:block">
                    <input class="form-control dadoProposta" name="TituloPagamento" id="TituloPagamento" value="<%=TituloPagamento%>" style="color: #4383b4;" <%=desabilitarProposta%>>
                </div>
                <div class="panel-body">
                    <div class="col-xs-9 PropostaItensConteudo">
                        <%server.Execute("propostasFormas.asp")%>
                    </div>
                    <div class="col-xs-3 pn <%=escondeProposta%>">
                        <div class="panel mn">
                          <div class="panel-menu">
                                <div class="input-group">
                                    <input id="FiltroProFormas" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar forma..." type="text">
                                    <span class="input-group-btn">
                                        <button class="btn btn-sm btn-default" onclick="ListaProFormas($('#FiltroProFormas').val(), '', '')" type="button">
                                            <i class="fa fa-filter icon-filter bigger-110"></i>
                                            Buscar 
                                        </button>
                                    </span>
                                    <%if aut("formapagamentopropostaI")=1 then%>
                                    <span class="input-group-btn">
                                        <a class="btn btn-sm btn-dark tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar formas de pagamento para futuras propostas" data-rel="tooltip" data-placement="top" title="" onclick="modalProFormas('', 0)"><i class="fa fa-plus"></i></a>
                                    </span>
                                    <%end if%>
                                </div>
                          </div>
                          <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                            <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                              <tbody id="ListaProFormas">

                              </tbody>
                            </table>

                          </div>
                        </div>
                    </div>
                </div>
            </div>


            <div class="panel">
                <div class="panel-editbox" style="display:block">
                    <input class="form-control dadoProposta" name="TituloOutros" id="TituloOutros" value="<%=TituloOutros%>" style="color:#4383b4;" <%=desabilitarProposta%>>
                </div>
                <div class="panel-body">
                    <div class="col-xs-9">
				        <%server.Execute("propostasOutros.asp")%>
                    </div>
                    <div class="col-xs-3 pn <%=escondeProposta%>">
                        <div class="panel mn">
                          <div class="panel-menu">
                                    <div class="input-group">
                                        <input id="FiltroProOutros" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar despesa..." type="text">
                                        <span class="input-group-btn">
                                            <button class="btn btn-sm btn-default" onclick="ListaProItens($('#FiltroProOutros').val(), '', '')" type="button">
                                                <i class="fa fa-filter icon-filter bigger-110"></i>
                                                Buscar 
                                            </button>
                                        </span>
                                        <span class="input-group-btn">
                                            <a class="btn btn-sm btn-dark tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar outras despesas para futuras propostas" data-rel="tooltip" data-placement="top" title="" onclick="modalProOutros('', 0)">
                                                <i class="fa fa-plus icon-plus blue"></i>
                                            </a>
                                        </span>
                                    </div>
                          </div>
                          <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                            <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                              <tbody id="ListaProOutros">

                              </tbody>
                            </table>

                          </div>
                        </div>
                    </div>
                    
                </div>
            </div>


		    <div class="panel">
                <div class="panel-body">
                    <%= quickField("editor", "ObservacoesProposta", "Texto complementar", 9, ObservacoesProposta, "80", "", desabilitarProposta) %>
            	    <%= quickField("memo", "Internas", "Observações Internas", 3, Internas, "dadoProposta", "", " rows=8") %>
                </div>
            </div>

              </form>


		    <div id="ListaPropostas" class="tab-pane">
			    <!--<p>Carregando...</p>-->
			    <%
			    if User<>"" then
			    %>
			    Criado por <%=User%>
			    <%
			    end if
			    %>
		    </div>

<!-- Modal -->

    </div>


<!--#include file="CalculaMaximoDesconto.asp"-->

<script type="text/javascript">
var $Proposta = $("#frmProposta");

var $DescontoTipo = $(".DescontoTipo");
var $Desconto = $(".PropostaDesconto");
var $DescontoTotal = $("#DescontoTotal");
var timeoutDesconto;

$DescontoTotal.keyup(function() {
    $DescontoTipo = $(".DescontoTipo");
    $Desconto = $(".PropostaDesconto");

    var Desconto = parseFloat($(this).val());
    if (!Desconto){
        Desconto = 0;
    }
    clearTimeout(timeoutDesconto);
    $DescontoTipo.val("P");
    $Desconto.val(Desconto);

    timeoutDesconto = setTimeout(function() {
        $DescontoTipo.change();
        $Desconto.change();
    }, 300);

    $DescontoInvalido = $(this);
});

var $DescontoInvalido = false;

$Proposta.on("change",".DescontoTipo, .PropostaDesconto", function() {
    var $descontoLinha = $(this).parents("tr");

    var Desconto = parseFloat($descontoLinha.find(".PropostaDesconto").val().replace(",00","")/*.replace(",",".")*/);

    var ProcedimentoID = parseInt($descontoLinha.find("[data-resource=procedimentos]").val());
    var TipoDesconto = $descontoLinha.find(".DescontoTipo").val();
    var ValorUnitario = parseFloat($descontoLinha.find(".ValorUnitario").val().replace(",00","").replace(".",""));
   


    if(TipoDesconto !== "P"){
        Desconto = (Desconto/ValorUnitario) * 100;
        
    }

    CalculaDesconto(ValorUnitario, Desconto, TipoDesconto, ProcedimentoID, "Propostas", $descontoLinha.find(".PropostaDesconto"));
});

function ListaProItens(Filtro, X, Aplicar){
	$("#ListaProItens").html('Buscando...');
	$.post("ListaProItens.asp?Filtro="+Filtro,{
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaProItens").html(data);
	});
}

function ListaProOutros(Filtro, X, Aplicar){
	$("#ListaProOutros").html('Buscando...');
	$.post("ListaProOutros.asp?Filtro="+Filtro,{
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaProOutros").html(data);
	});
}


function ListaProFormas(Filtro, X, Aplicar){
	$("#ListaProFormas").html('Buscando...');
	$.post("ListaProFormas.asp?Filtro="+Filtro,{
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaProFormas").html(data);
	});
}

function GerarContrato(){

    gtag('event', 'contrato_gerado', {
        'event_category': 'proposta',
        'event_label': "Botão 'Gerar contrato'",
    });

    propostaSave(false, function() {
        var profissional = document.getElementById("ProfissionalID");
        document.location.href = "?P=GerarContrato&Pers=1&PropostaID=<%=req("PropostaID")%>&ProfissionalSolicitante=" + profissional.options[profissional.selectedIndex].value;
    });
}

$('#FiltroProItens').keypress(function(e){
    if ( e.which == 13 ){
		ListaProItens($('#FiltroProItens').val(), '', '');
		return false;
	}
});


$('#FiltroProOutros').keypress(function(e){
    if ( e.which == 13 ){
		ListaProOutros($('#FiltroProOutros').val(), '', '');
		return false;
	}
});

$('#FiltroProFormas').keypress(function(e){
    if ( e.which == 13 ){
		ListaProFormas($('#FiltroProFormas').val(), '', '');
		return false;
	}
});

function modalProOutros(tipo, id){
	$.post("modalProOutros.asp?id="+id,{
		   PacienteID:'<%=PacienteID%>'
		   },function(data,status){
	  $("#modal").html(data);
	});
}

function modalProFormas(tipo, id){
	$.post("modalProFormas.asp?id="+id,{
		   PacienteID:'<%=PacienteID%>'
		   },function(data,status){
	  $("#modal").html(data);
	});
}
var propostaIDAplicar = '<%=PropostaID%>';
function aplicarProOutros(II, A){
	if(A=='I'){
		$.post("propostasOutros.asp?PacienteID=<%=PacienteID%>", {PropostaID:propostaIDAplicar,II:II, A:A, minorRowOutros:$("#minorRowOutros").val()}, function(data, status){ $("#PropostasOutros").before(data) } );
	}else if(A=='X'){
		$("#rowOutros"+II).replaceWith("");
	}
}

function aplicarProFormas(II, A){
	if(A=='I'){
		$.post("propostasFormas.asp?PacienteID=<%=PacienteID%>", {II:II, A:A, minorRowFormas:$("#minorRowFormas").val()}, function(data, status){ $("#PropostasFormas").before(data) } );
	}else if(A=='X'){
		$("#rowFormas"+II).replaceWith("");
	}
}

function imprimirProposta(){
    if($("#PacienteID").val() == ""){
		alert("Selecione um paciente");
		return false;
	}else{
        propostaSave(false, function() {
            $.get("ImprimirProposta.asp?PropostaID=<%=PropostaID%>", function(data){ $("#modal").html(data) });
        });
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
    }
}

function imprimirPropostaSV(){
	$("#modal-table").modal("show");
	$("#modal").html("Carregando...");
	$.get("ImprimirPropostaSV.asp?PropostaID=<%=PropostaID%>", function(data){ $("#modal").html(data) });
}

function ProcecimentosLaboratoriais(){
    openComponentsModal("AgendamentoLaboratorial.asp", {
            
        }, "Agendamento Laboratorial", false, "", "lg");
}

ListaProItens('', '', '');
ListaProFormas('', '', '');
ListaProOutros('', '', '');

<!--#include file="propostasfuncoes.asp"-->

<!--#include file="financialCommomScripts.asp"-->

var $conteudoParaOdontograma = $('#feegow-odontograma-conteudo'),
        $odontogramaModal = $('#feegow-odontograma-modal');

    $('#btn-abrir-modal-odontograma').on('click', function () {
        var PacienteID = $("#PacienteID").val();

        if(PacienteID == ''){
            alert('Você precisa selecionar um paciente!');
        }else{

            $("#modal").html('');
            $("#modal-table").modal('show');

            //$.get(feegow_components_path+'odontograma?P='+PacienteID+'&B=<%=ccur(replace(session("Banco"), "clinic", ""))*999 %>&O=Proposta&U=<%=session("User")%>&I=<%=PropostaID%>&L=<%=replace(session("Banco"), "clinic", "") %>',
            $.get(feegow_components_path+'odontograma?P='+PacienteID+'&B=<%=ccur(replace(session("Banco"), "clinic", ""))*999 %>&O=Proposta&U=<%=session("User")%>&I=<%=PropostaID%>&L=<%=replace(session("Banco"), "clinic", "") %>',
            function (data) {
                setTimeout(function () {
                    var content = "<div class='modal-header'>Odontograma</div><div class='modal-body'>" + data + "</div><div class='modal-footer'><div class='col-xs-12 col-md-offset-10 col-md-2'><button class='btn btn-primary btn-block' id='feegow-odontograma-finalizar'>Salvar Odontograma</button></div></div>";
                    $("#modal").html(content).fadeIn();
                }, 200);
            });

            $odontogramaModal.modal('show');
        }
    });

    $(function(){
        $(".btn-gerar-pedido").on('click', function(){
            var PacienteID = $("#PacienteID").val();
            if(PacienteID == ''){
                alert('Você precisa selecionar um paciente!');
                return false;
            }

            $.post("gravarCarrinhoAgendamento.asp?PropostaID=<%=PropostaID%>", $("#frmProposta").serialize(), function(data){ eval(data) });
        });
    });

    setTimeout(function(){
        Core.init();
    }, 2000);

    function adicionarItens(){
        var inc = $('[data-val]:last').attr('data-val');
        if(inc==undefined){inc=0}

        $(".itens-exames-laboratoriais").each(function(i, value){
            var id = $(this).find(".ck_procedimento_id").attr("data-value");
            var check = $(this).find(".ck_procedimento_id").is(':checked');
            var qtde = $(this).find(".itemquantidade").val();
            if(check){
                if(inc == 0){
                    itens('S', 'I', id, qtde, (i + 1))
                }else{
                    itens('S', 'I', id, qtde)
                }
            }
        })
        

        $.post("PreparoExame.asp",  $("#formprocedimentos").serialize()  , function (data) { $("#tela").html(data) });
    }

    var itensPropostasGlobal = "";

    function procurarAprovacaoDesconto(){
        var propostaItem = "";

        if(itensPropostasGlobal != ""){
            propostaItem = itensPropostasGlobal;
        }else{
            $("input[name='propostaItem']").each(function(index, item){
                propostaItem += "-"+item.value + ",";
            });
        }
        if(propostaItem != ""){
            propostaItem += "0";
            $.post('procurarDescontosPendentesPropostas.asp', { itens: propostaItem }, function(result){
                $(".msgDescontoPendente").html(result);
            });
        }
    }

    <%
    set PropostaAguardandoDescontoSQL = db.execute("select d.id from descontos_pendentes d INNER JOIN itensproposta i ON i.id= d.ItensInvoiceID*-1 where i.PropostaID="&treatvalzero(PropostaID)&" AND SysUserAutorizado IS NULL AND DataHoraAutorizado IS NULL")
    if not PropostaAguardandoDescontoSQL.eof then
    %>
    procurarAprovacaoDesconto();
    var descontoPendenteInterval = setInterval(procurarAprovacaoDesconto, 10000);
    <%
    end if
    %>




var idStr = "#TabelaID";
$('.modal').click(function(){
    $('#select2-TabelaID-container').text("Selecione");
    $('#TabelaID').val(0);
    $('.error_msg').empty();
});


$(idStr).change(function(){    
        var id          = $('#TabelaID').val();
        var sysUser     = "<%=session("user") %>";
        var Nometable   = $('#TabelaID :selected').text();
        var regra = "|tabelaParticular12V|";

        $.ajax({
        method: "POST",
        url: "TabelaAutorization.asp",
        data: {autorization:"buscartabela",id:id,sysUser:sysUser},
        success:function(result){
            if(result == "Tem regra") {
                $("#desconto-password").attr("type","password");
                $('#permissaoTabelaProposta').modal('show');
                buscarNome(id,sysUser,regra);
            }
        }
    });
        $('.confirmar').click(function(){
                var Usuario =  $('input[name="nome"]:checked').val();
                var senha   =  $('#desconto-password').val();
                liberar(Usuario , senha , id , Nometable);
                $('.error_msg').empty(); 
            });
    });



function buscarNome(id , user,regra){
    $.ajax({
        method: "POST",
        ContentType:"text/html",
        url: "TabelaAutorization.asp",
        data: {autorization:"pegarUsuariosQueTempermissoes",id:id,LicencaID:user,regra:regra},
        success:function(result){
            res = result.split('|');     
                    $('.tabelaParticular').html(result);
            }
        });
}

function liberar(Usuario , senha , id, Nometable){
    $.ajax({
    method: "POST",
    url: "SenhaDeAdministradorValida.asp",
    data: {autorization:"liberar",id:id ,U:Usuario , S:senha},
    success:function(result){      
            if( result == "1" ){
                    $('.error_msg').text("Logado Com Sucesso!").fadeIn().css({color:"green" });;
                setTimeout(() => {
                    $('#permissaoTabelaProposta').modal('hide');
                    $('#TabelaID').val(id);
                   
                    $('#select2-TabelaID-container').text(Nometable);

                }, 2000);
                }else{
                        $('.error_msg').text("Senha incorreta!").css({color:"red" }).fadeIn();
                        $('#select2-TabelaID-container').text("Selecione");
                        $('#TabelaID').val(0);
                }
            }
          
        });
       
}

</script>


