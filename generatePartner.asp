<%
if req("Part")="" then
		set pultusu = db.execute("select * from cliniccentral.licencasusuarios where LicencaID="&pult("id"))
		db_execute("update cliniccentral.licencas set AdminID="&pultusu("id")&" where id="&pult("id"))
		db_execute("CREATE DATABASE `clinic"&pult("id")&"` COLLATE 'utf8_general_ci'")
	
		session("Banco")="clinic"&pult("id")
		session("NomeEmpresa")=ref("NomeEmpresa")
		session("UnidadeID")=0

		response.Redirect("geraBancoPartner.php?BancoID="&pult("id"))
else
	%>
	<!--#include file="connect.asp"-->
	<%
		set pultusu = db.execute("select * from cliniccentral.licencasusuarios where LicencaID="&replace(session("Banco"), "clinic", ""))
		db_execute("update sys_users set id="&pultusu("id")&", Permissoes='"&permissoesPadrao()&"'")
		db_execute("update profissionais set NomeProfissional='"&pultusu("Nome")&"', Nascimento=NULL where id=1")
		db_execute("update empresa set NomeEmpresa=(select NomeEmpresa from cliniccentral.licencas where id="&replace(session("Banco"), "clinic", "")&") where id=1")
		
		db_execute("INSERT INTO `impressos` (`id`, `Cabecalho`, `Rodape`, `Prescricoes`, `Atestados`, `PedidosExame`, `Recibos`) VALUES	(1, '', '', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Receitu&aacute;rio</h1>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Pedido de Exame</h1>\n\n<p>&nbsp;</p>\n', '<p>Paciente: [Paciente.Nome]<br />\nIdade: [Paciente.Idade]<br />\nData: [Data.Extenso]</p>\n\n<p>&nbsp;</p>\n\n<h1>Recibo M&eacute;dico</h1>\n\n<p>&nbsp;</p>\n')")		
		
		response.Redirect("./?P=Home&Pers=1&ClientePartner=1")
end if
%>