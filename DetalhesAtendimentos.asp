<!--#include file="connect.asp"-->
<%
response.Charset="utf-8"

'on error resume next
if req("De")="" then
	De=dateAdd("m",-1,date())
	StaConsulta="3"
else
	De=req("De")
	StaConsulta=req("StaConsulta")
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

<h4>Agendamentos e Atendimentos</h4>
<form method="get" target="_blank" action="PrintStatement.asp">
    <input type="hidden" name="R" value="DetalhesAtendimentos">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "De", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
            <div class="col-md-3">
                <label>Forma</label><br />
                <select name="Forma" class="form-control">
                    <option value="">Todas</option>
                    <option value="0" <%if req("Forma")="0" then%> selected="selected" <%end if%>>Particular</option>
                    <option value="-1" <%if req("Forma")="-1" then%> selected="selected" <%end if%>>Todos os Conv&ecirc;nios</option>
                    <%
          set p=db.execute("select * from convenios where sysActive=1 order by NomeConvenio")
          while not p.EOF
                    %>
                    <option value="<%=p("id")%>" <%if cStr(p("id"))=req("Forma") then%> selected="selected" <%end if%>><%=p("NomeConvenio")%></option>
                    <%
          p.moveNext
          wend
          p.close
          set p=nothing
                    %>
                </select>
            </div>
            <%=quickField("simpleSelect", "AgendadoPor", "Agendado por", 3, "", "select lu.id, Nome from cliniccentral.licencasusuarios lu LEFT JOIN sys_users su on su.id=lu.id where lu.LicencaID="&replace(session("Banco"), "clinic", "")&" and lu.Nome not like '' and su.Permissoes like '%agendaI%' order by lu.Nome", "Nome", " empty")%>

            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button type="submit" class="btn btn-sm btn-primary" name="Gerar" value="Gerar"><i class="far fa-search"></i>Gerar</button>
            </div>
        </div>
        <div class="row">
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>
            <div class="col-md-3">
                <label>Paciente</label><br />
                <%=selectInsertCA("", "AccountID", Pagador, "3", "", "", "")%>
            </div>

            <%=quickfield("multiple", "Equipamentos", "Equipamentos", 3, ref("Procedimentos"), "select id, NomeEquipamento from equipamentos where sysActive=1 order by NomeEquipamento", "NomeEquipamento", "")%>

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
            <div class="col-md-5">
                <label>
                    <input type="checkbox" class="ace" name="Receitas" value="S"><small class="lbl"> Comparar com recebimentos gerados do paciente</small></label>
                <br />
                <label>
                    <input type="checkbox" class="ace" name="Origem" value="S"><small class="lbl"> Exibir origem do paciente</small></label>
                <br />
                <label>
                    <input type="checkbox" class="ace" name="MostrarTabela" value="S"><small class="lbl"> Mostrar tabela particular</small></label>

            </div>
        </div>
        <div class="row">
            <div class="col-md-12">
                <div class="row">
                    <%
                set psta=db.execute("select * from StaConsulta order by StaConsulta")
                while not psta.eof
                    %>
                    <div class="col-md-3" style="height: 25px; padding-left: 18px; padding-top: 4px; background-image: url(assets/img/<%=psta("id")%>.png); background-repeat: no-repeat; background-position: bottom left; float: left">
                        <label class="btn btn-xs btn-default btn-block text-left" style="text-align:left; padding-left:4px">
                            <input class="ace" type="checkbox" name="StaConsulta" value="<%=psta("id")%>" /><span class="lbl"><small><%=psta("StaConsulta")%></small></span> </label>
                    </div>
                    <%
                psta.movenext
                wend
                psta.close
                set psta=nothing
                    %>
                    <div class="col-md-3" style="height: 25px; padding-left: 18px; padding-top: 4px; background-repeat: no-repeat; background-position: bottom left; float: left">
                        <label class="btn btn-xs btn-default btn-block text-left" style="text-align:left; padding-left:4px">
                            <input class="ace" type="checkbox" name="StaConsulta" value="-1" /><span class="lbl"><small>Agendamentos excluídos</small></span> </label>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <input type="hidden" name="E" value="E" />
