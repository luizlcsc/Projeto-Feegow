<%
'on error resume next
%>
<style>
#modal-fimtestecontent {
	border-radius:30px!important;
}
</style>

        <!-- animsition.css -->
        <link rel="stylesheet" href="./dist/css/animsition.min.css">
        <!-- jQuery -->
        <script src="assets/js/jquery.1.11.0.min.js"></script>
        <!-- animsition.js -->
        <script src="./dist/js/animsition.min.js"></script>



<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
<!--#include file="atualizabanco2.asp"-->
<iframe src="ajustaHora.asp" width="1" height="1" frameborder="0"></iframe>
<%
if date()<cdate("22/01/2016") then
	set cp = db.execute("select * from cliniccentral.conversaoagenda where LicencaID="&replace(session("banco"), "clinic", "")&" and Resultado<>'S'")
	if not cp.eof then
	%>
		<div class="alert alert-info text-center">
			<button class="close" data-dismiss="alert" type="button">
				<i class="fa fa-remove"></i>
			</button>
			<strong><i class="fa fa-chat"></i> Prezado usuário, confira o novo layout da agenda. Dúvidas? Entre em contato ou assista ao <A class="btn btn-xs btn-info" href="https://www.youtube.com/watch?v=y4eoqSK_z1Q" target="_blank"><i class="fa fa-video-camera"></i> vídeo</A>.</strong>
		</div>
	<%
	end if
end if
if session("Status")="C" then
	set baf = db.execute("select l.Cliente from cliniccentral.licencas l where l.id="&replace(session("Banco"), "clinic", ""))
	if not baf.EOF then
		idBafim = baf("Cliente")
		set pContaCentral=db.execute("select * from bafim.contascentral where Tabela='Paciente' and ContaID like '"&idBafim&"'")
		if not pContaCentral.eof then
			idConta=pContaCentral("id")
			set ppac=db.execute("select * from bafim.paciente where id="&pContaCentral("ContaID"))
			if not ppac.eof then
				BNome=ppac("Nome")
				BEndereco=ppac("Endereco")
				BCidade=ppac("Cidade")
				BEstado=ppac("Estado")
				BCep=ppac("Cep")
			end if



			set pReceitas=db.execute("select * from bafim.receitasareceber where Paciente="&idConta&" order by Vencimento desc")
			while not pReceitas.eof
				exibe="N"
				CId = pReceitas("id")
				%>
				<!--#include file="minhasFaturasCalculo.asp"-->
				<%
				if cdate(datdate(pReceitas("Vencimento")))<dateadd("d",-2,date()) then
					exibe="S"
				end if
				if msg="QUITADA" then
					exibe="N"
				end if
				if exibe="S" then
					MostraCobranca="S"
				end if
			pReceitas.moveNext
			wend
			pReceitas.close
			set pReceitas=nothing




		end if
	end if
	if MostraCobranca="S" then
	%>
    <div class="alert alert-danger text-center">
        <button class="close" data-dismiss="alert" type="button">
            <i class="fa fa-remove"></i>
        </button>
        <strong><i class="fa fa-warning"></i> ATEN&Ccedil;&Atilde;O: 
        <%
		if session("Admin")=1 then
			%>
			Existem faturas em aberto do seu sistema. Evite a suspensão parcial dos serviços quitando os débitos.</strong><hr>
			<a href="?P=MinhasFaturas&Pers=1" class="btn btn-danger">
				<i class="fa fa-barcode"></i> Clique aqui para gerenciar suas faturas.
			</a>
            <%
		else
			%>
            H&aacute; mensagens importantes para o administrador do sistema. Solicitamos que o mesmo entre com seu login para visualiz&aacute;-las.
            <%
		end if
		%>
    </div>
	  <%
	end if
end if







on error resume next

if req("MudaLocal")<>"" then
	db_execute("update sys_users set UnidadeID="&req("MudaLocal")&" where id="&session("User"))
	session("UnidadeID") = ccur(req("MudaLocal"))
	if session("UnidadeID")=0 then
		set getNome = db.execute("select NomeEmpresa from empresa")
		if not getNome.eof then
			session("NomeEmpresa") = getNome("NomeEmpresa")
		end if
	else
		set getNome = db.execute("select UnitName from sys_financialcompanyunits where id="&session("UnidadeID"))
		if not getNome.eof then
			session("NomeEmpresa") = getNome("UnitName")
		end if
	end if
	response.Redirect("./?P=Home&Pers=1")
