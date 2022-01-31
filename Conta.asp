<!--#include file="connect.asp"-->

<style type="text/css">
    .btn-print{
        visibility:hidden;
    }
    .lguia:hover .btn-print{
        visibility:visible;
    }
</style>

<%
PacienteID = req("I")
AtendimentoID = req("A")
if isnumeric(AtendimentoID) and AtendimentoID<>"" then
	db_execute("update sys_users set notiflanctos=replace(notiflanctos, '|"&AtendimentoID&"|', '')")
end if
EliminaNotificacao=0
%>

<!--#include file="invoiceEstilo.asp"-->

<%
    've se tem crédito de itens pré-contratados (na verdade ele já ve isso quando lista os itens não executados. se tiver algum não executado ele dá hidden aqu)i
    've se alguma guia ou particular foi lançado hj
'    set vcaHoje = db.execute("select * from ")
%>



        <form method="post" id="FormConta" action="./?P=LanctoRapido&Pers=1&PacienteID=<%=PacienteID%>">

        <div class="bs-component">
            <div class="panel">
                <div class="panel-heading">
                    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab">
                        <li class="active">
                            <a data-toggle="tab" href="#Conta" onclick="$('#ExtratoDireto').html('')">
                                <i class="far fa-money bigger-110"></i>
                                Faturados 
                            </a>
                        </li>

                        <li>
                            <a data-toggle="tab" href="#NaoFaturados" id="tabNaoFaturados">
                                <i class="far fa-exclamation-circle bigger-110"></i>
                                Não faturados
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#ExtratoDireto" id="StatementTab" onclick="extratoDireto('3_<%=PacienteID%>', '<%=dateadd("m", -1, date())%>', '<%=date()%>', '')">
                                <i class="far fa-exchange bigger-110"></i>
                                Extrato
                            </a>
                        </li>
                        <li>
                            <a data-toggle="tab" href="#Informacoes" class="hidden" id="tabInformacoes">
                                <i class="far fa-exclamation-triangle bigger-110"></i>
                                Info.
                            </a>
                        </li>
                        <li class="pull-right">

                <div>


                <%
                set age = db.execute("select ag.id, ag.rdValorPlano, ag.ValorPlano, ag.TipoCompromissoID, proc.NomeProcedimento from agendamentos ag left join procedimentos proc on proc.id=ag.TipoCompromissoID where ag.StaID not in (6,11) and  ag.PacienteID="&PacienteID&" and ag.Data=date(now())")
                if not age.eof then
                    ProcedimentoAgendado = age("NomeProcedimento")
                    FormaPagtoAgendada = age("rdValorPlano")

                    if age("rdValorPlano")="P" then
                        set ConvenioConfigSQL = db.execute("SELECT NaoPermitirGuiaDeConsulta FROM convenios WHERE id="&treatvalzero(age("ValorPlano")))

                        if not ConvenioConfigSQL.eof then
                            NaoPermitirGuiaDeConsulta= ConvenioConfigSQL("NaoPermitirGuiaDeConsulta")
                        end if
                    end if

                    ProcedimentoIDAgendado = age("TipoCompromissoID")
                    if age("rdValorPlano")="V" then
                        if age("ValorPlano")=0 then
                            EliminaNotificacao=1
                        end if
                    else
		                set assoc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&treatvalzero(age("TipoCompromissoID"))&" and ConvenioID="&treatvalzero(age("ValorPlano")))
		                if not assoc.EOF then
			                if assoc("NaoCobre")="S" or assoc("Valor")=0 then
				                EliminaNotificacao=1
			                end if
		                else
			                EliminaNotificacao=1
                        end if
                    end if

                %>
                        <input type="checkbox" class="hidden" id="hiddenLanctoAgenda" name="Lancto" value="<%=age("id")%>|agendamento" checked>
                <%
                end if
                %>

                    Lançar
	                    <%
	                    set PermiteParticularSQL = db.execute("SELECT OcultarLanctoParticular FROM sys_users WHERE id="&session("User"))

	                    ExibeBotaoParticular=True
	                    if not PermiteParticularSQL.eof then
	                        if PermiteParticularSQL("OcultarLanctoParticular")="S" then
	                            ExibeBotaoParticular=False
                            end if
	                    end if

		                if ExibeBotaoParticular and ((aut("areceberpacienteI")) OR (aut("contasareceberI")) OR (aut("aberturacaixinhaI") AND session("CaixaID")<>"")) then
                   '         <a class="btn btn-default btn-sm" id="btnParticular" href="javascript:ajxContent('Invoice', 'N&T=C&Ent=Conta&PacienteID='+$('#PacienteID').val(), '1', 'divHistorico')">
			                %>
                            <button type="button" id="btnParticular" class="btn btn-default btn-sm" name="TipoBotao" value="AReceber">
                                <i class="far fa-money"></i> Particular
                            </button>
                            <%
		                elseif aut("aberturacaixinhaI") AND session("CaixaID")="" then
			                %>
			                <button type="button" id="btnParticular" onClick="alert('Seu caixa está fechado. \n\nAbra seu caixa para realizar lançamentos.')" class="btn btn-default btn-sm" name="TipoBotao" value="AReceber"><i class="far fa-money"></i> Particular</button>
			                <%
		                end if
                        if aut("|guiasI|") then
                        %>

                            <button name="TipoBotao" type="button" id="btnGuiaConsulta" class="btn btn-default btn-sm btn-guia" data-value="GuiaConsulta">
                                <i class="far fa-credit-card"></i> Guia Consulta
                            </button>
                            <button class="btn btn-default btn-sm btn-guia" type="button" id="btnGuiaSADT" name="TipoBotao" data-value="GuiaSADT">
                                <i class="far fa-credit-card"></i> Guia SP/SADT
                            </button>
                            <!--<button class="btn btn-default btn-sm btn-guia" type="button" id="btnGuiaHonorarios" name="TipoBotao" value="GuiaHonorarios">-->
                                <!--<i class="far fa-credit-card"></i> Guia Honorários-->
                            <!--</button>-->

                            <div class="btn-group">
                                        <button id="outrasGuias" class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" aria-expanded="false"><i class="far fa-plus"></i> Outras Guias  <i class="far fa-angle-down icon-on-right"></i></button>
                                        <ul class="dropdown-menu dropdown-danger">
                                        <!--<li><a href="#" id="btnGuiaConsulta" data-value="GuiaConsulta" class="btn-guia"><i class="far fa-plus btn-guia"></i> Consulta</a></li>-->
                                        <!--<li><a href="#" id="btnGuiaSADT" data-value="GuiaSADT" class="btn-guia"><i class="far fa-plus"></i> SP/SADT</a></li>-->
                                        <li><a href="#" id="btnGuiaHonorarios" data-value="GuiaHonorarios" class="btn-guia"><i class="far fa-plus"></i> Honorários</a></li>
                                        <li><a href="#" id="btnGuiaInternacao" data-value="GuiaInternacao" class="btn-guia"><i class="far fa-plus"></i> Sol. Internação</a></li>
                                        </ul>
                                    </div>
                        <%
                        end if

                        if getConfig("PermitirAtendimentoAvulso")=1 then
                        %>
                        <button type="button" class="btn btn-sm btn-default" onClick="infAten('N');"><i class="far fa-stethoscope"></i> Atendimento</button>
                        <%
                        end if
                        %>

                </div>


                        </li>
                    </ul>
                </div>
                <div class="panel-body">
                    <div class="tab-content pn br-n">
                        <div id="Conta" class="tab-pane active widget-box transparent">

        	                <!--#include file="contaNewContent.asp"-->


                        </div>
                        <div id="ExtratoDireto" class="tab-pane">
                            Carregando...
                        </div>
                        <div id="NaoFaturados" class="tab-pane">
                            <!--#include file="NaoFaturados.asp"-->
                        </div>
                        <div id="Informacoes" class="tab-pane">



                <div class="page-header">
                        <h1>Informações <small>&raquo; Recebidas no atendimento</small></h1>
                </div>

        	                <%
			                set Aviso = db.execute("select distinct FormID from buicamposforms where AvisoFechamento=1")
			                while not Aviso.eof
				                set preen = db.execute("select * from buiformspreenchidos where ModeloID="&Aviso("FormID")&" AND PacienteID="&PacienteID&" order by DataHora desc")
				                while not preen.eof
					                set campos = db.execute("select * from buicamposforms where AvisoFechamento=1 AND FormID="&Aviso("FormID"))
					                while not campos.EOF
						                Titulo = campos("RotuloCampo")
						                Data = preen("DataHora")
						                NomeProfissional = nameInTable(preen("sysUser"))
						                set val = db.execute("select * from _"&Aviso("FormID")&" where id="&preen("id"))
						                if not val.eof then
                                            set vcaCampo = db.execute("select i.table_name from information_schema.`COLUMNS` i where i.TABLE_SCHEMA='"&session("banco")&"' and i.TABLE_NAME='_"&Aviso("FormID")&"' and i.COLUMN_NAME='"&campos("id")&"'")
                                            if not vcaCampo.eof then
							                    Valor = val(""&campos("id")&"")
							                    if not isnull(Valor) and Valor<>"" then
								                    if campos("TipoCampoID")=4 or campos("TipoCampoID")=5 or campos("TipoCampoID")=6 then
                                                        valorIds=replace(Valor, "|", "")

                                                        if valorIds<>"nao" then
                                                            set opcoes = db.execute(" select group_concat(Nome separator '<br>') Valor from buiopcoescampos where id in("&valorIds&")")
                                                            if not opcoes.eof then
                                                                Valor = opcoes("Valor")
                                                            end if
                                                        end if
                                                    elseif  campos("TipoCampoID")=16 then
                                                        set pcid = db.execute("select * from cliniccentral.cid10 where id = '"&Valor&"'")
                                                        if not pcid.eof then
                                                            Valor = pcid("Codigo") &" - "& pcid("Descricao")
                                                        end if
								                    end if
								                    Tem = 1

								                    Valor=Valor&""

                                                    Valor = Replace(Valor, chr(10), "")
                                                    Valor = Replace(Valor, chr(13), "<br>")

                                                    if Data<>"" then
                                                        if formatdatetime(Data, 1)=formatdatetime(date(),1) then
                                                            Data = "Hoje"

                                                            Titulo = replace(Titulo, "'", "")
                                                            %>
                                                            <script>
                                                                $("#tabInformacoes").addClass("red");
                                                                var valor = `<%=Valor%>`;
                                                                $.gritter.add({
                                                                    title: '<i class="far fa-exclamation-triangle"></i> <%=Titulo%>',
                                                                    text: valor,
                                                                    time: 50000,
                                                                    class_name: 'gritter-error gritter-light'
                                                                });
                                                            </script>
                                                            <%
                                                        end if
                                                    end if
								                    %>
								                    <h4><%=Titulo%> &raquo; <small><%=Data%> por <%=NomeProfissional%></small></h4>
								                    <%=Valor%>
								                    <hr>
								                    <%
                                                end if
							                end if
						                end if
					                campos.movenext
					                wend
					                campos.close
					                set campos = nothing
				                preen.movenext
				                wend
				                preen.close
				                set preen=nothing
			                Aviso.movenext
			                wend
			                Aviso.close
			                set Aviso = nothing
			                if Tem=1 then
				                %>
                                <script>
                                $('#tabInformacoes').removeClass('hidden');
				                </script>
                                <%
			                end if
			                %>
                        </div>
                    </div>
                </div>
        </div>
        </form>
        <div id="verificacaoIntegracaoLaboratorial" style="float: right;">  </div>

