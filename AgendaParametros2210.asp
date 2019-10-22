<!--#include file="connect.asp"-->
<%
id = req("id")'variavel de acordo com o tipo
tipo = req("tipo")
ProcedimentoID = ref("ProcedimentoID")
ProfissionalID = ref("ProfissionalID")
PacienteID = ref("PacienteID")
FormaPagto = request.QueryString("FormaPagto")'Particular ou Convenio

if tipo="PacienteID" then
	PacienteID = id
	set pac = db.execute("select * from pacientes where id="&PacienteID&" limit 1")
	if not pac.eof then
		camposPedir = "Tel1, Cel1, Email1"
		if session("banco")="clinic811" then
			camposPedir = "Tel1, Cel1, Email1, Origem"
		end if
		splCamposPedir = split(camposPedir, ", ")
        %>
            $("#select2-PacienteID-container").html("<%=pac("NomePaciente") %>");
        <%
		
		for i=0 to ubound(splCamposPedir)
			if splCamposPedir(i)="Tel1" then
				if pac("Tel1")<>"" and not isnull(pac("Tel1")) then
					%>
					$('#qfagetel1').html('<label for="ageTel1">Telefone</label><br><div class="input-group"><span class="input-group-addon"><i class="fa fa-phone bigger-110"></i></span><input id="ageTel1" class="form-control" type="text" maxlength="150" name="ageTel1" value="<%= pac("Tel1") %>" placeholder=""></div></div>');
					<%
				else
					%>
					$("#ageTel1").val("<%=pac("Tel1")%>");
					<%
				end if
			elseif splCamposPedir(i)="Cel1" then
				if pac("Cel1")<>"" and not isnull(pac("Cel1")) then
					%>
					$('#qfagecel1').html('<label for="ageCel1">Celular</label><br><div class="input-group"><span class="input-group-addon"><i class="fa fa-mobile-phone bigger-110"></i></span><input id="ageCel1" class="form-control" type="text" maxlength="150" name="ageCel1" value="<%= pac("Cel1") %>" placeholder=""></div></div>');
					<%
				else
					%>
					$("#ageCel1").val("<%=pac("Cel1")%>");
					<%
				end if
			else
				%>
				$("#age<%=splCamposPedir(i)%>").val("<%=pac(""&splCamposPedir(i)&"")%>");
				<%
			end if
		next

        %>
        $("#ageTabela").val("<%=pac("Tabela") %>");
        <%
		
		
		
		set conv = db.execute("select * from convenios where id in("&treatvalzero(pac("ConvenioID1"))&", "&treatvalzero(pac("ConvenioID2"))&", "&treatvalzero(pac("ConvenioID3"))&")")
		if not conv.EOF then
			possuiConvenio = "S"
			%>
			$("#divConvenio").show();
			$("#divValor").hide();
			$("#rdValorPlanoP").click();
