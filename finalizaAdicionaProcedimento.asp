<!--#include file="connect.asp"-->
<!--#include file="Classes/ValorProcedimento.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%
Acao = req("Acao")
AssociacaoID = null
Row = req("Row")
if Row<>"" then
	Row=ccur(Row)
end if

BaixaItensNaoPagosAoFinalizarAtendimento=getConfig("BaixaItensNaoPagosAoFinalizarAtendimento")
PlanoID = null
AtendimentoID = req("AtendimentoID")
PermitirInformarProcedimentos = getConfig("PermitirInformarProcedimentos")

IF AtendimentoID > "0" AND AtendimentoID<>"N" THEN
    set AtendimentoSQL = db.execute("select at.AgendamentoID ,ap.*, p.NomeProcedimento, p.SolIC, p.TipoProcedimentoID, p.Valor, at.PacienteID,agendamentos.PlanoID from atendimentosprocedimentos as ap left join procedimentos as p on p.id=ap.ProcedimentoID INNER join atendimentos as at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ON AgendamentoID = agendamentos.id where AtendimentoID="&AtendimentoID)
    if not AtendimentoSQL.eof then
        PlanoID = AtendimentoSQL("PlanoID")
        AgendamentoID = AtendimentoSQL("AgendamentoID")
    end if
END IF

IF Acao = "X" THEN

    db.execute("DELETE FROM calculos_finalizar_atendimento_log where AtendimentoProcedimentoID="&req("ProcedimentoID")&" OR (id*-1) = "&req("ProcedimentoID"))

    IF getConfig("calculostabelas") THEN
        recalcularEscalonamentoAtendimento(AtendimentoID)

        set linhaRegistro = db.execute("SELECT calculos_finalizar_atendimento_log.*,COALESCE(AtendimentoProcedimentoID,CONCAT(calculos_finalizar_atendimento_log.id*-1,'')) as id,p.SolIC,p.Obs,p.NomeProcedimento, p.SolIC, p.TipoProcedimentoID, p.Valor,NomeConvenio FROM  calculos_finalizar_atendimento_log left join procedimentos as p on p.id=calculos_finalizar_atendimento_log.ProcedimentoID LEFT JOIN  convenios ON convenios.id = calculos_finalizar_atendimento_log.CalculoConvenioID WHERE AtendimentoID ="&AtendimentoID&" ORDER by fator DESC ;")

        while not linhaRegistro.eof
      		Icone            = "credit-card"
        	NomeProcedimento = linhaRegistro("NomeProcedimento")
        	NomeForma        = linhaRegistro("NomeConvenio")
            Fator            = linhaRegistro("Fator")
            Obs              = linhaRegistro("Obs")
            SolIC            = linhaRegistro("SolIC")
            ValorFinal       = linhaRegistro("ValorTotal")
            id               = linhaRegistro("id")
        %>
           <!--#include file="apLinhaItem.asp"-->
        <%
        linhaRegistro.movenext
        wend
        linhaRegistro.close
        set linhaRegistro=nothing
    END IF

    response.end
END IF

