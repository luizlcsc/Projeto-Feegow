<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<%
omitir = ""
if session("Admin")=0 then
	set omit = db.execute("select * from omissaocampos")
	while not omit.eof
		tipo = omit("Tipo")
		grupo = omit("Grupo")
		if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
			omitir = omitir&lcase(omit("Omitir"))
		elseif Tipo="E" and lcase(session("Table"))="profissionais" then
			set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
			if not prof.eof then
				if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
					omitir = omitir&lcase(omit("Omitir"))
				end if
			end if
		end if
	omit.movenext
	wend
	omit.close
	set omit = nothing
end if



camposPedir = "Tel1, Cel1, Email1"
if session("banco")="clinic811" or session("banco")="clinic5445" then
	camposPedir = "Tel1, Cel1, Email1, Origem"
end if
splCamposPedir = split(camposPedir, ", ")



if request.ServerVariables("REMOTE_ADDR")<>"::1" then
	'on error resume next
end if

ProfissionalID = req("ProfissionalID")
if ProfissionalID="undefined" or ProfissionalID="0" then
    ProfissionalID=""
end if
EquipamentoID = req("EquipamentoID")
if EquipamentoID="0" or EquipamentoID="undefined" then
    EquipamentoID=""
end if
LocalID = req("LocalID")
if LocalID="" or LocalID="undefined" then LocalID=0 end if

if ProfissionalID<>"" and ProfissionalID<>"0" then
    set prof = db.execute("select SomenteConvenios from profissionais where id="&ProfissionalID)
    if not prof.eof then
        if isnull(prof("SomenteConvenios")) or prof("SomenteConvenios")="" then
            Convenios = "Todos"
        elseif instr(prof("SomenteConvenios"), "|NONE|") then
            Convenios = "Nenhum"
        else
            SomenteConvenios = prof("SomenteConvenios")&""
            Convenios = replace(SomenteConvenios, "|", "")
        end if
    else
        Convenios = "Todos"
    end if
else
    Convenios = "Todos"
end if



Hora = req("horario")
Hora = left(Hora,2)&":"&mid(Hora, 3, 2)
if req("Data")="" or not isdate(req("Data")) then
	Data = date()
else
	Data = req("Data")
end if
if req("Horario")="00:00" then
	Encaixe = 1
    if ProfissionalID<>"" and ProfissionalID<>"0" then
        set vMax = db.execute("select MaximoEncaixes, (select count(id) from agendamentos where ProfissionalID="&ProfissionalID&" and Encaixe=1 and Data="&mydatenull(Data)&") NumeroEncaixes from profissionais where id="&ProfissionalID&" and not isnull(MaximoEncaixes)")
        if not vMax.EOF then
            NumeroEncaixes = ccur(vMax("NumeroEncaixes"))+1
            MaximoEncaixes = ccur(vMax("MaximoEncaixes"))
            if NumeroEncaixes>MaximoEncaixes then
                %>
                <div class="alert alert-danger text-center">
                    <i class="far fa-exclamation-triangle"></i> ATEN&Ccedil;&Atilde;O: O n&uacute;mero m&aacute;ximo de <%=MaximoEncaixes %> encaixes permitidos para este profissional j&aacute; foi atingido.
                </div>

                <script >
                    $("#btnSalvarAgenda").attr("disabled", true);
                </script>
                <%
            end if
        end if
    end if
end if
'response.Write("["&Hora&"]")

if req("id")<>"" and isNumeric(req("id")) then
	AgendamentoID = req("id")
	set buscaAgendamentos = db.execute("select * from agendamentos where id="&req("id"))
else
	set buscaAgendamentos = db.execute("select * from agendamentos where ProfissionalID="&ProfissionalID&" and Hora='"&Hora&"' and Data='"&mydate(Data)&"'")
	'VERIFICAR -> esse este der mais de um registro no horaio/profissional criar consulta em grupo
end if
if buscaAgendamentos.EOF then
	ConsultaID = 0
	set confirmacoes = db.execute("select AtivoEmail, AtivoSMS from sys_smsemail")
	if not confirmacoes.eof then
		if confirmacoes("AtivoEmail")="on" then
			ConfEmail = "S"
		end if
		if confirmacoes("AtivoSMS")="on" then
			ConfSMS = "S"
		end if
	end if
	StaID = 1
else
	Data = buscaAgendamentos("Data")
	ConsultaID = buscaAgendamentos("id")
	PacienteID = buscaAgendamentos("PacienteID")
	Encaixe = buscaAgendamentos("Encaixe")
    EquipamentoID = buscaAgendamentos("EquipamentoID")
    if session("Banco")="clinic5445" then
        ageCanal = buscaAgendamentos("CanalID")
    end if


	set pac = db.execute("select * from pacientes where id="&PacienteID)
	if not pac.eof then
