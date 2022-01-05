<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<%
id = req("id")'variavel de acordo com o tipo
tipo = req("tipo")
ProcedimentoID = ref("ProcedimentoID")
ProfissionalID = ref("ProfissionalID")
PacienteID = ref("PacienteID")
Checkin = ref("Checkin")
ProgramaID = ref("ProgramaID")
ConvenioID = ref("ConvenioID")

function somatempo()
controle = 0
    contador = 0
    variavel = ""
    tracinho = ""
    tempoFinal = 0

       
    While controle = 0
        if contador = 1 then
            variavel = 1
            tracinho= "-"
        end if  
        if contador > 1 then
            variavel = variavel +1
        end if  
        tempoLocal =  ref("Tempo"&tracinho&variavel)
        if tempoLocal = "" then
            controle = 1
        else
            tempoLocal = cint(tempoLocal)
            tempoFinal = tempoFinal + tempoLocal
        end if
        contador = contador +1
    wend

    tempoFinal = tempoFinal&""
    somatempo = tempoFinal 
end function 

ValidarRetornos=getConfig("ValidarRetornos")
FormaPagto = req("FormaPagto")'Particular ou Convenio
ProcedimentoTempoProfissional = req("ProcedimentoTempoProfissional")

hide = "true"
if getConfig("NaoRemoverAvisos")=1 then
    hide = "false"
end if

function getTempoProcedimento(procedimentoId, profissionalID)

        
ProcedimentoTempoProfissionalSQL =  ""&_
" SELECT COALESCE(t.TempoProf, p.TempoProcedimento) Tempo                                                                     "&chr(13)&_
" FROM procedimentos p                                                                                                        "&chr(13)&_
" LEFT JOIN                                                                                                                   "&chr(13)&_
" (                                                                                                                           "&chr(13)&_
" SELECT ptp.tempo TempoProf, proc.id                                                                                         "&chr(13)&_
" FROM procedimentos proc                                                                                                     "&chr(13)&_
" INNER JOIN procedimento_tempo_profissional ptp ON proc.id=ptp.ProcedimentoID                                                "&chr(13)&_
" WHERE proc.Id ="&treatvalzero(procedimentoId)&" AND ptp.profissionalId = "&treatvalzero(profissionalID)&") t ON t.id = p.id  "&chr(13)&_
" WHERE p.id="&treatvalzero(procedimentoId)                                                          

        set ProcedimentoTempoProfissional= db.execute(ProcedimentoTempoProfissionalSQL)
 
        if not ProcedimentoTempoProfissional.eof then
            getTempoProcedimento = ProcedimentoTempoProfissional("tempo")
        end if
end function

 if ProcedimentoTempoProfissional = "true" then
    tempoPorProfissional = getTempoProcedimento(req("idProcedimento"), req("idProfissional"))

    if tempoPorProfissional="" then
        response.write("{}")
        response.end
    end if

    response.ContentType = "application/json"

    response.write("{""tempo"":"&ProcedimentoTempoProfissional("tempo")&"}")   
    response.end
end if

