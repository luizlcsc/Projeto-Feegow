<!--#include file="connect.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
//alert('<%=request.Form()%>');
<%
if ref("Forma")="" then
	erro = "Por favor, preencha uma forma de pagamento."
end if
if ref("Tipo")="" then
	erro = "Selecione se deseja contratar em nome de pessoa física ou jurídica."
end if
if ref("Forma")="C" then
	if ref("CVV")="" then
		erro = "Por favor, preencha o código de segurança do cartão de crédito (três últimos números localizados no verso do cartão)."
		focus = "CVV"
	end if
	if ref("M")="" or ref("A")="" then
		erro = "Por favor, preencha o mês e ano de expiração do cartão de crédito."
		focus = "M"
	end if
	if ref("Titular")="" then
		erro = "Por favor, preencha o nome do titular do cartão de crédito."
		focus = "Titular"
	end if
	if ref("NumeroCartao")="" then
		erro = "Por favor, preencha o número do cartão de crédito."
		focus = "NumeroCartao"
	end if
end if
if ref("Forma")="B" then
	Boleto = "S"
end if
sql = "(`Tipo`, `Nome`, `Responsavel`, `CPF`, `Email`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `Cel`, `Tel`, `RazaoSocial`, `CNPJ`, `Forma`, `Titular`, `NumeroCartao`, `M`, `A`, `CVV`, `LicencaID`, `UserID`, `Funcionarios`, `Profissionais`, `Mensalidade`) VALUES ('"&ref("Tipo")&"', '"&ref("Nome")&"', '"&ref("Responsavel")&"', '"&ref("CPF")&"', '"&ref("Email")&"', '"&ref("Cep")&"', '"&ref("Endereco")&"', '"&ref("Numero")&"', '"&ref("Complemento")&"', '"&ref("Bairro")&"', '"&ref("Cidade")&"', '"&ref("Estado")&"', '"&ref("Cel")&"', '"&ref("Tel")&"', '"&ref("RazaoSocial")&"', '"&ref("CNPJ")&"', '"&ref("Forma")&"', '"&ref("Titular")&"', '"&ref("NumeroCartao")&"', '"&ref("M")&"', '"&ref("A")&"', '"&ref("CVV")&"', "&replace(session("banco"), "clinic", "")&", "&session("User")&", "&treatvalzero(ref("Funcionarios"))&", "&treatvalzero(ref("Profissionais"))&", "&treatvalzero(ref("Valor"))&")"
if erro<>"" then
	%>
    new PNotify({
        title: 'ERRO',
        text: '<%=erro%>',
        delay: 5000,
        align:'center',
        type: 'danger',
        width: '450px'
    });
    $("#<%=focus%>").focus();
	<%
	db_execute("INSERT INTO `cliniccentral`.`tentativascontratar` "&sql)
else
	db_execute("INSERT INTO `cliniccentral`.`contratar` "&sql)
	if ref("Tipo")="J" then
		Nome = ref("RazaoSocial")
	else
		Nome = ref("Nome")
	end if
	if ref("Forma")="B" then
		Sta = "P"'Status prospect (igual bafim) q espera boleto compensar
	else
		Sta = "C"
	end if
	Obs = "Contrato diretamente pelo sistema em "&date()
	'Insere o paciente
	db_execute("insert into bafim.paciente (`Nome`, `CorPele`, `CPF`, `Email1`, `Cep`, `Endereco`, `Numero`, `Complemento`, `Bairro`, `Cidade`, `Estado`, `telCel1`, `TelCom1`, `Documento`, Obs, Ativo, Sta) VALUES ('"&left(Nome, 150)&"', '"&ref("Responsavel")&"', '"&ref("CPF")&"', '"&ref("Email")&"', '"&ref("Cep")&"', '"&ref("Endereco")&"', '"&ref("Numero")&"', '"&ref("Complemento")&"', '"&ref("Bairro")&"', '"&ref("Cidade")&"', '"&ref("Estado")&"', '"&ref("Cel")&"', '"&ref("Tel")&"', '"&ref("CNPJ")&"', '"&Obs&"', 'S', '"&Sta&"')")
	set pult = db.execute("select id from bafim.paciente order by id desc")
	idBafim = pult("id")
	'Insere a conta central
	db_execute("insert into bafim.contascentral (Tabela, ContaID, Nome) values ('Paciente', "&idBafim&", '"&Nome&"')")
	set pultc = db.execute("select id from bafim.contascentral order by id desc limit 1")
	idCentral = pultc("id")


        on error resume next
        'conexao com o 45 ->
        ConnString45 = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193.45;Database=clinic100000;uid=root;pwd=pipoca453;"
        Set db45 = Server.CreateObject("ADODB.Connection")
        db45.Open ConnString45

        db45.execute("update pacientes set NomePaciente='"&Nome&"', Cel2='"&ref("Cel")&"', Tel2='"&ref("Tel")&"', Email2='"&ref("Email")&"', Cep='"&ref("Cep")&"', Endereco='"&ref("Endereco")&"', Numero='"&ref("Numero")&"', Complemento='"&ref("Complemento")&"', Bairro='"&ref("Bairro")&"', Cidade='"&ref("Cidade")&"', Estado='"&left(ref("Estado"),2)&"', Documento='"&ref("Documento")&"', CPF='"&ref("CPF")&"', ConstatusID=7, idImportado="&idBafim&" where id="&replace(session("banco"), "clinic", ""))
        '<- replicacao pro 45
	



	'Definindo o valor por usuário
	UsuariosContratados = ccur(ref("Funcionarios")) + ccur(ref("Profissionais"))
	ValorUsuario = ccur(ref("Valor")) / ( UsuariosContratados )
	
	db_execute("update cliniccentral.licencas set Cliente="&idBafim&", `Status`='"&Sta&"', ValorUsuario="&treatvalzero(ValorUsuario)&", UsuariosContratados="&UsuariosContratados&", Forma='"&ref("Forma")&"' where id="&replace(session("banco"), "clinic", ""))
	'criar a fatura no bafim
	db_execute("insert into bafim.receitasareceber (Nome, Vencimento, Boleto, NumeroDocto, Intervalo, TipoIntervalo, Valor, MemoPenalidades, DataCadastro, Paciente, TipoReceita, Quitada, Memorando, Parcela, Parcelas, moeda, FL, FixId, TipoValor, Ativa, PesEmp, Taxa, Comissao, Saldada) values ('Habilitação Feegow Clinic- "&Nome&"', "&jundatsp(date())&", '"&Boleto&"', '', 1, 'm', "&treatvalzero(ref("Valor"))&", '', "&jundatsp(date())&", "&idCentral&", '94', '', '"&Obs&"', 1, 1, 'BRL', 'L', 0, 'F', 'S', 'E', 1, 0, 'N')")
	set pultr = db.execute("select id from bafim.receitasareceber order by id desc limit 1")
	idReceita = pultr("id")
	db_execute("insert into bafim.movimentacao (Nome, Tipo, ContaCredito, ContaDebito, Valor, Data, Usuario, Memorando, TipoProduto, ProdutoID, Taxa, Moeda, CD) values ('Habilitação Feegow Clinic - "&Nome&"', 'Bill', 0, "&idCentral&", "&treatvalzero(ref("Valor"))&", "&jundatsp(date())&", 1, '"&Obs&"', 3, "&idReceita&", 1, 'BRL', 'C')")
	'criar tabela faturas, com o id na fatura do bafim
	%>
	$.get("Contratado.asp?Forma=<%=ref("Forma")%>", function(data, status){ $("#modal-fimtestecontent .modal-body").html(data) });
	<%
end if
%>