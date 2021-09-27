<!--#include file="connect.asp"-->
<%if req("PacienteID")="" then %>
<!--#include file="modal.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Edição de Proposta");
    $(".crumb-icon a span").attr("class", "far fa-files-o");
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
[name^=Quantidade]{
    width: 100%;
}
.form-control{
    min-width: 20px !important;
}

.modal-lg{
    width:70%!important
}

.select2-container,.select2-selection{
    width: 100%!important;
    max-width: 100%!important;
    max-width: 100%!important;
}
.select2-container--default .select2-results__option[aria-disabled=true] {
    display: none !important;
}
.dflex{
    display:flex;
}
.colunflex{
    flex-direction: column;
}
.executantes{
    justify-content: center;
    align-items: center;
    margin-left: 10px;
}
.actionbtn{
    position: relative;
    align-items: center;
    height: 60px;
}
.proposta-item-procedimentos td{
    vertical-align: baseline!important;
}
.proposta-item-procedimentos .input-group {
    position: relative;
    display: flex;
}
</style>
<% IF req("PacienteID")="" THEN %>
<script src="../feegow_components/assets/feegow-theme/vendor/plugins/datatables/media/js/jquery.dataTables.js"></script>
<% END IF %>
<%
tableName = "propostas"
CD = req("T")

Titulo = "EDIÇÃO DE PROPOSTA"

PropostaID = req("PropostaID")
if PropostaID="N" or PropostaID&"" = "" then
	sqlVie = "select * from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db_execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive, Valor) values ("&session("User")&", 0, 0)")
		set vie = db_execute(sqlVie)
	end if
	if req("PacienteID")<>"" then
		response.Redirect("PacientesPropostas.asp?PropostaID="&vie("id")&"&PacienteID="&req("PacienteID")&"&Pers=1")
	else
		response.Redirect("./?P=PacientesPropostas&PropostaID="&vie("id")&"&Pers=1")
	end if
else
    sql = "select * from "&tableName&" where id="&PropostaID
	set data = db_execute(sql)
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
    ProfissionalExecutanteID = data("ProfissionalExecutanteID")

    set tabPac = db_execute("select Tabela,Matricula1 from pacientes where id="&treatvalzero(PacienteID))
	if not tabPac.eof then
	    TabelaID = tabPac("Tabela")
	    Matricula = tabPac("Matricula1")
    end if

else
	PacienteID = req("PacienteID")
	TabelaID=0
	set tabPac = db_execute("select Tabela,Matricula1 from pacientes where id="&treatvalzero(PacienteID))
	if not tabPac.eof then
	    TabelaID = tabPac("Tabela")
	    Matricula = tabPac("Matricula1")
    end if

	DataProposta = date()
	set pultit = db_execute("select TituloItens, TituloOutros, TituloPagamento from propostas where sysActive=1 and not isnull(TituloItens) and not TituloItens='' order by id desc limit 1")
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
<div class="row col-md-12" id="proposta-page">
    <br />


                <%
                if req("PacienteID")&"" <> "" then
                    set PropostaEmAbertoSQL = db_execute("SELECT id FROM propostas WHERE PacienteID="&treatvalzero(req("PacienteID"))&" AND id<>"&PropostaID&" AND StaID IN (1, 4)")

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
                            <i class="far fa-files-o"></i> Edição de Proposta
                        </span>
                        <span class="panel-controls" id="btnsProposta">
                            <%call odonto()%>