if Acao="I" then
	ProcedimentoID = req("ProcedimentoID")
	ConvenioID = req("ConvenioID")
	ValorBruto = req("ValorBruto")

	if ValorBruto="" then
	    ValorBruto=0
	end if

	ValorBruto = ccur(ValorBruto)

	Fator = 1
    id = (Row+1)*(-1)

	set proc = db.execute("select NomeProcedimento, TipoProcedimentoID, SolIC from procedimentos where id="&ProcedimentoID)
	NomeProcedimento = proc("NomeProcedimento")
	TipoProcedimentoID = proc("TipoProcedimentoID")
	if ConvenioID="0" then
        set atenSQL = db.execute("SELECT tp.NomeTabela FROM atendimentos AS aten LEFT JOIN agendamentos AS ag ON aten.AgendamentoID = ag.id LEFT JOIN tabelaparticular AS tp ON tp.id = ag.TabelaParticularID WHERE aten.id="&req("AtendimentoID"))
		if not atenSQL.eof then
            if atenSQL("NomeTabela")&"" <>"" then
                NomeTabela = "<code>"&atenSQL("NomeTabela")&"</code>"
            end if
        end if
        
        NomeForma = "Particular "&NomeTabela
		Icone = "money"
		ValorFinal = ValorBruto*Fator
	else
		set conv = db.execute("select NomeConvenio, segundoProcedimento, terceiroProcedimento, quartoProcedimento from convenios where id="&ConvenioID)
		NomeForma = conv("NomeConvenio")
		segundoProcedimento = conv("segundoProcedimento")
		terceiroProcedimento = conv("terceiroProcedimento")
		quartoProcedimento = conv("quartoProcedimento")
		Icone = "credit-card"
		if (segundoProcedimento<>100 or terceiroProcedimento<>100 or quartoProcedimento<>100) and TipoProcedimentoID=4 then
			nProcedimentos = 1
			splLinhas = split(ref("Linhas"), ", ")
			for i=0 to ubound(splLinhas)
				if ref("ConvenioID"&splLinhas(i))=ConvenioID and ref("TipoProcedimentoID"&splLinhas(i))="4" then
					nProcedimentos = nProcedimentos+1
				end if
			next
		end if
		if nProcedimentos=2 then
			Fator = segundoProcedimento/100
		elseif nProcedimentos=3 then
			Fator = terceiroProcedimento/100
		elseif nProcedimentos>3 then
			Fator = quartoProcedimento/100
		end if

        CodigoNaOperadora = NULL

        'sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND (Contratado = "&session("idInTable")&" OR Contratado = "&session("UnidadeID")&"*-1) ORDER BY Contratado DESC "
        sqlCodigoNaOperador  = "SELECT * FROM contratosconvenio WHERE ConvenioID = NULLIF('"&ConvenioID&"','') ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC "
		set ContratosConvenio = db.execute(sqlCodigoNaOperador)

		IF NOT ContratosConvenio.eof THEN
            CodigoNaOperadora = ContratosConvenio("CodigoNaOperadora")
		END IF

		ValorFinal = ValorBruto*Fator

		IF getConfig("calculostabelas") THEN
		    set CalculaValorProcedimentoConvenioObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadora,null,null,null)
            AssociacaoID     = (CalculaValorProcedimentoConvenioObj("AssociacaoID"))
        	ValorFinal       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalGeral"))
        	CalculoContratos = (CalculaValorProcedimentoConvenioObj("Contratos"))
        	TotalCH          = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalCH"))
        	TotalValorFixo   = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalValorFixo"))
        	TotalUCO         = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalUCO"))
        	TotalPORTE       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalPORTE"))
        	TotalFILME       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalFILME"))
        	TotalGeral       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalGeral"))
            sqlInsert        = "INSERT INTO calculos_finalizar_atendimento_log(AtendimentoID,ProcedimentoID, CalculoConvenioID,CalculoContratos,CalculoPlanoID,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral)"&_
                               "VALUE(NULLIF('"&AtendimentoID&"',''),NULLIF('"&ProcedimentoID&"',''),NULLIF('"&ConvenioID&"',''),NULLIF('"&CalculoContratos&"',''),NULLIF('"&PlanoID&"',''),NULLIF('"&TotalCH&"',''),NULLIF('"&TotalValorFixo&"',''),NULLIF('"&TotalUCO&"',''),NULLIF('"&TotalPORTE&"',''),NULLIF('"&TotalFILME&"',''),NULLIF('"&TotalGeral&"',''))"

        	db.execute(sqlInsert)
		END IF

	end if

    SolIC = proc("SolIC")

   IF getConfig("calculostabelas") = "1" and ConvenioID <> "0" THEN

   ELSE %>
               <!--#include file="apLinhaItem.asp"-->
   <% END IF

	set Anexos = db.execute("SELECT * FROM tissprocedimentosanexos WHERE COALESCE(AssociacaoID=('"&AssociacaoID&"'), ConvenioID = "&req("ConvenioID")&" AND ProcedimentoPrincipalID = "&req("ProcedimentoID")&") ")

    while not Anexos.eof

            ProcedimentoID = Anexos("ProcedimentoAnexoID")
            ConvenioID = Anexos("ConvenioID")
            'ValorBruto = ccur(req("ValorBruto"))
            Fator = 1
            id = id-1

            set proc = db.execute("select NomeProcedimento, TipoProcedimentoID, SolIC from procedimentos where id="&ProcedimentoID)
            NomeProcedimento = proc("NomeProcedimento")
            TipoProcedimentoID = proc("TipoProcedimentoID")
            if ConvenioID="0" then
                NomeForma = "Particular"
                Icone = "money"
            else
                set conv = db.execute("select NomeConvenio, segundoProcedimento, terceiroProcedimento, quartoProcedimento from convenios where id="&ConvenioID)
                NomeForma = conv("NomeConvenio")
                segundoProcedimento = conv("segundoProcedimento")
                terceiroProcedimento = conv("terceiroProcedimento")
                quartoProcedimento = conv("quartoProcedimento")
                Icone = "credit-card"
                if (segundoProcedimento<>100 or terceiroProcedimento<>100 or quartoProcedimento<>100) and TipoProcedimentoID=4 then
                    nProcedimentos = 1
                    splLinhas = split(ref("Linhas"), ", ")
                    for i=0 to ubound(splLinhas)
                        if ref("ConvenioID"&splLinhas(i))=ConvenioID and ref("TipoProcedimentoID"&splLinhas(i))="4" then
                            nProcedimentos = nProcedimentos+1
                        end if
                    next
                end if
                if nProcedimentos=2 then
                    Fator = segundoProcedimento/100
                elseif nProcedimentos=3 then
                    Fator = terceiroProcedimento/100
                elseif nProcedimentos>3 then
                    Fator = quartoProcedimento/100
                end if
            end if


            ValorFinal = ValorBruto*Fator
            IF getConfig("calculostabelas") THEN
                set CalculaValorProcedimentoConvenioObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadora,null,Anexos("id"),null)
                ValorFinal = (CalculaValorProcedimentoConvenioObj("TotalGeral"))

                CalculoContratos = (CalculaValorProcedimentoConvenioObj("Contratos"))
                TotalCH          = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalCH"))
                TotalValorFixo   = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalValorFixo"))
                TotalUCO         = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalUCO"))
                TotalPORTE       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalPORTE"))
                TotalFILME       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalFILME"))
                TotalGeral       = treatvalnull(CalculaValorProcedimentoConvenioObj("TotalGeral"))
                sqlInsert = "INSERT INTO calculos_finalizar_atendimento_log(AtendimentoID,ProcedimentoID, CalculoConvenioID,CalculoContratos,CalculoPlanoID,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral)"&_
                            "VALUE(NULLIF('"&AtendimentoID&"',''),NULLIF('"&ProcedimentoID&"',''),NULLIF('"&ConvenioID&"',''),NULLIF('"&CalculoContratos&"',''),NULLIF('"&PlanoID&"',''),NULLIF('"&TotalCH&"',''),NULLIF('"&TotalValorFixo&"',''),NULLIF('"&TotalUCO&"',''),NULLIF('"&TotalPORTE&"',''),NULLIF('"&TotalFILME&"',''),NULLIF('"&TotalGeral&"',''))"
                db.execute(sqlInsert)
            END IF
            SolIC = proc("SolIC")

           IF getConfig("calculostabelas") = "1" and ConvenioID <> "0" THEN

           ELSE %>
                    <!--#include file="apLinhaItem.asp"-->
           <% END IF
    Anexos.movenext
    wend
    Anexos.close
    set Anexos=nothing

    IF getConfig("calculostabelas") = "1" and ConvenioID <> "0"  THEN
        recalcularEscalonamentoAtendimento(AtendimentoID)

        set linhaRegistro = db.execute("SELECT calculos_finalizar_atendimento_log.*,c.NomeConvenio,p.SolIC,p.Obs,p.NomeProcedimento, p.SolIC, p.TipoProcedimentoID, p.Valor,COALESCE(AtendimentoProcedimentoID,CONCAT(calculos_finalizar_atendimento_log.id*-1,'')) AS id FROM  calculos_finalizar_atendimento_log left join procedimentos as p on p.id=calculos_finalizar_atendimento_log.ProcedimentoID left join convenios as c on c.id=calculos_finalizar_atendimento_log.CalculoConvenioID WHERE AtendimentoID ="&AtendimentoID&" ORDER by fator DESC ;")

        while not linhaRegistro.eof
            ProcedimentoID = linhaRegistro("ProcedimentoID")
            NomeForma = linhaRegistro("NomeConvenio")
            NomeProcedimento = linhaRegistro("NomeProcedimento")
            Fator = linhaRegistro("Fator")
            Obs = linhaRegistro("Obs")
            SolIC = linhaRegistro("SolIC")
            ValorFinal = linhaRegistro("ValorTotal")
            id = linhaRegistro("id")
            response.write(id)
        %>
           <!--#include file="apLinhaItem.asp"-->
        <%
        linhaRegistro.movenext
        wend
        linhaRegistro.close
        set linhaRegistro=nothing
    END IF

