<!--#include file="connect.asp"-->
<%
configExibirNaSalaDeEspera = getConfig("ExibirEquipamentoNaSalaDeEspera")
OrdensNome="Hor&aacute;rio Agendado, Hor&aacute;rio de Chegada, Idade do Paciente"
Ordens="HoraSta, Hora, pac.Nascimento ASC"
splOrdensNome=split(OrdensNome, ", ")
unidadesBloqueioAtendimento = getConfig("BloquearAtendimentoMediantePagamento")

Ordem="Hora"
StatusExibir=req("StatusExibir")
ExibirChamar = getConfig("ExibirChamar")

if StatusExibir="" then
    StatusExibir="4"
end if

HorarioVerao = ""
if session("UnidadeID")=0 then
    set getNome = db.execute("select * from empresa")
    if not getNome.eof then
        FusoHorario = getNome("FusoHorario")
        HorarioVerao = getNome("HorarioVerao")
    end if
elseif session("UnidadeID")>0 then
    set getNome = db.execute("select * from sys_financialcompanyunits where id="&session("UnidadeID"))
    if not getNome.eof then
        FusoHorario = getNome("FusoHorario")
        HorarioVerao = getNome("HorarioVerao")
    end if
end if

if req("ProfissionalID")<>"" then
    ProfissionalID = req("ProfissionalID")
    sqlProfissional = " AND a.ProfissionalID="&ProfissionalID
else
    ProfissionalID=session("idInTable")
end if

splOrdens=split(Ordens, ", ")
	if req("Ordem")<>"" then
		db_execute("update sys_users set OrdemListaEspera='"&req("Ordem")&"' where id="&session("User"))
	end if
	set pUsu=db.execute("select * from sys_users where id="&session("User"))
	if isNull(pUsu("OrdemListaEspera")) then
		if session("Table")<>"profissionais" then
			Ordem="HoraSta"
		else
            Ordem="Hora"
		end if
	else

	    on error resume next
        Ordem=pUsu("OrdemListaEspera")
        On Error GoTo 0

	end if


DataHoje=date()
set ConfigGeraisSQL = db.execute("SELECT * FROM sys_config WHERE id=1")

if not ConfigGeraisSQL.eof then
    ChamarAposPagamento=ConfigGeraisSQL("ChamarAposPagamento")
end if

if request.QueryString("Chamar")<>"" then

    StaChamando = 5
    'triagem
    if lcase(session("table"))="profissionais" then


        if not ConfigGeraisSQL.eof then

            if ConfigGeraisSQL("Triagem")="S" then
                set AgendamentoSQL = db.execute("SELECT age.StaID,p.EspecialidadeID, age.PacienteID,age.Data,age.Hora,age.id, age.TipoCompromissoID FROM agendamentos age LEFT JOIN profissionais p ON p.id = "&ProfissionalID&" WHERE age.id = "&req("Chamar"))

                db_execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID) values ('"&AgendamentoSQL("PacienteID")&"', '"&ProfissionalID&"', '"&AgendamentoSQL("TipoCompromissoID")&"', '"&now()&"', '"&mydate(AgendamentoSQL("Data"))&"', "&mytime(AgendamentoSQL("Hora"))&", '"&StaChamando&"', '"&session("User")&"', '0', 'Chamada para atendimento', 'A', '"&AgendamentoSQL("id")&"')")
            else
                sqlProfissional = ", ProfissionalID="&ProfissionalID
            end if
        end if
    end if

	db_execute("update agendamentos set StaID='"&StaChamando&"' "& sqlProfissional &" where id = '"&req("Chamar")&"'")
	set dadosAgendamento = db.execute("select PacienteID, ProfissionalID from agendamentos where id = '"&request.QueryString("Chamar")&"'")
	if not dadosAgendamento.eof then
		call gravaChamada(dadosAgendamento("ProfissionalID"), dadosAgendamento("PacienteID"))
	end if

    set age = db.execute("select ProfissionalID from agendamentos where id="&req("Chamar"))
    if not age.eof then
        getEspera(age("ProfissionalID"))
    end if
end if

'da redirect ao atender
if request.QueryString("Atender")<>"" then
	'db_execute("update agendamentos set StaID='3' where StaID = '2' and ProfissionalID = '"&ProfissionalID&"'") -  não muda mais automaticamente para atendido, apenas quando encerra o contador
	db_execute("update agendamentos set StaID='2', ProfissionalID="&ProfissionalID&" where id = '"&request.QueryString("Atender")&"' AND ProfissionalID = 0")
    getEspera(ProfissionalID)
	response.Redirect("?P=Pacientes&Pers=1&I="&req("PacienteID")&"&Atender="&req("Atender")&"&Acao=Iniciar")
