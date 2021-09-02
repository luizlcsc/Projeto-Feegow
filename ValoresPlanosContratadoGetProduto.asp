<!--#include file="connect.asp"-->
<%
    tipo = req("tipo")

    if tipo = 3 then
        sql = "SELECT id, if(tipoproduto=3,concat('Material - ',NomeProduto),concat('Medicamento - ',NomeProduto)) NomeProduto FROM produtos WHERE TipoProduto IN (3) ORDER BY NomeProduto"
        nome = "Materiais"
    elseif tipo = 4 then
        sql = "SELECT id, if(tipoproduto=3,concat('Material - ',NomeProduto),concat('Medicamento - ',NomeProduto)) NomeProduto FROM produtos WHERE TipoProduto IN (4) ORDER BY NomeProduto"
        nome = "Medicamentos"
    else 
        sql = "SELECT id, if(tipoproduto=3,concat('Material - ',NomeProduto),concat('Medicamento - ',NomeProduto)) NomeProduto FROM produtos WHERE TipoProduto IN (3, 4) ORDER BY NomeProduto"
        nome = "Materiais e Medicamentos"
    end if 

    retorno = quickfield("multiple", "Produtos[0]", nome , 12, Produtos, sql, "NomeProduto", "")


    response.write(retorno)

%>

<script>
<!--#include file="JQueryFunctions.asp"-->
</script>