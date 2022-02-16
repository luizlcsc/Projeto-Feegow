<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
Obs = req("Obs")&""
NomePaciente = ""


set pac = db.execute("select * from pacientes where id="&req("PacienteID"))
if not pac.eof then
    NomePaciente = pac("NomePaciente")
	LabelPaciente = pac("id")&" - "&pac("NomePaciente")
end if

if Obs&"" = "1" then 
    response.write(pac("Observacoes"))
    response.end()
end if
%>

<style type="text/css">
    .form-control {
        text-transform: uppercase;
    }
</style>

<div class="panel">
    <form id="pacienteForm">
		<div class="panel collapse show">
            <div class="panel-heading">
	            <span class="panel-title" data-toggle="collapse" data-target="#demo" style="cursor: pointer;"> Dados Paciente - <%=LabelPaciente%> </span>
                <a href='?P=Pacientes&I=<%=PacienteID%>&Pers=1' target='_blank'>Ver Cliente</a>
            </div>
            <div id="demo" class="collapse in panel-body">
                <div >
                    <div class="alert alert-danger hidden" id="divComparaPacientes">
                        <button class="close" data-dismiss="alert" type="button" onclick="fecharModal()"><i class="far fa-remove"></i></button>
                        <span></span>
                    </div>

                    <input type="hidden" name="idpaciente" value="<%=PacienteID%>">
                    <div class="col-md-12">
                        <%= quickField("text", "Nome", "Nome", 8, NomePaciente, "", "", " autocomplete='nomepaciente' ") %>
                        <%=quickField("text", "CPF", "CPF", 2, pac("CPF"), " input-mask-cpf", "", "") %>
                        <%=quickField("datepicker", "Nascimento", "Nascimento", 2, pac("Nascimento"), "input-mask-date", "", "")%>
                    </div>

                    <div class="col-md-12">
                        <%= quickField("phone", "Tel1", "Telefone", 4, pac("tel1"), "", "", " autocomplete='tel1' ") %>
                        <%= quickField("mobile", "Cel1", "Celular", 4, pac("cel1"), "", "", " autocomplete='cel1'  ") %>
                        <%= quickField("mobile", "Cel2", "&nbsp;", 4, pac("cel2"), "", "", " autocomplete='cel2' ") %>
                    </div>

                    <div class="col-md-12">
                        <span style="font-size: 9px; width: 8px; position: absolute; left: 50px; min-width: 80px; z-index: 5;top: 5px" ><a href="http://www.buscacep.correios.com.br/sistemas/buscacep/buscaCepEndereco.cfm" target="_blank">Não sei o CEP</a></span>
                        <%= quickField("text", "Cep", "Cep", 4, pac("cep"), "input-mask-cep", "", " autocomplete='cep' ") %>
                        <%= quickField("text", "Endereco", "Endere&ccedil;o", 4, pac("endereco"), "", "", " autocomplete='endereco' ") %>
                        <%= quickField("text", "Numero", "N&uacute;mero", 2, pac("numero"), "", "", "") %>
                        <%= quickField("text", "Complemento", "Compl.", 2, pac("complemento"), "", "", " autocomplete='complemento' ") %>
                    </div>

                    <div class="col-md-10">
                        <%= quickField("text", "Bairro", "Bairro", 4, pac("bairro"), "", "", " autocomplete='bairro' ") %>
                        <%= quickField("text", "Cidade", "Cidade", 4, pac("cidade"), "", "", " autocomplete='cidade' ") %>
                        <%= quickField("text", "Estado", "Estado", 4, pac("estado"), "", "", " autocomplete='estado-uf' ") %>
                        </div>
                    <div class="col-md-2">
                        <%= selectInsert("País", "Pais", pac("Pais"), "paises", "NomePais", "", "", "") %>
                    </div>
            
                    <div class="col-md-12">
                        <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, pac("Observacoes"), "", "", "") %>
                    </div>

                    <div class="col-md-13 mr10 mt20 pull-right">
                       <!-- <button class="btn btn-sm btn-default" onclick="return false;" data-toggle="collapse" data-target="#demo">Fechar</button> -->
                        <button class="btn btn-sm btn-primary btnsalvar" type="button"  data-toggle="collapse" data-target="#demo"><i class="far fa-save"></i> Salvar</button>
                    </div>
                </div>
            </div> 
        </div>                               
    </form>
