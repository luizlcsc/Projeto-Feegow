<!--#include file="connect.asp"-->
<%
'response.Write(req())
    
DataDe = req("DataDe")
DataAte = req("DataAte")
%>
<h2 class="text-center">CAIXA - ANALÍTICO</h2>
<h4 class="text-center">    <%=DataDe %> a <%=DataAte %></h4>
<br />

<%
ProfissionalID = replace(req("ProfissionalID"), "|", "")
ProfissionalExtID = replace(req("ProfissionalExtID"), "|", "")
if ProfissionalID="" and ProfissionalExtID="" then
    erro = "Selecione ao menos um profissional."
end if
if erro<>"" then
    %>
    <div class="alert alert-danger"><%=erro %></div>
    <%
else

    splU = split(req("Unidades"), ", ")    
    for iu=0 to ubound(splU)
        UnidadeID = ccur(splU(iu))
        if UnidadeID=0 then
            set un = db.execute("select * from empresa limit 1")
            NomeUnidade = un("NomeFantasia")
        else
            set un = db.execute("select * from sys_financialcompanyunits where id="&UnidadeID)
            NomeUnidade = un("NomeFantasia")
        end if
    %>

    <h4>ATENDIMENTOS LANÇADOS - <%=ucase(NomeUnidade&"") %></h4>
    <%
    Dinheiro = 0
    Cheque = 0
    Credito = 0
    Debito = 0
    Transferencia = 0
    sqlPaymentMethod = ""
    if req("FormaRecto")<>"" then
        sqlPaymentMethod = " AND m.PaymentMethodID="&req("FormaRecto")
    end if

    if ProfissionalID<>"" or ProfissionalExtID<>"" then
        sql = "SELECT m.id, m.Date, m.AccountIDDebit, m.AccountAssociationIDDebit, p.id Prontuario, IFNULL(p.NomePaciente, '<em>Paciente Excluído</em>') NomePaciente, p.id PacienteID, pm.PaymentMethod, m.PaymentMethodID, m.Value FROM sys_financialmovement m LEFT JOIN sys_financialpaymentmethod pm ON pm.id=m.PaymentMethodID LEFT JOIN pacientes p ON p.id=m.AccountIDCredit WHERE m.Type='Pay' AND m.Date BETWEEN "& mydatenull(DataDe) &" AND "& mydatenull(DataAte) &" AND m.CD='D' AND m.AccountAssociationIDCredit=3 AND m.Value>0 AND m.UnidadeID="& UnidadeID&sqlPaymentMethod
        'response.write(sql)
        %>
        <!--#include file="caixaAnaliticoMiolo.asp"-->
        <%
    end if
    %>
<div class="row">
    <div class="col-md-12">
        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th width="16%" class="text-right">Dinheiro: R$ <%=fn(Dinheiro) %></th>
                    <th width="16%" class="text-right">Cheque: R$ <%=fn(Cheque) %></th>
                    <th width="16%" class="text-right">Débito: R$ <%=fn(Debito) %></th>
                    <th width="16%" class="text-right">Crédito: R$ <%=fn(Credito) %></th>
                    <th width="16%" class="text-right">Transferência: R$ <%=fn(Transferencia) %></th>
                    <th width="16%" class="text-right">Total: R$ <%=fn( Dinheiro + Cheque + Debito + Credito + Transferencia ) %></th>
                </tr>
            </thead>
        </table>
    </div>
</div>


<br />
<hr />
    <%
