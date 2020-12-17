<!--#include file="connect.asp"-->
<%
TarefaID = req("I")

if erro="" and req("onlySta")="" and req("tarefasProjetos")="" and req("tarefasSprints")="" then
    set tar = db.execute("select sysActive from tarefas where id="&TarefaID)
    staDe = ref("staDe")
    staPara = ref("staPara")
    CategoriaID = ref("CategoriaID")
    if tar("sysActive")=0 then
        sqlAbertura = ", DtAbertura=curdate(), HrAbertura=curtime()"
 '       staDe = "Pendente"
 '       staPara = "Pendente"
    end if

    if ref("HrPrazo")<>"" then
        HoraPrazo = mytime(ref("HrPrazo"))
    else
        HoraPrazo = "NULL"
    end if

    db_execute("update tarefas set De="&session("User")&", Para='"&ref("Para")&"' "& sqlAbertura &", DtPrazo="&mydatenull(ref("DtPrazo"))&", HrPrazo="& HoraPrazo &", Solicitantes='"&req("Solicitantes")&"', Titulo='"&ref("Titulo")&"', ta='"&ref("Texto")&"', AvaliacaoNota="&treatvalzero(ref("AvaliacaoNota"))&", staDe='"&staDe&"', staPara='"&staPara&"', sysActive=1, Urgencia="&treatvalzero(ref("Urgencia"))&", CategoriaID="&treatvalzero("CategoriaID")&" , ProjetoID="&treatvalzero(ref("Projeto-ID"))&" where id="&TarefaID)

    %>



    gtag('event', 'nova_tarefa', {
        'event_category': 'tarefas',
        'event_label': "Tarefas > Salvar",
    });

    new PNotify({
        title: '<%=req("Val") %>',
        text: 'Tarefa salva com sucesso.',
        type: 'success',
        delay: 1000
    });
    $("#divCxInt").removeClass("hidden");
    <%
    call statusTarefas(session("User"), ref("Para"))
   	if session("OtherCurrencies")="phone" then
		set vcaCha = db.execute("select id from chamadas where StaID=1 AND sysUserAtend="&session("User"))
		if not vcaCha.EOF then
			db_execute("insert into chamadastarefas (ChamadaID, TarefaID) values ("&vcaCha("id")&", "&TarefaID&")")
		end if
	end if

end if

if req("onlySta")<>"" then
    set ptar = db.execute("select * from tarefas where id="&TarefaID)
    if req("onlySta")="auto" then
        if ptar("De")=session("User") then
            strDe = ", staDe='"&req("Val")&"'"
        end if
        if instr(ptar("Para"), "|"&session("User")&"|")>0 then
            strPara = ", staPara='"&req("Val")&"'"
        end if
 '       response.Write("update tarefas set "& strDe & strPara &" where id="&TarefaID)
        db.execute("update tarefas set sysActive=1 "& strDe & strPara &" where id="&TarefaID)
    else
        tipoSta = "Para"
        valAntigo = ptar("staPara")
        if req("onlySta") = "staDe" then
            tipoSta = "De"
            valAntigo = ptar("staDe")
        end if

        set tarefaExecucao = db.execute("SELECT * FROM tarefasexecucao WHERE Fim IS NULL AND TarefaID="&TarefaID&" ORDER BY 1 DESC LIMIT 1")
        if not tarefaExecucao.EOF then
            Execucao = tarefaExecucao("id")
        else
            Execucao = "NULL"
        end if

        db.execute("INSERT INTO tarefastatus_log (UsuarioID, StatusAnterior, StatusAtual, DePara, ExecucaoID, TarefaID) VALUES ("&session("User")&", '"&valAntigo&"', '"&req("Val")&"', '"&tipoSta&"', "&Execucao&", "&TarefaID&")")
        db_execute("update tarefas set "&req("onlySta")&"='"&req("val")&"' where id="&TarefaID)
    end if
        %>
        new PNotify({
            title: '<%=req("Val") %>',
            text: 'Status alterado com sucesso!',
            type: 'success',
            delay: 1000
        });
        <%
        if not ptar.eof then
                call statusTarefas(pTar("De"), pTar("Para"))
        end if