<!--<a title="Histórico de Alterações" href="javascript:log()" class="btn btn-sm btn-default hidden-xs"><i class="far fa-history"></i></a>-->
                            <% if session("Odonto")=1 then %>
                                <button type="button" class="btn btn-system btn-sm" id="btn-abrir-modal-odontograma" <%=desabilitarProposta%>> <i class="far fa-tooth"></i> Odontograma </button>
                            <% end if %>
                            <button type="button" class="btn btn-sm " id="ListaProposta" onclick="<%=linkLista %>" title="Listas Propostas"><i class="far fa-list"></i></button>
                            <button type="button" class="btn btn-sm" title="Duplicar Proposta" onclick="window.location.href = '?P=DuplicarPacientesPropostas&Pers=1&PropostaID=<%=req("PropostaID")%>'"><i class="far fa-copy"></i> Duplicar Proposta</button>
                            <button type="button" class="btn btn-sm" onclick="log()" title="Histórico de Alterações"><i class="far fa-history"></i></button>

                            <div class="btn-group">
                                <a href="javascript:imprimirProposta(0)" class="btn btn-sm btn-info"><i class="far fa-print"></i></a>
                                <button class="btn btn-sm btn-info dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i
                                        class="far fa-angle-down icon-only"></i></button>
                                <ul class="dropdown-menu dropdown-info">
                                    <li>
                                        <a href="javascript:imprimirProposta(0)"><i class="far fa-print"></i> IMPRESSÃO PADRÃO</a>
                                        <a href="javascript:imprimirProposta(1)"><i class="far fa-print"></i> IMPRESSÃO AGRUPADA</a>
                                    </li>
                                </ul>
                            </div>


                            <button onclick="propostaSave(<%=reload%>)" type="button" class="btn btn-primary btn-sm "><i class="far fa-save"></i> SALVAR</button>
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
                              <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente","", "", "") %>
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

                      <%
                      if isAmorSaude() then
                      %>
                        <div class="col-md-3 qf" id="qfagematricula1">
                            <!--<div class="pull-right"><a id="openConsulta" href="javascript:openConsultaCartaoDeTodos()">-->

                            <div class="pull-right">
                                <a id="openConsulta" href="javascript:openConsultaCartaoDeTodos()">
                                    <i class="far fa-search" aria-hidden="true"></i>
                                </a>
                            </div>
                            <label for="matricula">Matrícula</label><br>
                            <input type="text" class="form-control " name="matricula" id="matricula" value="<%=Matricula%>" autocomplete="campo-agenda" no-select2="" datepicker-vazio="">
                        </div>
                        <%
                        end if
                        %>
                       <%= quickField("simpleSelect", "TabelaID", "Tabela", 4, TabelaID, "select id, NomeTabela from tabelaparticular where sysActive=1 and ativo='on' order by NomeTabela", "NomeTabela", " onchange='reloadItens()' " & desabilitarProposta ) %>
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
                                                  <div class="col-md-3">
                                                     <label>Profissional Solicitante</label>
                                                     <%

                                                      if getconfig("profissionalsolicitanteobrigatorioproposta")=1 then
                                                          SolicitanteRequired = " required empty "
                                                      end if
                                                      response.write(quickField("simpleSelect", "ProfissionalID", "", 4, ProfissionalID, "select * from profissionais WHERE "&franquiaUnidade(" id IN (SELECT ProfissionalID FROM profissionais_unidades WHERE UnidadeID IN ('"&session("UnidadeID")&"')) AND ")&" Ativo='on' AND sysActive = 1 order by NomeProfissional", "NomeProfissional", SolicitanteRequired))

                                                      %>
                                                 </div>
                                                    <% IF NOT ModoFranquia THEN %>
                                                      <div class="col-md-3">
                                                           <label>Profissional Executante</label>
                                                           <% ExecucaoRequired = " required empty " %>
                                                            <%=simpleSelectCurrentAccounts("ProfissionalExecutanteID", "5, 8, 2", ProfissionalExecutanteID, ExecucaoRequired&" "&onchangeProfissional&DisabledRepasse, "") %>
                                                       </div>
                                                   <% ELSE %>
                                                      <div class="col-md-3">
                                                          <label>Profissional Executante</label>
                                                          <button type="button" onclick="executadosPacientesPropostas()" class="btn btn-default btn-block">
                                                              <i class="far fa-check-circle"></i> Marcar itens como executado
                                                          </button>
                                                      </div>
                                                      <script>

                                                        var profissionalSelecionado = null;

                                                        function selectExecuteAll(){
                                                            $("[name^=table-select]:checked").each((a,b) =>{

                                                                if(!profissionalSelecionado){
                                                                    let dataVal = $(b).val();
                                                                    $("[data-val="+dataVal+"] .executantes [type='checkbox']").prop("checked",false);
                                                                    $("[data-val="+dataVal+"] .openAllProfissional").slideUp();
                                                                    $("[data-val="+dataVal+"] .openAllProfissional select").each((key,item) => $(item).select2("val",profissionalSelecionado));
                                                                    return;
                                                                }

                                                                let dataVal = $(b).val();
                                                                $("[data-val="+dataVal+"] .executantes [type='checkbox']").prop("checked",true);
                                                                $("[data-val="+dataVal+"] .openAllProfissional").slideDown();
                                                                $("[data-val="+dataVal+"] .openAllProfissional select").each((key,item) => $(item).select2("val",profissionalSelecionado));
                                                            })


                                                            $("#modal-components").modal("hide");
                                                            setTimeout(() =>reloadItens(),500);
                                                        }

                                                        var arr2 = [];
                                                        function executadosPacientesPropostas(){

                                                                arr2 = [];
                                                                let showOption = [];
                                                                $(".openAllProfissional select").each((key,item) =>{
                                                                    let itensRow = {data_val:$(item).parents("tr").attr("data-val"),itens:[]}
                                                                    $(item).find("option").map(function() { itensRow.itens.push(this.value);showOption.push(this.value) })
                                                                    arr2.push(itensRow)
                                                                });

                                                                openModal(`<div>
                                                                      <div class='mb15'>Selecione abaixo os itens que deseja marcar como "Executado":</div>
                                                                      <div class='mb15'>Executante</div>
                                                                     <%=simpleSelectCurrentAccounts("ProfissionalSelecao", "5, 8, 2", ProfissionalSelecao, "  ") %>
                                                                </div><br/><div class="table-select-all"></div>`,"Marcar múltiplas execuções",true,() => {
                                                                      profissionalSelecionado = $("#ProfissionalSelecao").val();
                                                                      selectExecuteAll();
                                                                });

                                                                $("#ProfissionalSelecao option").attr('disabled','disabled')

                                                                showOption && showOption.forEach((item) => {
                                                                    $("#ProfissionalSelecao option[value='"+item+"']").removeAttr('disabled');
                                                                })
                                                                setTimeout(() =>$("#ProfissionalSelecao").select2(),100);
                                                        }

                                                        function _selecionarProf() {
                                                                let profissionalSelecao = $("#ProfissionalSelecao").val();
                                                                let arr = arr2.filter((item) => item.itens.includes(profissionalSelecao))

                                                                let tableData = arr.map((data_val) => {
                                                                    let tag = $(`[data-val=${data_val.data_val}]`);
                                                                    console.log(tag.find("[name^=ItemID]").select2("data")[0].text.trim())
                                                                    let item = tag.find("[name^=ItemID]").select2("data")[0].text.trim();
                                                                    let valorTotal = tag.find("[id^=sub]").text().trim();
                                                                    let val = data_val.data_val;
                                                                    console.log(tag.find("[name^=ProfissionalLinhaID]").select2("data"))
                                                                    let profissionalExecutante = tag.find("[name^=ProfissionalLinhaID]").select2("data")[0].text.trim();

                                                                    return {item,valorTotal,profissionalExecutante,val};
                                                                })

                                                                let trs = tableData.map((item) => {
                                                                    return `<tr>
                                                                                <td><input type="checkbox" value="${item.val}" name="table-select[]" /></td>
                                                                                <td>${item.item}</td>
                                                                                <td>${item.profissionalExecutante}</td>
                                                                                <td style="text-align: right">${item.valorTotal}</td>
                                                                            </tr>`
                                                                }).join("");

                                                                $(".table-select-all").html(`
                                                                    <table class="table table-condensed">
                                                                        <thead>
                                                                            <tr class="primary">
                                                                                <th style="width: 10px"><input type="checkbox"  onchange="selecionarTodosFornencedores(this.checked)" /></th>
                                                                                <th>Item</th>
                                                                                <th>Profissional Executante</th>
                                                                                <th style="text-align: right">Valor Total</th>
                                                                            </tr>
                                                                        </thead>
                                                                        <tbody>
                                                                            ${trs}
                                                                        </tbody>
                                                                    </table>
                                                                `)

                                                            }

                                                        $("body").on("change","#ProfissionalSelecao", _selecionarProf)
                                                        function selecionarTodosFornencedores(value){
                                                            $("[name='table-select[]']").prop("checked",value)
                                                        }
                                                      </script>
                                                   <% END IF  %>
                                                   <div class="col-md-3">
                                                       <label>Status</label>
                                                       <%= quickField("simpleSelect", "StaID", "", 4, StaID, "select * from propostasstatus order by id", "NomeStatus", "semVazio") %>
                                                   </div>
                                                   <div class="col-md-3 hidden motivo">
                                                        <label>Motivo</label>
                                                        <%= quickField("simpleSelect", "MotivoID", "", 4, MotivoID, "select * from propostasmotivostatus WHERE status = 3 order by id", "descricao", "semVazio") %>
                                                   </div>
                                                   <div class="col-md-3 text-right">
                                                    <%=pula%>
                                                    <!-- <a id="btn-gerar-contrato" href="?P=GerarContrato&Pers=1&PropostaID=<%=req("PropostaID")%>&ProfissionalSolicitante=<%=ProfissionalID %>" class="btn btn-default">Gerar contrato</a>-->
                                                    <%
                                                    if isnull(data("InvoiceID")) then
                                                        %>
                                                        <button id="btn-gerar-contrato" class="btn btn-default btn-block" onclick="GerarContrato()" type="button"><i class="far fa-money"></i>  Gerar contrato </button>
                                                        <%
                                                    else
                                                        %>
                                                        <a target="_blank" href="?P=invoice&I=<%=data("InvoiceID")%>&A=&Pers=1&T=C&Ent=" id="btn-gerar-contrato" class="btn btn-default" type="button"> <i class="far fa-external-link"></i> Abrir conta</a>
                                                        <%
                                                    end if
                                                    %>
                                                </div>
