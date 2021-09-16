<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
DominioID = req("I")
Tipo = req("T")
Acao = req("A")

if Tipo = "" then
	Titulo = "Regra Geral de repasse"
else
	Titulo = "Exce&ccedil;&atilde;o por "&Tipo
end if

if DominioID<>"" then
	set dominio = db.execute("select * from rateiodominios where id="&DominioID)
	if not dominio.eof then
		Procedimentos = dominio("Procedimentos")
		Profissionais = dominio("Profissionais")
		Formas = dominio("Formas")
	end if
else
	set vcaInativo = db.execute("select * from rateiodominios where dominioSuperior="&Acao&" and Tipo='"&Tipo&"' and sysActive=0")
	if not vcaInativo.eof then
		DominioID = vcaInativo("id")
	else
		db_execute("insert into rateiodominios (Tipo, dominioSuperior, sysUser, sysActive) values ('"&Tipo&"', '"&Acao&"', '"&session("User")&"', 0)")
		set pult = db.execute("select id from rateiodominios where sysUser="&session("User")&" and sysActive=0 order by id desc LIMIT 1")
		
		DominioID = pult("id")
		'pega as funcoes do dominio superior e duplica
		set funSup = db.execute("select * from rateiofuncoes where DominioID like '"&Acao&"'")
		while not funSup.eof
			db_execute("insert into rateiofuncoes (Funcao, DominioID, tipoValor, Valor, ContaPadrao, sysUser, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysActive) values ('"&rep(funSup("Funcao"))&"', '"&DominioID&"', '"&rep(funSup("tipoValor"))&"', "&treatvalzero(funSup("Valor"))&", '"&rep(funSup("ContaPadrao"))&"', '"&session("User")&"', "&treatvalzero(funSup("Sobre"))&", '"&rep(funSup("FM"))&"', '"&rep(funSup("ProdutoID"))&"', "&treatvalzero(funSup("ValorUnitario"))&", "&treatvalzero(funSup("Quantidade"))&", 0)")
		funSup.movenext
		wend
		funSup.close
		set funSup=nothing
	end if
	response.Redirect("modalRateioFuncoes.asp?T="&Tipo&"&I="&DominioID&"&A=E")
end if
%>
<form method="post" action="" name="frmModal" id="frmModal">
<div class="modal-header">
    <h4>Fun&ccedil;&otilde;es para Repasse - <%=Titulo%></h4>
