<!--#include file="connect.asp"-->
<%
PropostaID = req("PropostaID")

db_execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, sysDate, TabelaID) (select 'Gerado pela proposta', PacienteID, '3', Valor, '1', 'BRL', '"&session("UnidadeID")&"', '1', 'm', 'C', '1', '"&session("User")&"', date(now()), TabelaID from propostas where id="&PropostaID&")")

set pult = db.execute("select id from sys_financialinvoices order by id desc limit 1")

db_execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade,PacoteID, CategoriaID, ItemID, ValorUnitario, Desconto, Executado, Acrescimo, Associacao, OdontogramaObj) (select "&pult("id")&", 'S', Quantidade,PacoteID, CategoriaID, ItemID, ValorUnitario, IF(TipoDesconto='V',Desconto,(Desconto/100)*ValorUnitario)Desconto, '', Acrescimo, '3', OdontogramaObj from itensproposta where PropostaID="&PropostaID&")")

db_execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, UnidadeID) (select '0', '0', '3', AccountID, Value, date(now()), 'C', 'Bill', 'BRL', '-1', id, '1', '"&session("User")&"', '"&session("UnidadeID")&"' from sys_financialinvoices where id="&pult("id")&")")

db_execute("update propostas set InvoiceID="&pult("id")&", StaID=5 where id="&PropostaID)

response.Redirect( "./?P=Invoice&Pers=1&T=C&I="&pult("id") )
%>