/*			$("#ConvenioID").val('<%=conv("id")%>');
			$("#searchConvenioID").val("<%=conv("NomeConvenio")%>");
*/
            //to ajax select2
            $("#ConvenioID option").val("<%=conv("id") %>");
            $("#ConvenioID option").text("<%=conv("NomeConvenio") %>");
            $("#ConvenioID").val("<%=conv("id") %>");
            $("#ConvenioID").select2("destroy");
   	        s2aj("ConvenioID", 'convenios', 'NomeConvenio', '', '');
			<%
			if not isnull(conv("RetornoConsulta")) and conv("RetornoConsulta")<>"" and isnumeric(conv("RetornoConsulta")) then
				RetornoConsulta=ccur(conv("RetornoConsulta"))
				if RetornoConsulta>0 then
					'pega o ultimo atendido deste paciente antes de hoje, se houve, ve quantos dias de retorno deste convenio e avisa
					set agendAnt = db.execute("select Data from agendamentos where PacienteID="&PacienteID&" and Data<"&mydatenull(ref("Data"))&" and StaID=3 order by Data desc limit 1")
					if not agendAnt.EOF then
						TempoUltima = datediff("d", agendAnt("Data"), ref("Data"))
						if TempoUltima<=RetornoConsulta then
							%>
							alert('Atenção: Este paciente teve um atendimento com este profissional há <%=TempoUltima%> dia(s). \n A melhor data para retorno de consulta é a partir do dia <%=dateadd("d", RetornoConsulta+1, agendAnt("Data"))%>');
							<%
						end if
					end if
				end if
			end if
		end if
		
		
		
	end if

	if possuiConvenio <> "S" then
		%>
            $("#divConvenio").hide();
            $("#rdValorPlanoV").attr("checked", "checked");
            $("#divValor").show();
			$("#ConvenioID").val('0');
			$("#searchConvenioID").val("");
		<%
	end if
	
	set vcaItemInvoice = db.execute("select ii.ItemID, proc.NomeProcedimento, ii.ValorUnitario+ii.Acrescimo-ii.Desconto Valor FROM itensinvoice ii LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID LEFT JOIN procedimentos proc on proc.id=ii.ItemID WHERE Tipo='S' AND (Executado='' OR isnull(Executado)) AND i.AssociationAccountID=3 AND i.AccountID="&PacienteID&" LIMIT 1")
	if not vcaItemInvoice.EOF then
		%>
		$("#rdValorPlanoV").attr("checked", "checked");
        $("#ProcedimentoID option").text("<%=vcaItemInvoice("NomeProcedimento")%>");
        $("#ProcedimentoID option").val("<%=vcaItemInvoice("ItemID")%>");
        $("#ProcedimentoID").val("<%=vcaItemInvoice("ItemID")%>");
        s2aj("ProcedimentoID", 'procedimentos', 'NomeProcedimento', '');
        $("#Valor").val("<%=formatnumber(vcaItemInvoice("Valor"),2)%>");
		<%
	end if
    if session("Banco")="clinic100000" or session("Banco")="clinic2901" then
        saldo = accountBalance("3_"&PacienteID, 0)
        if saldo<0 then
            %>
            alert('Este paciente possui débitos financeiros. Para mais detalhes, clique na aba \'Conta\'.');
            <%
        end if
    end if
