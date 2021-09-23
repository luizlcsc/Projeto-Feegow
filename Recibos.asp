<!--#include file="connect.asp"-->

<%
if req("X")<>"" then
    db_execute("delete from recibos where id="&req("X"))

else


PacienteID = req("PacienteID")
set pac = db.execute("select * from pacientes where id="&PacienteID)
if not pac.eof then
	Nome = pac("NomePaciente")
end if

set AgendamentoSQL = db.execute("SELECT proc.NomeProcedimento, age.ProfissionalID,age.Data,IF(age.rdValorPlano='P',0,age.ValorPlano)Valor FROM agendamentos age INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID WHERE age.Data = CURDATE() AND age.PacienteID="&PacienteID)

Data = date()
Valor = 0
Servicos=""

if not AgendamentoSQL.eof then
    Emitente = AgendamentoSQL("ProfissionalID")
    Servicos = AgendamentoSQL("NomeProcedimento")
    Data = AgendamentoSQL("Data")
    Valor = AgendamentoSQL("Valor")
end if

%>
<div class="panel">
<div class="row">
<div class="col-md-12">
<div class="panel-heading">
    <span class="panel-title">
        Recibos
    </span>
</div>
<div class="panel-body">
<form id="frm-recibo">
<div class="row">
    <input type="hidden" name="PacienteID" value="<%=PacienteID%>">
	<%=quickField("simpleSelect", "EmitenteRecibo", "Profissional", 4, Emitente, "select * from profissionais where sysActive=1 order by NomeProfissional", "NomeProfissional", " required")%>
    <%=quickField("text", "NomeRecibo", "Recebido de", 5, Nome, "", "", " required")%>
    <%=quickField("currency", "ValorRecibo", "Valor", 3, Valor, "", "", " required")%>
    <%=quickField("datepicker", "DataRecibo", "Data", 3, Data, "", "", " required")%>
    <%=quickField("text", "ServicosRecibo", "Servi&ccedil;os", 5, Servicos, "", "", " required")%>
    <div class="col-md-2">
    <label>&nbsp;</label><br>
        <button class="btn btn-sm btn-warning btn-block" id="GerarRecibo"><i class="far fa-search-plus"></i> Gerar</button>
    </div>
    <div class="col-md-2">
    <label>&nbsp;</label><br>
        <button type="button" class="btn btn-sm btn-info btn-block" id="saveRecibo"><i class="far fa-print"></i> Imprimir</button>
    </div>
</div>
<hr>
<div class="row">
	<div class="col-md-8">
	    <%=quickField("editor", "TextoRecibo", "Conte&uacute;do gerado <small>(Preencha acima e clique em GERAR)</small>", 12, Texto, "400", "", "")%>
    </div>
    <div class="col-md-4" id="listarecibos" >
		<!--#include file="ReciboLista.asp"-->
    </div>

</div>
</form>
</div>
</div>
</div>
<div id="RetornoRecibo"></div>
<script language="javascript">
var ReciboId=0;
function getRecibo(id){
	$.ajax({
		type:"POST",
		url:"getRecibo.asp?ReciboID="+id,
		success:function(data){
			ReciboId = id;
			$("#RetornoRecibo").html(data);
		}
	});
}

$("#frm-recibo").submit(function(){
	$.ajax({
		type:"POST",
		url:"GeraRecibo.asp",
		data:$(this).serialize(),
		success:function(data){
			$("#TextoRecibo").val(data);
		}
	});
	return false;
});

$("#saveRecibo").click(function(){
	$.ajax({
		type:"POST",
		url:"saveRecibo.asp?I=<%=req("PacienteID")%>",
		data:$("#frm-recibo").serialize(),
		success:function(data){
			$("#modal").html(data);
			$("#modal-table").modal('show');
			updateListaRecibos();
		}
	});
});

function updateListaRecibos()
{
	$.ajax({
		type:"POST",
		url:"ReciboLista.asp?update=1&I=<%=req("PacienteID")%>",
		data:[],
		success:function(data){
			$("#listarecibos").html(data);
		}
	});
}

function deleteRecibo(idRecibo)
{
	if(confirm('Tem certeza de que deseja excluir este recibo?'))
	{
		$.ajax({
			type:"POST",
			url:"Recibos.asp?&PacienteID=<%=PacienteID %>&X="+idRecibo,
			data:[],
			success:function(data){
				updateListaRecibos();

				if(ReciboId === idRecibo)
					$("#TextoRecibo").val("")
			}
		});
	}
}

<!--#include file="jQueryFunctions.asp"-->
</script>
<%
end if
%>