end if

DiaAtual = weekday(date())
Inicio = DiaAtual-1
Inicio = dateAdd("d", (Inicio*(-1)), date())
Fim = dateAdd("d", 6, Inicio)

if lcase(session("Table"))="profissionais" then
	Data = Inicio
	while Data<=Fim
		set age = db.execute("select count(id) as total from agendamentos where Data='"&mydate(Data)&"' and StaID=7 and ProfissionalID="&session("idInTable"))
		age7 = age7&", "&age("total")
		set age = db.execute("select count(id) as total from agendamentos where Data='"&mydate(Data)&"' and StaID=1 and ProfissionalID="&session("idInTable"))
		age1 = age1&", "&age("total")
		set age = db.execute("select count(id) as total from agendamentos where Data='"&mydate(Data)&"' and StaID=3 and ProfissionalID="&session("idInTable"))
		age3 = age3&", "&age("total")
		set age = db.execute("select count(id) as total from agendamentos where Data='"&mydate(Data)&"' and StaID=6 and ProfissionalID="&session("idInTable"))
		age6 = age6&", "&age("total")
		Data = Data+1
	wend
	splAge7 = split(age7, ", ")
	splAge1 = split(age1, ", ")
	splAge3 = split(age3, ", ")
	splAge6 = split(age6, ", ")
end if
'response.Write("|||"&DifTempo&"|||<br />"&time())
if 1=2 then
	%>
    <div class="alert alert-danger">
    <button class="close" data-dismiss="alert" type="button">
    <i class="fa fa-remove"></i>
    </button>
    <strong><i class="fa fa-warning-sign"></i> ATEN&Ccedil;&Atilde;O:</strong>
    Informamos que do dia 22/12/2014 a 05/01/2015 nosso departamento de desenvolvimento estar&aacute; inserindo diversas atualiza&ccedil;&otilde;es e aperfei&ccedil;oamentos no sistema, o que pode ocasionar pequenas instabilidades no uso durante este per&iacute;odo.<br />
    <br />
    <br>
    Atenciosamente,<br />
    Equipe Feegow Clinic
    </div>
	<%
end if
%>

<div class="page-header">
	<div class="row">
		<div class="col-xs-12">
			<h1>
			Resumo da Semana
			<small>
			<i class="fa fa-double-angle-right"></i>
			de <%=Inicio%> a <%=Fim%>
			</small>
			</h1>
		</div>
	</div>
</div>

<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>
<div class="row">
<%
if session("table")="profissionais" then
%>
    <div class="col-xs-12 col-sm-6 widget-container-span">
        <div class="widget-box">
            <div class="widget-header">
                <h5>Agendamentos</h5>

                <div class="widget-toolbar">
                    <a href="#" data-action="close">
                        <i class="fa fa-remove"></i>
                    </a>
                </div>
            </div>

            <div class="widget-body">
                <div class="widget-main" id="agendamentos">
                    carregando...
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12 col-sm-6 widget-container-span">
        <div class="widget-box">
            <div class="widget-header">
                <h5>Procedimentos Agendados</h5>

                <div class="widget-toolbar">
                    <a href="#" data-action="close">
                        <i class="fa fa-remove"></i>
                    </a>
                </div>
            </div>

            <div class="widget-body">
                <div class="widget-main" id="procedimentos">
                    carregando...
                </div>
            </div>
        </div>
    </div>
<%
End If
%>
</div>
<div class="row">
    <div class="col-xs-12 col-sm-6 widget-container-span">
        <div class="widget-box">
            <div class="widget-header">
                <h5>A Pagar e A Receber</h5>

                <div class="widget-toolbar">
                    <a href="#" data-action="close">
                        <i class="fa fa-remove"></i>
                    </a>
                </div>
            </div>

            <div class="widget-body">
                <div class="widget-main" id="financeiro">
                    carregando...
                </div>
            </div>
        </div>
    </div>
    <div class="col-xs-12 col-sm-6 widget-container-span">
        <div class="widget-box">
            <div class="widget-header">
                <h5>Confirmações de Agendamento <small>E-mail e SMS</small></h5>

                <div class="widget-toolbar">
                    <a href="#" data-action="close">
                        <i class="fa fa-remove"></i>
                    </a>
                </div>
            </div>

            <div class="widget-body">
                <div class="widget-main">
				<%
				if lcase(session("Table"))="profissionais" then
					filtraProf = " where a.ProfissionalID="&session("idInTable")
				end if
