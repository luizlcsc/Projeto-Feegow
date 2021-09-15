<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

'on error resume next
if req("De")="" then
	De=dateAdd("m",-1,date())
else
	De=req("De")
end if

if req("Ate")="" then
	A=date()
else
	A=req("Ate")
end if

valorTotal=0
%>
<%
if req("De")="" then
%>
<h4>Duração do atendimento</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="ProdutividadeAtendimento">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>
            <div class="col-md-3">
                <label>Paciente</label><br />
                <%=selectInsertCA("", "AccountID", Pagador, "3", "", "", "")%>
            </div>
            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button type="submit" class="btn btn-sm btn-primary" name="Gerar" value="Gerar"><i class="far fa-search"></i>Gerar</button>
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-md-4">
                <div class="row">
                    <%=quickfield("multiple", "Procedimentos", "Procedimentos", 12, ref("Procedimentos"), "select id, NomeProcedimento from procedimentos where sysActive=1 order by NomeProcedimento", "NomeProcedimento", "")%>
                </div>
            </div>
            <div class="col-md-3">
                <label>Profissional</label><br />
                <select name="Profissional" class="form-control">
                    <%
			  if aut("|agendaV|")=1 then
                    %>
                    <option value="">Todos</option>
                    <%
			  end if
              set p=db.execute("select * from profissionais where ativo='on' and sysActive=1 order by NomeProfissional")
              while not p.EOF
			  	if aut("|agendaV|")=1 or (lcase(session("Table"))="profissionais" and session("idInTable")=p("id")) then
                    %>
                    <option value="<%=p("id")%>" <%if cStr(p("id"))=req("Profissional") then%> selected="selected" <%end if%>><%=p("NomeProfissional")%></option>
                    <%
				end if
              p.moveNext
              wend
              p.close
              set p=nothing
                    %>
                </select>
            </div>

        </div>

    </div>
    <input type="hidden" name="E" value="E" />
</form>
<%
else
%>
<h3>DURAÇÃO DO ATENDIMENTO</h3>
<hr />
<%
end if


if req("E")="E" then
	if req("Profissional")="" then
		sqlProfissional=""
	else
		sqlProfissional=" and id = '"&req("Profissional")&"'"
	end if
	qtdTotal = 0
	set pP=db.execute("select * from profissionais where sysActive=1"&sqlProfissional&" and ativo='on' order by NomeProfissional")
	while not pP.EOF
%>
<h4><%=uCase(pP("NomeProfissional"))%></h4>
<table width="100%" class="table table-condensed table-striped table-hover">
    <thead>
        <tr>
            <th width="25"></th>
            <th >DATA</th>
            <th >HORA MARCADA</th>
            <th >HORA ATENDIMENTO</th>
            <th >TEMPO DE ESPERA</th>
            <th >DURAÇÃO</th>
            <th >DURAÇÃO ESPERADA</th>
            <th >PROCEDIMENTO</th>
            <th >PACIENTE</th>
        </tr>
    </thead>
    <%
		if req("Procedimentos")<>"" then
			sqlProc = " AND age.TipoCompromissoID IN ("& replace(req("Procedimentos"), "|", "") &")"
		end if
		if req("AccountID")<>"" and req("AccountID")<>"0" then
		    AccountID = req("AccountID")
            splPaciente = split(AccountID, "_")
            PacienteID = splPaciente(1)
			sqlPac = " AND a.PacienteID = "&PacienteID
		end if
        if req("UnidadeID")<>"" then
            sqlUnid = " AND (a.UnidadeID IN ("& replace(req("UnidadeID"), "|", "")&") or isnull(a.UnidadeID))"
        end if

		sql = "select a.*, p.NomePaciente, age.Hora as 'HoraMarcada', p.Tel1, p.Tel2, p.Cel1, p.Cel2 "&sqlCampoOrigem&" from atendimentos a LEFT JOIN agendamentos age ON age.id = a.AgendamentoID LEFT JOIN pacientes p on p.id=a.PacienteID "&sqlLeftOrigem&" where (a.ProfissionalID="&pP("id")&" and a.Data BETWEEN "&mydatenull(De)&" and "&mydatenull(A)&") "& sqlProc & sqlUnid & sqlPac & ref("Procedimentos") &" order by a.Data, a.HoraInicio  "
		'response.Write(sql)
		set pCon=db.execute(sql)
		valorTotal=0
		MinutosTotal = 0
        c=0
		while not pCon.EOF
        c=c+1

        TempoAguardo = datediff("n", pCon("HoraMarcada"), pCon("HoraInicio"))
        TempoAtendimento = DateDiff("n", pCon("HoraInicio"), pCon("HoraFim"))

        MinutosTotal = MinutosTotal + DateDiff("n", pCon("HoraInicio"), pCon("HoraFim"))

        Tempo = 0
        NomeProcedimento = ""

        set AgendamentoSQL = db.execute("SELECT p.id, p.TempoProcedimento, a.Tempo FROM agendamentos a LEFT JOIN procedimentos p ON p.id = a.TipoCompromissoID WHERE a.id = "&pCon("AgendamentoID"))
        if not AgendamentoSQL.eof then
            Tempo = AgendamentoSQL("Tempo")

            if AgendamentoSQL("id") <> "" then
                set pProc=db.execute("select NomeProcedimento,TempoProcedimento from procedimentos where id="&AgendamentoSQL("id"))
                if not pProc.EOF then
                    NomeProcedimento = pProc("NomeProcedimento")
                    if Tempo="" then
                        Tempo =  pProc("TempoProcedimento")
                    end if
                end if
            end if
        end if
        IndicadorAguardo = ""
        if TempoAguardo > 60 then
            IndicadorAguardo = "color: red"
        elseif TempoAguardo > 30 then
            IndicadorAguardo = "color: orange"
        end if

        IndicadorAtendimento = ""
        if Tempo<>"" and not isnull(Tempo) then
            if Tempo>0 then
                if Tempo / 4 >= TempoAtendimento then
                    IndicadorAtendimento = "color: red"
                elseif Tempo / 2 >= TempoAtendimento then
                    IndicadorAtendimento = "color: orange"
                end if
            end if
        end if


    %>
    <tr>
        <td></td>
        <td><%=pCon("Data")%></td>
        <td><%=left(right(pCon("HoraMarcada"),8),5)%></td>
        <td><%=left(right(pCon("HoraInicio"),8),5)%> - <%=left(right(pCon("HoraFim"),8),5)%></td>
        <td><span style="<%=IndicadorAguardo%>"><%=TempoAguardo%> min. </span></td>
        <td><span style="<%=IndicadorAtendimento%>"><%=TempoAtendimento%> min.</span></td>
        <td><%=Tempo%></td>
        <td><%=NomeProcedimento%></td>
        <td></td>
        <td></td>
        <td><%=pCon("NomePaciente")%></td>

    </tr>
    <%
		pCon.moveNext
		wend
		pCon.close
		set pCon=nothing%>
</table>
<%
T = MinutosTotal/60
if isnull(T) then
    T = 0
end if
%>
<h4>Total: <%=round(T,2)%>h</h4>
<%
	pP.moveNext
	wend
	pP.close
	set pP=nothing

end if%><!--#include file="disconnect.asp"-->
<script>
<!--#include file="jQueryFunctions.asp"-->
</script>
