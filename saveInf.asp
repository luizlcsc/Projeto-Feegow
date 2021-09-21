<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
CalculosTabela = getConfig("calculostabelas")
AtendimentoID = req("AtendimentoID")

if AtendimentoID="" then
    AtendimentoID = replace(req("Atendimentos"), "|", "")
end if

set AtendimentoSQL = db.execute("SELECT PacienteID FROM atendimentos WHERE id="&AtendimentoID)

set ConfigSQL = db.execute("SELECT RecursosAdicionais, ObrigarPreenchimentoDeFormulario FROM sys_config WHERE id=1")

if ConfigSQL("ObrigarPreenchimentoDeFormulario")="S" then

    set FormPreenchidoSQL = db.execute("SELECT count(id)n FROM buiformspreenchidos WHERE PacienteID="&AtendimentoSQL("PacienteID")&" AND sysUser="&session("User")&" AND sysActive=1 AND date(DataHora)="&mydatenull(date()))

    if not FormPreenchidoSQL.eof then
        PodeContinuar=True

        if isnull(FormPreenchidoSQL("n")) then
            PodeContinuar=False
        else
            if FormPreenchidoSQL("n")="0" then
                PodeContinuar=False
            end if

        end if

        if PodeContinuar=False then
            %>
            showMessageDialog("Você precisa fazer algum lançamento em Anamnese/Evolução.");
            $("#modal-table").modal("hide");
            $("#abaForms").click();
            <%
            Response.End
        end if
    end if
end if

splLinhas = split(ref("Linhas"), ", ")
for i=0 to ubound(splLinhas)
	LinhaID = splLinhas(i)
	ProcedimentoID = ref("ProcedimentoID"&LinhaID)
	if ProcedimentoID<>"" then
		LinhaID = ccur(LinhaID)
		ConvenioID = ref("ConvenioID"&LinhaID)
		Fator = ref("Fator"&LinhaID)
		Obs = ref("Obs"&LinhaID)
		ValorFinal = ref("ValorFinal"&LinhaID)
		if ConvenioID="0" then
			rdValorPlano = "V"
			ValorPlano = ValorFinal
		else
			rdValorPlano = "P"
			ValorPlano = ConvenioID
		end if
'		response.Write("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, QuantidadeSolicitada, QuantidadeAutorizada, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal, PlanoTabela, Ordem) values ("&AtendimentoID&", "&ProcedimentoID&", 1, 1, 1, '"&Obs&"', "&treatvalzero(ValorPlano)&", '"&rdValorPlano&"', "&treatvalzero(Fator)&", "&treatvalzero(ValorFinal)&", 0, 0)")
		if LinhaID<0 then
			db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, QuantidadeSolicitada, QuantidadeAutorizada, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal, PlanoTabela, Ordem) values ("&AtendimentoID&", "&ProcedimentoID&", 1, 1, 1, '"&Obs&"', "&treatvalzero(ValorPlano)&", '"&rdValorPlano&"', "&treatvalzero(Fator)&", "&treatvalzero(ValorFinal)&", 0, 0)")
		else
			db_execute("update atendimentosprocedimentos set ProcedimentoID="&ProcedimentoID&", Quantidade=1, QuantidadeSolicitada=1, QuantidadeAutorizada=1, Obs='"&Obs&"', ValorPlano="&treatvalzero(ValorPlano)&", rdValorPlano='"&rdValorPlano&"', Fator="&treatvalzero(Fator)&", ValorFinal="&treatvalzero(ValorFinal)&", PlanoTabela=0, Ordem=0 WHERE id="&LinhaID)
		end if
	end if
next

'aqui coloca na chamada de pos atendimento caso tenha + de um item
if ubound(splLinhas) > 1 then

    if not ConfigSQL.eof then
        if ConfigSQL("ObrigarPreenchimentoDeFormulario")="S" then

        end if

        Adicionais = ConfigSQL("RecursosAdicionais")
        if instr(Adicionais, "|PosAtendimento|") then
            set GuicheSQL = db.execute("SELECT g.Senha FROM guiche g WHERE PacienteID="&AtendimentoSQL("PacienteID")&" AND date(g.DataHoraChegada) = CURDATE() AND Sta='Atendido'")

            Senha=0
            if not GuicheSQL.eof then
                Senha=GuicheSQL("Senha")
            end if

            db_execute("insert INTO guiche (Senha,Sta,sysUser,DataHoraChegada,PacienteID,UnidadeID) VALUES ("&Senha&",'Espera pós',"&session("User")&","&mydatetime(now)&","&AtendimentoSQL("PacienteID")&","&treatvalzero(session("UnidadeID"))&")")
        end if
    end if
