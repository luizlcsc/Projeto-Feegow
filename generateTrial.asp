<%
response.Charset="utf-8"
if req("Part")="" then'primeira parte do processo
	%>
	<!--#include file="connectCentral.asp"-->
	<%
	function ref(Val)
		ref = replace(ref(Val), "'", "''")
	end function
	
	set verify = dbc.execute("select * from licencasusuarios where Email like '"&ref("Email")&"'")
	if not verify.EOF then
		%>
		alert('O e-mail informado já está cadastrado no sistema.');
		$("#btnGenerate").removeAttr("disabled");		<%
	else
		dbc.execute("insert into licencas (NomeContato, Telefone, Celular, IP, FimTeste, Cupom, ComoConheceu, referrer, gclid) values ('"&ref("NomeContato")&"', '"&ref("Telefone")&"', '"&ref("Celular")&"', '"&request.ServerVariables("REMOTE_ADDR")&"', "&mydatenull(date()+15)&", '"&ref("Cupom")&"', '"&ref("ComoConheceu")&"', '"&ref("referrer")&"', '"&ref("gclid")&"')")
		set pult = dbc.execute("select id from licencas order by id desc LIMIT 1")
		dbc.execute("insert into licencasusuarios (Nome, Tipo, Email, Senha, LicencaID) values ('"&ref("NomeContato")&"', 'Profissionais', '"&ref("Email")&"', '"&ref("senha1")&"', '"&pult("id")&"')")
		set pultusu = dbc.execute("select * from licencasusuarios where LicencaID="&pult("id"))
		dbc.execute("update licencas set AdminID="&pultusu("id")&" where id="&pult("id"))
		dbc.execute("CREATE DATABASE `clinic"&pult("id")&"` COLLATE 'utf8_general_ci'")
	
		session("Banco")="clinic"&pult("id")
		%>
		<!--#include file="connect.asp"-->
   		$("#btnGenerate").html('<i class="far fa-refresh"></i> GERANDO, AGUARDE...');
		<%


        on error resume next
        'conexao com o 45 ->
        ConnString45 = "Driver={MySQL ODBC 5.3 ANSI Driver};Server=192.168.193.45;Database=clinic100000;uid="&objSystemVariables("FC_MYSQL_USER")&";pwd="&objSystemVariables("FC_MYSQL_PASSWORD")&";"
        Set db45 = Server.CreateObject("ADODB.Connection")
        db45.Open ConnString45

'        set pultusu45 = db45.execute("select sysUser from pacientes where sysUser in(104718, 104723) order by id desc limit 1")
'        if pultusu45.eof then
'            sysUser = 104721
'        else
'            if pultusu45("sysUser")=104718 then
'                sysUser=104721
'            else
'                sysUser=104721
'            end if
'        end if


        db45.execute("insert into pacientes (id, NomePaciente, Tel1, Cel1, sysDate, Origem, Email1, sysUser, sysActive, ConstatusID) values ("&pult("id")&", '"&ref("NomeContato")&"', '"&ref("Telefone")&"', '"&ref("Celular")&"', NOW(), (select id from origens where Origem='"&ref("ComoConheceu")&"' limit 1), '"&ref("Email")&"', "&sysUser&", 1, 9)")
        '<- replicacao pro 45


		session("NameUser") = ref("NomeContato")
		session("Photo") = "assets/img/user.png"
		session("User")=pultusu("id")

		response.Redirect("geraBanco.php?BancoID="&pult("id"))
	end if
else'segunda parte do processo
		%>
		<!--#include file="connect.asp"-->
		<%
	
		set config = db.execute("select * from sys_config")
		session("DefaultCurrency") = config("DefaultCurrency")
		session("OtherCurrencies") = config("OtherCurrencies")
		set getCurrencySymbol = db.execute("select * from sys_financialCurrencies where Name='"&session("DefaultCurrency")&"'")
		session("CurrencySymbol") = getCurrencySymbol("Symbol")
		session("idInTable")=1
		session("Table") = "profissionais"
		session("Admin") = 1
		session("Permissoes") = permissoesPadrao()
		session("Status") = "T"
		session("UnidadeID")=0
		db_execute("update sys_users set id="&session("User")&", Permissoes='"&permissoesPadrao()&"'")
		db_execute("update profissionais set NomeProfissional='"&session("NameUser")&"', Nascimento=NULL, Tel1='"&ref("Telefone")&"', Cel1='"&ref("Celular")&"', Email1='"&ref("Email")&"' where id=1")
		
		db_execute("INSERT INTO `impressos` (`id`, `Cabecalho`, `Rodape`, `Prescricoes`, `Atestados`, `PedidosExame`, `Recibos`) VALUES	(1, '', '', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Receitu&aacute;rio</h1>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Pedido de Exame</h1>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Recibo M&eacute;dico</h1>\n\n<p>&nbsp;</p>\n')")		
		
		set tel = db.execute("select * from cliniccentral.licencas where id="&replace(session("Banco"), "clinic", ""))
		db_execute("insert into cliniccentral.smsfila (LicencaID, DataHora, AgendamentoID, Mensagem, Celular) values (0, "&myDateTime(now())&", 0, '"&rep(session("NameUser")&", bem-vindo ao Feegow Clinic. Obrigado por testar o software clinico mais completo do Brasil. Conte conosco!")&"', '55"&replace(replace(replace(replace(tel("Celular"), "(", ""), ")", ""), "-", ""), " ", "")&"')")
		%>
		location.href='./?P=Home&Pers=1&Acesso=1';
		<%
end if

%>