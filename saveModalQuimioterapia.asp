<!--#include file="connect.asp"-->
<!--#include file="testaCPF.asp"-->
<%
ItemID = request.QueryString("II")
GuiaID = request.QueryString("I")
Tipo = request.QueryString("T")
DataAdministracao = ""
if ref("DataAdministracao")&"" <> "" then
    DataAdministracao = myDate(ref("DataAdministracao"))
end if

if Tipo="Produto" then
	if erro="" then
		if ItemID="0" then
            db_execute("insert into tissmedicamentosquimioterapia (GuiaID, ProdutoID, TabelaID, CodigoMedicamento, Descricao, DataAdministracao, DosagemMedicamento, UnidadeMedidaMedicamento, ViaADM, Frequencia, sysUser) values ("&GuiaID&", '"&ref("gProdutoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoMedicamento")&"', '"&ref("Descricao")&"', '"&DataAdministracao&"', '"&ref("DosagemMedicamento")&"', '"&ref("UnidadeMedidaMedicamento")&"', '"&ref("ViaADM")&"', '"&ref("Frequencia")&"', '"&session("User")&"')")
			set pult = db.execute("select id from tissmedicamentosquimioterapia where GuiaID="&GuiaID&" and sysUser="&session("User")&" order by id desc LIMIT 1")
			EsteItem = pult("id")
		else
			db_execute("update tissmedicamentosquimioterapia set  ProdutoID='"&ref("gProdutoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoMedicamento='"&ref("CodigoMedicamento")&"', Descricao='"&ref("Descricao")&"', DataAdministracao='"&DataAdministracao&"', DosagemMedicamento='"&ref("DosagemMedicamento")&"', UnidadeMedidaMedicamento='"&ref("UnidadeMedidaMedicamento")&"', ViaADM='"&ref("ViaADM")&"', Frequencia='"&ref("Frequencia")&"', sysUser='"&session("User")&"' where id="&ItemID)
			EsteItem = ItemID
		end if

       ' aqui entra nova forma de valores de itens
       ProdutoID = ref("gProdutoID")
       ConvenioID = ref("gConvenioID")

       	%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissmedicamentosquimioterapia", "tissmedicamentosquimioterapia.asp?I=<%=GuiaID%>");
		<%
	end if
end if
%>