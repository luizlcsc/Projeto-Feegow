<!--#include file="../connect.asp"-->
<!--#include file="../Classes/Json.asp"-->
<%

AccountID           = req("AccountID")
searchAccountID     = req("searchAccountID")
DateFrom            = myDate(req("DateFrom"))
DateTo              = myDate(req("DateTo"))
LancadoPor          = req("LancadoPor")
Unidades            = req("Unidades")
Tipo                = req("Tipo")
pagina              = req("Pagina")
Formas              = req("Formas")
qtdPerPage          = req("qtdPerPage")
totaloffset = 0

offset = (pagina-1)*20

sqldiscover =   " 	(CASE                                                                                                                                               "&chr(13)&_
                "     WHEN tipocontaid = 1 then (select AccountName from sys_financialCurrentAccounts where id = cd.contaid)                                            "&chr(13)&_
                "     WHEN tipocontaid = 2 then (select NomeFornecedor from fornecedores where id = cd.contaid)                                                         "&chr(13)&_
                "     WHEN tipocontaid = 3 then (select NomePaciente from Pacientes where id = cd.contaid)                                                              "&chr(13)&_
                "     WHEN tipocontaid = 4 then (select NomeFuncionario from funcionarios where id = cd.contaid)                                                        "&chr(13)&_
                "     WHEN tipocontaid = 5 then (select NomeProfissional from profissionais where id = cd.contaid)                                                      "&chr(13)&_
                "     WHEN tipocontaid = 6 then (select NomeConvenio from convenios where id = cd.contaid)                                                              "&chr(13)&_
                "     WHEN tipocontaid = 7 then (select Descricao from caixa where id = cd.contaid)                                                                     "&chr(13)&_
                "     WHEN tipocontaid = 8 then (select NomeProfissional from profissionalexterno where id = cd.contaid)                                                "&chr(13)&_
                "     WHEN tipocontaid = 9 then (select NomeEmpresa from vw_unidades where id = cd.contaid)                                                             "&chr(13)&_
                " 	end) as nome,                                                                                                                                       "&chr(13)&_
                " 	(select PaymentMethod from sys_financialpaymentmethod sf where id= cd.tipopagamento) tipoPagamentoNome,                                             "&chr(13)&_
                " 	coalesce(sp_sysUserName(coalesce(cd.sysuser,(select sysUser from caixa where id = caixaid))),'Não identificado') as lancadoPor ,                    "

sqlbase =       " 	cd.id, cd.movementid, cd.data, cd.tipopagamento"

'filtro por tipo 
 select Case Tipo
    case 0
        sqlfiltroTipo = " ,round(cd.entrada,2) entrada, round(cd.saida,2) saida "
    case 1
        sqlfiltroTipo = " ,round(cd.entrada,2) entrada, 0 saida "
    case 2
        sqlfiltroTipo = " ,0 entrada, round(cd.saida,2) saida "
end select 
sqlbase = sqlbase&sqlfiltroTipo        
'fim

sqlbase = sqlbase&"  from "&chr(13)&_
                "  	movimentacoesfinanceiras cd "

sqlFiltroData = "  	and `data` between '"&DateFrom&"' and '"&DateTo&"' "

sqlFiltro = sqlFiltroData