end if

if Acao="" then
	PacienteID = req("PacienteID")

sqlFaturado = "select 'itemSADT' tipo, ig.id, g.NGuiaPrestador, c.NomeConvenio, proc.NomeProcedimento, ig.ValorTotal from tissprocedimentossadt ig left join tissguiasadt g on g.id=ig.GuiaID LEFT JOIN convenios c on c.id=g.ConvenioID LEFT JOIN procedimentos proc on proc.id=ig.ProcedimentoID WHERE g.PacienteID="&PacienteID&" AND (ig.ProfissionalID="&session("idInTable")&" OR isnull(ig.ProfissionalID) OR ig.ProfissionalID=0) AND date(ig.Data)=date(now()) AND (isnull(ig.AtendimentoID) OR ig.AtendimentoID=0) UNION ALL "&_
              "select 'idConsulta', gc.id, gc.NGuiaPrestador, cCon.NomeConvenio, procCon.NomeProcedimento, gc.ValorProcedimento FROM tissguiaconsulta gc LEFT JOIN convenios cCon on cCon.id=gc.ConvenioID LEFT JOIN procedimentos procCon on procCon.id=gc.ProcedimentoID WHERE gc.PacienteID="&PacienteID&" AND gc.ProfissionalID="&session("idInTable")&" AND date(gc.DataAtendimento)=date(now()) AND (isnull(gc.AtendimentoID) OR gc.AtendimentoID=0)"

