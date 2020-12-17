<!--#include file="connect.asp"-->
<!--#include file="Classes/ValidaProcedimentoProfissional.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
ItemInvoiceID = req("II")
sqlat = "select i.AccountID PacienteID, ii.ItemID ProcedimentoID, (ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) ValorTotal, ii.DataExecucao, ii.InvoiceID from itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&ItemInvoiceID
set iinv = db.execute(sqlat)



if instr(ref("ProfissionalID"&ItemInvoiceID), "_") then
    splExecutante = split(ref("ProfissionalID"&ItemInvoiceID), "_")
    Associacao = splExecutante(0)
    ProfissionalID = splExecutante(1)
    dataExecucao = ref("DataExecucao"&ItemInvoiceID)
    horaExecucao = ref("HoraExecucao"&ItemInvoiceID)
    horaFim = ref("HoraFim"&ItemInvoiceID)
    EspecialidadeID = ref("EspecialidadeID"&ItemInvoiceID)
else
    Associacao = 0
    ProfissionalID = 0
    EspecialidadeID = 0
    dataExecucao = ""
    horaExecucao = ""
    horaFim = ""
end if


if ref("Executado"&ItemInvoiceID)="S" then
    if validaProcedimentoProfissional(Associacao, ProfissionalID, EspecialidadeID, iinv("ProcedimentoID"), 0)=False then
    %>
    new PNotify({
            title: 'ERRO AO TENTAR SALVAR!',
            text: 'Procedimento não permitido para este Profissional e/ou Especialidade',
            type: 'danger',
            delay: 3000
        });
        $("#btnSave").prop("disabled", false);
    <%
    Response.End
    end if

    if ref("DataExecucao"&ItemInvoiceID)="" then
        %>
showMessageDialog('Preencha a data da execução.');
        <%
        Response.End
    end if
end if

sqlUpdate = "update itensinvoice set Executado='"&ref("Executado"&ItemInvoiceID)&"', Associacao="&Associacao&", ProfissionalID="&ProfissionalID&", EspecialidadeID="&treatvalnull(EspecialidadeID)&",DataExecucao="&mydatenull(dataExecucao)&", HoraExecucao="&mytime(horaExecucao)&", HoraFim="&mytime(horaFim)&", Descricao='"&ref("Descricao"&ItemInvoiceID)&"' where id="&ItemInvoiceID


call gravaLogs(sqlUpdate, "AUTO", "Executado manualmente","InvoiceID")
db_execute(sqlUpdate)
db_execute("delete rr from rateiorateios rr  where rr.ItemInvoiceID="&ItemInvoiceID&" and (isnull(rr.ItemContaAPagar) OR rr.ItemContaAPagar=0)")

'call salvaRepasse(ItemInvoiceID, ItemInvoiceID)


'response.Write( sqlat )
if not iinv.eof then
    if ref("Executado" & ItemInvoiceID)="S" and ref("DataExecucao" & ItemInvoiceID)<>"" and isdate(ref("DataExecucao" & ItemInvoiceID)) then
        Data = ref("DataExecucao"&ItemInvoiceID)
    elseif ref("Executado"&ItemInvoiceID)="" and not isnull(iinv("DataExecucao")) then
        Data = iinv("DataExecucao")
    else
        Data = date()
    end if
    call statusPagto("", iinv("PacienteID"), Data, "P", iinv("ValorTotal"), 0, iinv("ProcedimentoID"), ProfissionalID)
end if
%>
$("#pagar").fadeOut();
ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico')


<!--#include file="disconnect.asp"-->