end if

sqlunidades  = "select Unidades from " & session("table") &" where id = " & session("idInTable")
set UnidadesUser  = db.execute(sqlunidades)
UnidadesUser = replace(UnidadesUser("Unidades"), "|", "")
lista = split(UnidadesUser, ",")
sqlOR = ""
for z=0 to ubound(lista)
    sqlOR = sqlOR & " or CONCAT('|',a.localid,'|') like '%|"& replace(lista(z), " ","") &"|%' "
next
sqlOR = " AND (false " & sqlOR & ") "


if lcase(session("Table"))<>"profissionais" or req("ProfissionalID")<>"" then
    sqlTotal = "SELECT count(*) total, l.UnidadeID " &_
               "FROM agendamentos a " &_
               "INNER JOIN pacientes pac ON pac.id=a.PacienteID " &_
               "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID " &_
               "LEFT JOIN locais l on l.id=a.LocalID " &_
               "WHERE a.Data = '"&mydate(DataHoje)&"' and a.StaID in(2, 5, "&StatusExibir&") " &_
               "AND (l.UnidadeID <> "&session("UnidadeID")&" and not isnull(l.UnidadeID)) "&sqlProfissional&" " &_
               "group by(l.UnidadeID) order by total desc limit 1 "
    sql = "SELECT a.*, p.NomeProfissional,p.EspecialidadeID, l.UnidadeID, tp.NomeTabela,  a.ValorPlano+(select if(rdValorPlano = 'V', ifnull(sum(ValorPlano),0),0) " &_
          "FROM agendamentosprocedimentos " &_
          "WHERE agendamentosprocedimentos.agendamentoid = a.id) as ValorPlano " &_
          "FROM agendamentos a " &_
          "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID " &_
          "LEFT JOIN profissionais p on p.id=a.ProfissionalID " &_
          "INNER JOIN pacientes pac ON pac.id=a.PacienteID " &_
          "LEFT JOIN locais l on l.id=a.LocalID " &_
          "WHERE Data = '"&mydate(DataHoje)&"' and StaID in(2, 5, "&StatusExibir&", 102, 33,105,106, 101, 5) " &_
          "AND (l.UnidadeID="&treatvalzero(session("UnidadeID"))&" or isnull(l.UnidadeID)) "& sqlProfissional & sqlOR &" order by "&Ordem
else
    'triagem
    sqlSalaDeEspera = ""
    if configExibirNaSalaDeEspera = 0 then
        sqlSalaDeEspera  = " a.ProfissionalID !=0 and "
    end if
    sqlTotal = "SELECT count(*) total, l.UnidadeID " &_
               "FROM agendamentos a " &_
               "INNER JOIN pacientes pac ON pac.id=a.PacienteID " &_
               "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID " &_
               "LEFT JOIN locais l on l.id=a.LocalID  " &_
               "WHERE a.Data = '"&mydate(DataHoje)&"' and a.ProfissionalID in("&ProfissionalID&", 0) " &_
               "and a.StaID in(2, 5, "&StatusExibir&") and (l.UnidadeID <> "&session("UnidadeID")&" and not isnull(l.UnidadeID))  " &_
               "group by(l.UnidadeID) order by total desc limit 1 "
	sql = "SELECT a.*, tp.NomeTabela,  a.ValorPlano+(select if(rdValorPlano = 'V', ifnull(sum(ValorPlano),0),0) " &_
          "from agendamentosprocedimentos where agendamentosprocedimentos.agendamentoid = a.id) as ValorPlano " &_
          "from agendamentos a INNER JOIN pacientes pac ON pac.id=a.PacienteID " &_
          "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID " &_
          "LEFT JOIN locais l on l.id=a.LocalID  " &_
          "LEFT JOIN profissionais p on p.id=a.ProfissionalID " &_
          "WHERE "&sqlSalaDeEspera&" a.Data = '"&mydate(DataHoje)&"' " &_
          "AND a.ProfissionalID in("&ProfissionalID&", 0) " &_
          "AND a.StaID in(2, 5, "&StatusExibir&") " &_
          "AND (l.UnidadeID="&treatvalzero(session("UnidadeID"))&" or isnull(l.UnidadeID)) "& sqlOR &" order by "&Ordem&" "

end if