set guia = db.execute(sqlFaturado)
if not guia.eof then
	%>
	<h5><strong>GUIAS EMITIDAS</strong></h5>
    <table class="table table-condensed table-striped">
    <thead>
    	<tr>
        	<th>NÚM</th>
        	<th>CONVÊNIO</th>
        	<th>PROCEDIMENTO</th>
        	<%if aut("areceberpacienteV")>0 then%><th width="10%">VALOR</th><%end if%>
        	<th width="1%" class="text-center">EXEC</th>
        </tr>
    </thead>
	<%
	while not guia.eof
		if isnull(guia("ValorTotal")) then
			ValorTotal = 0
		else
			ValorTotal = guia("ValorTotal")
		end if
		%>
		<tr>
			<td><%=guia("NGuiaPrestador")%></td>
			<td><%=guia("NomeConvenio")%></td>
			<td><%=guia("NomeProcedimento")%></td>
			<%if aut("areceberpacienteV")>0 then%><td><%=formatnumber(ValorTotal, 2)%></td><%end if%>
            <td class="text-center"><label><input type="checkbox" name="<%=guia("tipo")%>" value="<%=guia("id")%>" checked><span class="lbl"></span></label>
        </tr>
		<%
	guia.movenext
	wend
	guia.close
	set guia = nothing
	%>
	</table>
	<%
end if

