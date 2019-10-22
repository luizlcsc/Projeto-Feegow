<!--#include file="connect.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%
parcelas = Request.QueryString("parcelas")
bandeira = Request.QueryString("bandeira")
formaPagamento = Request.QueryString("formaPagamento")
contaCorrente = Request.QueryString("contaCorrente")
unidade = Request.QueryString("unidade")

sysFormasrectoId = Request.QueryString("sysFormasrectoId")


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