<%'="{"& creditosII &"}"%>
<%'"{"& GuiasEmitidas &"}"%>
<script type="text/javascript">
$(document).ready(function(){
    //<%=EliminaNotificacao%>
    <%
    if EliminaNotificacao=1 then
        %>
        $("#NotificacaoLancto").addClass("hidden");
        // $("#hiddenLanctoAgenda").removeAttr("checked");
        // $("#hiddenLanctoAgenda").prop("checked", false);
        $("#hiddenLanctoAgenda").remove();
        <%
    else
        if FormaPagtoAgendada="V" then
            %>
            $("#btnParticular").addClass("btn-warning");
            <%
            elseif FormaPagtoAgendada="P" then
            %>
            $("#btnGuiaConsulta, #btnGuiaSADT, #outrasGuias").addClass("btn-warning");
            <%

            if NaoPermitirGuiaDeConsulta=1 then
                %>
                $("#btnGuiaConsulta").attr("disabled", true);
                <%
            end if
        end if
    end if
    %>
});

$(".btn-guia").click(function(){
    $.post("LanctoRapido.asp?Pers=1&PacienteID=<%=PacienteID%>&TipoBotao="+$(this).attr("data-value"), $("#FormConta").serialize(), function(data){
        $("#divHistorico").html(data);
    })
});

