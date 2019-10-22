<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
tabela = ref("tabela")
id = ref("id")
codigo = ref("codigo")


set ProdutoSQL = dbc.execute("SELECT * FROM cliniccentral.produtos WHERE id="&id)

if not ProdutoSQL.eof then
    set TissProdutoTabelaSQL = db.execute("SELECT ProdutoID, TabelaID FROM tissprodutostabela WHERE Codigo='"&codigo&"' AND TabelaID="&treatvalnull(tabela))

    if not TissProdutoTabelaSQL.eof then
        ProdutoID=TissProdutoTabelaSQL("ProdutoID")
    else

        'insere o produto
        Fabricante = ProdutoSQL("Fab")
        set FabricanteSQL = db.execute("SELECT id FROM produtosfabricantes WHERE NomeFabricante = '"&Fabricante&"'")
        if not FabricanteSQL.eof then
            FabricanteID = FabricanteSQL("id")
        else
            db.execute("INSERT INTO produtosfabricantes (NomeFabricante, sysActive, sysUser) VALUES ('"&Fabricante&"', 1, "&session("User")&")")
            set FabricanteSQL = db.execute("SELECT id FROM produtosfabricantes ORDER BY id DESC LIMIT 1")
            FabricanteID = FabricanteSQL("id")
        end if

        TipoUnidadeID=ProdutoSQL("TipFraID")
        db.execute("INSERT INTO produtos (NomeProduto, Codigo, FabricanteID, ApresentacaoNome, PrecoCompra, TipoCompra, PrecoVenda, TipoVenda, sysActive, sysUser, RegistroANVISA, CD, ApresentacaoQuantidade, ApresentacaoUnidade) VALUES "&_
        "('"&ProdutoSQL("Descricao")&"', '"&ProdutoSQL("NumCodBarra")&"', "&treatvalnull(FabricanteID)&", '"&ProdutoSQL("TipEmb")&"', "&_
         ""&treatvalzero(ProdutoSQL("PreFabFra"))&", 'U',"&treatvalzero(ProdutoSQL("PreVenFra"))&", 'U', 1, "&session("User")&",'"&ProdutoSQL("NumRegANVISA")&"', '"&ProdutoSQL("CD")&"', "&treatvalnull(ProdutoSQL("QuaEmb"))&", "&treatvalnull(TipoUnidadeID)&")")

         set ProdutoAdicionadoSQL = db.execute("SELECT id FROM produtos ORDER BY id DESC LIMIT 1")
         if not ProdutoAdicionadoSQL.eof then
            ProdutoID=ProdutoAdicionadoSQL("id")
         end if

            Valor = ProdutoSQL("PreFabFra")
        if ref("AdicionarValor")="1" then
            db.execute("INSERT INTO tissprodutostabela (Codigo, ProdutoID, TabelaID, Valor, sysActive, sysUser) VALUES ('"&codigo&"', "&treatvalzero(ProdutoID)&","&treatvalzero(tabela)&","&treatvalzero(Valor)&",1,"&session("User")&")")
        end if
    end if


    set ProdutoSQL = db.execute("SELECT p.*, IFNULL(pt.Valor, p.PrecoVenda) Valor FROM produtos p LEFT JOIN tissprodutostabela pt ON pt.ProdutoID=p.id WHERE (pt.TabelaID='"&tabela&"' or pt.TabelaID is null) AND p.id="&ProdutoID)

    if not ProdutoSQL.eof then
        Valor = ProdutoSQL("Valor")
        TipoUnidadeID=ProdutoSQL("ApresentacaoUnidade")
        %>
        $("#RegistroANVISA").val("<%=ProdutoSQL("RegistroANVISA")%>");
        $("#<%=ref("CDField")%>").val("<%=ProdutoSQL("CD")%>");
        $("#<%=ref("ValorField")%>").val("<%=Valor%>").change();
        $("#<%=ref("UnidadeMedidaField")%>").val(parseInt("<%=TipoUnidadeID%>"));
        $("#<%=ref("DescricaoField")%>").html("<option value='<%= ProdutoSQL("id") %>'><%= ProdutoSQL("NomeProduto") %></option>").change();
        <%
    end if
end if
%>