</form>
<%
else
%>

<style>

table.dataTable td.dataTables_empty{
    padding: 5px !important;
}
</style>
<h3>AGENDAMENTOS E ATENDIMENTOS</h3>
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
		if req("Forma")="" then
			sqlForma=""
		elseif req("Forma")="0" then
			sqlForma=" and a.rdValorPlano='V'"
		elseif req("Forma")="-1" then
			sqlForma=" and a.rdValorPlano='P'"
		else
			sqlForma=" and a.rdValorPlano='P' and a.ValorPlano="&req("Forma")
		end if
		if req("Procedimentos")<>"" then
			sqlProc = " AND a.TipoCompromissoID IN ("& replace(req("Procedimentos"), "|", "") &")"
		end if
		if req("Equipamentos")<>"" then
			sqlEquip = " AND a.EquipamentoID IN ("& replace(req("Equipamentos"), "|", "") &")"
		end if
		if req("AccountID")<>"" and req("AccountID")<>"0" then
		    AccountID = req("AccountID")
            splPaciente = split(AccountID, "_")
            PacienteID = splPaciente(1)
			sqlPac = " AND a.PacienteID = "&PacienteID
		end if
        if req("AgendadoPor")<>"" then
            sqlLeftUser = "left join logsmarcacoes l on a.id=l.ConsultaID and l.ARX='A'"
            sqlWhereUser = " AND l.Usuario="&req("AgendadoPor")
        end if
        if req("Origem")="S" then
            sqlCampoOrigem = " , o.Origem , ifnull(p.IndicadoPor, '') IndicadoPor"
            sqlLeftOrigem = "left join origens o on o.id=p.Origem"
        end if
        if req("StaConsulta")<>"" then
            sqlSta = " and a.StaID IN("&req("StaConsulta")&") "
        end if
        if req("UnidadeID")<>"" then
            sqlLeftUnid = " LEFT JOIN locais loc on loc.id=a.LocalID "
            sqlUnid = " AND (loc.UnidadeID IN ("& replace(req("UnidadeID"), "|", "")&") or isnull(loc.UnidadeID))"
        end if
		sql = "select a.*, p.NomePaciente,p.Tabela, p.Tel1, p.Tel2, p.Cel1, p.Cel2 "&sqlCampoOrigem&" from agendamentos a "&sqlLeftUser & sqlLeftUnid & " LEFT JOIN pacientes p on p.id=a.PacienteID "&sqlLeftOrigem&" where a.sysActive=1 AND a.ProfissionalID="&pP("id")&" and a.Data>="&mydatenull(De)&" and a.Data<="&mydatenull(A) & sqlForma & sqlProc & sqlEquip & sqlSta & sqlWhereUser & sqlUnid & sqlPac & ref("Procedimentos") &" order by a.Data, a.Hora"
'		response.Write(sql)
		set pCon=db.execute(sql)

    if not pcon.eof then
%>

<h4><%=uCase(pP("NomeProfissional"))%></h4>

