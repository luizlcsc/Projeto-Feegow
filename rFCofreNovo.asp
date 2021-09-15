<%
if req("debug")="" then
''    response.end
end if
%>
<!--#include file="connect.asp"-->
<style>
body{font-size:14px;}
th{vertical-align: top !important;}

@media print {
    body{font-size:11px;}
}
</style>


<%
Unidades = req("Unidades")
De = req("De")
mDe = mydatenull(De)
Ate = req("Ate")
mAte = mydatenull(Ate)
TipoData = req("TipoData")

%>
<h2 class="text-center">Fechamento de Cofre<br />
    <small> Período: <%=De%> a <%=Ate%></small>
</h2>
<%
    gtVendas = 0
    gqVendas = 0
    gtoData = 0
    gqoData = 0
    gtmData = 0
    gqmData = 0


set unidade = db.execute("select id, NomeFantasia, Sigla from (select '0' id, NomeFantasia, Sigla from empresa UNION ALL select id, NomeFantasia, Sigla from sys_financialcompanyunits) t where t.id IN ("&Unidades&") ")
while not unidade.eof
    NomeFantasia = unidade("NomeFantasia")
    UnidadeID = unidade("id")
    Sigla = unidade("Sigla")
    tVendas = 0
    qVendas = 0
    tmData = 0
    qmData = 0
    toData = 0
    qoData = 0

    'pegando as faturas do período
    sql = "SELECT inv.sysActive FaturaAtiva, inv.Name DescricaoExclusao, inv.id InvoiceID, inv.NumeroFatura, inv.AssociationAccountID, inv.AccountID, inv.NRoNFe, inv.sysDate DataFatura, (select ifnull(sum(Value),0) from sys_financialmovement where Type='Bill' AND InvoiceID=inv.id) Value, pagto.id, rec.sysActive, rec.sysDate dataRecibo, tab.NomeTabela, "&_
	"inv.sysDate datainvoice, "&_
	"pagto.Date dataPagto, pagto.Value valorPago, "&_
	"pm.PaymentMethod "&_
	"FROM sys_financialinvoices inv  "&_
	"LEFT JOIN recibos rec ON inv.id=rec.InvoiceID AND rec.sysActive=1 "&_
	"LEFT JOIN sys_financialmovement parc ON parc.InvoiceID=inv.id "&_
	"LEFT JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=parc.id  "&_
	"LEFT JOIN sys_financialmovement pagto ON pagto.id=dp.MovementID  "&_
	"LEFT JOIN sys_financialpaymentmethod pm ON pm.id=pagto.PaymentMethodID  "&_
    "LEFT JOIN tabelaparticular tab ON tab.id=inv.TabelaID "&_
	"WHERE inv.AssociationAccountID=3 and not isnull(inv.AccountID)  "&_
	"AND (pagto.CD='D' OR ISNULL(pagto.CD))  "&_
	"AND inv.CompanyUnitID="& UnidadeID &" "&_
	"AND (  "&_
	"	inv.sysDate BETWEEN "& mDe &" AND "& mAte &"  "&_
	"	OR  "&_
	"	pagto.Date BETWEEN "& mDe &" AND "& mAte &"  "&_
	") GROUP BY inv.id ORDER BY inv.NumeroFatura, inv.id"

    'sql = "select i.*, tab.NomeTabela from sys_financialinvoices i "&_
    '                        "LEFT JOIN tabelaparticular tab ON tab.id=i.TabelaID "&_
    '                        " where i.CD='C' AND i.CompanyUnitID="& UnidadeID &" AND i.sysDate BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND NOT ISNULL(i.AccountID) ORDER BY i.id")

    set fat = db.execute( sql )
    if not fat.eof then
        %>
        <%= "<h2>"& NomeFantasia &"</h2>" %>
        <%
        while not fat.eof
            DescricaoExclusao = ""
            FaturaAtiva = fat("FaturaAtiva")
            cl = 0
            DataFatura = fat("DataFatura")
            if DataFatura>=cdate(De) and DataFatura<=Ate then
                classeFat = "primary"
                tVendas = tVendas + fat("Value")
                if fat("Value")>0 then
                    qVendas = qVendas + 1
                    gqVendas = gqVendas + 1
                elseif FaturaAtiva=-1 then
                    classeFat = "danger"
                    DescricaoExclusao = "<br><span class='label label-danger'>"& fat("DescricaoExclusao") &"</span>"
                else
                    classeFat = "dark"
                end if
                gtVendas = gtVendas + fat("Value")
            else
                classeFat = "warning"
            end if
            %>
            <table class="table table-condensed mt25">
                <thead>
                    <tr class="<%= classeFat %>">
                        <th width="1%">
                            <a class="btn btn-<%= classeFat %> btn-xs" href="./?P=invoice&Pers=1&CD=C&I=<%= fat("InvoiceID") %>" target="_blank">
                                <i class="far fa-external-link"></i>
                            </a>
                        </th>
                        <th width="10%" rowspan="20"><%= "Fatura "& DataFatura &" <br> "& sigla & fat("NumeroFatura") %></th>
                        <th width="50%"><%= "Paciente <br> "& nameInAccount( fat("AssociationAccountID") &"_"& fat("AccountID")) & DescricaoExclusao %></th>
                        <th width="15%"><%= "Tabela <br> "& fat("NomeTabela") %></th>
                        <th width="10%"><%= "Desconto" %></th>
                        <th width="10%"><%= "Valor" %></th>
                        <th width="10%" id="nf<%= fat("id") %>">

                            <%
                            set rec = db.execute("select r.*, u.Sigla from recibos r LEFT JOIN sys_financialcompanyunits u ON u.id=r.UnidadeID where r.InvoiceiD="& fat("InvoiceID") &"")
                            if rec.eof then
                                classe = "bg-danger"
                            else
                                classe = ""
                            end if
                            %>

                            <div class="mt50" style="position:absolute; background-color:#fff; ">
                                <div class="panel-body p5">
                                <%
                                while not rec.eof
                                    if rec("sysActive")=1 then
                                        estilo = ""
                                    else
                                        estilo = " style='text-decoration:line-through; color:#f00' "
                                    end if
                                    %>
                                    <div <%= estilo %> >
                                        <%= rec("Sigla") & rec("NumeroSequencial") &" :: R$ "& fn(rec("Valor"))%>
                                    </div>
                                    <%
                                rec.movenext
                                wend
                                rec.close
                                set rec = nothing
                                %>
                                </div>
                            </div>

                            <%= "NFS-e <br> "& fat("NRoNFe") %>
                        </th>
                        <th nowrap width="10%" id="val<%= fat("InvoiceID") %>"><%= "Valor da Conta <br> R$ "& fn(fat("Value")) %></th>
                    </tr>
                </thead>
                <%
                set procDados = db.execute("SELECT ii.Quantidade, ii.ValorUnitario, ii.Acrescimo, ii.Desconto, ii.Tipo, (CASE ii.Tipo WHEN 'O' THEN ii.Descricao WHEN 'M' THEN prod.NomeProduto ELSE proc.NomeProcedimento END) NomeProcedimento, ii.PacoteID "&_
                                        "FROM itensinvoice ii "&_
                                        "LEFT JOIN procedimentos proc ON proc.id=ii.ItemID "&_
                                        "LEFT JOIN produtos prod ON prod.id=ii.ItemID "&_
                                        "WHERE ii.Tipo<>'K' AND ii.InvoiceID="& fat("InvoiceID")&" ORDER BY ii.id")


                while not procDados.eof
                    Pacote = procDados("PacoteID")
                    if Pacote&""<>"" then
                        Pacote = "(Pacote)"
                    end if
                    if procDados("Tipo")="O" then
                        Tipo="Outro"
                    elseif procDados("Tipo")="M" then
                        Tipo="Produto"
                    else
                        Tipo="Serviço"
                    end if

                    cl = cl+1

                    Total=procDados("Quantidade")*(procDados("ValorUnitario")+procDados("Acrescimo")-procDados("Desconto"))

                    DescontoItem=procDados("Desconto")
                    PercentualDescontoDescricao=""

                    if procDados("ValorUnitario")>0 then
                        PercentualDescontoItem=(procDados("Desconto")/procDados("ValorUnitario"))*100

                        if PercentualDescontoItem>0 then
                            PercentualDescontoDescricao = " <i>("&fn(PercentualDescontoItem)&"%)</i> "
                        end if
                    end if

                %>
                <tr>
                    <td></td>
                    <td></td>
                    <td><b><%=Tipo%>:</b> <%=procDados("Quantidade")&"x "&procDados("NomeProcedimento")&" "&Pacote%></td>
                    <td></td>
                    <td><%= "R$ "& fn( DescontoItem )%><%=PercentualDescontoDescricao%></td>
                    <td class="text-right"><%= "R$ "& fn( Total )%></td>
                </tr>
                <%
                procDados.movenext
                wend
                procDados.close
                set procDados=nothing

                InvoiceID=fat("InvoiceID")

                'pegando os recebimentos desta fatura

                sqlPagamentos="SELECT * FROM (select pg.id, count(mPag.id) Qtd, mPag.Date DataPagto, SUM(mPag.Value) Value, pm.PaymentMethod, mPag.PaymentMethodID, ifnull(t.Parcelas, 1) Parcelas, null StatusBoleto, b.Bandeira  from sys_financialdiscountpayments pg "&_
                " LEFT JOIN sys_financialmovement mBill ON mBill.id=pg.InstallmentID "&_
                " LEFT JOIN sys_financialmovement mPag ON mPag.id=pg.MovementID "&_
                " LEFT JOIN sys_financialpaymentmethod pm ON pm.id=mPag.PaymentMethodID "&_
                " LEFT JOIN sys_financialcreditcardtransaction t ON t.MovementID=mPag.id "&_
                " LEFT JOIN cliniccentral.bandeiras_cartao b ON b.id=t.BandeiraCartaoID "&_
                " WHERE mBill.UnidadeID="& UnidadeID &" AND mPag.Type='Pay' AND mPag.CD='D' AND mBill.InvoiceID="&InvoiceID&" GROUP BY mPag.Date, mPag.PaymentMethodID, t.Parcelas "&_
                " UNION ALL "&_
                " select bol.id, count(bol.id) Qtd, mBill.Date DataPagto, SUM(bol.AmountCents/ 100) Value, 'Boleto' PaymentMethod, 4 PaymentMethodID, 1 Parcelas, bolSta.NomeStatus StatusBoleto, null Bandeira " &_
                " FROM boletos_emitidos bol " &_
                " INNER JOIN sys_financialmovement mBill ON mBill.id=bol.MovementID " &_
                " INNER JOIN sys_financialinvoices inv ON inv.id=bol.InvoiceID " &_
                " INNER JOIN cliniccentral.boletos_status bolSta ON bolSta.id=bol.StatusID " &_
                " WHERE inv.CompanyUnitID="& UnidadeID &" AND inv.sysDate BETWEEN "& mDe &" AND "& mAte &" AND inv.CD='C' " &_
                " AND mBill.InvoiceID="&InvoiceID&" "&_
                " AND bol.StatusID NOT IN (2,5,6,7) HAVING Value > 0 " &_                
                ")t"

                set pg = db.execute(sqlPagamentos)

                if pg.eof AND Total>0 then

                    set BoletoEmitidoSQL = db.execute("SELECT b.* FROM boletos_emitidos b WHERE b.InvoiceID="&InvoiceID&" AND b.StatusID IN (1)")

                    if not BoletoEmitidoSQL.eof then

                        %>
                        <tr>
                            <td colspan="2"></td>
                            <td class="warning" colspan="2">Boleto emitido</td>
                        </tr>
                        <%

                    else

                        %>
                        <tr>
                            <td colspan="2"></td>
                            <td class="danger" colspan="2">Nenhum pagamento lançado.</td>
                        </tr>
                        <%
                    end if
                end if

                if not pg.eof then
                    %>
