<!--#include file="connect.asp"-->
<%
Inicio = cdate(req("Inicio"))
Fim = cdate(req("Fim"))

if req("tc")="Agendamentos" then
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

    %>
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
    agendamentos();

    <%
end if

if req("tc")="Procedimentos" then
    %>
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
         ['Nenhum agendamento',   100],
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
    procedimentos();
    <%
end if

if req("tc")="Financeiro" then
    %>
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
    financeiro();
    <%
end if
%>