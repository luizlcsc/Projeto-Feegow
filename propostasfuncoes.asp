<%if 1=2 then%><script><%end if%>
function parametros(ElementoID, id){
	$.ajax({
		type:"POST",
		url:"propostaParametros.asp?ElementoID="+ElementoID+"&id="+id,
		data:$("#frmPropostas").serialize(),
		success:function(data){
			eval(data);
			$(".valor").val( $("#Valor").val() );
		}
	});
}


function imprimir(){

}


function itens(T, A, II){
	var inc = $('[data-val]:last').attr('data-val');
	var PacienteID = $('#PacienteID').val();
    var TabelaID = $('#TabelaID').val();

	if(inc==undefined){inc=0}
	$.post("propostaItens.asp?I=<%=PropostaID%>&Row="+inc, {T:T,A:A,II:II,PacienteID:PacienteID,TabelaID:TabelaID}, function(data, status){
	if(A=="I"){
		$("#footItens").before(data);
	}else if(A=="X"){
		eval(data);
	}else{
		$("#propostaItens").html(data);
	}
});}

function recalc(input){
	$.post("recalcProposta.asp?PropostaID=<%=PropostaID%>&input="+input, $("#frmProposta").serialize(), function(data, status){ eval(data) });
}

function cadastrarOutro(){
	$("#modal-table").modal("show");
	$.post("propostaCadastroOutro.asp", '', function(data, status) { $("#modal").html(data) });
}

function propostaSave(){
//	---> Form do paciente.serialize
	if($("#PacienteID").val() == ""){
		alert("Selecione um paciente");
	}else{
		$.post("propostaSave.asp?PropostaID=<%=PropostaID%>", $("#frmProposta").serialize(), function(data){ eval(data) });
	}
}

<%if 1=2 then%><script><%end if%>