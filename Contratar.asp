<!--#include file="connect.asp"-->
<script>
$(".input-mask-cep").keyup(function(){
	getEndereco( $(this).val() );
});
var resultadoCEP;
function getEndereco( cep ) {
	//alert()
	//	alert(($("#Cep").val() *= '_'));
		var temUnder = /_/i.test( cep )
		if(temUnder == false){
			$.getScript("webservice-cep/cep.php?cep="+ cep , function(){
				if(resultadoCEP["logradouro"]!=""){
					$("input[name=Endereco]").val(unescape(resultadoCEP["logradouro"]));
					$("input[name=Bairro]").val(unescape(resultadoCEP["bairro"]));
					$("input[name=Cidade]").val(unescape(resultadoCEP["cidade"]));
					$("input[name=Estado]").val(unescape(resultadoCEP["uf"]));
					$("input[name=Numero]").focus();
				}else{
					$("input[name=Endereco]").focus();
				}
			});				
		}			
}
</script>
<form id="pagto">

 <style>
          .person-option{ border:1px solid #D4D4D4;
		  background: -moz-linear-gradient(top, #fffefc 0%, #e5e5e5 100%); /* FF3.6-15 */
background: -webkit-linear-gradient(top, #fffefc 0%,#e5e5e5 100%); /* Chrome10-25,Safari5.1-6 */
background: linear-gradient(to bottom, #fffefc 0%,#e5e5e5 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#fffefc', endColorstr='#e5e5e5',GradientType=0 ); 
padding:20px 0; text-align:center; margin-bottom:15px;

		  }
		  .wrap-f{ width:90%; margin:15px auto;}
		  .person-option input[type=radio]{display:hidden;}
          
          </style>
          
    <img src="assets/img/logo.png"/><br><br>
    <div class="row text-left">
        <div class="page-header">
            <h1>Dados do Contratante <small> &raquo; Preencha os dados para contratação</small></h1>
        </div>
        <div class="clearfix wrap-f">
          <div class="row">
         
            <div class="col-md-6 person-option"><label><input type="radio" class="ace" name="Tipo" value="F" required><span class="lbl"> Pessoa física</span></label></div>
            <div class="col-md-6 person-option"><label><input type="radio" class="ace" name="Tipo" value="J" required><span class="lbl"> Pessoa jurídica</span></label></div>
          </div>
          <div class="row" style="display:none" id="pf">
            <h4 class="lighter blue">Dados para emissão da Nota Fiscal</h4>
            <%=quickField("text", "Nome", "Nome do Contratante", 8, "", "", "", "")%>
            <%=quickField("text", "CPF", "CPF", 4, "", " input-mask-cpf", "", "")%>
          </div>
          <div class="row" style="display:none" id="pj">
            <h4 class="lighter blue">Dados para emissão da Nota Fiscal</h4>
            <%=quickField("text", "RazaoSocial", "Razão Social", 5, "", "", "", "")%>
            <%=quickField("text", "CNPJ", "CNPJ", 3, "", " input-mask-cnpj", "", "")%>
            <%=quickField("text", "Responsavel", "Resp. Legal", 4, "", "", "", "")%>
		  </div>
          <div class="row" style="display:none" id="divEndereco">
            <%=quickField("text", "Cep", "Cep", 2, "", " input-mask-cep", "", "")%>
            <%=quickField("text", "Endereco", "Endereço", 4, "", "", "", "")%>
            <%=quickField("text", "Numero", "Número", 2, "", "", "", "")%>
            <%=quickField("text", "Complemento", "Complemento", 2, "", "", "", "")%>
            <%=quickField("text", "Bairro", "Bairro", 2, "", "", "", "")%>
            <%=quickField("text", "Cidade", "Cidade", 2, "", "", "", "")%>
            <%=quickField("text", "Estado", "Estado", 1, "", "", "", " maxlength=""2""")%>
            <%=quickField("mobile", "Cel", "Celular", 3, "", "", "", "")%>
            <%=quickField("phone", "Tel", "Telefone", 3, "", "", "", "")%>
            <%=quickField("email", "Email", "E-mail", 3, "", "", "", "")%>
          </div>
        </div>
    </div>
    
    <div class="row text-left" id="divUsuarios">
		<%=server.Execute("ContratarUsuarios.asp")%>
    </div>
    
    <div class="row text-left">
        <div class="col-md-12">

            <table class="table">
				<tbody>
                    <tr>
                        <td colspan="2">
                          <div class="col-md-4">
                            <i class="far fa-credit-card blue"></i> Forma de pagto
                          </div>
                          <div class="col-md-4 btn btn-default">
                            <label><input type="radio" name="Forma" value="C" class="ace"><span class="lbl"> CARTÃO DE CRÉDITO</button><br><small class="green"><i class="far fa-credit-card"></i> Liberação imediata</small></span></label>
                          </div>
                          <div class="col-md-4 btn btn-default">
                            <label><input type="radio" name="Forma" value="B" class="ace"><span class="lbl"> BOLETO BANCÁRIO</button><br><small class="green"><i class="far fa-barcode"></i> Liberação na compensação</small></span></label>
                          </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
     </div>
     <div class="form-actions no-margin text-left" id="cc" style="display:none">
        <div class="page-header">
            <h1>
                Dados do Cartão
                <img src="assets/img/visa.png" width="50">
                <img src="assets/img/mastercard.png" width="50">
            </h1>
        </div>
        <div class="row">
            <%=quickField("text", "Titular", "Nome do Titular (como escrito no cartão)", 6, "", "", "", " autocomplete=""off""")%>
            <%=quickField("text", "NumeroCartao", "Número do Cartão", 6, "", "", "", " autocomplete=""off""")%>
        </div>
        <div class="row">
            <div class="col-md-2">
                <label>Validade</label><br>
                <select name="M" class="form-control">
                    <option value="">MÊS</option>
                    <%
                    c=0
                    while c<12
                        c=c+1
                        %>
                        <option><%=left(ucase(monthName(c)), 3)%></option>
                        <%
                    wend
                    %>
                </select>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <select name="A" class="form-control">
                    <option value="">ANO</option>
                    <%
                    c = year(date())+15
                    a = year(date())
                    while a<=c
                        %>
                        <option><%=a%></option>
                        <%
                        a=a+1
                    wend
                    %>
                </select>
            </div>
            <div class="col-md-2"></div>
            <%=quickField("text", "CVV", "Cód. Segurança", 2, "", "", "", " autocomplete=""off""")%>
        </div>
     </div>
	<div class="row">
        <div class="col-md-12">
	        <iframe id="Aceite" width="100%" height="400" src="ACEITE.htm" frameborder="0" style="border: 1px dashed #ccc; display:none"></iframe>
        </div>
    </div>

    <div class="modal-footer text-left">
        <div class="col-sm-9">
            <label><input type="checkbox" name="Aceito" value="S" required class="ace"><span class="lbl"> Declaro que li e aceito os termos de contratação do Feegow Clinic  &raquo; <button type="button" onClick="$('#Aceite').slideUp('fast');" class="btn btn-xs btn-default blue">Ler o contrato</button>.</span></label>
        </div>
        <div class="col-sm-3">
    		<button id="contratar" class="btn btn-block btn-primary"><i class="far fa-chevron-right"></i> CONTRATAR</button>
        </div>
    </div>
</form>
<script>

$("#pagto").submit(function(){
	$.post("saveContratar.asp", $(this).serialize(), function(data, status){eval(data)});
	return false;
});

/*$("#p, #f").change(function(){
	var v = <%= Valor1 %>;
	var u = parseInt($("#p").val()) + parseInt($("#f").val());
	if(u>9){
		v = <%= Valor2 %>;
	}
	if(u>19){
		v = <%= Valor3 %>;
	}
	$("#mensalidade").html( u*v );
	$("#Valor").val( u*v );
});
*/

$("input[name=Tipo]").click(function(){
	var t = $(this).val();
	if(t=='F'){
		$("#pf").slideDown("fast");
		$("#pj").slideUp("fast");
	}else{
		$("#pj").slideDown("fast");
		$("#pf").slideUp("fast");
	}
	$("#divEndereco").slideDown("fast");
});

$("input[name=Forma]").click(function(){
	if($(this).val()=='C'){
		$("#cc").slideDown("fast");
	}else{
		$("#cc").slideUp("fast");
	}
});

<!--#include file="JQueryFunctions.asp"-->
</script>