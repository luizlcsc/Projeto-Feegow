<!--#include file="connect.asp"-->
<%
response.write("<script type='text/javascript'>")

DataCredito = ref("DataCredito")
spl = split(ref("parcCC"), ", ")
somaBruta = ccur(ref("Soma"))
valorBaixar = ccur(ref("ValorBaixar"))
coef = valorBaixar/somaBruta

for i=0 to ubound(spl)
    valorCheio = ccur(ref("ValorCheio" & spl(i)))
    valorLiquido = valorCheio * coef
    soma = soma + valorCheio






    'fator = 100 / valorLiquido
    'taxa = 100 - (fator * valorCheio)
    taxa = coef * 100
    taxa = 100-taxa

        
        response.write("$('#Fee"& spl(i) &"').val('"& fn(taxa) &"');")
        response.write("$('#ValorCredito"& spl(i) &"').val('"& fn(valorLiquido) &"');")
        response.write("$('#DateToReceive"& spl(i) &"').val('"& DataCredito &"');")
        

    'response.Write( valorCheio & " - " & valorLiquido &" - "& taxa &"<br>")
next

response.write("</script>")
%>