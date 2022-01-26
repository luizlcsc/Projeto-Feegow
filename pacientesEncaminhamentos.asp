<!--#include file="connect.asp"-->
<%
if req("i")<>"" then
    set pp = db.execute("select * from encaminhamentos where id="& req("i"))
    if not pp.eof then
        EncaminhamentoId = pp("id")
    end if
end if
%>
<div class="panel-heading">
    <ul>
        <li class="active"><i class="fa fa-file-archive-o"></i> <span class="hidden-480">Encaminhamento</span></li>
	</ul>

</div>
<div class="panel-body p25" id="iProntCont">

    <div class="tab-content">
        <div id="prescricao" class="tab-pane in active">
          <div class="row">
            <div class="col-md-4">
                <input type="hidden" id="EncaminhamentoId" value="<%=EncaminhamentoId%>">
                <%response.write(quickField("simpleSelect", "especialidadeID", "Especialidade para encaminhamento", 12, id, "SELECT * FROM especialidades esp WHERE esp.sysActive=1 order by especialidade", "especialidade", "required"))%>
            </div>
          </div>
        </div>
        <hr class="short alt" />
        <div class="row">
	        <div class="col-xs-12 sensitive-data">
		        <textarea id="receituario" name="receituario"><%=receituario %></textarea>
		        <input id="ultimoUso" name="ultimoUso" type="hidden" />
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

	$('#receituario').ckeditor(config);

});

$("#savePrescription").click(function(){
	SaveAndPrint(true);
});

function SaveAndPrint(salvarEncaminhamento){
    let EncaminhamentoId = $("#EncaminhamentoId").val();
    $.post("saveEncaminhamento.asp",{
		   PacienteID:'<%=PacienteID%>',
		   receituario:$("#receituario").val(),
		   EspecialidadeID:$("#especialidadeID").val(),
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