</div>
                         <div class="row">

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
                    <input class="form-control dadoProposta" name="TituloItens" id="TituloItens" value="<%=TituloItens%>" style="color: #45AAF2;" <%=desabilitarProposta%>>
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-9">
                            <%= selectInsert("Inserir procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""itens(`S`, 'I', $(this).val()); $(this).val(''); $('#select2-ProcedimentoID-container').html('')"" ", oti, "ConvenioID") %>
                        </div>
                        <div class="col-md-3">
                            <button type="button" onclick="selRap()" class="mt25 btn btn-alert btn-block"><i class="far fa-check"></i> Seleção Rápida</button>
                        </div>
                    </div>
                    <hr class="short alt">
                    <div class="row">
                        <div class="col-xs-12">
                            <%server.Execute("PropostaItens.asp")%>
                        </div>
                    </div>
                </div>
            </div>




            <div class="panel">
                <div class="panel-editbox" style="display:block">
                    <input class="form-control dadoProposta" name="TituloPagamento" id="TituloPagamento" value="<%=TituloPagamento%>" style="color: #45AAF2;" <%=desabilitarProposta%>>
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
                                            <i class="far fa-filter icon-filter bigger-110"></i>
                                            Buscar
                                        </button>
                                    </span>
                                    <%if aut("formapagamentopropostaI")=1 then%>
                                    <span class="input-group-btn">
                                        <a class="btn btn-sm btn-dark tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar formas de pagamento para futuras propostas" data-rel="tooltip" data-placement="top" title="" onclick="modalProFormas('', 0)"><i class="far fa-plus"></i></a>
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
                    <input class="form-control dadoProposta" name="TituloOutros" id="TituloOutros" value="<%=TituloOutros%>" style="color:#45AAF2;" <%=desabilitarProposta%>>
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
                                                <i class="far fa-filter icon-filter bigger-110"></i>
                                                Buscar
                                            </button>
                                        </span>
                                        <span class="input-group-btn">
                                            <a class="btn btn-sm btn-dark tooltip-info" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar outras despesas para futuras propostas" data-rel="tooltip" data-placement="top" title="" onclick="modalProOutros('', 0)">
                                                <i class="far fa-plus icon-plus blue"></i>
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

