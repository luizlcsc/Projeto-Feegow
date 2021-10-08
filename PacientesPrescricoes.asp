<!--#include file="connect.asp"-->
<%
ExistePrescricao = "display:none;"
ArquivoAssinado = ""

if req("i")<>"" then
    set pp = db.execute("select * from pacientesprescricoes where id="& req("i"))
    if not pp.eof then
        PrescricaoId = pp("id")
        receituario = pp("Prescricao")
        ControleEspecial = pp("ControleEspecial")
        ExistePrescricao = ""

        if Adicional = "assinado" then
            ArquivoAssinado = "display:none;"
        end if
    end if
end if
%>
<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#prescricao" id="btnprescricao"><i class="far fa-flask"></i> <span class="hidden-480">Prescrição</span></a></li>
        <li><a data-toggle="tab" class="hidden" id="btnprescricoesmodelos" href="#prescricoesmodelos"><i class="far fa-list"></i> <span class="hidden-480">Modelos</span></a></li>
        <li><a data-toggle="tab"  href="#Bulas" onclick="ajxContent('Bulas', '', 1, 'Bulas')"><i class="far fa-medkit"></i> <span class="hidden-480">Bulas</span></a></li>
	</ul>

</div>
<div class="panel-body p25" id="iProntCont">

    <div class="tab-content">
      <div id="prescricao" class="tab-pane in active">
          <div class="row">
            <div class="col-md-5">
                <input type="hidden" id="PrescricaoId" value="<%=PrescricaoId%>">
                <button type="button" onclick="novo();" class="btn btn-info"><i class="far fa-plus icon-plus"></i> Nova</button>
                <button type="button" class="btn btn-primary" id="savePrescription" style="<%=ArquivoAssinado%>"><i class="far fa-save icon-save"></i> Salvar e Imprimir</button>
                <button type="button" class="btn btn-info" style="<%=ExistePrescricao%>" id="printPrescription"><i class="far fa-print icon-print"></i> Imprimir</button>
            </div>
            <div class="col-md-2">
	            <div class="checkbox-custom checkbox-primary"><input type="checkbox" name="ControleEspecial" id="ControleEspecial" <%if ControleEspecial="checked" then response.write(" checked ") end if %> /><label for="ControleEspecial">Controle especial</label></div>
            </div>
            <div class="col-md-3 text-right">



                    <div class="btn-group text-left">
			            <button data-toggle="dropdown" class="btn btn-default dropdown-toggle">
				            Grupos
				            <span class="far fa-caret-down icon-on-right"></span>
			            </button>

			            <ul class="dropdown-menu dropdown-default">
                            <%
                            set g = db.execute("select distinct trim(Grupo) Grupo from pacientesmedicamentos where not Grupo like '' "&_
                                                 " UNION ALL "&_
                                                 " select distinct trim(Grupo) Grupo from pacientesformulas where not Grupo like '' "&_
                                                 " order by trim(Grupo) ")
                            while not g.eof
                            %>
				            <li>
					            <a href="javascript:grupo('<%=g("Grupo") %>')"><small> <%=g("Grupo") %></small></a>
				            </li>
                            <%
                            g.movenext
                            wend
                            g.close
                            set g=nothing
                            %>
			            </ul>
		            </div>

            </div>
        </div>
        <hr class="short alt" />
        <div class="row">
	        <div class="col-xs-8 sensitive-data">
		        <textarea id="receituario" name="receituario"><%=receituario %></textarea>
		        <input id="ultimoUso" name="ultimoUso" type="hidden" />
            </div>


            <div class="col-xs-4 pn">
                <div class="panel">
                    <div class="panel-heading">
                      <span class="panel-title">
                            <i class="far fa-flask"></i> Medicamentos / F&oacute;rmulas
                      </span>
                      <div class="panel-controls">
                            <% if aut("|modelosprontuarioI|")=1 then%>
                                <a class="tooltip-info hidden" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar medicamento ou f&oacute;rmula para futuras prescri&ccedil;&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalMedicamento('', 0)">
                                    <i class="far fa-eyedropper icon-plus"></i>
                                </a>
                                <a class="tooltip-info hidden" href="#modal-table" role="button" data-toggle="modal" data-original-title="Cadastrar medicamento ou f&oacute;rmula para futuras prescri&ccedil;&otilde;es" data-rel="tooltip" data-placement="top" title="" onclick="modalMedicamento('', 0)">
                                    <i class="far fa-medkit icon-plus"></i>
                                </a>
                                <a href="#" onclick="modalMedicamento('', 0)" class="btn btn-xs btn-dark" data-original-title="Cadastrar medicamento ou f&oacute;rmula para futuras prescri&ccedil;&otilde;es" data-rel="tooltip" data-placement="top" title="">
                                    <i class="far fa-plus text-white"></i>
                                </a>
                            <%end if%>
                      </div>
                    </div>

                    <div class="panel-menu">

                    


                                <div class="input-group">

                                <select name="TipoMedicamento" id="TipoMedicamento" class="form-control input-sm" style="width: 15%;">
                                    <option value="">Todos</option>
                                    <option value="M">M</option>
                                    <option value="F">F</option>
                                </select>
                                <input id="FiltroMF" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar medicamentos..." type="text" style="width: 65%;margin-left: 10px">
                                <span class="input-group-btn">
                                <button id="btnMF" class="btn btn-sm btn-default" onclick="ListaMedicamentosFormulas($('#FiltroMF').val(), '', '')" type="button">
                                <i class="far fa-filter icon-filter bigger-110"></i>
                                Buscar
                                </button>
                                </span>
                                </div>




                    </div>
                    <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                        <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                            <tbody id="ListaMedicamentosFormulas">
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
    <div class="tab-pane" id="prescricoesmodelos">
        Carregando...
    </div>
    <div id="Bulas" class="tab-pane">
        Carregando...
    </div>