</div>
<div class="panel">
    <div class="">

        <ul class="nav nav-tabs">
            <li class="active"><a data-toggle="tab" href="#agdFuturo">Agendamentos Futuros <span class="badge badge-default badgefuturo">0</span></a></li>
            <li><a data-toggle="tab" href="#agendamentosantigos">Agendamentos <span class="badge badge-default badgeagendamento">0</span></a></li>
            <li><a data-toggle="tab" href="#propostas" href="#">Propostas <span class="badge badge-default badgeproposta">0</span></a></li>
            <li><a data-toggle="tab" href="#agendamentos" href="#">Excluídos <span class="badge badge-default badgeexcluido">0</span></a></li>
            <li><a data-toggle="tab" href="#pendencias" href="#">Pendências <span class="badge badge-default badgependencia">0</span></a></li>
            <li><a data-toggle="tab" href="#contas" href="#">Contas <span class="badge badge-default badgecontas">0</span></a></li>
        </ul>
    
    <div class="tab-content m15">
    <div id="agdFuturo" class="active tab-pane">
    <form method="post" id="formAgdFut">
    <table class="table footable fw-labels table-condensed" data-page-size="20">
        <thead>
            <tr>
                <th>Status</th>
                <th>Data/Hora</th>
                <th>Profissional</th>
                <th>Especialidade</th>
                <th>Procedimento</th>
                <th>Valor/Convênio</th>
                <th></th>
            </tr>
        </thead>
        <tbody>

        <%
	    c = 0
        temNovoPagamento = 0
	    agends = ""

        set pCons = db.execute("select a.id, a.rdValorPlano, a.ValorPlano, a.Data, a.Hora, a.StaID, a.Procedimentos, s.StaConsulta,p.id as ProcedimentoID, p.NomeProcedimento, " &_
        " c.NomeConvenio, prof.NomeProfissional, esp.Especialidade NomeEspecialidade FROM agendamentos a LEFT JOIN profissionais prof on prof.id=a.ProfissionalID " &_
        " LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID or (a.EspecialidadeID is null and prof.EspecialidadeID=esp.id) " &_
        " LEFT JOIN procedimentos p on a.TipoCompromissoID=p.id LEFT JOIN staconsulta s ON s.id=a.StaID LEFT JOIN convenios c on c.id=a.ValorPlano " &_
        " WHERE DATE_FORMAT(a.Data, '%Y-%m-%d') >= DATE_FORMAT(now(),'%Y-%m-%d') AND a.PacienteID="&PacienteID&" ORDER BY a.Data ASC, a.Hora ASC")

        while not pCons.EOF

            jaTemValorPago = 0

            'Buscar a movement dos agendamentos
            sqlMovement = "select mov.id as movementID,ii.InvoiceID, SUM(mov.ValorPago) ValorPago, SUM(mov.Value) Value from sys_financialmovement mov INNER JOIN sys_financialinvoices inv ON inv.id = mov.InvoiceID " &_
                    " LEFT JOIN itensinvoice ii ON ii.InvoiceID = inv.id WHERE ii.AgendamentoID = " & pCons("id") & " GROUP BY(ii.AgendamentoID)"

            set Movs = db.execute(sqlMovement)

            InvoiceID = ""

            if not Movs.eof then
                InvoiceID = Movs("InvoiceID")
            end if

		    c = c+1
            valorPagar = 0
		    if pCons("rdValorPlano")="V" then
                'if aut("areceberareceberpaciente") then
    			    Pagto = "R$ " & formatnumber(0&pCons("ValorPlano"), 2)
                    valorPagar = pCons("ValorPlano")
                'else
                '    Pagto = ""
                'end if
		    else
			    Pagto = pCons("NomeConvenio")
		    end if
		    agends = agends & pCons("id") & ","

		    consHora = pCons("Hora")
		    if not isnull(consHora) then
			    consHora = formatdatetime(consHora, 4)
		    end if


            select case pCons("StaID")
                case 1
                    classe = "alert"
                case 2, 3
                    classe = "success"
                case 4
                    classe = "warning"
                case 5, 8
                    classe = "primary"
                case 6, 11
                    classe = "danger"
                case else
                    classe = "dark"
            end select

            NomeProcedimento = pCons("NomeProcedimento")
            VariosProcedimentos = pCons("Procedimentos")&""
            if VariosProcedimentos<>"" then
                NomeProcedimento = VariosProcedimentos
            end if

            %>
            <tr class="row-<%=classe %>" onclick="">
                <td class="pn">
                    <span class="label label-<%=classe %> mn">
                        <%=left(pCons("StaConsulta"), 18) %>
                    </span>
                </td>
                <td><%=imoon(pCons("StaID"))%> &nbsp; <%=pCons("Data")&" - "&consHora %></td>
                <td><%=left(pCons("NomeProfissional"), 30) %></td>
                <td><%=left(pCons("NomeEspecialidade"), 30) %></td>
                <td><%=left(NomeProcedimento, 30) %></td>
                <td><%=Pagto%></td>
                <td>
                    <div class="btn-group">
                        <a title="Imprimir" data-toggle="tab" href="#recibosgerados"  onclick='$.get("listaRecibos.asp?Externo=true&InvoiceID=" +<%=InvoiceID%> , function (data) {$("#recibosgerados").html(data+"<div class=\"text-right\"><a data-toggle=\"tab\" href=\"#agdFuturo\" >Voltar</a></div>") });' class="btn btn-default btn-xs" data-agendamentoid="<%= pCons("id") %>"><i class="far fa-print"></i></a>
                        <button title="Detalhes" class="btn btn-default btn-xs" data-agendamentoid="<%= pCons("id") %>" id="hist<%=pCons("id")%>"><i class="far fa-info-circle"></i></button>
                        <% if jaTemValorPago = 0 then %>
                        <a title="Remarcar" class="btn btn-default btn-xs" onclick="remarcar('<%=pCons("id")%>')" href="#"> <i class="far fa-calendar"></i> </a>
                        <% end if %>
                        <a class="btn btn-default btn-xs" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=pCons("id")%>" target="_blank" title="Ir para agendamento"><i class="far fa-external-link"></i></a>
                        <%
                            set sql = db.execute("SELECT PendenciaID FROM pendenciasagendamentos WHERE AgendamentoID ="&pCons("id"))

                            if not sql.eof then
                        %>
                            <button class="btn btn-danger btn-xs" onclick="voltarPendencia('<%=pCons("id")%>', '<%=pCons("ProcedimentoID")%>')">Pendência</button>
                        <%
                            end if
                        %>
                    </div>
                    <div id="divhist<%=pCons("id")%>" class="ResultSearchInput" style="position:absolute; display:none;z-index: 99999; padding:0; margin-left:-740px; width:800px; height:200px; overflow-y:scroll">Carregando...</div>

                </td>
            </tr>
            <%
        pCons.MoveNext
        wend
        pCons.close
        set pCons=nothing

	    if c=0 then
		    txt = "Nenhum agendamento."
	    elseif c=1 then
		    txt = "1 agendamento."
	    else
		    txt = c& " agendamentos."
	    end if
    %>
    </tbody>
    </table>
        <input id="AccountID" type="hidden" name="AccountID" value="<%= "3_"& PacienteID %>" />
    </form>
    <div class="row">
	    <div class="col-xs-8">
    	    <%=txt%>
        </div>
    </div>
    </div>
    <script>$(function(){ if('<%=c%>' == 0) { $(".badgefuturo").hide() } $(".badgefuturo").html('<%=c%>') })</script>

    <div id="propostas" class="tab-pane">
    <table class="table footable fw-labels table-condensed" data-page-size="20">
        <thead>
            <tr>
                <th>Data</th>
                <th>Executor</th>
                <th>Valor</th>
                <th>Desconto</th>
                <th>3x</th>
                <th>6x</th>
                <th>Status</th>
                <th>
                    <a href="#" class="btn btn-xs btn-success pull-right" onclick="propostas()">
                        <i class="far fa-plus"></i> Nova proposta
                    </a>
                </th>
            </tr>
        </thead>

        <tbody>
        <%
        c = 0
        sqlProposta = "SELECT *, pp.NomeProfissional, p.id as idproposta, (select SUM(ValorUnitario) from itensproposta ipp where ipp.PropostaID = p.id) valorTotal, " &_
        " (select SUM(Desconto) from itensproposta ipp where ipp.PropostaID = p.id) valorDesconto FROM propostas p " &_
        " LEFT JOIN profissionais pp ON pp.id= p.ProfissionalID  " &_
        " LEFT JOIN propostasstatus ps ON ps.id= p.StaID WHERE p.sysActive=1 AND p.StaID = 1 "
        PacienteID = req("PacienteID")

        if PacienteID <> "" then
            sqlProposta = sqlProposta & " AND p.PacienteID = " & PacienteID
        end if


        sqlProposta = sqlProposta & " ORDER BY p.DataProposta desc "
        set propostaSQL = db.execute(sqlProposta)

        while not propostaSQL.EOF
            c = c + 1

            valorTotal = 0
            Desconto = 0

            if propostaSQL("valorTotal")&"" <> "" then
                valorTotal = propostaSQL("valorTotal")
            end if

            if propostaSQL("valorDesconto")&"" <> "" then
                Desconto = propostaSQL("valorDesconto")
            end if

            tresVezes = (valorTotal - Desconto) / 3
            seisVezes = (valorTotal - Desconto) / 6

        %>
            <tr>
                <td><%=propostaSQL("DataProposta")%></td>
                <td><%=propostaSQL("NomeProfissional") %></td>
                <td><% if propostaSQL("valorTotal")&"" <> "" then
                     response.write("R$ " & formatnumber(propostaSQL("valorTotal")))
                    end if %></td>
                <td><% if propostaSQL("valorDesconto")&"" <> "" then
                     response.write("R$ " & formatnumber(propostaSQL("valorDesconto")))
                    end if %></td>
                <td><%= "R$ " & formatnumber(tresVezes) %></td>
                <td><%= "R$ " & formatnumber(seisVezes) %></td>
                <td><%=propostaSQL("NomeStatus")%></td>
                <td>
                <div class="btn-group pull-right">
                    <button title="Detalhes" class="btn btn-default btn-xs" data-propostaid="<%= propostaSQL("idproposta") %>" id="prophist2<%=propostaSQL("idproposta")%>"><i class="far fa-info-circle"></i></button>
                    <a title="Ir para agendamento" class="btn btn-default btn-xs" href="./?P=PacientesPropostas&Pers=1&I=&PropostaID=<%=propostaSQL("idproposta")%>" target="_blank" title="Ir para proposta"><i class="far fa-external-link"></i></a>
                </div>
                    <div id="divhist2<%=propostaSQL("idproposta")%>" style="position:absolute; display:none;z-index: 99999; background-color:#fff; margin-left:-740px; border:1px solid #2384c6; width:800px; height:200px; overflow-y:scroll">Carregando...</div>
                </td>
            </tr>
        <%
            propostaSQL.movenext
        wend
        %>
        </tbody>
    </table>
    </div>
    <script>$(function(){ if('<%=c%>' == 0) { $(".badgeproposta").hide() } $(".badgeproposta").html('<%=c%>') })</script>

    <div id="agendamentosantigos" class="tab-pane">
    <table class="table footable fw-labels table-condensed" data-page-size="20">
        <thead>
            <tr>
                <th>Status</th>
                <th>Data/Hora</th>
                <th>Profissional</th>
                <th>Especialidade</th>
                <th>Procedimento</th>
                <th>Valor/Convênio</th>
            </tr>
        </thead>
        <tbody>

        <%
	    c = 0

	    agends = ""

        set pCons = db.execute("select a.id, a.rdValorPlano, a.ValorPlano, a.Data, a.Hora, a.StaID, a.Procedimentos, s.StaConsulta, p.NomeProcedimento, " &_
        " c.NomeConvenio, prof.NomeProfissional, esp.Especialidade NomeEspecialidade FROM agendamentos a LEFT JOIN profissionais prof on prof.id=a.ProfissionalID "&_
        " LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID or (a.EspecialidadeID is null and prof.EspecialidadeID=esp.id) " &_
        " LEFT JOIN procedimentos p on a.TipoCompromissoID=p.id LEFT JOIN staconsulta s ON s.id=a.StaID LEFT JOIN convenios c on c.id=a.ValorPlano " &_
        " WHERE DATE_FORMAT(a.Data, '%Y-%m-%d') < DATE_FORMAT(now(),'%Y-%m-%d') AND a.PacienteID="&PacienteID&" ORDER BY a.Data DESC, a.Hora DESC LIMIT 20")

        while not pCons.EOF
		    c = c+1
		    if pCons("rdValorPlano")="V" then
                if aut("areceberareceberpaciente") then
    			    Pagto = "R$ " & formatnumber(0&pCons("ValorPlano"), 2)

                else
                    Pagto = ""
                end if
		    else
			    Pagto = pCons("NomeConvenio")
		    end if
		    agends = agends & pCons("id") & ","

		    consHora = pCons("Hora")
		    if not isnull(consHora) then
			    consHora = formatdatetime(consHora, 4)
		    end if


            select case pCons("StaID")
                case 1
                    classe = "alert"
                case 2, 3
                    classe = "success"
                case 4
                    classe = "warning"
                case 5, 8
                    classe = "primary"
                case 6, 11
                    classe = "danger"
                case else
                    classe = "dark"
            end select

            NomeProcedimento = pCons("NomeProcedimento")
            VariosProcedimentos = pCons("Procedimentos")&""
            if VariosProcedimentos<>"" then
                NomeProcedimento = VariosProcedimentos
            end if
            %>
            <tr class="row-<%=classe %>" onclick="">
                <td class="pn">
                    <span class="label label-<%=classe %> mn">
                        <%=left(pCons("StaConsulta"), 18) %>
                    </span>
                </td>
                <td><%=imoon(pCons("StaID"))%> &nbsp; <%=pCons("Data")&" - "&consHora %></td>
                <td><%=left(pCons("NomeProfissional"), 30) %></td>
                <td><%=left(pCons("NomeEspecialidade"), 30) %></td>
                <td><%=left(NomeProcedimento, 30) %></td>
                <td><%=Pagto%></td>
                <td>
                    <div class="btn-group">
                        <button title="Detalhes" class="btn btn-default btn-xs" data-agendamentoid="<%= pCons("id") %>" id="hist<%=pCons("id")%>"><i class="far fa-info-circle"></i></button>
                        <a class="btn btn-default btn-xs" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=pCons("id")%>" target="_blank" title="Ir para agendamento"><i class="far fa-external-link"></i></a>
                    </div>
                    <div id="divhist<%=pCons("id")%>" class="ResultSearchInput" style="position:absolute; display:none;z-index: 99999; padding:0; margin-left:-740px; width:800px; height:200px; overflow-y:scroll">Carregando...</div>
                </td>
            </tr>
            <%
        pCons.MoveNext
        wend
        pCons.close
        set pCons=nothing

	    if c=0 then
		    txt = "Nenhum agendamento."
	    elseif c=1 then
		    txt = "1 agendamento."
	    else
		    txt = c& " agendamentos."
	    end if
    %>
    </tbody>
    </table>
    <div class="row">
	    <div class="col-xs-12">
    	    <%=txt%>
        </div>
    </div>
    </div>
    <script>$(function(){ if('<%=c%>' == 0) { $(".badgeagendamento").hide() }  $(".badgeagendamento").html('<%=c%>') })</script>

  <style>
        .accountBalance{
            display: none !important;
        }
    </style>
    <div id="contas" class="tab-pane">
        <% TiposFaturas = "Particular" %>
        <% NaoExibirPago = TRUE %>
        <% function ExecuteBotton(InvoiceID) %>
            <a data-toggle="tab" href="#recibosgerados"  onclick='$.get("listaRecibos.asp?Externo=true&InvoiceID=" +<%=InvoiceID%> , function (data) {$("#recibosgerados").html(data+"<div class=\"text-right\"><a data-toggle=\"tab\" href=\"#agdFuturo\" >Voltar</a></div>") });' class="btn btn-info btn-xs"><i class="far fa-print"></i></a>
        <% end function %>
        <% 
            ExecuteBottonStr = "ExecuteBotton" 
            origemHistorico = "sim"
        %>

        <!--#include file="contaNewContent.asp"-->