if tipo="PacienteID" then
	PacienteID = id

	if PacienteID="-1" then
	    Response.End
	end if

    QuantidadeFaltasPagtoPrevio = getConfig("QuantidadeFaltasPagtoPrevio")&""
    if isnumeric(QuantidadeFaltasPagtoPrevio) then
        QuantidadeFaltasPagtoPrevio = ccur(QuantidadeFaltasPagtoPrevio)
        if QuantidadeFaltasPagtoPrevio>0 then
            set contaFaltas = db.execute("select IFNULL(count(*),0) Faltas from agendamentos where PacienteID="& PacienteID &" And StaID=6")
            Faltas = ccur(contaFaltas("Faltas"))
            if Faltas>=QuantidadeFaltasPagtoPrevio then
                %>
                alert("ATENÇÃO: ESTE PACIENTE NÃO COMPARECEU <%= Faltas%> VEZES. SOLICITA-SE O PAGAMENTO ANTECIPADO.");
                <%
            end if
        end if
    end if


	set pac = db.execute("select * from pacientes where id="&PacienteID&" limit 1")
	if not pac.eof then
        LembrarPendencias = pac("lembrarPendencias")
        Pendencias = pac("Pendencias")

		camposPedir = "Tel1, Cel1, Email1"
		if session("banco")="clinic811" or session("banco")="clinic5445" then
			camposPedir = "Tel1, Cel1, Email1, Origem"
		end if

		set CamposPedirConfigSQL = db.execute("SELECT * FROM obrigacampos WHERE Recurso='Agendamento'")

        if not CamposPedirConfigSQL.eof then
            camposPedir= "Tel1, Cel1, Email1, " & replace(CamposPedirConfigSQL("Exibir"),"|","")
        end if

		splCamposPedir = split(camposPedir, ", ")
        %>
            $("#select2-PacienteID-container").html("<%=pac("NomePaciente") %>");
        <%
		
		for i=0 to ubound(splCamposPedir)
			if splCamposPedir(i)="Tel1" then
				if pac("Tel1")<>"" and not isnull(pac("Tel1")) then
					%>
					$('#qfagetel1').html('<label for="ageTel1">Telefone</label><br><div class="input-group"><span class="input-group-addon"><i class="far fa-phone bigger-110"></i></span><input id="ageTel1" class="form-control" type="text" maxlength="150" name="ageTel1" value="<%= pac("Tel1") %>" placeholder=""></div></div>');
					<%
				else
					%>
					$("#ageTel1").val("<%=pac("Tel1")%>");
					<%
				end if
			elseif splCamposPedir(i)="Cel1" then
				if pac("Cel1")<>"" and not isnull(pac("Cel1")) then
					%>
					if($('#qfagecel1').length > 0){
					    $('#qfagecel1').html('<label for="ageCel1">Celular</label><br><div class="input-group"><span class="input-group-addon"><i class="far fa-mobile-phone bigger-110"></i></span><input id="ageCel1" class="form-control" type="text" maxlength="150" name="ageCel1" value="<%= pac("Cel1") %>" placeholder=""></div></div>');
					}else{
					    $("#ageCel1").val("<%=pac("Cel1")%>");
					}
					<%
				else
					%>
					$("#ageCel1").val("<%=pac("Cel1")%>");
					<%
				end if
			elseif splCamposPedir(i)&""<>"" then

			    if splCamposPedir(i)<>"IndicadoPorSelecao" then
				%>
				$("#age<%=splCamposPedir(i)%>").val("<%=pac(""&splCamposPedir(i)&"")%>");
				<%
				end if
			end if
		next

        %>
        $("#ageTabela, #bageTabela").val("<%=pac("Tabela") %>");
        <%

        'verifica se tem agendamento pra retorno
        if PacienteID<>"" then
            set AgendamentoParaRetornoSQL = db.execute("SELECT age.id FROM agendamentos age INNER JOIN procedimentos proc ON proc.id=age.TipoCompromissoID WHERE ProfissionalID="&treatvalzero(ref("ProfissionalID"))&" AND PacienteID="&PacienteID&" AND StaID IN (3) AND DATEDIFF("&mydatenull(ref("Data"))&", age.Data) BETWEEN 1 AND proc.DiasRetorno and proc.DiasRetorno>0")
            if not AgendamentoParaRetornoSQL.eof then

                %>
                //$("#Retorno").prop("checked", true).change();
                <%
            end if
        end if


        'verifica se o paciente tem algum aviso ou pendencia na ficha e exibe no agendamento caso esteja com a opção de sinalizar
		if LembrarPendencias="S" AND not isnull(Pendencias) AND trim(Pendencias)<>"" AND getConfig("AvisosPendenciasProntuario")=1 then
            %>
            new PNotify({
                title: 'AVISOS E PENDÊNCIAS',
                text: '<%=replace(replace(Pendencias, chr(10), "\n"), chr(13), "")%>',
                sticky: true,
                type: 'warning',
                hide: <%=hide%>,
                delay: 10000
            });
            <%
        end if

        set conv = db.execute("select id,NomeConvenio,RetornoConsulta, Prioridade FROM ( "&_
                              "select id,NomeConvenio,RetornoConsulta, 1 Prioridade FROM convenios WHERE id="&treatvalzero(pac("ConvenioID1"))&" "&_
                              "UNION ALL "&_
                              "select id,NomeConvenio,RetornoConsulta, 2 Prioridade FROM convenios WHERE id="&treatvalzero(pac("ConvenioID2"))&" "&_
                              "UNION ALL "&_
                              "select id,NomeConvenio,RetornoConsulta, 3 Prioridade FROM convenios WHERE id="&treatvalzero(pac("ConvenioID3"))&" "&_
                              ")conv "&_
                              "ORDER BY Prioridade")

		if not conv.EOF then
			QueryGradeSQL = "SELECT Convenios FROM assperiodolocalxprofissional WHERE ProfissionalID="&treatvalzero(ProfissionalID)
            set GradeSQL = db.execute(QueryGradeSQL)
            conveniosGrade = ""
            if not GradeSQL.eof then
                conveniosGrade = GradeSQL("Convenios")
            else
                QueryGradeSQL = "SELECT Convenios FROM assfixalocalxprofissional WHERE ProfissionalID="&treatvalzero(ProfissionalID)
                set GradeSQL = db.execute(QueryGradeSQL)
                if not GradeSQL.eof then
                    conveniosGrade = GradeSQL("Convenios")
                end if
            end if
            if conveniosGrade <> "" then
                while not GradeSQL.eof
                    if instr(conveniosGrade, conv("id")) > 0 then
                        possuiConvenio = "S"
                    end if
                    GradeSQL.movenext
                wend
                GradeSQL.close
                set GradeSQL = nothing
            else
                possuiConvenio = "S"
            end if

			ObsConvenios = ""
            set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&conv("id")&"")
            if not ConvenioSQL.eof then

                 planosOptions = getPlanosOptions(conv("id"), pac("PlanoID"&conv("Prioridade")))

                 if planosOptions<>"" then
                    %>
                        $(document).ready(function() {
                            $("#divConvenioPlano").remove();
                            $("#divConvenio").after("<%=planosOptions%>");

                            $("#PlanoID").select2();
                        })
                    <%
                end if

                ObsConvenio = ConvenioSQL("Obs")

                if ObsConvenio&""<>"" then
                %>
                var btnObs = '<button title="Observações do convênio" id="ObsConvenios" style="z-index: 99;position: absolute;left:-16px" class="btn btn-system btn-xs" type="button" onclick="ObsConvenio(<%=conv("id")%>)"><i class="far fa-align-justify"></i></button>';
                $("#ConvenioID").before(btnObs);
                <%
                end if
            end if
			%>
			$("#divConvenio").show();
			$("#divValor").hide();
			$("#rdValorPlanoP").click();