if lcase(session("table"))="profissionais" then
    if not ConfigGeraisSQL.eof then
        if ConfigGeraisSQL("Triagem")="S" then
            Triagem = "S"
            TriagemProcedimentos = ConfigGeraisSQL("TriagemProcedimentos")
            ProfissionalTriagem="N"

            sqlTriagem = "SELECT IF(conf.TriagemEspecialidades LIKE CONCAT('%',prof.EspecialidadeID,'%'),1,0)EspecialidadeTriagem FROM profissionais prof "&_
                         "INNER JOIN sys_config conf  "&_
                         "WHERE prof.id = "&ProfissionalID

'enfermeira ou tec enfermagem
            set ProfissionalTriagemSQL = db.execute(sqlTriagem)
            if not ProfissionalTriagemSQL.eof then
                if ProfissionalTriagemSQL("EspecialidadeTriagem")="1" then
                    ProfissionalTriagem="S"
                    sql = "select age.*, profage.NomeProfissional, tp.NomeTabela from agendamentos age LEFT JOIN tabelaparticular tp on tp.id=age.TabelaParticularID LEFT JOIN profissionais profage ON profage.id=age.ProfissionalID INNER JOIN pacientes pac ON pac.id=age.PacienteID LEFT JOIN locais l ON l.id=age.LocalID where age.Data = '"&mydate(DataHoje)&"' and age.StaID in(2,"&StatusExibir&", 5, 102,105,106) AND '"&TriagemProcedimentos&"' LIKE CONCAT('%|',age.TipoCompromissoID,'|%') AND (l.UnidadeID IS NULL or l.UnidadeID='"&session("UnidadeID")&"') or '"&session("UnidadeID")&"'='' order by "&Ordem
                end if
            end if
        end if
    end if
end if

set veseha=db.execute(sql)'Hora

if session("Table")="profissionais" then
    set vtotal=db.execute(sqlTotal)'Hora
    if not vtotal.eof then
    %>
        <div class="alert alert-warning">Existem pacientes para ser atendido em outra unidade <a href="?P=Home&Pers=1&MudaLocal=<%=vtotal("UnidadeID")%>" class="btn btn-default">MUDAR DE UNIDADE</a></div>
    <%
    end if
end if

if veseha.eof then
	%>Nenhum paciente aguardando para ser atendido.<%
