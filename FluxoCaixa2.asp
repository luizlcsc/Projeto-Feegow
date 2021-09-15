<!--#include file="connect.asp"-->

<style type="text/css">
    body {
        font-size:10px;
    }
</style>

<%
De = req("De")
Ate = req("Ate")
TipoFC = req("TipoFC")

if TipoFC="D" then
    nomeTipo = "Diário"
elseif TipoFC="M" then
    nomeTipo = "Mensal"
    De = req("DeM")
    Ate = DiaMes("U", req("AteM"))
elseif TipoFC="S" then
    nomeTipo = "Semanal"
    De = req("DeM")
    Ate = DiaMes("U", req("AteM"))
end if
Unidades = replace(req("UnidadeID"), "|", "")

if cdate(De)>cdate(Ate) then
    erro = "A data final não pode ser menor que a data inicial."
end if
if datediff("m", Ate, De)>4 then
    erro = "Selecione um período máximo de 4 meses."
end if
if erro<>"" then
    %>
    <div class="alert alert-warning m25">
            <button class="pull-right btn-xs btn btn-default" type="button" onclick="window.close()">
                <i class="far fa-remove"></i> FECHAR
            </button>

        <%= erro %></div>
    <%
    response.End
end if

mDe = mydatenull(De)
mAte = mydatenull(Ate)
between = " BETWEEN "& mDe &" AND "& mAte

db.execute("delete from cliniccentral.rel_fluxocaixa2 where sysUser="& session("User"))

'1. P - todas as partes nao pagas (DiscountPaymentID=0, ItemDescontadoID=0, ItemDescontadoVal=Valor da parte não paga)
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, CategoriaID, CentroCustoID, InvoiceID, IteminvoiceID, ParcID, InvoiceVal, ItemInvoiceVal, ParcVal, ValNaoPago, PercValNaoPagoMov, PercItemInv, ValorConta, Data, interno, UnidadeID) "&_
    "select "& session("User") &", ii.Tipo, parc.CD, 'P', ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, parc.id, i.Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "parc.Value, "&_
    "/* ValNaoPago ================= */ parc.Value-ifnull(parc.ValorPago,0), "&_
    "/* PercValNaoPagoMov ========== */ ((parc.Value-ifnull(parc.ValorPago,0))/parc.Value), "&_
    "/* PercItemInv ================ */ ((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value), "&_
    "/* ValorConta ================= */ ((parc.Value-ifnull(parc.ValorPago,0))/parc.Value) * (((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value)*parc.Value) , "&_
    "parc.Date, '1. parte nao paga', i.CompanyUnitID  "&_
    "from sys_financialmovement parc LEFT JOIN sys_financialinvoices i ON parc.InvoiceID=i.id LEFT JOIN itensinvoice ii ON ii.InvoiceID=i.id "&_
    "WHERE parc.Date "& BETWEEN &"      AND      parc.Type='Bill' AND parc.Value-ifnull(parc.ValorPago,0)>0 AND i.CompanyUnitID IN("& Unidades &") "
db.execute( sql )

'2.1. P - toda parte paga em cash cuja data do pagto não muda a previsão
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, DiscountPaymentID, ParcID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, DiscountPaymentVal, ParcVal, PagtoVal, PercItemInv, ValorConta, Data, Interno, UnidadeID) "&_
    "select "& session("User") &", ii.Tipo, parc.CD, 'P', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, dp.id, parc.id, pagto.id, NULL i_Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, dp.DiscountedValue, parc.Value, pagto.Value, NULL, idesc.Valor, parc.Date, '2.1. P - cash', parc.UnidadeID "&_
    "FROM sys_financialmovement parc INNER JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=parc.id INNER JOIN sys_financialmovement pagto ON pagto.id=dp.MovementID INNER JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
    "WHERE parc.Date "& BETWEEN &" AND parc.UnidadeID IN("& Unidades &") AND parc.Type='Bill' AND dp.DiscountedValue>0      AND     ( (pagto.PaymentMethodID NOT IN(2, 8, 9, 10) and parc.CD='C') OR (pagto.PaymentMethodID NOT IN(2, 8, 10) and parc.CD='D') )       GROUP BY idesc.id"
