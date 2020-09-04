<!--#include file="../connect.asp"-->
<%
optante = req("optante")
cnpj = req("cnpj")

if optante = true then
    sql = "INSERT INTO cliniccentral.cnpj_info (CNPJ, NomeEmpresarial, SituacaoSimples, SimplesPeriodos, SimplesAgendamentos, SimplesEventos, SituacaoSimei, SimeiPeriodos, SimeiEventos, DataHora) VALUES ('"&cnpj&"', 'CLINICA MEDICA DR. MEYRON EIRELI ', 'Optante pelo Simples Nacional desde 01/01/2018  ', '', 'Não Existem', 'Não Existem', 'NÃO optante pelo SIMEI ', 'Não Existem', 'Não Existem', '2019-09-13 10:51:06');"
else
    sql = "INSERT INTO cliniccentral.cnpj_info (CNPJ, NomeEmpresarial, SituacaoSimples, SimplesPeriodos, SimplesAgendamentos, SimplesEventos, SituacaoSimei, SimeiPeriodos, SimeiEventos, DataHora) VALUES ('"&cnpj&"', 'GERIATRE ENSINO E ASSISTENCIA MEDICA LTDA. ', 'NÃO optante pelo Simples Nacional ', 'Não Existem', 'Não Existem', 'Não Existem', 'NÃO optante pelo SIMEI ', 'Não Existem', 'Não Existem', '2019-09-13 10:51:12');"
end if

db.execute(sql)
response.write("true")
%>

