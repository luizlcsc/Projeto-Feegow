<!--#include file="connect.asp"-->
<%
ConvenioID= req("ConvenioID")
ProcedimentoID= req("ProcedimentoID")
EspecialidadeID= req("EspecialidadeID")
PacienteID= req("PacienteID")
ProfissionalID= req("ProfissionalID")
UnidadeID= req("UnidadeID")
TipoImpresso= req("Tipo")
Solicitante= req("solicitante")
AgendamentoID= req("AgendamentoID")
DataAgendamento = req("DataAgendamento")
Imprime=False
ProAssociationID = "5"
if instr(ProfissionalID,"_")>0 then
    splAccountInQuestion = split(ProfissionalID, "_")
	ProAssociationID = splAccountInQuestion(0)
	ProfissionalID = splAccountInQuestion(1)
end if

TipoFaturamentoLaudo = "PARTICULAR"
if ConvenioID&"" <> "" and ConvenioID&""<>"0" then
    TipoFaturamentoLaudo = "CONVENIO"
end if

if TipoImpresso="Protocolo" then
    set ProcedimentoLaudoSQL = db.execute("SELECT Laudo, DiasLaudo FROM procedimentos WHERE id="&ProcedimentoID&" AND Laudo=1")
    if not ProcedimentoLaudoSQL.eof then
        'imprime o protocolo do exame
        set LaudoExisteSQL = db.execute("SELECT l.id, t.DataExecucao FROM laudos l "&_
                                        "LEFT JOIN (SELECT id, DataExecucao, 'itensinvoice' Tabela FROM itensinvoice  UNION ALL SELECT id, Data DataExecucao, 'tissprocedimentossadt' Tabela FROM tissprocedimentossadt ) t ON t.id=l.IDTabela AND t.Tabela=l.Tabela "&_
                                        "WHERE l.PacienteID="&PacienteID&" AND l.ProcedimentoID="&ProcedimentoID&" AND t.DataExecucao="&mydatenull(DataAgendamento)&" LIMIT 1")


        if not LaudoExisteSQL.eof then
            LaudoID=LaudoExisteSQL("id")
        else
            if ProfissionalID&""<>"" then

                if TipoFaturamentoLaudo="CONVENIO" then
                    sqlRegistroLaudo = "SELECT 'tissprocedimentossadt' TipoRegistro, ii.id IDRegistro FROM tissprocedimentossadt ii INNER JOIN tissguiasadt i ON i.id=ii.GuiaID WHERE i.PacienteID="&PacienteID&" AND ii.ProfissionalID="&ProfissionalID&" AND ii.Associacao in (5,0) AND ii.ProcedimentoID="&ProcedimentoID&" AND ii.Data=CURDATE()"
                else
                    sqlRegistroLaudo = "SELECT 'itensinvoice' TipoRegistro, ii.id IDRegistro FROM itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AssociationAccountID=3 AND i.AccountID="&PacienteID&" AND ii.ProfissionalID="&ProfissionalID&" AND ii.Associacao in (5,0) AND ii.ItemID="&ProcedimentoID&" AND ii.Tipo='S' AND ii.DataExecucao=CURDATE()"
                end if

                set RegistroLaudoSQL = db.execute(sqlRegistroLaudo)
                if not RegistroLaudoSQL.eof then
                    IdRegistro=RegistroLaudoSQL("IDRegistro")
                    TipoRegistro=RegistroLaudoSQL("TipoRegistro")
                    PrazoEntrega=ProcedimentoLaudoSQL("DiasLaudo")

                    if isnull(PrazoEntrega) then
                        PrazoEntrega=1
                    end if

                    db.execute("INSERT INTO laudos (PacienteID, ProcedimentoID, PrevisaoEntrega, ProfissionalID, StatusID, Tabela, IDTabela) VALUES ("&PacienteID&", "&ProcedimentoID&", "&mydatenull(dateadd("d", PrazoEntrega, date()))&","&ProfissionalID&",1,'"&TipoRegistro&"', "&IdRegistro&")")

                    set LaudoSQL = db.execute("SELECT id FROM laudos ORDER BY id DESC LIMIT 1")
                    LaudoID=LaudoSQL("id")
                end if
            end if
        end if

        if LaudoID<>"" then
            UrlPrint = "printLaudoProtocolo.asp?L="&LaudoID&"&AgendamentoID="&AgendamentoID
            Imprime=True
            %>
            $("#ImpressaoProcedimento").remove();
            $("body").append("<iframe id='ImpressaoProcedimento' src='<%=UrlPrint%>' style='display:none;'></iframe>")
            <%
        else
            if TipoFaturamentoLaudo="CONVENIO" then
                TipoConta="Guia SP/SADT"
            else
                TipoConta="conta"
            end if

            %>
            showMessageDialog("Nenhuma <%=TipoConta%> foi gerada para este atendimento.", "warning");
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
    set ImpressosModeloSQL = db.execute("SELECT id FROM procedimentosmodelosimpressos WHERE Procedimentos LIKE '%|"&ProcedimentoID&"|%' AND sysActive=1")
    

    if ProfissionalID <> "" then
        if not ImpressosModeloSQL.eof then
            UrlPrint = "printProcedimentoImpresso.asp?I="&ImpressosModeloSQL("id")&"&Solicitante="&Solicitante&"&PacienteID="&PacienteID&"&UnidadeID="&UnidadeID&"&ProfissionalID="&ProfissionalID&"&ProcedimentoID="&ProcedimentoID
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
    else
    %>
        showMessageDialog("Favor preencher profissional.", "warning");
    <%
    end if
end if


%>