if 1=1 and AtendimentoID<>"N" and GetConfig("BaixarItensContratadosAoFinalizarAtendimento")=1 then
'aqui ira listar os itens contratados do agendamento que foi feito e iniciado

    sqlItens= "select proc.NomeProcedimento, proc.id ProcedimentoID "&_
                  " from ( select id, TipoCompromissoID ProcedimentoID from agendamentos where id="&treatvalzero(AgendamentoID)&" "&_
                              " UNION ALL SELECT AgendamentoID * -1 as id, TipoCompromissoID ProcedimentoID FROM agendamentosprocedimentos proc WHERE proc.AgendamentoID="&treatvalzero(AgendamentoID)&") age "&_
                  " LEFT JOIN procedimentos proc on proc.id=age.ProcedimentoID "&_            
                  " ORDER BY proc.NomeProcedimento "
                  'retirado pois não estava listando todos os procedimentos 
                  '" GROUP BY proc.id "
    set part = db.execute(sqlItens)

    itensNaListagem="-1"
    if not part.eof then
	    %>
<div class="itens-contratados">
	    <h5 style="padding: 10px; background-color: #888888; color: #fff"><strong>ITENS CONTRADADOS</strong> <small style="color: #fdfdfd;">&raquo; marque os procedimentos que foram executados</small></h5>
        <table class="table table-condensed table-striped">
        <thead>
    	    <tr>
                <th width="1%" class="text-center">EXEC</th>
        	    <th>QTD</th>
        	    <th>PROCEDIMENTO</th>
        	    <%if aut("areceberpacienteV")>0 then%><th width="10%">VALOR</th><%end if%>
            </tr>
        </thead>
	    <%

	    TemItemContratado = False

	    while not part.eof
	        ItemChecked=""
            ExibeLinha = True

            ItemChecked = " checked "

            if BaixaItensNaoPagosAoFinalizarAtendimento&""<>"1" then
                sqlValorPago = " mov.ValorPago > 0 OR ii.ValorUnitario=0"
            else
                sqlValorPago = "true"
            end if
            

            ProcedimentoID= part("ProcedimentoID")


            sqlItens= "select ii.id, proc.NomeProcedimento, ii.ValorUnitario, ii.Quantidade, ii.ValorUnitario, ii.Desconto, ii.Acrescimo "&_
              " from itensinvoice ii "&_
              " LEFT JOIN sys_financialinvoices i on i.id=ii.InvoiceID "&_
              " LEFT JOIN sys_financialmovement mov on mov.InvoiceID=ii.InvoiceID "&_
              " LEFT JOIN procedimentos proc on proc.id=ii.ItemID "&_
              " WHERE ii.id not in ("&itensNaListagem&") and ii.ItemID="&treatvalzero(ProcedimentoID)&" AND "&_
              "(ISNULL(ii.Executado) OR ii.Executado='') AND ("&sqlValorPago&") AND i.sysActive=1 AND i.CD='C' AND ii.Tipo='S' AND i.AccountID="&PacienteID&" AND i.AssociationAccountID=3 "

            set ItemSQL = db.execute(sqlItens)
            if ExibeLinha and not ItemSQL.eof then
                TemItemContratado=True
                itensNaListagem=itensNaListagem&","&ItemSQL("id")
		    %>
		    <tr>
                <td class="text-center">
                    <div class="checkbox-custom checkbox-default">
                        <input type="checkbox" class="ace " name="itemInvoice" id="Executado<%=ItemSQL("id")%>" value="<%=ItemSQL("id")%>" <%=ItemChecked%>> <label class="checkbox" for="Executado<%=ItemSQL("id")%>"></label>
                    </div>
			    <td><%=ItemSQL("Quantidade")%></td>
			    <td><%=ItemSQL("NomeProcedimento")%></td>
			    <%if aut("areceberpacienteV")>0 then%><td><%=formatnumber(ItemSQL("ValorUnitario")-ItemSQL("Desconto")+ItemSQL("Acrescimo"), 2)%></td><%end if%>
            </tr>
		    <%
		    end if
	    part.movenext
	    wend
	    part.close
	    set part = nothing

	    if not TemItemContratado then
	        %>
<script >
//$(".itens-contratados").remove();
</script>
	        <%
	    end if
	    %>
	    </table>
	    <%
    else
        if PermitirInformarProcedimentos="0" then
            %>