<script>$(function(){ if('<%=c%>' == 0) { $(".badgecontas").hide() } $(".badgecontas").html(' - ') })</script>        
    </div>
    <script>
    function ajxContent(a,b){
          window.open('?P=invoice&Pers=1&I='+b, '_blank');
    }
    </script>
    <div id="agendamentos" class="tab-pane">
    <%
	c = 0
	if agends<>"" then
		agends = left(agends, len(agends)-1)
        sql = "select l.*, p.NomeProcedimento, prof.NomeProfissional, s.StaConsulta FROM logsmarcacoes l LEFT JOIN procedimentos p on p.id=l.ProcedimentoID LEFT JOIN staconsulta s on s.id=l.Sta LEFT JOIN profissionais prof on prof.id=l.ProfissionalID WHERE l.PacienteID="&PacienteID&" AND ARX = 'X' AND l.ConsultaID NOT IN("&agends&") GROUP BY l.ConsultaID"
		set logs = db.execute(sql)
    else
        sql = "select l.*, p.NomeProcedimento, prof.NomeProfissional, s.StaConsulta FROM logsmarcacoes l LEFT JOIN procedimentos p on p.id=l.ProcedimentoID LEFT JOIN staconsulta s on s.id=l.Sta LEFT JOIN profissionais prof on prof.id=l.ProfissionalID WHERE l.PacienteID="&PacienteID&" AND ARX = 'X' GROUP BY l.ConsultaID"
		set logs = db.execute(sql)
    end if
    
		    if not logs.eof then
		    %>
		    <h4>Agendamentos excluídos</h4>
		    <%
		    end if
		    while not logs.eof
            c = c + 1
			    %>

                <div class="panel panel-default" style="margin-bottom: 5px !important;">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a class="accordion-toggle red" data-toggle="collapse" data-parent="#accordion" onClick="log(<%=logs("ConsultaID")%>)" href="#collapse<%=logs("ConsultaID")%>">
                              <div class="row" style="padding: 15px;">
                                <div class="col-xs-3"><%="<img src=""assets/img/"&logs("Sta")&".png"">"%>&nbsp;<% if logs("Data")&"" <> "" then %>
                                 <%=formatdatetime(logs("Data"), 2)%> - <% end if %> <% if logs("Hora")&"" <> "" then %> <%=formatdatetime(logs("Hora"),4)%> <% end if %></div>
                                <div class="col-xs-3"><%=left(logs("NomeProfissional")&" ", 30)%></div>
                                <div class="col-xs-2"><%=left(logs("NomeProcedimento")&" ", 15)%></div>

                                <div class="col-xs-2">
                                    <%=left(logs("StaConsulta"), 18)%>
                                </div>
                                <div class="col-xs-2">
                                    <%=Pagto%>
                                    <i class="far fa-angle-down bigger-110 pull-right" data-icon-hide="far fa-angle-down" data-icon-show="far fa-angle-right"></i>
                                </div>
        
                              </div>
                            </a>
                        </h4>
                    </div>
        
                    <div class="panel-collapse collapse panel-body" id="collapse<%=logs("ConsultaID")%>">
                        <div id="hist<%=logs("ConsultaID")%>">
                            Carregando...
                        </div>
                    </div>
                </div>
			    <%
		    logs.movenext
		    wend
		    logs.close
		    set logs=nothing
        %>
        </div>

        <script>$(function(){ if('<%=c%>' == 0) { $(".badgeexcluido").hide() } $(".badgeexcluido").html('<%=c%>') })</script>
        
        <div id="pendencias" class="tab-pane">

        <table class="table table-striped table-condensed">
            <thead>
                <tr>
                    <th>Paciente</th>
                    <th>Zona</th>
                    <th>Itens</th>
                    <th>Data</th>
                    <th>Hora</th>
                    <th>Status</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
        <%
        c = 0
        sqlPendencias = "SELECT pend.*, NomeStatus, pac.NomePaciente, ps.NomeStatus, DATE_FORMAT(pend.sysDate,'%d/%m/%Y') AS `Data`, DATE_FORMAT(pend.sysDate,'%H:%i') AS `Hora` FROM pendencias pend LEFT JOIN pendencia_timeline t ON t.PendenciaID = pend.id AND t.Ativo = 1 LEFT JOIN pacientes pac ON pac.id= pend.PacienteID LEFT JOIN cliniccentral.pendencia_executante_status ps ON ps.id = t.StatusID WHERE pend.sysActive=1 AND pend.StatusID != 6"
        PacienteID = req("PacienteID")
        
        if PacienteID <> "" then
            sqlPendencias = sqlPendencias & " AND pac.ID = " & PacienteID
        end if

        sqlPendencias = sqlPendencias & " ORDER BY pend.sysDate"

        set PendenciasSQL = db.execute(sqlPendencias)

        while not PendenciasSQL.eof
            c = c + 1
            temProcedimento = 1

            if ProcedimentoID <> "" then
                set temProc = db.execute("SELECT count(pp.id)Qtd FROM pendencia_procedimentos pp inner join agendacarrinho ac on ac.id = pp.BuscaID  WHERE   ProcedimentoID = " & ProcedimentoID & " AND  PendenciaID="&PendenciasSQL("id") & "  ")
                temProcedimento = ccur(temProc("Qtd"))
            end if 
            
            if Status <> "" then
                set temProc = db.execute("SELECT count(pp.id)Qtd FROM pendencia_procedimentos pp inner join pendencia_contatos_executantes ppe on ppe.PendenciaProcedimentoID = pp.id  WHERE   ppe.StatusID = " & Status & " AND  PendenciaID="&PendenciasSQL("id") & "  ")
                temProcedimento = ccur(temProc("Qtd"))
            end if 

            'if temProcedimento > 0 then 
                set ItensSQL = db.execute("SELECT count(id)Qtd FROM pendencia_procedimentos WHERE PendenciaID="&PendenciasSQL("id"))
                Itens = ccur(ItensSQL("Qtd"))
                StatusPendencia="Pendente"

        %>
        <tr>
            <td><%=PendenciasSQL("NomePaciente")%></td>
            <td><%=replace((PendenciasSQL("Zonas")&""), "|","")%></td>
            <td class="item" style="cursor:pointer;" data-value="<%=PendenciasSQL("id") %>"><%=ItensSQL("Qtd")%></td>
            <td><%="<code>"& replace( PendenciasSQL("Data") &"", ", ", "</code> <code>") &"<code>" %></td>
            <td><%=PendenciasSQL("Hora")%></td>
            <td><%=PendenciasSQL("NomeStatus") %></td>
            <td nowrap>
                <button onclick="GerenciarPendencia('<%=PendenciasSQL("id")%>')" type="button" class="btn btn-xs btn-warning"><i class="far fa-cog"></i></button>
            </td>
        </tr>

        <%
            'end if
            PendenciasSQL.movenext
        wend
    PendenciasSQL.close
    set PendenciasSQL = nothing
    %>
        
