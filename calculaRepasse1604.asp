<!--#include file="connect.asp"-->
<%
rps=request.QueryString("rps")
vlr = request.QueryString("vlr")
cc = ref("AccountID")

if rps<>"" then
	'categoria de repasse
	sqlCatRepasse = "select * from sys_financialexpensetype where Name like 'Repasse' or Name like 'Repasses'"
	set vcaCatRepasse = db.execute(sqlCatRepasse)
	if vcaCatRepasse.eof then
		db_execute("insert into sys_financialexpensetype (Name, Category, Ordem, sysActive, sysUser) values ('Repasses', 0, 1, 1, "&session("User")&")")
		vcaCatRepasse = db.execute(sqlCatRepasse)
	end if
	Categoria = vcaCatRepasse("id")

	'conta credito
	splAccount = split(cc, "_")
	AccountID = splAccount(1)
	AssociationAccountID = splAccount(0)

	'insere a invoice
	db_execute("insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser) values("&AccountID&", "&AssociationAccountID&", '"&treatVal(vlr)&"', 1, 'BRL', 0, 1, 'm', 'D', 1, "&session("User")&")")
	set pult = db.execute("select id from sys_financialinvoices where CD='D' and sysUser="&session("User")&" order by id desc limit 1")
	
	'insere o movimento
	db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber) values ("&AssociationAccountID&", "&AccountID&", 0, 0, '"&treatVal(vlr)&"', "&mydatenull(date())&", 'D', 'Bill', 'BRL', 1, "&pult("id")&", 1)")

	'insere o item da invoice
	db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser) values ("&pult("id")&", 'O', 1, "&Categoria&", 0, "&treatvalzero(vlr)&", 0, 'Repasse de "&ref("De")&" a "&ref("Ate")&"', "&session("User")&")")
	set pult = db.execute("select id from itensinvoice where sysUser="&session("User")&" order by id desc limit 1")

	'atualiza os rateios
	db_execute("update rateiorateios set ItemContaAPagar="&pult("id")&" where id in("&rps&")")
	%>
	alert('Conta a pagar criada com sucesso a partir dos repasses selecionados!');
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
			<div class="col-md-7"><br>
				<span class="label label-success arrowed-in arrowed-right">
					R$ <%=formatnumber(repasse, 2)%> &raquo; <%=n%> repasse<%=s%> a ser<%=em%> lan&ccedil;ado<%=s%>
				</span>
			</div>
			<div class="col-md-5"><br>
				<button type="button" class="btn btn-success btn-block btn-sm btn-lanca-conta" onclick="lancaRepasses('<%=strChecados%>', '<%=formatnumber(repasse, 2)%>', '<%=request.QueryString("ContaCredito")%>');"><i class="fa fa-money"></i> Lan&ccedil;ar no Contas a Pagar</button>
			</div>
		</div>
		<%
	else
		%>
		<br />
		<span class="label label-default">Busque o perfil desejado de repasses e clique nos que deseja lan&ccedil;ar no contas a pagar.</span>
		<%
	end if
end if
%>