'		Tel1 = pac("Tel1")
'		Cel1 = pac("Cel1")
'		Email1 = pac("Email1")
        ageTabela = pac("Tabela")
	end if

	ProcedimentoID = buscaAgendamentos("TipoCompromissoID")
	rdValorPlano = buscaAgendamentos("rdValorPlano")
	if rdValorPlano="P" then
		ConvenioID = buscaAgendamentos("ValorPlano")
	else
		Valor = fn(buscaAgendamentos("ValorPlano"))
	end if
	Tempo = buscaAgendamentos("Tempo")
	StaID = buscaAgendamentos("StaID")
	LocalID = buscaAgendamentos("LocalID")
	Notas = buscaAgendamentos("Notas")
	ConfEmail = buscaAgendamentos("ConfEmail")
	ConfSMS = buscaAgendamentos("ConfSMS")
	Chegada = buscaAgendamentos("HoraSta")
	ProfissionalID = buscaAgendamentos("ProfissionalID")
end if

'dah o select pegando os dados do agendamento
'rdValorPlano = agen("rdValorPlano")


'response.Write(Hora)

set vcaVarTab = db.execute("select id from tabelaparticular where sysActive=1")
if not vcaVarTab.eof then
    colPac = 4
    haTab = 1
else
    colPac = 6
    haTab = 0
end if

if isnumeric(req("EquipamentoID")) and req("EquipamentoID")<>"0" then
    oti = ""
else
    oti = "agenda"
end if

GradeID = req("GradeID")
if GradeID<> "" and GradeID<>"undefined" then
    set GradeSQL = db.execute("SELECT * FROM assfixalocalxprofissional WHERE id="&GradeID)
    if not GradeSQL.eof then
        GradeApenasProcedimentos = GradeSQL("Procedimentos")
        GradeApenasConvenios = GradeSQL("Convenios")
        GradeEquipamentoApenasProfissionais = GradeSQL("Profissionais")
    end if
else
    GradeID=""
end if

%>
<div class="panel">
<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab4">
        <li class="active abaAgendamento"><a data-toggle="tab" href="#dadosAgendamento"><i class="far fa-calendar"></i> <span class="hidden-xs">Agendamento</span></a></li>
        <li id="abaFicha" class="abasAux abaAgendamento"><a data-toggle="tab" onclick="ajxContent('Pacientes&Agenda=1', $('#PacienteID').val(), '1', 'divDadosPaciente'); $('#alertaAguardando').removeClass('hidden');" href="#divDadosPaciente"><i class="far fa-user"></i> <span class="hidden-xs">Ficha</span></a></li>
        <li class="abasAux abaAgendamento"><a data-toggle="tab" onclick="ajxContent('HistoricoPaciente&PacienteID='+$('#PacienteID').val(), '', '1', 'divHistorico'); crumbAgenda();" href="#divHistorico"><i class="far fa-list"></i> <span class="hidden-xs">Hist&oacute;rico</span></a></li>
        <%if Aut("contapac")=1 or aut("|areceberpaciente")=1 then%>
	        <li class="abasAux abaAgendamento hidden-xs"><a data-toggle="tab" onclick="$('#divHistorico').html('Carregando...'); ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico'); crumbAgenda();$('#alertaAguardando').removeClass('hidden');" href="#divHistorico"><i class="far fa-money"></i> <span class="hidden-xs">Conta</span></a></li>
        <% End If %>
	</ul>



<span class="panel-controls" onclick="javascript:af('f'); crumbAgenda();">
    <i class="far fa-arrow-left"></i> <span class="hidden-xs">Voltar</span>
</span>



