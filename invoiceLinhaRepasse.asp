<%
if ref("r_Quantidade_"&Row&"_"&FuncaoID)<>"" then
	Quantidade = ref("r_Quantidade_"&Row&"_"&FuncaoID)
end if
if ref("r_ContaCredito_"&Row&"_"&FuncaoID)<>"" then
	ContaCredito = ref("r_ContaCredito_"&Row&"_"&FuncaoID)
end if

if FM="M" then
    if valorGravado="N" then
        if Row>0 then
            'tem que procurar se na rr tem com mesmo ProdutoID
            set vca = db.execute("select Quantidade from rateiorateios where ProdutoID="&ProdutoID&" AND Variavel='S' AND ItemInvoiceID="&Row)
            if not vca.eof then
                Quantidade = vca("Quantidade")
            end if
        end if
    end if
	'EXIBE DADOS DO USO DE MATERIAL ---
	set prod = db.execute("select NomeProduto from produtos where id="&ProdutoID)
	if not prod.eof then
		%>
		<%'=quickField("text", "prod"&Row&"_"&FuncaoID, prod("NomeProduto"), 2, Quantidade, " input-mask-brl text-right", "", "")%>
		<div class="col-md-2">
			<label><%= prod("NomeProduto") %></label><br>
			<div class="input-group">
				<input id="<%="r_Quantidade_"&Row&"_"&FuncaoID%>" class="form-control input-mask-brl text-right" type="text" value="<%= fn(Quantidade) %>" name="<%="r_Quantidade_"&Row&"_"&FuncaoID%>">
				<span class="input-group-addon">
					<em>qtd.</em>
				</span>
			</div>
		</div>
		<%
	end if
else
    if valorGravado="N" then
        if Row>0 then
            set vca = db.execute("select ContaCredito from rateiorateios where Funcao like '"&Funcao&"' AND Variavel='S' AND ItemInvoiceID="&Row)
            if not vca.eof then
                ContaCredito = vca("ContaCredito")
            end if
        end if
    end if

    if FuncaoID>0 OR TabelasPermitidas="" then
        TabelasPermitidas = "5, 8, 4, 3, 2"

    else
        TabelasPermitidas = replace(TabelasPermitidas, "|", "")
    end if
	'EXIBE AS CONTAS DE PESSOAS PARA SELECIONAR ---
	%>
	<div class="col-md-2">
		<label><%=Funcao%></label><br>
		<%=selectInsertCA("", "r_ContaCredito_"&Row&"_"&FuncaoID, ContaCredito, TabelasPermitidas, "", "", "")%>
	</div>
	<%
end if
%>
