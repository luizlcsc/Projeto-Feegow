<!--#include file="connect.asp"-->
<%
Parcela = replace(ref("Parcela"), "|", "")
DataPagto = cdate(ref("DataPagto"))
set mov = db.execute("select * from sys_financialmovement where id IN("&Parcela&")")
while not mov.eof
    Valor = mov("Value")
    Vencimento = mov("Date")
    if Vencimento<DataPagto then
        ValorM = Valor * 0.02
        DiasAtraso = datediff("d", Vencimento, DataPagto)
        ValorJ = Valor * 0.002 * DiasAtraso
    end if
mov.movenext
wend
mov.close
set mov=nothing

response.Write( "Multa: "& fn(valorM) )
response.Write( "<br> Juros: "& fn(valorJ) )
response.Write( "<br> Total: "& fn(ValorM + valorJ) )
'response.Write( "<br> Dias atraso: "& DiasAtraso )
%>
<script type="text/javascript">
    $("#ValorPagto").val("<%=fn( Valor + ValorM + ValorJ ) %>");
</script>
