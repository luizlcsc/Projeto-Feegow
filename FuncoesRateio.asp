<!--#include file="connect.asp"-->
<script>
$("#divUsers, #divMedkit").removeClass("hidden");
</script>

<%
DominioID = req("I")
Tipo = req("T")
Acao = req("A")
Q = req("Q")

if isnumeric(Q) and Q<>"" then
	Q = ccur(Q)
else
	Q = 1
end if

	set itens = db.execute("select * from rateiofuncoes where DominioID like '"&DominioID&"' and (FM='F' or isnull(FM))")
	if not itens.eof then
	%>
	<table width="100%" class="table table-striped">
    <thead>
        <tr>
            <th width="1%">Inv.</th>
            <th width="100%"><div class="col-xs-3">Fun&ccedil;&atilde;o</div>
            <div class="col-xs-4">Conta Padr&atilde;o</div>
            <div class="col-xs-2">Valor</div>
            <div class="col-xs-1"></div>
            <div class="col-xs-2">Sobre</div>
            </th>
            <%if DominioID<>"" then%><th width="50"></th><%end if%>
        </tr>
     </thead>
     <tbody>
		<%
		c = 0
		while not itens.eof
			n = itens("id")
			c = c+1
			if isnull(itens("Valor")) then
				Valor = "0,00"
			else
				Valor = formatnumber(itens("Valor"),2)
			end if

            if request.form()="" then
                Funcao = itens("Funcao")
                ContaPadrao = itens("ContaPadrao")
                tipoValor = itens("tipoValor")
                Sobre = cstr(itens("Sobre") &"")
                modoCalculo = cstr(itens("modoCalculo") &"")
                valorVariavel = itens("ValorVariavel")&""
            else
                Funcao = ref("Funcao"& n)
                ContaPadrao = ref("ContaPadrao"& n)
                Valor = ref("Valor"& n)
                tipoValor = ref("tipoValor"& n)
                Sobre = ref("Sobre"& n)
                modoCalculo = ref("modoCalculo"& n)
                valorVariavel = ref("ValorVariavel"&n)
            end if
			%>
			<tr>
                <td><input type="checkbox" name="modoCalculo<%= n %>" value="I" <% if modoCalculo="I" then response.write("checked") end if %> /></td>
                <td><div class="row">
				<div class="col-xs-3"><%= quickField("text", "Funcao"&n, "", "", Funcao, "", "", "") %></div>
				<div class="col-xs-4"><%call selectCurrentAccounts("ContaPadrao"&n, "0, 5, 4, 2, 8, 1", ContaPadrao, "")%></div>
				<div class="col-xs-2"><%= quickField("text", "Valor"&n, "", "", Valor, " text-right input-mask-brl", "", "") %>
                    <input type="checkbox" id="ValorVariavel<%= n %>" name="ValorVariavel<%= n %>" value="S" <% if ValorVariavel="S" then response.write(" checked ") end if %> /> valor variável
				</div>
				<div class="col-xs-1">
					<select name="tipoValor<%=n%>" class="form-control" id="tipoValor<%=n%>">
						<option value="P"<% If tipoValor="P" Then %> selected<%end if%>>%</option>
						<option value="V"<% If tipoValor="V" Then %> selected<%end if%>>R$</option>
						<option value="E"<% If tipoValor="E" Then %> selected<%end if%>>% do preço de compra</option>
						<option value="S"<% If tipoValor="S" Then %> selected<%end if%>>% do preço de venda</option>
					</select>
				</div>
				<div class="col-xs-2">
					<select name="Sobre<%= n %>" class="form-control" id="Sobre<%= n %>">
						<option value="0"<% If Sobre="0" Then %> selected<%end if%>>Total</option>
						<option value="1"<% If Sobre="1" Then %> selected<%end if%>>Subtotal 1</option>
						<option value="2"<% If Sobre="2" Then %> selected<%end if%>>Subtotal 2</option>
						<option value="3"<% If Sobre="3" Then %> selected<%end if%>>Subtotal 3</option>
					</select>
				</div>
                </div></td>
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="far fa-remove"></i></button></td>
			</tr>
			<%
		itens.movenext
		wend
		itens.close
		set itens = nothing
		%>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="2"><%=c%> fun&ccedil;&otilde;es
            <%if c>1 then%><button type="button" class="btn btn-danger btn-xs pull-right" onClick="removeItem('Grupo', <%=DominioID%>);"><i class="far fa-remove"></i> Remover Todas</button><%end if%></td>
          </tr>
        </tfoot>
    </table>
		<%
	end if



	'Materiais
	set itens = db.execute("select * from rateiofuncoes where DominioID like '"&DominioID&"' and FM='M'")
	if not itens.eof then
	%>
	<table width="100%" class="table table-striped">
    <thead>
        <tr>
            <th width="100%"><div class="col-xs-2">Produto</div>
            <div class="col-xs-2">Conta Padr&atilde;o</div>
            <div class="col-xs-2">Valor Unit.</div>
            <div class="col-xs-2">Quant.</div>
            <div class="col-xs-2">Total</div>
            <div class="col-xs-1">Sobre</div>
            </th>
            <%if DominioID<>"" then%><th width="50"></th><%end if%>
        </tr>
     </thead>
     <tbody>
		<%
		c = 0
		while not itens.eof
			n = itens("id")
			c = c+1
			if isnull(itens("Valor")) then
				Valor = "0,00"
			else
				Valor = formatnumber(itens("Valor"),2)
			end if
			%>
				<tr><td><div class="row">
				<div class="col-md-2"><%=selectInsert("", "ProdutoID"&n, itens("ProdutoID"), "produtos", "NomeProduto", "", "", "")%></div>
				<div class="col-xs-2"><%call selectCurrentAccounts("ContaPadrao"&n, "0, 5, 4, 2, 1", itens("ContaPadrao"), "")%></div>
                <div class="col-xs-2"><%= quickField("text", "ValorUnitario"&n, "", "", formatnumber(itens("ValorUnitario"),2), " text-right input-mask-brl", "", " onkeyup=""tot("& itens("id") &")""") %>
                    <div class="checkbox-custom checkbox-system hidden"><input type="checkbox" name="ValorVariavel<%=n%>" id="ValorVariavel<%=n%>" value="S" <% If itens("ValorVariavel")="S" Then %> checked="checked"<% End If %> /> <label for="ValorVariavel<%=n%>">Variável</label></div>
                </div>
                <div class="col-xs-2"><%= quickField("text", "Quantidade"&n, "", "", formatnumber(itens("Quantidade"),2), " text-right input-mask-brl", "", " onkeyup=""tot("& itens("id") &")""") %>
					<div class="checkbox-custom checkbox-alert" title="Ao marcar esta opção será descontado baseado na quantidade retirada do estoque"><input type="checkbox" name="Variavel<%=n%>" id="Variavel<%=n%>" value="S" <% If itens("Variavel")="S" Then %> checked="checked"<% End If %> /> <label for="Variavel<%=n%>"> Variável</label></div></div>
				<div class="col-xs-2"><%= quickField("text", "Valor"&n, "", "", Valor, " text-right input-mask-brl", "", "") %></div>
				<div class="col-xs-2">
					<select name="Sobre<%=itens("id")%>" class="select2-single" id="Sobre<%=itens("id")%>">
						<option value="0"<% If itens("Sobre")=0 Then %> selected<%end if%>>Total</option>
						<option value="1"<% If itens("Sobre")=1 Then %> selected<%end if%>>Subtotal 1</option>
						<option value="2"<% If itens("Sobre")=2 Then %> selected<%end if%>>Subtotal 2</option>
						<option value="3"<% If itens("Sobre")=3 Then %> selected<%end if%>>Subtotal 3</option>
					</select>
				</div>
                </div></td>
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="far fa-remove"></i></button></td>
			</tr>
			<%
		itens.movenext
		wend
		itens.close
		set itens = nothing
	 %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="2"><%=c%> materiais/medicamentos
            <%if c>1 then%><button type="button" class="btn btn-danger btn-xs pull-right" onClick="removeItem('Grupo', <%=DominioID%>);"><i class="far fa-remove"></i> Remover Todas</button><%end if%></td>
          </tr>
        </tfoot>
    </table>