function listaRecibos(InvoiceID) {
    openComponentsModal("listaRecibos.asp", {
        InvoiceID: InvoiceID
    }, "Recibos Gerados", true);
}

    <%if (aut("areceberpacienteI")) OR (aut("contasareceberI")) OR (aut("aberturacaixinhaI") AND session("CaixaID")<>"") then%>
$("#btnParticular").click(function () {
    btnToggleLoading("btnParticular",false,true)
    $.post("LanctoRapido.asp?Pers=1&PacienteID=<%=PacienteID%>", $("input[name=Lancto]").serialize()+"&tt=hh&TipoBotao=AReceber", function (data) {
        $("#divHistorico").html(data);
    });
});
    <%end if%>


function anexa(){
    $("#btnAnexa").css("visibility", "visible");
}

$("#btnFatAgendamento").click(function(){
    $("#divFatAgendamento").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.get("AgendamentosFaturar.asp?PacienteID=<%=PacienteID%>", function(data){
        $("#divFatAgendamento").html(data);
    });
});

function modalEstoqueAtend(AtendimentoID){
    $("#modal-table").modal("show");
    $.post("atendimentoEstoque.asp?AtendimentoID="+ AtendimentoID+"&CD=C", {}, function (data) {
        $("#modal").html( data );
    });
}

