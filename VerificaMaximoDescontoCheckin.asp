<!--#include file="connect.asp"-->
<!--#include file="Classes/ValidaDesconto.asp"-->

<%

' parâmetros
Procedimentos = req("Procedimentos")
PercDesconto  = req("PercDesconto")

if not isnumeric(PercDesconto) then
    PercDesconto=0
end if

' valida o parametro procedimento
if Procedimentos = "" then
    Response.Status = "400 Bad Request"
    Response.Write("Parametro Procedimentos nao informado")
    Response.end
end if

arrProcedimentos = split(Procedimentos, "|")
for i=0 to ubound(arrProcedimentos)

    arrProcedimento = split(arrProcedimentos(i), "_")
    ProcedimentoID  = arrProcedimento(0)

    if not isnumeric(ProcedimentoID) then
        Response.Status = "422"
        Response.Write("Procedimento " & ProcedimentoID & " invalido")
        Response.end
    end if

    if ubound(arrProcedimento) < 1 then
        Response.Status = "422"
        Response.Write("Valor do procedimento " & ProcedimentoID & " nao informado")
        Response.end
    end if 
    
    ProcedimentoValor = arrProcedimento(1)
    if not isnumeric(ProcedimentoValor) then
        Response.Status = "422"
        Response.Write("Valor do procedimento " & ProcedimentoID & " invalido")
        Response.end
    end if
next

' valida o desconto
Set result = ValidaDesconto("Checkin", Procedimentos, session("User"), session("UnidadeID"), PercDesconto)

temRegraCadastrada             = result.Item("temRegraCadastrada")
temRegraCadastradaProUsuario   = result.Item("temRegraCadastradaProUsuario")
temDescontoParaOGrupoDoUsuario = result.Item("temDescontoParaOGrupoDoUsuario")
temRegraSuperior               = result.Item("temRegraSuperior")
regrasSuperiores               = result.Item("regrasSuperiores")
totalProcedimentos             = result.Item("totalProcedimentos")
percMaximoDesconto             = result.Item("percMaximoDesconto")
valido                         = result.Item("valido")


' formata a resposta em JSON
Response.ContentType = "application/json" 
%>
{
    "temRegraCadastrada": <% if temRegraCadastrada then response.write("true") else response.write("false") end if%>,
    "temRegraCadastradaProUsuario": <% if temRegraCadastradaProUsuario then response.write("true") else response.write("false") end if%>,
    "temDescontoParaOGrupoDoUsuario": <% if temDescontoParaOGrupoDoUsuario then response.write("true") else response.write("false") end if%>,
    "temRegraSuperior": <% if temRegraSuperior then response.write("true") else response.write("false") end if%>,
    "regrasSuperiores": "<%=regrasSuperiores%>",
    "totalProcedimentos": <%=Replace(totalProcedimentos, ",", ".")%>,
    "percMaximoDesconto": <%=Replace(percMaximoDesconto, ",", ".")%>,
    "valido": <% if valido then response.write("true") else response.write("false") end if%>
}