' filtro de conta 
if AccountID&"" <> "" and AccountID <> "0" then 
    splAccountID = split(AccountID,"_") 
    idAccount = splAccountID(1)
    tipoAccount = splAccountID(0)
    sqlfiltroContaJoin = ""
    sqlfiltroContaWhere = ""

    select Case tipoAccount
	    case 1
            sqlfiltroContaJoin =  " left join sys_financialCurrentAccounts fca on fca.id = cd.contaid "
            sqlfiltroContaWhere  = " and fca.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 2
            sqlfiltroContaJoin =  " left join fornecedores f on f.id = cd.contaid "
            sqlfiltroContaWhere  = " and f.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 3
            sqlfiltroContaJoin =  " left join Pacientes p on p.id = cd.contaid "
            sqlfiltroContaWhere  = " and p.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 4
            sqlfiltroContaJoin =  " left join funcionarios f on f.id = cd.contaid "
            sqlfiltroContaWhere  = " and f.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 5
            sqlfiltroContaJoin =  " left join profissionais p on p.id = cd.contaid "
            sqlfiltroContaWhere  = " and p.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 6
            sqlfiltroContaJoin =  " left join convenios c on c.id = cd.contaid "
            sqlfiltroContaWhere  = " and c.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 7
            sqlfiltroContaJoin =  " left join caixa c on c.id = cd.contaid "
            sqlfiltroContaWhere  = " and c.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 8
            sqlfiltroContaJoin =  " left join profissionalexterno pe on pe.id = cd.contaid "
            sqlfiltroContaWhere  = " and pe.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
        case 9
            sqlfiltroContaJoin =  " left join vw_unidades u on u.id = cd.contaid "
            sqlfiltroContaWhere  = " and u.id = "&idAccount
            sqlbase = sqlbase&sqlfiltroContaJoin
            sqlFiltro = sqlFiltro& sqlfiltroContaWhere
    End Select
end if
' fim


' filtro lancado por
if LancadoPor&"" <> "" then
    sqlfiltroLancadoPor = " and cd.sysuser = "&LancadoPor
    sqlFiltro = sqlFiltro&sqlfiltroLancadoPor
end if
'fim 

' filtro Formas
if Formas&"" <> "" then
    splFormas = split(Formas,",")

    for index = 0 To ubound(splFormas)
        if index > 0 then 
            ids = ids&","
        end if
        ids = ids & replace(splFormas(index),"|","")
    next

    sqlfiltroFormas = " and cd.tipopagamento in ("&ids&")"
    sqlFiltro = sqlFiltro&sqlfiltroFormas
end if
'fim 

sqlbase = sqlbase&  "  where "&chr(13)&_
                    "  	true "


orderby = " order by data asc "

' esse sql tras os dados para montar as linhas da tabela
sqlpesquisa = "select "&sqldiscover&sqlbase&sqlFiltro&orderby&" LIMIT 20 OFFSET "&offset
' dd(sqlpesquisa)
set pesquisa  = db_execute(sqlpesquisa)
' fim 

' esse sql tras os valor total ja movimentado na conta antes da data selecionada
sqlSaldoAnterior =  " and `data` > '"&DateFrom&"'"
sqlvalortotal = "select round(round(sum(s.entrada),2)-round(sum(s.saida),2),2) saldoAnterior from ( select "&sqlbase&sqlFiltro&sqlSaldoAnterior&") as s"
set saldoAnterior =  db_execute(sqlvalortotal)
saldoAnteriorValor = ccur(saldoAnterior("saldoAnterior"))
' fim


' essa tratativa é para trazer a diferença de saldo entre o total e as paginas navegadas 
if pagina > 1 then
    set totaloffsetsql  = db_execute(" select round(round(sum(plus.entrada),2)-round(sum(plus.saida),2),2) saldoAnterior from (select "&sqlbase&sqlFiltro&orderby&" LIMIT "&offset&") as plus" )
    totaloffset = totaloffsetsql("saldoAnterior")
end if 
saldoAnteriorValor = saldoAnteriorValor + ccur(totaloffset)
' fim 

' converte os dados em json
dadosDaPagina = recordToJSON(pesquisa)
'fim

' esse sql pega a quatidade total de linhas para saber quantas paginas precisa ser montada
set quantidade = db.execute("select count(0) as total from ( select "&sqlbase&sqlFiltro&") as t")
qtdpPagina = Ceil(cint(quantidade("total"))/cint(qtdPerPage))
' fim

%>
{
    "saldoAnterior" : "<%=saldoAnteriorValor%>",
    "dadosDaPagina" : <%=dadosDaPagina%>,
    "pagina"        : <%=pagina%>,
    "qtdpPagina"    : <%=qtdpPagina%>,
    "totaloffset"   : <%=totaloffset%>
}
<%





%>