end if

if ref("Excluir")<>"" then
	db_execute("delete from atendimentosprocedimentos where id in("&req("Excluir")&")")
end if

%>
var callbackFinaliza = function(){		
	location.href='./?P=ListaEspera&Pers=1';
}

 var envioSmsEmail = 0;  <%
set at = db.execute("select * from atendimentos where id="&AtendimentoID)
if not at.eof then
	%> envioSmsEmail = 1;  <%
	sysUser = at("sysUser")
	AgendamentoID = at("AgendamentoID")
	if sysUser<0 then
		sysUser = sysUser*(-1)
	end if
    if not isnull(at("Data")) then
        DataAnterior = at("Data")
    end if
	'response.Write("update atendimentos set ProfissionalID="&ref("inf-ProfissionalID")&", sysUser="&sysUser&", HoraInicio="&mytime(ref("inf-HoraInicio"))&", HoraFim="&mytime(ref("inf-HoraFim"))&", Data="&mydatenull(ref("inf-Data"))&", Obs='"&ref("Obs")&"', UnidadeID="&ref("UnidadeID")&" where id="&AtendimentoID)
	%>
	
    <%
	db_execute("update atendimentos set ProfissionalID="&ref("inf-ProfissionalID")&", sysUser="&sysUser&", HoraInicio=IFNULL(HoraInicio,"&mytime(ref("inf-HoraInicio"))&"), HoraFim=IFNULL(HoraFim,IFNULL("&mytime(ref("inf-HoraFim"))&",NOW())), Data=IFNULL(Data, "&mydatenull(ref("inf-Data"))&"), Obs='"&ref("Obs")&"', UnidadeID="&ref("UnidadeID")&" where id="&AtendimentoID)
	PacienteID = at("PacienteID")
end if

if req("Origem")="Atendimento" then
	db_execute("update sys_users set notiflanctos='' where LENGTH(notiflanctos)>50")
	str = "select * from atendimentos where id="& AtendimentoID
	'response.Write(str)
	set buscaAtendimento = db.execute(str)
	if not buscaAtendimento.eof then
		if req("Solicitacao")<>"S" then
			'db_execute("update atendimentos set HoraFim='"&time()&"' where id="&buscaAtendimento("id"))
			'fecha possível lista de espera com este paciente

			AgendamentoID=req("AgendamentoID")

			if AgendamentoID="0" then
			    AgendamentoID=buscaAtendimento("AgendamentoID")
			end if

			set lista = db.execute("select * from agendamentos where id = "&treatvalzero(AgendamentoID)&" order by Hora")

			if lista.eof then
			    set lista = db.execute("select * from agendamentos where PacienteID="&PacienteID&" and Data='"&mydate(date())&"' and StaID<>3 and (ProfissionalID="&session("idInTable")&" OR id = "&AgendamentoID&") order by Hora")
            end if

			if not lista.EOF then
			    'triagem
			    StaID = 3
			    EhTriagem="N"
                set ConfigSQL = db.execute("SELECT Triagem, TriagemProcedimentos, TriagemEspecialidades, PosConsulta FROM sys_config WHERE id=1")

                if not ConfigSQL.eof then
                    if ConfigSQL("Triagem")="S" then

                        if instr(ConfigSQL("TriagemProcedimentos"), "|"&lista("TipoCompromissoID")&"|") then
                            set Especialidade = db.execute("SELECT EspecialidadeID FROM profissionais WHERE id = "&session("idInTable"))
                            EspecialidadeID = Especialidade("EspecialidadeID")

                             'enfermeira
                            if instr(ConfigSQL("TriagemEspecialidades"), "|"&EspecialidadeID&"|") then
                                db_execute("DELETE FROM atendimentosprocedimentos WHERE AtendimentoID="&AtendimentoID)

                                StaID = 4
                                EhTriagem="S"

                                if ConfigSQL("PosConsulta")="S" then
                                    set AtendimentoSQL = db.execute("select id FROM atendimentos WHERE AgendamentoID="&lista("id")&" AND ProfissionalID="&lista("ProfissionalID"))
                                    if not AtendimentoSQL.eof then
                                        StaID=3
                                    end if
                                end if
                            else
                                if ConfigSQL("PosConsulta")="S" then
                                    StaID=4
                                end if
                            end if
                        end if
                    end if
			    end if

				if StaID = 11 or StaID = 22 then ' desmarcado e cancelado
					call agendaUnificada("delete", lista("id"), lista("ProfissionalID"))
				else
					call agendaUnificada("update", lista("id"), lista("ProfissionalID"))
				end if

				db_execute("update agendamentos set StaID="&StaID&" where id="&lista("id"))
				call logAgendamento(lista("id"), "Atendimento finalizado", "R")
			end if
			session("Atendimentos") = replace(session("Atendimentos"), "|"&buscaAtendimento("id")&"|", "")
			session("AtendimentoTelemedicina")=""
		end if

		'pos consulta na recepcao
        if session("Banco")="clinic100000" or session("Banco")="clinic5445" then
            set FilaPosSQL = db.execute("SELECT id, StartNumero FROM guiche_tipos_senha WHERE PrePos='Pos'")
            if not FilaPosSQL.eof then
                TipoSenhaPosID = FilaPosSQL("id")

                set UltimaSenhaSQL = db.execute("SELECT Senha FROM guiche WHERE UnidadeID = "&session("UnidadeID")&" and TipoSenha = "&TipoSenhaPosID&" and date(DataHoraChegada) = date(curdate()) ORDER BY id DESC LIMIT 1")
                if not UltimaSenhaSQL.eof then
                    Senha = UltimaSenhaSQL("Senha") + 1
                else
                    Senha = FilaPosSQL("StartNumero")
                end if

                db.execute("INSERT INTO guiche (Senha, Sta, PacienteID, UnidadeID, TipoSenha) VALUES ("&treatvalzero(Senha)&", 'Espera', "&PacienteID&", "&session("UnidadeID")&",  "&treatvalzero(TipoSenhaPosID)&")")
            end if
        end if

		db_execute("update sys_users set UsuariosNotificar='"&ref("UsuariosNotificar")&"' where id="&session("User"))
		splNotificar = split(ref("UsuariosNotificar"), "|")
		for	h=0 to ubound(splNotificar)
			if isnumeric(splNotificar(h)) and splNotificar(h)<>"" then
				db_execute("update sys_users as u set notiflanctos=concat( u.notiflanctos, '|"&buscaAtendimento("id")&"|' ) where id="&splNotificar(h))
			end if
		next
		%>
		$("#agePac<%=PacienteID%>").css("display", "none");
