<!--#include file="connect.asp"-->
<%
ProcedimentoID = ref("ProcedimentoID")
ProfissionalID = ref("ProfissionalID")
PacienteID = ref("PacienteID")
FormaPagto = req("FormaPagto")'Particular ou Convenio
TabelaID = ref("bageTabela")
ids = ref("ids")
splIds = split(ids, ", ")

for k=0 to ubound(splIds)
    apID = replace(tipo, "ProcedimentoID", "")
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
            if TipoProcedimentoID="9" then
                %>
                //$("#Retorno").prop("checked", true).change();
                <%
            end if
        end if

        if SomenteConvenios<>"" then
            if instr(SomenteConvenios,"|NONE|")>0 then
                SomenteConvenios = replace(SomenteConvenios, "|NONE|","")
            end if
            SomenteConvenios = replace(SomenteConvenios,"|","'")

            if SomenteConvenios<>"" and SomenteConvenios<>"NONE" then
                set ConveniosSQL = db.execute("SELECT NomeConvenio,id FROM convenios WHERE id IN("&SomenteConvenios&")")
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

        sqlProcedimentoTabela = "SELECT ptv.Valor, Profissionais, TabelasParticulares, Especialidades FROM procedimentostabelasvalores ptv INNER JOIN procedimentostabelas pt ON pt.id=ptv.TabelaID WHERE ProcedimentoID="&ProcedimentoID&" AND "&_
        "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&ref("EspecialidadeID")&"|%' ) AND "&_
        "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ref("ProfissionalID")&"|%' ) AND "&_
        "(TabelasParticulares='' OR TabelasParticulares IS NULL OR TabelasParticulares LIKE '%|"&TabelaID&"|%' ) AND "&_
        "(Unidades='' OR Unidades IS NULL OR Unidades LIKE '%|"&UnidadeID&"|%' ) AND "&_
        "pt.Fim>="&mydatenull(ref("Data"))&" AND pt.Inicio<="&mydatenull(ref("Data"))&" AND pt.sysActive=1 AND pt.Tipo='V' "

        ultimoPonto=0

        set ProcedimentoVigenciaSQL = db.execute(sqlProcedimentoTabela)

        while not ProcedimentoVigenciaSQL.eof
            estePonto=0


            if instr(ProcedimentoVigenciaSQL("Profissionais"), "|"&ref("ProfissionalID")&"|")>0 then
                estePonto = estePonto + 1
            end if

            if instr(ProcedimentoVigenciaSQL("TabelasParticulares"), "|"&TabelaID&"|")>0 then
                estePonto = estePonto + 1
            end if

            if instr(ProcedimentoVigenciaSQL("Especialidades"), "|"&ref("EspecialidadeID")&"|")>0 then
                estePonto = estePonto + 1
            end if

            if estePonto>=ultimoPonto then
                Valor=fn(ProcedimentoVigenciaSQL("Valor"))
                procValor = ProcedimentoVigenciaSQL("Valor")
            end if

            ultimoPonto=estePonto

        ProcedimentoVigenciaSQL.movenext
        wend
        ProcedimentoVigenciaSQL.close
        set ProcedimentoVigenciaSQL=nothing

        ValorAgendamento=Valor
		%>
		 $("#Tempo<%= apID %>").val('<%=TempoProcedimento%>');
		 if($("#EquipamentoID<%= apID %>").val() == "" || $("#EquipamentoID<%= apID %>").val() == "0"){
		        $("#EquipamentoID<%= apID %>").val('<%=EquipamentoPadrao%>').change();
             $("#EquipamentoID<%= apID %>").select2();
		 }
		<%
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
                delay: 10000
            });
    		<%
    	end if

    '>ve se ha valor diferenciado e muda o valor
    PontoMaior = 0
    pmTipo = ""
    pmValor = ""
    pmTipoValor = ""

    sqlVarPreco = "select * from("&_
                       "select (if(instr(Procedimentos, '|"&ProcedimentoID&"|'), 0, 1)) PrioridadeProc, t.* from (select * from varprecos WHERE "&_
                       "((Procedimentos='' OR Procedimentos IS NULL)  "&_
                       "OR (Procedimentos LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                       "OR (Procedimentos NOT LIKE '%|"&ProcedimentoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                       "OR (Procedimentos LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|ONLY|%') "&_
                       "OR (Procedimentos NOT LIKE '%|GRUPO_"&GrupoID&"|%' AND Procedimentos LIKE '%|EXCEPT|%') "&_
                       "OR (Procedimentos LIKE '%|ALL|%') "&_
                       ") AND "&_
                       "(Profissionais='' OR Profissionais IS NULL OR Profissionais LIKE '%|"&ref("ProfissionalID")&"|%' ) AND "&_
                       "(Especialidades='' OR Especialidades IS NULL OR Especialidades LIKE '%|"&ref("EspecialidadeID")&"|%' ) AND "&_
                       "(Tabelas='' OR Tabelas IS NULL OR Tabelas LIKE '%|"&TabelaID&"|%' ) AND "&_
                       "(Unidades='' OR Unidades='0' OR Unidades IS NULL OR Unidades LIKE '%|"&UnidadeID&"|%' ) ORDER BY Ordem"&_
                   ") t ) t2 order by PrioridadeProc desc"
    set vcaTab = db.execute(sqlVarPreco)

    while not vcaTab.eof
        'response.Write("//"& sqlVarPreco )
        pmTipo = vcaTab("Tipo")
        pmValor = vcaTab("Valor")
        pmTipoValor = vcaTab("TipoValor")
    vcaTab.movenext
    wend
    vcaTab.close
    set vcaTab=nothing

    if pmTipo="F" then
        ValorAgendamento=pmValor
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
        ValorAgendamento=pmValor
    end if


    if ref("Retorno")="1" then
        'ValorAgendamento=0
    end if

    if not isnull(ValorAgendamento) then
        if isnumeric(ValorAgendamento) then
            %>

             $("#Valor<%= apID %>").val('<%=fn(ValorAgendamento)%>');
             $("#ValorText<%= apID %>").html('<%=fn(ValorAgendamento)%>');
            <%
        end if
    end if

next
%>