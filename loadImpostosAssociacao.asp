<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
convenio    = req("convenio")

sql = "select * from impostos_associacao where convenio = "&convenio
set impostos = db_execute(sql)

while not impostos.eof then
%>
{
    id: <%=impostos("id")%>
    convenio: <%=impostos("convenio")%>
    imposto: <%=impostos("imposto")%>
    planoContas: <%=impostos("planoContas")%>
    CentroCusto: <%=impostos("CentroCusto")%>
    valor: <%=impostos("valor")%>
    de: <%=impostos("de")%>
    ate: <%=impostos("ate")%>
    contratos:[
    <%
        sqlContratos = "select contratosConvenio_id from impostos_associacao where impostos_associacao_id = "&impostos("id")
        set contratos = db_execute(sqlContratos)
        while not contratos.eof then
        %>
            {
                contrato: <%=contratos("contratosConvenio_id")%>
            }
        <%
        contratos.movenext
        wend
    %>
    ]
}
<%
   impostos.movenext
wend
%>