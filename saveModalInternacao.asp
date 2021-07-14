<!--#include file="connect.asp"-->
<!--#include file="testaCPF.asp"-->
<%
ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")

if Tipo="Procedimentos" then
	if erro="" then
		if ref("gConvenioID")<>"" and ref("gConvenioID")<>"0" then

'original
'			set proc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&ref("ProcedimentoID")&" and ConvenioID="&ref("ConvenioID"))
'			if proc.eof then
'				db_execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, TabelaID, CodigoProcedimento, Valor, TecnicaID) values ('"&ref("ProcedimentoID")&"', '"&ref("ConvenioID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&treatval(ref("ValorUnitario"))&"', '"&ref("TecnicaID")&"')")
'			else
'				db_execute("update tissprocedimentosvalores set TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Valor='"&treatval(ref("ValorUnitario"))&"', TecnicaID='"&ref("TecnicaID")&"' where id="&proc("id"))
'			end if
'/original
		end if
		if ItemID="0" then
            db_execute("insert into tissprocedimentosinternacao (GuiaID, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, QuantidadeAutorizada ,sysUser) values ("&GuiaID&", '"&ref("gProcedimentoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&ref("Descricao")&"', '"&ref("Quantidade")&"', '"&ref("QuantidadeAutorizada")&"', '"&session("User")&"')")
			set pult = db.execute("select id from tissprocedimentosinternacao where GuiaID="&GuiaID&" and sysUser="&session("User")&" order by id desc LIMIT 1")
			EsteItem = pult("id")
		else
			db_execute("update tissprocedimentosinternacao set  ProcedimentoID='"&ref("gProcedimentoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Descricao='"&ref("Descricao")&"', Quantidade='"&ref("Quantidade")&"', QuantidadeAutorizada='"&ref("QuantidadeAutorizada")&"', sysUser='"&session("User")&"' where id="&ItemID)
			EsteItem = ItemID
		end if

       ' aqui entra nova forma de valores de itens
       ProcedimentoID = ref("gProcedimentoID")
       ConvenioID = ref("gConvenioID")

		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprocedimentosinternacao", "tissprocedimentosinternacao.asp?I=<%=GuiaID%>");
		<%
	end if
end if
%>