<tr class="" >
<td colspan="2"></td>
<td colspan="4"><b>Pagamento(s) realizado(s):</b></td>
</tr>
                    <%
                end if

                while not pg.eof
                    cl = cl+1
                    DataPagto = pg("DataPagto")
                    AvisoDataDivergente = False

                    if DataPagto>=cdate(De) and DataPagto<=Ate then
                        classePagto = ""
                        if DataFatura<>pg("DataPagto") then
                            toData = toData + pg("Value")
                            qoData = qoData + 1
                            gtoData = gtoData + pg("Value")
                            gqoData = gqoData + 1
                        else
                            tmData = tmData + pg("Value")
                            qmData = qmData + 1
                            gtmData = gtmData + pg("Value")
                            gqmData = gqmData + 1
                        end if
                    else
                        classePagto = "warning"
                        AvisoDataDivergente = True
'                        toData = toData + pg("Value")
'                        qoData = qoData + 1
'                        gtoData = gtoData + pg("Value")
'                        gqoData = gqoData + 1
                    end if


                    Descricao = pg("PaymentMethod")
                    Subdescricao=""

                    Parcelas = pg("Parcelas")
                    if ccur(pg("PaymentMethodID"))=8 then
                        Descricao = Parcelas &"x "& Descricao &" ("& pg("Bandeira") &")"
                    end if

                    if ccur(pg("PaymentMethodID"))=4 then
                        StatusBoleto = pg("StatusBoleto")
                        ClasseBadgeStatusBoleto = "warning"

                        if StatusBoleto="Paga" then
                            ClasseBadgeStatusBoleto="success"
                        end if

                        Subdescricao = "<span class='label label-"&ClasseBadgeStatusBoleto&"'>"&StatusBoleto&"</span>"

                    end if
                    %>
                    <tr class="<%= classePagto %>">
                        <td colspan="2"></td>
                        <td><em><%= DataPagto &" > "&  Descricao %></em> <small><%=Subdescricao%></small>
                        <%
                        if AvisoDataDivergente then
                        %> 
                        <span class="badge badge-pill badge-warning"><i class="far fa-info-circle"></i> Data do recebimento divergente </span>
                        <%
                        end if
                        %>
                        </td>
                        <td></td>
                        <td></td>
                        <td class="text-right"><b><em><%= "R$ "& fn(pg("Value")) %></em></b></td>
                    </tr>
                    <%
                pg.movenext
                wend
                pg.close
                set pg = nothing
                %>
            </table>
            <%
        fat.movenext
        wend
        fat.close
        set fat = nothing
    end if

    'pegando os pagtos do período
    set pg = db.execute("SELECT * FROM (select pg.id, count(mPag.id) Qtd, mPag.Date DataPagto, SUM(mPag.Value) Value, pm.PaymentMethod, mPag.PaymentMethodID, ifnull(t.Parcelas, 1) Parcelas from sys_financialdiscountpayments pg "&_
                " LEFT JOIN sys_financialmovement mBill ON mBill.id=pg.InstallmentID "&_
                " LEFT JOIN sys_financialmovement mPag ON mPag.id=pg.MovementID "&_
                " LEFT JOIN sys_financialpaymentmethod pm ON pm.id=mPag.PaymentMethodID "&_
                " LEFT JOIN sys_financialcreditcardtransaction t ON t.MovementID=mPag.id "&_
                " WHERE mBill.UnidadeID="& UnidadeID &" AND mPag.Date BETWEEN "& mDe &" AND "& mAte &" AND mPag.Type='Pay' AND mPag.CD='D' GROUP BY mPag.PaymentMethodID, t.Parcelas "&_
                " UNION ALL "&_
                " select bol.id, count(bol.id) Qtd, mBill.Date DataPagto, SUM(bol.AmountCents/ 100) Value, 'Boleto' PaymentMethod, 4 PaymentMethodID, 1 Parcelas " &_
                " FROM boletos_emitidos bol " &_
                " INNER JOIN sys_financialmovement mBill ON mBill.id=bol.MovementID " &_
                " INNER JOIN sys_financialinvoices inv ON inv.id=bol.InvoiceID " &_
                " WHERE inv.CompanyUnitID="& UnidadeID &" AND inv.sysDate BETWEEN "& mDe &" AND "& mAte &" AND inv.CD='C' " &_
                " AND bol.StatusID NOT IN (2,5,6,7) HAVING Value > 0" &_
                
                ")t")

    idsPagto = 0

    if not pg.eof then
        %>
        <table class="table">
            <thead>
                <tr class="success">
                    <th width="1%"><a class="btn-success btn-xs"><i class="far fa-check-circle"></i></a></th>
                    <th>Quantidade</th>
                    <th>Forma de pagamento</th>
                    <th>Valor</th>
                </tr>
            </thead>
        <%
        while not pg.eof
            idsPagto = idsPagto &", "& pg("id")

            Descricao = pg("PaymentMethod")
            Parcelas = pg("Parcelas")
            if ccur(pg("PaymentMethodID"))=8 then
                Descricao = Parcelas &"x "& Descricao
            end if
            
            %>
            <tr>
                <td></td>
                <td><%= pg("Qtd") %></td>
                <td><%= Descricao %></td>
                <td><%= fn(pg("Value")) %></td>
            </tr>
            <%
        pg.movenext
        wend
        pg.close
        set pg = nothing
        %>
        </table>
        <div class="row m5 alert alert-dark">
            <div class="col-xs-4">
                Vendas no Período<br> R$ <%= fn(tVendas) %> (<%= qVendas %>)
            </div>
            <div class="col-xs-4">
                Recebimentos do período <br> R$ <%= fn(tmData) %> (<%= qmData %>)
            </div>
            <div class="col-xs-4">
                Recebimentos de outras datas <br> R$ <%= fn(toData) %> (<%= qoData %>)
            </div>
        </div>
        <hr class="short alt mt50 mb50" style="page-break-after:always">
        <%
    end if

'response.write( idsPagto )

unidade.movenext
wend
unidade.close
set unidade=nothing

%>
<h2>Consolidado</h2>
<div class="row m5 alert alert-dark">
    <div class="col-xs-4">
        Vendas no Período<br> R$ <%= fn(gtVendas) %> (<%= gqVendas %>)
    </div>
    <div class="col-xs-4">
        Recebimentos do período <br> R$ <%= fn(gtmData) %> (<%= gqmData %>)
    </div>
    <div class="col-xs-4">
        Recebimentos de outras datas <br> R$ <%= fn(gtoData) %> (<%= gqoData %>)
    </div>
</div>