</table>
        </div>
        <div id="recibosgerados" class="tab-pane">Carregando...</div>

        </div>

        <script>$(function(){ if('<%=c%>' == 0) { $(".badgependencia").hide() }  $(".badgependencia").html('<%=c%>') })</script>
    </div>
    
</div>

<script type="text/javascript">
    <!--#include file="JQueryFunctions.asp"-->
    function log(id){
        $.get("logsAgendamentos.asp?PacienteID=<%=PacienteID%>&AgendamentoID=" + id, function (data) {
            $("#hist"+id).next().find("td").html(data);
            $(".panel-body").filter("#hist"+id).html(data);
        });
    }

    $("[id^=hist]").on("click", function () {
        AI = $(this).attr("data-agendamentoid");
        $("#agendativo").val(AI);
        $("#div" + $(this).attr("id")).css("display", "block");
        if($("#div" + $(this).attr("id")).html()=="Carregando..."){
            $.get("logsAgendamentos.asp?PacienteID=<%=PacienteID%>&AgendamentoID="+ AI, function (data) {
                $("#divhist" + AI).html( data );
            });
        }
        return false;
    });

    $("[id^=prophist2]").on("click", function () {
        AI = $(this).attr("data-propostaid");
        $("#divhist2" + AI).css("display", "block");
        if($("#divhist2" + AI).html()=="Carregando..."){
            $.get("logsProposta.asp?PacienteID=<%=PacienteID%>&PropostaID="+ AI, function (data) {
                $("#divhist2" + AI).html( data );
            });
        }
        return false;
    });

    
    function comparaPaciente(T) {
        $.post("ComparaPacientes.asp?T=" + T, { I: <%= PacienteID %>, No: $("#Nome").val(), Na: $("#Nascimento").val(), C: $("#CPF").val(), S: $("#Sexo").val() }, function (data) {
            if (T == 'Conta') {
                eval(data);
            } else {
                $("#modal-components").modal('hide');
                $("#div-descontos-pendentes").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
                $("#modal-descontos-pendentes").css( 'z-index', 999999900999999999999999);
                $("#modal-descontos-pendentes").modal("show");
                $("#div-descontos-pendentes").html(data);
            }
        });
    }

    comparaPaciente('Conta');

    <!--#include file="financialCommomScripts.asp"-->
    $("#Cep").keyup(function(){
	    getEndereco();
    });
    
    var resultadoCEP

    function getEndereco() {
		var temUnder = /_/i.test($("#Cep").val())
		if(temUnder == false){
			$.getScript("webservice-cep/cep.php?cep="+$("#Cep").val(), function(){
				if(resultadoCEP["logradouro"]!=""){
					$("#Endereco").val(unescape(resultadoCEP["logradouro"]));
					$("#Bairro").val(unescape(resultadoCEP["bairro"]));
					$("#Cidade").val(unescape(resultadoCEP["cidade"]));
					$("#Estado").val(unescape(resultadoCEP["uf"]));
					if(resultadoCEP["pais"]==1){
					    $("#Pais").html("<option value='1'>Brasil</option>").val(1).change();
					}
					$("#Numero").focus();
				}else{
					$("#Endereco").focus();
				}
			});
		}
    }

    function sairCampo(value){
        if(value == ""){
            naoSalvo = false;
        }
    }

    function mesclar(p1, p2){
        if(confirm('ATENÇÃO: Esta ação unirá as informações das duas fichas em uma só. \n Confirme apenas se os dois cadastros forem de um mesmo paciente.')){
            //window.open("mesclar.asp?p1="+p1+"&p2="+p2);
            location.href="mesclar.asp?p1="+p1+"&p2="+p2;
        }
    }

    $(".btn-system").hide();

    $(".btnsalvar").on('click', function(){
        var btnsav = true;
        var nome = $("#Nome").val().toUpperCase();
        var nascimento = $("#Nascimento").val();
        var cel1 = $("#Cel1").val();
        var tel1 = $("#Tel1").val();

        if(nome == "" || nascimento == "" || (cel1 == "" && tel1 == "")){
            var btnsav = false;
            new PNotify({
                title: 'Error!',
                text: 'Preencha os campos nome, celular ou telefone e nascimento.',
                type: 'danger',
                delay: 2500
            });
        }else{
            $.ajax({
                type:"POST",
                url:"savepaciente.asp",
                data:$("#pacienteForm").serialize(),
                success:function(data){
                    eval(data);
                }
            });
        }
        if(btnsav){
            $('#demo').collapse({
            toggle: true
            });
        }
        return false;
    });

    function GerenciarPendencia(PendenciaID) {
        window.open("./?P=AdministrarPendencia&Pers=1&I="+PendenciaID,"_blank")
    }

    function remarcar(id){
        $.post('adicionarCarrinhoReagendar.asp', { PacienteID : <%=PacienteID %>,id : id, sessaoAgenda: sessionStorage.getItem('sessaoAgenda') }, function(result){
            eval(result)
        })
    }

    function pagarTodos(){
        var ids = "";
        $(".parcela").each(function(i, value) {
            if($(this).is(":checked")){
                if(ids == ""){
                    ids = "Parcela=" + value.value
                }else{
                    ids += "&Parcela=" + value.value
                }
            }
        })

        if(ids != ""){
            $( "#pagar" ).draggable();
            $("#pagar").show();
            $.post("pagar.asp?T=C&origemHistorico=<%=origemHistorico%>", $(".parcela").serialize(), function(data){
                $("#pagar").html(data);
            });
        }
    }

    function geraParcelas(recalc){
        $.post("HistoricoAgendamentoFuturo.asp", {
            PacienteID : "<%=PacienteID%>"
        }, function(data){
            $("#agdFuturo").html(data)
        })
    }

    function modalPagamento()
    {
        if($(".parcela").val() != undefined){
            $(".parcela").each(function(){
                let pendID = "pend"+$(this).val().split("|").join("")
                let parcelaID = "Parcela"+$(this).val().split("|").join("")
                let checkPend = $("#"+pendID).text().includes("de");
                if (checkPend === true) {
                    $("#"+parcelaID).prop('checked', true);
                    pagarTodos();
                }
            })
        }
    }

    $(function() {
        modalPagamento();
    });

    function voltarPendencia(AgendamentoID, ProcedimentoID) {

        $("#formAgdFut").submit(function(e){
            e.preventDefault();
        });

        $.post('savePendencia.asp', {AgendamentoID: AgendamentoID, ProcedimentoID: ProcedimentoID, acao: 'VoltarParaPendencia' }, function(result){
            eval(result);
            paciente();

        })
    }

    $(document).ajaxComplete(function(event,request, settings){
        if ( settings.url === "savePagto.asp" ) {
            paciente();
        }
    });
</script>