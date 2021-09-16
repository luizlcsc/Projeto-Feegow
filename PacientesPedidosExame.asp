﻿<!--#include file="connect.asp"-->
<!--#include file="Classes/Json.asp"-->
<%
ExistePedidoExame="display:none;"
ArquivoAssinado = ""

if req("i")<>"" then
    set pp = db.execute("select * from pacientespedidos where id="& req("i"))
    if not pp.eof then
        PedidoExameId = pp("id")
        PedidoExame = pp("PedidoExame")
        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&req("i"))
        ExistePedidoExame=""

        if Adicional = "assinado" then
            ArquivoAssinado = "display:none;"
        end if
    end if
end if
%>
<style>
.cke_textarea_inline{
    border: 1px solid #b8b8b8;
    border-radius: 3px;
    min-height: 200px;
    padding: 15px;
}


.lista-exames > li {
    background: #ededed;
    padding: 5px;
}

.lista-exames > li:nth-child(odd) { background: #f9f9f9; }

.lista-exames {
    padding-left: 0;
    margin-top: 10px;
}
</style>
<script>
var listagemExames   = <% response.write(recordToJSON(db.execute(" SELECT PacoteID,procedimentos.id,NomeProcedimento,'Exame' Tipo FROM pacotesprontuariositens                     "&chr(13)&_
                                                                 " JOIN procedimentos ON procedimentos.id = pacotesprontuariositens.ItemID                            "&chr(13)&_
                                                                 " WHERE PacoteID in (SELECT id FROM pacotesprontuarios WHERE Tipo = 'pedidoexame' AND sysActive = 1);")))%>
var listagemDeGrupos = <% response.write(recordToJSON(db.execute("SELECT id,Nome FROM pacotesprontuarios WHERE Tipo = 'pedidoexame' AND sysActive = 1 ORDER BY 2;")))%>
</script>

<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#divpedido" id="btnpedido"><i class="far fa-file-text"></i> Pedidos de Exame</a></li>
        <li><a data-toggle="tab" class="hidden" id="btnpedidosmodelos" href="#pedidosmodelos"><i class="far fa-list"></i> <span class="hidden-480">Modelos</span></a></li>
	</ul>
</div>
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
      <div id="divpedido" class="tab-pane in active">
        <div class="row">
            <div class="col-xs-12">
                        <div class="row">
                            <div class="col-md-2">
                                <button type="button" onclick="NovoPedido();" class="btn btn-info btn-block"><i class="far fa-plus icon-plus"></i> Novo</button>
                            </div>
                            <div class="col-md-3">
                                <button type="button" class="btn btn-primary btn-block" id="savePedido" style="<%=ArquivoAssinado%>"><i class="far fa-save icon-save"></i> Salvar e Imprimir</button>
                            </div>
                            <div class="col-md-2">
                                <input type="hidden" id="PedidoExameId" value="<%=PedidoExameId%>">
                                <button type="button" style="<%=ExistePedidoExame%>" class="btn btn-info btn-block" id="printPedido"><i class="far fa-print icon-print"></i> Imprimir</button>
                            </div>
                            <div class="col-md-3 exame-procedimento-content" style="display: none;">
                                <div class="checkbox-custom checkbox-primary">
                                    <input type="checkbox" name="GerarProposta" id="GerarProposta"
                                    value="S" checked/> <label for="GerarProposta">Gerar Proposta</label>
                                </div>
                            </div>
                        </div>
            </div>
            <% IF getConfig("ExamesCheckbox") = "1" THEN %>
                <style>
                        .wid-3{
                            width: 32%;
                            margin-top: 10px;
                        }
                        .wid-2{
                            width: 48%;
                            margin-top: 10px;
                        }
                        .listagem-de-exames{
                            flex-wrap: wrap;
                            display: flex;
                              justify-content: space-evenly;
                        }
                </style>
                <div class="col-xs-12 pn">
                   <h3 style="margin-left: 10px">Exames
                      <span style="float: right" onclick="modalPastas('', 'Lista')">
                          <a href="javascript:void(0)"  class="btn btn-xs btn-dark" data-original-title="Cadastrar modelo de pedido para futuras solicitações" data-rel="tooltip" data-placement="top" title="">
                              <i class="far fa-folder text-white"></i> Gerar Pastas
                          </a>
                      </span>
                   </h3>

                   <div class="listagem-de-exames">

                    </div>
                    <script>
                        var strListagem = "";
                        var strListagemGrupos = listagemDeGrupos.map((grupo) => {
                            var mod = 0;

                            strListagem += `<div class='wid-3' style="border: 1px solid #e2e2e2;" >`
                            strListagem += `<div class="panel panel-widget draft-widget" >
                                              <div class="panel-heading" style="    height: 35px;    border: 1px solid #fff;">
                                                <h4 style="text-align: center">${grupo.Nome.toUpperCase()}</h4>
                                              </div>
                                              <div class="panel-body p10" style="border: none;">`

                            strListagem += listagemExames.filter(i => i.PacoteID === grupo.id).map((item) => {
                                let html = '';
                                 html += `<div class="col-md-6">
                                                <div class="checkbox-custom checkbox-primary">
                                                    <input type="checkbox" name="Exame${item.id}_{grupo.id}" id="Exame${item.id}_${grupo.id}"
                                                    value="S" onclick="changeTexto(${item.id},'${item.Tipo}',this)" /> <label for="Exame${item.id}_${grupo.id}">${item.NomeProcedimento}</label>
                                                </div>
                                          </div>`;


                                return html;
                            }).join("");
                            strListagem += "</div></div></div>"
                        });

                        $(".listagem-de-exames").html(strListagem);

                        function changeTexto(id,tipo,arg) {
                            if(arg.checked){
                                aplicarTextoPedido(id,tipo)
                            }else{
                              $(".ProcedimentoExameID[value="+id+"]").parent().remove()
                            }
                            //
                            //
                        }

                    </script>
                </div>
            <% END IF %>
            <div class="col-xs-8">
                <div class="row">
                    <div class="col-md-12 exame-procedimento-content" id="PedidoExameLista" ><br>
                        <input type="hidden" name="PedidoExameListaID" id="PedidoExameListaID" value="100">

                        <strong>Exames solicitados:</strong>

                        <ul class="lista-exames">
                        <%
                        if req("i")<>"" then
                            while not ProcedimentosPedidoSQL.eof
                                %>
                                <li><input type='hidden' class='ProcedimentoExameID' value='<%=ProcedimentosPedidoSQL("ProcedimentoID")%>'>
                                <label class='titulodesc '><%=ProcedimentosPedidoSQL("NomeProcedimento")%> <i class='ml20 mt5 btn-xs btn btn-info far fa-comment'> </i></label>
                                    <%
                                        styleText = "display:none;"
                                        obsText = ProcedimentosPedidoSQL("Observacoes")
                                        if obsText <> "" then
                                            styleText = ""
                                        end if
                                    %>
                                    <textarea style='float:left;<%=styleText%>' class='obs-exame form-control' placeholder='Observações'><%=obsText %></textarea>
                                    <!--<button onclick="xPedidoExame(<%'ProcedimentosPedidoSQL("ProcedimentoID")%>)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>-->
                                </li>
                                <%
                            ProcedimentosPedidoSQL.movenext
                            wend
                            ProcedimentosPedidoSQL.close
                            set ProcedimentosPedidoSQL=nothing
                        end if
                        %>
                        </ul>
                    </div>
                </div>
                <%
                hiddenTextArea = ""
                if getConfig("DesabilitarTextoPedidoExame")=1 then
                    hiddenTextArea = " hidden"
                end if
                %>

                <div class="row">
                    <div class="col-md-12 sensitive-data <%=hiddenTextArea%>"><br />
                        <textarea id="pedido" name="pedido"><%=PedidoExame %></textarea>
                    </div>
                </div>
            </div>
            <% IF getConfig("ExamesCheckbox") = "0" THEN %>
            <div class="col-xs-4 pn">
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                            <i class="far fa-file-text-o"></i>
                            Modelos de Pedidos de Exame
                        </span>
                        <% if aut("|modelosprontuarioI|")=1 then%>
                        <div class="panel-controls">
                            <a href="#" onclick="modalTextoPedido('', 0)" class="btn btn-xs btn-dark" data-original-title="Cadastrar modelo de pedido para futuras solicitações" data-rel="tooltip" data-placement="top" title="">
                                <i class="far fa-plus text-white"></i>
                            </a>
                                <a href="#" onclick="modalPastas('', 'Lista')" class="btn btn-xs btn-dark" data-original-title="Cadastrar modelo de pedido para futuras solicitações" data-rel="tooltip" data-placement="top" title="">
                                <i class="far fa-folder text-white"></i>
                            </a>
                        </div>
                        <%end if%>
                    </div>
                    <style>
                        #FiltroP.form-control[readonly] {
                            cursor: text;
                            background: white;
                        }
                    </style>
                    <div class="panel-menu">
                        <div class="input-group">
                            <input id="FiltroP" class="form-control input-sm refina" readonly onfocus="this.removeAttribute('readonly');" placeholder="Filtrar..." type="text">
                            <span class="input-group-btn">
                                <button class="btn btn-sm btn-default" onclick="ListaTextosPedidos($('#FiltroP').val(), '', '')" type="button">
                                    <i class="far fa-filter icon-filter bigger-110"></i>
                                    Buscar
                                </button>
                            </span>
                        </div>
                    </div>
                    <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                        <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                            <tbody id="ListaTextosPedidos">
                                <tr>
                                    <td>
                                        Carregando...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <% END IF %>
        </div>
    </div>
    <div class="tab-pane" id="pedidosmodelos">
        Carregando...
    </div>
  </div>
  <div style="display: none;" class="lista-procedimentos-exames"></div>


