<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
TelemedicinaAtiva = recursoAdicional(32) = 4

IF ref("Rechamar") = "1" THEN
    db.execute("UPDATE agendamentos SET Falado = NULL WHERE id = "&ref("id"))
    response.write("true")
END IF

configExibirNaSalaDeEspera = getConfig("ExibirEquipamentoNaSalaDeEspera")
OrdensNome="Hor&aacute;rio Agendado, Hor&aacute;rio de Chegada, Idade do Paciente"
Ordens="HoraSta, Hora, pac.Nascimento ASC"
splOrdensNome=split(OrdensNome, ", ")
unidadesBloqueioAtendimento = getConfig("BloquearAtendimentoMediantePagamento")
OmitirEncaixeGrade = getConfig("OmitirEncaixeGrade")

Ordem="Hora"
StatusExibir=req("StatusExibir")
ExibirChamar = getConfig("ExibirChamar")

if StatusExibir="" then
    StatusExibir="4"
end if


dataHoraCliente = getClientDataHora(session("UnidadeID"))

if req("ProfissionalID")<>"" and req("ProfissionalID")<>"ALL"  then
    ProfissionalID = req("ProfissionalID")
    sqlProfissional = " AND a.ProfissionalID="&ProfissionalID
else
    ProfissionalID=session("idInTable")
end if

if req("EspecialidadeID")<>"" and req("EspecialidadeID")<>"0"  then
    EspecialidadeID = req("EspecialidadeID")
    sqlEspecialidade = " AND a.EspecialidadeID="&EspecialidadeID
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

if req("Chamar")<>"" and intval(req("Chamar"))&"" <> "0" then

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
	set dadosAgendamento = db.execute("select PacienteID, ProfissionalID from agendamentos where id = '"&req("Chamar")&"'")
	if not dadosAgendamento.eof then
		call gravaChamada(dadosAgendamento("ProfissionalID"), dadosAgendamento("PacienteID"), session("UnidadeID"))
	end if
	call logAgendamento(req("Chamar") , "Chamando paciente pela sala de espera", "R")

    set age = db.execute("select ProfissionalID from agendamentos where id="&req("Chamar"))
    if not age.eof then
        getEspera(age("ProfissionalID")) 
    end if
end if

'da redirect ao atender
if req("Atender")<>"" and intval(req("Atender"))&"" <> "0" then
    AgendamentoIDAtender = req("Atender")
	'db_execute("update agendamentos set StaID='3' where StaID = '2' and ProfissionalID = '"&ProfissionalID&"'") -  não muda mais automaticamente para atendido, apenas quando encerra o contador
	db_execute("update agendamentos set StaID='2', ProfissionalID="&ProfissionalID&" where id = '"&AgendamentoIDAtender&"' AND ProfissionalID = 0")
    getEspera(ProfissionalID)

    if req("isTelemedicina")="true" then
        db.execute("INSERT INTO atendimentoonline (AgendamentoID, PacienteID, hashpaciente, MedicoID, hashmedico) (SELECT age.id, age.PacienteID,'', age.ProfissionalID,'' FROM agendamentos age LEFT JOIN atendimentoonline ao ON ao.AgendamentoID=age.ID WHERE ao.id is NULL AND age.id='"&AgendamentoIDAtender&"')")
        session("AtendimentoTelemedicina")=AgendamentoIDAtender
    end if

	response.Redirect("?P=Pacientes&Pers=1&I="&req("PacienteID")&"&Atender="&req("Atender")&"&Acao=Iniciar")
end if

