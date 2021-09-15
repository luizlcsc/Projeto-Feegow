<!--#include file="connect.asp"-->

        <%
		if ref("De")<>"" and ref("Ate")<>"" and ref("Conta")<>"" then
		%>
		<div class="row">
			<div class="col-xs-12">
					<%
					if ref("Conta")<>"0" then
					    sqlCartao = "AND i.AccountID="&ref("Conta")&" AND i.AssociationAccountID=1"
                    end if
					sqlData = "AND i.sysDate BETWEEN "&mydatenull(ref("De"))&" AND "&mydatenull(ref("Ate"))
                    set FaturasSQL = db.execute("SELECT i.*, ca.BestDay, ca.AccountName FROM sys_financialinvoices i INNER JOIN sys_financialcurrentaccounts ca ON ca.id=i.accountId WHERE i.Name like 'Fatura do cartão%' "&sqlData&sqlCartao&" ORDER BY i.sysDate")
                    if not FaturasSQL.eof then
                        if FaturasSQL("BestDay")="" or isnull(FaturasSQL("BestDay")) then
                            %>
                            <div class="alert alert-warning m15">
                                <strong>Atenção:</strong>Preencha o melhor dia para a compra <a target="_blank" href="?P=sys_financialcurrentaccounts&I=<%=FaturasSQL("AccountID")%>&Pers=1">do cartão</a>!
                            </div>
                            <%
                        end if

                            %>

                            <table class="table table-striped table-bordered table-condensed">
                                <thead>
                                    <tr class="success">
                                        <th width="1%"></th>
                                        <th nowrap>Cartão</th>
                                        <th nowrap>Mês de referência</th>
                                        <th nowrap align="center" width="10%">Data do vencimento</th>
                                        <th nowrap width="8%">Data de fechamento</th>
                                        <th nowrap width="10%">Valor total</th>
                                        <th nowrap width="1%">Status</th>
                                        <th nowrap width="1%">Detalhar</th>
                                    </tr>
                                </thead>
                                <tbody>
                        <%

                        while not FaturasSQL.eof
                            MesVigente = cdate(FaturasSQL("sysDate"))
                            DataVencimento = dateadd("m",1,cdate(FaturasSQL("sysDate")))
                            NomeCartao = FaturasSQL("AccountName")

                            if FaturasSQL("BestDay")<>"" AND not isnull(FaturasSQL("BestDay")) then
                                DataFechamento = cdate(FaturasSQL("BestDay")&"/"&month(MesVigente)&"/"&year(MesVigente))
                                if date() > DataFechamento then
                                    Status = "<span style='color:green'>Fechada</span>"
                                else
                                    Status = "<span style='color:orange'>Aberta</span>"
                                end if


                            %>
<tr>
    <td><a class="hidden-print" href="?P=invoice&I=<%=FaturasSQL("id")%>&A=&Pers=1&T=D" target="_blank"><i class="far fa-external-link"></i></a></td>
    <td><%=NomeCartao%></td>
    <td><%=FaturasSQL("Name")%></td>
    <td><%=DataVencimento%></td>
    <td><%=DataFechamento%></td>
    <td>R$ <%=fn(FaturasSQL("Value"))%></td>
    <td><%=Status%></td>
    <td><button style="float: right;" type="button" onclick="location.href='?P=DetalhamentoFatura&Pers=1&Fatura=<%=FaturasSQL("id")%>'" title="Abrir detalhamento" class="btn-default btn btn-xs"><i class="far fa-list"></i></button></td>
</tr>
                            <%
                            end if
                        FaturasSQL.movenext
                        wend
                        FaturasSQL.close
                        set FaturasSQL=nothing

					%>

					</tbody>
				</table>
			</div>
		</div>
        <%
                    end if
                    else%>
        <center><em>Busque acima o perfil da fatura do cartão.</em></center>
        <%End if%>