<div class="text-left mt20">
    <a href="#" class="btn btn-info btn-sm" id="showTimeline">Mostrar/Ocultar Histórico</a>
    </div>
    <div id="conteudo-timeline"></div>

  </div>
</div>
</div>
<script type="text/javascript">

<%
    recursoPermissaoUnimed = recursoAdicional(12)
    if session("User")="14128" or session("Banco")="clinic5351" or session("Banco")="clinic100000" or recursoPermissaoUnimed=4 or true then
    %>
    if('<%=req("IFR")%>'!=="S"){
        $.get("timeline.asp", {PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
            $("#conteudo-timeline").html(data)
        });
    }
    <%
    end if
    %>
    $(function(){
        $("#conteudo-timeline").hide();
        $("#showTimeline").on('click', function(){
            $("#conteudo-timeline").toggle(1000);
        })
    });
function NovoPedido(){
    pedidoCk.setData('');
    $("#printPedido").hide();
    $("#savePedido").show();
}

var pedidoCk = CKEDITOR.inline('pedido', {
    skin: 'office2013',
    floatSpaceDockedOffsetY: 30,
});

var $listaPedidoExames = $(".lista-exames");
var IdsExamesProcedimentos = [];

function aplicarTextoPedido(id, tipo){
	$.post("PacientesAplicarFormula.asp?Tipo=E&PacienteID=<%=PacienteID%>", {id:id, idsAdicionados: IdsExamesProcedimentos,Tipo:tipo}, function(data, status){

	    if(tipo === "Exame"){
            $listaPedidoExames.append("<li><input type='hidden' class='ProcedimentoExameID' value='"+id+"'> <label >"+data+" </label> <a href='#' style='float: right' class='excluiritem btn btn-xs btn-danger ml5'><i class='far fa-remove icon-remove '></i></a> <i  style='float: right' class='titulodesc btn btn-xs btn-info far fa-comment'> </i><textarea style='float:rigth;display:none' class='obs-exame form-control' placeholder='Observações'></textarea>  </li>");
	        $(".exame-procedimento-content").css("display", "");
            $( ".titulodesc" ).unbind("click").on("click", function() {
                $(this).next(".obs-exame").toggle();
            })

            $(".excluiritem").on('click', function(){
                $(this).parent("li").remove();
            })

        }else{
            pedidoCk.setData(pedidoCk.getData()+data);
        }

        $("#FiltroP").val("").focus();
    } );
}