if lcase(session("Table"))<>"profissionais" or req("ProfissionalID")<>"" then
	sql = "select a.*,TIME_TO_SEC(TIME_FORMAT(TIMEDIFF(time("&mytime(dataHoraCliente)&"), a.HoraSta),'%H:%i'))/60 AS tempoEspera, conv.NomeConvenio, st.StaConsulta, proc.NomeProcedimento, pac.NomePaciente, pac.NomeSocial, pac.Nascimento,p.NomeProfissional,p.EspecialidadeID, l.UnidadeID, tp.NomeTabela, ac.NomeCanal, a.ValorPlano, proc.ProcedimentoTelemedicina "&_
    ", ( "&_
    " SELECT count(ap.id) "&_
    " FROM agendamentosprocedimentos ap "&_
    " WHERE ap.agendamentoid = a.id) qtdProcedimentosExtras "&_
    "from agendamentos a "&_
    "INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID "&_
    "LEFT JOIN agendamentocanais ac ON ac.id=a.CanalID "&_
    "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID "&_
    "left join profissionais p on p.id=a.ProfissionalID "&_
    "inner join pacientes pac ON pac.id=a.PacienteID "&_
    "left join locais l on l.id=a.LocalID "&_
    " LEFT JOIN convenios conv ON conv.id=a.ValorPlano AND a.rdValorPlano='P' "&_
    " LEFT JOIN staconsulta st ON st.id=a.StaID "&_
    "where Data = '"&mydate(DataHoje)&"' and StaID in(2, 5, "&StatusExibir&", 33, 102,105,106, 101, 5) and (l.UnidadeID="&treatvalzero(session("UnidadeID"))&" or isnull(l.UnidadeID)) "&sqlProfissional&sqlEspecialidade&" and a.sysActive = 1 "&_
    "order by "&Ordem

    sqlTotal = "select count(*) total, l.UnidadeID from agendamentos a INNER JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID left join locais l on l.id=a.LocalID                                                                                         where a.Data = '"&mydate(DataHoje)&"' and a.StaID in(2, 5, 33, "&StatusExibir&") and (l.UnidadeID <> "&session("UnidadeID")&" and not isnull(l.UnidadeID)) "&sqlProfissional&"  group by(l.UnidadeID) and a.sysActive = 1 order by total desc limit 1 "
else
    'triagem
    sqlSalaDeEspera = ""
    if configExibirNaSalaDeEspera = 0 then
        sqlSalaDeEspera  = " a.ProfissionalID !=0 and "
    end if

	'sql = "select * from Consultas where Data = "&DataHoje&" and DrId = '"&session("DoutorID")&"' and not StaID = '3' and not StaID = '1' and not StaID = '6' and not StaID = '7' order by "&Ordem
    sqlTotal = "select count(*) total, l.UnidadeID from agendamentos a INNER JOIN pacientes pac ON pac.id=a.PacienteID LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID left join locais l on l.id=a.LocalID  where a.Data = '"&mydate(DataHoje)&"' and a.ProfissionalID in("&ProfissionalID&", 0) and a.StaID in(2, 5, 33, "&StatusExibir&") and (l.UnidadeID <> "&session("UnidadeID")&" and not isnull(l.UnidadeID))  group by(l.UnidadeID) and a.sysActive = 1 order by total desc limit 1 "
	sql = "select a.*,TIME_TO_SEC(TIME_FORMAT(TIMEDIFF(time("&mytime(dataHoraCliente)&"), a.HoraSta),'%H:%i'))/60 AS tempoEspera, conv.NomeConvenio, st.StaConsulta, proc.NomeProcedimento, pac.NomePaciente, pac.NomeSocial, pac.Nascimento, tp.NomeTabela, ac.NomeCanal,  a.ValorPlano, proc.ProcedimentoTelemedicina "&_
    ", ( "&_
    " SELECT count(ap.id) "&_
    " FROM agendamentosprocedimentos ap "&_
    " WHERE ap.agendamentoid = a.id) qtdProcedimentosExtras "&_
    "from agendamentos a "&_
    "INNER JOIN procedimentos proc ON proc.id=a.TipoCompromissoID "&_
    "LEFT JOIN agendamentocanais ac ON ac.id=a.CanalID "&_
    "INNER JOIN pacientes pac ON pac.id=a.PacienteID "&_
    "LEFT JOIN tabelaparticular tp on tp.id=a.TabelaParticularID "&_
    "left join locais l on l.id=a.LocalID  "&_
    " LEFT JOIN convenios conv ON conv.id=a.ValorPlano AND a.rdValorPlano='P' "&_
    " LEFT JOIN staconsulta st ON st.id=a.StaID "&_
    "where "&sqlSalaDeEspera&" a.Data = '"&mydate(DataHoje)&"' and a.ProfissionalID in("&ProfissionalID&", 0) and a.StaID in(2, 5, 33, "&StatusExibir&") and (l.UnidadeID="&treatvalzero(session("UnidadeID"))&" or isnull(l.UnidadeID)) and a.sysActive = 1 "&_
    "order by "&Ordem

