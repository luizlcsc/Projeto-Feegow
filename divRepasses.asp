<%
AddRepasse = req("Add")
FM = req("FM")
RemoveRepasse = req("Remove")
NumeraRepasse = 0
contaParalelaRepasse = 0
'id = itemInvoiceID ao qual estes repasses pertencem

dominiomaior = 0
pontomaior = 0
set dom = db.execute("select * from rateiodominios order by Tipo desc")
while not dom.eof
	esteponto = 0
	queima = 0
	if instr(dom("Formas"), "|P|")>0 then
		esteponto = esteponto+1
	else
		if trim(dom("Formas"))<>"" then
			queima = 1
		end if
	end if
	if instr(dom("Profissionais"), "|"&ref("ProfissionalID"&id)&"|")>0 then
		esteponto = esteponto+1
	else
		if trim(dom("Profissionais"))<>"" then
			queima = 1
		end if
	end if
	if instr(dom("Procedimentos"), "|"&ref("ProcedimentoID")&"|")>0 then
		esteponto = esteponto+1
	else
		if trim(dom("Procedimentos"))<>"" then
			queima = 1
		end if
	end if
	
	if queima=0 and esteponto>pontomaior then
		dominiomaior = dom("id")
		pontomaior = esteponto
	end if
dom.movenext
wend
dom.close
set dom = nothing


newstrRep = ""

%>

<table width="100%" class="table table-striped table-bordered">
<thead>
	<tr>
		<th width="26%">Fun&ccedil;&atilde;o</th>
		<th width="26%">Conta</th>
		<th colspan="2" width="30%">Valor</th>
		<th width="8%">Sobre</th>
        <th>Estoque</th>
		<th width="1%"></th>
	</tr>
</thead>
<tbody>
    <tr>
        <td>Seringa (UN)</td>
        <td>Posi&ccedil;&atilde;o</td>
        <td colspan="2"><%=quickField("text", "Mat1", "", 5, "1,00", " input-mask-brl text-right input-sm", "", "")%> </td>
        <td>Total</td>
        <td colspan="2" class="text-center"><button type="button" class="btn btn-xs btn-warning"><i class="far fa-external-link"></i> Retirar</button>
    </tr>
    <tr>
        <td>Toxina (ML)</td>
        <td>Posi&ccedil;&atilde;o</td>
        <td colspan="2"><%=quickField("text", "Mat2", "", 5, "2,00", " input-mask-brl text-right input-sm", "", "")%> </td>
        <td>Total</td>
        <td colspan="2" class="text-center"><button type="button" class="btn btn-xs btn-warning"><i class="far fa-external-link"></i> Retirar</button>
    </tr>



	<%
if ref("E")="" then
	strRep = "db"
else
	if req("Change")="Profissional" then
		'strRep = "|-1|" => vai popular baseado na regra que se aplica a ref(Prof) e ref(Proc), com forma 0
		set fun = db.execute("select * from rateiofuncoes where DominioID="&dominiomaior)
		while not fun.eof
			contaParalelaRepasse = contaParalelaRepasse-1
			if fun("ContaPadrao")="PRO" then
				ContaCorrente = "5_"&ref("ProfissionalID"&id)
			else
				ContaCorrente = fun("ContaPadrao")
			end if
			call linhaFuncao(contaParalelaRepasse, fun("Funcao"), fun("Valor"), fun("TipoValor"), fun("Sobre"), ContaCorrente, NumeraRepasse, id, fun("FM"), fun("ProdutoID"), fun("ValorUnitario"), fun("Quantidade"))
			newstrRep = newstrRep&"|"&contaParalelaRepasse&"|"
		fun.movenext
		wend
		fun.close
		set fun=nothing
	else
		strRep = ref("strRep"&id)
		if isnumeric(RemoveRepasse) and RemoveRepasse<>"" then
			strRep = replace(strRep, "|"&RemoveRepasse&"|", "")
		end if
		splRep = split(strRep, "|")
		for l=0 to ubound(splRep)
			if splRep(l)<>"" then
				if ccur(splRep(l))<contaParalelaRepasse then
					contaParalelaRepasse = ccur(splRep(l))
				end if
				NumeraRepasse = NumeraRepasse+1
				call linhaFuncao(splRep(l), ref("Funcao"&id&"-"&splRep(l)), ref("Valor"&id&"-"&splRep(l)), ref("TipoValor"&id&"-"&splRep(l)), ref("Sobre"&id&"-"&splRep(l)), ref("ContaCredito"&id&"-"&splRep(l)), NumeraRepasse, id, ref("FM"&id&"-"&splRep(l)), ref("ProdutoID"&id&"-"&splRep(l)), ref("ValorUnitario"&id&"-"&splRep(l)), ref("Quantidade"&id&"-"&splRep(l)) )
				'call( linhaItem(spl(i), ref("ValorUnitario"&spl(i)), ref("Executado"&spl(i)), ref("DataExecucao"&spl(i)), ref("HoraExecucao"&spl(i)), ref("ProfissionalID"&spl(i)), ref("Desconto"&spl(i)), Numera) )
				newstrRep = newstrRep&"|"&splRep(l)&"|"
			end if
		next
	end if
end if


if strRep="db" then
	set repasses = db.execute("select * from rateiorateios where ItemInvoiceID="&id)
	while not repasses.eof
		contaParalelaRepasse = contaParalelaRepasse-1
		call linhaFuncao(repasses("id"), repasses("Funcao"), repasses("Valor"), repasses("TipoValor"), repasses("Sobre"), repasses("ContaCredito"), NumeraRepasse, id, repasses("FM"), repasses("ProdutoID"), repasses("ValorUnitario"), repasses("Quantidade"))
		newstrRep = newstrRep&"|"&repasses("id")&"|"
	repasses.movenext
	wend
	repasses.close
	set repasses=nothing
end if

if isnumeric(AddRepasse) and AddRepasse<>"" then
	if ccur(AddRepasse)>0 then
		cRepasse=0
		while cRepasse<ccur(AddRepasse)
			cRepasse=cRepasse+1
			contaParalelaRepasse = contaParalelaRepasse-1
			NumeraRepasse = NumeraRepasse+1
			call( linhaFuncao(contaParalelaRepasse, "", "", "", "", "", NumeraRepasse, id, FM, "", "", "") )
			newstrRep = newstrRep&"|"&contaParalelaRepasse&"|"
		wend
	end if
end if

%>
<input type="hidden" name="strRep<%=id%>" value="<%=newstrRep%>" />

</tbody>
</table>