/*		$.ajax({
			type:"POST",
			url:"modalFimAtendimento.asp?AtendimentoID=<%=buscaAtendimento("id")%>",
			success: function(data){
				$("#modal").html(data);
				$("#modal-table").modal("show");
			}
		});*/
        <%
		if req("Solicitacao")<>"S"  then
			if ref("itemSADT")<>"" and EhTriagem<>"S" then
				splItemSADT = split(ref("itemSADT"), ", ")
				for i=0 to ubound(splItemSADT)
					
					set itemSADT = db.execute("select ig.ProcedimentoID, ig.Quantidade, ig.ValorUnitario, g.ConvenioID, ig.ValorTotal FROM tissprocedimentossadt ig INNER JOIN tissguiasadt g on g.id=ig.GuiaID WHERE ig.id="&splItemSADT(i))

					'verifica se ha algum ap pra insert ou update
					set pult = db.execute("select ap.id FROM atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID WHERE a.Data=date(now()) AND a.PacienteID="&PacienteID&" AND AtendimentoID ="&req("AtendimentoID")&" AND ProcedimentoID="&itemSADT("ProcedimentoID")&" AND rdValorPlano='P' AND ValorPlano="&treatvalzero(itemSADT("ConvenioID"))&"")
					if pult.EOF then
						db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&req("AtendimentoID")&", "&itemSADT("ProcedimentoID")&", "&treatvalzero(itemSADT("Quantidade"))&", "&treatvalzero(itemSADT("ValorUnitario"))&", 'P', 1, "&treatvalzero(itemSADT("ValorTotal"))&")")
						set pult = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&req("AtendimentoID")&" ORDER BY id desc limit 1")
					end if

					AtualiarHorario=True

                    set ConvenioSQL = db.execute("SELECT IFNULL(AlterarHorarioGuia, 1)AlterarHorarioGuia FROM convenios WHERE id="&treatvalzero(itemSadt("ConvenioID")))
                    if not ConvenioSQL.eof then
                        if ccur(ConvenioSQL("AlterarHorarioGuia"))=0 then
                            AlterarHorarioGuia=False
                        end if
                    end if
                    if AlterarHorarioGuia then
                        db_execute("UPDATE tissprocedimentossadt SET ProfissionalID="&session("idInTable")&", Data=date(now()), HoraInicio="&mytime(buscaAtendimento("HoraInicio"))&", HoraFim="&mytime(buscaAtendimento("HoraFim"))&", AtendimentoID="&pult("id")&" WHERE id="&splItemSADT(i))
                    end if
				next
			end if
			
			
			if ref("idConsulta")<>"" and EhTriagem<>"S" then
				splidConsulta = split(ref("idConsulta"), ", ")
				for i=0 to ubound(splidConsulta)
					
					set idConsulta = db.execute("select g.ProcedimentoID, g.ConvenioID, g.ValorProcedimento FROM tissguiaconsulta g WHERE g.id="&splidConsulta(i))

					'verifica se ha algum ap pra insert ou update
					set pult = db.execute("select ap.id FROM atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID WHERE a.Data=date(now()) AND a.PacienteID="&PacienteID&" AND AtendimentoID ="&req("AtendimentoID")&" AND ProcedimentoID="&idConsulta("ProcedimentoID")&" AND rdValorPlano='P' AND ValorPlano="&treatvalzero(idConsulta("ConvenioID"))&"")
					if pult.EOF then
						db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&req("AtendimentoID")&", "&idConsulta("ProcedimentoID")&", 1, "&treatvalzero(idConsulta("ValorProcedimento"))&", 'P', 1, "&treatvalzero(idConsulta("ValorProcedimento"))&")")
						set pult = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&req("AtendimentoID")&" ORDER BY id desc limit 1")
					end if

					db_execute("UPDATE tissguiaconsulta SET ProfissionalID="&session("idInTable")&", DataAtendimento=date(now()), AtendimentoID="&pult("id")&" WHERE id="&splidConsulta(i))
				next
			end if

			
			if ref("itemInvoice")<>"" and EhTriagem<>"S" then
				splitemInvoice = split(ref("itemInvoice"), ", ")
				for i=0 to ubound(splitemInvoice)
					
					set itemInvoice = db.execute("select ii.ItemID ProcedimentoID, ii.ValorUnitario, ii.Desconto, ii.Acrescimo FROM itensinvoice ii WHERE ii.id="&splitemInvoice(i))

					'verifica se ha algum ap pra insert ou update
					set pult = db.execute("select ap.id FROM atendimentosprocedimentos ap LEFT JOIN atendimentos a on a.id=ap.AtendimentoID WHERE a.Data=date(now()) AND a.PacienteID="&PacienteID&" AND AtendimentoID ="&req("AtendimentoID")&" AND ProcedimentoID="&itemInvoice("ProcedimentoID")&" AND rdValorPlano='V'")
					if pult.EOF then
						'..... ver tb se este ap já foi usado em outro item, ou seja, nao passa o AtendimentoID, mas ve se este está orfao nao aplicado a outro item/guia.....
						db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Quantidade, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&req("AtendimentoID")&", "&itemInvoice("ProcedimentoID")&", 1, "&treatvalzero(itemInvoice("ValorUnitario"))&", 'P', 1, "&treatvalzero(itemInvoice("ValorUnitario"))&")")
						set pult = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&req("AtendimentoID")&" ORDER BY id desc limit 1")
					end if
					'....... tem que gerar o repasse a partir desta execução.....
					db_execute("UPDATE atendimentos set HoraInicio="&mytime(buscaAtendimento("HoraInicio"))&", HoraFim="&mytime(time())&" WHERE id="&req("AtendimentoID"))

					sqlUpdateItensInvoice = "UPDATE itensinvoice SET Executado='S', ProfissionalID="&session("idInTable")&", Associacao=5, DataExecucao=date(now()), HoraExecucao="&mytime(buscaAtendimento("HoraInicio"))&", HoraFim="&mytime(time())&", AtendimentoID="&pult("id")&" WHERE id="&splitemInvoice(i)
					call gravaLogs(sqlUpdateItensInvoice, "AUTO", "Executado por atendimento", "InvoiceID")
					db_execute(sqlUpdateItensInvoice)
				next
			end if
			
			'verifica se existe algum item invoice igual a este atendimento, mas com AtendimentoID nulo