/*			$("#ConvenioID").val('<%=conv("id")%>');
			$("#searchConvenioID").val("<%=conv("NomeConvenio")%>");
*/
            $("#ConvenioID").html('');
            var optionExists = ($('#ConvenioID option[value=' + <%=conv("id") %> + ']').length > 0);

            if(!optionExists)
            {
                $('#ConvenioID').append("<option value='<%=conv("id") %>'><%=conv("NomeConvenio") %></option>");
            }
            
            //to ajax select2
            //$("#ConvenioID option").val("<%=conv("id") %>");
            //$("#ConvenioID option").text("<%=conv("NomeConvenio") %>");
            $("#ConvenioID").val("<%=conv("id") %>").trigger('change').select2();

            if($("#ConvenioID").length > 0){
                $("#ConvenioID").select2("destroy");
            }
   	        s2aj("ConvenioID", 'convenios', 'NomeConvenio', '', '');
			<%
			if not isnull(conv("RetornoConsulta")) and conv("RetornoConsulta")<>"" and isnumeric(conv("RetornoConsulta")) then
				RetornoConsulta=conv("RetornoConsulta")
				if RetornoConsulta>0 then
					'pega o ultimo atendido deste paciente antes de hoje, se houve, ve quantos dias de retorno deste convenio e avisa
					set agendAnt = db.execute("select Data from agendamentos where PacienteID="&PacienteID&" and Data<"&mydatenull(ref("Data"))&" and ProfissionalID="&treatvalzero(ProfissionalID)&" and StaID=3 order by Data desc limit 1")
					if not agendAnt.EOF then

                        DataAgendamento = replace(mydatenull(ref("Data")), "'", "")
                        DataAgendamentoAnterior = replace(mydatenull(agendAnt("Data")), "'", "")
						TempoUltima = datediff("d", DataAgendamentoAnterior, DataAgendamento)

						if TempoUltima<=RetornoConsulta then
							%>

                            new PNotify({
                                title: 'ALERTA!',
                                text: 'Atenção: Este paciente teve um atendimento com este profissional há <%=TempoUltima%> dia(s). \n A melhor data para retorno de consulta é a partir do dia <%=dateadd("d", RetornoConsulta+1, DataAgendamentoAnterior)%>.',
                                type: 'warning',
                                delay: 10000
                            });
							<%
						end if
					end if
				end if
			end if
		end if
		
		
		
	end if

	if possuiConvenio <> "S" then
		%>
            $("#divConvenio, #divConvenioPlano").hide();
            $("#rdValorPlanoV").attr("checked", "checked");
            $("#divValor").show();
			$("#ConvenioID").val('0');
			$("#searchConvenioID").val("");
		<%
	end if

    if getConfig("ProcedimentosContratadosParaSelecao")&"" <> "1" then
        set vcaItemInvoice = db.execute("select ii.ItemID, proc.NomeProcedimento, ii.ValorUnitario+ii.Acrescimo-ii.Desconto Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN procedimentos proc on proc.id=ii.ItemID WHERE Tipo='S' AND (Executado='' OR isnull(Executado)) AND i.AssociationAccountID=3 AND i.AccountID="&PacienteID&" LIMIT 1")

        if not vcaItemInvoice.EOF then
            %>
            $("#ProcedimentoID option").text("<%=vcaItemInvoice("NomeProcedimento")%>");
            $("#ProcedimentoID option").val("<%=vcaItemInvoice("ItemID")%>");
            $("#ProcedimentoID").val("<%=vcaItemInvoice("ItemID")%>");
            $("#Valor").val("<%=formatnumber(vcaItemInvoice("Valor"),2)%>");
            s2aj("ProcedimentoID", 'procedimentos', 'NomeProcedimento', '','','agenda');
            $("#rdValorPlanoV").click();
            <%
        end if
	end if

    if session("Banco")="clinic100000" or session("Banco")="clinic2901" or session("Banco")="clinic5355" or session("Banco")="clinic105" or session("Banco")="clinic5583" or session("Banco")="clinic5968" or session("Banco")="clinic5710" or session("Banco")="clinic5563" then
        saldo = accountBalance("3_"&PacienteID, 0)

        BoletoAberto=False
        if recursoAdicional(24)=4 then
            sqlBoleto = "SELECT  coalesce(sum(now() > boletos_emitidos.DueDate and StatusID <> 3),0) as vencido"&_
                                                            "       ,coalesce(sum(boletos_emitidos.DueDate > now() and StatusID = 1),0) as aberto"&_
                                                            "       ,coalesce(sum(StatusID  = 3),0) as pago"&_
                                                            " FROM sys_financialinvoices"&_
                                                            " JOIN boletos_emitidos ON boletos_emitidos.InvoiceID = sys_financialinvoices.id"&_
                                                            " WHERE TRUE"&_
                                                            " AND sys_financialinvoices.AccountID ="&PacienteID&" "&_
                                                            " AND sys_financialinvoices.AssociationAccountID = 3;"
            'response.write(sqlBoleto)
            set getBoletos = db.execute(sqlBoleto)
            if not getBoletos.eof then
                if getBoletos("aberto") = "0" then
                    BoletoAberto=True
                end if
            end if
        else
            BoletoAberto=True
        end if


        BloquearSalvar=False
        mensagemDebitoFinanceiro = "Este paciente possui débitos financeiros. Para mais detalhes, clique na aba \'Conta\'."

        if saldo>=0 and (session("Banco")="clinic5355" or session("Banco")="clinic100000" or session("Banco")="clinic105" or session("Banco")="clinic4421" or session("Banco")="clinic5968") then
            'aqui verifica se os relativos estão devendo, os responsaveis
            set PacientesRelativosSQL = db.execute("SELECT * FROM pacientesrelativos WHERE NomeID > 0 AND Dependente='S' AND PacienteID="&PacienteID)

            while not PacientesRelativosSQL.eof
                saldoRelativo = accountBalance("3_"&PacientesRelativosSQL("NomeID"), 0)
                if saldoRelativo < 0 then
                    BloquearSalvar = True
                    mensagemDebitoFinanceiro = "O relativo \'"&PacientesRelativosSQL("Nome")&"\' deste paciente possui débitos financeiros."
                    saldo = saldoRelativo
                end if
            PacientesRelativosSQL.movenext
            wend
            PacientesRelativosSQL.close
            set PacientesRelativosSQL=nothing

        end if

        if saldo<0 AND  BoletoAberto then
            %>

            new PNotify({
                title: 'ALERTA!',
                text: '<%=mensagemDebitoFinanceiro%>',
                type: 'danger',
                delay: 7000
            });

            <%
            if BloquearSalvar then
                %>
                $("#btnSalvarAgenda").attr("disabled", true);
                <%
            end if
        end if
    end if

    ' altera as opções do select de Programas de Saúde
    if getConfig("ExibirProgramasDeSaude") = 1 then 
    %> 
    $("#ProgramaID").html(`<%=getProgramasOptions(ProfissionalID, PacienteID, ConvenioID, ProgramaID)%>`);
    <% end if

