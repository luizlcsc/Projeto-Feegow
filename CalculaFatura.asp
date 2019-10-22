<!--#include file="connect.asp"-->
<!--#include file="FuncoesAntigas.asp"-->
<%
response.Charset = "utf-8"

ValorSMS = 0.08
ValorEmail = 0

set lic = db.execute("select * from cliniccentral.licencas where `Status`='C'")
'set lic = db.execute("select * from cliniccentral.licencas where `Status`='C' and id=1475")
while not lic.eof
	UltimaFatura = ""
	set pultFat = db.execute("select * from cliniccentral.faturas where LicencaID="&lic("id")&" order by DataFechamento desc limit 1")
	if not pultFat.eof then
		UltimaFatura = pultFat("DataFechamento")
		UsuariosS = lic("UsuariosContratados")
		UsuariosNS = pultFat("UsuariosNS")
	else
		set cont = db.execute("select * from cliniccentral.contratar where LicencaID="&lic("id"))
		if not cont.eof then
			UltimaFatura = cdate(left(cont("DataHora"),10))
			UsuariosS = cont("Funcionarios") + cont("Profissionais")
			UsuariosNS = 0
		end if
	end if
	if UltimaFatura<>"" then
		ValorUsuario = lic("ValorUsuario")
		NomeContato = lic("NomeContato")
		Vencimento = dateadd("d", 5, date())
	end if
	if UltimaFatura<=dateadd("m", -1, date()) then
		ValorTotal = 0
		'1. verificar se Usuarios teve acrescimo ou decrescimo pra ajustar qtd
		DiasCorridos = datediff("d", UltimaFatura, dateadd("d", -1, date()) )
		ValorDiaUsuario = ValorUsuario/DiasCorridos
		Descricao = ""
		UsuariosAtuais = UsuariosS
		set logs = db.execute("select * from cliniccentral.licencaslogs where LicencaID="&lic("id")&" and date(sysDate) BETWEEN "&mydatenull(UltimaFatura)&" and "&mydatenull( dateadd("d", -1, date()) )&"")
		while not logs.eof
			DataAcao = cdate( left(logs("sysDate"), 10) )
			DiasDaAcao = datediff("d", DataAcao, dateadd("d", -1, date()) )
			ProRataS = ValorDiaUsuario * DiasDaAcao
			if logs("acao")="I" then
				acao = "Insercao"
				UsuariosAtuais = UsuariosAtuais + 1
			elseif logs("acao")="X" then
				acao = "Exclusao"
				ProRataS = ProRataS * (-1)
				UsuariosAtuais = UsuariosAtuais - 1
			end if
			ValorTotal = ValorTotal + ProRataS
			Descricao = Descricao & acao & " do usuario "& left(logs("Nome"), 10) &" em "&DataAcao&" ....... R$ "& formatnumber(ProRataS, 2)&"<br>"' &" (Dias Corridos:"& DiasDaAcao &" - "& ValorDiaUsuario &") <br>"
		logs.movenext
		wend
		logs.close
		set logs=nothing
		Descricao = "Mensalidade Feegow Clinic - "&UsuariosS&" usu&aacute;rios: R$ "&formatnumber( UsuariosS*ValorUsuario, 2 ) &"<br>" & Descricao
		ValorTotal = ValorTotal + (UsuariosS*ValorUsuario)
		ValorTotal = formatnumber( ValorTotal, 2 )
		'2. fazer rotina pra calcular quantos SMS e Emails foram disparados no período em questao
		set conta = db.execute("select (select count(id) from cliniccentral.smshistorico where LicencaID="&lic("id")&" and date(EnviadoEm) BETWEEN "&mydatenull(UltimaFatura)&" and "&mydatenull( dateadd("d", -1, date()) )&") QtdSMS, (select count(id) from cliniccentral.emailshistorico where LicencaID="&lic("id")&" and date(EnviadoEm) BETWEEN "&mydatenull(UltimaFatura)&" and "&mydatenull( dateadd("d", -1, date()) )&") QtdEmail")
		QtdSMS = conta("QtdSMS")
		QtdEmail = conta("QtdEmail")
		'gera uma fatura pq deu 1 mes ou mais do ultimo fechamento
		sql = "insert into cliniccentral.faturas (LicencaID, DataInicio, DataFechamento, Vencimento, UsuariosS, ValorUsuariosS, UsuariosNS, ValorUsuariosNS, QtdSMS, ValorSMS, QtdEmails, ValorEmails, Descricao) values ("&lic("id")&", "&mydatenull(UltimaFatura)&", "&mydatenull(date())&", "&mydatenull(Vencimento)&", "&UsuariosS&", "&treatvalzero(ValorUsuario)&", "&UsuariosNS&", "&treatvalzero(ValorUsuarioNS)&", "&QtdSMS&", "&treatvalzero(ValorSMS)&", "&QtdEmail&", "&treatvalzero(ValorEmail)&", '"&Descricao&"')"
		response.Write( sql )
		'&"<br>Valor total: " & ValorTotal & "<br>Usuarios atuais: "& UsuariosAtuais)
		db_execute(sql)
		'4. insert do contas a receber do bafim
		set baf = db.execute("select * from bafim.paciente where id="&lic("Cliente"))
		Nome = baf("Nome")
		if lic("Forma")="B" then
			Boleto="S"
		else
			Boleto=""
		end if
		set ccentral = db.execute("select * from bafim.contascentral where Tabela='Paciente' and ContaID="&lic("Cliente"))
		idCentral = ccentral("id")
		sqlBafim = "insert into bafim.receitasareceber (Nome, Vencimento, Boleto, NumeroDocto, Intervalo, TipoIntervalo, Valor, MemoPenalidades, DataCadastro, Paciente, TipoReceita, Quitada, Memorando, Parcela, Parcelas, moeda, FL, FixId, TipoValor, Ativa, PesEmp, Taxa, Comissao, Saldada) values ('Mensalidade Feegow Clinic- "&Nome&"', "&jundatsp(Vencimento)&", '"&Boleto&"', '', 1, 'm', "&treatvalzero(ValorTotal)&", '', "&jundatsp(date())&", "&idCentral&", '101', '', '"&rep(Descricao)&"', 1, 1, 'BRL', 'L', 0, 'F', 'S', 'E', 1, 0, 'N')"
		response.Write( sqlBafim )
		db_execute(sqlBafim)
		set pultr = db.execute("select id from bafim.receitasareceber order by id desc limit 1")
		idReceita = pultr("id")
		db_execute("insert into bafim.movimentacao (Nome, Tipo, ContaCredito, ContaDebito, Valor, Data, Usuario, Memorando, TipoProduto, ProdutoID, Taxa, Moeda, CD) values ('Mensalidade Feegow Clinic - "&Nome&"', 'Bill', 0, "&idCentral&", "&treatvalzero(ValorTotal)&", "&jundatsp(Vencimento)&", 1, '"&rep(Descricao)&"', 3, "&idReceita&", 1, 'BRL', 'C')")
		'5. atualizar a tabela licencas com o numerocontratado
		db_execute("update cliniccentral.licencas set UsuariosContratados="&UsuariosAtuais&" where id="&lic("id"))
		%>
		<%'= NomeContato &" - "& ValorUsuario &" - "& UsuariosS "& - "& UsuariosNS &" - "& UltimaFatura %>
		<%
	end if
lic.movenext
wend
lic.close
set lic=nothing
%>