<!--#include file="connect.asp"-->
<!--#include file="Classes/ValorProcedimento.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%

function treatvalnullformat(Val,Number)

	if isnumeric(Val) and Val<>"" then
		Val = formatnumber(Val,Number)
		Val = replace(Val, ".", "")
		treatValNULLFormat = replace(Val, ",", ".")
	else
		treatValNULLFormat = "NULL"
	end if
end function

ConvenioID = request.QueryString("ConvenioID")
ProcedimentoID = request.QueryString("ProcedimentoID")
str = ref("str")

set psobra = db.execute("select pp.* from tissprodutosprocedimentos as pp left join tissprocedimentosvalores as pv on pv.id=pp.AssociacaoID where pv.ProcedimentoID="&ProcedimentoID&" and ConvenioID="&ConvenioID)
while not psobra.eof
	sobra = sobra&"|"&pSobra("id")&"|"
pSobra.movenext
wend
pSobra.close
set pSobra=nothing

QuantidadeCH      = treatvalnullformat(ref("QuantidadeCH"),4)
CustoOperacional  = treatvalnullformat(ref("CustoOperacional"),4)
ValorFilme        = treatvalnullformat(ref("ValorFilme"),4)
QuantidadeFilme   = treatvalnullformat(ref("QuantidadeFilme"),4)
ValorUCO          = treatvalnullformat(ref("ValorUCO"),4)
CoeficientePorte  = treatvalnullformat(ref("CoeficientePorte"),2)
Porte             = ref("Porte")

'1. Verificar se na tabela tissprocedimentostabela existe esse procedimento cadastrado, senao cria. Sobrando ProcedimentoTabelaID
sqlVept = "select * from tissprocedimentostabela where TabelaID="&ref("TabelaID")&" and Codigo like '"&ref("Codigo")&"'"

set vept = db.execute(sqlVept)
if vept.eof then
	db_execute("insert into tissprocedimentostabela (Codigo, Descricao, TabelaID, sysActive, sysUser) values ('"&ref("Codigo")&"', '"&ref("Descricao")&"', "&ref("TabelaID")&", 1, "&session("User")&")")
	set vept = db.execute(sqlVept)
else
	db_execute("update tissprocedimentostabela set Descricao='"&ref("Descricao")&"' where id="&vept("id"))
end if
ProcedimentoTabelaID = vept("id")

'2. Vê se esse ProcedimentoTabelaID, com esse ConvenioID, TecnicaID e ProcedimentoID existem na tissprocedimentosvalores. Se existir, dá update, se não existir, cria
set vepv = db.execute("select * from tissprocedimentosvalores where COALESCE(ID=NULLIF('"&req("AssociacaoID")&"',''), ConvenioID="&ConvenioID&" and ProcedimentoID="&ProcedimentoID&")")
if vepv.eof then

    sqlInsert = "insert into  tissprocedimentosvalores (Contratados, CoeficientePorte,Porte,QuantidadeCH,CustoOperacional,ValorFilme,QuantidadeFilme,ValorUCO,ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, ValorCH, TecnicaID, NaoCobre, ModoDeCalculo) values "&_
              	    "(NULLIF('"&ref("Contratados")&"',''),"&CoeficientePorte&",'"&Porte&"',"&QuantidadeCH&", "&CustoOperacional&", "&ValorFilme&", "&QuantidadeFilme&", "&ValorUCO&","&ProcedimentoID&", "&ConvenioID&", "&ProcedimentoTabelaID&", "&treatvalnullformat(ref("ValorUnitario"),4)&",  "&treatvalnullformat(ref("ValorCH"),4)&", "&ref("TecnicaID")&", '"&ref("NaoCobre")&"', '"&ref("ModoDeCalculo")&"')"

	db_execute(sqlInsert)

	set pult = db.execute("select id from tissprocedimentosvalores where ConvenioID="&ConvenioID&" and ProcedimentoID="&ProcedimentoID&" order by id desc LIMIT 1")
	AssociacaoID = pult("id")