end if
if left(tipo, 14)="ProcedimentoID" then
    apID = replace(tipo, "ProcedimentoID", "")
    TabelaID = ref("ageTabela")
	ProcedimentoID = id
    procValor = 0

    if ProcedimentoID="" then
        Response.End
    end if
	set proc = db.execute("select * from procedimentos where id="&ProcedimentoID)
	if not proc.EOF then
		ObrigarTempo = proc("ObrigarTempo")
		GrupoID = proc("GrupoID")
		TempoProcedimento = proc("TempoProcedimento")
		Valor = fn(proc("Valor"))
		DiasRetorno = proc("DiasRetorno")
        EquipamentoPadrao = proc("EquipamentoPadrao")
        procValor = proc("Valor")
        SomenteConvenios = proc("SomenteConvenios")
        TipoProcedimentoID = proc("TipoProcedimentoID")

        if not isnull(TipoProcedimentoID) then
            if ValidarRetornos="1" then
                if TipoProcedimentoID="9" then
                    %>
                    $("#Retorno").prop("checked", true).change();
                    <%
                else
                    %>
                    $("#Retorno").prop("checked", false).change();
                    <%
                end if
            end if
        end if

        if SomenteConvenios<>"" then
            if instr(SomenteConvenios,"|NONE|")>0 then
                SomenteConvenios = replace(SomenteConvenios, "||NONE||","")
                SomenteConvenios = replace(SomenteConvenios, "|NONE|","")
            end if
            
            if instr(SomenteConvenios,"|NOTPARTICULAR|")>0 then
                SomenteConvenios = replace(SomenteConvenios, "||NOTPARTICULAR||","")
                SomenteConvenios = replace(SomenteConvenios, "|NOTPARTICULAR|","")
            end if

            SomenteConvenios = replace(SomenteConvenios,"|","'")
            SomenteConvenios = replace(SomenteConvenios,"''", "'")

            if SomenteConvenios<>"" and SomenteConvenios<>"NONE" then
                SomenteConvenios = fix_array_comma(SomenteConvenios)
                set ConveniosSQL = db.execute("SELECT NomeConvenio,id FROM convenios WHERE id IN("&SomenteConvenios&") AND sysActive=1 AND Ativo='on'")
                %>
                if($("#ConvenioID<%= apID %>").length > 0){
                    $("#ConvenioID<%= apID %>").select2("destroy");
                }
                <%
                optionsConvenio = "<option value=''>Selecione</option>"
                while not ConveniosSQL.eof
                    optionsConvenio = optionsConvenio & "<option value='"&ConveniosSQL("id")&"'>"&ConveniosSQL("NomeConvenio")&"</option>"
                ConveniosSQL.movenext
                wend
                ConveniosSQL.close
                set ConveniosSQL=nothing
                %>
                var ConvenioIDSelecionado = $("#ConvenioID<%= apID %>").val();

                $("#ConvenioID<%= apID %>").html("<%=optionsConvenio%>").val(ConvenioIDSelecionado);
                $("#ConvenioID<%= apID %>").select2();
                <%
            end if
        end if

        UnidadeID=0
        set LocalSQL = db.execute("SELECT UnidadeID FROM locais WHERE id="&treatvalzero(ref("LocalID")))
        if not LocalSQL.eof then
            UnidadeID=LocalSQL("UnidadeID")
        end if

        ValorAgendamento = calcValorProcedimento(ProcedimentoID, TabelaID, UnidadeID, ref("ProfissionalID"), ref("EspecialidadeID"), GrupoID, 0)
		if Checkin&"" <> "1" then 

        tempoProcedimento = getTempoProcedimento(procedimentoId, profissionalID)
        
        %>
		 $("#Tempo<%= apID %>").val('<%=TempoProcedimento%>');
		 if($("#EquipamentoID<%= apID %>").val() == "" || $("#EquipamentoID<%= apID %>").val() == "0"){
		        $("#EquipamentoID<%= apID %>").val('<%=EquipamentoPadrao%>').change();
             $("#EquipamentoID<%= apID %>").select2();
		 }
		<%
        end if
		if PacienteID<>"" and not isnull(DiasRetorno) and isnumeric(DiasRetorno) then
			set agendAnt = db.execute("select Data from agendamentos where PacienteID="&PacienteID&" and Data>"&mydatenull( dateadd("d", DiasRetorno*(-1), ref("Data")) )&" AND EspecialidadeID="&treatvalnull(ref("EspecialidadeID"))&" AND TipoCompromissoID="&ProcedimentoID&" and StaID=3 order by Data desc limit 1")
			if not agendAnt.EOF then
				%>

                new PNotify({
                    title: 'ATENÇÃO!',
                    text: 'Este paciente teve um atendimento em <%=agendAnt("Data")%>. \n A melhor data para retorno é a partir do dia <%=dateadd("d", DiasRetorno+1, agendAnt("Data"))%>',
                    type: 'warning',
                    delay: 10000
                });
				<%
			end if
		end if
	end if
	AvisoAgenda = proc("AvisoAgenda")
	if not isnull(AvisoAgenda) and trim(AvisoAgenda)<>"" then
		%>

        new PNotify({
            title: 'ALERTA!',
            text: '<%=replace(replace(AvisoAgenda, chr(10), "\n"), chr(13), "")%>',
            type: 'dark',
            hide: <%=hide%>,
            delay: 10000
        });
		<%
	end if

	TextoPreparo = proc("TextoPreparo")
    	if not isnull(TextoPreparo) and trim(TextoPreparo)<>"" then
    	    TextoPreparo=replace(TextoPreparo, "'","")
    		%>

            new PNotify({
                title: 'PREPARO:',
                text: '<%=replace(replace(TextoPreparo, chr(10), "\n"), chr(13), "")%>',
                type: 'warning',
                hide: <%=hide%>,
                delay: 10000
            });
    		<%
    	end if

    '>ve se ha valor diferenciado e muda o valor
    PontoMaior = 0
    pmTipo = ""
    pmValor = ""
    pmTipoValor = ""


    if ref("Retorno")="1" then
        'ValorAgendamento=0
    end if

    if not isnull(ValorAgendamento) then
        if isnumeric(ValorAgendamento) then
            %>
             let pacote = $("#ProcedimentoID<%= apID %>").parent().parent().attr("data-pacote")
             if (!pacote || pacote == undefined ) {
                $("#Valor<%= apID %>").val('<%=fn(ValorAgendamento)%>');
                $("#ValorText<%= apID %>").html('<%=fn(ValorAgendamento)%>');
             }
             somarValores();
             dispEquipamento();
            <%
        end if
    end if

    ' altera as opções do select de Programas de Saúde
    if getConfig("ExibirProgramasDeSaude") = 1 then 
    %> 
    $("#ProgramaID").html(`<%=getProgramasOptions(ProfissionalID, PacienteID, ConvenioID, ProgramaID)%>`);
    <% end if
