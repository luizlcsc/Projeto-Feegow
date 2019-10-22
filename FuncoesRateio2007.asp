<!--#include file="connect.asp"-->
<script>
$("#divUsers, #divMedkit").removeClass("hidden");
</script>

<%
DominioID = request.QueryString("I")
Tipo = request.QueryString("T")
Acao = request.QueryString("A")
Q = request.QueryString("Q")

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
			%>
			<tr>
                <td><div class="row">
				<div class="col-xs-3"><%= quickField("text", "Funcao"&n, "", "", itens("Funcao"), "", "", "") %></div>
				<div class="col-xs-4"><%call selectCurrentAccounts("ContaPadrao"&n, "0, 5, 4, 2, 1", itens("ContaPadrao"), "")%></div>
				<div class="col-xs-2"><%= quickField("text", "Valor"&n, "", "", Valor, " text-right input-mask-brl", "", "") %></div>
				<div class="col-xs-1">
					<select name="tipoValor<%=itens("id")%>" class="select2-single" id="tipoValor<%=itens("id")%>">
						<option value="P"<% If itens("tipoValor")="P" Then %> selected<%end if%>>%</option>
						<option value="V"<% If itens("tipoValor")="V" Then %> selected<%end if%>>R$</option>
					</select>
				</div>
				<div class="col-xs-2">
					<select name="Sobre<%=itens("id")%>" class="select2-single" id="Sobre<%=itens("id")%>">
						<option value="0"<% If itens("Sobre")=0 Then %> selected<%end if%>>Total</option>
						<option value="1"<% If itens("Sobre")=1 Then %> selected<%end if%>>Subtotal 1</option>
						<option value="2"<% If itens("Sobre")=2 Then %> selected<%end if%>>Subtotal 2</option>
						<option value="3"<% If itens("Sobre")=3 Then %> selected<%end if%>>Subtotal 3</option>
					</select>
				</div>
                </div></td>
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="fa fa-remove"></i></button></td>
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
            <%if c>1 then%><button type="button" class="btn btn-danger btn-xs pull-right" onClick="removeItem('Grupo', <%=DominioID%>);"><i class="fa fa-remove"></i> Remover Todas</button><%end if%></td>
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
                <div class="col-xs-2"><%= quickField("text", "ValorUnitario"&n, "", "", formatnumber(itens("ValorUnitario"),2), " text-right input-mask-brl", "", "") %></div>
                <div class="col-xs-2"><%= quickField("text", "Quantidade"&n, "", "", formatnumber(itens("Quantidade"),2), " text-right input-mask-brl", "", "") %>
					<label><input type="checkbox" name="Variavel<%=n%>" value="S" class="ace"<% If itens("Variavel")="S" Then %> checked="checked"<% End If %> /> <span class="lbl">Variável</span></label></div>
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
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="fa fa-remove"></i></button></td>
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
            <%if c>1 then%><button type="button" class="btn btn-danger btn-xs pull-right" onClick="removeItem('Grupo', <%=DominioID%>);"><i class="fa fa-remove"></i> Remover Todas</button><%end if%></td>
          </tr>
        </tfoot>
    </table>
    <%end if

	'Kits
	set itens = db.execute("select * from rateiofuncoes where DominioID like '"&DominioID&"' and FM in('K', 'E')")
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
                txt = "<i class='fa fa-medkit'></i> Descontar produtos vinculados ao procedimento executado, caso haja, sobre:"
                %>
                <script>$("#divMedkit").addClass("hidden");</script>
                <%
            elseif itens("FM")="E" then
                txt = "<i class='fa fa-users'></i> Gerar repasse para equipe vinculada ao procedimento executado, caso haja, sobre:"
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
					<select name="Sobre<%=itens("id")%>" class="select2-single" id="Sobre<%=itens("id")%>">
						<option value="0"<% If itens("Sobre")=0 Then %> selected<%end if%>>Total</option>
						<option value="1"<% If itens("Sobre")=1 Then %> selected<%end if%>>Subtotal 1</option>
						<option value="2"<% If itens("Sobre")=2 Then %> selected<%end if%>>Subtotal 2</option>
						<option value="3"<% If itens("Sobre")=3 Then %> selected<%end if%>>Subtotal 3</option>
					</select>
				</div>
                </div></td>
				<td width="50"><button type="button" class="btn btn-danger btn-sm" onClick="removeItem('Item', <%=itens("id")%>);"><i class="fa fa-remove"></i></button></td>
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