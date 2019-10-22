<!-- #include file = "connect.asp" -->
<table class="table table-striped table-condensed">
<%
if req("DtConc")<>"" then
    De = req("DtConc")
    Ate = cdate(req("DtConc"))+5
else
    De = req("De")
    Ate = req("Ate")
end if
%>

<%= quickfield("datepicker", "De", "De", 4, De, "", "", "") %>
    
<%


CD = req("CD")
if CD="C" then
    CDI = "D"
else
    CDI = "C"
end if
Val = req("Val")
    'falta colunas de conta e assoc
set movs = db.execute("SELECT * FROM sys_financialmovement m WHERE m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND m.Value<="& treatvalzero(Val) &" AND m.Type<>'Bill' AND CD='"& CDI &"' AND ISNULL(m.ConciliacaoID) ORDER BY m.Date, m.id")
while not movs.eof
    Descricao = ""
    if movs("Type")="Pay" then
        set pm = db.execute("SELECT i.AccountID, i.AssociationAccountID FROM sys_financialdiscountpayments dp LEFT JOIN sys_financialmovement m ON m.id=dp.InstallmentID LEFT JOIN sys_financialinvoices i ON i.id=m.InvoiceID WHERE dp.MovementID="& movs("id"))
        if not pm.eof then
            
            Descricao = accountName(pm("AssociationAccountID"), pm("AccountID"))
            
        end if
    end if
    %>
    <tr>
        <td><%= movs("Date") %></td>
        <td><%= Descricao %></td>
        <td nowrap class="text-right">R$ <%= fn(movs("Value")) %> <%= movs("CD") %></td>
    </tr>
    <%
movs.movenext
wend
movs.close
set movs = nothing
%>
</table>