</div>
<div class="modal-body">
    <div class="row">
    <%
	if Tipo="Profissional" then
		response.Write(quickField("multiple", "Profissionais", "Especialidades / Profissionais", 12, Profissionais, "select * from (	select concat('ESP', esp.id) id, concat('    > ', esp.especialidade) NomeProfissional from especialidades esp 	left join profissionais prof on prof.EspecialidadeID=esp.id where not isnull(prof.id)	group by esp.id		UNION	select id, NomeProfissional from profissionais where sysActive=1 AND Ativo='on' order by NomeProfissional) t", "NomeProfissional", " required"))
	elseif Tipo="Procedimento" then
		response.Write(quickField("multiple", "Procedimentos", "Grupos de procedimentos / Procedimentos", 12, Procedimentos, "select (id * -1)id, concat('     >> ', NomeGrupo) NomeProcedimento from procedimentosgrupos where sysActive UNION ALL select id, NomeProcedimento from procedimentos where sysActive=1 AND Ativo='on' order by NomeProcedimento", "NomeProcedimento", " required"))
	elseif Tipo="Forma" then
		%>
		<div class="col-md-6">
        	<div class="row">
            	<div class="col-md-12">
		        	<div class="checkbox-custom checkbox-primary"><input type="checkbox" name="Formas" id="FormaParticular" value="|P|"<% If instr(Formas, "|P|")>0 Then %> checked="checked"<% End If %> /><label for="FormaParticular"> Todas as formas no particular</label></div>
                </div>
            </div>
            <div class="row">
            	<div class="col-md-12">
                	<label>Ou somente as formas abaixo</label><br />
                    <select multiple class="multisel tag-input-style" id="FormasParticular" name="Formas">
                    <%
					set forma = db.execute("select f.*, m.PaymentMethod from sys_formasrecto f left join sys_financialpaymentmethod m on m.id=f.MetodoID order by PaymentMethod")
					while not forma.eof
                        if forma("MetodoID")=1 OR forma("MetodoID")=2 OR forma("MetodoID")=7 then
                            %>
                            <option value="|P<%=forma("id")%>_0|"<%if instr(Formas, "|P"&forma("id")&"_0|")>0 then%> selected="selected"<%end if%>><%=forma("PaymentMethod")%>: De <%=forma("ParcelasDe")%> a <%=forma("ParcelasAte")%> parcelas</option>

                            <%
                        else
						    spl = split(forma("Contas"), ", ")
						    for i=0 to ubound(spl)
							    if spl(i)<>"" then
								    conta = replace(spl(i), "|", "")
								    if isnumeric(conta) then
									    set contas = db.execute("select * from sys_financialcurrentaccounts where id="&conta)
									    if not contas.eof then
										    %>
										    <option value="|P<%=forma("id")%>_<%=contas("id")%>|"<%if instr(Formas, "|P"&forma("id")&"_"&contas("id")&"|")>0 then%> selected="selected"<%end if%>><%=forma("PaymentMethod")%> - <%=contas("AccountName")%>: De <%=forma("ParcelasDe")%> a <%=forma("ParcelasAte")%> parcelas</option>
										    <%
									    end if
								    end if
							    end if
						    next
                        end if
					forma.movenext
					wend
					forma.close
					set forma=nothing
					%>
                    </select>
            	</div>
            </div>
        </div>

        <div class="col-md-6">
        	<div class="row">
				<div class="col-md-12">
		        	<div class="checkbox-custom checkbox-primary"><input type="checkbox" class="ace" name="Formas" id="FormaTodosConvenios" value="|C|"<% If instr(Formas, "|C|")>0 Then %> checked="checked"<% End If %> /><label for="FormaTodosConvenios"> Todos os Conv&ecirc;nios</label></div>
                </div>
            </div>
            <div class="row">
            	<%= quickField("multiple", "Formas", "Ou somente os Conv&ecirc;nios", 12, Formas, "select * from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "") %>
            </div>
        </div>
		<%
	end if
	%>
    </div>
    <hr />
	<%
    if DominioID="" then
		%>
        <div class="row">
    	<%=quickField("text", "Quantidade", "Quantidade de Fun&ccedil;&otilde;es", 3, 1, "", "", " autocomplete='off' onkeyup='quantidade(this.value);' maxlength='2' required")%>
        </div>
        <hr />
		<%
	else
		%>
		<div class="row">
		<div class="col-md-2">

            <div class="btn-group">
            <button class="btn btn-sm btn-primary dropdown-toggle" data-toggle="dropdown"><i class="far fa-plus"></i> Adicionar <i class="far fa-angle-down icon-on-right"></i></button>
            <ul class="dropdown-menu dropdown-danger">
            <li><a href="javascript:adicionaItem('Adicionar', 0, 'F')">Fun&ccedil;&atilde;o ou regra</a></li>
            <li><a href="javascript:adicionaItem('Adicionar', 0, 'M')">Material ou medicamento</a></li>
            <li id="divMedkit"><a href="javascript:adicionaItem('Adicionar', 0, 'K')"><i class="far fa-medkit"></i> Materiais vinculados ao procedimento, caso haja</a></li>
            <li id="divEstoque"><a href="javascript:adicionaItem('Adicionar', 0, 'Q')"><i class="far fa-medkit"></i> Materiais baixados no estoque</a></li>
            <li id="divUsers"><a href="javascript:adicionaItem('Adicionar', 0, 'E')"><i class="far fa-users"></i> Equipe vinculada ao procedimento, caso haja</a></li>
            </ul>
            </div>

        </div>
        </div>
		<%
	end if
	%>
    <div class="row" id="FuncoesRateio">
    	<%server.Execute("FuncoesRateio.asp")%>
    </div>

<div class="row">
    <div class="col-md-12 mt15" style="max-height: 250px; overflow-y: scroll">

    <%
    LogFuncoesSQL = renderLogsTable("rateiofuncoes", 0, DominioID)
    %>
        </div>

    </div>
</div>
<div class="modal-footer">
	<button class="btn btn-success btn-sm"><i class="far fa-save"></i> Salvar</button>
    <button class="btn btn-sm btn-default" data-dismiss="modal">
    	<i class="far fa-remove"></i> Fechar</button>
    </button>
</div>
</form>
<script type="text/javascript">

<!--#include file="jQueryFunctions.asp"-->

$("#frmModal").submit(function(){
	$.ajax({
		   type:"POST",
		   url:"saveFuncoesRateio.asp?DominioID=<%=DominioID%>&Tipo=<%=Tipo%>&Acao=<%=Acao%>&Linear=<%=req("Linear")%>",
		   data:$("#frmModal").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });
	return false;
});

function quantidade(Q){
	$.ajax({
		type:"POST",
		url:"FuncoesRateio.asp?Q="+Q+"&T=<%=Tipo%>&I=<%=DominioID%>&A=<%=Acao%>",
		data:$("#frmModal").serialize(),
		success:function(data){
			$("#FuncoesRateio").html(data);
		}
	});
}

function removeItem(Tipo, ItemID){
	if(Tipo=='Item'){
		var msg = 'Tem certeza de que deseja excluir este item?';
	}else{
		var msg = 'Tem certeza de que deseja excluir todos os itens listados acima?';
	}
	if(confirm(msg)){
			   $.ajax({
			   type:"POST",
			   url:"funcoesRateioRemoveItem.asp?Tipo="+Tipo+"&DominioID=<%=DominioID%>&ItemID="+ItemID,
			   success:function(data){
				   eval(data);
			   }
			   });
	}
}

function adicionaItem(Tipo, ItemID, FM){
   $.ajax({
   type:"POST",
   url:"funcoesRateioRemoveItem.asp?Tipo="+Tipo+"&DominioID=<%=DominioID%>&ItemID="+ItemID+"&FM="+FM,
   success:function(data){
	   eval(data);
   }
   });
}
</script>