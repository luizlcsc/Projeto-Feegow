<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<form id="frm">
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select t.* from "&req("P")&" t where t.id="&req("I"))

set cc = db.execute("select CentroCustoID from "&session("Table")&" where id="& session("idInTable"))
if not cc.eof then
    CentroCustoID = cc("CentroCustoID")
end if

TarefaID=0
RequisicaoID=req("I")
Tipo="Requisicao"

%>
<input type="hidden" name="P" value="estoque_requisicao" />
<input type="hidden" name="I" value="<%= req("I") %>" />

<script type="text/javascript">
    function log(){$('#modal-table').modal('show');$.get('DefaultLog.asp?R=tarefas&I=<%= req("I")%>', function(data){$('#modal').html(data);})}

    $(".crumb-active a").html("Requisição de estoque");
    $(".crumb-icon a span").attr("class", "far fa-tasks");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("<%=subtitulo%>");

    $("#rbtns").html('<a title="Lista" href="?P=ListaRequisicaoEstoque&Pers=1" class="btn btn-sm btn-default"><i class="far fa-list"></i></a> <a title="Novo" href="?P=ListaRequisicaoEstoque&Pers=1&I=N" class="btn btn-sm btn-default"><i class="far fa-plus"></i></a> ');


</script>

    <br />
    <div class="row">
        <div class="col-md-7">
            <div class="panel">
                <div class="panel-heading">
                <%
                if reg("sysActive")=0 then
                    disabled=""'por enquanto nao usa
                    DtPrazo = date()
                    HrPrazo = time()
                    SolicitanteID = session("User")
                else
                    DtPrazo = reg("DataPrazo")
                    SolicitanteID = reg("SolicitanteID")
                    Autorizador = reg("AutorizadorID")
                end if
                %>
                    <span class="panel-title"> Requisição  #<%=req("I")%></span>
                    <span class="panel-controls">
                        <button class="btn btn-sm btn-primary" id="save">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>
                    </span>
                </div>
                <div class="panel-body">


                    <div class="row">
                    <%=quickField("simpleSelect", "SolicitanteID", "Solicitante", 4, SolicitanteID, "select lu.id, usu.Nome from cliniccentral.licencasusuarios lu LEFT JOIN sys_users su on su.id=lu.id LEFT JOIN (SELECT id, Ativo, sysActive, 'profissionais' Tipo, NomeProfissional Nome FROM profissionais UNION ALL SELECT id, Ativo, sysActive, 'funcionarios' Tipo, NomeFuncionario Nome FROM funcionarios) usu ON su.IdInTable=usu.id AND su.Table=usu.Tipo where lu.LicencaID="&replace(session("Banco"), "clinic", "")&" and usu.Ativo='on' and usu.sysActive=1 order by lu.Nome", "Nome", " empty")%>
                    <%=quickfield("simpleSelect", "PrioridadeID", "Prioridade", 4, cstr(reg("PrioridadeID")&""), "select id, Prioridade from cliniccentral.tarefasprioridade order by id", "Prioridade", " semVazio no-select2 ") %>
                    <%=quickfield("simpleSelect", "StatusID", "Status", 4, reg("StatusID"), "select id, NomeStatus from estoque_requisicao_status order by NomeStatus", "NomeStatus", " semVazio no-select2 ") %>
                    <%=quickfield("simpleSelect", "LocalizacaoID", "Localização destino", 4, reg("LocalizacaoID"), "select id, NomeLocalizacao from produtoslocalizacoes order by NomeLocalizacao", "NomeLocalizacao", " semVazio no-select2 ") %>
                    <%=quickField("datepicker", "DataPRazo", "Data Prazo", 4, DtPrazo, "", "", " "& disabled &" ")%>
                    <%=quickField("simpleSelect", "AutorizadorID", "Destinatário", 4, Autorizador, "select lu.id, usu.Nome from cliniccentral.licencasusuarios lu LEFT JOIN sys_users su on su.id=lu.id LEFT JOIN (SELECT id, Ativo, sysActive, 'profissionais' Tipo,  NomeProfissional Nome FROM profissionais UNION ALL SELECT id, Ativo, sysActive, 'funcionarios' Tipo, NomeFuncionario Nome FROM funcionarios) usu ON su.IdInTable=usu.id AND su.Table=usu.Tipo where lu.LicencaID="&replace(session("Banco"), "clinic", "")&" and usu.Ativo='on' and usu.sysActive=1 order by lu.Nome", "Nome", " ")%>
                    </div>
                </div>
            </div>




            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">Produtos</span>
                    <span class="panel-controls">
                        <button type="button" class="btn btn-xs btn-success mn" onclick="tsol('I');"><i class="far fa-plus"></i></button>
                    </span>
                </div>
                <div class="panel-body">
                    <div class="row">
                      <div class="col-md-12" id="TarefasSolicitantes">
                          <% server.execute("RequisicaoEstoqueItens.asp") %>
                      </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-5">
    	    <div class="panel mn">
			    <div class="panel-heading">
				    <span class="panel-title"><i class="far fa-comment blue"></i> Interações</span>
			    </div>


                <div class="panel-body panel-scroller scroller-navbar pn">
                    <div class="tab-content br-n pn">

                      <div id="interacoes" class="tab-pane chat-widget active" role="tabpanel">
                            <%server.Execute("RequisicaoEstoqueInteracoes.asp") %>
                      </div>

                    </div>
                </div>
                <div class="panel-body">
				    <div class="widget-main no-padding">
					    <div class="dialogs" id="">
					    </div>

					    <div class="form-actions" id="divCxInt">
						    <div class="input-group">
							    <textarea placeholder="Digite sua mensagem para interação no chamado..." type="text" class="form-control" name="msgInteracao" id="msgInteracao"></textarea>
								<span class="input-group-addon btn btn-primary" style="background-color:#428bca;" type="button" id="btnInteracao">
									<i class="far fa-send"></i> Enviar</span>
						    </div>
					    </div>

				    </div><!-- /widget-main -->
			    </div><!-- /widget-body -->


            </div>
        </div>
    </div>