db.execute( sql )


'2.2. R - toda parte paga em cash cuja data do pagto não muda a previsão - !!!!! POR ENQUANTO ESTÁ JÁ LEVANDO EM CONTA CHEQUES EMITIDOS COMO COMPENSADOS
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, DiscountPaymentID, ParcID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, DiscountPaymentVal, ParcVal, PagtoVal, PercItemInv, ValorConta, Data, Interno, UnidadeID) "&_
    "select "& session("User") &", ii.Tipo, parc.CD, 'R', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, dp.id, parc.id, pagto.id, NULL i_Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, dp.DiscountedValue, parc.Value, pagto.Value, NULL, idesc.Valor, pagto.Date, '2.2. R - cash', pagto.UnidadeID "&_
    "FROM sys_financialmovement parc INNER JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=parc.id INNER JOIN sys_financialmovement pagto ON pagto.id=dp.MovementID INNER JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
    "WHERE parc.Date "& BETWEEN &" AND pagto.UnidadeID IN("& Unidades &") AND parc.Type='Bill' AND dp.DiscountedValue>0      AND     ( (pagto.PaymentMethodID NOT IN(2, 8, 9, 10) and parc.CD='C') OR (pagto.PaymentMethodID NOT IN(8, 10) and parc.CD='D') )       GROUP BY idesc.id"
'            response.Write( sql )
db.execute( sql )

'3.1. P - previsões dos cheques recebidos
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, DiscountPaymentID, ParcID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, DiscountPaymentVal, ParcVal, PagtoVal, PercItemInv, ValorConta, Data, Interno, UnidadeID) "&_
    "select "& session("User") &", ii.Tipo, parc.CD, 'P', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, dp.id, parc.id, pagto.id, NULL i_Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, dp.DiscountedValue, parc.Value, pagto.Value, NULL, idesc.Valor, ck.CheckDate, '3.1. P - cheque recebido', parc.UnidadeID "&_
    "FROM sys_financialmovement parc INNER JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=parc.id INNER JOIN sys_financialmovement pagto ON pagto.id=dp.MovementID INNER JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID INNER JOIN sys_financialreceivedchecks ck ON ck.id=pagto.ChequeID "&_
    "WHERE ck.CheckDate "& BETWEEN &" AND parc.UnidadeID IN("& Unidades &") AND parc.Type='Bill' AND dp.DiscountedValue>0      AND     pagto.PaymentMethodID=2       GROUP BY idesc.id"
db.execute( sql )


'3.2. R - realização dos cheques recebidos
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, DiscountPaymentID, ParcID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, DiscountPaymentVal, ParcVal, PagtoVal, PercItemInv, ValorConta, Data, Interno, UnidadeID) "&_
    "select "& session("User") &", ii.Tipo, parc.CD, 'R', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, dp.id, parc.id, pagto.id, NULL i_Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, dp.DiscountedValue, parc.Value, pagto.Value, NULL, idesc.Valor, cm.Data, '3.2. R - cheque recebido realizado', parc.UnidadeID "&_
    "FROM sys_financialmovement parc INNER JOIN sys_financialdiscountpayments dp ON dp.InstallmentID=parc.id INNER JOIN sys_financialmovement pagto ON pagto.id=dp.MovementID INNER JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id INNER JOIN itensinvoice ii ON ii.id=idesc.ItemID INNER JOIN sys_financialreceivedchecks ck ON ck.id=pagto.ChequeID INNER JOIN chequemovimentacao cm ON (ck.id=cm.ChequeID AND cm.StatusID IN (4,5)) "&_
    "WHERE cm.Data "& BETWEEN &" AND parc.UnidadeID IN("& Unidades &") AND parc.Type='Bill' AND dp.DiscountedValue>0      AND     pagto.PaymentMethodID=2       AND      ck.Cashed=1       GROUP BY idesc.id"
db.execute( sql )

