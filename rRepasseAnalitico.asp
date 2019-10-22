<!--#include file="connect.asp"-->

<style type="text/css">
body, tr, td, th {
	font-size:9px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}

</style>

<%
response.CharSet="utf-8"

DataDe = ref("DataDe")
DataAte = ref("DataAte")
AccountID=ref("AccountID")

response.Buffer
%>
<h3 class="text-center">Repasse - Analítico</h3>
<h5 class="text-center">Per&iacute;odo - <%=DataDe%> at&eacute; <%=DataAte%></h5>

<table class="table table-striped">
    <thead>
        <tr>
            <th>Unidade</th>
            <th>Tipo de fornecedor</th>
            <!--<th>Tipo de repasse</th>-->
            <th>Razão social do fornecedor</th>
            <th>CNPJ do fornecedor</th>
            <th>ID do fornecedor</th>
            <th>Status do fornecedor</th>
            <!--<th>Status da conta bancária do fornecedor</th>-->
            <th>Nome do profissional</th>
            <!--<th>CPF do profissional</th>-->
            <th>ID do profissional</th>
            <th>Status do profissional</th>
            <th>ID do procedimento</th>
            <th>Nome do procedimento</th>
            <th>Quantidade</th>
            <th>Status do procedimento</th>
            <!--<th>Data do agendamento</th>-->
            <!--<th>Hora do agendamento</th>-->
            <th>Data de realização</th>
            <th>Hora de realização</th>
            <th>Nome do paciente</th>
            <th>Status do faturamento</th>
            <th>Data do faturamento</th>
            <th>Hora do faturamento</th>
            <th>Tipo do faturamento</th>
            <th>Metodo do faturamento</th>
            <th>Condição do faturamento</th>
            <!--<th>ID do recebimento</th>-->
            <!--<th>No. recibo</th>-->
            <th>No. nota fiscal</th>
            <th>Valor bruto da nota fiscal</th>
            <th>Valor bruto do procedimento</th>
            <th>ID da conta a pagar</th>
            <th>Status da conta a pagar</th>
            <th>Valor do repasse</th>
            <th>Valor do repasse aprovado</th>
        </tr>
    </thead>
<%
set RepassesSQL = db.execute("select IF(filial.id IS NULL,matriz.Sigla,filial.Sigla)Unidade, "_
                              &"IF(profissional.FornecedorID IS NULL OR profissional.FornecedorID=0, 'PF', 'PJ') as 'TipoFornecedor', "_
                              &"fornecedor.NomeFornecedor, "_
                              &"fornecedor.CPF as 'CNPJFornecedor', "_
                              &"fornecedor.id as 'FornecedorID', "_
                              &"IF(fornecedor.sysActive =1,'Ativo','Inativo')as 'FornecedorStatus', "_
                              &"profissional.NomeProfissional, "_
                              &"profissional.id as 'ProfissionalID', "_
                              &"IF(profissional.ativo ='on','Ativo','Inativo') as 'ProfissionalStatus' , "_
                              &"procedimento.id as 'ProcedimentoID', "_
                              &"procedimento.NomeProcedimento, "_
                              &"procedimento.id as 'ProcedimentoID', "_
                              &"item.Quantidade, "_
                              &"IF(item.Executado='S', 'Realizado', 'Não realizado') as 'StatusProceidmento', "_
                              &"item.DataExecucao, "_
                              &"item.HoraExecucao, "_
                              &"item.HoraFim, "_
                              &"paciente.NomePaciente, "_
                              &"conta.Value as 'ValorConta', "_
                              &"nfe.numero as 'NumeroNfe', "_
                              &"repasse.ItemContaAPagar, "_
                              &"IF(conta.nroNfe IS NOT NULL,conta.Value,0) as 'ValorBrutoNfe', "_
                              &"((item.ValorUnitario + item.Acrescimo + item.Desconto)* item.Quantidade) as 'ValorBrutoProcedimento', "_
                              &"repasse.Valor as 'ValorRepasse', "_
                              &"conta.id as 'ContaID' "_
                              &" FROM rateiorateios repasse "_
                              &"LEFT JOIN itensinvoice item ON item.id = repasse.ItemInvoiceID "_
                              &"LEFT JOIN sys_financialinvoices conta ON conta.id = item.InvoiceID "_
                              &"LEFT JOIN sys_financialcompanyunits filial ON filial.id = conta.CompanyUnitID "_
                              &"LEFT JOIN empresa matriz ON matriz.id = IF(conta.CompanyUnitID=0,1,0) "_
                              &"LEFT JOIN pacientes paciente ON paciente.id = conta.AccountID AND conta.AssociationAccountID=3 "_
                              &"LEFT JOIN profissionais profissional ON profissional.id = REPLACE(repasse.ContaCredito,'5_','') "_
                              &"LEFT JOIN fornecedores fornecedor ON fornecedor.id = profissional.FornecedorID "_
                              &"LEFT JOIN procedimentos procedimento ON procedimento.id = item.ItemID AND item.Tipo='S' "_
                              &"LEFT JOIN nfe_notasemitidas nfe ON nfe.InvoiceID = conta.id and nfe.situacao=1 "_
                              &"WHERE repasse.ContaCredito = '"&AccountID&"' AND item.DataExecucao BETWEEN "&mydatenull(DataDe)&" AND "&mydatenull(DataAte))