else

	db_execute("update tissprocedimentosvalores set Contratados=NULLIF('"&ref("Contratados")&"',''), CoeficientePorte = "&CoeficientePorte&", ProcedimentoTabelaID="&ProcedimentoTabelaID&", Porte = '"&Porte&"',QuantidadeCH = "&QuantidadeCH&",CustoOperacional = "&CustoOperacional&",ValorFilme = "&ValorFilme&",QuantidadeFilme = "&QuantidadeFilme&",ValorUCO = "&ValorUCO&_
	",Valor="&treatvalnullformat(ref("ValorUnitario"),4)&",ValorCH="&treatvalnullformat(ref("ValorCH"),4)&", NaoCobre='"&ref("NaoCobre")&"', TecnicaID="&treatvalnull(ref("TecnicaID"))&", ModoDeCalculo='"&ref("ModoDeCalculo")&"' where id="&vepv("id"))
	AssociacaoID = vepv("id")

end if


db.execute("UPDATE tissprocedimentosanexos SET AssociacaoID = "&AssociacaoID&" WHERE ("&ConvenioID&","&ProcedimentoID&") = (ConvenioID,ProcedimentoPrincipalID) AND AssociacaoID IS NULL;")

'3. Dá um loop de todos os planos que este convênio tem, e verifica se existe registro pra essa associação. Se existir update, se não, insert
set plan = db.execute("select * from conveniosplanos where ConvenioID="&ConvenioID&" and sysActive=1")
while not plan.eof
	set vcaAssoc = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&AssociacaoID&" and PlanoID="&plan("id"))

	QuantidadeCH      = treatvalnullformat(ref("QuantidadeCH"&plan("id")),4)
    CustoOperacional  = treatvalnullformat(ref("CustoOperacional"&plan("id")),4)
    ValorFilme        = treatvalnullformat(ref("ValorFilme"&plan("id")),4)
    QuantidadeFilme   = treatvalnullformat(ref("QuantidadeFilme"&plan("id")),4)
    ValorUCO          = treatvalnullformat(ref("ValorUCO"&plan("id")),4)
	if vcaAssoc.eof then
		db_execute("insert into tissprocedimentosvaloresplanos (QuantidadeCH,CustoOperacional,ValorFilme,QuantidadeFilme,ValorUCO,AssociacaoID, PlanoID, Valor, ValorCH, NaoCobre, Codigo)"&_
		" values ("&QuantidadeCH&","&CustoOperacional&","&ValorFilme&","&QuantidadeFilme&","&ValorUCO&","&AssociacaoID&", "&plan("id")&", "&treatvalnullformat(ref("Valor"&plan("id")),4)&", "&treatvalnullformat(ref("ValorCH"&plan("id")),4)&", '"&ref("NaoCobre"&plan("id"))&"', '"&(ref("Codigo"&plan("id")))&"')")
	else
	    sql = "update tissprocedimentosvaloresplanos set QuantidadeCH="&QuantidadeCH&",CustoOperacional="&CustoOperacional&",ValorFilme="&ValorFilme&",QuantidadeFilme="&QuantidadeFilme&",ValorUCO="&ValorUCO&" "&_
              		",Valor="&treatvalnullformat(ref("Valor"&plan("id")),4)&", ValorCH="&treatvalnullformat(ref("ValorCH"&plan("id")),4)&", NaoCobre='"&ref("NaoCobre"&plan("id"))&"', Codigo='"&(ref("Codigo"&plan("id")))&"' where id="&vcaAssoc("id")
		db_execute(SQL)
	end if
plan.movenext
wend
plan.close
set plan=nothing

call ProcessarValores(AssociacaoID)