end if

if req("tarefasProjetos")<>"" then
    Ordem = req("Ordem")
    if Ordem = "" then
        Ordem = "NULL"
    end if
    Titulo = req("Titulo")
    TipoEstimado = req("TipoEstimado")
    TempoEstimado = req("TempoEstimado")
    ProjetoID = req("ProjetoID")
    CategoriaID = req("CategoriaID")
    Para = req("Para")
    Solicitantes = req("Solicitantes")

    ParaAux = REPLACE(Para, "|", "")
    ParaAux = SPLIT(ParaAux, ",")
    PRs = ""
    CCs = ""
    qtdAux = 1

    for each x in ParaAux
        cc = db.execute("SELECT CentroCustoID FROM profissionais WHERE id = "&x)
        val = cc("CentroCustoID")
        valAux = "|-" & val & "|,"
        if(InStr(CCs,valAux) = 0 and val <> "") then
            CCs = CCs & valAux
        end if

        pr = db.execute("SELECT id FROM sys_users WHERE idInTable = "&x)
        val = pr("id")
        if(qtdAux = (ubound(ParaAux)+1)) then
            valAux = "|" & val & "|"
        else
            valAux = "|" & val & "|,"
        end if
        if(InStr(PRs,valAux) = 0 and val <> "") then
            PRs = PRs & valAux
        end if

        qtdAux = qtdAux + 1
    next

    Para = CCs & PRs

    'response.write("INSERT INTO tarefas (Ordem, Titulo, TipoEstimado, TempoEstimado, ProjetoID, Para, Solicitantes, sysActive, De) VALUES ("&Ordem&", '"&Titulo&"', "&TipoEstimado&", "&TempoEstimado&", "&ProjetoID&", '"&Para&"', '"&Solicitantes&"', 1, "&session("User")&")")
    db.execute("INSERT INTO tarefas (Ordem, Titulo, TipoEstimado, TempoEstimado, ProjetoID, Para, Solicitantes, sysActive, De, CategoriaID) VALUES ("&Ordem&", '"&Titulo&"', "&TipoEstimado&", "&TempoEstimado&", "&ProjetoID&", '"&Para&"', '"&Solicitantes&"', 1, "&session("User")&", "&treatvalzero("CategoriaID")&")")

end if

if req("tarefasSprints")<>"" then
    Ordem = req("Ordem")
    if Ordem = "" then
        Ordem = "NULL"
    end if
    Titulo = req("Titulo")
    TipoEstimado = req("TipoEstimado")
    TempoEstimado = req("TempoEstimado")
    SprintID = req("SprintID")
    Para = req("Para")
    Solicitantes = req("Solicitantes")

    ParaAux = REPLACE(Para, "|", "")
    ParaAux = SPLIT(ParaAux, ",")
    PRs = ""
    CCs = ""
    qtdAux = 1

    for each x in ParaAux
        cc = db.execute("SELECT CentroCustoID FROM profissionais WHERE id = "&x)
        val = cc("CentroCustoID")
        valAux = "|-" & val & "|,"
        if(InStr(CCs,valAux) = 0 and val <> "") then
            CCs = CCs & valAux
        end if

        pr = db.execute("SELECT id FROM sys_users WHERE idInTable = "&x)
        val = pr("id")
        if(qtdAux = (ubound(ParaAux)+1)) then
            valAux = "|" & val & "|"
        else
            valAux = "|" & val & "|,"
        end if
        if(InStr(PRs,valAux) = 0 and val <> "") then
            PRs = PRs & valAux
        end if

        qtdAux = qtdAux + 1
    next

    Para = CCs & PRs

    db.execute("INSERT INTO tarefas (Ordem, Titulo, TipoEstimado, TempoEstimado, SprintID, Para, Solicitantes, sysActive, De) VALUES ("&Ordem&", '"&Titulo&"', "&TipoEstimado&", "&TempoEstimado&", "&SprintID&", '"&Para&"', '"&Solicitantes&"', 1, "&session("User")&")")

end if
%>