<table width="100%" class="table table-condensed table-striped table-hover detalheAtendimentoResultado">
    <thead>
        <tr>
            <th width="25"></th>
            <th width="7%">STATUS</th>
            <th width="7%">DATA</th>
            <th width="7%">HORA</th>
            <th width="20%">PACIENTE</th>
            <%
             if req("MostrarTabela")="S" then
                %>
                <th width="100">Tabela</th>
                <%
             end if
		    %>
            <th width="10%">TELEFONES</th>
            <%
            if req("Origem")="S" then
            %>
            <th width="15%">ORIGEM</th>
            <%
            end if
            %>
            <th width="18%">PROCEDIMENTO</th>
            <th>VALOR</th>
            <%
		  if req("Receitas")="S" then
            %>
            <th width="200">LANÇTO/GUIA</th>
            <%
		  end if

            %>
        </tr>
    </thead>
    <%
		valorTotal=0
        c=0
		while not pCon.EOF
        c=c+1
    %>
    <tr>
        <td width="25">
            <img src="assets/img/<%=pCon("StaID")%>.png" /></td>
        <td><%set pSta=db.execute("select * from StaConsulta where id="&pCon("StaID"))
					if not pSta.EOF then response.Write(pSta("StaConsulta")) end if%></td>
        <td><%=pCon("Data")%></td>
        <td><%=right(pCon("Hora"),8)%></td>
        <td><%=pCon("NomePaciente")%></td>
        <%
        if req("MostrarTabela")="S" then
          if pcon("Tabela") > 0 then
              set TabelaSQL = db.execute("SELECT NomeTabela FROM tabelaparticular WHERE id = "&pcon("Tabela"))
              Tabela = ""
              if not TabelaSQL.eof then
                Tabela = TabelaSQL("NomeTabela")
              end if
          else
            Tabela = ""
          end if
          %>
          <td width="100"><%=Tabela%></td>
          <%
        end if
        %>
        <td><%=pCon("Tel1")%>&nbsp;&nbsp;<%=pCon("Cel1")%>&nbsp;&nbsp;<%=pCon("Tel2")%>&nbsp;&nbsp;<%=pCon("Cel2")%>&nbsp;&nbsp;</td>
        <%
        if req("Origem")="S" then
        %>
        <td width="15%">
            <%=pCon("Origem") %>
            <%if pCon("IndicadoPor")<>"" then response.Write(" - "& pCon("IndicadoPor")) end if %>
        </td>
        <%
        end if
        %>
        <td><%
        ProcedimentosIDs = pCon("TipoCompromissoID")

        set ProcedimentosAdicionaisSQL = db.execute("SELECT * FROM agendamentosprocedimentos WHERE AgendamentoID="&pCon("id"))
        ValorProcedimentosAdicionais = 0
        while not ProcedimentosAdicionaisSQL.eof
            if ProcedimentosAdicionaisSQL("rdValorPlano")="V" then
                ValorProcedimentosAdicionais = ValorProcedimentosAdicionais + ProcedimentosAdicionaisSQL("ValorPlano")
                ProcedimentosIDs = ProcedimentosIDs&","&ProcedimentosAdicionaisSQL("TipoCompromissoID")
            end if
        ProcedimentosAdicionaisSQL.moveNext
        wend
        ProcedimentosAdicionaisSQL.close
        set ProcedimentosAdicionaisSQL=nothing

        ValorAgendamento = pCon("ValorPlano") + ValorProcedimentosAdicionais

        set pProc=db.execute("select GROUP_CONCAT(NomeProcedimento)NomeProcedimento from procedimentos where id IN ("&ProcedimentosIDs&")")
					if not pProc.EOF then

						response.Write(pProc("NomeProcedimento"))
					'		set pSubTP=db.execute("select * from SubtiposProcedimentos where id = '"&pCon("SubtipoProcedimentoID")&"'")
					'		if not pSubTP.EOF then
					'			response.Write(" - "&pSubTP("SubtipoProcedimento"))
					'		end if
					end if%></td>
        <td align="right"><%
					if pCon("rdValorPlano")="V" then
						valorTotal=valorTotal+ValorAgendamento
        %>R$ <%=fn(ValorAgendamento)%><%else
						set pConv=db.execute("select * from convenios where id="&treatvalzero(pCon("ValorPlano")))
						if not pConv.EOF then response.Write(pConv("NomeConvenio")) end if
					end if
                    qtdTotal = qtdTotal+1

                  if req("Receitas")="S" then
                    if pCon("rdValorPlano")="V" then
				  	    set ii = db.execute("select ii.*, p.NomeProcedimento, (ii.Quantidade * (ii.ValorUnitario+ii.Acrescimo-ii.Desconto) ) ValorTotal FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID LEFT JOIN procedimentos p on p.id=ii.ItemID WHERE i.AccountID="&pCon("PacienteID")&" AND ii.ProfissionalID="&pCon("ProfissionalID")&" AND ii.ItemID="& pCon("TipoCompromissoID") &" AND ii.DataExecucao="&mydatenull(pcon("Data"))&" AND ii.Tipo='S'")
                    else
				  	    set ii = db.execute("select ii.*, p.NomeProcedimento, (ii.ValorProcedimento) ValorTotal FROM tissguiaconsulta ii  LEFT JOIN procedimentos p on p.id=ii.ProcedimentoID WHERE ii.PacienteID="&pCon("PacienteID")&" AND ii.ProfissionalID="&pCon("ProfissionalID")&" AND ii.DataAtendimento ="&mydatenull(pcon("Data")))
                    end if
        %>
        </td>
        <td>
            <%
                        if ii.eof then
            %>
            <em>Nada lançado - <a href="./?P=Pacientes&Pers=1&I=<%=pcon("PacienteID")%>&Ct=1" target="_blank">Ver conta</a></em>
            <%
						else
							while not ii.eof
							if pCon("rdValorPlano")="V" then
							    redir = "./?P=invoice&T=C&I="&ii("InvoiceID")&"&Pers=1"
                            else
							    redir = "./?P=tissguiaconsulta&I="&ii("id")&"&Pers=1"
                            end if
            %>
            <a href="<%=redir%>" target="_blank" class="btn btn-xs btn-default btn-block"><%=left(ii("NomeProcedimento")&" ", 13) &" - R$ "& fn(ii("ValorTotal")) %></a></td>
                            <%
							ii.movenext
							wend
							ii.close
							set ii=nothing
                        end if
                  end if

            %>

    </tr>
    <%
		pCon.moveNext
		wend
		pCon.close
		set pCon=nothing%>
    <tfoot>

        <tr>
            <td colspan="7"><%=c %> registro(s) encontrado(s)</td>
            <td align="right"><strong>R$ <%=fn(valorTotal)%></strong></td>
        </tr>
    </tfoot>