end if
if tipo="ProcedimentoID" then
    TabelaID = ref("ageTabela")
	ProcedimentoID = id
    procValor = 0
	set proc = db.execute("select * from procedimentos where id="&ProcedimentoID)
	if not proc.EOF then
		ObrigarTempo = proc("ObrigarTempo")
		TempoProcedimento = proc("TempoProcedimento")
		Valor = fn(proc("Valor"))
		DiasRetorno = proc("DiasRetorno")
        EquipamentoPadrao = proc("EquipamentoPadrao")
        procValor = proc("Valor")
        SomenteConvenios = proc("SomenteConvenios")
        ConveniosRecarregados = False

        if not isnull(SomenteConvenios) then
            if SomenteConvenios <> "" then
                ConveniosRecarregados = True
                SomenteConvenios = replace(SomenteConvenios,"|","")

                if SomenteConvenios <> "NONE" then
                    set convenios = db.execute("SELECT id,NomeConvenio FROM convenios WHERE sysActive = 1 AND id IN ("&SomenteConvenios&")")

                    %>
                    var val = $("#ConvenioID").val();

                    $("#ConvenioID").html("");
                    var convenios = "<option value=''>Selecione</option>";

                    <%
                    while not convenios.eof
                        %>
                        convenios += "<option value='<%=convenios("id")%>'><%=convenios("NomeConvenio")%></option>";
                        <%
                    convenios.movenext
                    wend
                    convenios.close
                    set convenios=nothing
                    %>
                    $("#ConvenioID").html(convenios).select2();

                    $("#ConvenioID").html(convenios).select2();
                    $("#ConvenioID").val(val).change();

                    <%
                end if
            end if
        end if

        if not ConveniosRecarregados then
            set convenios = db.execute("SELECT id,NomeConvenio FROM convenios")

            %>
            var val = $("#ConvenioID").val();

            $("#ConvenioID").html("");
            var convenios = "<option value=''>Selecione</option>";

            <%
            while not convenios.eof
                %>
                convenios += "<option value='<%=convenios("id")%>'><%=convenios("NomeConvenio")%></option>";
                <%
            convenios.movenext
            wend
            convenios.close
            set convenios=nothing
            %>

            $("#ConvenioID").html(convenios).select2();
            $("#ConvenioID").val(val).change();

            <%
        end if

		%>
		 $("#Valor").val('<%=Valor%>');
		 $("#Tempo").val('<%=TempoProcedimento%>');
		 $("#EquipamentoID").val('<%=EquipamentoPadrao%>');
         $("#EquipamentoID").select2();
		<%
		if PacienteID<>"" and not isnull(DiasRetorno) and isnumeric(DiasRetorno) then
			set agendAnt = db.execute("select Data from agendamentos where PacienteID="&PacienteID&" and Data>"&mydatenull( dateadd("d", DiasRetorno*(-1), ref("Data")) )&" and StaID=3 order by Data desc limit 1")
			if not agendAnt.EOF then
				%>
				alert('Atenção: Este paciente teve um atendimento com este profissional em <%=agendAnt("Data")%>. \n A melhor data para retorno é a partir do dia <%=dateadd("d", DiasRetorno+1, agendAnt("Data"))%>');
				<%
			end if
		end if
	end if
	AvisoAgenda = proc("AvisoAgenda")
	if not isnull(AvisoAgenda) and trim(AvisoAgenda)<>"" then
		%>
		alert('<%=replace(replace(AvisoAgenda, chr(10), "\n"), chr(13), "")%>');
		<%
	end if
    msgEquip = dispEquipamento(ref("Data"), ref("Hora"), ref("Tempo"), EquipamentoPadrao)
    if msgEquip<>"" then
        %>
        alert('<%=msgEquip %>');
        <%
    end if
    '>ve se ha valor diferenciado e muda o valor
    PontoMaior = 0
    pmTipo = ""
    pmValor = ""
    pmTipoValor = ""
    set vcaTab = db.execute("select * from varprecos order by Ordem")
    while not vcaTab.eof
        Queima = 0
        PontosDeste = 0
        vpProcedimentos = vcaTab("Procedimentos")&""
        vpProfissionais = vcaTab("Profissionais")&""
        vpTabelas = vcaTab("Tabelas")&""
        vpUnidades = vcaTab("Unidades")&""
        vpEspecialidades = vcaTab("Especialidades")&""
        vpTipo = vcaTab("Tipo")
        vpValor = vcaTab("Valor")
        vpTipoValor = vcaTab("TipoValor")
        
        'profissionais
        if instr(vpProfissionais, "|"& ProfissionalID &"|")>0 AND vpProfissionais<>"" AND ProfissionalID<>"" AND ProfissionalID<>"0" then
            PontosDeste = PontosDeste + 1
        elseif instr(vpProfissionais, "|"& ProfissionalID &"|")=0 AND vpProfissionais<>"" then
            Queima = 1
        end if

        'tabelas
        if instr(vpTabelas, "|"& TabelaID &"|")>0 AND vpTabelas<>"" AND TabelaID<>"" AND TabelaID<>"0" then
            PontosDeste = PontosDeste + 1
        elseif instr(vpTabelas, "|"& TabelaID &"|")=0 AND vpTabelas<>"" then
            Queima = 1
        end if

        if (instr(vpProcedimentos, "|"& ProcedimentoID &"|")>0 AND instr(vpProcedimentos, "|ONLY|")>0 AND ProcedimentoID<>"" AND ProcedimentoID<>"0") or (instr(vpProcedimentos, "|ALL|")>0) or (instr(vpProcedimentos, "|"& ProcedimentoID &"|")=0 AND instr(vpProcedimentos, "|EXCEPT|")>0) then
            PontosDeste = PontosDeste + 1
        else
            Queima = 1
        end if
        if PontosDeste>PontoMaior and Queima=0 then
            PontoMaior = PontosDeste
            pmTipo = vpTipo
            pmValor = vpValor
            pmTipoValor = vpTipoValor
        end if
    vcaTab.movenext
    wend
    vcaTab.close
    set vcaTab=nothing

    if pmTipo="F" then
        %>
		 $("#Valor").val('<%=fn(pmValor)%>');
        <%
    elseif pmTipo="D" or pmTipo="A" then
        if pmTipoValor="V" then
            pmDescAcre = pmValor
        else
            pmFator = pmValor/100
            pmDescAcre = pmFator * procValor
        end if
        if pmTipo="D" then
            pmValor = procValor - pmDescAcre
        else
            pmValor = procValor + pmDescAcre
        end if
        %>
		 $("#Valor").val('<%=fn(pmValor)%>');
        <%
    end if
    '<
end if

if tipo="Equipamento" then
    msgEquip = dispEquipamento(ref("Data"), ref("Hora"), ref("Tempo"), ref("EquipamentoID"))
    if msgEquip<>"" then
        %>
        alert('<%=msgEquip %>');
        <%
    end if
end if
%>