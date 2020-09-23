<!--#include file="connect.asp"-->
<%
Acao = request.QueryString("Acao")
Tipo = request.QueryString("T")

if Acao="Inserir" then
	if not isnumeric(ref("Lote")) or ref("Lote")="" then
		erro = "N&uacute;mero do lote inv&aacute;lido."
	else
		set vca=db.execute("select * from tisslotes where Lote="&ref("Lote"))
		if not vca.eof then
			erro = "J&aacute; existe um lote com este n&uacute;mero."
		end if
	end if
	if erro<>"" then
		%>
        $.gritter.add({
            title: '<i class="fa fa-thumbs-down"></i> ERRO:',
            text: '<%=erro%>',
            class_name: 'gritter-error gritter-light'
        });
		<%
	else
		db_execute("insert into tisslotes (Lote, ConvenioID, Mes, Ano, Ordem, Tipo, sysUser,Observacoes,DataPrevisao) values ("&ref("Lote")&", "&request.QueryString("ConvenioID")&", "&ref("Mes")&", "&ref("Ano")&", '"&ref("Ordem")&"', '"&Tipo&"', "&session("User")&", '"&ref("Obs")&"',"&mydatenull(ref("PrevisaoRecebimento"))&")")
		set pult = db.execute("select id from tisslotes where sysUser="&session("User")&" order by id desc limit 1")
		spl = split(ref("guia"), ", ")
		if Tipo="GuiaConsulta" then
			tabela = "tissguiaconsulta"
		elseif Tipo="GuiaSADT" then
			tabela = "tissguiasadt"
		elseif Tipo="GuiaHonorarios" then
			tabela = "tissguiahonorarios"
		end if
		for i=0 to ubound(spl)
		    loteSql = "update "&tabela&" set LoteID="&pult("id")&" where id="&spl(i)
			db_execute(loteSql)
		next
		if getConfig("FechamentoLoteCR") = "1" then
            if Tipo="GuiaConsulta" then
                set valorProc = db.execute("select sum(ValorProcedimento) Valor, ProcedimentoID  from tissguiaconsulta t where LoteID = "&pult("id")&"")
            elseif Tipo="GuiaSADT" then
                set valorProc = db.execute("select sum(TotalGeral) Valor from tissguiasadt t where LoteID = "&pult("id")&"")
            elseif Tipo="GuiaHonorarios" then
                set valorProc = db.execute("select sum(ValorPago) Valor from tissguiahonorarios t where LoteID = "&pult("id")&"")
            end if
                db.execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser,sysDate, FormaID, ContaRectoID) values ('Fechamento de Lotes', "&request.QueryString("ConvenioID")&", 6, "&treatvalzero(valorProc("Valor"))&", 1, 'BRL', "&session("UnidadeID")&", 1, 'm', 'C', 1, "&session("User")&",CURDATE(), 0, 0)")
                set pultInv = db.execute("select id from sys_financialinvoices where sysUser="&session("User")&" order by id desc limit 1")
                InvoiceID = pultInv("id")
                db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, UnidadeID) values (0, 0, 6, "&request.QueryString("ConvenioID")&", "&treatvalzero(valorProc("Valor"))&", CURDATE(), 'C', 'Bill', 'BRL', 1, "&InvoiceID&", 1, "&session("User")&", "&session("UnidadeID")&")")
                if Tipo="GuiaConsulta" then
                    db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser, Executado) values ("&InvoiceID&", 'S', 1, 0, "&valorProc("ProcedimentoID")&", "&treatvalzero(valorProc("Valor"))&", 0, 'fechamento de lote', "&session("User")&", '')")
                else
                    db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Descricao, sysUser, Executado) values ("&InvoiceID&", '0', 1, 0, '', "&treatvalzero(valorProc("Valor"))&", 0, 'fechamento de lote', "&session("User")&", '')")
                end if
        end if
		%>
        alert('O lote foi salvo com sucesso. Para gerar o arquivo XML, acesse o menu TISS -> Administrar Lotes.');
        location.href='./?P=tissfechalote&Pers=1';
		<%
	end if
elseif Acao="Update" then
    LoteID = ref("LoteID")
    Enviado = ref("Enviado")
    Protocolo = ref("Protocolo")
    NumeroNFSe = ref("NumeroNFSe")
    DataEnvio = mydatenull(ref("DataEnvio"))
    DataPrevisao = mydatenull(ref("DataPrevisao"))
    DataPrevisaoOriginal = mydatenull(ref("DataPrevisaoOriginal"))
    db_execute("update tisslotes set Protocolo='"&Protocolo&"', NumeroNFSe='"&NumeroNFSe&"', Enviado="&Enviado&" , DataEnvio="&DataEnvio&", DataPrevisao="&DataPrevisao&", DataPrevisaoOriginal="&DataPrevisaoOriginal&" where id="&LoteID)
    %>
           $.gritter.add({
            title: '<i class="fa fa-save"></i> Informações salvas com sucesso!',
            text: '',
            class_name: 'gritter-success gritter-light'
        });

    <%
end if
%>