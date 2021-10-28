<!--#include file="connect.asp"-->
<%

limparDados = 1
todosMarcados = 1
sessaoAgenda = ref("sessaoAgenda")

set todosAgendados = db.execute("SELECT id FROM agendacarrinho WHERE sysUser="&session("User")&" AND sessaoAgenda='"&sessaoAgenda&"' AND Arquivado IS NULL AND AgendamentoID IS NULL")
if not todosAgendados.eof then 
    todosMarcados = 0
end if

if todosMarcados = 0 then
%>
    showMessageDialog("Existem itens no carrinho sem agendamento.", "danger");
<%
else 

carrinhoID = ref("carrinhoID")
sqlCarrinho = ""

if carrinhoID&"" <> "" then 
    sqlCarrinho = " OR AgendamentoID IN ("&carrinhoID&") "
end if

set AgendamentosDaBuscaSQL = db.execute("SELECT group_concat(AgendamentoID) Agendamentos,PacienteID FROM agendacarrinho WHERE sysUser="&session("User")&" AND sessaoAgenda='"&sessaoAgenda&"' AND Arquivado IS NULL " & sqlCarrinho )

if not AgendamentosDaBuscaSQL.eof then
    idAgendamento = AgendamentosDaBuscaSQL("Agendamentos")
    PacienteID = AgendamentosDaBuscaSQL("PacienteID")
    if not isnull(idAgendamento) then
            
            sqlMovement = "select mov.id as movementID from sys_financialmovement mov INNER JOIN sys_financialinvoices inv ON inv.id = mov.InvoiceID " &_ 
            " LEFT JOIN itensinvoice ii ON ii.InvoiceID = inv.id WHERE ii.AgendamentoID in (" & idAgendamento &")"
            set Movs = db.execute(sqlMovement)
            if Movs.eof then
            %>
                $.post("checkinLancto.asp?Pers=1&PacienteID=<%=PacienteID%>&historicoPacienteAutomativo=1", {
                    LanctoCheckin:"<%=idAgendamento%>_",
                    notPagar : "1"
                }, function(result){
                    
                });
            <%
            end if
        %>
        openComponentsModal("ModalPreparo.asp", {finalizar: '1', Agendamentos: '<%=idAgendamento%>'}, "Finalizar Agendamento", true)
        Limpar(0);
        <%
        limparDados = 0
    end if
end if

db.execute("update agendacarrinho SET Arquivado=NOW() WHERE sysUser="& session("User") &" AND sessaoAgenda='"&sessaoAgenda&"' AND Arquivado IS NULL")
if limparDados = 1 then 
%>          
    Limpar(1);
<% 
end if 
%>
    var $tableCarrinho = $("#divCart").find("table");
    if($tableCarrinho){
        $tableCarrinho.remove();
        $("#divBusca").html("");
    }
    //location.href="./?P=MultiplaFiltros2&Pers=1";
<%
end if
%>