end if

if tipo="Equipamento" then

    tempoFinal = somatempo()

    ProcedimentosAgendamento = trim(ref("ProcedimentosAgendamento"))
    if ProcedimentosAgendamento<>"" then
        if (Mid(ProcedimentosAgendamento,Len(ProcedimentosAgendamento),1) = ",") then
        ProcedimentosAgendamento = Mid(ProcedimentosAgendamento,1,Len(ProcedimentosAgendamento)-1)
        end if
        ProcedimentosAgendamento = replace(ProcedimentosAgendamento, ", ,", ", ")
        splPA = split(ProcedimentosAgendamento, ", ")
        for iPA=0 to ubound(splPA)
            if splPA(iPA)&""<>"" then
                apID = ccur( splPA(iPA) )
                apEquipamentoID = "EquipamentoID"&apID
                apTipoCompromissoID = ref("ProcedimentoID"&apID)
                set EquipamentoPadraoSQL = db.execute("SELECT * FROM procedimentos WHERE id="&apTipoCompromissoID)
                if not EquipamentoPadraoSQL.eof then
                    EquipamentoPadrao = EquipamentoPadraoSQL("EquipamentoPadrao")
                    msgEquip = dispEquipamento(ref("Data"), ref("Hora"), tempoFinal, EquipamentoPadrao, ref("ConsultaID"))
                    if msgEquip<>"" then
                        %>
                        new PNotify({
                            title: 'EQUIPAMENTO EM USO!',
                            text: '<%=msgEquip %>',
                            type: 'danger',
                            delay: 3000,
                            icon: 'fa fa-times'
                        });
                        $("#btnSalvarAgenda").attr("disabled", true);
                        <%
                    else

                        %>
                        if('<%=apEquipamentoID%>' != ''){
                            $("#<%=apEquipamentoID%>").val('<%=EquipamentoPadrao%>').change();
                            $("#<%=apEquipamentoID%>").select2();
                        }
                        btnSalvarToggleLoading(true);
                        <%
                    end if
                end if
            end if
        next

    else
        msgEquip = dispEquipamento(ref("Data"), ref("Hora"), tempoFinal, ref("EquipamentoID"), ref("ConsultaID"))
        if msgEquip<>"" then
            %>
            new PNotify({
                title: 'EQUIPAMENTO EM USO!',
                text: '<%=msgEquip %>',
                type: 'danger',
                delay: 3000,
                icon: 'fa fa-times'
            });
            $("#btnSalvarAgenda").attr("disabled", true);
            <%
        else
            %>
            btnSalvarToggleLoading(true);
            <%
        end if
    end if
