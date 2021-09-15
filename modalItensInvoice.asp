<!--#include file="connect.asp"-->
<style type="text/css">
.expandRateio {
	display:none;
}
</style>
<%
TipoItem = req("TipoItem")
TipoAcao = req("TipoAcao")
I = ccur(req("I"))
if TipoAcao = "I" then
	NomeAcao = "Inser&ccedil;&atilde;o"
elseif TipoAcao = "E" then
	NomeAcao = "Edi&ccedil;&atilde;o"
end if

if TipoItem="S" then
	NomeTipoItem = "Servi&ccedil;o"
elseif TipoItem="P" then
	NomeTipoItem = "Produto"
elseif TipoItem="O" then
	if ref("T")="C" then
		NomeTipoItem = "Outros Tipos de Receita"
	else
		NomeTipoItem = "Despesa"
	end if
	if ref("T")="C" then
		TabelaCategoria = "sys_financialincometype"
	else
		TabelaCategoria = "sys_financialexpensetype"
	end if
end if


if I=0 then
	ValorUnitario = 0
	Quantidade = 1
	Desconto = 0
else
	set pitem = db.execute("select * from itensinvoice where id="&I)
	if not pitem.eof then
		ProcedimentoID = pitem("ItemID")
		Quantidade = pitem("Quantidade")
		Desconto = pitem("Desconto")
		Descricao = pitem("Descricao")
		CategoriaID = pitem("CategoriaID")
		Valor = pitem("ValorUnitario")
	end if
end if

%>
<form class="" id="formItem" name="formItem">
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><%=NomeAcao&" de "&NomeTipoItem%></h4>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
			<%
			if TipoItem="S" then
				%>
                <div class="row">
                	<div class="col-md-4">
                    	<%
						if I<>0 then
							tags = " readonly='readonly'"
						else
							tags = " required"
						end if
						%>
                    	<%= selectInsert("Procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""parametros(this.id, this.value);""", tags, "") %>
                    </div>
                    <%
                   	response.Write(quickField("text", "Quantidade", "Quantidade", 1, Quantidade, "", "", " readonly='readonly' autocomplete='off'"))
					%>
					<div class="col-md-1"><label>&nbsp;</label><br />
                    	<button onclick="Add(1);" class="btn btn-success btn-block" type="button"><i class="far fa-plus"></i></button>
                    </div>
					<%
					response.Write(quickField("currency", "Valor", "Valor Unit&aacute;rio", 3, Valor, "", "", " required"))
					response.Write(quickField("currency", "Desconto", "Desconto Unit&aacute;rio", 3, Desconto, "", "", ""))
					%>
                </div>

                <div class="row">
                	<div class="col-md-12" id="invoiceItensTabela">
                    	<%server.Execute("invoiceItensTabela.asp")%>
                    </div>
                </div>
                <%
			elseif TipoItem="O" then
				've se tem algum repasse atrelado a esta conta
				classBtnHide = " hidden"
				if I>0 then
					set vcaRat = db.execute("select * from rateiorateios where ItemContaAPagar="&I)
					disableable = " readonly='readonly'"
					classBtnHide = ""
					ItemContaAPagar = I
				end if
				%>
                <div class="row">
                    <%=quickField("text", "Descricao", "Descri&ccedil;&atilde;o", 6, Descricao, "", "", " autocomplete='off' required")%>
                    <div class="col-md-6">
                    	<%=selectInsert("Categoria", "CategoriaID", CategoriaID, TabelaCategoria, "Name", "", "", "")%>
                    </div>
                    <%
					response.Write(quickField("text", "Quantidade", "Quantidade", 2, Quantidade, "", "", " autocomplete='off' required"&disableable))
					response.Write(quickField("currency", "Valor", "Valor Unit&aacute;rio", 3, Valor, "", "", " required"&disableable))
					response.Write(quickField("currency", "Desconto", "Desconto Unit&aacute;rio", 3, Desconto, "", "", ""&disableable))
					if classBtnHide="" and 1=2 then%>
                        <div class="col-md-4"><label>&nbsp;</label><br />
                            <button type="button" class="btn btn-block btn-primary"><i class="far fa-puzzle-piece"></i> Ver Repasses Inclusos</button>
                        </div>
                        <div class="col-md-12">
                        <hr />
							<!--#include file="resultadoRepasses.asp"-->
                        </div>
                        <%
					end if%>
                </div>
				<script language="javascript">
                    <!--#include file="jQueryFunctions.asp"-->
                </script>
                <%
			end if
			%>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
	<button class="btn btn-primary"><i class="far fa-save"></i> Salvar Itens</button>
</div>
</form>

<script language="javascript">
function parametros(tipo, id){
	$.ajax({
		type:"POST",
		url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
		data:$("#formAgenda").serialize(),
		success:function(data){
			eval(data);
			$(".valor").val( $("#Valor").val() );
		}
	});
}

function Add(Q){
	$.ajax({
		type:"POST",
		url:"invoiceItensTabela.asp?Add="+Q+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#formItem").serialize(),
		success:function(data){
			$("#invoiceItensTabela").html(data);
		}
	});
}

function Remove(R){
	$.ajax({
		type:"POST",
		url:"invoiceItensTabela.asp?Remove="+R+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#formItem").serialize(),
		success:function(data){
			$("#invoiceItensTabela").html(data);
		}
	});
}

function AddRepasse(Item, Q, FM){
	$.ajax({
		type:"POST",
		url:"chamaDivRepasses.asp?Add="+Q+"&FM="+FM+"&Item="+Item+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#formItem").serialize(),
		success:function(data){
			$("#divRepasses"+Item).html(data);
		}
	});
}
//corrigir
function RemoveRepasse(Item, R){
	$.ajax({
		type:"POST",
		url:"chamaDivRepasses.asp?Remove="+R+"&Item="+Item+"&I=0&Valor="+$("#Valor").val()+"&Desconto="+$("#Desconto").val(),
		data:$("#formItem").serialize(),
		success:function(data){
			$("#divRepasses"+Item).html(data);
		}
	});
}

$("#formItem").submit(function(){
	$.ajax({
		type:"POST",
		url:"saveItemInvoice.asp?<%=request.QueryString%>",
		data:$("#formItem").serialize(),
		success:function(data){
			eval(data);
		}
	});
	return false;
});
$("#Valor").change(function(){
	$(".valor").val( $(this).val() );
});
$("#Desconto").change(function(){
	$(".desconto").val( $(this).val() );
});
</script>