'4.1. P - dos itens de cartão Recebidos
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, CCInstallmentID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, CCInstallmentVal, PagtoVal, PercItemInv, ValorConta, Data, interno, UnidadeID) "&_
"select "& session("User") &", ii.Tipo, 'C', 'P', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, cci.id, pagto.id, i.Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, "&_
    "/* CCInstallmentVal =========== */ cci.Value-(cci.value*(ifnull(cci.Fee,0)/100)), "&_
    "pagto.Value, "&_
    "/* PercItemInv ================ */ ((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value), "&_
    "/* ValorConta ================= */ (((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value) * cci.Value-(cci.value*(       (ifnull(cci.Fee,0)/100) * ((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value)       ))), "&_
    "DateToReceive, '4.1. P - cartões Recebidos', i.CompanyUnitID "&_
    "FROM sys_financialcreditcardreceiptinstallments cci LEFT JOIN sys_financialcreditcardtransaction cct ON cci.TransactionID=cct.id LEFT JOIN sys_financialmovement pagto ON pagto.id=cct.MovementID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
    "WHERE cci.DateToReceive "& BETWEEN &" AND i.CompanyUnitID IN("& Unidades &") "
db.execute( sql )


'4.2. R - dos itens de cartão Recebidos/Compensados
sql = "insert into cliniccentral.rel_fluxocaixa2 (sysUser, Tipo, CD, PR, PaymentMethodID, CategoriaID, CentroCustoID, InvoiceID, ItemInvoiceID, ItemDescontadoID, CCInstallmentID, PagtoID, InvoiceVal, ItemInvoiceVal, ItemDescontadoVal, CCInstallmentVal, PagtoVal, PercItemInv, ValorConta, Data, interno, UnidadeID) "&_
"select "& session("User") &", ii.Tipo, 'C', 'R', pagto.PaymentMethodID, ii.CategoriaID, ii.CentroCustoID, ii.InvoiceID, ii.id, idesc.id, cci.id, pagto.id, i.Value, "&_
    "/* ItemInvoiceVal ============= */ (ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto)), "&_
    "idesc.Valor, "&_
    "/* CCInstallmentVal =========== */ cci.Value-(cci.value*(ifnull(cci.Fee,0)/100)), "&_
    "pagto.Value, "&_
    "/* PercItemInv ================ */ ((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value), "&_
    "/* ValorConta ================= */ (((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value) * cci.Value-(cci.value*(       (ifnull(cci.Fee,0)/100) * ((ii.Quantidade*(ii.ValorUnitario+ii.Acrescimo-ii.Desconto))/i.Value)       ))), "&_
    "DateToReceive, '4.1. R - cartões Recebidos', i.CompanyUnitID "&_
    "FROM sys_financialcreditcardreceiptinstallments cci LEFT JOIN sys_financialcreditcardtransaction cct ON cci.TransactionID=cct.id LEFT JOIN sys_financialmovement pagto ON pagto.id=cct.MovementID LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=pagto.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID "&_
    "WHERE cci.DateToReceive "& BETWEEN &" AND i.CompanyUnitID IN("& Unidades &") AND cci.InvoiceReceiptID<>0 "
db.execute( sql )

'A RESOLVER: 
'CHEQUES EMITIDOS COMPENSADOS
'CHEQUES LIQUIDADOS/SACADOS EM CAIXA GRAVAR DATA E DANDO UPDATE NO QUE JA FOI E REGISTRANDO O LOG - E COMPENSADO TAMBÉM NÃO ESTÁ GERANDO O LOG
'QUANDO COLOCAR COMPENSADO / SACADO / LIQUIDADO VER SE JA TEM ESSA MOVIMENTACAO COM UM STATUS ASSIM PRA DAR UPDATE (SO PODE LIQUIDAR/COMPENSAR UMA VEZ), SE FOR OUTRO STATUS PODE LANCAR VARIAS VEZES
'FATURAS DE CARTÕES PAGOS


db.execute("delete from cliniccentral.rel_fluxocaixa2 where ValorConta<0.03")