end if

if left(tipo, 10)="ConvenioID" then
    apID = replace(tipo, "ConvenioID", "")
    ConvProc = split(req("id"),"_")
    ConvenioID = ConvProc(0)

    if ubound(ConvProc) > 0 then
        ProcedimentoID = ConvProc(1)
    end if

    set ConvenioSQL = db.execute("SELECT Obs FROM convenios WHERE id="&ConvenioID)
    if not ConvenioSQL.eof then

         planosOptions = getPlanosOption(ConvenioID, PlanoID, apID)

        %>
            $("#divConvenioPlano<%=apID%>").remove();
        <%
         if planosOptions<>"" then

            %>
            $("#divConvenio<%=apID%>").after("<%=planosOptions%>");
            $("#PlanoID<%=apID%>").select2();
            <%
        end if
        ObsConvenio = ConvenioSQL("Obs")

        if ObsConvenio&""<>"" then
            %>
            var btnObs = '<button title="Observações do convênio" id="ObsConvenios<%=apID%>" style="z-index: 99;position: absolute;left:-16px" class="btn btn-system btn-xs" type="button" onclick="ObsConvenio(<%=ConvenioID%>)"><i class="far fa-align-justify"></i></button>';
            $("#ConvenioID<%=apID%>").before(btnObs);
            <%
        else
            %>
            $("#ObsConvenios<%=apID%>").remove();
            <%
        end if
    else
        %>
        $("#ObsConvenios<%=apID%>").remove();
        <%
    end if

    ' altera as opções do select de Programas de Saúde
    if getConfig("ExibirProgramasDeSaude") = 1 then 
    %> 
    $("#ProgramaID").html(`<%=getProgramasOptions(ProfissionalID, PacienteID, ConvenioID, ProgramaID)%>`);
    <% end if


    if session("Banco")="clinic100000" or session("Banco")="clinic5304" then
        set PlanosQueCobreSQL = db.execute("SELECT cp.NomePlano, IF(pvp.NaoCobre is null or pvp.NaoCobre = '', 1,0)Cobre FROM conveniosplanos cp LEFT JOIN tissprocedimentosvalores pv ON pv.ConvenioID = cp.id LEFT JOIN tissprocedimentosvaloresplanos pvp ON pvp.AssociacaoID = pv.id WHERE cp.ConvenioID = "&ConvenioID&" GROUP BY cp.id")
        'response.write("SELECT cp.NomePlano, IF(pvp.NaoCobre is null or pvp.NaoCobre = '', 1,0)Cobre FROM conveniosplanos cp LEFT JOIN tissprocedimentosvalores pv ON pv.ConvenioID = cp.id LEFT JOIN tissprocedimentosvaloresplanos pvp ON pvp.AssociacaoID = pv.id WHERE pv.ProcedimentoID="&ProcedimentoID&" AND cp.ConvenioID = "&ConvenioID&" GROUP BY cp.id")
        PlanosQueCobre = ""
        if not PlanosQueCobreSQL.eof then
                while not PlanosQueCobreSQL.eof
                    if not isnull(PlanosQueCobreSQL("Cobre")) and PlanosQueCobreSQL("Cobre")<>"" then
                        if PlanosQueCobreSQL("Cobre")&""="1" then
                            if PlanosQueCobre="" then
                                PlanosQueCobre = PlanosQueCobreSQL("NomePlano")
                            else
                                PlanosQueCobre = PlanosQueCobre & "<br> "&PlanosQueCobreSQL("NomePlano")
                            end if
                        end if
                    end if
                PlanosQueCobreSQL.movenext
                wend
                PlanosQueCobreSQL.close
                set PlanosQueCobreSQL=nothing

            if(PlanosQueCobre<>"") then
                %>

                <%
            else
            %>
                $(".aviso-planos").remove();
            <%
            end if
        else
            %>
                $(".aviso-planos").remove();
            <%
        end if
    end if
