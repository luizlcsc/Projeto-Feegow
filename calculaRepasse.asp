<!--#include file="connect.asp"-->
<%
response.CharSet="utf-8"

rps=ref("rps")
vlr = ref("vlr")
cc = ref("AccountID")
tipo = req("tipo")
modoCalculo = req("modoCalculo")

if rps<>"" then
	'conta credito
    if tipo="ContaAPagar" then
	    'categoria de repasse
	    sqlCatRepasse = "select * from sys_financialexpensetype where Name like 'Repasse' or Name like 'Repasses'"
	    set vcaCatRepasse = db.execute(sqlCatRepasse)
	    if vcaCatRepasse.eof then
		    db.execute("insert into sys_financialexpensetype (Name, Category, Ordem, sysActive, sysUser) values ('Repasses', 0, 1, 1, "&session("User")&")")
		    vcaCatRepasse = db.execute(sqlCatRepasse)
	    end if
	    Categoria = vcaCatRepasse("id")


        sqlContas = "SELECT rat.ContaCredito, group_concat(id) idsRateio , sum(rat.Valor) ValorTotal, "&_
                             "(CASE "&_
                             "WHEN rat.ItemInvoiceID is not null then (SELECT i.CompanyUnitID FROM itensinvoice ii inner join sys_financialinvoices i on ii.InvoiceID=i.id where ii.id=rat.ItemInvoiceID LIMIT 1) "&_
                             "WHEN rat.ItemGuiaID is not null then (SELECT gs.UnidadeID FROM tissprocedimentossadt ps INNER JOIN tissguiasadt gs ON gs.id=ps.GuiaID WHERE ps.id=rat.ItemGuiaID LIMIT 1) "&_
                             "WHEN rat.ItemGuiaID is not null then (SELECT gh.UnidadeID FROM tissprocedimentoshonorarios ph INNER JOIN tissguiahonorarios gh ON gh.id=ph.GuiaID WHERE ph.id=rat.ItemHonorarioID LIMIT 1) "&_
                             "WHEN rat.GuiaConsultaID is not null then (SELECT gc.UnidadeID FROM tissguiaconsulta gc WHERE gc.id=rat.GuiaConsultaID LIMIT 1) "&_
                             "END) UnidadeID " &_
                             "FROM rateiorateios rat WHERE rat.id IN ("&rps&") AND rat.ContaCredito not in ('0', '0_0') GROUP BY UnidadeID, rat.ContaCredito"
        set ContaCreditoSQL = db.execute(sqlContas)


        while not ContaCreditoSQL.eof
            ContaCredito=ContaCreditoSQL("ContaCredito")
            UnidadeIDAtendimento=ContaCreditoSQL("UnidadeID")

            if UnidadeIDAtendimento&""="" then
                UnidadeIDAtendimento=session("UnidadeID")
            end if

            idsRateio=ContaCreditoSQL("idsRateio")

            splAccount = split(ContaCredito, "_")
            AccountID = splAccount(1)
            AssociationAccountID = splAccount(0)

            ValorContaCredito = ContaCreditoSQL("ValorTotal")

            'insere a invoice
            sqlInsertInvoice="insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate) values("&AccountID&", "&AssociationAccountID&", '"&treatVal(ValorContaCredito)&"', 1, 'BRL', '"& UnidadeIDAtendimento &"', 1, 'm', 'D', 1, "&session("User")&", curdate())"

            db.execute(sqlInsertInvoice)
            set pult = db.execute("select id from sys_financialinvoices where CD='D' and sysUser="&session("User")&" order by id desc limit 1")

            'insere o movimento
            db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser) values ("&AssociationAccountID&", "&AccountID&", 0, 0, '"&treatVal(ValorContaCredito)&"', "&mydatenull(date())&", 'D', 'Bill', 'BRL', 1, "&pult("id")&", 1, "& session("User") &")")

            'insere o item da invoice
            db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser) values ("&pult("id")&", 'O', 1, "&Categoria&", 0, "&treatvalzero(ValorContaCredito)&", 0, 'Repasse de "&ref("De")&" a "&ref("Ate")&"', "&session("User")&")")
            set pult = db.execute("select id from itensinvoice where sysUser="&session("User")&" order by id desc limit 1")

            'atualiza os rateios
            db.execute("update rateiorateios set ItemContaAPagar="&pult("id")&" where id in("&idsRateio&") and ContaCredito='"&ContaCredito&"'")


        ContaCreditoSQL.movenext
        wend
        ContaCreditoSQL.close
        set ContaCreditoSQL=nothing

        msg = "Conta a pagar criada com sucesso a partir dos repasses selecionados!"
    elseif tipo="ContaAReceber" then
	    'categoria de repasse
	    sqlCatRepasse = "select * from sys_financialincometype where Name like 'Repasse' or Name like 'Repasses'"
	    set vcaCatRepasse = db.execute(sqlCatRepasse)
	    if vcaCatRepasse.eof then
		    db.execute("insert into sys_financialincometype (Name, Category, Ordem, sysActive, sysUser) values ('Repasses', 0, 1, 1, "&session("User")&")")
		    vcaCatRepasse = db.execute(sqlCatRepasse)
	    end if
	    Categoria = vcaCatRepasse("id")


        accountSplit = split(ref("AccountID"), "_")
        AccountID = accountSplit(1)
        AssociationAccountID = accountSplit(0)


	    'insere a invoice
	    db.execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser) values("&AccountID&", "&AssociationAccountID&", '"&treatVal(vlr)&"', 1, 'BRL', 0, 1, 'm', 'C', 1, "&session("User")&")")
	    set pult = db.execute("select id from sys_financialinvoices where CD='C' and sysUser="&session("User")&" order by id desc limit 1")
	
	    'insere o movimento
	    db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser) values (0, 0, "&AssociationAccountID&", "&AccountID&", '"&treatVal(vlr)&"', "&mydatenull(date())&", 'C', 'Bill', 'BRL', 1, "&pult("id")&", 1, "& session("User") &")")

	    'insere o item da invoice
	    db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser, Executado) values ("&pult("id")&", 'O', 1, "&Categoria&", 0, "&treatvalzero(vlr)&", 0, 'Repasse de "&ref("De")&" a "&ref("Ate")&"', "&session("User")&", '')")
	    set pult = db.execute("select id from itensinvoice where sysUser="&session("User")&" order by id desc limit 1")

	    'atualiza os rateios
	    db.execute("update rateiorateios set ItemContaAReceber="&pult("id")&" where id in("&rps&")")
        msg = "Conta a receber criada com sucesso a partir dos repasses selecionados!"

    elseif tipo="Credito" then
        sqlCredito = "insert into sys_financialmovement (Name, AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser) values ('Crédito de repasse invertido', 0, 0, "&AssociationAccountID&", "&AccountID&", '"&treatVal(vlr)&"', "&mydatenull(date())&", '', 'Transfer', 'BRL', 1, NULL, 1, "& session("User") &")"