if 1=2 then'colocar isso em outro relatorio
    'response.write("select i.AccountID, ii.id idItem, ii.DataExecucao, ii.Descricao, prof.NomeProfissional, i.sysDate, p.id Prontuario, p.NomePaciente, proc.NomeProcedimento from sys_financialinvoices i LEFT JOIN pacientes p on p.id=i.AccountID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN procedimentos proc on proc.id=ii.ItemID LEFT JOIN profissionais prof on prof.id=ii.ProfissionalID WHERE (i.sysDate<"&mydatenull(DataDe)&" or i.sysDate>"&mydatenull(DataDe)&") and ii.DataExecucao<="&mydatenull(DataAte)&" and  ii.DataExecucao>="&mydatenull(DataDe)&" and ii.DataExecucao<="&mydatenull(DataAte)&" and i.AssociationAccountID=3 AND ii.ProfissionalID IN ("&req("ProfissionalID")&") and i.CompanyUnitID="&UnidadeID & sqlProcsII & sqlExceptProcsII )
    if req("ProfissionalID")<>"" then
        set inv = db.execute("select i.AccountID, ii.id idItem, ii.DataExecucao, ii.Descricao, prof.NomeProfissional, i.sysDate, p.id Prontuario, p.NomePaciente, proc.NomeProcedimento from sys_financialinvoices i LEFT JOIN pacientes p on p.id=i.AccountID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN procedimentos proc on proc.id=ii.ItemID LEFT JOIN profissionais prof on prof.id=ii.ProfissionalID WHERE (i.sysDate<"&mydatenull(DataDe)&" or i.sysDate>"&mydatenull(DataDe)&") and ii.DataExecucao<="&mydatenull(DataAte)&" and  ii.DataExecucao>="&mydatenull(DataDe)&" and ii.DataExecucao<="&mydatenull(DataAte)&" and ii.DataExecucao<>i.sysDate and i.AssociationAccountID=3 AND ii.ProfissionalID IN ("&req("ProfissionalID")&") AND ii.Associacao=5 and i.CompanyUnitID="&UnidadeID & sqlProcsII & sqlExceptProcsII)
    end if
    if req("ProfissionalExtID")<>"" then
        set inv = db.execute("select i.AccountID, ii.id idItem, ii.DataExecucao, ii.Descricao, prof.NomeProfissional, i.sysDate, p.id Prontuario, p.NomePaciente, proc.NomeProcedimento from sys_financialinvoices i LEFT JOIN pacientes p on p.id=i.AccountID LEFT JOIN itensinvoice ii on ii.InvoiceID=i.id LEFT JOIN procedimentos proc on proc.id=ii.ItemID LEFT JOIN profissionalexterno prof on prof.id=ii.ProfissionalID WHERE (i.sysDate<"&mydatenull(DataDe)&" or i.sysDate>"&mydatenull(DataDe)&") and ii.DataExecucao<="&mydatenull(DataAte)&" and  ii.DataExecucao>="&mydatenull(DataDe)&" and ii.DataExecucao<="&mydatenull(DataAte)&" and ii.DataExecucao<>i.sysDate and i.AssociationAccountID=3 AND ii.ProfissionalID IN ("&req("ProfissionalExtID")&") and ii.Associacao=8 and i.CompanyUnitID="&UnidadeID & sqlProcsII & sqlExceptProcsII)
    end if

    if not inv.eof then
    %>

    <h4>ATENDIMENTOS EXECUTADOS - <%=ucase(NomeUnidade&"") %></h4>

    <div class="row col-md-12">
        <table class="table table-bordered table-condensed table-hover relatorio-tabela">
            <thead>
                <tr>
                    <th>Lançto</th>
                    <th>Execução</th>
                    <th>Prontuário</th>
                    <th>Paciente</th>
                    <th>Procedimento</th>
                    <th>Profissional</th>
                    <th>Descrição</th>
                    <th>Pagamento</th>
                    <th>Valor</th>
                </tr>
            </thead>
            <tbody>
            <%
            while not inv.eof
                valDesc = 0
                Forma = "0"
                NomeForma = ""
    '            set nf = db.execute("select PaymentMethod NomeForma from sys_financialpaymentmethod where id in ("&Forma&")")
    '            if not nf.eof then
    '                NomeForma = nf("NomeForma")
    '            end if
                %>
                <tr>
                    <td class="text-right"><%=left(inv("sysDate"),5) %></td>
                    <td class="text-right"><%=left(inv("DataExecucao"),5) %></td>
                    <td class="text-right"><%=zeroEsq(inv("Prontuario"), 8) %></td>
                    <td nowrap><a style="color:#000" target="_blank" href="./?P=Pacientes&Pers=1&I=<%=inv("AccountID") %>&Ct=1"><%=left(inv("NomePaciente"),30) %></a></td>
                    <td nowrap><%=left(inv("NomeProcedimento")&"", 30) %></td>
                    <td nowrap><%=inv("NomeProfissional") %></td>
                    <td><%=inv("Descricao") %></td>
                    <td nowrap style="padding:0">
                        <table width="100%" style="padding:0; margin:0; border:none!important">
                        <%
                        set descs = db.execute("select idesc.Valor, m.sysUser, m.PaymentMethodID PMID, pm.PaymentMethod Metodo, AccountAssociationIDDebit, AccountIDDebit, idesc.PagamentoID from itensdescontados idesc LEFT JOIN sys_financialmovement m on m.id=idesc.PagamentoID LEFT JOIN sys_financialpaymentmethod pm on pm.id=m.PaymentMethodID where ItemID="&inv("idItem"))
                        while not descs.eof
                            PMID = descs("PMID")
                            parcs = ""
                            if PMID=8 then
                                set trans = db.execute("select parcelas from sys_financialcreditcardtransaction where MovementID="&descs("PagamentoID"))
                                if not trans.eof then
                                    parcs = trans("Parcelas")&"x &nbsp;"
                                end if
                                parcs = trans("Parcelas")&"x &nbsp;"
                            end if
                            %>
                            <tr>
                                <td nowrap width="75%">
                                    <small>
                                        <%=parcs %>
                                        <%=left(replace(replace( descs("Metodo")&"" , "Cartão de ", ""), "Caixa de ", ""), 13) %>
                                        <%if PMID<>1 and PMID<>2 then %>
                                             &raquo; <%=left(replace(accountName(descs("AccountAssociationIDDebit"), descs("AccountIDDebit"))&"", "Caixa de ", ""), 13) %>
                                        <%end if %>
                                        </small>
                                    </td>
                                    </small>
                                </td>
                                <td nowrap class="text-right" width="25%"><small><%=fn(descs("Valor")) %></small></td>
                            </tr>
                            <%
                            valDesc = valDesc + descs("Valor")
                        descs.movenext
                        wend
                        descs.close
                        set descs=nothing
                        %>
                        </table>
                    </td>
                    <td class="text-right"><%=fn(valDesc) %></td>
                </tr>
                <%
            inv.movenext
            wend
            inv.close
            set inv=nothing
            %>
            </tbody>
        </table>
    </div>

        <%
        end if
    end if'fim da desabilitacao
    next 
end if
%>
<script >
$(document).ready(function() {
    $(".relatorio-tabela").dataTable({
     ordering: true,
     bPaginate: false,
     bLengthChange: false,
     bFilter: false,
     bInfo: false,
     bAutoWidth: false });
});
</script>