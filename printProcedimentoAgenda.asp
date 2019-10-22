<!--#include file="connect.asp"-->
<%
ProcedimentoID= req("ProcedimentoID")
EspecialidadeID= req("EspecialidadeID")
PacienteID= req("PacienteID")
ProfissionalID= req("ProfissionalID")
UnidadeID= req("UnidadeID")
TipoImpresso= req("Tipo")
DataAgendamento = req("DataAgendamento")
Imprime=False

if TipoImpresso="Protocolo" then
    set ProcedimentoLaudoSQL = db.execute("SELECT Laudo, DiasLaudo FROM procedimentos WHERE id="&ProcedimentoID&" AND Laudo=1")
    if not ProcedimentoLaudoSQL.eof then
        'imprime o protocolo do exame

        set LaudoExisteSQL = db.execute("SELECT l.id FROM laudos l LEFT JOIN itensinvoice ii ON ii.id=l.IDTabela WHERE l.PacienteID="&PacienteID&" AND l.ProcedimentoID="&ProcedimentoID&" AND ii.DataExecucao='"&DataAgendamento&"'")


        if not LaudoExisteSQL.eof then
            LaudoID=LaudoExisteSQL("id")
        else
            set ItemInvoiceSQL = db.execute("SELECT ii.id FROM itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AssociationAccountID=3 AND i.AccountID="&PacienteID&" AND ii.ProfissionalID="&ProfissionalID&" AND ii.Associacao in (5,0) AND ii.ItemID="&ProcedimentoID&" AND ii.Tipo='S' AND ii.DataExecucao=CURDATE()")
            if not ItemInvoiceSQL.eof then
                ItemInvoiceID=ItemInvoiceSQL("id")
                PrazoEntrega=ProcedimentoLaudoSQL("DiasLaudo")

                if isnull(PrazoEntrega) then
                    PrazoEntrega=1
                end if

                db.execute("INSERT INTO laudos (PacienteID, ProcedimentoID, PrevisaoEntrega, ProfissionalID, StatusID, Tabela, IDTabela) VALUES ("&PacienteID&", "&ProcedimentoID&", "&mydatenull(dateadd("d", PrazoEntrega, date()))&","&ProfissionalID&",1,'itensinvoice', "&ItemInvoiceID&")")

                set LaudoSQL = db.execute("SELECT id FROM laudos ORDER BY id DESC LIMIT 1")
                LaudoID=LaudoSQL("id")
            end if
        end if

        if LaudoID<>"" then
            UrlPrint = "printLaudoProtocolo.asp?L="&LaudoID
            Imprime=True
            %>
            $("#ImpressaoProcedimento").remove();
            $("body").append("<iframe id='ImpressaoProcedimento' src='<%=UrlPrint%>' style='display:none;'></iframe>")
            <%
        else
            %>
            showMessageDialog("Nenhuma conta foi gerada para este atendimento.", "warning");
            <%
        end if
    else
        %>
        showMessageDialog("Este procedimento não está habilitado para laudo.", "warning");
        <%
    end if
end if

if TipoImpresso="Etiqueta" then

    set AgendamentoSQL = db.execute("SELECT id FROM agendamentos WHERE Data=CURDATE() AND ProfissionalID="&treatvalzero(ProfissionalID)&" AND PacienteID="&PacienteID&" LIMIT 1")
    if not AgendamentoSQL.eof then
        AgendamentoID = AgendamentoSQL("id")
    end if

    UrlPrint = "printEtiquetaPaciente.asp?PacienteID="&PacienteID&"&AgendamentoID="&AgendamentoID&"&DataAgendamento="&DataAgendamento&"&ProfissionalID="&ProfissionalID&"&ProcedimentoID="&ProcedimentoID

    %>
    $("#ImpressaoEtiqueta").remove();
    $("body").append("<iframe id='ImpressaoEtiqueta' src='<%=UrlPrint%>' style='display:none;'></iframe>")
    <%

end if

if TipoImpresso="Impresso" then
    set ImpressosModeloSQL = db.execute("SELECT id FROM procedimentosmodelosimpressos WHERE Procedimentos LIKE '|%"&ProcedimentoID&"%|'")

    if not ImpressosModeloSQL.eof then
        UrlPrint = "printProcedimentoImpresso.asp?I="&ImpressosModeloSQL("id")&"&PacienteID="&PacienteID&"&UnidadeID="&UnidadeID&"&ProfissionalID="&ProfissionalID&"&ProcedimentoID="&ProcedimentoID
        Imprime=True
    %>
    $("#ImpressaoProcedimento").remove();
    $("body").append("<iframe id='ImpressaoProcedimento' src='<%=UrlPrint%>' style='display:none;'></iframe>")
    <%
    else
        %>
    showMessageDialog("Este procedimento não possui nenhum modelo a ser impresso.", "warning");
        <%
    end if
end if


%>