'4. Materiais utilizados nesta associacao
spl = split(str, "|")
for i=0 to ubound(spl)
	if spl(i)<>"" and isnumeric(spl(i)) then
		n = ccur(spl(i))
		'4.1. Ve se existe, cria e pega o id do tissprodutostabela

		set vcaProdutoTabela = db.execute("select * from tissprodutostabela where TabelaID like '"&ref("TabelaProdutoID"&n)&"' and Codigo like '"&ref("CodigoProduto"&n)&"' AND ProdutoID="&ref("ProdutoID"&n)&" ")
		if vcaProdutoTabela.eof then
			db_execute("insert into tissprodutostabela (Codigo, ProdutoID, TabelaID, Valor, sysActive, sysUser) values ('"&ref("CodigoProduto"&n)&"', '"&ref("ProdutoID"&n)&"', '"&ref("TabelaProdutoID"&n)&"', "&treatvalzero(ref("ValorUnitario"&n))&", 1, "&session("User")&")")
			set pult = db.execute("select id from tissprodutostabela where ProdutoID like '"&ref("ProdutoID"&n)&"' order by id desc LIMIT 1")
			ProdutoTabelaID = pult("id")
		else
          sqlUp = "update tissprodutostabela set ProdutoID='"&ref("ProdutoID"&n)&"', Valor="&treatvalzero(ref("ValorUnitario"&n))&" where id="&vcaProdutoTabela("id")
			db_execute(sqlUp)
			ProdutoTabelaID = vcaProdutoTabela("id")
		end if
		'4.2. Anexa propriedades ao produto
		db_execute("update produtos set CD='"&ref("CD"&n)&"', Codigo='"&ref("CodigoNoFabricante"&n)&"', RegistroANVISA='"&ref("RegistroANVISA"&n)&"', AutorizacaoEmpresa='"&ref("AutorizacaoEmpresa"&n)&"', ApresentacaoUnidade='"&ref("UnidadeMedidaID"&n)&"' where id="&ref("ProdutoID"&n))

		'4.3. Grava tissprodutosvalores (up/ins se nao existe)
		sql = "select * from tissprodutosvalores where ProdutoTabelaID="&ProdutoTabelaID&" and ConvenioID="&ConvenioID
		set vcaProdutosValores = db.execute(sql)
		if vcaProdutosValores.eof then
'			db_execute("insert into tissprodutosvalores (ProdutoTabelaID, ConvenioID, Valor) values ("&ProdutoTabelaID&", "&ConvenioID&", "&treatvalzero(ref("ValorUnitario"&n))&")")
'			set vcaProdutosValores = db.execute(sql)
		else
'			db_execute("update tissprodutosvalores set Valor="&treatvalzero(ref("ValorUnitario"&n))&" where id="&vcaProdutosValores("id"))
		    ProdutoValorID = vcaProdutosValores("id")
		end if

		'4.4. Grava cada material a ser anexado como outra despesa na guia SADT
		if n<0 then
            '!!! verifica se tem mas ignorando a quantidade, dando apenas update na quantidade
			db_execute("insert into tissprodutosprocedimentos (ProdutoValorID, AssociacaoID, Quantidade, ProdutoTabelaID) values ("&treatvalzero(ProdutoValorID)&", "&AssociacaoID&", "&treatvalzero(ref("Quantidade"&n))&", "& ProdutoTabelaID &")")
			set pult = db.execute("select id from tissprodutosprocedimentos order by id desc limit 1")
			EsteItem = pult("id")
		else
			EsteItem = n
			db_execute("update tissprodutosprocedimentos set ProdutoValorID="& treatvalzero(ProdutoValorID) &", AssociacaoID="&AssociacaoID&", Quantidade="&treatValZero(ref("Quantidade"&n))&", ProdutoTabelaID="& ProdutoTabelaID &" where id="&n)
		end if
		sobra = replace(sobra, "|"&n&"|", "")
	end if
next

splSobra = split(sobra, "|")
for j=0 to ubound(splSobra)
	if splSobra(j)<>"" and isnumeric(splSobra(j)) then
		db_execute("delete from tissprodutosprocedimentos where id="&splSobra(j))
	end if
next

%>
$("#modal-table").modal("hide");
ajxContent('ConveniosValoresProcedimentos&ConvenioID=<%=ConvenioID%>', '', '1', 'divValores');