set ctpc = db.execute("select distinct catc.Category CategoriaPrin, CategoriaID from cliniccentral.rel_fluxocaixa2 fc left join sys_financialincometype catc on fc.CategoriaID=catc.id where fc.CD='C' and fc.sysUser="& session("User") &" and not isnull(catc.Category) and fc.Tipo='O'")
while not ctpc.eof
    if ctpc("CategoriaPrin")=0 then
        CategoriaPrin = ctpc("CategoriaID")
    else
        CategoriaPrin = ctpc("CategoriaPrin")
    end if
    db.execute("update cliniccentral.rel_fluxocaixa2 set CategoriaPrin="& CategoriaPrin &" where CategoriaID="& ctpc("CategoriaID") &" and CD='C' and Tipo='O' and sysUser="& session("User"))
ctpc.movenext
wend
ctpc.close
set ctpc = nothing

set ctpd = db.execute("select distinct catd.Category CategoriaPrin, CategoriaID from cliniccentral.rel_fluxocaixa2 fc left join sys_financialexpensetype catd on fc.CategoriaID=catd.id where fc.CD='D' and fc.sysUser="& session("User") &" and not isnull(catd.Category) and fc.Tipo='O'")
while not ctpd.eof
    if ctpd("CategoriaPrin")=0 then
        CategoriaPrin = ctpd("CategoriaID")
    else
        CategoriaPrin = ctpd("CategoriaPrin")
    end if
    db.execute("update cliniccentral.rel_fluxocaixa2 set CategoriaPrin="& CategoriaPrin &" where CategoriaID="& ctpd("CategoriaID") &" and CD='D' and Tipo='O' and sysUser="& session("User"))
ctpd.movenext
wend
ctpd.close
set ctpd = nothing

'ajusta a categoria para o ProcedimentoID e a categoria principal para o GrupoProcedimentoID
db.execute("update cliniccentral.rel_fluxocaixa2 f LEFT JOIN itensinvoice ii ON ii.id=f.ItemInvoiceID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID set f.CategoriaID=ii.ItemID, f.CategoriaPrin=ifnull(proc.GrupoID, 0) WHERE f.sysUser="& session("User") &" AND f.Tipo='S' AND f.CD='C'")

function sqlData(DataSQL)
    if TipoFC="D" then
        sqlData = " Data="& mydatenull(DataSQL) &" "
    elseif TipoFC="M" then
        sqlData = " month(Data)="& month(DataSQL) &" and year(Data)="& year(DataSQL) &" "
    elseif TipoFC="S" then
        sqlData = ""
    end if
end function

function add(DataAAdd)
    if TipoFC="D" then
        add = DataAAdd+1
    elseif TipoFC="M" then
        add = dateadd("m", 1, DataAAdd)
    elseif TipoFC="S" then
        add = DataAAdd+7
    end if
end function

function linhaFC(tipoRotulo, classe)
    %><tr><%
    Data = cdate(De)
    colu = 0
    acuP = 0
    acuR = 0
    while Data<=cdate(Ate)
        if tipoRotulo="PR" then
            rotuloP = "Previsto"
            rotuloR = "Realizado"
        end if
        %>
        <th class="<%= classe %>"><%= rotuloP %></th>
        <th class="<%= classe %>"><%= rotuloR %></th>
        <%
        Data = add(Data)
        colu = colu+1
    wend
    %></tr><%
end function

response.Buffer



%>
<h1 class="text-center">
    Fluxo de Caixa <%= nomeTipo %>
    <br />
    <small><%
        if TipoFC="D" then
            response.write(De &" a "& Ate)
        elseif TipoFC="M" then
            response.Write( ucase(monthname(month(De)))&"/"&year(De) &" a "& ucase(monthname(month(Ate)))&"/"&year(Ate) )
        end if
        %></small>
</h1>