</table>

    <%
end if

    if instr(req("StaConsulta"), "-1")>0 then
        %>
        <h3 class="text-danger">Agendamentos Excluídos</h3>

        <table class="table table-condensed table-bordered">
            <thead>
                <tr>
                    <th>Data Agendamento</th>
                    <th>Data Exclusão</th>
                    <th>Paciente</th>
                    <th>Procedimento</th>
                    <th>Usuário</th>
                    <th>Obs</th>
                </tr>
            </thead>
            <tbody>
                <%
                set logs = db.execute("select l.Data, l.Hora, l.DataHoraFeito, p.NomePaciente, proc.NomeProcedimento, lu.Nome, l.Obs from logsmarcacoes l LEFT JOIN pacientes p ON p.id=l.PacienteID LEFT JOIN procedimentos proc ON proc.id=l.ProcedimentoID LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=l.Usuario where l.ProfissionalID="&pP("id")&" and Data BETWEEN "&mydatenull(De)&" and "&mydatenull(A)&" AND l.ARX='X' order by l.Data, l.Hora")
                while not logs.eof
                    %>
                    <tr>
                        <td><%=logs("Data") & " - " & formatdatetime(logs("Hora"),3) %></td>
                        <td><%=logs("DataHoraFeito") %></td>
                        <td><%=logs("NomePaciente") %></td>
                        <td><%=logs("NomeProcedimento") %></td>
                        <td><%=logs("Nome") %></td>
                        <td><%=logs("Obs") %></td>
                    </tr>
                    <%
                logs.movenext
                wend
                logs.close
                set logs=nothing
                %>
            </tbody>
        </table>
        <%
    end if
    %>



<%
	pP.moveNext
	wend
	pP.close
	set pP=nothing

	%>
	<h2>Total: <%=qtdTotal%></h2>
	<%
end if%><!--#include file="disconnect.asp"-->


<script >
$(document).ready(function() {

    $.each($(".detalheAtendimentoResultado"), function() {
       $(this).dataTable( {
                      aoColumns: [ null,{ "sType": "date-uk" },null, null,null,null,null,null ],
                      ordering: true,
                      bPaginate: false,
                      bLengthChange: false,
                      bFilter: false,
                      bInfo: false,
                      bAutoWidth: false
                  } );

    });

         });
</script>

<script>
<!--#include file="jQueryFunctions.asp"-->
</script>
