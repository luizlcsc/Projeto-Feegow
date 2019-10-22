<!--#include file="connect.asp"-->
<%
DominioID = req("DominioID")
Tipo = req("Tipo")
Acao = req("Acao")
Linear = req("Linear")


if DominioID="" then
	'itens comuns ao registro
	if isnumeric(ref("Quantidade")) and ref("Quantidade")<>"" then
		Quantidade = ccur(ref("Quantidade"))
	else
		Quantidade = 1
	end if
	CategoriaID = 0
	set dominioSuperior = db.execute("select * from rateiodominios where id="&Acao)
	if not dominioSuperior.eof then
		Procedimentos = dominioSuperior("Procedimentos")
		Profissionais = dominioSuperior("Profissionais")
		Formas = dominioSuperior("Formas")
	end if

	if Tipo="Profissional" then
		Profissionais = ref("Profissionais")
	elseif Tipo="Procedimento" then
		Procedimentos = ref("Procedimentos")
	elseif Tipo="Forma" then
		Formas = ref("Formas")
	end if
	db_execute("insert into rateiodominios (Tipo, Procedimentos, Profissionais, Formas, dominioSuperior, sysUser) values ('"&Tipo&"', '"&Procedimentos&"', '"&Profissionais&"', '"&Formas&"', "&Acao&", "&session("User")&")")
	set pult = db.execute("select * from rateiodominios where sysUser="&session("User")&" order by id desc")
	DominioID = pult("id")
	n = 0
	while n<Quantidade
		n = n+1
        if ref("modoCalculo"&n)="" then
            modoCalculo = "N"
        else
            modoCalculo = "I"
        end if
		db_execute("insert into rateiofuncoes (modoCalculo, Funcao, DominioID, tipoValor, Valor, ContaPadrao, sysUser, Sobre) values ('"& modoCalculo &"', '"&ref("Funcao"&n)&"', '"&DominioID&"', '"&ref("tipoValor"&n)&"', "&treatValZero(ref("Valor"&n))&", '"&ref("ContaPadrao"&n)&"', '"&session("User")&"', '"&ref("Sobre"&n)&"')")
	wend
else
    if Linear="" then
	    set dom = db.execute("select * from rateiodominios where id="&DominioID)
	    if not dom.eof then
		    set domSup = db.execute("select * from rateiodominios where id="&dom("dominioSuperior"))
		    if not domSup.eof then
			    db_execute("update rateiodominios set Procedimentos='"&domSup("Procedimentos")&"', Profissionais='"&domSup("Profissionais")&"', Formas='"&domSup("Formas")&"' where id="&dom("id"))
		    end if
	    end if
	    if Tipo="Profissional" then
		    sql = "Profissionais='"&ref("Profissionais")&"'"
	    elseif Tipo="Procedimento" then
		    sql = "Procedimentos='"&ref("Procedimentos")&"'"
	    elseif Tipo="Forma" then
		    sql = "Formas='"&ref("Formas")&"'"
	    end if
	    if Tipo<>"" then
		    db_execute("update rateiodominios set "&sql&", sysActive=1 where id="&DominioID)
		    db_execute("update rateiodominios set "&sql&" where dominioSuperior="&DominioID)
		    set subs = db.execute("select * from rateiodominios where dominioSuperior="&DominioID)
		    while not subs.eof
			    db_execute("update rateiodominios set "&sql&" where dominioSuperior="&subs("id"))
		    subs.movenext
		    wend
		    subs.close
		    set subs=nothing
	    end if
    end if
	set grupo = db.execute("select * from rateiofuncoes where DominioID="&DominioID)
	while not grupo.eof
		if ref("ProdutoID"&grupo("id"))="" then
			ProdutoID=0
		else
			ProdutoID=ref("ProdutoID"&grupo("id"))
		end if
        if ref("modoCalculo"&grupo("id"))="" then
            modoCalculo = "N"
        else
            modoCalculo = "I"
        end if
		db_execute("update rateiofuncoes set modoCalculo='"& modoCalculo &"', Funcao='"&ref("Funcao"&grupo("id"))&"', tipoValor='"&ref("tipoValor"&grupo("id"))&"', Valor="&treatValZero(ref("Valor"&grupo("id")))&", ContaPadrao='"&ref("ContaPadrao"&grupo("id"))&"', Sobre="&treatvalzero(ref("Sobre"&grupo("id")))&", ProdutoID="&ProdutoID&", ValorUnitario="&treatvalzero(ref("ValorUnitario"&grupo("id")))&", Quantidade="&treatvalzero(ref("Quantidade"&grupo("id")))&", Variavel='"&ref("Variavel"&grupo("id"))&"', ValorVariavel='"&ref("ValorVariavel"&grupo("id"))&"' where id="&grupo("id"))
	grupo.movenext
	wend
	grupo.close
	set grupo=nothing
end if
%>
ajxContent('arvorerateio', '', 1, 'arvorerateio');
$("#modal-table").modal("hide");
<% if req("Linear")="1" then %>

    location.reload();

<% end if %>