</form>
<% if not isnull(reg("sysDate")) then %>
    Requisição criada por <%=nameInTable(reg("sysUser")) %> - <%=reg("sysDate") %>
<% end if %>


<script type="text/javascript">
    $("#btnInteracao").click(function () {
        var frm = $("#frm").serialize();
        $("#msgInteracao").val('');
        $("#btnInteracao").html("<center><i class='far fa-circle-o-notch fa-spin'></i></center>");
        $.post("RequisicaoEstoqueInteracoes.asp?I=<%=req("I")%>&Tipo=<%=Tipo%>", frm, function(data){
            $("#interacoes").html(data);
            $("#btnInteracao").html("<i class='far fa-send'></i> Enviar");
        });
    });

    $("#frm").submit(function () {
        var Solicitantes = "";
        $("input[name^=Solicitante]").each(function () {
            Solicitantes += "," + $(this).val();
        });

        var obsEstoque = "";
        $("[id^='Observacoes-estoque_requisicao']").each(function () {
            obsEstoque +=`${$(this).val()} <br>`;
        });

        obsEstoque = encodeURIComponent(obsEstoque)
        $.post("save.asp?I=<%=req("I")%>", $("#frm").serialize()+"&Solicitantes="+Solicitantes+"&obsEstoque="+obsEstoque, function(data){
            eval(data);
        });
        return false;
    });

    function recalculaTotalRequisicao(totalId, unitarioId, quantidadeId) {
        var $valorTotal = $("#"+totalId),
            $valorUnitario = $("#"+unitarioId),
            $quantidade = $("#"+quantidadeId);

        var valorUnitario = parseFloat($valorUnitario.val().replace(".", "").replace(",", ".")),
            quantidade = parseFloat($quantidade.val().replace(".", "").replace(",", ".")),
            valorTotal = (valorUnitario * quantidade).toFixed(2);

        if(!$.isNumeric(valorTotal)){
            valorTotal=0;
        }

        $valorTotal.val(valorTotal.replace(".", ","));
    }

    function tsol(A) {

        $.post("RequisicaoEstoqueItens.asp?I=<%=req("I")%>&A="+ A, function (data) {
            $("#TarefasSolicitantes").html(data);
        });
    }

    function delItem(ItemID) {
        if(confirm("Tem certeza que deseja excluir esse item?")){

            $.post("RequisicaoEstoqueItens.asp?I=<%=req("I")%>&A=X&X="+ ItemID, function (data) {
                $("#TarefasSolicitantes").html(data);
            });
        }
    }


    $("#staDe, #staPara").change(function(){
        $.get("tarefaSave.asp?I=<%=req("I")%>&onlySta="+$(this).attr("id")+"&Val="+$(this).val(), function(data){
            eval(data);
        });
    });


    function modalEstoque(ProdutoID, LinhaID){
        $("#modal-table").modal("show");
        var LocalizacaoID = $("#LocalizacaoID").val();
        var Quantidade = $("#Quantidade-estoque_requisicao_produtos-"+LinhaID).val();
        var UnidadeID = $("#UnidadeID-estoque_requisicao_produtos-"+LinhaID).val();
        //http://192.168.0.27/feegowclinic/v7/EstoquePosicao.asp?ItemInvoiceID=&ProdutoInvoiceID=&AtendimentoID=&CD=D&I=1
        $.get("EstoquePosicao.asp", {
            CD:"D",
            I: ProdutoID,
            LocalizacaoID: LocalizacaoID,
            Quantidade: Quantidade,
            UnidadeID: UnidadeID
        }, function (data) {
            $("#modal").html( "<div class='modal-body'>"+data+"</div>" );
        });
    }


    function lancar(P, T, L, V, PosicaoID){
        $("#modal").html("Carregando...");
        $.ajax({
            type:"POST",
            url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }
    function dividir(P, T, L, V, PosicaoID, Q){
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.ajax({
            type:"POST",
            url:"EstoqueDist.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&Q="+Q+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }

</script>
<script src="assets/js/estrela.js" type="text/javascript"></script>
<script type='text/javascript'>

</script>