end if

if tipo="ProgramaID" then
    sqlPrograma = "SELECT ConvenioID FROM programas WHERE id = '" & ProgramaID & "' AND ConvenioID IS NOT NULL"
    set rsPrograma = db.execute(sqlPrograma)
    if not rsPrograma.eof then
%>
        $("#ConvenioID").val("<%=rsPrograma("ConvenioID")%>").select2();
<%
    end if
end if



function getPlanosOption(ConvenioID, PlanoID, CampoID)
    set PlanosConvenioSQL = db.execute("SELECT NomePlano, id FROM conveniosplanos WHERE sysActive=1 and NomePlano!='' and ConvenioID="&ConvenioID)
    if not PlanosConvenioSQL.eof then

        planosOption="<option value=''>Selecione</option>"

        while not PlanosConvenioSQL.eof
            planoSelected = ""
            if PlanoID=PlanosConvenioSQL("id") then
                planoSelected=" selected "
            end if

            planosOption= planosOption&"<option "&planoSelected&" value='"&PlanosConvenioSQL("id")&"'>"&PlanosConvenioSQL("NomePlano")&"</option>"
        PlanosConvenioSQL.movenext
        wend
        PlanosConvenioSQL.close
        set PlanosConvenioSQL=nothing

        getPlanosOption = "<div id='divConvenioPlano"&CampoID&"' class='col-md-12 mt5' ><label for='PlanoID"&CampoID&"'>Plano</label><select name='PlanoID"&CampoID&"' id='PlanoID"&CampoID&"' class='form-control'>"& planosOption &"</select></div>"
    else
        getPlanosOption=""
    end if