<div class="text-left mt20">
    <a href="#" class="btn btn-default btn-sm" id="showTimeline">Mostrar/Ocultar Histórico <span class="caret ml5"></span></a>
    </div>
    <div id="conteudo-timeline"></div>

  </div>
</div>
<script type="text/javascript">
<%
    recursoPermissaoUnimed = recursoAdicional(12)
    if session("User")="14128" or session("Banco")="clinic5351" or session("Banco")="clinic100000" or recursoPermissaoUnimed=4 or true then
    %>
    if('<%=req("IFR")%>'!=="S" && false){
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
            $.get("timeline.asp", {PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
                $("#conteudo-timeline").html(data)
                $("#conteudo-timeline").toggle(1000);
            });
        })
    });

$(function () {

    var config = {
        shiftEnterMode:CKEDITOR.ENTER_P,
        enterMode:CKEDITOR.ENTER_BR,
        height: 400
     };

	$('#receituario').ckeditor(config);

});


var qtdMedicamentos = 0;

function aplicarFormula(id, Tipo, Uso = 'Indefinido'){
    // var JaTemUso = $("#receituario").val().indexOf("Uso ") > 0;
    // var myRe = new RegExp("Uso ([a-zA-Z]*)", "g");

    // var Uso = myRe.exec($("#receituario").val());
    // if(Uso){
    //     Uso = Uso[1];
    // }

    var JaTemUso = $("#ultimoUso").val() === Uso;

    qtdMedicamentos+=1;

	$.post("PacientesAplicarFormula.asp?PacienteID=<%=PacienteID%>&Uso="+Uso+"&JaTemUso="+JaTemUso+"&Tipo="+Tipo,{
		   id:id,
		   qtdMedicamentos: qtdMedicamentos
		   },function(data,status){
	  			$("#receituario").val($("#receituario").val()+data);
	});

	$("#ultimoUso").val(Uso);
}

function modalMedicamento(tipo, id){
    $("#btnprescricoesmodelos").click();
	$.post("modalMedicamento.asp?tipo="+tipo+"&id="+id,{
		   PacienteID:'<%=PacienteID%>'
		   },function(data,status){
		$("#prescricoesmodelos").html(data);
	});
}

$("#savePrescription").click(function(){
	SaveAndPrint(true);
});

$("#printPrescription").click(function(){
	SaveAndPrint(false);
});

function novo(){
    $('#receituario').val('');
    $("#printPrescription").hide();
    $("#savePrescription").show();
}

function SaveAndPrint(salvarPrescricao){
    let PrescricaoId = $("#PrescricaoId").val();

    $.post("savePrescription.asp",{
		   PacienteID:'<%=PacienteID%>',
		   receituario:$("#receituario").val(),
		   ControleEspecial:$("#ControleEspecial").prop('checked'),
           save: salvarPrescricao,
           PrescricaoId: PrescricaoId
		   },function(data,status){
	    $("#modal").html(data);
        $("#modal-table").modal('show');
        $("#printPrescription").show();
	});
}


$('#FiltroMF').keypress(function(e){
    if ( e.which == 13 ){
		ListaMedicamentosFormulas($('#FiltroMF').val(), '', '');
		return false;
	}
});


//--------------------------------------------

function ListaMedicamentosFormulas(Filtro, X, Aplicar){
	$("#ListaMedicamentosFormulas").html('Buscando...');
	var TipoMedicamento=$("#TipoMedicamento").val();

	$.post("ListaMedicamentosFormulas.asp?Filtro="+Filtro+"&TipoMedicamento="+TipoMedicamento,{
		   X: X,
		   Aplicar: Aplicar
		   },function(data,status){
		       $("#ListaMedicamentosFormulas").html(data);
		       Core.init();
	});
}

function grupo(G){
    $("#FiltroMF").val("Grupo: "+G);
    $("#btnMF").click();
}

ListaMedicamentosFormulas('', '', '');

function bula(M, I){
    $.ajax({
        type:"GET",
        url:"Bulas.asp?M="+M+"&I="+I,
        success:function(data){
            $("#Bulas").html(data);
        }
    });
}


$('#pdfModal').on('hidden.bs.modal', function (e) {
	  $("#modal-table").modal('show');
})



<!--#include file="jQueryFunctions.asp"-->
</script>