'        response.write( sqlCredito )
        db.execute( sqlCredito )
	    set pult = db.execute("select id from sys_financialmovement where sysUser="&session("User")&" and Type='Transfer' order by id desc limit 1")
	    db.execute("update rateiorateios set CreditoID="& pult("id") &" where id in("& rps &")")

        msg = "Crédito lançado com sucesso na conta do executante!"
    end if
	%>
	alert('<%= msg %>');
    location.reload();
	<%
else
	repasse = 0
	spl = split(ref("Repasses"), ", ")
	n = 0
	for i=0 to ubound(spl)
		'response.Write(spl(i))
		spl2 = split(spl(i), "|")
		strChecados = strChecados&","&spl2(0)
		repasse = repasse+ccur(spl2(1))
		n = n+1
	next
	if n>0 then
		strChecados = right(strChecados, len(strChecados)-1)
		if n>1 then
			s="s"
			em="em"
		end if
		%>
		<div class="row">
			<div class="col-md-7 pt30">
				<span class="label label-success arrowed-in arrowed-right label-lg p10 mt15" style="margin-left:5px">
					R$ <%=formatnumber(repasse, 2)%> &raquo; <%=n%> repasse<%=s%> a ser<%=em%> lan&ccedil;ado<%=s%>
				</span>
			</div>
			<br>
			<div class="col-md-5">




                <div class="btn-group btn-sm btn-block">
                    <button type="button" class="btn btn-sm btn-success btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        <i class="far fa-money"></i> Lan&ccedil;ar...
                        <span class="caret ml5"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <% if modoCalculo="N" then %>
                        <li><a href="javascript:void(0);" onclick="lancaRepasses('<%=strChecados%>', '<%=formatnumber(repasse, 2)%>', '<%=req("ContaCredito")%>', 'ContaAPagar');"><i class="far fa-plus"></i> Como conta a pagar</a></li>
                        <%
                        else
                        %>
                        <li><a href="javascript:void(0);" onclick="lancaRepasses('<%=strChecados%>', '<%=formatnumber(repasse, 2)%>', '<%=req("ContaCredito")%>', 'Credito');"><i class="far fa-plus"></i> Como crédito (invertido)</a></li>
                        <li><a href="javascript:void(0);" onclick="lancaRepasses('<%=strChecados%>', '<%=formatnumber(repasse, 2)%>', '<%=req("ContaCredito")%>', 'ContaAReceber');"><i class="far fa-plus"></i> Como conta a receber (invertido)</a></li>
                        <% end if %>
                    </ul>
                </div>

			</div>
		</div>
		<%
	else
		%>
        <div class="pt30">
		    <span class="label label-default  p10 mt15" style="margin-left:5px">Clique nos repasses que deseja lan&ccedil;ar para pagamento.</span>
        </div>
		<%
	end if
end if
%>