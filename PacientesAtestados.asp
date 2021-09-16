<!--#include file="connect.asp"-->
<%
ExisteAtestado = "display:none;"
redirect = req("redirect")&""
ArquivoAssinado = ""


if req("i")<>"" then
    set pp = db.execute("select * from pacientesatestados where id="& req("i"))
    if not pp.eof then
        AtestadoID = pp("id")
        Atestado = pp("Atestado")
        Titulo = pp("Titulo")
        ExisteAtestado = ""

        if Adicional = "assinado" then
            ArquivoAssinado = "display:none;"
        end if
    end if
end if
%>
<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#divatestado" id="btnatestado"><i class="far fa-hospital-o"></i> Textos e Atestados</a></li>
        <li><a data-toggle="tab" class="hidden" id="btnatestadosmodelos" href="#atestadosmodelos"><i class="far fa-list"></i> <span class="hidden-480">Modelos</span></a></li>
	</ul>
</div>
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
      <div id="divatestado" class="tab-pane in active">
        <div class="row">
            <div class="col-xs-8">
                <div class="row">
                    <div class="col-md-5">
                        <input id="AtestadoID" type="hidden" value="<%=AtestadoID%>">
                        <input type="text" class="form-control" id="TituloAtestado" name="TituloAtestado" value="<%=Titulo %>" />
                    </div>
                    <div class="col-md-2">
                        <button type="button" onclick="novo();" class="btn btn-info btn-block"><i class="far fa-plus icon-plus"></i> Novo</button>
                    </div>
                    <div class="col-md-3">
                        <button type="button" class="btn btn-primary btn-block" id="saveAtestado" style="<%=ArquivoAssinado%>"><i class="far fa-save icon-save"></i> Salvar e Imprimir</button>
                    </div>

                    <div class="col-md-2">
                        <button type="button" style="<%= ExisteAtestado%>" class="btn btn-info btn-block" id="printAtestado"><i class="far fa-print icon-print"></i> Imprimir</button>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 sensitive-data"><br />
                        <%=quickField("editor", "atestado", "Texto", 12, Atestado, "140", "", " id=""atestado"" rows=""6""" )%>
                    </div>
                    <hr class="short alt" />
                </div>
            </div>
            <div class="col-xs-4 pn">
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                            <i class="far fa-file-text-o"></i>
                            Modelos de Textos / Atestados
                        </span>
                        <% if aut("|modelosprontuarioI|")=1 then%>
                        <div class="panel-controls">
                                 <a href="#" onclick="modalTextoAtestado('', 0)" class="btn btn-xs btn-dark" data-original-title="Cadastrar medicamento ou f&oacute;rmula para futuras prescri&ccedil;&otilde;es" data-rel="tooltip" data-placement="top" title="">
                                    <i class="far fa-plus text-white"></i>
                                </a>
                        </div>
                        <%end if%>
                    </div>

                    <div class="panel-menu">
                        <div class="input-group">
                        <input id="FiltroTA" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar..." type="text">
                        <span class="input-group-btn">
                        <button class="btn btn-sm btn-default" onclick="ListaTextosAtestados($('#FiltroTA').val(), '', '')" type="button">
                        <i class="far fa-filter icon-filter bigger-110"></i>
                        Buscar
                        </button>
                        </span>
                        </div>
                    </div>
                    <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                        <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                            <tbody id="ListaTextosAtestados">
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
        </div>
    </div>
    <div class="tab-pane" id="atestadosmodelos">
        Carregando...
    </div>


<div class="text-left mt20">
    <a href="#" class="btn btn-info btn-sm" id="showTimeline">Mostrar/Ocultar Histórico</a>
    </div>
    <div id="conteudo-timeline"></div>

  </div>
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
    })

$(function () {
	CKEDITOR.config.height = 400;
    $('#atestado').ckeditor();
});

function novo(){
    $('#atestado, #TituloAtestado').val('');
    $("#printAtestado").hide();
    $("#saveAtestado").show();
    }

function aplicarTextoAtestado(id){
	$.post("PacientesAplicarFormula.asp?Tipo=A&PacienteID=<%=PacienteID%>", {id:id}, function(data, status){
        $("#atestado").val($("#atestado").val()+data);
        $("#TituloAtestado").val( $("#NomeAtestado"+id).html() );
    } );
/*
	var Atestado = "<p><strong>"+$("#TituloAtestado"+id).html()+"</strong><br /><br />";
	Atestado = Atestado + $("#TextoAtestado"+id).html()+"</p>";
	$("#atestado").val($("#atestado").val()+Atestado);
*/
}

function modalTextoAtestado(tipo, id){
    $("#btnatestadosmodelos").click();
    $.post("modalTextoAtestado.asp?id="+id,{
		   PacienteID:'<%=id%>'
		   },function(data,status){
		       $("#atestadosmodelos").html(data);
		});
}

$("#saveAtestado").click(function(){
	SaveAndPrint(true);
});

$("#printAtestado").click(function(){
	SaveAndPrint(false);
});

function SaveAndPrint(salvarAtestado){
    let AtestadoId = $("#AtestadoID").val();

    $.post("saveAtestado.asp",{
		   PacienteID:'<%=PacienteID%>',
           TituloAtestado: $("#TituloAtestado").val(),
		   atestado:$("#atestado").val(),
           save: salvarAtestado,
           AtestadoId: AtestadoId,
       <%if redirect="false" then%>
           redirect: false,
       <%else%>
           redirect: true,
       <%end if%>
		   },function(data,status){
	    $("#modal").html(data);
        $("#modal-table").modal('show');
        $("#printAtestado").show();
	});
}

function ListaTextosAtestados(Filtro, X, Aplicar){
	$.post("ListaTextosAtestados.asp",{
		   Filtro:Filtro,
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
	  $("#ListaTextosAtestados").html(data);
	  Core.init();
		   });
}



$('#FiltroTA').keypress(function(e){
    if ( e.which == 13 ){
		ListaTextosAtestados($('#FiltroTA').val(), '', '');
		return false;
	}
});

ListaTextosAtestados('', '', '');
</script>
