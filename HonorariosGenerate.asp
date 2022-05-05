<!--#include file="connect.asp"-->
<%
'response.write( request.form() )

splProf = split(ref("ProfissionaisChecados"), "&")
for i=0 to ubound(splProf)
	ProfissionalDataSplt = split(splProf(i),"_")
	ProfissionalID = ProfissionalDataSplt(0)
	Data = ProfissionalDataSplt(1)

	'response.write("<br>Prof.: "& ProfissionalID &"<br>")

	sqlInv = "insert into sys_financialinvoices (AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate) values("& ProfissionalID &", 5, 0, 1, 'BRL', "&session("UnidadeID")&", 1, 'm', 'D', 1, "&session("User")&", curdate())"
	'response.write( sqlInv )
	db.execute( sqlInv )
	set pult = db.execute("select id from sys_financialinvoices where sysUser="& session("User") &" order by id desc limit 1")
	InvoiceID = pult("id")
	db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser) values ("& InvoiceID &", 'O', 1, 0, 0, 0, 0, 'Honorários médicos', "&session("User")&")")
	set pult = db.execute("select id from itensinvoice where sysUser="& session("User") &" order by id desc limit 1")
	ItemInvoiceID = pult("id")

	splDatas = split( ref("Profissional"& ProfissionalID), ", " )

	TotalGeral = 0
	for idt=0 to ubound(splDatas)

		'response.write("<br>"& splDatas(idt) &"<br>")

		splData = split(splDatas(idt), "_")
		Data = splData(0)
		tMin = ccur(splData(1))
		tVal = splData(2)

		sqlIIH = "insert into iihonorarios set ProfissionalID="& ProfissionalID &", sysUser="& session("User") &", ItemInvoiceID="& ItemInvoiceID &", Minutos="& tMin &", Valor="& treatvalzero(tVal) &", Data="& mydatenull(Data)
		'response.write("<br>"& sqlIIH &"<br>")
		db.execute( sqlIIH )
	next

	db.execute("update itensinvoice set ValorUnitario=(select sum(Valor) from iihonorarios where ItemInvoiceID="& ItemInvoiceID &") WHERE id="& ItemInvoiceID)
	db.execute("update sys_financialinvoices set Value=(select sum(Valor) from iihonorarios where ItemInvoiceID="& ItemInvoiceID &") WHERE id="& InvoiceID)
	db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser) values (5, "& ProfissionalID &", 0, 0, (select sum(Valor) from iihonorarios where ItemInvoiceID="& ItemInvoiceID &"), "&mydatenull(date())&", 'D', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "& session("User") &")")
next

response.redirect("./?P=ContasCD&T=D&Pers=1")
%>