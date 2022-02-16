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


function itens(T, A, II, Q = "", incP = 0, valor, profissionalID){

	var inc = $('[data-val]:last').attr('data-val');
	var PacienteID = $('#PacienteID').val();
    var TabelaID = $('#TabelaID').val();
	if(valor == undefined){ valor = -1 }
	if(profissionalID == undefined){ profissionalID = 0 }
	if(inc==undefined){inc=0}
	if(incP > 0) { inc = incP}

	$('#botao-aplicar-proposta-'+II).attr('disabled',true)

    var $itens = $(".proposta-item-procedimentos").find("[data-resource=procedimentos]");
    var procedimentoIds = [];
    $itens.each(function(){
        procedimentoIds.push($(this).val())
    });


		$.post("propostaItens.asp?I=<%=PropostaID%>&Row="+inc, {procedimentoIds: procedimentoIds.join(","), valor:valor, T:T,A:A,II:II,PacienteID:PacienteID,TabelaID:TabelaID, Q:Q, profissionalID:profissionalID}, function(data, status){

		$('#botao-aplicar-proposta-'+II).attr('disabled',false)
		
		if(A=="I"){
			$("#footItens").before(data);

			let removido = false
			$("[unico]").each((arg,arg1)=>{
			let id = $(arg1).attr("unico");
			if($(`[unico="${id}"]`).length > 1 && !removido){
				removido = true;
				$(`[unico="${id}"]`).last().remove();
				$("#ListaProItens").parent().parent().before(`<div class="text-danger confirm-add" style="padding:5px">Este procedimento não permite duplicidade em propostas.</div>`)
					setTimeout(() => {
						$(".confirm-add").fadeOut();
					},2000);
			}
			});

			if(!removido){
				$("#ListaProItens").parent().parent().before(`<div class="text-success confirm-add" style="padding:5px">Item incluído com sucesso.</div>`)
				$("#FiltroProItens").val("").focus();
				ListaProItens("", '', '')
				setTimeout(() => {
						$(".confirm-add").fadeOut();
				},1000);

			}

		}else if(A=="X"){
			eval(data);
		}else{
			$("#propostaItens").html(data);
		}
	}
);}

function recalc(input){
	$.post("recalcProposta.asp?PropostaID=<%=PropostaID%>&input="+input, $("#frmProposta").serialize(), function(data, status){ eval(data) });
}

function cadastrarOutro(){
	$("#modal-table").modal("show");
	$.post("propostaCadastroOutro.asp", '', function(data, status) { $("#modal").html(data) });
}

function propostaSave(reload, callback){
//	---> Form do paciente.serialize
	if($("#PacienteID").val() == ""){
		alert("Selecione um paciente");
		return false;
	}
	<% if getconfig("profissionalsolicitanteobrigatorioproposta")=1 then %>
	if($("#ProfissionalID").val() == ""){
    	    alert("Selecione um profissional")
    	    return false;
    	}
	<%end if%>

    <% if getconfig("tabelaobrigatorioproposta")=1 then %>
    	if($("#TabelaID").val() == "" || $("#TabelaID").val() == "0"){
        	    alert("Selecione uma tabela")
        	    return false;
        	}
    <%end if%>

		$.post("propostaSave.asp?PropostaID=<%=PropostaID%>", 
		$("#frmProposta").serialize(), 
		function(data){ 
			eval(data);
			if(callback){
			    callback(data);
			}
			/*if (reload){
				location.reload();			
			}else{
				$("#ListaProposta").click();
			}*/
		}).error(function(err){
			showMessageDialog("Ocorreu um erro ao tentar salvar");

		});

}
/*
$("#StaID").on("change",function(){
let disabledimputs = false;
if($("#StaID").val() == 5){
disabledimputs=true;
}

$("#order-tbody").find(':input').each(function(){
  $(this).attr("disabled", disabledimputs);
})

$("#DescontoTotal").attr("disabled", disabledimputs);

});
*/
<%if 1=2 then%><script><%end if%>