end function

function getProgramasOptions(ProfissionalID, PacienteID, ConvenioID, ProgramaID)
    sqlProgramas = "SELECT p.id, p.NomePrograma FROM programas p " &_
                   "INNER JOIN profissionaisprogramas pop ON pop.ProgramaID = p.id " &_
                   "LEFT JOIN pacientesprogramas pap ON pap.ProgramaID = p.id " &_
                   "WHERE p.sysActive = 1 AND pop.ProfissionalID = '" & ProfissionalID & "' AND pop.sysActive = 1 "

    if PacienteID <> "" then
        sqlProgramas = sqlProgramas & " AND pap.PacienteID = '" & PacienteID & "' AND pap.sysActive = 1 "
    end if

    if ConvenioID&"" <> "" and ConvenioID&"" <> "0" then
        sqlProgramas = sqlProgramas & " AND (p.ConvenioID IS NULL OR p.ConvenioID = '" & ConvenioID & "') "
    end if

    sqlProgramas = sqlProgramas & " GROUP BY p.id"

    set rsProgramasOptions = db.execute(sqlProgramas)
    if  rsProgramasOptions.eof then
        getProgramasOptions = ""
    else
        programsOptions = "<option value=''>Selecione</option>"
        while not rsProgramasOptions.eof
            progSelected = ""
            if ProgramaID=rsProgramasOptions("id")&"" then
                progSelected = " selected "
            end if
            programsOptions = programsOptions & "<option" & progSelected & " value='" & rsProgramasOptions("id") & "'>" & rsProgramasOptions("NomePrograma") & "</option>"
            rsProgramasOptions.movenext
        wend
        getProgramasOptions=programsOptions
    end if
    rsProgramasOptions.close
    set rsProgramasOptions=nothing

end function

%>