function modalEstoque(ItemInvoiceID, ProdutoID, ProdutoInvoiceID){
    $("#modal-table").modal("show");
    $.get("invoiceEstoque.asp?CD=<%=CD%>&I="+ ProdutoID +"&ItemInvoiceID="+ ItemInvoiceID + "&ProdutoInvoiceID=" + ProdutoInvoiceID, function (data) {
        $("#modal").html( data );
    });
}

function lancar(P, T, L, V, PosicaoID, ItemInvoiceID, AtendimentoID) {
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.ajax({
        type:"POST",
        url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID +"&ItemInvoiceID=" + ItemInvoiceID + "&AtendimentoID="+ AtendimentoID,
        success: function(data){
            setTimeout(function(){
                if ($("div-secundario").length == 0 ){
                    $("#modal").html(data);
                } else {
                    $("div-secundario").html(data);
                }
            }, 500);
        }
    });
}
function btnToggleLoading(target,state, force, waitMessage="Aguarde...") {
  var $el = $('#'+target), timeout= state ?  500 : 0;


  setTimeout(function() {
    if($el.attr("data-force-disabled") !== 'true' || force){
          if(state){
              $el.attr('disabled', false).html("<i class='far fa-save'></i> Salvar", false);
          }else{
              $el.attr('disabled', true).html("<i class='far fa-circle-o-notch fa-spin'></i> "+waitMessage, true);
          }
      }
  }, timeout);
}

function verificaServicoIntegracaoLaboratorial()
{
   var integracaook = '<span class="badge badge-success">Int. Laboratorial on-line</span>';
   var integracaooff = '<span class="badge badge-danger">Int. Laboratorial off-line</span>';   
   $.ajax({
        type:"POST",
        url: labServiceURL+"api/labs-integration/verifica-servico",
        error: function(data){
            setTimeout(function(){
                $("#verificacaoIntegracaoLaboratorial").html(integracaooff);
                $('button[id^="btn-abrir-integracao-"]').prop('disabled', true);
            }, 500);
        },
        success: function(data){
            setTimeout(function(){
                $("#verificacaoIntegracaoLaboratorial").html(integracaook);
                $('button[id^="btn-abrir-integracao-"]').prop('disabled', false); 
            }, 500);
        }
    });
      
}
<% if verificaSevicoIntegracaoLaboratorial("")= "1|2" then %>
 verificaServicoIntegracaoLaboratorial();
<% end if %>

</script>