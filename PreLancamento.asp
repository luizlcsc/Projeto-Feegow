<!--#include file="connect.asp"-->
<%
AtendimentoID = req("A")
PacienteID=req("I")
set pac = db.execute("select * from pacientes where id="&PacienteID)
if isnumeric(AtendimentoID) or AtendimentoID<>"" then
	db_execute("update sys_users set notiflanctos=replace(notiflanctos, '|"&AtendimentoID&"|', '')")
end if
%>

<div class="tabbable">
    <ul class="nav nav-tabs" id="myTab">
        <li class="active">
            <a data-toggle="tab" href="#Conta">
                <i class="green icon-money bigger-110"></i>
                Fechamento de Conta
            </a>
        </li>

        <li>
            <a data-toggle="tab" href="#Extrato" id="StatementTab" onclick="getStatement('3_<%=PacienteID%>', '', '')">
                <i class="green icon-exchange bigger-110"></i>
                Extrato
            </a>
        </li>
    </ul>

    <div class="tab-content">
        <div id="Conta" class="tab-pane active">
            <div class="page-header">
                <h1>Fechamento de Conta <small>&raquo; <%=pac("NomePaciente")%> &raquo; <%= accountBalance("3_"&PacienteID, 1) %></small></h1>
            </div>


























<%
set datas = db.execute("select distinct Data from agendamentoseatendimentos where PacienteID="&PacienteID&" order by Data desc")
while not datas.eof
%>
    <div class="widget-box">
        <div class="widget-header header-color-green">
            <h5>Bottom Toolbox (Footer)</h5>
            <div class="widget-toolbar">
                <a data-action="collapse" href="#"><i class="1 far fa-chevron-up bigger-125"></i></a>
            </div>
            <div class="widget-toolbar no-border">
                <button class="btn btn-xs btn-light bigger"><i class="far fa-arrow-left"></i>Prev</button>
                <button class="btn btn-xs bigger btn-yellow dropdown-toggle" data-toggle="dropdown">Next <i class="far fa-chevron-down icon-on-right"></i></button>
                <ul class="dropdown-menu dropdown-yellow pull-right dropdown-caret dropdown-close">
                    <li>
                        <a href="#">Action</a>
                    </li>
                    <li>
                        <a href="#">Another action</a>
                    </li>
                    <li>
                        <a href="#">Something else here</a>
                    </li>
                    <li class="divider"></li>
                    <li>
                        <a href="#">Separated link</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <div class="widget-body">
        <div class="widget-main">
            <div class="widget-toolbox padding-8 clearfix">
                
            </div>
        </div>
    </div>
<%
datas.movenext
wend
datas.close
set datas=nothing
%>




















            <div class="row">
              <div class="col-md-12">
                <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                    	<th></th>
                        <th width="5%">Data/Hora</th>
                        <th>Profissional</th>
                        <th>Procedimento</th>
                        <th>Valor Informado</th>
                    </tr>
                </thead>
                <tbody>
                <%
				set atend = db.execute("select agt.*, p.NomeProfissional, proc.NomeProcedimento from agendamentoseatendimentos as agt left join profissionais as p on p.id=agt.ProfissionalID left join procedimentos as proc on proc.id=agt.ProcedimentoID where PacienteID="&PacienteID)
				'complemento acima, pois será separado em 2 blocos, hoje e outros dias: &" and Data="&mydatenull(date())
                while not atend.eof
					ValorPlano = ""
					if rdValorPlano="V" then
						ValorPlano = formatnumber(atend("ValorPlano"), 2)
					else
						set conv = db.execute("select NomeConvenio from convenios where id = '"&atend("ValorPlano")&"'")
						if not conv.eof then
							ValorPlano = conv("NomeConvenio")
						end if
					end if
                    %>
                    <tr>
                    	<td><%=atend("Tipo")%></td>
                        <td nowrap="nowrap"><span class="label block"><%if atend("Data")=date() then response.Write("HOJE") else response.Write(atend("Data")) end if%></span>
                        <span class="label block"><%=formatdatetime(atend("HoraInicio"),3)%> - <%=formatdatetime(atend("HoraFim"),3)%></span></td>
                        <td><%=atend("NomeProfissional")%></td>
                        <td><%=atend("NomeProcedimento")%></td>
                        <td><%=atend("ValorPlano")%></td>
                    </tr>
                    <%
                atend.movenext
                wend
                atend.close
                set atend=nothing
                %>
                </tbody>
                </table>
              </div>
              <!--div class="col-md-3">
                <table class="table table-striped table-bordered table-hover">
                <thead>
                    <tr>
                        <th>Pr&eacute;-lan&ccedil;amentos</th>
                    </tr>
                </thead>
                <tbody>
                <%
				'set pre = db.execute("select ii.*, p.NomeProcedimento from itensinvoice as ii left join sys_financialinvoices as i on i.id=ii.InvoiceID left join procedimentos as p on ii.ItemID=p.id where ii.Executado like '' and i.sysActive=1 and ii.Tipo='S' and AccountID="&PacienteID&" and AssociationAccountID=3")
				'while not pre.eof
					%>
					<tr>
                    	<td><%'=pre("NomeProcedimento")%></td>
                    </tr>
					<%
'				pre.movenext
'				wend
'				pre.close
'				set pre=nothing
				%>
                </tbody>
                </table>
              </div-->
            </div>

		</div>
        <div id="Extrato" class="tab-pane">
        Carregando...
        </div>
    </div>
</div>






































<%
'ITENS ANTIGOS A AVALIAR SE VALE A PENA MANTER
'2. Apenas para ficar uma notificação, caso ache coisas que não são este atendimento. Ve se ha lanctos feitos hoje para este profissional
set itensinvoice = db.execute("select * from itensinvoice where ( AgendamentoID=0 or isnull(AgendamentoID) ) and ( ProfissionalID="&session("idInTable")&" or isnull(ProfissionalID) or ProfissionalID=0 ) and ( isnull(DataExecucao) or DataExecucao="&mydatenull(date())&" )")
if not itensinvoice.eof then
	%>
	<h4>Lan&ccedil;amentos existentes ainda n&atilde;o executados</h4>
	<table class="table table-striped table-hover">
	<%
	while not itensinvoice.eof
		%>
		<tr>
			<td></td>
			<td></td>
		</tr>
		<%
	itensinvoice.movenext
	wend
	itensinvoice.close
	set itensinvoice=nothing
	%>
	</table>
	<%
end if
%>

<script>
<!--#include file="financialCommomScripts.asp"-->
</script>