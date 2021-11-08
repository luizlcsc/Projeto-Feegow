<!--#include file="connect.asp"-->
<%
EspecialidadeID = req("a")

if req("i")<>"" then
    set pp = db.execute("select * from encaminhamentos where id="& req("i"))
    if not pp.eof then
        EncaminhamentoId = pp("id")
        EspecialidadeID = pp("especialidadeid")
        ConteudoEncaminhamento = pp("descricao")
    end if
else
    set getImpressos = db.execute("select * from encaminhamentosmodelos WHERE Tipo like '|Encaminhamento|' ORDER BY id DESC")
    if not getImpressos.EOF then
        ConteudoEncaminhamento = replaceTags(getImpressos("Conteudo")&"", PacienteID, session("User"), session("UnidadeID"))
    end if

    if EspecialidadeID<>"0" then
        set getEspecialidadeEncaminhada = db.execute("SELECT COALESCE(especialidade, nomeEspecialidade) especialidade FROM especialidades WHERE id="&EspecialidadeID)
        if not getEspecialidadeEncaminhada.eof then
            NomeEspecialidade = getEspecialidadeEncaminhada("especialidade")
        end if
    end if

    ConteudoEncaminhamento = replace(ConteudoEncaminhamento, "[Encaminhamento.Especialidade]", NomeEspecialidade)
end if
%>
<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#encaminhar" id="btnencaminha"><i class="fa fa-hospital-o"></i> Encaminhamentos</a></li>
        <li><a data-toggle="tab" class="hidden" id="btnencaminhamodelos" href="#encaminhamodelos"><i class="fa fa-list"></i> <span class="hidden-480">Modelos</span></a></li>
	</ul>
</div>
<div class="panel-body p25" id="iProntCont">

    <div class="tab-content">
        <div class="row">
            <div class="col-xs-8">
                <div id="encaminhar" class="tab-pane in active">
                <div class="row">
                    <div class="col-md-8">
                        <input type="hidden" id="EncaminhamentoId" value="<%=EncaminhamentoId%>">
                        <input type="hidden" id="EspecialidadeID" value="<%=EspecialidadeID%>">
                        <%response.write(quickField("simpleSelect", "EspecialidadeID", "Especialidade para encaminhamento", 12, EspecialidadeID, "SELECT * FROM especialidades esp WHERE esp.sysActive=1 order by especialidade", "especialidade", "required semVazio disabled"))%>
                    </div>
                </div>
                </div>
                <hr class="short alt" />
                <div class="row">
                    <div class="col-xs-12 sensitive-data">
                        <textarea id="ConteudoEncaminhamento" name="ConteudoEncaminhamento"><%=ConteudoEncaminhamento %></textarea>
                        <input id="ultimoUso" name="ultimoUso" type="hidden" />
                    </div>
                </div>
            </div>
                <div class="col-xs-4 pn">
                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title">
                                <i class="fa fa-file-text-o"></i>
                                Modelos de Encaminhamentos
                            </span>
                            <%' if aut("|modelosencaminhamentosI|")=1 then%>
                            <div class="panel-controls">
                                    <a href="#" onclick="modalEncaminhamento('', 0, id)" class="btn btn-xs btn-dark" data-original-title="Cadastrar modelos de encaminhamentos" data-rel="tooltip" data-placement="top" title="">
                                        <i class="fa fa-plus text-white"></i>
                                    </a>
                            </div>
                            <%'end if%>
                        </div>

                        <div class="panel-menu">
                            <div class="input-group">
                            <input id="FiltroEnc" class="form-control input-sm refina" autocomplete="off" placeholder="Filtrar..." type="text">
                            <span class="input-group-btn">
                            <button class="btn btn-sm btn-default" onclick="ListaEncaminhamentos($('#FiltroEnc').val(), '', '',$('#EspecialidadeID').val())" type="button">
                            <i class="fa fa-filter icon-filter bigger-110"></i>
                            Buscar
                            </button>
                            </span>
                            </div>
                        </div>
                        <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                            <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                                <tbody id="ListaEncaminhamentos">
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

    <div class="text-left mt20">
        <a href="#" class="btn btn-info btn-sm" id="showTimeline">Mostrar/Ocultar Histórico</a>
    </div>
    <div id="conteudo-timeline"></div>
</div>
<div class="panel-footer text-right">
    <button type="button" class="btn btn-primary" id="savePrescription" ><i class="fa fa-save icon-save"></i> Salvar e Imprimir</button>
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

$(function () {

    var config = {
        shiftEnterMode:CKEDITOR.ENTER_P,
        enterMode:CKEDITOR.ENTER_BR,
        height: 200
     };

	$('#ConteudoEncaminhamento').ckeditor(config);

});

$("#savePrescription").click(function(){
	SaveAndPrint(true);
});


function aplicarEncaminhamento(id){
	$.post("PacientesAplicarFormula.asp?Tipo=Enc&PacienteID=<%=PacienteID%>", {id:id}, function(data, status){
        $("#ConteudoEncaminhamento").val($("#ConteudoEncaminhamento").val()+data);
        // $("#EspecialidadeID").val( $("#EspecialidadeID"+id) );
    } );
}

function modalEncaminhamento(tipo, id, PacienteID){
    $("#btnencaminhamodelos").click();
    openComponentsModal('EncaminhamentosTextos.asp', {PacienteID:PacienteID, id:id}, 'Cadastro de Modelo de Encaminhamento')
}

function ListaEncaminhamentos(Filtro, X, Aplicar, Especialidade){
	$.post("ListaEncaminhamentos.asp",{
		   Filtro:Filtro,
		   X: X,
		   Aplicar: Aplicar,
           Especialidade: Especialidade
		   },function(data,status){
	  $("#ListaEncaminhamentos").html(data);
	  Core.init();
		   });
}

$('#FiltroEnc').keypress(function(e){
    if ( e.which == 13 ){
		ListaEncaminhamentos($('#FiltroEnc').val(), '', '','');
		return false;
	}
});

ListaEncaminhamentos('', '', '', $('#EspecialidadeID').val());

function SaveAndPrint(salvarEncaminhamento){
    let EncaminhamentoId = $("#EncaminhamentoId").val();
    $.post("saveEncaminhamento.asp",{
		   PacienteID:'<%=PacienteID%>',
		   receituario:$("#ConteudoEncaminhamento").val(),
		   EspecialidadeID:$("#EspecialidadeID").val(),
           save: salvarEncaminhamento,
           EncaminhamentoId: EncaminhamentoId
		   },function(data,status){
	    $("#modal").html(data);
        $("#modal-table").modal('show');
	});
}

$('#pdfModal').on('hidden.bs.modal', function (e) {
	  $("#modal-table").modal('show');
})

<!--#include file="jQueryFunctions.asp"-->
</script>