setTimeout(() => {
        $('[id^=ProfissionalLinhaID]:not([class^="select2"])').each(function (i, obj) {
            $(obj).select2();
        })
    },1000)

	function moneyString (valor){
		if(valor.indexOf(",") < 0){
			return (valor.toString())+",00"
		}else{
			return valor
		}
	}

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

function intersect(a, b) {
  var setB = new Set(b);
  return [...new Set(a)].filter(x => setB.has(x));
}

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
    $("#btn-gerar-contrato").hide();

    gtag('event', 'contrato_gerado', {
        'event_category': 'proposta',
        'event_label': "Botão 'Gerar contrato'",
    });

    propostaSave(false, function() {
        var profissional = document.getElementById("ProfissionalID");
        document.location.href = "?P=GerarContrato&Pers=1&PropostaID=<%=req("PropostaID")%>&ProfissionalSolicitante=" + profissional.options[profissional.selectedIndex].value;
        $("#btn-gerar-contrato").show();
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

function imprimirProposta(Agrupada){
    if($("#PacienteID").val() == ""){
		alert("Selecione um paciente");
		return false;
	}else{
        propostaSave(false, function() {
            $.get("ImprimirProposta.asp?PropostaID=<%=PropostaID%>&Agrupada="+Agrupada, function(data){ $("#modal").html(data) });
        });
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
    }
}

function imprimirPropostaSV(){
	$("#modal-table").modal("show");
	$("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
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
    set PropostaAguardandoDescontoSQL = db_execute("select d.id from descontos_pendentes d INNER JOIN itensproposta i ON i.id= d.ItensInvoiceID*-1 where i.PropostaID="&treatvalzero(PropostaID)&" AND SysUserAutorizado IS NULL AND DataHoraAutorizado IS NULL")
    if not PropostaAguardandoDescontoSQL.eof then
    %>
    procurarAprovacaoDesconto();
    var descontoPendenteInterval = setInterval(procurarAprovacaoDesconto, 10000);
    <%
    end if
    %>
  function toggleLine(id){
        let status = $(".profi"+id).css('display')
        if(status == 'none'){
            $(".profi"+id).slideDown()
        }else{
            $(".profi"+id).slideUp()
        }
    }



    function reloadItensByParent(parents) {
          let Procedimento = parents .find("[id^=ItemID]").val();

          let profissionalID = parents.find("[id^=ProfissionalLinhaID]").val();

          if(!profissionalID){
              profissionalID = "";
          }

          let [AssociationAccountID,AccountID] =profissionalID.split("_");
          let Tabela = $("#TabelaID").val();
          let prom = cacularValorTabela({Procedimento,AssociationAccountID,AccountID,Tabela});
              prom.then((valor) => {
                  return valor;
              });
              prom.then((valor) => parents.find("[id^=ValorUnitario]").val(formatNumber(valor,2)));
              prom.then((valor) => recalc());
    }

var idStr = "#TabelaID";
$('.modal').click(function(){
    $('#select2-TabelaID-container').text("Selecione");
    $('#TabelaID').val(0);
    $('.error_msg').empty();
});

const validarTabela = "<% if ModoFranquia then response.write("true") else response.write("false") end if %>" == "true"

$(idStr).change(function(){


        var id          = $('#TabelaID').val();
        var sysUser     = "<%= session("user") %>";
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


       $(document).ready(() => {
            $(document).on('change', "[id^=ItemID]", function() {
                 let parents = $(this).parents("tr");

                 let procedimentoQuery = this.value;
                 let id = this.id.replace('ItemID','','');
                 let r = parents.find("[id^=ProfissionalLinhaID]").parent().html("");

                 $.get(`PropostaItens.asp?reload=${procedimentoQuery}&id=${id}`,function (data) {
                     r.html(data);
                     parents.find("[id^=ProfissionalLinhaID]").select2();
                     reloadItensByParent(parents)
                 })


                 //
            });

            $(document).on('change', "[id^=ProfissionalLinhaID]", function() {
                  let parents = $(this).parents("tr");
                  reloadItensByParent(parents)
            });
        })

    function formatNumber(num,fix){
        return Number(num).toLocaleString('de-DE', {
         minimumFractionDigits: fix,
         maximumFractionDigits: fix
       });
    }

function reloadItens(){
     $(".proposta-item-procedimentos").each((a,item) =>{
        reloadItensByParent($(item))
    });
}

function cacularValorTabela({Procedimento,Tabela,Unidade="",AssociationAccountID="",AccountID="",Tipo="v"}){
    return $.post("procedimentos/getValores.asp",{Procedimento,Tabela,Unidade,AssociationAccountID,AccountID,Tipo})
    .then((resolve) => JSON.parse(resolve))
    .then((json) =>{
        let num = json[0].Valor;
        return Number(num.replace(".","").replace(",","."))
    });
}

function checkParticularTableFields(){
    if(!$("#TabelaID").val()){
        return true;
    }

    let particularTable = endpointFindValidationRules($("#TabelaID").val());
    if(!particularTable){
        return true;
    }

    if(particularTable.TipoValidacao !== 1)
    {
        return true;
    }

    if(!$("#matricula").val()){
        showMessageDialog("Preencha a campo matrícula","error");
        return false;
    }

    let returnEndpoint = endpointGetMatricula($("#matricula").val());
    let dataFromFeegow = returnEndpoint.data.dados;

    if(!returnEndpoint || !returnEndpoint.data){
            showMessageDialog("Não foi possível validar a matrícula","error");
            return false;
    }

    if(returnEndpoint.data.elegivel && dataFromFeegow.length > 0){
        let encontrado = false;
        $.each(dataFromFeegow,function(index,obj){
            let arrayName = obj.nomeFiliado.split(" ");
            let choosenName = $("#select2-PacienteID-container").text();
            if(!choosenName){
                choosenName = $("#select2-PacienteID2-container").text();
            }
            let arrayChoosenName = choosenName.split(" ");

            if(arrayChoosenName[0].toLowerCase() == arrayName[0].toLowerCase()){
                encontrado = true;
            }
        });
        if(encontrado){
            showMessageDialog("Matricula válida","success");
            return true;
        }

        showMessageDialog("Matricula não pertence a este paciente","error");
        return;

    }else if(returnEndpoint.data && returnEndpoint.data.dados[0] && returnEndpoint.data.dados[0].tipoSituacaoFinanceira === "Inadimplente"){
        showMessageDialog("Matrícula não autorizado","error");
        return;
    }

    showMessageDialog("Matrícula inválida","error");
    return false;
};

function endpointFindValidationRules(idTable) {
    let url = domain+"medical-report-integration/verify-validation-type";
    return $.ajax({
        type: 'POST',
        url: url,
        async: false,
        dataType: 'json',
        data:{"particularTableId":idTable},
        done: function(results) {

        },
        fail: function( jqXHR, textStatus, errorThrown ) {
            console.log( 'Could not get posts, server response: ' + textStatus + ': ' + errorThrown );
        }
    }).responseJSON;
};
function endpointGetMatricula(matricula){
    let url = "https://api.feegow.com.br/autorizador/elegivel/140188/cpf/" + matricula;
    return $.ajax({
        type: 'GET',
        url: url,
        async: false,
        dataType: 'json',
        done: function(results) {

        },
        fail: function( jqXHR, textStatus, errorThrown ) {
            console.log( 'Could not get posts, server response: ' + textStatus + ': ' + errorThrown );
        }
    }).responseJSON;
};
function openConsultaCartaoDeTodos(){
    openComponentsModal("pesquisa-paciente-parceiro.asp",{}, "Consulta de Paciente | Cartão de Todos", true);
}

    $( document ).ready(function() {
        $('#PacienteID').change(()=>{
            let paciente = $("#PacienteID").val()
            $.ajax({
                type:"POST",
                url:"AgendaParametros.asp?tipo=PacienteID&id="+paciente,
                success:function(data){
                    let valorMatricula = data.split('$("#ageMatricula1").val("')[1].split('")')[0]
                    let tabelaID = data.split('$("#ageTabela, #bageTabela").val("')[1].split('")')[0]
                    $('#matricula').val(valorMatricula)
                    $('#TabelaID option[value='+tabelaID+']').attr('selected',true)
                    let texto = $('#TabelaID option[value='+tabelaID+']').html()
                    $('#qftabelaid .select2-selection__rendered').html(texto)
                    $('#qftabelaid .select2-selection__rendered').attr('title',texto)

                    if(validarTabela){
                        checkParticularTableFields()
                    }
                },
                error:function(data){
                }
            });
        })

        if(validarTabela){
            $('#matricula').change(()=>{
                checkParticularTableFields()
            })
            $("#TabelaID").change(()=>{
                checkParticularTableFields()
            })
        }
        Core && Core.init({})
    });
function MarDes(Pro, Che){
    if(Che==1){
        itens('S', 'I', Pro);
    }else{
        $('.pi'+Pro).click();
    }
}

function selRap(){
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10">
                                <center>
                                     <i class="far fa-2x fa-circle-o-notch fa-spin"></i>
                                 </center>
                            </div>`)
    $.post("ProcedimentosRapidos.asp", $(".PIs").serialize(), function(data){
        $("#modal").html(data);
    });
}

    function callRow(paciente){
        $("#matricula").val(paciente.matricula)
        $("#modal-components").modal("hide");
    }

</script>