<script type="text/javascript">
function tot(I){
    var vu = parseFloat($("#ValorUnitario"+I).val().replace(".", "").replace(",", "."));
    var q = parseFloat($("#Quantidade"+I).val().replace(".", "").replace(",", "."));
    var S = (vu * q).toFixed(2);
    if (isNaN(S)){
        S = "0,00"
    }
    S = S.toString().replace('.', ',')
    $("#Valor"+I).val(S);
}
</script>

    <%end if

	'Kits
	set itens = db.execute("select * from rateiofuncoes where DominioID like '"&DominioID&"' and FM in('K', 'E', 'Q')")
	if not itens.eof then
	%>
	<table width="100%" class="table table-striped">
     <tbody>
		<%
		c = 0
		while not itens.eof
			n = itens("id")
			c = c+1

            if itens("FM")="K" then
                txt = "<i class='far fa-medkit'></i> Descontar produtos vinculados ao procedimento executado, caso haja, sobre:"
                %>
                <script>$("#divMedkit").addClass("hidden");</script>
                <%
            elseif itens("FM")="Q" then
                txt = "<i class='far fa-medkit'></i> Descontar produtos baixados no estoque"
                %>
                <script>$("#divEstoque").addClass("hidden");</script>
                <%
            elseif itens("FM")="E" then
                txt = "<i class='far fa-users'></i> Gerar repasse para equipe vinculada ao procedimento executado, caso haja, sobre:"
                %>
                <script>$("#divUsers").addClass("hidden");</script>
                <%
            end if
			%>
				<tr><td><div class="row">
				<div class="col-md-10">
                    <%=txt %>
				</div>
				<div class="col-xs-2">
                    Sobre<br />
					<select name="Sobre<%=itens("id")%>" class="select2-single" id="Sobre<%=itens("id")%>">
						<option value="0"<% If itens("Sobre")=0 Then %> selected<%end if%>>Total</option>
						<option value="1"<% If itens("Sobre")=1 Then %> selected<%end if%>>Subtotal 1</option>
						<option value="2"<% If itens("Sobre")=2 Then %> selected<%end if%>>Subtotal 2</option>
						<option value="3"<% If itens("Sobre")=3 Then %> selected<%end if%>>Subtotal 3</option>
					</select>
				</div>
                </div></td>
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="far fa-remove"></i></button></td>
			</tr>
			<%
		itens.movenext
		wend
		itens.close
		set itens = nothing
	 %>
        </tbody>
    </table>
    <%end if%>

<script>
	<!--#include file="jQueryFunctions.asp"-->
</script>