'				set conf = db.execute("select ar.*, a.StaID, p.NomePaciente from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN pacientes p on p.id=a.PacienteID "&filtraProf&" order by ar.DataHora desc limit 8")
				set conf = db.execute("select ar.*, a.StaID, p.NomePaciente from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN locais l on l.id=a.LocalID LEFT JOIN pacientes p on p.id=a.PacienteID "&filtraProf&" AND l.UnidadeID="&session("UnidadeID")&" order by ar.DataHora desc limit 8")
				if conf.eof then
					%>
                    Nenhuma confirmação recente.
                    <%
				else
					%>
                    <table class="table table-striped table-condensed table-hover">
                        <tbody>
                        <%
						while not conf.eof
							%>
                        	<tr>
                            	<td width="1%"><img src="assets/img/<%=conf("StaID")%>.png" /></td>
                            	<td>
                                	<div><%=conf("NomePaciente")%> <small>&raquo; em <%=conf("DataHora")%></small></div>
                                	<em><%=conf("Resposta")%></em>
                                </td>
                                <td width="1%"><a href="./?P=Agenda&Pers=1&Conf=<%=conf("id")%>" class="btn btn-xs btn-white"><i class="fa fa-search-plus"></i></a></td>
                            </tr>
                            <%
						conf.movenext
						wend
						conf.close
						set conf=nothing
						%>
                        </tbody>
                    </table>
                    <%
				end if
				%>
                <a class="btn btn-xs btn-info pull-right" href="./?P=Confirmacoes&Pers=1"><i class="fa fa-list"></i> Ver todas</a>
                </div>
            </div>
        </div>
    </div>
</div>
<script language="javascript">
function agendamentos() {
	$('#agendamentos').highcharts({
		chart: {
			type: 'spline'
		},
		title: {
			text: ''
		},
		subtitle: {
			text: ''
		},
		xAxis: {
			categories: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab']
		},
		yAxis: {
			title: {
				text: 'Quantidade'
			},
			labels: {
				formatter: function () {
					return this.value + ':';
				}
			}
		},
		tooltip: {
			crosshairs: true,
			shared: true
		},
		plotOptions: {
			spline: {
				marker: {
					radius: 4,
					lineColor: '#666666',
					lineWidth: 1
				}
			}
		},
		<%
		'set age = select 
		%>
		series: [{
			name: 'Marcado - confirmado',
			marker: {
				symbol: 'square'
			},
			data: [<%=splAge7(1)%>, <%=splAge7(2)%>, {
				y: <%=splAge7(3)%>,
				marker: {
					symbol: 'url(assets/img/7.png)'
				}
			}, <%=splAge7(4)%>, <%=splAge7(5)%>, <%=splAge7(6)%>, <%=splAge7(7)%>]

		},
		{
			name: 'Marcado - nao confirmado',
			marker: {
				symbol: 'square'
			},
			data: [<%=splAge1(1)%>, <%=splAge1(2)%>, <%=splAge1(3)%>, <%=splAge1(4)%>, {
				y: <%=splAge1(5)%>,
				marker: {
					symbol: 'url(assets/img/1.png)'
				}
			}, <%=splAge1(6)%>, <%=splAge1(7)%>]

		},
		{
			name: 'Atendido',
			marker: {
				symbol: 'square'
			},
			data: [<%=splAge3(1)%>, {
				y: <%=splAge3(2)%>, 
				marker: {
					symbol: 'url(assets/img/3.png)'
				}
			}, <%=splAge3(3)%>, <%=splAge3(4)%>, <%=splAge3(5)%>, <%=splAge3(6)%>, <%=splAge3(7)%>]

		},
		{
			name: 'Nao compareceu',
			marker: {
				symbol: 'diamond'
			},
			color: '#ff0000',
			data: [{
				y: <%=splAge6(1)%>,
				marker: {
					symbol: 'url(assets/img/6.png)'
				}
			}, <%=splAge6(2)%>, <%=splAge6(3)%>, <%=splAge6(4)%>, <%=splAge6(5)%>, <%=splAge6(6)%>, <%=splAge6(7)%>]
		}]
	});
}


