<!--#include file="connect.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%
parcelas = req("parcelas")
bandeira = req("bandeira")
formaPagamento = req("formaPagamento")
contaCorrente = req("contaCorrente")
unidade = req("unidade")

sysFormasrectoId = req("sysFormasrectoId")


db.execute("SET SESSION group_concat_max_len = 1000000; ")

set formaRecebimento = db.execute("SELECT id, acrescimo, tipoAcrescimo, desconto, replace(bandeiras, '|', '') bandeiras, parcelasDe, parcelasAte, tipoDesconto "&_
                                   " FROM sys_formasrecto where id = '"&sysFormasrectoId&"'")

Response.ContentType = "application/json" 

valorCheck = recordToJSON(formaRecebimento)

if not IsNull(valorCheck) then
    response.write(valorCheck)   
    response.end
end if

response.write("{}")
response.end
%>