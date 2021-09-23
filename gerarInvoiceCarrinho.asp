<!--#include file="connect.asp"-->
function callHist(){
    $.get('HistoricoPacienteAgenda.asp?Obs=1&PacienteID=' + id, {}, function(result){
        if(result != ""){
            showMessageDialog(result, "info");
        }
        openComponentsModal('HistoricoPacienteAgenda.asp?PacienteID=' + id, false, 'Pacientes')
    })
}
<%

PacienteID = req("PacienteID")
AbrirHistorico = req("AbrirHistorico")&""

set AgendamentosDaBuscaSQL = db.execute("SELECT group_concat(ac.AgendamentoID) idAgenda, IFNULL(mov.id, 0) movementID FROM agendacarrinho ac inner join agendamentos a ON a.id = ac.AgendamentoID " &_ 
" LEFT JOIN itensinvoice ii ON ii.AgendamentoID = ac.AgendamentoID " &_ 
" LEFT JOIN sys_financialinvoices inv ON ii.InvoiceID = inv.id " &_ 
" LEFT JOIN sys_financialmovement mov ON   inv.id = mov.InvoiceID " &_ 
" WHERE a.Data >= DATE_FORMAT(now(), '%Y-%m-%d') and ac.PacienteID="&PacienteID&" AND mov.id IS NULL ")

if not AgendamentosDaBuscaSQL.eof then 
    while not AgendamentosDaBuscaSQL.eof
        idAgenda = AgendamentosDaBuscaSQL("idAgenda")&""
        if idAgenda <> "" then 
            sqlMovement = "select mov.id as movementID from sys_financialmovement mov INNER JOIN sys_financialinvoices inv ON inv.id = mov.InvoiceID " &_ 
                " LEFT JOIN itensinvoice ii ON ii.InvoiceID = inv.id WHERE ii.AgendamentoID in (" & idAgenda &")"
                set Movs = db.execute(sqlMovement)
                if Movs.eof then
                %>
                    $.post("checkinLancto.asp?Pers=1&PacienteID=<%=PacienteID%>&historicoPacienteAutomativo=1", {
                        LanctoCheckin:"<%=idAgenda%>_",
                        notPagar : "1"
                    }, function(result){
                    <%
                    if AbrirHistorico <> "nao" then
                    %>
                        callHist()
                    <%
                    end if
                    %>
                    });
                <%
                end if
            else
                
                    if AbrirHistorico <> "nao" then
                    %>
                        callHist()
                    <%
                    end if
                 
            end if

        AgendamentosDaBuscaSQL.movenext
    wend
else 

    if AbrirHistorico <> "nao" then
    %>
        callHist()
    <%
    end if
end if
%>