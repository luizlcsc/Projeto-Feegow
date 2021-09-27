<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="modulos/audit/AuditoriaUtils.asp"-->
<%
I = ref("I")
AuditoriaRegistrada = False

DeletarCheck = TRUE

IF ref("DeletarCheck") = "FALSE" THEN
    DeletarCheck = FALSE
END IF

strStatusPagto = ""
set iinv = db.execute("select i.AccountID PacienteID, i.AssociationAccountID Associacao, ii.ItemID ProcedimentoID, (ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) ValorTotal, ii.ProfissionalID, ii.DataExecucao, ii.InvoiceID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN itensdescontados idesc on idesc.ItemID=ii.id where idesc.PagamentoID="&I&" AND not isnull(ii.DataExecucao) AND i.AssociationAccountID=3 AND i.CD='C'")
while not iinv.eof
    Data = iinv("DataExecucao")
    InvoiceID=iinv("InvoiceID")
    strStatusPagto = strStatusPagto & iinv("PacienteID") &"|"& Data &"|"& iinv("ValorTotal") &"|"& iinv("ProcedimentoID") &"|"& iinv("ProfissionalID") &";"
    Invoices = Invoices &", "& InvoiceID
    'call statusPagto("", iinv("PacienteID"), Data, "V", iinv("ValorTotal"), 0, iinv("ProcedimentoID"), iinv("ProfissionalID"))
iinv.movenext
wend
iinv.close
set iinv=nothing

RemoveMov = 1
set MovementSQL = db.execute("SELECT * FROM sys_financialmovement WHERE id="&I)

' ######################### BLOQUEIO FINANCEIRO ########################################
UnidadeID = treatvalzero(ref("UnidadeIDPagto"))
contabloqueadacred = verificaBloqueioConta(1, 1, MovementSQL("AccountIDCredit"), MovementSQL("UnidadeID"),MovementSQL("Date"))
contabloqueadadebt = verificaBloqueioConta(1, 1, MovementSQL("AccountIDDebit"), MovementSQL("UnidadeID"),MovementSQL("Date"))

if contabloqueadacred = "1" or contabloqueadadebt = "1" then
    retorno  = " alert('Esta conta está BLOQUEADA e não pode ser alterada!'); "
    response.write(retorno)
    response.end
end if
' #####################################################################################

IF MovementSQL.EOF THEN
   response.end
END IF


if InvoiceID<>"" and session("Admin")=0 then
    set NotaFiscalSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE InvoiceiD='"&InvoiceID&"' AND situacao=1")
    if not NotaFiscalSQL.eof then
        %>
        showMessageDialog("Existe uma nota fiscal emitida para esta conta.");
        <%

        Response.End
    end if
end if

if InvoiceID<>"" then
    set RepasseConsolidadoSQL = db.execute("SELECT ii.id, rr.ItemContaAPagar FROM itensinvoice ii INNER JOIN rateiorateios rr ON rr.ItemInvoiceID=ii.id WHERE ii.InvoiceiD='"&InvoiceID&"'")
    if not RepasseConsolidadoSQL.eof then

        if isnull(RepasseConsolidadoSQL("ItemContaAPagar")) then
            db.execute("DELETE FROM rateiorateios WHERE ItemInvoiceID="&RepasseConsolidadoSQL("id")&" AND ItemContaAPagar IS NULL")
        else
            %>
            showMessageDialog("Existe um repasse para esta conta. Para excluir a conta, desconsolide o repasse.");
            <%

            Response.End
        end if

    end if
end if

if MovementSQL("Name")="Fechamento Cx - Dinheiro" then
    'aqui reabre o caixa
    CaixaID=MovementSQL("CaixaID")

    if session("Admin")=0 and aut("reaberturadecaixa")=0 then

        %>
        showMessageDialog("Sem permissão para reabrir o caixa.");
        <%
        Response.End
    end if

    AuditoriaRegistrada = True
    call registraEventoAuditoria("reabre_caixinha", CaixaID, ref("Jst"))

    db.execute("UPDATE caixa SET Reaberto='S',dtFechamento=null, Descricao=concat(Descricao, ' (Aberto)') WHERE id="&CaixaID)

    %>
    showMessageDialog("Caixinha reaberto.", "warning");
    <%
    'Response.End
end if


if not isnull(MovementSQL("CaixaID")) and session("admin")=0 then
    CaixaID=MovementSQL("CaixaID")

    set CaixaSQL = db.execute("SELECT * FROM caixa WHERE dtFechamento is not null and id="&CaixaID)
    if not CaixaSQL.eof then

        %>
        showMessageDialog("Não é possível excluir uma movimentação de um caixinha fechado.");
        <%
        db.execute("INSERT INTO log (sysUser, Operacao, I, recurso, ValorAtual) VALUES ("&session("User")&",'N', "&I&", 'caixa', 'Não é possível excluir uma movimentação de um caixinha fechado.')")
        Response.End
    end if
end if

if not MovementSQL.eof then
    if MovementSQL("Type")="Transfer" then
        'RemoveMov = 0
    end if

    sqlCartaoBaixado = "SELECT ci.id FROM sys_financialcreditcardreceiptinstallments ci "&_
                                                           " INNER JOIN sys_financialcreditcardtransaction ct ON ct.id=ci.TransactionID "&_
                                                           " WHERE ci.InvoiceReceiptID IS NOT NULL AND ci.InvoiceReceiptID != 0 AND ct.MovementID="&I
    set CartaoBaixadoSQL = db.execute(sqlCartaoBaixado)

    if not CartaoBaixadoSQL.eof then
        %>
        showMessageDialog("Esta transação já foi baixada. Cancele a baixa em <strong><i>Financeiro > Cartões > Baixar pagamentos</i></strong> e tente novamente.");
        <%
        Response.End
    end if
