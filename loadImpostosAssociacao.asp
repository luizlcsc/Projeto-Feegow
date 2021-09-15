<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"
' response.ContentType = "application/json"
convenio    = req("convenio")

sql =   " select                                                            "&chr(13)&_
        " 	ia.id id_ia,                                                    "&chr(13)&_
        " 	i.nome as imposto,                                              "&chr(13)&_
        " 	fe.name as planoContas,                                         "&chr(13)&_
        " 	fe.id,                                                          "&chr(13)&_
        " 	cc.NomeCentroCusto as CentroCusto,                              "&chr(13)&_
        " 	cc.id id_cc,                                                    "&chr(13)&_
        " 	ia.valor,                                                       "&chr(13)&_
        " 	ia.de,                                                          "&chr(13)&_
        " 	ia.ate                                                          "&chr(13)&_
        " from                                                              "&chr(13)&_
        " 	impostos_associacao ia                                          "&chr(13)&_
        " 	left join sys_financialexpensetype fe on ia.planoContas = fe.id "&chr(13)&_
        " 	left join centrocusto cc on ia.CentroCusto = cc.id              "&chr(13)&_
        " 	left join impostos i on ia.imposto = i.id                       "&chr(13)&_
        " where                                                             "&chr(13)&_
        " 	ia.convenio ="&convenio

set impostos = db_execute(sql)
contadorImposto = 1
%>
[
<%

while not impostos.eof 
  if contadorImposto > 1 then
    %>
    ,
    <%
   end if
   %>
{

    "id":             <%=impostos("id_ia")%>,
    "imposto":        "<%=impostos("imposto")%>",
    "planoContas":    "<%=impostos("planoContas")%>",
    "CentroCusto":    "<%=impostos("CentroCusto")%>",
    "valor":          "<%=impostos("valor")%>",
    "de":             "<%=impostos("de")%>",
    "ate":            "<%=impostos("ate")%>",
    "contratos":[
    <%
        sqlContratos =  " select                                                                "&chr(13)&_
                        " 	icc.contratosConvenio_id,                                           "&chr(13)&_
                        " 	cc.CodigoNaOperadora                                                "&chr(13)&_
                        " from                                                                  "&chr(13)&_
                        " 	impostos_contratos_convenio icc                                     "&chr(13)&_
                        " 	left join contratosconvenio cc on icc.contratosConvenio_id = cc.id  "&chr(13)&_
                        " where                                                                 "&chr(13)&_
                        " 	icc.impostos_associacao_id =                                        "&impostos("id_ia")
        set contratos = db_execute(sqlContratos)
        contador = 1
        while not contratos.eof 
            if contado > 1 then 
            %>
            ,
            <%
            end if 
        %>
            {
                "contrato_id":    <%=contratos("contratosConvenio_id")%>,
                "contrato_nome":  "<%=contratos("CodigoNaOperadora")%>"
            }

        <%
        contratos.movenext
        contador = contador+1
        wend
    %>
    ]
}
<%
   impostos.movenext
   contadorImposto = contadorImposto+1
wend
%>
]
<%
response.end
%>