</div>
<div class="panel-body">

    <input type="hidden" name="AgAberto" id="AgAberto" value="<%= ProfissionalID &"_"& Data &"_"& Hora %>"

    <% if (StaID=1 or StaID=7 or StaID=15) and cdate(Data)=date() and 0 then %>
        <div class="alert alert-warning hidden" id="alertaAguardando">Caso o paciente tenha chegado, mude o status para aguardando.</div>
    <% end if %>

    <div class="tab-content">
    <div id="dadosAgendamento" class="tab-pane in active">
        <form method="post" action="" id="formAgenda" name="formAgenda">
        <input type="hidden" name="ConsultaID" id="ConsultaID" value="<%=ConsultaID%>" />
        <input type="hidden" name="GradeID" id="GradeID" value="<%=GradeID%>" />

        <div class="modal-body">
            <div class="bootbox-body">

                <div class="panel hidden" id="autDiv">
                    <div class="panel-heading warning">
                        <span class="panel-title">Esta ação requer a autorização de um dos usuários abaixo:</span>
                    </div>
                    <div class="panel-body">
                        <div class="alert alert-warning" id="autUsers"></div>
                        <input type="password" name="autSenha" placeholder="Digite a senha" class="form-control" autocomplete="off" />
                    </div>
                </div>

        <%
		set msgs = db.execute("select * from agendamentosrespostas where AgendamentoID = '"&AgendamentoID&"'")
		while not msgs.eof
			%>
			<span class="label label-alert">Paciente respondeu em <%=msgs("DataHora")%>: <em><%=msgs("Resposta")%></em></span>
			<%
		msgs.movenext
		wend
		msgs.close
		set msgs = nothing

        HoraReadonly = ""
        if req("horario")<>"00:00" then
            HoraReadonly = " readonly"
        end if

        ProfissionaisEquipamentos = replace(GradeEquipamentoApenasProfissionais&"","|","")
        if ProfissionaisEquipamentos&"" = "" then
            ProfissionaisEquipamentos="0"
        end if
		%>

        <div class="row">
			<%= quickField("datepicker", "Data", "Data", 2, Data, "", "", " required no-datepicker readonly") %>
            <%= quickField("timepicker", "Hora", "Hora", 2, Hora, "", "", " required"&HoraReadonly) %>

            <div class="col-md-2"><br>
            	<div class="checkbox-custom checkbox-alert"><input type="checkbox" name="Encaixe" id="Encaixe" value="1"<%if Encaixe=1 then%> checked<%end if%>><label for="Encaixe" class="checkbox"> Encaixe</label></div>
            </div>

			<%if req("Tipo")="Quadro" or req("ProfissionalID")="" or req("ProfissionalID")="0" then%>
                <%= quickField("simpleSelect", "ProfissionalID", "Profissional", 2, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' AND (id IN ("&ProfissionaisEquipamentos&") or '"&ProfissionaisEquipamentos&"'='0') order by NomeProfissional", "NomeProfissional", " required") %>
            <%else %>
                <div class="col-md-2">
                    <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID%>" />
                </div>
            <%end if %>




                    <div class="col-md-4">

                    <%
					if StaID=4 or StaID=101 then
						colCheg = "6"
						disCheg = "block"
					else
						colCheg = "12"
						disCheg = "none"
					end if
					%>


                        <div class="row">
                	        <div class="col-md-<%=colCheg%>" id="divStatus">
                                <label>Status</label><br />
	                	        <select name="StaID" id="StaID" class="form-control">
                                <%
						        set sta = db.execute("select * from StaConsulta order by StaConsulta")
						        while not sta.eof
							        %>
							        <option value="<%=sta("id")%>"<%if StaID=sta("id") then%> selected="selected"<%end if%> style="background-image:url(assets/img/<%=sta("id")%>.png); background-repeat:no-repeat; padding-left:22px; background-position:3px 3px"><%=sta("StaConsulta")%></option>
							        <%
						        sta.movenext
						        wend
						        sta.close
						        set sta=nothing
						        %>
                    	        </select>
                            </div>
                            <div class="col-md-6" id="divChegada" style="display:<%=disCheg%>">
                    	        <label>Chegada</label><br>
						        <%= quickField("timepicker", "Chegada", "", 2, Chegada, "", "", "") %>
                            </div>
                        </div>
                    </div>




        </div>
        <div class="row pt20">
            <div class="col-md-<%= colPac %>">
                <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""parametros(this.id, this.value);""", "required", "") %>
            </div>
			<%
			for i=0 to ubound(splCamposPedir)
				if isobject(pac) then
					if not pac.eof then
						valorCampo = pac(""&splCamposPedir(i)&"")
					end if
				end if
				set dField = db.execute("select c.label, c.selectSQL, c.selectColumnToShow, tc.typeName from cliniccentral.sys_resourcesfields c LEFT JOIN cliniccentral.sys_resourcesfieldtypes tc on tc.id=c.fieldTypeID WHERE c.ResourceID=1 AND c.columnName='"&splCamposPedir(i)&"'")
				if not dField.EOF then

    	            if instr(Omitir, "|"&lcase(splCamposPedir(i))&"|") then%>
                    	<input type="hidden" name="age<%=splCamposPedir(i)%>" id="age<%=splCamposPedir(i)%>" value="<%=valorCampo%>">
						<%
					else
						%><input type="text" name="ageEmail10" class="form-control hidden" autocomplete="off" />
						<%= quickField(dField("typeName"), "age"&splCamposPedir(i), dField("label"), 2, valorCampo, dField("selectSQL"), dField("selectColumnToShow"), " autocomplete='off' no-select2 ") %>
					<%end if

				end if
			next
            if haTab then
                call quickField("simpleSelect", "ageTabela", "Tabela", 2, ageTabela, "select id, NomeTabela from tabelaparticular where sysActive=1 order by NomeTabela", "NomeTabela", " no-select2  onchange=""$.each($('.linha-procedimento'), function(){ parametros('ProcedimentoID'+$(this).data('id'),$(this).find('select[data-showcolumn=\'NomeProcedimento\']').val()); })""  ")
            end if

            if session("Banco")="clinic5445" or session("Banco")="clinic100000" then
                if ageCanal<>1 then
                    call quickField("simpleSelect", "ageCanal", "Canal", 2, ageCanal, "select id, NomeCanal from agendamentocanais where sysActive=1 AND ExibirNaAgenda='S' order by NomeCanal", "NomeCanal", " no-select2 required empty")
                end if
            end if
			%>
        </div>







                <div class="row pt20">
                    <div class="col-md-12" <% if device()<>"" then %> style="overflow-x:scroll" <% end if %>>
                        <table class="table table-condensed">
                            <thead>
                                <tr class="info">
                                    <th width="25%">Procedimento</th>
                                    <th width="10%" nowrap>Tempo (min)</th>
                                    <th width="10%">Forma</th>
                                    <th width="15%">Valor / Convênio</th>
                                    <th width="15%">Local</th>
                                    <th width="15%">Equipamento</th>
                                    <th width="1%"><button type="button" onclick="procs('I', 0)" class="btn btn-xs btn-success"><i class="far fa-plus"></i></button></th>
                                </tr>
                            </thead>
                            <tbody id="bprocs">
                                <tr class="linha-procedimento" data-id="">
                                    <td><%= selectInsert("", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""parametros(this.id, this.value);"" data-agenda="""" data-exibir="""&GradeApenasProcedimentos&"""", oti, "") %></td>
                                    <td>
                                        <%
                                        TempoChange = ""
                                        if aut("|agendaalteracaoprecadastroA|")=0 then
                                            TempoChange=" readonly"
                                        end if
                                        %>
                                        <%=quickField("number", "Tempo", "", 2, Tempo, "", "", " placeholder='Em minutos'"&TempoChange)%>
                                    </td>
                                    <td>
                                        <div class="radio-custom radio-primary"><input type="radio" name="rdValorPlano" id="rdValorPlanoV" required value="V"<% If rdValorPlano="V" Then %> checked="checked"<% End If %> class="ace valplan" onclick="valplan('', 'V')" style="z-index:-1" /><label for="rdValorPlanoV" class="radio"> Particular</label></div>
                                        <%
                                        if Convenios<>"Nenhum" and (GradeApenasConvenios<> "|P|" or isnull(GradeApenasConvenios)) then
                                        %>
                                        <div class="radio-custom radio-primary"><input type="radio" name="rdValorPlano" id="rdValorPlanoP" required value="P"<% If rdValorPlano="P" Then %> checked="checked"<% End If %> class="ace valplan" onclick="valplan('', 'P')" style="z-index:-1" /><label for="rdValorPlanoP" class="radio"> Conv&ecirc;nio</label></div>
                                        <%end if %>
                                    </td>
                                    <td>
                                        <div class="col-md-12" id="divValor"<% If rdValorPlano<>"V" Then %> style="display:none"<% End If %>>
                                            <div class="row">
                                                <div class="col-md-12">
                                                    <%
                                                    if aut("|valordoprocedimentoA|")=0 and aut("|valordoprocedimentoV|")=1 then
                                                        %>
                                                        <input type="hidden" id="Valor" name="Valor" value="<%=Valor%>">
                                                        R$ <span id="ValorText"><%=Valor%></span>
                                                        <script >
                                                          $("#Valor").change(function() {
                                                              $("#ValorText").html($(this).val());
                                                          });
                                                        </script>
                                                    <% elseif aut("areceberpacienteV")=1 and aut("|valordoprocedimentoV|")=1 then
                                                        %>
                                                        <%=quickField("text", "Valor", "", 5, Valor, " text-right input-mask-brl ", "", "")%>
                                                        <%
                                                    else
                                                        %>
                                                        <input type="hidden" id="Valor" name="Valor" value="<%=Valor%>">
                                                        <%
                                                    end if
                                                    %>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-md-12" id="divConvenio"<% If rdValorPlano<>"P" Then %> style="display:none"<% End If %>>
                                            <%
                                            if Convenios="Todos" then
                                            %>
                                            <%=selectInsert("", "ConvenioID", ConvenioID, "convenios", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value+'_'+$('#ProcedimentoID').val());""", "", "")%>
                                            <%
                                            else
                                                if (len(Convenios)>2 or (isnumeric(Convenios) and not isnull(Convenios))) and instr(Convenios&" ", "Nenhum")=0 then
                                                %>
                                                <%=quickfield("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 12, ConvenioID, "select id, NomeConvenio from convenios where id in("&Convenios&") order by NomeConvenio", "NomeConvenio", " data-exibir="""&GradeApenasConvenios&""" onchange=""parametros(this.id, this.value);""") %>
                                                <%
                                                end if
                                            end if
                                            %>

                                        </div>

                                    </td>
                                    <td><%= selectInsert("", "LocalID", LocalID, "locais", "NomeLocal", "", "", "") %></td>
                                    <td>
                                        <%if req("Tipo")="Quadro" or req("EquipamentoID")="" or req("EquipamentoID")="undefined" or req("EquipamentoID")="0" then%>
                                            <%=quickfield("select", "EquipamentoID", "", 2, EquipamentoID, "select * from equipamentos where sysActive=1", "NomeEquipamento", "") %>
                                        <%else %>
                                            <input type="hidden" name="EquipamentoID" id="EquipamentoID" value="<%=EquipamentoID%>" />
                                        <%end if %>
                                    </td>
                                    <td>

                                    </td>
                                </tr>
                                <%
                                nProcedimentos = 0
                                set ageprocs = db.execute("select * from agendamentosprocedimentos where AgendamentoID="& ConsultaID)
                                while not ageprocs.eof
                                    call linhaAgenda(ageprocs("id"), ageprocs("TipoCompromissoID"), ageprocs("Tempo"), ageprocs("rdValorPlano"), ageprocs("ValorPlano"), ageprocs("ValorPlano"), Convenios, ageprocs("EquipamentoID"), ageprocs("LocalID"))
                                ageprocs.movenext
                                wend
                                ageprocs.close
                                set ageprocs=nothing
                                %>
                            </tbody>
                        </table>
                        <input type="hidden" id="nProcedimentos" value="<%= nProcedimentos %>" />
                    </div>


                </div>
                        <hr class="alt short">
                <div class="row">
                    <div class="col-md-8">
                        <div class="row">
                        <%
						set s = dbc.execute("select * from cliniccentral.smshistorico where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))
						set m = dbc.execute("select * from cliniccentral.emailshistorico where AgendamentoID="&ConsultaID&" and AgendamentoID<>0 and LicencaID="&replace( session("banco"), "clinic", "" ))

						if not s.eof then
							SMSEnviado = "S"
						end if
						if not m.EOF then
							EmailEnviado = "S"
						end if

                        response.write("    <div class=""col-md-4"">")
                        if ConsultaID=0 then
                            IntervaloRepeticao = 1
						    %>
                                <div class="checkbox-custom checkbox-success"><input name="rpt" id="rpt" onclick="rpti();" value="S" type="checkbox"<%if rpt="S" and rpt="" then%> checked="checked"<%end if%> /><label for="rpt"> Repetir</label></div>
                            <%
                        end if
                        response.write("    </div>")
						%>
                            <div class="col-md-4">
                                <div class="checkbox-custom checkbox-primary"><input name="ConfSMS" id="ConfSMS" value="S" type="checkbox"<%if ConfSMS="S" and SMSEnviado="" then%> checked="checked"<%end if%> /><label for="ConfSMS"> Enviar SMS</label></div>
                                <%
								'response.Write("select * from cliniccentral.smshistorico where AgendamentoID="&ConsultaID&" and LicencaID="&replace( session("banco"), "clinic", "" ))
								while not s.eof
									%>
									<br><small><em>SMS enviado em <%=s("EnviadoEm")%></em></small>
									<%
								s.movenext
								wend
								s.close
								set s=nothing
								%>
                            </div>
                            <div class="col-md-4">
                                <div class="checkbox-custom checkbox-primary"><input name="ConfEmail" id="ConfEmail" value="S" type="checkbox"<%if ConfEmail="S" and EmailEnviado="" then%> checked="checked"<%end if%> /><label for="ConfEmail"> Enviar E-mail</label></div>
                                <%
								while not m.eof
									%>
									<br><small><em>E-mail enviado em <%=m("EnviadoEm")%></em></small>
									<%
								m.movenext
								wend
								m.close
								set m=nothing
								%>
                            </div>
                        </div>
                        <div class="row hidden" id="divRpt">
                        	<div class="col-md-12">
                                <div class="row">
                                    <table class="table">
                                        <tr>
                                            <td>Repetição:</td>
                                            <td>
                                                <select name="Repeticao" id="Repeticao" class="form-control">
                                                    <option value="D" data-description="dias">Todos os dias</option>
                                                    <option value="S" data-description="semanas" selected>Semanal</option>
                                                    <option value="M" data-description="meses">Mensal</option>
                                                    <option value="A" data-description="anos">Anual</option>
                                                </select>


                                                <%'=quickfield("simpleSelect", "Repeticao", "", 12, Repeticao, "select 'D'id, 'Todos os dias' Tipo UNION ALL select 'S', 'Semanal:' UNION ALL select 'M', 'Mensal' UNION ALL select 'A', 'Anual'", "Tipo", "") %></td>
                                        </tr>
                                        <tr>
                                            <td>Repete a cada:</td>
                                            <td>
                                                <div class="input-group">
                                                    <%=quickfield("number", "IntervaloRepeticao", "", 12, IntervaloRepeticao, "", "", " min=1 max=30 maxlegth=2") %>
                                                    <span class="input-group-addon" id="rptDescricao">
														semanas
													</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="rptDS">
                                            <td>Repete:</td>
                                            <td nowrap>
                                                <%
                                                    DiaSemana = weekday(Data)

                                                c=0
                                                while c<7
                                                    c=c+1
                                                    %>
                                                    <label>
                                                            <input type="checkbox" class="ace" name="repetirDias" value="<%=c %>"<%if DiaSemana=c then response.write(" checked ") end if %> /><span class="lbl"> <%=left(ucase(weekdayname(c)), 3) %></span>
                                                    </label>
                                                    &nbsp;
                                                    <%
                                                wend
                                                %>
                                            </td>
                                        </tr>
                                        <tr id="rptDM" class="hidden">
                                            <td>Considerar:</td>
                                            <td>
                                                <label><input type="radio" class="ace" name="tipoDiaMes" value="Dia" checked /><span class="lbl"> dia corrido do mês</span></label>
                                                <label><input type="radio" class="ace" name="tipoDiaMes" value="DiaSemana" /><span class="lbl"> dia da semana equivalente</span></label>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Início em:</td>
                                            <td>
                                                <%=quickfield("datepicker", "InicioRepeticao", "", 12, Data, "", "", " disabled ") %>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Termina:</td>
                                            <td>
                                                <div class="row col-xs-12">
                                                    <label><input type="radio" class="ace" name="TerminaRepeticao" value="N" checked /><span class="lbl"> Nunca </span></label>
                                                </div>
                                                <div class="row">
                                                    <div class="col-xs-3">
                                                        <label><input type="radio" class="ace" name="TerminaRepeticao" value="O" /><span class="lbl"> Após </span></label>
                                                    </div>
                                                    <div class="col-xs-3">
                                                        <input type="number" class="form-control" name="RepeticaoOcorrencias" value="<%=RepeticaoOcorrencias %>" />
                                                    </div>
                                                    <div class="col-xs-6">
                                                        Ocorrências
                                                    </div>
                                                </div>
                                                <div class="row">
                                                    <div class="col-xs-3">
                                                        <label><input type="radio" class="ace" name="TerminaRepeticao" value="D" /><span class="lbl"> Em </span></label>
                                                    </div>
                                                    <div class="col-xs-9">
                                                        <%=quickfield("datepicker", "RepeticaoDataFim", "", 9, RepeticaoDataFim, "", "", "") %>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>


                                </div>
                            </div>
                        </div>

                    </div>
                    <%= quickField("memo", "Notas", " ", 4, Notas, "", "", " placeholder=""Observações"" ") %>


                </div>





















            </div>
        </div>
        <div class="modal-footer">
        <%if session("banco")="clinic1773" then%>
        <button class="btn btn-sm btn-primary" title="Enviar sms personalizado." type="button" style="float: left;" id="btnSendSms">
                        <i class="far fa-mobile"></i>
                    </button>
        <%end if

            %>

            <div class="col-xs-12 col-md-6 pull-right">
                <%
                if (ConsultaID=0 and aut("agendaI")=1) or (ConsultaID<>0 and aut("agendaA")=1) then
                %>
                <div class="col-xs-6 col-md-3 pt10">
                    <button class="btn btn-sm btn-primary btn-block" id="btnSalvarAgenda">
                        <i class="far fa-save"></i> Salvar
                    </button>
                </div>
                <%
                end if
                if ConsultaID<>0 then
                    if aut("agendaI")=1 then
                    %>
                    <div class="col-xs-6 col-md-3 pt10">
                        <button class="btn btn-sm btn-success btn-block" type="button" onclick="repetir(<%=ConsultaID%>, 'Solicitar', '');">
                            <i class="far fa-copy"></i> Repetir
                        </button>
                    </div>
                    <%
                    end if
                    if aut("agendaA")=1 then
                    %>
                    <div class="col-xs-6 col-md-3 pt10">
                        <button class="btn btn-sm btn-warning btn-block" type="button" onclick="remarcar(<%=ConsultaID%>, 'Solicitar', '');">
                            <i class="far fa-copy"></i> Remarcar
                        </button>
                    </div>
                    <%
                    end if
                    if aut("agendaX")=1 then
                    %>
                    <div class="col-xs-6 col-md-3 pt10">
                        <button class="btn btn-sm btn-danger btn-block" type="button" data-bb-handler="danger" onclick="excluiAgendamento(<%=ConsultaID%>, 0);">
                            <i class="far fa-trash"></i> Excluir
                        </button>
                    </div>
                    <%
                    end if
                Else
                    if aut("bloqueioagendaI")=1 and req("Tipo")<>"Quadro" then
                    %>
                    <div class="col-xs-6 col-md-3 pt10">
                        <button class="btn btn-sm btn-info btn-block" type="button" data-bb-handler="danger" onclick="abreBloqueio(0, '<%=Data%>', '<%=Hora%>');">
                            <i class="far fa-lock"></i> Inserir Bloqueio
                        </button>
                    </div>
                    <%
                    end if
                End If %>
            </div>


        </div>
        </form>
	</div>
    <div id="divDadosPaciente" class="tab-pane">
    	Carregando...
    </div>
    <div id="divHistorico" class="tab-pane">
    	Carregando...
    </div>
</div>
</div>
</div>














<script type="text/javascript">
    $("#Encaixe").change(function() {
        var $Hora = $("#Hora");
        $Hora.attr("readonly", !$(this).prop("checked"));
        $Hora.mask("99:99");
    });

    $.fn.modal.Constructor.prototype.enforceFocus = function() {};
$("#searchPacienteID").change(function(){
	$("#ageTel1, #ageCel1, #ageEmail1").val('');
});
function abasAux(){
//	alert($("#PacienteID").val());
	if($("#PacienteID").val()=="" || $("#PacienteID").val()=="0"){
		$(".abasAux").css("display", "none");
	}else{
		$(".abasAux").css("display", "block");
	}
}
abasAux();
function parametros(tipo, id){
    setTimeout(function() {
        if(id == -1){
            id = $("#"+tipo).val();
        }
        $.ajax({
            type:"POST",
            url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
            data:$("#formAgenda").serialize(),
            success:function(data){
                eval(data);
                abasAux();
            }
        });
    }, 100);
}

$(".abaAgendamento").click(function(){
    setAgendamentoHeaders();
});

function setAgendamentoHeaders() {
    <%
      set UnidadeSQL = db.execute("SELECT (SELECT NomeFantasia FROM (SELECT 0 id, NomeFantasia FROM empresa WHERE id=1 UNION ALL SELECT id,NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1)t WHERE t.id=l.UnidadeID)NomeFantasia FROM locais l WHERE l.id="&treatvalzero(LocalID))
      if not UnidadeSQL.eof then
          NomeUnidade = UnidadeSQL("NomeFantasia")&" - "
      end if
      set ProfissionalSQL = db.execute("SELECT CONCAT(IF(tr.Tratamento IS NULL, '',tr.Tratamento),' ', p.NomeProfissional)NomeProfissional FROM profissionais p LEFT JOIN tratamento tr ON tr.id=p.TratamentoID WHERE p.id="&treatvalzero(ProfissionalID))
      if not ProfissionalSQL.eof then
          NomeProfissional = ProfissionalSQL("NomeProfissional")
      end if
      %>
      var nomeUnidade = "<%=NomeUnidade%>";
      var nomeProfissional = "<%=NomeProfissional%>";
      $("#rbtns").html(" <strong style='font-size:17px;margin-right:30px'>"+nomeUnidade +nomeProfissional+"</strong>");
}
setAgendamentoHeaders();

function valplan(n, tipo){
//	var tipo = $(this).val();
	if(tipo=="V"){
		$("#divConvenio"+n).hide();
		$("#divValor"+n).show();
	}else{
		$("#divConvenio"+n).show();
		$("#divValor"+n).hide();
	}
}
$("#formAgenda").submit(function() {
	$("#btnSalvarAgenda").html('salvando');
	$("#btnSalvarAgenda").attr('disabled', 'disabled');
	$.post("saveAgenda.asp", $("#formAgenda").serialize())
	.done(function(data) {
	  $("#btnSalvarAgenda").html('<i class="far fa-save"></i> Salvar');
	  $("#btnSalvarAgenda").removeAttr('disabled');
	  eval(data);
	});
	return false;
});
function excluiAgendamento(ConsultaID, Confirma){
	$.ajax({
		type:"POST",
		url:"excluiAgendamento.asp?ConsultaID="+ConsultaID+"&Confirma="+Confirma+"&token=98b4d9bbfdfe2170003fcb23b8c13e6b",
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
function repeteAgendamento(ConsultaID){
	$.ajax({
		type:"POST",
		url:"repeteAgendamento.asp?ConsultaID="+ConsultaID,
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
setInterval(function(){abasAux()}, 3000);


$("#StaID").change(function(){
    //triagem 101
	if($(this).val()=="4" || $(this).val()=="101"){
		$("#divStatus").removeClass("col-md-12");
		$("#divStatus").addClass("col-md-6");
		$("#divChegada").fadeIn("slow");

		var time = new Date();
		var M = time.getMinutes();
		var H = time.getHours();

		if(M <= 9){
		    M = "0"+M;
		}
		if(H <= 9){
		    H = "0"+H;
		}

        var horaAtual = H + ":" + M;

		$("#Chegada").val(horaAtual);
	}else{
		$("#divStatus").addClass("col-md-12");
		$("#divStatus").removeClass("col-md-6");
		$("#divChegada").hide();
	}
});

<%
if session("OtherCurrencies")="phone" and ConsultaID=0 then
	set vcaCha = db.execute("select Contato from chamadas where StaID=1 AND sysUserAtend="&session("User"))
	if not vcaCha.EOF then
		if not isnull(vcaCha("Contato")) and instr(vcaCha("Contato")&" ", "_") then
			spl = split(vcaCha("Contato"), "_")
			if spl(0)="3" then
				set pac = db.execute("select id, NomePaciente from pacientes where id="&spl(1))
				if not pac.eof then
					%>
					$("#PacienteID").val("<%=pac("id")%>");
					$("#searchPacienteID").val("<%=pac("NomePaciente")%>");
					parametros('select-PacienteID', <%=pac("id")%>);
					<%
				end if
			end if
		end if
	end if
end if


    if Convenios="Nenhum" then
        %>
        $("#rdValorPlanoV").click();
        <%
    end if
        %>


function dispEquipamento(){
        $.post("agendaParametros.asp?tipo=Equipamento", $("#formAgenda").serialize(), function(data){eval(data);});
    }

$("#EquipamentoID, #Hora, #Data, #Tempo").change(function(){
    dispEquipamento();
})

    $("#btnSendSms").click(function() {
        var licenca = "<%=session("banco")%>";
        var agendamento = $("#ConsultaID").val();
        var celular = $("#ageCel1").val();
        if(celular != ''){
            var txt = prompt("Digite a mensagem do sms:");
            if(txt != null){
                $.post("send_sms_agenda.php",{licenca:licenca,msg:txt,celular:celular,agendamento:agendamento},function(data) {

                });
            }
        }
    });

    function rpti(){
        var d = $("#divRpt");
        var c = $("#rpt");
        if(c.prop("checked")==true){
            d.removeClass("hidden");
        }else{
            d.addClass("hidden");
        }
    }

$("#Repeticao").change(function(){
    Descricao = $("#Repeticao option:selected").attr("data-description");
    $("#rptDescricao").html(Descricao);
    if(Descricao=="semanas"){
        $("#rptDS td").fadeIn();
        $("#rptDM").addClass("hidden");
    }else if(Descricao=="meses"){
        $("#rptDM").removeClass("hidden");
        $("#rptDS td").fadeOut();
    }else{
        $("#rptDS td").fadeOut();
        $("#rptDM").addClass("hidden");
    }
});


<%
if req("ProcedimentoID")<>"" and isnumeric(req("ProcedimentoID")) then
    set proc = db.execute("select id, NomeProcedimento from procedimentos where id="&req("ProcedimentoID"))
    if not proc.eof then
        %>
        $("#searchProcedimentoID").val("<%=proc("NomeProcedimento")%>");
        $("#ProcedimentoID").val("<%=proc("id")%>");
        $("#rdValorPlanoV").click();
        parametros("select-ProcedimentoID", <%=proc("id")%>);
    <%
    end if
end if
%>

function procs(A, I) {
    if(A=='I'){
        I = parseInt($("#nProcedimentos").val())-1;
        $("#nProcedimentos").val( I );
        $.post("procedimentosagenda.asp", { A: A, I: I }, function (data) {
            $('#bprocs').append(data);
        });
    }else if(A=='X'){
        $("#la"+I).remove();
    }
}

<!--#include file="jQueryFunctions.asp"-->
</script>