end if

if lcase(session("table"))="profissionais" then
    if not ConfigGeraisSQL.eof then
        if ConfigGeraisSQL("Triagem")="S" then
            Triagem = "S"
            TriagemProcedimentos = ConfigGeraisSQL("TriagemProcedimentos")
            ProfissionalTriagem="N"

            sqlTriagem = "SELECT IF(conf.TriagemEspecialidades LIKE CONCAT('%|',prof.EspecialidadeID,'|%'),1,0)EspecialidadeTriagem FROM profissionais prof "&_
                                                                             "INNER JOIN sys_config conf  "&_
                                                                             "WHERE prof.id = "&ProfissionalID
'enfermeira ou tec enfermagem
            set ProfissionalTriagemSQL = db.execute(sqlTriagem)
            if not ProfissionalTriagemSQL.eof then
                if ProfissionalTriagemSQL("EspecialidadeTriagem")="1" then
                    ProfissionalTriagem="S"
                    sql = "select age.*, TIME_TO_SEC(TIME_FORMAT(TIMEDIFF(time("&mytime(dataHoraCliente)&"),age.HoraSta),'%H:%i'))/60 AS tempoEspera , conv.NomeConvenio, st.StaConsulta, proc.NomeProcedimento, pac.NomePaciente, pac.NomeSocial, pac.Nascimento, profage.NomeProfissional, tp.NomeTabela, ac.NomeCanal, proc.ProcedimentoTelemedicina "&_
                    ", ( "&_
                    " SELECT count(ap.id) "&_
                    " FROM agendamentosprocedimentos ap "&_
                    " WHERE ap.agendamentoid = age.id) qtdProcedimentosExtras "&_
                    "from agendamentos age "&_
                    "INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID "&_
                    "LEFT JOIN tabelaparticular tp on tp.id=age.TabelaParticularID "&_
                    "LEFT JOIN profissionais profage ON profage.id=age.ProfissionalID "&_
                    "LEFT JOIN agendamentocanais ac ON ac.id=age.CanalID "&_
                    "INNER JOIN pacientes pac ON pac.id=age.PacienteID "&_
                    "LEFT JOIN locais l ON l.id=age.LocalID "&_
                    " LEFT JOIN convenios conv ON conv.id=age.ValorPlano AND age.rdValorPlano='P' "&_
                    " LEFT JOIN staconsulta st ON st.id=age.StaID "&_
                    "where age.Data = '"&mydate(DataHoje)&"' and age.StaID in(2,"&StatusExibir&", 5, 33, 102,105,106) AND '"&TriagemProcedimentos&"' LIKE CONCAT('%|',age.TipoCompromissoID,'|%') AND (l.UnidadeID IS NULL or l.UnidadeID='"&session("UnidadeID")&"') or '"&session("UnidadeID")&"'='' and age.sysActive = 1 "&_
                    "order by "&Ordem
                end if
            end if
        end if
    end if
end if

if req("debug")="1" then
    response.write("<pre>"&sql&"</pre>")
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

ExibirCanal = getConfig("ExibirCanalSalaDeEspera")

if veseha.eof then
	%>
	<div class="p15">
	    Nenhum paciente aguardando para ser atendido.
    </div>
    <script >
        $("#total-pacientes").html("")
    </script>
	<%