$(function(){
$( ".titulodesc" ).on("click", function() {
    $(this).next(".obs-exame").toggle();
})

})
function modalPastas(tipo, id){
    $.post("pacotesProntuarios.asp?id="+id,{
		   PacienteID:'<%=id%>',
		   Tipo: "pedidoexame"
		   },function(data,status){
		       $("#iProntCont").html(data);
		});
}

function modalTextoPedido(tipo, id){
    $("#btnpedidosmodelos").click();
    $.post("modalTextoPedido.asp?id="+id,{
		   PacienteID:'<%=id%>'
		   },function(data,status){
		       $("#pedidosmodelos").html(data);
		});
}

function xPedidoExame(X) {
    $.post("PacientesPedidosExame.asp?i=" + $("#PedidoExameListaID").val(), {X: X}, function (data) {
        $("#PedidoExameLista").html(data);
    });
}

$("#savePedido").click(function(){
    SaveAndPrint(true);
});

$("#printPedido").click(function(){
    SaveAndPrint(false);
});

function SaveAndPrint(salvarPedido){
    var $idsExames = $listaPedidoExames.find(".ProcedimentoExameID");
    var idsExames = [];
    var $examesObs = $(".obs-exame");
    var examesObs = [];
    let PedidoExameId = $("#PedidoExameId").val();

    $.each($idsExames, function() {
        idsExames.push($(this).val());
    });
    $.each($examesObs, function() {
        examesObs.push($(this).val());
    });

	$.post("savePedido.asp",{
		   PacienteID:'<%=PacienteID%>',
		   pedido:pedidoCk.getData(),
		   idsExames: idsExames,
		   examesObs: examesObs,
           GerarProposta: $("#GerarProposta").is(":checked") ? "S" : "N",
           save : salvarPedido,
           PedidoExameId: PedidoExameId
		   },function(data,status){
	    $("#modal").html(data);
	    $("#modal-table").modal('show');
        $("#printPedido").show();
	});
}