<div class="panel">
    <div class="panel-body">
        <div class="row">
            <div class="col-xs-2 pn mn">
                <table class="table table-bordered">
                    <thead>
                        <tr>
                            <th>&nbsp;</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        sqlCat = "SELECT * FROM ( "&_
	                        " select distinct ifnull(g.NomeGrupo, 'Outros serviços') Categoria, f.CD, f.Tipo, f.CategoriaPrin FROM cliniccentral.rel_fluxocaixa2 f "&_
			                "        LEFT JOIN procedimentosgrupos g ON g.id=f.CategoriaPrin WHERE f.sysUser="& session("User") &" AND f.Tipo='S' AND f.CD='C' "&_
	                        " UNION ALL "&_
	                        " select distinct ifnull(cr.Name, 'Outras receitas') Categoria, f.CD, f.Tipo, f.CategoriaPrin FROM cliniccentral.rel_fluxocaixa2 f "&_
		                    "    LEFT JOIN sys_financialincometype cr ON cr.id=f.CategoriaPrin WHERE f.sysUser="& session("User") &" AND f.Tipo='O' AND f.CD='C' "&_
	                        " UNION ALL "&_
	                        " select distinct ifnull(cd.Name, 'Outras despesas') Categoria, f.CD, f.Tipo, f.CategoriaPrin FROM cliniccentral.rel_fluxocaixa2 f "&_ 
		                    "    LEFT JOIN sys_financialexpensetype cd ON cd.id=f.CategoriaPrin WHERE f.sysUser="& session("User") &" AND f.Tipo='O' AND f.CD='D' "&_
                        " ) T ORDER BY CD, Categoria"

                        set pcat = db.execute( sqlCat )
                        while not pcat.eof
                            if pcat("CD")<>ultCD then
                                if pcat("CD")="C" then
                                    %>
                                    <tr class="success"><th>ENTRADAS</th></tr>
                                    <%
                                else
                                    %>
                                    <tr class="success"><th>TOTAL DE ENTRADAS</th></tr>
                                    <tr class="danger"><th>SAÍDAS</th></tr>
                                    <%
                                end if
                            end if
                            ultCD = pcat("CD")
                            %>
                            <tr>
                                <th><%= left(ucase(pcat("Categoria")), 27) %></th>
                            </tr>
                            <%
                        pcat.movenext
                        wend
                        pcat.close
                        set pcat = nothing
                        ultCD = ""'zera
                        %>
                        <tr class="danger"><th>TOTAL DE SAÍDAS</th></tr>
                        <tr class="dark">
                            <th nowrap>RESULTADO</th>
                        </tr>
                        <tr class="dark">
                            <th nowrap>ACUMULADO</th>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="col-xs-10 mn pn" style="overflow-x:scroll">
                <table class="table table-bordered table-hover">
                <thead>
                    <tr>
                        <%
                        cols = 0
                        arr = "0"

                        Data = cdate(De)
                        while Data<=cdate(Ate)
                            cols = cols+2
                            arr = arr &", 0, 0"

                            if TipoFC="D" then
                                RotuloData = Data
                            elseif TipoFC="M" then
                                RotuloData = ucase(monthname(month(Data))) &"/"& year(Data)
                            end if
                            %>
                            <th colspan="2" class="primary text-center"><%= RotuloData %></th>
                            <%
                            Data = add(Data)
                        wend
                        %>
                    </tr>
                </thead>
                    <tbody>
                        <%
                        tEntradasP = split( arr, ", " )
                        tEntradasR = split( arr, ", " )
                        tSaidasP = split( arr, ", " )
                        tSaidasR = split( arr, ", " )

                        resPrev = split( arr, ", " )
                        resReal = split( arr, ", " )
                        
                        set pcat = db.execute( sqlCat )
                        while not pcat.eof
                            response.Flush()
                            if pcat("CD")<>ultCD then
                                if pcat("CD")="C" then
                                    response.write( linhaFC("PR", "success text-center") )
                                else
                                    'TOTAL DE ENTRADAS
                                    Data = cdate(De)
                                    response.Write("<tr class=""success"">")
                                    col = 0
                                    while Data<=cdate(Ate)
                                        tipoRotulo = "C"
                                        set soma = db.execute("select (select ifnull(sum(ValorConta), 0) from cliniccentral.rel_fluxocaixa2 where "& sqlData(Data) &" and sysUser="& session("User") &" and CD='"&tipoRotulo&"' and PR='P') tP, (select ifnull(sum(ValorConta), 0) from cliniccentral.rel_fluxocaixa2 where "& sqlData(Data) &" and sysUser="& session("User") &" and CD='"&tipoRotulo&"' and PR='R') tR")
                                        tEntradasP(col) = soma("tP")
                                        tEntradasR(col) = soma("tR")
                                        %>
                                            <th class="text-right"><%= fn(soma("tP")) %></th>
                                            <th class="text-right"><%= fn(soma("tR")) %></th>
                                        <%
                                        Data = add(Data)
                                        col = col+1
                                    wend
                                    response.write("</tr>")
                                    response.write( linhaFC("PR", "danger text-center") )
                                end if
                            end if
                            ultCD = pcat("CD")
                            
                            Tipo = pcat("Tipo")
                            CD = pcat("CD")
                            CategoriaPrin = pcat("CategoriaPrin")


                            %><tr><%
                            Data = cdate(De)
                            col = 0
                            while Data<=cdate(Ate)
                                sql = "select (select sum(ValorConta) from cliniccentral.rel_fluxocaixa2 where Tipo='"& Tipo &"' and PR='P' and CD='"&CD&"' and ifnull(CategoriaPrin, 0)="& CategoriaPrin &" and "& sqlData(Data) &") P, (select sum(ValorConta) from cliniccentral.rel_fluxocaixa2 where Tipo='"& Tipo &"' and PR='R' and CD='"&CD&"' and CategoriaPrin="& CategoriaPrin &" and "& sqlData(Data) &") R"
                                'response.write( sql &"<br>")
                                set soma = db.execute( sql )
                                prev = soma("P")
                                real = soma("R")
                                %>
                                <td class="text-right"><%= fn(prev) %></td>
                                <td class="text-right"><%= fn(real) %></td>
                                <%
                                Data = add(Data)
                                col = col+1
                            wend
                            %></tr><%

                        pcat.movenext
                        wend
                        pcat.close
                        set pcat = nothing

                        'TOTAL DE SAIDAS
                        Data = cdate(De)
                        response.Write("<tr class=""danger"">")
                        col = 0
                        while Data<=cdate(Ate)
                            tipoRotulo = "D"
                            set soma = db.execute("select (select ifnull(sum(ValorConta), 0) from cliniccentral.rel_fluxocaixa2 where "& sqlData(Data) &" and sysUser="& session("User") &" and CD='"&tipoRotulo&"' and PR='P') tP, (select ifnull(sum(ValorConta), 0) from cliniccentral.rel_fluxocaixa2 where "& sqlData(Data) &" and sysUser="& session("User") &" and CD='"&tipoRotulo&"' and PR='R') tR")
                            tSaidasP(col) = soma("tP")
                            tSaidasR(col) = soma("tR")
                            %>
                                <th class="text-right"><%= fn(soma("tP")) %></th>
                                <th class="text-right"><%= fn(soma("tR")) %></th>
                            <%
                            Data = add(Data)
                            col = col+1
                        wend
                        response.write("</tr>")
                        'RESULTADO
                        Data = cdate(De)
                        response.Write("<tr class=""dark"">")
                        col = 0
                        while Data<=cdate(Ate)
                            resPrev(col) = tEntradasP(col)-tSaidasP(col)
                            resReal(col) = tEntradasR(col)-tSaidasR(col)
                            %>
                                <th class="text-right"><%= fn(resPrev(col)) %></th>
                                <th class="text-right"><%= fn(resReal(col)) %></th>
                            <%
                            Data = add(Data)
                            col = col+1
                        wend
                        response.write("</tr>")

                        'ACUMULADO
                        Data = cdate(De)
                        response.Write("<tr class=""dark"">")
                        col = 0
                        acuP = 0
                        acuR = 0
                        while Data<=cdate(Ate)
                            acuP = acuP + resPrev(col)
                            acuR = acuR + resReal(col)
                            %>
                                <th class="text-right"><%= fn(acuP) %></th>
                                <th class="text-right"><%= fn(acuR) %></th>
                            <%
                            Data = add(Data)
                            col = col+1
                        wend
                        response.write("</tr>")

                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
