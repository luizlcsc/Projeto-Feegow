<!--#include file="connect.asp"-->
<!--#include file="webhookFuncoes.asp"-->
<!--#include file="Classes/Logs.asp"-->

<%
PropostaID = req("PropostaID")
AguardaDesconto=false
PropostaIDS=""
autosave = 0
if req("autosave")&"" <> "" then
	autosave = req("autosave")
end if

if left(ref("AccountID"), 2)="3_" then
	splPac = split(ref("AccountID"), "_")
	PacienteID = splPac(1)
end if

if session("Banco")="clinic6118" then
    if ref("TabelaID")="0" then
        erro = "Preencha a tabela do paciente."
    end if
end if

temregradesconto=ref("temregradesconto")
if temregradesconto="" then
    temregradesconto="0"
end if

idUsuariosDesconto = "0"

if temregradesconto=1 then
	'Validar se existe algum desconto cadastrado para o sistema
	
	temdescontocadastrado=0
	querydesconto="Propostas"
	set rsDescontoItem = db_execute("select * from regrasdescontos descontos where Recursos LIKE '%|"&querydesconto&"|%'")
	if not rsDescontoItem.eof then
		temdescontocadastrado=1
	end if

	'Pegar todos os descontos do usuário pelo perfil dele
	set rsDescontosUsuario = db_execute("select suser.id as idUser, rd.id, Recursos, Unidades, rd.RegraID, Procedimentos, DescontoMaximo, TipoDesconto "&_
										" from regrasdescontos rd inner join sys_users suser on suser.RegraID = rd.RegraID  "&_
										" WHERE rd.Recursos LIKE '%"&querydesconto&"%' AND (rd.Unidades LIKE '%|"& session("UnidadeID") &"|%' OR rd.Unidades  = '' OR rd.Unidades IS NULL OR rd.Unidades  = '0' ) AND rd.RegraID IS NOT NULL")

end if


if erro="" then
	UnidadeID = session("UnidadeID")
	if ref("UnidadeID") <> "" then
		UnidadeID = ref("UnidadeID")
	end if
	'response.write(UnidadeID)
	set PropostaSQl = db_execute("SELECT sysUser, sysActive, StaID FROM propostas WHERE id="&PropostaID)

	if not PropostaSQL.eof then
		if PropostaSQL("sysUser")&""="" and PropostaSQL("sysActive")&""="1" then
			sysUserSql = " sysUser="&session("User")&","
		end if
	end if

	if PropostaSQl("StaID")&"" = "5" then
		sqlSave = "update propostas set ProfissionalExecutanteID=NULLIF('"&ref("ProfissionalExecutanteID")&"',''), ProfissionalID="&treatvalzero(ref("ProfissionalID"))&",  StaID="&ref("StaID")&", Internas='"&ref("Internas")&"',  ObservacoesProposta='"&ref("ObservacoesProposta")&"' where id="&PropostaID
		db_execute(sqlSave)

	else
		sqlSave = "update propostas set ProfissionalExecutanteID=NULLIF('"&ref("ProfissionalExecutanteID")&"',''),  ProfissionalID="&treatvalzero(ref("ProfissionalID"))&", PacienteID="&treatvalzero(ref("PacienteID"))&",TabelaID="&treatvalzero(ref("TabelaID"))&", Valor="&treatvalzero(ref("Valor"))&", UnidadeID="&treatvalzero(UnidadeID)&", StaID="&ref("StaID")&", TituloItens='"&ref("TituloItens")&"', TituloOutros='"&ref("TituloOutros")&"', TituloPagamento='"&ref("TituloPagamento")&"', DataProposta="&mydatenull(ref("DataProposta"))&", sysActive=1, "&sysUserSql&" Cabecalho='"&ref("Cabecalho")&"', Internas='"&ref("Internas")&"', ObservacoesProposta='"&ref("ObservacoesProposta")&"', Desconto="&treatvalzero(ref("DescontoTotal"))&" where id="&PropostaID