while not RepassesSQL.eof
    IDContaAPagar="-"
    FormaRecebimento="-"
    DataRecebimento="-"
    HoraRecebimento="-"
    StatusRecebimento="Não recebido"
    StatusPagamentoRepasse = "Pendente"
    CondicaoRecebimento = "A vista"

    if not isnull(RepassesSQL("ItemContaAPagar")) then
        set ContaAPagarSQL = db.execute("SELECT conta.id FROM sys_financialinvoices conta LEFT JOIN itensinvoice item ON item.InvoiceID=conta.id WHERE item.id="&treatvalzero(RepassesSQL("ItemContaAPagar")))
        if not ContaAPagarSQL.eof then
            IDContaAPagar = ContaAPagarSQL("id")
            set PagamentoSQL = db.execute("SELECT credito.id FROM sys_financialmovement debito "_
                                           &"LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID=debito.id "_
                                           &"LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID WHERE debito.InvoiceID="&IDContaAPagar)
            if not PagamentoSQL.eof then
                if not isnull(PagamentoSQL("id")) then
                    StatusPagamentoRepasse = "Pago"
                 end if
            end if
        end if
    end if
    set RecebimentoSQL = db.execute("SELECT credito.id, forma_pagamento.PaymentMethod, IF(debito.Value=pagamento.DiscountedValue,'Recebido', 'Parcialmente recebido')StatusRecebimento, credito.sysDate as 'DataRecebimento', credito.sysDate as 'HoraRecebimento' FROM sys_financialmovement debito "_
                                   &"LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID=debito.id "_
                                   &"LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "_
                                   &"LEFT JOIN sys_financialpaymentmethod forma_pagamento ON forma_pagamento.id=credito.PaymentMethodID WHERE debito.InvoiceID="&RepassesSQL("ContaID"))

    if not RecebimentoSQL.eof then
        if not isnull(RecebimentoSQL("id")) then
            FormaRecebimento=RecebimentoSQL("PaymentMethod")
            DataRecebimento=formatdatetime(RecebimentoSQL("DataRecebimento"),2)
            HoraRecebimento=RecebimentoSQL("HoraRecebimento")
            StatusRecebimento=RecebimentoSQL("StatusRecebimento")

            set NumeroParcelasSQL = db.execute("SELECT Parcelas FROM sys_financialcreditcardtransaction WHERE MovementID="&RecebimentoSQL("id"))
            if not NumeroParcelasSQL.eof then
                if NumeroParcelasSQL("Parcelas")>1 then
                    CondicaoRecebimento =  "Parcelado ("&NumeroParcelasSQL("Parcelas")&"x)"
                end if
            end if
        end if
    end if

    if IDContaAPagar="-" then
        ValorRepasse = 0
    else
        ValorRepasse = RepassesSQL("ValorRepasse")
    end if
    %>
    <tr>
        <td><%=RepassesSQL("Unidade")%></td>
        <td><%=RepassesSQL("TipoFornecedor")%></td>
        <!--<td>Tipo de repasse</td>-->
        <td><%=RepassesSQL("NomeFornecedor")%></td>
        <td><%=RepassesSQL("CNPJFornecedor")%></td>
        <td><%=RepassesSQL("FornecedorID")%></td>
        <td><%=RepassesSQL("FornecedorStatus")%></td>
        <!--<td>Status da conta bancária do fornecedor</td>-->
        <td><%=RepassesSQL("NomeProfissional")%></td>
        <!--<td>Status da conta bancária do fornecedor</td>-->
         <td><%=RepassesSQL("ProfissionalID")%></td>
        <td><%=RepassesSQL("ProfissionalStatus")%></td>
        <td><%=RepassesSQL("ProcedimentoID")%></td>
        <td><%=RepassesSQL("NomeProcedimento")%></td>
        <td><%=RepassesSQL("Quantidade")%></td>
        <td><%=RepassesSQL("StatusProceidmento")%></td>
        <!--<td>Data do agendamento</td>-->
        <!--<td>Hora do agendamento</td>-->
        <td><%=RepassesSQL("DataExecucao")%></td>
        <td><%=ft(RepassesSQL("HoraExecucao"))%>-<%=ft(RepassesSQL("HoraFim"))%></td>
        <td><%=RepassesSQL("NomePaciente")%></td>
        <td><%=StatusRecebimento%></td>
        <td><%=DataRecebimento%></td>
        <td><%=ft(HoraRecebimento)%></td>
        <td>Particular</td>
        <td><%=FormaRecebimento%></td>
        <td><%=CondicaoRecebimento%></td>
        <!--<td>ID do recebimento</td>-->
        <!--<td>No. recibo</td>-->
        <td><%=RepassesSQL("NumeroNfe")%></td>
        <td><%=fn(RepassesSQL("ValorBrutoNfe"))%></td>
        <td><%=fn(RepassesSQL("ValorBrutoProcedimento"))%></td>
        <td><%=IDContaAPagar%></td>
        <td><%=StatusPagamentoRepasse%></td>
        <td><%=fn(RepassesSQL("ValorRepasse"))%></td>
        <td><%=fn(ValorRepasse)%></td>
    </tr>
    <%
RepassesSQL.movenext
wend
RepassesSQL.close
set RepassesSQL=nothing
%>
    </tbody>
</table>