<div class="alert alert-default">
    Nenhum item contratado.
</div>
<script >
saveInf('<%=AtendimentoID%>');
</script>
            <%
        end if
    end if
    %>
</div>
    <%
end if

if PermitirInformarProcedimentos then
%>
    <h5 style="padding: 10px; background-color: #888888; color: #fff"><strong>INFORME ITENS A FATURAR</strong> <small style="color: #fdfdfd;">&raquo; insira novos itens da lista de procedimentos ao lado</small></h5>
	<table class="duplo table table-striped table-hover table-condensed">
	<thead>
		<tr>
			<th width="1%"></th>
			<th>Pagto</th>
			<th>Procedimento</th>
			<th>Fator</th>
			<%if aut("areceberpacienteV")>0 then%><th>Valor</th><%end if%>
			<th width="1%"></th>
			<th width="1%"></th>
		</tr>
	</thead>
	<tbody>
	<%
	if AtendimentoID<>"N" and AtendimentoID<>"" then

	    sqlAtendimento = "select ap.*, p.NomeProcedimento, p.SolIC, p.TipoProcedimentoID, p.Valor, at.PacienteID,agendamentos.PlanoID, agendamentos.TabelaParticularID, TabelaParticular.NomeTabela from atendimentosprocedimentos as ap left join procedimentos as p on p.id=ap.ProcedimentoID left join atendimentos as at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ON AgendamentoID = agendamentos.id LEFT JOIN TabelaParticular ON TabelaParticular.id = agendamentos.TabelaParticularID where AtendimentoID="&AtendimentoID
		set procs = db.execute(sqlAtendimento)

		IF getConfig("calculostabelas") THEN
		    db.execute("DELETE FROM calculos_finalizar_atendimento_log WHERE AtendimentoID="&AtendimentoID)
		END IF

        if not procs.eof then
            if procs("NomeTabela")&"" <> "" then
                NomeTabela= "<code>"&procs("NomeTabela")&"</code>"
            end if

            while not procs.eof
                id = procs("id")
                ProcedimentoID = procs("ProcedimentoID")
                NomeProcedimento = procs("NomeProcedimento")
                TipoProcedimentoID = procs("TipoProcedimentoID")
                if procs("rdValorPlano")="V" then
                    ConvenioID = 0
                    NomeForma = "Particular "&NomeTabela
                    Icone = "money"
                else
                    ConvenioID = procs("ValorPlano")
                    set conv = db.execute("select NomeConvenio, segundoProcedimento, terceiroProcedimento, quartoProcedimento from convenios where id="&treatvalzero(ConvenioID))
                    if not conv.eof then
                        NomeForma = conv("NomeConvenio")
                    else
                        NomeForma = ""
                    end if
                    Icone = "credit-card"
                end if

                ValorFinal = procs("ValorFinal")

                IF ConvenioID <> 0 THEN
                    CodigoNaOperadora = NULL

                    'sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND (Contratado = "&session("idInTable")&" OR Contratado = "&session("UnidadeID")&"*-1) ORDER BY Contratado DESC "
                    ConvenioIDStr = ConvenioID

                    sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&treatvalnull(ConvenioIDStr)&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC "

                    set ContratosConvenio = db.execute(sqlCodigoNaOperador)

                    IF NOT ContratosConvenio.eof THEN
                        CodigoNaOperadora = ContratosConvenio("CodigoNaOperadora")
                    END IF

                    IF getConfig("calculostabelas") THEN
                        SET Valores = CalculaValorProcedimentoConvenio(null,ConvenioID,procs("ProcedimentoID"),procs("PlanoID"),CodigoNaOperadora,1,null,null)

                        if xxxCalculaValorProcedimentoConvenioNotIsNull then
                            AssociacaoID = Valores("AssociacaoID")

                            ValorFinal       = (Valores("TotalGeral"))

                            CalculoContratos = (Valores("Contratos"))
                            TotalCH = treatvalnull(Valores("TotalCH"))
                            TotalValorFixo = treatvalnull(Valores("TotalValorFixo"))
                            TotalUCO = treatvalnull(Valores("TotalUCO"))
                            TotalPORTE = treatvalnull(Valores("TotalPORTE"))
                            TotalFILME = treatvalnull(Valores("TotalFILME"))
                            TotalGeral = treatvalnull(Valores("TotalGeral"))
                            sqlInsert = "INSERT INTO calculos_finalizar_atendimento_log(AtendimentoID,AtendimentoProcedimentoID,ProcedimentoID, CalculoConvenioID,CalculoContratos,CalculoPlanoID,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral)"&_
                                        "VALUE(NULLIF('"&AtendimentoID&"',''),"&id&",NULLIF('"&ProcedimentoID&"',''),NULLIF('"&ConvenioID&"',''),NULLIF('"&CalculoContratos&"',''),NULLIF('"&PlanoID&"',''),"&TotalCH&","&TotalValorFixo&","&TotalUCO&","&TotalPORTE&","&TotalFILME&","&TotalGeral&")"

                            db.execute(sqlInsert)

                            ValorFinal = formatnumber(Valores("TotalGeral"), 2)

                        END IF
                    END IF
                END IF

                Fator = procs("Fator")
                Obs = procs("Obs")
                SolIC = procs("SolIC")

                IF getConfig("calculostabelas") = "1" and ConvenioID <> "0" THEN
                    IF ConvenioID = 0 THEN

                    %>
                      <!--#include file="apLinhaItem.asp"-->
                    <% END IF %>
                <% ELSE %>
                <!--#include file="apLinhaItem.asp"-->
                <% END IF
            procs.movenext
            wend
            procs.close
            set procs=nothing
        end if

            IF getConfig("calculostabelas") THEN
                sqlAnexos =  "SELECT * FROM tissprocedimentosanexos WHERE COALESCE(AssociacaoID=('"&AssociacaoID&"'), ConvenioID = "&treatvalzero(ConvenioID)&" AND ProcedimentoPrincipalID = "&treatvalzero(ProcedimentoID)&") "
            ELSE
                sqlAnexos = "SELECT * FROM tissprocedimentosanexos WHERE ConvenioID = "&treatvalzero(ConvenioID)&" AND ProcedimentoPrincipalID = "&treatvalzero(ProcedimentoID)&" "
            END IF

    	    set Anexos = db.execute(sqlAnexos)

        	while not Anexos.eof

                    ProcedimentoID = Anexos("ProcedimentoAnexoID")
                    ConvenioID = Anexos("ConvenioID")
                    'ValorBruto = ccur(req("ValorBruto"))
                    Fator = 1
                    id = id-1

                    set proc = db.execute("select NomeProcedimento, TipoProcedimentoID, SolIC from procedimentos where id="&ProcedimentoID)
                    NomeProcedimento = proc("NomeProcedimento")
                    TipoProcedimentoID = proc("TipoProcedimentoID")
                    if ConvenioID="0" then
                        NomeForma = "Particular"
                        Icone = "money"
                    else
                        set conv = db.execute("select NomeConvenio, segundoProcedimento, terceiroProcedimento, quartoProcedimento from convenios where id="&ConvenioID)
                        NomeForma = conv("NomeConvenio")
                        segundoProcedimento = conv("segundoProcedimento")
                        terceiroProcedimento = conv("terceiroProcedimento")
                        quartoProcedimento = conv("quartoProcedimento")
                        Icone = "credit-card"
                        if (segundoProcedimento<>100 or terceiroProcedimento<>100 or quartoProcedimento<>100) and TipoProcedimentoID=4 then
                            nProcedimentos = 1
                            splLinhas = split(ref("Linhas"), ", ")
                            for i=0 to ubound(splLinhas)
                                if ref("ConvenioID"&splLinhas(i))=ConvenioID and ref("TipoProcedimentoID"&splLinhas(i))="4" then
                                    nProcedimentos = nProcedimentos+1
                                end if
                            next
        	end if
                        if nProcedimentos=2 then
                            Fator = segundoProcedimento/100
                        elseif nProcedimentos=3 then
                            Fator = terceiroProcedimento/100
                        elseif nProcedimentos>3 then
                            Fator = quartoProcedimento/100
                        end if
                    end if
                    ValorFinal = ValorBruto*Fator

                    IF getConfig("calculostabelas") THEN
                        set CalculaValorProcedimentoConvenioObj = CalculaValorProcedimentoConvenio(null,null,null,null,null,null,Anexos("id"),null)
                        ValorFinal = (CalculaValorProcedimentoConvenioObj("TotalGeral"))

                        CalculoContratos = CalculoContratos
                        TotalCH = (CalculaValorProcedimentoConvenioObj("TotalCH"))
                        TotalValorFixo = (CalculaValorProcedimentoConvenioObj("TotalValorFixo"))
                        TotalUCO = (CalculaValorProcedimentoConvenioObj("TotalUCO"))
                        TotalPORTE = (CalculaValorProcedimentoConvenioObj("TotalPORTE"))
                        TotalFILME = (CalculaValorProcedimentoConvenioObj("TotalFILME"))
                        TotalGeral = (CalculaValorProcedimentoConvenioObj("TotalGeral"))
                        sqlInsert = "INSERT INTO calculos_finalizar_atendimento_log(AtendimentoID,ProcedimentoID, CalculoConvenioID,CalculoContratos,CalculoPlanoID,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral)"&_
                                    "VALUE(NULLIF('"&AtendimentoID&"',''),NULLIF('"&ProcedimentoID&"',''),NULLIF('"&ConvenioID&"',''),NULLIF('"&CalculoContratos&"',''),NULLIF('"&PlanoID&"',''),NULLIF('"&TotalCH&"',''),NULLIF('"&TotalValorFixo&"',''),NULLIF('"&TotalUCO&"',''),NULLIF('"&TotalPORTE&"',''),NULLIF('"&TotalFILME&"',''),NULLIF('"&TotalGeral&"',''))"
                        db.execute(sqlInsert)
                    END IF
            SolIC = proc("SolIC")
            IF getConfig("calculostabelas") and ConvenioID <> "0" THEN
        	%>

        	<% ELSE %>
            <!--#include file="apLinhaItem.asp"-->
            <% END IF

            Anexos.movenext
            wend
            Anexos.close
            set Anexos=nothing
            IF getConfig("calculostabelas") = "1" and ConvenioID <> "0" THEN
                    recalcularEscalonamentoAtendimento(AtendimentoID)
                    set linhaRegistro = db.execute("SELECT *,calculos_finalizar_atendimento_log.Obs,p.NomeProcedimento,c.NomeConvenio, p.SolIC, p.TipoProcedimentoID, p.Valor,COALESCE(AtendimentoProcedimentoID,CONCAT(calculos_finalizar_atendimento_log.id*-1,'')) as idlog FROM  calculos_finalizar_atendimento_log left join procedimentos as p on p.id=calculos_finalizar_atendimento_log.ProcedimentoID  left join convenios as c on c.id=calculos_finalizar_atendimento_log.CalculoConvenioID WHERE AtendimentoID ="&AtendimentoID&" ORDER by fator DESC ;")

                    while not linhaRegistro.eof
                        ProcedimentoID   = linhaRegistro("ProcedimentoID")
                        NomeForma        = linhaRegistro("NomeConvenio")
                        NomeProcedimento = linhaRegistro("NomeProcedimento")
                        Fator            = linhaRegistro("Fator")
                        Obs              = linhaRegistro("Obs")
                        SolIC            = linhaRegistro("SolIC")
                        ValorFinal       = linhaRegistro("ValorTotal")
                        id               = linhaRegistro("idlog")
                    %>
                       <!--#include file="apLinhaItem.asp"-->
                    <%
                    linhaRegistro.movenext
                    wend
                    linhaRegistro.close
                    set linhaRegistro=nothing

            END IF
	end if
	%>
	<tr id="fimListaAP" class="hidden"></tr>
	</table>
    <em>Selecione ao lado os procedimentos que foram realizados neste atendimento para adicioná-los à conta do paciente.</em>
	<%
end if
end if
%>
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>