'			set itemOrfao = db.execute("select ii.ItemID ProcedimentoID, ii.ValorUnitario, ii.Desconto, ii.Acrescimo FROM itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID WHERE i.AccountID="&PacienteID&"")
			
			%>
			if(envioSmsEmail = 0){
                callbackFinaliza();
			}
			<%
		else
			%>
			$("#modal-table").modal("hide");
            $.gritter.add({
                title: '<i class="far fa-share-square"></i> Solicitação enviada...',
                text: '',
                class_name: 'gritter-success gritter-light'
            });
			<%
		end if
	end if
else
	%>
	if($('#modal-table').hasClass('in')==false){
		conteudoConta();
		$("#modal-table").modal("hide");
	}else{
		ajxContent('Conta', <%=PacienteID%>, '1', 'divHistorico');
        $("#modal-table").modal("hide");
	}
	<%
end if
'if isdate(ref("inf-Data")) then
'    DataAtual = cdate(ref("inf-Data"))
'    if DataAtual<>DataAnterior then
'        if DataAnterior<>"" and isdate(DataAnterior) then
'            call statusPagto("", PacienteID, DataAnterior, "V", 0, 0, 0, 0)
'        end if
'    end if
'    call statusPagto("", PacienteID, ref("inf-Data"), "V", 0, 0, 0, 0)
'end if

