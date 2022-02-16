<!--#include file="connect.asp"-->
<%
ProdutoID = req("ProdutoID")
Colunas = ref("CBIColunas")
if Colunas<>"" and isnumeric(Colunas) then
    Colunas = cint(ref("CBIColunas"))
    db_execute("update produtos set CBIColunas="&treatvalzero(ref("CBIColunas"))&", CBILargura="&treatvalzero(ref("CBILargura"))&", CBIAltura="&treatvalzero(ref("CBIAltura"))&" where id="&ProdutoID)
end if


%>
<style type="text/css">
    body{
        background-color:#fff!important;
    }
    @media print{
        form{
            display:none;
        }
        td{
            border: 1px solid #fff!important;
        }
    }
    td{
        height: <%=replace(treatvalzero(ref("CBIAltura")), "'", "") %>mm;
        width: <%=replace(treatvalzero(ref("CBILargura")), "'", "") %>mm;
        border:1px dotted #CCC;
    }
</style>
<link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/fgw.css">
<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.15.4/css/all.css" integrity="sha384-rqn26AG5Pj86AF4SO72RK5fyefcQ/x32DNQfChxWvbXIyXFePlEktwD18fEz+kQU" crossorigin="anonymous">

<%
Posicao = ref("Posicao")
if not isnumeric(Posicao) or Posicao="" then
    Posicao=1
end if
set prod = db.execute("select * from produtos where id="& ProdutoID)

CBILargura=prod("CBILargura")
CBIAltura=prod("CBIAltura")

set ConfigEtiquetaSQL = db.execute("SELECT * FROM config_etiqueta WHERE id=1")

if isnull(CBILargura) then
    if not ConfigEtiquetaSQL.eof then
        CBILargura=ConfigEtiquetaSQL("Largura")
        CBIAltura=ConfigEtiquetaSQL("Altura")
        Posicao=ConfigEtiquetaSQL("PosicaoInicial")
    end if
end if

if req("Etiquetas")="" then
    %>
    Selecione alguma posição.
    <%
else
    set CodigoBarrasPrimeiroItemSQL = db.execute("SELECT CBID, Quantidade FROM estoqueposicao WHERE id in ("&req("Etiquetas")&")")
    QuantidadePosicao = CodigoBarrasPrimeiroItemSQL("Quantidade")


    %>
    <form method="post" action="cbiGeraEtiquetas.asp?ProdutoID=<%=ProdutoID %>&Etiquetas=<%=req("Etiquetas") %>">
        <div class="row">
            <div class="col-xs-3">
                <%=quickfield("number", "CBIColunas", "Colunas", 12, prod("CBIColunas"), "", "", "") %>
            </div>
            <div class="col-xs-3">
                <%=quickfield("text", "CBILargura", "Largura (mm)", 12, CBILargura, "", "", " text-right input-mask-brl") %>
            </div>
            <div class="col-xs-3">
                <%=quickfield("text", "CBIAltura", "Altura (mm)", 12, CBIAltura, "", "", " text-right input-mask-brl") %>
            </div>
            <div class="col-xs-3">
                <%=quickfield("number", "Posicao", "Posição incial na folha", 12, Posicao, "", "", "") %>
            </div>
            <div class="col-xs-3">
                <%=quickfield("number", "Quantidade", "Quantidade", 12, QuantidadePosicao, "", "", "") %>
            </div>
            <div class="col-xs-3">
                <%=quickfield("number", "MargemEsquerda", "Margem esquerda (mm)", 12, "0", "", "", "") %>
            </div>
            <div class="col-xs-2">
                &nbsp;<br />
                <button class="mt5 btn btn-block btn-md btn-primary" type="submit"><i class="far fa-barcode"></i> Gerar</button>
            </div>
            <div class="col-xs-2">
                &nbsp;<br />
                <button onclick="print()" class="mt5 btn btn-block btn-md btn-system" type="button"><i class="far fa-print"></i>&nbsp;</button>
            </div>
            <input type="hidden" name="etiqueta" value="<%=req("Etiquetas") %>" />
            <hr />
        </div>
    </form>
    <table align="center" style="float: left;">
        <tr>
        <%
        Posicao = ref("Posicao")
        if Posicao="" or not isnumeric(Posicao) then
            Posicao=1
        else
            Posicao = cint(Posicao)
        end if
        c = 0
        cv = 0

        if Colunas<>"" and isnumeric(Colunas) then
            db.execute("REPLACE INTO config_etiqueta (id,Largura,Altura,PosicaoInicial) VALUES (1, "&treatvalzero(ref("CBILargura"))&", "& treatvalzero(ref("CBIAltura"))&", "& treatvalzero(ref("Posicao")) & ")")

            Colunas = cint(Colunas)
            if Posicao>1 then
                while c<Posicao
                    c = c+1
                    cv = cv+1
                    %>
                        <td align="center"></td>
                    <%
                    if cv=Colunas then
                        response.write("</tr>")
                        response.write("<tr>")
                        cv = 0
                    end if
                wend
            end if
            c = cv
            spl = split(ref("etiqueta"),", ")
            Quantidade = ref("Quantidade")

            if not isnumeric(Quantidade) then
                Quantidade=1
            else
                Quantidade=ccur(Quantidade)
            end if


            for i = 0  to ubound(spl)
                if spl(i)<>"" then
                    set CodigoBarrasSQL = db.execute("SELECT ep.CBID, ep.Quantidade, p.NomeProduto, ep.Lote, ep.Validade FROM estoqueposicao ep INNER JOIN produtos p ON p.id=ep.ProdutoID WHERE ep.id="&spl(i))
                    CodigoDeBarras = CodigoBarrasSQL("CBID")

                    Lote = CodigoBarrasSQL("Lote")&""
					Validade = CodigoBarrasSQL("Validade")
					if not isnull(Validade) then
						Lote = Lote & "<br>Val.: "& Validade
					end if

                    if Lote<>"" then
                        Lote=" - "&Lote
                    end if

                    for j = 1  to Quantidade
                        c = c+1

                        if CodigoDeBarras<>"" then

                            %>
                                <td align="center" style="padding-left: <%=ref("MargemEsquerda")%>mm;">
                                    <img align="middle" name="CBInd"
                                    frameborder="0"
                                    src="https://api.feegow.com.br/barcode/render?type=code128&width_factor=2&content=<%= CodigoDeBarras %>" height="25"/>
                                    <br>
                                    <span style="font-size: 10px;"><%=CodigoDeBarras %></span>
                                     <br>
                                    <span style="font-size: 7px"><%=left(CodigoBarrasSQL("NomeProduto"),20)%><%=Lote%></span>

                                </td>
                            <%
                        else

                            %>
                                <td align="center" style="padding-left: <%=ref("MargemEsquerda")%>mm;">
                                    <code>Cod. barras não informado</code>
                                     <br>
                                    <span style="font-size: 7px"><%=left(CodigoBarrasSQL("NomeProduto"),20)%><%=Lote%></span>

                                </td>
                            <%
                        end if

                    if c=Colunas then
                        response.write("</tr>")
                        response.write("<tr>")
                        c = 0
                    end if
                    next

                end if
                Quantidade=1
            next
        end if
        %>
        </tr>
    </table>
<%
end if
%>