else
%>
<script>
    var AtendimentoSimultaneoValidado = true;
    <% IF getConfig("PermitirAtendimentoSimultaneo") <> 1 AND session("Atendimentos")<>"" THEN %>
        AtendimentoSimultaneoValidado = false;
    <% END IF %>


    <% IF getConfig("ValidarCertificadoUsuario") = 1 THEN
        sql = "SELECT count(*) > 0 as qtd FROM cliniccentral.digitalcertificates WHERE LicencaID = "&replace(session("Banco"), "clinic", "")&" AND sysActive = 1 AND UsuarioID = "& session("User")
        set hasCertificadoDigital = db.execute(sql)
        IF hasCertificadoDigital.EOF THEN %>
            var certificadoValido = true;
        <% ELSE %>
            <%IF hasCertificadoDigital("qtd") = "1" THEN%>
                var certificadoValido = true;
            <%ELSE %>
                var certificadoValido = false;
            <%END IF %>
        <% END IF%>
    <% ELSE  %>
        var certificadoValido = true;
    <% END IF %>
</script>


  <table style="width: 100%" id="listaespera" class="table tc-checkbox-1 admin-form theme-warning br-t">
  <thead>
	<tr class="info">
    	<th>HORA</th>
    	<th>CHEGADA</th>
        <th>PACIENTE</th>
        <th>IDADE</th>
        <% If session("Table")<>"profissionais" or req("ProfissionalID")="ALL" Then %><th>PROFISSIONAL</th><% End If %>
        <% If ExibirCanal=1 Then %><th>CANAL</th><% End If %>
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
    TotalPacientes = 0
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
        Nome=veseha("NomePaciente")
        NomeSocial = veseha("NomeSocial")&""
        if NomeSocial<>"" then
            Nome = Nome &"<br><code>Nome social: "& NomeSocial &"</code>"
        end if
        DataNascimento=veseha("Nascimento")
        TipoCompromisso=ucase(veseha("NomeProcedimento"))
        OutrosProcedimentosStr=""
        StaConsulta=veseha("StaConsulta")
        NomeConvenio = veseha("NomeConvenio")&""
        if NomeConvenio<>"" then
            Valor="<center>"&NomeConvenio&"</center>"
        end if

        if not veseha.EOF then
            PacId=veseha("PacienteID")

            if veseha("rdValorPlano")="V" then
				if aut("areceberpacienteV")=1 then
	                Valor = veseha("ValorPlano")
				else
					Valor = ""
				end if
            end if
            
            if session("Banco")="clinic100000" or session("Banco")="clinic2263" or session("Banco")="clinic5856" then
                Valor = veseha("NomeTabela")
            end if
            if veseha("qtdProcedimentosExtras")&""<>"0" then
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

    isTelemedicina = veseha("ProcedimentoTelemedicina")&""="S"

    if not ConfigGeraisSQL.eof then
        UnidadeBloqueiaPagamento = False

        if unidadesBloqueioAtendimento&""<>"" and unidadesBloqueioAtendimento<>"0" then
            UnidadeBloqueiaPagamento = (inStr(unidadesBloqueioAtendimento, "|"&session("UnidadeID")&"|")<>"0" or unidadesBloqueioAtendimento&""="")
        end if

        if ChamarAposPagamento="S" or UnidadeBloqueiaPagamento then
            'verifica se procedimento ja foi pago preveamente
            sqlQuitado =    "SELECT ii.id"&_
                            " FROM itensinvoice ii"&_
                            " LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID"&_
                            " WHERE i.AccountID="&veseha("PacienteID")&" "&_
                            " AND AssociationAccountID=3 "&_
                            " AND ii.Tipo='S' "&_
                            " AND ii.ItemID="&veseha("TipoCompromissoID")&" "&_
                            " AND FLOOR((ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto)))>= FLOOR("&treatvalzero(veseha("ValorPlano"))&") "&_
                            " AND FLOOR(IFNULL(("&_
                            " 				SELECT SUM(Valor)"&_
                            " 				FROM itensdescontados"&_
                            " 				WHERE ItemID=ii.id), 0))>= FLOOR("&treatvalzero(veseha("ValorPlano"))&") "&_
                            " AND (ISNULL(DataExecucao) OR DataExecucao= '"&mydate(veseha("Data"))&"' OR Executado='') "&_
                            " AND (ii.ProfissionalID="&veseha("ProfissionalID")&" or ii.ProfissionalID=0) "&_
                            " AND ii.Executado!='C' "

            'response.write sqlQuitado

            set procPrePago = db.execute(sqlQuitado)

            formaPagamento = veseha("FormaPagto")
            if not procPrePago.eof then
                formaPagamento = 1
            end if

            if formaPagamento < 0 and veseha("ValorPlano")>0 then
                if Triagem="S" and ProfissionalTriagem="N" and labelDisabled = "Pendente de Triagem" then
                    'exibeLinha = "N"
                end if
                ' COMENTADA AS LINHAS ABAIXO POR QUE ESTÁ BLOQUEANDO PAGAMENTOS COM DESCONTOS
                disabPagto = "disabled"
                labelDisabled = "Pendente de pgto."
                tagPaciente = "div"

                
            end if
            
        end if
    end if

    'DESATIVA BOTÕES DE CHAMAR / ATENDE::: PERMISSAO > OUTRAS CONFIGS > CAT(ATENDIMENTO) :: RAFAEL MAIA ::
    if instr(unidadesBloqueioAtendimento,"|"&session("unidadeID")&"|") > 1 then
        if accountBalance("3_"&veseha("PacienteID"), 0) < 0 then
            btnAtenderDisabled  = 1
            btnChamarDisabled   = 1
            
            disabPagto = "disabled"
            labelDisabled = "Pendente de pgto."
            tagPaciente = "div"
        end if
    else
        btnAtenderDisabled  = 0
        btnChamarDisabled   = 0
    end if
    '</DESATIVA BOTÕES DE CHAMAR>
    if exibeLinha="S" then
        if Sta=33 then
            fLinha = " class='warning' "
            rowspan = " rowspan=2 "
        else
            fLinha = ""
            rowspan = ""
        end if

        statusIcon = imoon(Sta)
        %>
    <tr <%= fLinha %>>
    <td nowrap <%= rowspan %> ><%=statusIcon%> <%=Hora%></td>
    <td <%= rowspan %> ><%= HoraSta %></td>
    <%

    %>
    <td <%if not isnull(Imagem) and not Imagem="" then%>class="hotspot" onMouseOver1="tooltip.show('<img src=<%=EnderecoImagens%>/<%=Imagem%> width=100>');"<%end if%>>
    	<%
        'set veSePre=db.execute("select * from PacienteAnamneses where preAtendimento like 'S' and Data like '"&DataHoje&"' and PacienteID = '"&PacId&"'")
        'if not veSePre.EOF then
			'<img src="checked.jpg" />
		'end if%>
		<%if veseha("Encaixe")=1 and OmitirEncaixeGrade=0 then%><span class="label label-alert ml5">Encaixe </span><%end if%>
		<%if veseha("Primeira")=1 then%><span class="label label-info ml5">Primeira vez</span><%end if%>
		<<%=tagPaciente%> href="./?P=Pacientes&Pers=1&I=<%=veseha("PacienteID")%>" <%=cssAdicionl%>><%=Nome%></<%=tagPaciente%>><br />
		<small><%=Notas%></small></td>
        <td><%=IdadeAbreviada(DataNascimento)%></td>
    <% If session("Table")<>"profissionais" or req("ProfissionalID")="ALL" Then %><td><%=veseha("NomeProfissional")%></td><% End If %>
    <% If ExibirCanal=1 Then %><td><%=veseha("NomeCanal")%></td><% End If %>
    <td ><%=TipoCompromisso%><%=compromisso%><%=OutrosProcedimentosStr%><%
    if SubtipoAgendamento<>"" then
		response.Write(" &raquo; <small>"&SubtipoAgendamento&"</small>")
	end if
    if veseha("Retorno")=1 then%><span class="label label-warning ml5"><i class="far fa-undo"></i> Retorno </span><%end if
    %></td>
    <td nowrap="nowrap">
    <%=StaConsulta%>&nbsp;
    <%
    Plurais=""
    if veseha("StaID")=4 or veseha("StaID")=8 then
		if veseha("Data")=DataHoje then
        totalMinutosEspera = veseha("tempoEspera")
            if totalMinutosEspera <> "1" then
            Plurais="s"
            end if
	%>
        há <%=totalMinutosEspera%> minuto<%=Plurais%>
        <%
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
        <% if session("Banco")<>"clinic5760" then
            Rechamar = false
         %>
            <button class="btn btn-xs btn-warning" type="button" <%=disabPagto%> <%

            if isTelemedicina then
            %>disabled <%
            end if

            if veseha("StaID")<>4 and veseha("StaID")<>101 and veseha("StaID")<>102 and veseha("StaID")<>33 then

                Rechamar = getConfig("ReChamarAtendimento")
                IF Rechamar THEN
                    %> onClick="rechamar(<%=veseha("id")%>)"<%
                ELSE
                    response.write("disabled")
                END IF
            else
                %> onClick="window.location='?P=ListaEspera&Pers=1&Chamar=<%=veseha("id")%>';"<%
            end if
            %>><i class="far fa-bell"></i>
             <% IF Rechamar THEN %>
                RECHAMAR
             <% ELSE %>
                CHAMAR
             <% END IF %>

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
        
        if (veseha("StaID")<>4 and veseha("StaID")<>5 and veseha("StaID")<>33) OR (disabPagto<>"") then
            %> disabled<%
        else
            %> onClick="isValido(certificadoValido,() => window.location='?P=ListaEspera&Pers=1&Atender=<%=veseha("id")%>&PacienteID=<%=veseha("PacienteID")%>&isTelemedicina=<% if isTelemedicina then %>true<%end if%>')"<%
        end if
        %><%
        if isTelemedicina and TelemedicinaAtiva then
        %>
    	 class="btn btn-xs btn-alert" type="button" <%=disabPagto%> >
    	 <i class="far fa-video-camera"></i> ATENDER ONLINE
    	 <%
    	 else
    	 %>
         class="btn btn-xs btn-success btn-block" type="button" <%=disabPagto%> >
         <i class="far fa-play"></i> ATENDER
         <%
         end if
    	 %>
    	 </button>
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
                <td colspan="8">
                <table class="table table-condensed table-bordered">
                    <%
                    set esp = db.execute("select e.*, ep.ProcedimentoID, ep.Obs, proc.NomeProcedimento from espera e LEFT JOIN esperaprocedimentos ep ON ep.EsperaID=e.id LEFT JOIN procedimentos proc ON proc.id=ep.ProcedimentoID where e.PacienteID="& veseha("PacienteID") &" and e.ProfissionalID="& veseha("ProfissionalID") &" and isnull(e.Fim)")
                        if not esp.eof then
                            %>
                            <tr class="dark">
                                <th>Procedimento solicitado</th>
                                <th>Observações</th>
                                <th>Agendamento</th>
                            </tr>
                            <%
                        end if

                        idsExibidos = "0"
                        while not esp.eof
                        %>
                        <tr>
                            <td><%= esp("NomeProcedimento") %></td>
                            <td><%= esp("Obs") %></td>
                            <td width="200">
                                <%
                                set vcaag = db.execute("select a.id, a.Data, a.Hora, a.StaID, p.NomeProfissional, sta.StaConsulta from agendamentos a inner join staconsulta sta ON sta.id=a.StaID left join profissionais p on p.id=a.ProfissionalID where a.Data>=curdate() and a.PacienteID="& veseha("PacienteID") &" and a.TipoCompromissoID="& treatvalzero(esp("ProcedimentoID")) &" and a.id not in ("&idsExibidos&") order by data, hora limit 1")
                                classeBtnEsp = ""
                                if vcaag.eof then
                                    %>
                                    <a data-toggle="tooltip" title="Não agendado" class="btn btn-xs btn-block btn-<%= classeBtnEsp %>" href="./?P=AgendaMultipla&Pers=1&ProcedimentoID=<%= esp("ProcedimentoID") %>&PacienteID=<%= veseha("PacienteID") %>&SolicitanteID=5_<%= veseha("ProfissionalID") %>">
                                        <i class="far fa-calendar"></i> Não agendado
                                    </a>
                                    <%
                                else
                                    if vcaag("StaID")=3 then
                                        classeBtnEsp = "success"
                                    end if

                                    idsExibidos = idsExibidos&","&vcaag("id")


                                    statusIcon = vcaag("StaID")
                                    %>
                                    <a data-toggle="tooltip" title="<%=vcaag("StaConsulta")%>" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%= vcaag("id") %>" class="btn btn-block btn-<%= classeBtnEsp %> btn-xs">
                                        <%=statusIcon%> <%= vcaag("Data") &" - "& ft(vcaag("Hora")) &" - "& vcaag("NomeProfissional") %>
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
        TotalPacientes = TotalPacientes + 1
        OutrosProcedimentosStr = ""
	end if
    veseha.movenext
    wend
    veseha.close
    set veseha=nothing%>
