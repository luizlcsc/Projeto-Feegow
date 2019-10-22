<!--#include file="connect.asp"-->
<%
response.charset="utf-8"

nForn = req("nForn")
vForn = req("vForn")
if nForn<>"" then
    db.execute("update clinic5760.ContasBancarias set ContaID="& nForn &" where ContaID="& vForn &" and AssociacaoID=2")
    db.execute("update clinic5760.fornecedorcentrocusto set FornecedorID="& nForn &" where FornecedorID="& vForn &"")
    db.execute("update clinic5760.fornecedores_produtos set FornecedorID="& nForn &" where FornecedorID="& vForn &"")
    db.execute("update clinic5760.itensinvoice set ProfissionalID="& nForn &" where ProfissionalID="& vForn &" and Associacao=2")
    db.execute("update clinic5760.invoicesfixas set AccountID="& nForn &" where AccountID="& vForn &" and AssociationAccountID=2")
    db.execute("update clinic5760.rateiofuncoes set ContaPadrao='2_"& nForn &"' where ContaPadrao='2_"& vForn &"'")
    db.execute("update clinic5760.rateiorateios set ContaCredito='2_"& nForn &"' where ContaCredito='2_"& vForn &"'")
    db.execute("update clinic5760.sys_financialinvoices set AccountID="& nForn &" where AccountID="& vForn &" and AssociationAccountID=2")
    db.execute("update clinic5760.sys_financialmovement set AccountIDCredit="& nForn &" where AccountIDCredit="& vForn &" AND AccountAssociationIDCredit=2")
    db.execute("update clinic5760.sys_financialmovement set AccountIDDebit="& nForn &" where AccountIDDebit="& vForn &" AND AccountAssociationIDDebit=2")
    db.execute("delete from clinic5760.fornecedores where id="& vForn)
end if

%>
<table border="1">
    <tr>
        <th>id</th>
        <th>Nome</th>
        <th>CNPJ / CPF</th>
        <th>Contas a Pagar</th>
        <th>Conta Bancária</th>
    </tr>
<%
response.buffer
set pfor = db.execute("select id, NomeFornecedor, replace(replace(replace(f.CPF, '.', ''), '-', ''), '/', '') CPF FROM clinic5760.fornecedores f where sysActive=1 order by replace(replace(replace(f.CPF, '.', ''), '-', ''), '/', '')")
while not pfor.eof
    response.flush()
    set pcp = db.execute("select count(id) Total from clinic5760.sys_financialinvoices where AssociationAccountID=2 AND AccountID="& pfor("id"))
    cp = pcp("Total")
    if trim(pfor("CPF")&"")=ultimoCPF and ultimoCPF<>"" then
        cor = "red"
    else
        cor = ""
    end if
    ultimoCPF = trim(pfor("CPF")&"")
    %>
    <tr style="background-color:<%= cor %>">
        <td><%= pfor("id") %></td>
        <td><%= pfor("NomeFornecedor") %></td>
        <td><%= pfor("CPF") %></td>
        <td><%= cp %></td>
    </tr>
    <%
pfor.movenext
wend
pfor.close
set pfor = nothing
%>
</table>