end if

if MovementSQL("Type")="Pay" and MovementSQL("CD")="D" and not AuditoriaRegistrada then
    AuditoriaRegistrada = True
    call registraEventoAuditoria("cancela_recebimento", I, ref("Jst"))
end if


if MovementSQL("Type")="Transfer" and not AuditoriaRegistrada then
    call registraEventoAuditoria("exclui_transferencia", I, ref("Jst"))
end if


set cct = db.execute("select group_concat(id) parcelascartao from sys_financialcreditcardtransaction where MovementID="&I)
if not cct.eof then
    if not isnull(cct("parcelascartao")) then
        parcelascartao = cct("parcelascartao")
        if parcelascartao<>"" then
            db_execute("delete from sys_financialcreditcardreceiptinstallments where TransactionID IN ("& parcelascartao &")")
        end if
    end if
end if
db_execute("delete from sys_financialcreditcardtransaction where MovementID="&I)

IF DeletarCheck THEN
    db_execute("delete from sys_financialreceivedchecks where id=(select ChequeID from sys_financialmovement where id="&I&")")
END IF

'gerar o log
set iInvoice = db.execute("select * from sys_financialmovement WHERE id="& I)

db_execute("update rateiorateios set CreditoID=NULL where CreditoID="& I)
if RemoveMov=1  then
    sqlDel = "delete from sys_financialmovement where id="&I

    db.execute("insert into sys_financialmovement_removidos (id, Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate, MovementAssociatedID, InvoiceID, InstallmentNumber, sysUser, ValorPago, CaixaID, ChequeID, UnidadeID, sysDate, ConciliacaoID, CodigoDeBarras) select id, Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, PaymentMethodID, Value, Date, CD, Type, Obs, Currency, Rate, MovementAssociatedID, InvoiceID, InstallmentNumber, sysUser, ValorPago, CaixaID, ChequeID, UnidadeID, sysDate, ConciliacaoID, CodigoDeBarras from sys_financialmovement where id="& I)
    db.execute("insert into xmovement_log (MovimentacaoID, sysUser, AutorizadoPor, Descricao, MovementsBill, Invoices) values ("& I &", "& session("User") &", "& treatvalnull(ref("AutID")) &", '"& ref("jst") &"', '', ( select group_concat( concat('|', ii.InvoiceID, '|') ) from itensdescontados idesc left join itensinvoice ii on ii.id=idesc.ItemID where idesc.PagamentoID="& I &" ) )")
    call gravaLogs(sqlDel, "AUTO", "Pagamento excluído", "")
    db_execute(sqlDel)

    db_execute("UPDATE recibos SET sysActive=-1, Nome=CONCAT(Nome, ' (Excluído)') WHERE sysActive=1 AND InvoiceID="&treatvalzero(InvoiceID))

end if
db_execute("delete from itensdescontados where PagamentoID="&I)
db_execute("update sys_financialcreditcardreceiptinstallments set InvoiceReceiptID=0 where InvoiceReceiptID="&I)
set movsPagos = db.execute("select * from sys_financialdiscountpayments where MovementID="&I)
while not movsPagos.EOF
    db_execute("delete from sys_financialdiscountpayments where MovementID="&I)
    call getValorPago(movsPagos("InstallmentID"), NULL)
movsPagos.movenext
wend
movsPagos.close
set movsPagos = nothing

'excluir devolução
Obs = MovementSQL("Obs")

if Obs<>"" then
    ItemInvoiceID = Replace(Obs,"{","")
    ItemInvoiceID = Replace(ItemInvoiceID,"}","")
    ItemInvoiceID = Replace(ItemInvoiceID,"C","")

    if isnumeric(ItemInvoiceID) then
        set rsDevolucao = db.execute("select d.id from devolucoes d inner join devolucoes_itens di on di.devolucoesID = d.id where di.itensInvoiceID = " & ItemInvoiceID)

        while not rsDevolucao.eof
            db.execute("update devolucoes SET sysActive = -1 where id= " & rsDevolucao("id"))

            db_execute("update itensinvoice set Executado = 'S' WHERE id = "& ItemInvoiceID &" AND Executado = 'C' AND ProfissionalID > 0 ")
            db_execute("update itensinvoice set Executado = '' WHERE id = "& ItemInvoiceID &" AND Executado = 'C' AND ( ProfissionalID = 0 OR ProfissionalID is null) ")

            rsDevolucao.movenext
        wend
    end if
end if

%>

    if( $.isNumeric($("#PacienteID").val()) )
    {
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
    }else if ( $("#Filtrate").html()!="" && $("#Filtrate").html()!=undefined ){
        $("#Filtrate").click();
        $('#pagar').fadeOut();
    }else if ( $("#MeuCaixa").val()=="S" ){
        $.post("ExtratoConteudo.asp?T=MeuCaixa", $("#frmExtrato").serialize(), function(data){ $("#Extrato").html(data) });
    }else{
        $('.parcela').prop('checked', false);
        $('#pagar').fadeOut();
        geraParcelas('N');
    }
<%
if strStatusPagto<>"" then
    spl = split(strStatusPagto, ";")
    for i=0 to ubound(spl)
        if spl(i)<>"" then
            spl2 = split(spl(i), "|")
            call statusPagto("", spl2(0), spl2(1), "V", spl2(2), 0, spl2(3), spl2(4))
        end if
    next
end if

if invoices<>"" then
    splInvoices = split(Invoices, ", ")
    for iv=0 to ubound(splInvoices)
        if splInvoices(iv)<>"" and isnumeric(splInvoices(iv)) then
              call reconsolidar("invoice", splInvoices(iv))
        end if
    next
end if
%>