<script >
    $("#total-pacientes").html("<strong><%=TotalPacientes%></strong> paciente(s) aguardando");
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
        /*var now = dateFixDmy("<%=now()%>");
        
        var timeDiff = Math.abs(new Date(now) - new Date(arrival));
        timeDiff = Math.floor((timeDiff/1000)/60);
        var diffText = "há "+timeDiff+" minuto"+(timeDiff>1 ? "s" : "");
        
        $(this).html(diffText);*/
        $(this).html(diferencaEmMinutos(arrival));
    });
    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });

    function diferencaEmMinutos(data1){
        const now = new Date(); 
        const past = new Date(data1); 
        const diff = Math.abs(now.getTime() - past.getTime()); 
        const min = Math.floor(diff / (1000 * 60 )); 

        return "há "+min+" minuto"+(min>1 ? "s" : "")
    }

    function rechamar(arg){

        $.post("ListaEsperaCont.asp", {Rechamar:"1",id: arg}, function(data){
            showMessageDialog("Chamando paciente.", "success");
            window.location='?P=ListaEspera&Pers=1&Chamar='+arg;
         });


    }

    function isValido(arg1,arg2){

         if(!AtendimentoSimultaneoValidado){
            new PNotify({
                title: '<i class="far fa-warning"></i> Finalize o atendimento',
                text: 'Finalize o atendimento atual para iniciar outro.',
                type: 'danger'
            });
        }

        if(!(arg1 === true)){
            new PNotify({
                    title: '<i class="far fa-warning"></i> Certificado Digital',
                    text: 'Para iniciar o atendimento, o usuário deverá configurar o certificado digital.',
                    type: 'danger'
            });
        }

        if(arg1 === true && AtendimentoSimultaneoValidado){
             gtag('event', 'iniciar', {
                'event_category': 'atendimento',
                'event_label': "Sala de espera > Iniciar",
            });
            arg2();
        }
    }
</script>
    </tbody>
  </table>
<%end if%>
<% if req("Chamar")<>"" and intval(req("Chamar"))&"" <> "0" then %>
<script>
fetch('<%=getEnv("APP_SOCKET", "")%>/send',{
         method:"POST",
         headers: {
                "Authorization":localStorage.getItem("tk"),
                'Accept': 'application/json',
                'Content-Type': 'application/json'
         },
         body:JSON.stringify({
                                 "service":"panel",
                                 "data": {"call": "next"}
                             })
      })
</script>
<% end if %>
<!--#include file = "disconnect.asp"-->