'		response.Write(sqlSave)
		db_execute(sqlSave)
		totalProposta = ref("Valor")

		'-> roda de novo o processo de cima
		'itens da proposta

		set ItemPropostaSQL = db_execute("SELECT ProfissionalID, group_concat(id) ids FROM itensproposta WHERE PropostaID="&PropostaID)
		if not ItemPropostaSQL.eof then
			ProfissionalID=ItemPropostaSQL("ProfissionalID")
			PropostaIDS=ItemPropostaSQL("ids")
		end if

		db_execute("delete from itensproposta where PropostaID="&PropostaID)

		splInv = split(ref("propostaItem"), ", ")
		totInvo = 0
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			valInv = ref("ValorUnitario"&splInv(i))
			ordemInv = treatvalzero(ref("Ordem"&splInv(i)))
			pacoteInv = treatvalnull(ref("PacoteID"&splInv(i)))

			prioridadeInv = treatvalzero(ref("Prioridade"&splInv(i)))
			quaInv = ref("Quantidade"&splInv(i))
			desInv = ref("Desconto"&splInv(i))
			desTipoInv = ref("DescontoTipo"&splInv(i))
			acrInv = ref("Acrescimo"&splInv(i))

			profissionalLinha = ref("ProfissionalLinhaID"&splInv(i))
			AccountAssociationID = ""
			AccountID = ""
			if ref("ProfissionalLinhaID"&splInv(i)) <> "" then
				profissionalLinha = Split(profissionalLinha,"_")
				AccountAssociationID = profissionalLinha(0)
				AccountID = profissionalLinha(1)
			end if
			if isnumeric(valInv) and valInv<>"" then valInv=ccur(valInv) else valInv=0 end if
			if isnumeric(quaInv) and quaInv<>"" then quaInv=ccur(quaInv) else quaInv=1 end if
			'if isnumeric(desInv) and desInv<>"" then desInv=ccur(desInv) else desInv=0 end if
			if isnumeric(ValorDesconto) and ValorDesconto<>"" then ValorDesconto=ccur(ValorDesconto) else ValorDesconto=0 end if
			if isnumeric(acrInv) and acrInv<>"" then acrInv=ccur(acrInv) else acrInv=0 end if

			if ProfissionalID&""="" then
				ProfissionalID=ref("ProfissionalID"&ii)
			end if

			if Row>0 then
				camID = "id,"
				valID = ii&","
			else
				camID = ""
				valID = ""
			end if
			Tipo = "S"'Fixado em servico

				valorUnitarioDB = treatvalzero(valInv)
				valorDescontoDB = treatvalzero(ValorDesconto)

			DescontoRef = ref("Desconto"&splInv(i))

			if DescontoRef="" then
				DescontoRef=0
			end if

			ValorDesconto = ccur(DescontoRef)
			ValorDescontoFinal = ccur(DescontoRef)
			
			desTipoInvP = desTipoInv

			if desTipoInv = "P" then
				ValorDescontoFinal = valInv * ValorDesconto  / 100
				ValorDesconto = valInv * ValorDesconto  / 100
				desTipoInv = "V"
			end if
			
			DescontoMaximo = 0
			VDesconto = 0

			totalProposta = totalProposta + ValorDescontoFinal

			if temregradesconto=1 then
				'Validar se o o valor do desconto esta conforme o valor limite para o desconto na regra dele
				if temdescontocadastrado=1 then
					'Existem descontos cadastrados rsDescontosUsuario
					if not rsDescontosUsuario.eof then
						while not rsDescontosUsuario.eof
							procedimentoText = rsDescontosUsuario("Procedimentos")
							if  (instr(procedimentoText, "|"&ref("ItemID"&splInv(i))&"|" ) AND "S"=Tipo) OR trim(procedimentoText)="" then
								if rsDescontosUsuario("idUser")&"" = Session("User")&"" then 	
									VDesconto = rsDescontosUsuario("DescontoMaximo")
									if rsDescontosUsuario("TipoDesconto")="P" then
										VDesconto = ref("ValorUnitario"&splInv(i)) * rsDescontosUsuario("DescontoMaximo") / 100
									end if
									if VDesconto > DescontoMaximo then 
										DescontoMaximo = VDesconto 
									end if
								else 
									VDescontomaximo = rsDescontosUsuario("DescontoMaximo")
									if rsDescontosUsuario("TipoDesconto")="P" then
										VDescontomaximo = ref("ValorUnitario"&splInv(i)) * rsDescontosUsuario("DescontoMaximo") / 100
									end if
									
									valorDescontoPermitido = ref("ValorUnitario"&splInv(i)) * 0.05

									if ValorDescontoFinal <= VDescontomaximo and VDescontomaximo>valorDescontoPermitido then
										idUsuariosDesconto = idUsuariosDesconto & "," & rsDescontosUsuario("idUser")
									end if
								end if
							end if

							rsDescontosUsuario.movenext
						wend
						rsDescontosUsuario.movefirst
					else
						ValorDesconto=0
						ValorDescontoFinal=0
					end if

					if ValorDesconto="" then
						ValorDesconto=0
						ValorDescontoFinal=0
					end if

					if DescontoMaximo < CCUR(ValorDescontoFinal) and DescontoMaximo <> 0 then
						ValorDesconto=0
						ValorDescontoFinal = 0
					end if
				end if
			end if

			if ValorDesconto = 0 then
				'Valida se tem desconto_pendentes para este item
				sqlDescontoPendente = "select desconto from descontos_pendentes where ItensInvoiceID = CONCAT('-',"&ii&") AND SysUserAutorizado IS NOT NULL AND DataHoraAutorizado IS NOT NULL "
				set rsDesconto = db_execute(sqlDescontoPendente)
				if not rsDesconto.eof then 
					ValorDesconto = rsDesconto("desconto")
				end if
			end if

			totalProposta = totalProposta - ValorDescontoFinal

			if session("Odonto")=1 then
				sqlInsert = "insert into itensproposta ("&camID&" PropostaID,PacoteID ,Ordem, Prioridade, Tipo, Quantidade, CategoriaID, AccountAssociationID, AccountID, ItemID, ValorUnitario, Desconto,TipoDesconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, OdontogramaObj) values ("&valID&" "&PropostaID&", "&pacoteInv&", "&ordemInv&","&prioridadeInv&",'"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&", NULLIF('"&AccountAssociationID&"',''),NULLIF('"&AccountID&"',''), "&treatvalzero(ref("ItemID"&ii))&", "& valorUnitarioDB &", "& treatvalzero(ValorDesconto)  &", '"&desTipoInv&"', '"&ref("Descricao"&ii)&"', '"&ref("Executado"&ii)&"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&", '"&replace(request.form("OdontogramaObj"&ii), "\", "\\")&"')"
			else
				sqlInsert = "insert into itensproposta ("&camID&" PropostaID,PacoteID , Ordem, Prioridade, Tipo, Quantidade, CategoriaID, AccountAssociationID, AccountID, ItemID, ValorUnitario, Desconto,TipoDesconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID) values("&valID&" "&PropostaID&", "&pacoteInv&", "&ordemInv&","&prioridadeInv&",'"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&",  NULLIF('"&AccountAssociationID&"',''),NULLIF('"&AccountID&"',''), "&treatvalzero(ref("ItemID"&ii))&", "& valorUnitarioDB &", "& treatvalzero(ValorDesconto) &", '"&desTipoInv&"', '"&ref("Descricao"&ii)&"', '"&ref("Executado"&ii)&"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&")"
			end if
			db_execute(sqlInsert)

			if Row<0 then
				set pult = db_execute("select id from itensproposta order by id desc limit 1")
				NewItemID = "-" & pult("id")
			else
				NewItemID = "-" & Row
			end if

			if temregradesconto=1 then
				'Gravar esses dados em outra tabela

				DescontoInput =  ref("Desconto"&splInv(i))

				if ValorDesconto="" then
					ValorDesconto=0
				end if
				if DescontoInput="" then
					DescontoInput=0
				end if
				
				if desTipoInvP = "P" then
					DescontoInput = valInv * DescontoInput / 100
				end if
				
				if temdescontocadastrado=1 and  CCUR(ValorDesconto) <> CCUR(DescontoInput)  then
					msgExtra = "Alguns itens necessitam de aprovação para o desconto"
					AguardaDesconto=True
					set DescontosSQL = db_execute("select * from descontos_pendentes where ItensInvoiceID = "&NewItemID&"")
					if not DescontosSQL.eof then
						sqlInsertpendente = "update descontos_pendentes set DataHora=NOW(), sysUserAutorizado=null,DataHoraAutorizado=null, Desconto = "&treatvalzero(DescontoInput)&",  Status = 0, SysUser = "&session("User")&" where id = " & DescontosSQL("id")
						db_execute(sqlInsertpendente)
					else
						sqlInsertpendente = "insert into descontos_pendentes values (null, "&NewItemID&", "&treatvalzero(DescontoInput)&", 0, "&session("User")&", now(), null, null, now())"
						db_execute(sqlInsertpendente)

						set DescontosSQL = db_execute("select * from descontos_pendentes where ItensInvoiceID = "&NewItemID&" order by id desc limit 1")
					end if

					'Gravar na tabela notificacao
					idsU = Split(idUsuariosDesconto,",")
					for j = 0 to ubound(idsU) 
						idUsuario = idsU(j)

						if idUsuario&"" <> "0" then 
							sqlNotificacao = "insert into notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID) " &_ 
								" values(4, "&idUsuario&", "&DescontosSQL("id")&", "&session("User")&", 1,1)" 
							db_execute(sqlNotificacao)

						end if

					next
				end if
			end if
		next

		sqlSave = "update propostas set Valor="&treatvalzero(totalProposta)&" where id="&PropostaID
		db_execute(sqlSave)
		'<Aciona webhook de sincronização com SalesForce>
		if recursoAdicional(45) = 4 then
			call webhook(124, true, "[PropostaID]", PropostaID)
		end if
		'</Aciona webhook de sincronização com SalesForce>

		'formas da proposta
		db_execute("delete from pacientespropostasformas where PropostaID="&PropostaID)
		splInv = split(ref("propostaFormas"), ", ")
		totInvo = 0
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			if Row>0 then
				camID = "id,"
				valID = ii&","
			else
				camID = ""
				valID = ""
			end if
			sqlInsert = "insert into pacientespropostasformas ("&camID&" PropostaID, Descricao, sysActive, sysUser) values ("&valID&" "&PropostaID&", '"&ref("DescricaoFormas"&splInv(i))&"', 1, "&session("User")&")"
			'response.Write("//"&ii&" - "&sqlInsert)
			db_execute(sqlInsert)
		next
		'<-

		'outras despesas
		db_execute("delete from pacientespropostasoutros where PropostaID="&PropostaID)
		splInv = split(ref("propostaOutros"), ", ")
		totInvo = 0
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			if Row>0 then
				camID = "id,"
				valID = ii&","
			else
				camID = ""
				valID = ""
			end if
			sqlInsert = "insert into pacientespropostasoutros ("&camID&" PropostaID, Descricao, Valor, sysActive, sysUser) values ("&valID&" "&PropostaID&", '"&ref("DescricaoOutros"&splInv(i))&"', '"&ref("ValorOutros"&splInv(i))&"', 1, "&session("User")&")"
			'response.Write("//"&ii&" - "&sqlInsert)
			db_execute(sqlInsert)
		next
		'<-
	end if
		if autosave = 0 then
			%>
			new PNotify({
				title: 'Sucesso!',
				text: 'Proposta salva. <%=msgExtra%>',
				type: 'success',
				delay: 2000
			});
			$("#sysActive").val("1");
			
			<%
		end if
	else
	%>
	new PNotify({
		title: 'ERRO!',
		text: '<%=erro%>',
		type: 'danger',
        delay: 2500
	});
	<%
end if
%>

<!--#include file="disconnect.asp"-->