$("#FiltroP").keyup(function(){
    if($(this).val()==''){
        $("#ListaTextosPedidos").html("");
        $.post("ListaTextosPedidos.asp",{
             Filtro:'',
             X: '',
             Aplicar: ''
             },function(data,status){
        $("#ListaTextosPedidos").html(data);
        Core.init();
         });
    }else{
        $("#ListaTextosPedidos").html("");
        $.post("ListaTextosPedidos.asp",{
             Filtro:$(this).val(),
             X: '',
             Aplicar: ''
             },function(data,status){
        $("#ListaTextosPedidos").html(data);
        Core.init();
         });
    }
});


function ListaTextosPedidos(Filtro, X, Aplicar){
	$.post("ListaTextosPedidos.asp",{
		   Filtro:Filtro,
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaTextosPedidos").html(data);
	  Core.init();
		   });
}

$('#FiltroP').keypress(function(e){
    if ( e.which == 13 ){
		ListaTextosPedidos($('#FiltroP').val(), '', '');
		return false;
	}
});

ListaTextosPedidos('', '', '');

$(document).click(function(event) { 
  var $target = $(event.target);
  if(!$target.closest('div[id^="tooltip"]').length && 
  $('div[id^="tooltip"]').is(":visible")) {
    $('div[id^="tooltip"]').hide();
  }
});
</script>