else
%>
<div class="table-responsive">
<table width="100%" class="table table-striped table-hover table-bordered">
  <thead>
	<tr class="info">
    	<th>HORA</th>
    	<th>CHEGADA</th>
        <th>PACIENTE</th>
        <th>IDADE</th>
        <% If session("Table")<>"profissionais" Then %><th>PROFISSIONAL</th><% End If %>
        <th>COMPROMISSO</th>
        <th>TEMPO DE ESPERA</th>
        <th>PAGTO</th>
        <%if ExibirChamar=1 then%>
        <th width="1%">CHAMAR</th>
        <%end if%>
        <%if lcase(session("table"))="profissionais" then %>
        <th width="1%">ATENDER</th>
        <%end if %>
    </tr>
  </thead>
  <tbody>
	<%

	ExibirLinkParaFicha = getConfig("ExibirLinkParaFicha")

    while not veseha.eof
        SubtipoAgendamento=""
        if not isNull(veseha("SubtipoProcedimentoID")) and not veseha("SubtipoProcedimentoID")=0 then
            set pSubTP=db.execute("select * from SubtiposProcedimentos where id = '"&veseha("SubtipoProcedimentoID")&"'")
            if not pSubTP.eof then
                SubtipoAgendamento=pSubTP("SubtipoProcedimento")
            end if
        end if
        if  session("Banco")<>"clinic5856" then
            Notas=veseha("Notas")
        end if
        Hora=veseha("Hora")
		if not isnull(Hora) then
			Hora = formatdatetime(Hora, 4)
		end if
		ProfissionalID=veseha("ProfissionalID")
        HoraSta=veseha("HoraSta")
		if not isnull(HoraSta) then
			HoraSta = formatdatetime(HoraSta, 4)
		end if
        Sta=veseha("StaID")

        if not veseha.EOF then
            PacId=veseha("PacienteID")
            set pPac=db.execute("select * from pacientes where id = '"&veseha("PacienteId")&"'")
            if not pPac.EOF then
                Nome=pPac("NomePaciente")
                NomeSocial = pPac("NomeSocial")&""
                if NomeSocial<>"" then
                    Nome = Nome &"<br><code>Nome social: "& NomeSocial &"</code>"
                end if
                Imagem=pPac("Foto")
                DataNascimento=pPac("Nascimento")
            end if
            set pTip=db.execute("select * from procedimentos where id ="&veseha("TipoCompromissoID"))

            set pSta=db.execute("select * from staconsulta where id = '"&veseha("StaID")&"'")
            if not pSta.EOF then
                StaConsulta=pSta("StaConsulta")
            end if
            if veseha("rdValorPlano")="V" then
				if aut("areceberpacienteV")=1 then
	                Valor = veseha("ValorPlano")
				else
					Valor = ""
				end if
            else
                set pPlan=db.execute("select * from convenios where id = '"&veseha("ValorPlano")&"'")
                if not pPlan.EOF then
                    Valor="<center>"&pPlan("NomeConvenio")&"</center>"
                end if
            end if

            if session("Banco")="clinic100000" or session("Banco")="clinic2263" or session("Banco")="clinic5856" then
                 set TabelaSQL = db.execute("SELECT t.NomeTabela FROM tabelaparticular t LEFT JOIN pacientes p ON p.Tabela=t.id WHERE p.id = "&veseha("PacienteID"))
                if not TabelaSQL.eof then
                    Valor = TabelaSQL("NomeTabela")
                end if
            end if
            if not pTip.EOF then
                TipoCompromisso=ucase(pTip("NomeProcedimento"))
                set OutrosProcedimentos = db.execute("SELECT GROUP_CONCAT(' /<br>',UPPER(p.NomeProcedimento))procs,rdValorPlano, if(rdValorPlano = 'V', ((select IFNULL(ValorPlano,0) from agendamentos where id = a.AgendamentoId) + (ifnull(sum(a.ValorPlano), 0))), a.ValorPlano) as ValorPlano FROM agendamentosprocedimentos a LEFT JOIN procedimentos p ON p.id = a.TipoCompromissoID WHERE a.AgendamentoID = "&veseha("id"))
                if not OutrosProcedimentos.eof then
                    if OutrosProcedimentos("rdValorPlano")="V" and not isnull(OutrosProcedimentos("ValorPlano")) then
                        if isnumeric(Valor) and isnumeric(OutrosProcedimentos("ValorPlano")) then
                            Valor = OutrosProcedimentos("ValorPlano")
                        end if
                    end if
                    OutrosProcedimentosStr = OutrosProcedimentos("procs")
                end if
            end if
        end if

        if isnumeric(Valor) then
            Valor = fn(Valor)
        end if
        if not isnull(veseha("NomeTabela")) then
            Valor = Valor & "<br><code>"& veseha("NomeTabela") &"</code>"
        end if

    disabPagto = ""
    labelDisabled = ""

    if ExibirLinkParaFicha then
        tagPaciente = "a"
    else
        tagPaciente = "div"
    end if
    exibeLinha = "S"
    Triado=False

    if Triagem="S" then
        if instr(TriagemProcedimentos, "|"&veseha("TipoCompromissoID")&"|") then
            set AtendimentoTriagemSQL = db.execute("SELECT ate.id, ate.ProfissionalID,ate.Triagem FROM atendimentos ate WHERE HoraFim is not null and ate.AgendamentoID="&veseha("id")&" ORDER BY ate.Triagem limit 1")

            if ProfissionalTriagem="N" then
                    ' adicionar mais Where
                    if AtendimentoTriagemSQL.eof then
                        disabPagto = " disabled"
                        labelDisabled = "Pendente de Triagem"
                        tagPaciente = "div"
                    else
                        Triado = True
                        if ConfigGeraisSQL("PosConsulta")="S" and AtendimentoTriagemSQL("Triagem")="N" then
                            disabPagto = " disabled"
                            labelDisabled = "Pendente de Pós-consulta"
                            tagPaciente = "div"
                        end if
                    end if
            else
                    ' adicionar mais Where

                    if not AtendimentoTriagemSQL.eof then
                        exibeLinha = "N"

                        if ConfigGeraisSQL("PosConsulta")="S" and AtendimentoTriagemSQL("Triagem")="N" then
                            exibeLinha="S"
                            compromisso = " (Pós-consulta)"
                        end if
                    else

                        compromisso = " (Triagem) - "& veseha("NomeProfissional")
                    end if
            end if
        end if
    end if
    if session("Banco")="clinic105" or session("Banco")="clinic5856" then
        cssAdicionl = "data-toggle='tooltip' title='Nascimento: "&DataNascimento&"'"
    else
        cssAdicionl = ""
    end if


    if not ConfigGeraisSQL.eof then
        if ChamarAposPagamento="S" and (inStr(unidadesBloqueioAtendimento, "|"&session("UnidadeID")&"|")<>"0" or unidadesBloqueioAtendimento&""="") then

            if veseha("FormaPagto") < 0 and veseha("ValorPlano")>0 then
                if Triagem="S" and ProfissionalTriagem="N" and labelDisabled = "Pendente de Triagem" then
                    'exibeLinha = "N"
                end if

                disabPagto = "disabled"
                labelDisabled = "Pendente de pgto."
                tagPaciente = "div"
            end if
        end if
    end if

    if exibeLinha="S" then
        if Sta=33 then
            fLinha = " class='warning' "
            rowspan = " rowspan=2 "
        else
            fLinha = ""
            rowspan = ""
        end if
        %>
    <tr <%= fLinha %>>
    <td nowrap <%= rowspan %> ><img src="assets/img/<%=Sta%>.png" /> <%=Hora%></td>
    <td <%= rowspan %> ><%= HoraSta %></td>
    <%

    %>
    <td <%if not isnull(Imagem) and not Imagem="" then%>class="hotspot" onMouseOver="tooltip.show('<img src=<%=EnderecoImagens%>/<%=Imagem%> width=100>');"<%end if%>>
    	<%
        'set veSePre=db.execute("select * from PacienteAnamneses where preAtendimento like 'S' and Data like '"&DataHoje&"' and PacienteID = '"&PacId&"'")
        'if not veSePre.EOF then
			'<img src="checked.jpg" />
		'end if%>
		<%if veseha("Encaixe")=1 then%><span class="label label-alert ml5">Encaixe </span><%end if%>
		<%if veseha("Primeira")=1 then%><span class="label label-info ml5">Primeira vez</span><%end if%>
		<<%=tagPaciente%> href="./?P=Pacientes&Pers=1&I=<%=veseha("PacienteID")%>" <%=cssAdicionl%>><%=Nome%></<%=tagPaciente%>><br />
		<small><%=Notas%></small></td>
        <td><%=IdadeAbreviada(DataNascimento)%></td>
    <% If session("Table")<>"profissionais" Then %><td><%=veseha("NomeProfissional")%></td><% End If %>
    <td ><%=TipoCompromisso%><%=compromisso%><%=OutrosProcedimentosStr%><%
    if SubtipoAgendamento<>"" then
		response.Write(" &raquo; <small>"&SubtipoAgendamento&"</small>")
	end if
    %></td>
    <td nowrap="nowrap">
    <%=StaConsulta%>&nbsp;<%
    TempoEspera=""
    if veseha("StaID")=4 or veseha("StaID")=8 then
		if veseha("Data")=DataHoje then
		%><span class="waiting-time" data-arrival="<%=mydatenull(veseha("HoraSta"))%>T<%=mytime(veseha("HoraSta"))%>"></span><%
		end if
    end if
    if Triado=True then
		%>
		<span class="label label-dark">Triado</span>
		<%
    end if
    %>
    </td>
    <td nowrap="nowrap" class="text-center"><%=Valor%></td>
    <%if ExibirChamar=1 then%>
    <td>
        <% if session("Banco")<>"clinic5760" then %>
        <button class="btn btn-xs btn-warning" type="button" <%=disabPagto%> <%
        if veseha("StaID")<>4 and veseha("StaID")<>101 and veseha("StaID")<>102 then
            %> disabled<%
        else
            %> onClick="window.location='?P=ListaEspera&Pers=1&Chamar=<%=veseha("id")%>';"<%
        end if
		%>>CHAMAR
		<%
        if disabPagto <> "" then
            %>
            <small>*<%=labelDisabled%></small>
            <%
        end if
        %>
		</button>
        <% end if %>

    </td>
    <%end if%>

    <%if lcase(session("table"))="profissionais" then %>
    <td>
        <%if veseha("StaID")<>2 then%>
    	<button
    	 <%

        if veseha("StaID")<>4 and veseha("StaID")<>5 and veseha("StaID")<>33 then
            %> disabled<%
        else
            %> onClick="window.location='?P=ListaEspera&Pers=1&Atender=<%=veseha("id")%>&PacienteID=<%=veseha("PacienteID")%>';"<%
        end if
        %>
    	 class="btn btn-xs btn-success" type="button" <%=disabPagto%> >ATENDER</button>
    	<%else%>
    	<button onClick="window.location='?P=Pacientes&Pers=1&I=<%=veseha("PacienteID")%>'" class="btn btn-xs btn-primary" type="button">IR PARA ATENDIMENTO</button>
    	<%end if%>
    </td>
    <%end if %>
    </tr>
        <%
        if Sta=33 then

            %>
            <tr class="warning">
                <td colspan="7">
                <table class="table table-condensed table-bordered">
                    <%
                    set esp = db.execute("select e.*, ep.ProcedimentoID, ep.Obs, proc.NomeProcedimento from espera e LEFT JOIN esperaprocedimentos ep ON ep.EsperaID=e.id LEFT JOIN procedimentos proc ON proc.id=ep.ProcedimentoID where e.PacienteID="& veseha("PacienteID") &" and e.ProfissionalID="& veseha("ProfissionalID") &" and isnull(e.Fim)")
                        if not esp.eof then
                            %>
                            <tr class="warning">
                                <th>Procedimento solicitado</th>
                                <th>Observações</th>
                                <th>Agendamento</th>
                            </tr>
                            <%
                        end if
                        while not esp.eof
                        %>
                        <tr>
                            <td><%= esp("NomeProcedimento") %></td>
                            <td><%= esp("Obs") %></td>
                            <td width="200">
                                <%
                                set vcaag = db.execute("select a.id, a.Data, a.Hora, a.StaID, p.NomeProfissional from agendamentos a left join profissionais p on p.id=a.ProfissionalID where a.Data>=curdate() and a.PacienteID="& veseha("PacienteID") &" and a.TipoCompromissoID="& esp("ProcedimentoID") &" order by data, hora limit 1")
                                classeBtnEsp = ""
                                if vcaag.eof then
                                    %>
                                    <a class="btn btn-xs btn-block btn-<%= classeBtnEsp %>" href="./?P=AgendaMultipla&Pers=1&ProcedimentoID=<%= esp("ProcedimentoID") %>&PacienteID=<%= veseha("PacienteID") %>"><i class="fa fa-calendar"></i> Não agendado</a>
                                    <%
                                else
                                    if vcaag("StaID")=3 then
                                        classeBtnEsp = "success"
                                    end if
                                    %>
                                    <a href="./?P=Agenda-1&Pers=1&AgendamentoID=<%= vcaag("id") %>" class="btn btn-block btn-<%= classeBtnEsp %> btn-xs">
                                        <img src="./assets/img/<%= vcaag("StaID") %>.png" /> <%= vcaag("Data") &" - "& ft(vcaag("Hora")) &" - "& vcaag("NomeProfissional") %>
                                    </a>
                                    <%
                                end if
                                %>
                            </td>
                        </tr>
                        <%
                        esp.movenext
                        wend
                        esp.close
                        set esp = nothing
                    %>
                </table>
                </td>
            </tr>
	        <%
        end if
	end if
    veseha.movenext
    wend
    veseha.close
    set veseha=nothing%>
