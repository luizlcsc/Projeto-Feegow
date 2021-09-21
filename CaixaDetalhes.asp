<!--#include file="connect.asp"-->
<%
if req("BandeiraID")<>"" then
	sqlBand = " AND cc.BandeiraID="&req("BandeiraID")
end if
if req("Parcelas")<>"" then
	sqlParcs = " AND cc.Parcelas="&req("Parcelas")
end if
if req("DaisCheque")<>"" then
	sqlDC = " AND cc.DiasCheque="&req("DiasCheque")
end if

CD = mid(req("Div"), 5, 1)

'response.write("select cc.*, m.AccountAssociationIDCredit AssID, m.AccountIDCredit ContaID FROM cliniccentral.rel_fechamento"&mid(req("Div"), 5, 1)&" cc JOIN sys_financialmovement m on m.id=cc.MovimentoID WHERE cc.UsuarioID="&session("User")&" AND cc.MetodoID="&req("MetodoID") & sqlBand & sqlParcs & sqlDC & " ORDER BY cc.Data")
    if CD="C" then
        set mov = db.execute("select cc.*, m.AccountAssociationIDDebit AssID, m.AccountIDDebit ContaID, m.sysUser FROM cliniccentral.rel_fechamento"& CD &" cc JOIN sys_financialmovement m on m.id=cc.MovimentoID WHERE cc.UsuarioID="&session("User")&" AND cc.MetodoID="&req("MetodoID") & sqlBand & sqlParcs & sqlDC & " ORDER BY cc.Data")
    else
        set mov = db.execute("select cc.*, m.AccountAssociationIDCredit AssID, m.AccountIDCredit ContaID FROM cliniccentral.rel_fechamento"& CD &" cc JOIN sys_financialmovement m on m.id=cc.MovimentoID WHERE cc.UsuarioID="&session("User")&" AND cc.MetodoID="&req("MetodoID") & sqlBand & sqlParcs & sqlDC & " ORDER BY cc.Data")
    end if
while not mov.eof
    Omite = 0
    if mov("MetodoID")=2 then
        if mov("DiasCheque")<>ccur(req("DiasCheque")) then
            Omite = 1
        end if
    end if
    if Omite=0 then
	%>
	<tr>
		<td style="padding-left:90px">
<em>			<%=left(mov("Data"),5)%>
            &nbsp;&nbsp;&nbsp;
        <%
            response.write( accountName(mov("AssID"), mov("ContaID")) )
        if CD="C" then
            response.Write( " - " & nameInTable(mov("sysUser")) )
        end if
        %>
</em>        
		</td>
		<td class="text-right">
<em>			<%=formatnumber(mov("Valor"), 2)%>
</em>            <a class="blue hidden-print" onclick="modalPaymentDetails(<%=mov("MovimentoID")%>);" data-toggle="modal" role="button" href="#modal-table">
                <i class="far fa-search-plus"></i>
            </a>
        </td>
    </tr>
	<%
    end if
mov.movenext
wend
mov.close
set mov=nothing
%>