function procedimentos() {
	$('#procedimentos').highcharts({
		chart: {
			plotBackgroundColor: null,
			plotBorderWidth: 0,//null,
			plotShadow: false
		},
		title: {
			text: ''
		},
		tooltip: {
			pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
		},
		plotOptions: {
			pie: {
				allowPointSelect: true,
				cursor: 'pointer',
				dataLabels: {
					enabled: true,
					format: '<b>{point.name}</b>: {point.percentage:.1f} %',
					style: {
						color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
					}
				}
			}
		},
		series: [{
			type: 'pie',
			name: 'Percentual',
			data: [
				   <%
				   set proc = db.execute("select count(id) as totalProcedimentos from agendamentos where Data>='"&mydate(Inicio)&"' and Data<='"&myDate(Fim)&"' and ProfissionalID="&session("idInTable"))
				   totalProcedimentos = ccur(proc("totalProcedimentos"))
				   if totalProcedimentos=0 then
				   %>
					['Nenhum procedimento agendado',   100],
				   <%
				   else
					set procs = db.execute("select distinct TipoCompromissoID from agendamentos where Data>='"&mydate(Inicio)&"' and Data<='"&mydate(Fim)&"' and ProfissionalID="&session("idInTable"))
					while not procs.eof
						set conta = db.execute("select count(id) as total from agendamentos where Data>='"&mydate(Inicio)&"' and Data<='"&mydate(Fim)&"' and TipoCompromissoID="&procs("TipoCompromissoID")&" and ProfissionalID="&session("idInTable"))
						Quantidade = ccur(conta("total"))
						set Nome = db.execute("select id, NomeProcedimento from procedimentos where id="&procs("TipoCompromissoID"))
						if not Nome.EOF then
							Percentual = 100/totalProcedimentos
							Percentual = Percentual*Quantidade
							Percentual = replace(formatnumber(Percentual, 2), ",", ".")
							%>
							  ['<%=left(Nome("NomeProcedimento"), 13)%>', <%=Percentual%>],
							<%
						end if
					procs.movenext
					wend
					procs.close
					set procs=nothing
					%>
					
					<%
				   end if
				   %>
			]
		}]
	});
}
function financeiro() {
	$('#financeiro').highcharts({

		chart: {
			type: 'column',
			marginTop: 80,
			marginRight: 40
		},

		title: {
			text: ''
		},

		xAxis: {
			categories: ['Domingo', 'Segunda', 'Terca', 'Quarta', 'Quinta', 'Sexta', 'Sabado']
		},

		yAxis: {
			allowDecimals: false,
			min: 0,
			title: {
				text: 'Valor'
			}
		},

		tooltip: {
			headerFormat: '<b>{point.key}</b><br>',
			pointFormat: '<span style="color:{series.color}">\u25CF</span> {series.name}: {point.y} / {point.stackTotal}'
		},

		plotOptions: {
			column: {
				stacking: 'normal',
				depth: 40
			}
		},
<%
Data = Inicio
strD = ""
while Data<=Fim
	TotalDia = 0
	PagoDia = 0
	set getMovement = db.execute("select * from sys_financialMovement where Type='Bill' and Date='"&mydate(Data)&"' and CD='D' order by Date")
	while not getMovement.eof
		Value = getMovement("Value")
		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")
		Rate = getMovement("Rate")
		'defining who is the C and who is the D
	'	response.Write("if "&AccountAssociationIDCredit&"="&AccountAssociationID&" and "&AccountIDCredit&"="&AccountID&" then")
	'	response.Write("if "&AccountAssociationIDCredit=AccountAssociationID&" and "&AccountIDCredit=AccountID&" then")
		if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
			CD = "C"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "D"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
		else
			CD = "D"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "C"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			Balance = Balance-Value
			accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
		end if

		AlreadyDiscounted = 0
		'if (accountReverse="" and getMovement("Type")="Bill") or (ScreenType<>"" and getMovement("Type")="Bill") then
			'->if paid
				if getMovement("Type")="Bill" then
					linkBill = "<a href=""?P=sys_financialInvoices&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					endLinkBill = "</a>"
				else
					linkBill = ""
					endLinkBill = ""
				end if
				if ScreenType="Statement" then
					if getMovement("CD")="C" then
						accountReverse = linkBill&"<span class=""badge"">Receita</span>"&endLinkBill
					else
						accountReverse = linkBill&"<span class=""badge"">Despesa</span>"&endLinkBill
					end if
				end if

				set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&getMovement("id"))
				while not getAlreadyDiscounted.EOF
					AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
				getAlreadyDiscounted.movenext
				wend
				getAlreadyDiscounted.close
				set getAlreadyDiscounted = nothing

				PaymentMovement = 0
				set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&getMovement("id"))
				while not getPaymentMovement.EOF
					PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
				getPaymentMovement.movenext
				wend
				getPaymentMovement.close
				set getPaymentMovement = nothing
				
				totalPago = AlreadyDiscounted + PaymentMovement
			'<-if paid
		'end if
		'-
		cType = getMovement("Type")
		TotalDia = TotalDia+getMovement("Value")
		PagoDia = PagoDia+totalPago
	getMovement.movenext
	wend
	getMovement.close
	set getMovement = nothing
	Data = Data+1
	strD = strD&TotalDia&":"&PagoDia&"|"
	strEmAbertoAPagar = strEmAbertoAPagar&", "&replace(TotalDia-PagoDia, ",", ".")
	strPagoAPagar = strPagoAPagar&", "&replace(PagoDia, ",", ".")
wend

Data = Inicio
strD = ""
while Data<=Fim
	TotalDia = 0
	PagoDia = 0
	set getMovement = db.execute("select * from sys_financialMovement where Type='Bill' and Date='"&mydate(Data)&"' and CD='C' order by Date")
	while not getMovement.eof
		Value = getMovement("Value")
		AccountAssociationIDCredit = getMovement("AccountAssociationIDCredit")
		AccountIDCredit = getMovement("AccountIDCredit")
		AccountAssociationIDDebit = getMovement("AccountAssociationIDDebit")
		AccountIDDebit = getMovement("AccountIDDebit")
		PaymentMethodID = getMovement("PaymentMethodID")
		Rate = getMovement("Rate")
		'defining who is the C and who is the D
	'	response.Write("if "&AccountAssociationIDCredit&"="&AccountAssociationID&" and "&AccountIDCredit&"="&AccountID&" then")
	'	response.Write("if "&AccountAssociationIDCredit=AccountAssociationID&" and "&AccountIDCredit=AccountID&" then")
		if ccur(AccountAssociationIDCredit)=ccur(AccountAssociationID) and ccur(AccountIDCredit)=ccur(AccountID) then
			CD = "C"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "D"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			accountReverse = accountName(AccountAssociationIDDebit, AccountIDDebit)
		else
			CD = "D"
			displayCD = CD
			if AccountAssociationID = "1" then
				displayCD = "C"
			end if
			if getMovement("Currency")<>session("DefaultCurrency") then
				Value = Value / Rate
			end if
			Balance = Balance-Value
			accountReverse = accountName(AccountAssociationIDCredit, AccountIDCredit)
		end if

		AlreadyDiscounted = 0
		'if (accountReverse="" and getMovement("Type")="Bill") or (ScreenType<>"" and getMovement("Type")="Bill") then
			'->if paid
				if getMovement("Type")="Bill" then
					linkBill = "<a href=""?P=sys_financialInvoices&T="&getMovement("CD")&"&I="&getMovement("InvoiceID")&"&Pers=1"">"
					endLinkBill = "</a>"
				else
					linkBill = ""
					endLinkBill = ""
				end if
				if ScreenType="Statement" then
					if getMovement("CD")="C" then
						accountReverse = linkBill&"<span class=""badge"">Receita</span>"&endLinkBill
					else
						accountReverse = linkBill&"<span class=""badge"">Despesa</span>"&endLinkBill
					end if
				end if

				set getAlreadyDiscounted = db.execute("select * from sys_financialDiscountPayments where InstallmentID="&getMovement("id"))
				while not getAlreadyDiscounted.EOF
					AlreadyDiscounted = AlreadyDiscounted+getAlreadyDiscounted("DiscountedValue")
				getAlreadyDiscounted.movenext
				wend
				getAlreadyDiscounted.close
				set getAlreadyDiscounted = nothing

				PaymentMovement = 0
				set getPaymentMovement = db.execute("select * from sys_financialDiscountPayments where MovementID="&getMovement("id"))
				while not getPaymentMovement.EOF
					PaymentMovement = PaymentMovement+getPaymentMovement("DiscountedValue")
				getPaymentMovement.movenext
				wend
				getPaymentMovement.close
				set getPaymentMovement = nothing
				
				totalPago = AlreadyDiscounted + PaymentMovement
			'<-if paid
		'end if
		'-
		cType = getMovement("Type")
		TotalDia = TotalDia+getMovement("Value")
		PagoDia = PagoDia+totalPago
	getMovement.movenext
	wend
	getMovement.close
	set getMovement = nothing
	Data = Data+1
	strEmAbertoAReceber = strEmAbertoAReceber&", "&replace(TotalDia-PagoDia, ",", ".")
	strPagoAReceber = strPagoAReceber&", "&replace(PagoDia, ",", ".")
wend
%>

		series: [{
			name: 'Em Aberto',
			data: [<%= right(strEmAbertoAPagar, len(strEmAbertoAPagar)-2) %>],
			stack: 'A Pagar',
			color:'#ff0000'
		}, {
			name: 'Pago',
			data: [<%= right(strPagoAPagar, len(strPagoAPagar)-2) %>],
			stack: 'A Pagar',
			color:'#069'
		}, {
			name: 'A Receber',
			data: [<%= right(strEmAbertoAReceber, len(strEmAbertoAReceber)-2) %>],
			stack: 'A Receber',
			color:'grey'
		}, {
			name: 'Recebido',
			data: [<%= right(strPagoAReceber, len(strPagoAReceber)-2) %>],
			stack: 'A Receber',
			color:'green'
		}]
	});
}
$(document).ready(function(){
<%
if req("Acesso")="1" then
%>
	$.post("videoHome.asp", '', function(data, status){
		$("#modal-table").modal("show");
		$("#modal").html(data);
	});

	$("#speak").attr("src", "speakWelcome.asp?<%=buscaAtu("chamar")%>");
	$("#speak").fadeIn(2000);
	setTimeout(function(){$("#speak").fadeOut(500)}, 27000);
	setTimeout(function(){$("#legend").fadeOut(500)}, 27000);

<%
end if
if aut("agendaV")=1 or aut("agendaA")=1 or session("Table")="profissionais" then
%>
	setTimeout(function(){agendamentos()}, 1000);
	setTimeout(function(){procedimentos()}, 1800);
<%
End If
if aut("contasapagarV")=1 and aut("contasareceberV")=1 then
%>
	setTimeout(function(){financeiro()}, 3000);
	setTimeout(function(){apaga()}, 4000);
<%
end if
%>
	function apaga(){
		$("text[zIndex='8']").css("display", "none");
	}
});
</script>
		<script>
        $(document).ready(function() {
          $(".animsition").animsition({
            inClass: 'fade-in-down',
            outClass: 'zoom-out-lg',
            inDuration: 1000,
            outDuration: 800,
            linkElement: '.animsition-link',
            // e.g. linkElement: 'a:not([target="_blank"]):not([href^=#])'
            loading: true,
            loadingParentElement: 'body', //animsition wrapper element
            loadingClass: 'animsition-loading',
            loadingInner: '', // e.g '<img src="loading.svg" />'
            timeout: false,
            timeoutCountdown: 5000,
            onLoadEvent: true,
            browser: [ 'animation-duration', '-webkit-animation-duration'],
            // "browser" option allows you to disable the "animsition" in case the css property in the array is not supported by your browser.
            // The default setting is to disable the "animsition" in a browser that does not support "animation-duration".
            overlay : false,
            overlayClass : 'animsition-overlay-slide',
            overlayParentElement : 'body',
            transition: function(url){ window.location.href = url; }
          });
        });
		
		
        </script>
        <%
if session("Bloqueado")="FimTeste" then
	%>
	<!--#include file="FimTeste.asp"-->
	<%
end if
%>
<!--#include file="disconnect.asp"-->