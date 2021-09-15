<!--#include file="connect.asp"-->
<%
muID = req("muID")
splMuID = split(muID, "_")
ItemInvoiceID = splMuID(0)
FuncaoRateioID = splMuID(1)
Quantidade = ref("Quantidade"&muID)
Lote = req("Lote")
Validade = req("Validade")

set fun = db.execute("select rf.*, p.ApresentacaoQuantidade from rateiofuncoes rf left join produtos p on p.id=rf.ProdutoID where rf.id="&FuncaoRateioID)
Valor = fun("Valor")*ccur(Quantidade)
set ii = db.execute("select ii.*, i.AccountID from itensinvoice ii left join sys_financialinvoices i on i.id=ii.InvoiceID where ii.id="&ItemInvoiceID)

db_execute("insert into estoquelancamentos (ProdutoID, EntSai, Quantidade, TipoUnidade, Data, Lote, Validade, Valor, UnidadePagto, Responsavel, PacienteID, sysUser, QuantidadeConjunto, QuantidadeTotal, ItemInvoiceID, FuncaoRateioID) values ("&fun("ProdutoID")&", 'S', "&treatvalzero(Quantidade)&", 'U', "&mydatenull(Date())&", '"&Lote&"', "&mydatenull(Validade)&", "&treatvalzero(Valor)&", 'U', '3_"&ii("ProfissionalID")&"', "&ii("AccountID")&", "&session("User")&", "&treatvalnull(fun("ApresentacaoQuantidade"))&", "&treatvalzero(Quantidade)&", "&ItemInvoiceID&", "&FuncaoRateioID&")")
%>
$("#muid<%=muID%>").html('<button type="button" class="btn btn-xs btn-success"><i class="far fa-upload"></i> Baixado</button>');
<!--#include file="disconnect.asp"-->