if req("Origem")="Atendimento" and req("Solicitacao")<>"S" then
%>
setTimeout(()=>{
	callbackFinaliza();
}, 3000)
<%
	ativarSMS="true"
	ativarEmail="true"
    sqlAgendamentos = "select age.*, l.UnidadeID from agendamentos age left join locais l on l.id=age.localID where age.id = "&AgendamentoID
                set resultAgendamentos = db.execute(sqlAgendamentos)
				if not resultAgendamentos.eof then
					ProcedimentoID = resultAgendamentos("TipoCompromissoID")
					Status = resultAgendamentos("StaID")
					ProfissionalID = resultAgendamentos("ProfissionalID")
					EspecialidadeID = resultAgendamentos("EspecialidadeID")
					UnidadeID = resultAgendamentos("UnidadeID")
					sqlEventoSMS = " SELECT evt.*,"&_
						"         s.TextoEmail,"&_
						"         s.TextoSMS,"&_
						"         s.AtivoSMS,"&_
						"         s.AtivoEmail,"&_
						"         s.ConfirmarPorEmail,"&_
						"         s.ConfirmarPorSMS,"&_
						"         s.id ModeloIDExiste,"&_
						"         s.TituloEmail,"&_
						"         s.InviteEmail "&_
						"         FROM eventos_emailsms evt "&_
						"         LEFT JOIN sys_smsemail s ON s.id = evt.ModeloID "&_
						"   WHERE (((evt.Procedimentos LIKE '%|"&ProcedimentoID&"|%' OR evt.Procedimentos LIKE '%|ALL|%' OR evt.Procedimentos ='') "&_
						"     AND evt.Status LIKE '%|"&Status&"|%') ) AND evt.Ativo=1 AND evt.sysActive=1  "&_
						"     AND (evt.Profissionais like '%|"&ProfissionalID&"|%' or evt.Profissionais = '' or evt.Profissionais IS NULL) "&_
						"     AND (evt.Especialidades like '%|"&EspecialidadeID&"|%' or evt.Especialidades = '' or evt.Especialidades IS NULL) "&_
						"     AND (evt.Unidades like '%|"&UnidadeID&"|%' or evt.Unidades = '' or evt.Unidades IS NULL) "&_
						"     AND (evt.TipoEventosEmailsmsID <> 2 or evt.TipoEventosEmailsmsID is null) "&_
						" ORDER BY IF(evt.Procedimentos LIKE '%|"&ProcedimentoID&"|%',0,1) ASC limit 1"
					set eventSMS = db.execute(sqlEventoSMS)
					ativarSMS = "false"
					ativarEmail= "false"
					if not eventSMS.eof then 
						if eventSMS("AtivoSMS")&"" = "on" then
							ativarSMS = "true"
						end if
						if eventSMS("AtivoEmail")&"" = "on" then
							ativarEmail = "true"
						end if
					end if
				end if
%>


gtag('event', 'atendimento_finalizado', {
	'event_category': 'atendimento',
	'event_label': "Proposta > Salvar",
});

getUrl("patient-interaction/get-appointment-events", {appointmentId: "<%= AgendamentoID %>",sms: <%=ativarSMS%>,email: <%=ativarEmail%>, forceEvent:false }, callbackFinaliza)
<%
end if
%>