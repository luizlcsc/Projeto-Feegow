<!--#include file="connect.asp"-->
<pre>
== Filtro baseado no agendamento vindo da invoiceID==
1. Formas de pagamento permitido na unidade agendada
2. Verifica os grupos de procedimento
3. Join com tabela que identifique o procedimento
4. While formaspgto where IN(procedimentoID)
5. While formaspgto where IN(procedimentosgrupos "id negativo" join procedimentoID)
6. replace duplicatas dos itens ALL, ONLY e EXCEPT

1. Método = Dinheiro: Procedimentos = TODOS         || Resultado: 1,2,3,4,5,6,7,8,9,10
2. Método = Dinheiro: Procedimentos = EXCETO 1,2,3  || Resultado: 4,5,6,7,8,9,10
2. Método = Dinheiro: Procedimentos = SOMENTE 3,4   || Resultado: 4


</pre>
<%
'SELECT
'procedimentos
'procedimentosgrupos
'invoiceid
%>