</table>
</div>
<script >
    var $waitingTime = $(".waiting-time");

    function dateFix(datetime) {
        datetime = datetime.replace(new RegExp("'", 'g'), "");

        if(datetime.indexOf("T") > 0){
            datetime = datetime.split("T");
        }

        var date = datetime[0];
        var dateSplit = date.split("-");

        if (dateSplit[1].length === 1){
            dateSplit[1] = "0"+dateSplit[1];
        }
        if (dateSplit[2].length === 1){
            dateSplit[2] = "0"+dateSplit[2];
        }

        return dateSplit[0]+"-"+dateSplit[1]+"-"+dateSplit[2]+"T"+datetime[1];
    }

    function dateFixDmy(date){
        var datetime = date.split(" ");
        var dateSplt = datetime[0].split("/");

        return dateSplt[2]+"-"+dateSplt[1]+"-"+dateSplt[0]+"T"+datetime[1];
    }

    $.each($waitingTime,function() {
        var arrival = dateFix($(this).data("arrival"));
        var now = dateFixDmy("<%=now()%>");

        var timeDiff = Math.abs(new Date(now) - new Date(arrival));
        <%if HorarioVerao<>"" then%>
            timeDiff = Math.floor((timeDiff/1000)/60);
        <%else%>
            timeDiff = Math.floor(((timeDiff/1000)/60)-60);
        <%end if%>

        var diffText = "há "+timeDiff+" minuto"+(timeDiff>1 ? "s" : "");

        $(this).html(diffText);
    });
    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>
<%end if%>
<!--#include file = "disconnect.asp"-->