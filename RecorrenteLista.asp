<!--#include file="connect.asp"-->
<%
I = req("I")
PrimeiroVencto = ref("PrimeiroVencto")
Intervalo = ref("Intervalo")
TipoIntervalo = ref("TipoIntervalo")
RepetirAte = ref("RepetirAte")
if isdate(RepetirAte) and RepetirAte<>"" then
    RepetirAte = cdate(RepetirAte)
else
    RepetirAte = cdate("01/01/2500")
end if
if PrimeiroVencto="" or not isdate(PrimeiroVencto) then
    PrimeiroVencto = date()
end if
If Intervalo="" or not isnumeric(Intervalo) then
    Intervalo = 1
else
    if ccur(Intervalo)<1 then
        Intervalo = 1
    end if
end if
if TipoIntervalo="" then
    TipoIntervalo = """m"""
end if

set fx = db.execute("select * from invoicesfixas where id="&I)
if not fx.eof then
    Geradas = fx("Geradas")&""
end if
%>
<table class="table table-condensed table-striped">
    <thead>
        <tr>
            <th>Vencimento</th>
            <th>Seq.</th>
            <th>Valor</th>
        </tr>
    </thead>
    <tbody>
        <%
        c = 0
        Data = PrimeiroVencto
        while c<=12 and cdate(Data)<=cdate(RepetirAte)
            c=c+1
            if instr(Geradas, "|"&c&"|") then
                set inv = db.execute("select (select Date from sys_financialmovement where InvoiceID=i.id limit 1) Vencimentos, i.Value from sys_financialinvoices i where i.FixaID="&I&" and i.FixaNumero="&c)
                if not inv.eof then
                %>
                <tr>
                    <td><b><%=inv("Vencimentos") %></b></td>
                    <td class="text-right"><b><%=c %></b></td>
                    <td class="text-right"><b><%=fn(inv("Value")) %></b></td>
                </tr>
                <%
                end if
            else
            %>
            <tr id="fix<%=c %>">
                <td><%= Data%></td>
                <td class="text-right"><%= c%></td>
                <td class="text-right">~ <%= ref("Valor") %></td>
            </tr>
            <%
            end if
            Data = dateadd(TipoIntervalo, Intervalo*c, PrimeiroVencto)
        wend
        %>
    </tbody>
</table>