<!--#include file="connect.asp"-->
<!--#include file="Classes/ValidaProcedimentoProfissional.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%


InvoiceID = req("I")
CD = ref("T")
msgExtra=""
temregradesconto=ref("temregradesconto")
if temregradesconto="" then
    temregradesconto="0"
end if

idUsuariosDesconto = "0"

totalValorDescontado = 0
totalValorDescontadoEnvio = 0
totalValorAcrescido = 0
contaRateada = 0
sqlRateio = "select count(*) total from invoice_rateio where InvoiceID = " & InvoiceID
set rsRateio = db.execute(sqlRateio)
if not rsRateio.eof then
	if ccur(rsRateio("total")) > 0 then
		contaRateada = 1
	end if
end if


' ######################### BLOQUEIO FINANCEIRO ########################################
if verificaBloqueioConta(1, 1, 1, ref("CompanyUnitID"),ref("sysDate")) then
 %>
         showMessageDialog("Esta conta está BLOQUEADA e não pode ser alterada!");
         $("#btnSave").prop("disabled", false);

     saveExecutados();
 <%
        response.write(retorno)
        response.end
end if

' #####################################################################################

if temregradesconto=1 then
	'Validar se existe algum desconto cadastrado para o sistema
	querydesconto = ""
	temdescontocadastrado=0
	'if CD="D" then
	'querydesconto="ContasAPagar"
	'elseif CD="C" then
	if CD="C" then
	querydesconto="ContasAReceber"
	end if

	if querydesconto<>"" then
		set rsDescontoItem = db.execute("select * from regrasdescontos descontos INNER JOIN regraspermissoes rp ON rp.id=descontos.RegraID where descontos.Recursos LIKE '%|"&querydesconto&"|%'")
		if not rsDescontoItem.eof then
			temdescontocadastrado=1
		end if

		'Pegar todos os descontos do usuário pelo perfil dele
		set rsDescontosUsuario = db.execute("select suser.id as idUser, rd.id, Recursos, Unidades, rd.RegraID, Procedimentos, DescontoMaximo, TipoDesconto "&_
											" from regrasdescontos rd  "&_
											" INNER JOIN regraspermissoes rp ON rp.id = rd.RegraID "&_
											" INNER JOIN sys_users suser on suser.Permissoes LIKE CONCAT('%[',rd.RegraID,']%') "&_
											" WHERE  rd.Recursos LIKE '%"&querydesconto&"%' AND (rd.Unidades LIKE '%|"& session("UnidadeID") &"|%' OR rd.Unidades  = '' OR rd.Unidades IS NULL OR rd.Unidades  = '0' ) AND rd.RegraID IS NOT NULL")

		'select suser.id, rd.id, Recursos, Unidades, rd.RegraID, Procedimentos, DescontoMaximo, TipoDesconto from regrasdescontos rd inner join sys_users suser on suser.Permissoes LIKE CONCAT('%[',rd.RegraID,']%') WHERE suser.id = 3531 AND rd.Recursos LIKE '%ContasAReceber%' AND (rd.Unidades LIKE '%|6|%' OR rd.Unidades = '' )
	end if
end if


if left(ref("AccountID"), 2)="3_" then
	splPac = split(ref("AccountID"), "_")
	PacienteID = splPac(1)
end if

set caixa = db.execute("select * from caixa where sysUser="&session("User")&" and isnull(dtFechamento)")
if not caixa.eof then
	CaixaID = caixa("id")
end if

'Verificar se há lancto financeiro em qualquer das parcelas antes de alterar dados da invoice
set inv = db.execute("select * from sys_financialinvoices where id="&InvoiceID)
if getConfig("PermitirAlterarPacienteContaAReceber") = "0" then'TROCAR PARA VERIFICACAO SE HA CONFIG DE BLOQUEIO DE TROCA DE UNIDADE E CONTA NA FATURA
	if inv("sysActive")=1 and instr(ref("AccountID"), "_")>0 then
		splAcc = split(ref("AccountID"), "_")
		AssociationAccountID = ccur(splAcc(0))
		AccountID = ccur(splAcc(1))
		if AssociationAccountID<>inv("AssociationAccountID") or AccountID<>inv("AccountID") then
			erro = "Você não pode alterar a conta de uma fatura já salva."
		end if
		if inv("AssociationAccountID")=3 and ref("CompanyUnitID")<>inv("CompanyUnitID")&"" then
			erro = "Você não pode alterar a unidade de uma fatura já salva."
		end if
	end if
end if

if getConfig("profissionalsolicitanteobrigatorio") and ref("ProfissionalSolicitante")="" and CD="C" then
	erro = "Profissional solicitante obrigatório"
end if

set pg = db.execute("select m.id from sys_financialmovement m left join sys_financialdiscountpayments d on (d.InstallmentID=m.id or d.MovementID=m.id) where m.InvoiceID="&InvoiceID&" and not isnull(d.InstallmentID) and not isnull(d.MovementID)")
if not pg.eof then
	existePagto = "S"
end if

if ref("ExisteRepasse")="S" and aut("|repassesA|")=0 then
    existePagto="S"
end if

if existePagto="" then
	splAcc = split(ref("AccountID"), "_")
	splForma = split(ref("FormaID"), "_")

	AssociationAccountID = splAcc(0)
	AccountID = splAcc(1)

	if CD="C" then
		AccountAssociationIDCredit = 0
		AccountIDCredit = 0
		AccountAssociationIDDebit = AssociationAccountID
		AccountIDDebit = AccountID
		reverse = "D"
	else
		AccountAssociationIDCredit = AssociationAccountID
		AccountIDCredit = AccountID
		AccountAssociationIDDebit = 0
		AccountIDDebit = 0
		reverse = "C"
	end if

	'1. Verificar erro de valores digitados errado
	splInv = split(ref("inputs"), ", ")
	totInvo = 0
	for i=0 to ubound(splInv)
		valInv = ref("ValorUnitario"&splInv(i))
		if valInv&"" = "" then
		    valInv="0"
		end if
		quaInv = ref("Quantidade"&splInv(i))
		' Validar quando não tiver desconto
		desInv = ref("Desconto"&splInv(i))
		acrInv = ref("Acrescimo"&splInv(i))

		ValorDesconto = ref("Desconto"&splInv(i))

        if ValorDesconto&"" <> "" then
            totalValorDescontadoEnvio = totalValorDescontadoEnvio + ValorDesconto
        end if
		DescontoMaximo = 0
		Tipo = ref("Tipo"&splInv(i))

		
        if temregradesconto<>"" then
            if temregradesconto=1 then
                if temdescontocadastrado=1 then
					descontoIgual = False
					idItensInvoice = splInv(i)
					'Verificar se o desconto enviado é o mesmo ja
					sqlIntesInvoice = "select ValorUnitario, IFNULL(Desconto, 0) Desconto from itensinvoice where id = " & idItensInvoice
                    set itensInvoice = db.execute(sqlIntesInvoice)
                    if not itensInvoice.eof then
						if ValorDesconto&"" <> "" then
							if ccur(itensInvoice("Desconto")) = ccur(ValorDesconto) then
								descontoIgual = True
							end if
						end if
                    end if

					if descontoIgual = False then
					    if isnumeric(ref("Quantidade"&splInv(i))) and isnumeric(ref("Desconto"&splInv(i))) then


                            ValorDesconto = ref("Quantidade"&splInv(i)) * ref("Desconto"&splInv(i))
                            if not rsDescontosUsuario.eof then

                                while not rsDescontosUsuario.eof
                                    procedimentoText = rsDescontosUsuario("Procedimentos")
                                    if  (instr(procedimentoText, "|"&ref("ItemID"&splInv(i))&"|" ) AND "S"=Tipo) OR trim(procedimentoText)="" then
                                        if rsDescontosUsuario("idUser")&"" = Session("User")&"" then
                                            VDesconto = rsDescontosUsuario("DescontoMaximo")
                                            if rsDescontosUsuario("TipoDesconto")="P" then
                                                VDesconto = valInv * rsDescontosUsuario("DescontoMaximo") / 100
                                            end if

                                            if VDesconto > DescontoMaximo then DescontoMaximo = VDesconto end if
                                        else
                                            VDescontomaximo = rsDescontosUsuario("DescontoMaximo")
                                            if rsDescontosUsuario("TipoDesconto")="P" then
                                                VDescontomaximo = valInv * rsDescontosUsuario("DescontoMaximo") / 100
                                            end if

                                            valorDescontoPermitido = valInv * 0.05

                                            if ValorDescontoFinal <= VDescontomaximo and VDescontomaximo>valorDescontoPermitido then
                                                idUsuariosDesconto = idUsuariosDesconto & "," & rsDescontosUsuario("idUser")
                                            end if
                                        end if
                                    end if
                                    rsDescontosUsuario.movenext
                                wend
                                rsDescontosUsuario.movefirst
                            end if
                        end if

						if ValorDesconto = "" then
							ValorDesconto=0
						end if


						if DescontoMaximo < CCUR(ValorDesconto)  then
							totalValorDescontado = totalValorDescontado + CCUR(ValorDesconto)
							ValorDesconto = 0
						end if
					end if
                end if
            end if
        end if

		if isnumeric(valInv) and valInv<>"" then valInv=ccur(valInv) else valInv=0 end if
		if isnumeric(quaInv) and quaInv<>"" then quaInv=ccur(quaInv) else quaInv=1 end if
		if isnumeric(desInv) and desInv<>"" then desInv=ccur(desInv) else desInv=0 end if
		if isnumeric(ValorDesconto) and ValorDesconto<>"" then ValorDesconto=ccur(ValorDesconto) else ValorDesconto=0 end if
		if isnumeric(acrInv) and acrInv<>"" then acrInv=ccur(acrInv) else acrInv=0 end if
		'totInvo = totInvo + (quaInv * (valInv-desInv+acrInv))
		totInvo = totInvo + (quaInv * (valInv-ValorDesconto+acrInv))
		totalValorAcrescido = totalValorAcrescido + acrInv
	next

	splPar = split(ref("ParcelasID"), ", ")
	totParc = 0

    fim =  ubound(splPar)
	for i=0 to ubound(splPar)
		valPar = ref("Value"&splPar(i))

        if temregradesconto=1 then
            if temdescontocadastrado=1 then
                if totalValorDescontadoEnvio > 0 then
                    valPar = valPar + ( totalValorDescontado /  (fim + 1))
                end if
            end if
        end if

		if isnumeric(valPar) and valPar<>"" then
			valPar = ccur(valPar)
			totParc = totParc+valPar
		end if
	next

	if totInvo<=(totParc-0.05) or totInvo>=(totParc+0.05) then
		erro = "O valor total n&atilde;o coincide com a soma das parcelas."
	end if
end if

if (ref("invTabelaID")="" or ref("invTabelaID")="0") and getConfig("ObrigarTabelaParticular") and CD="C" and existePagto="" then
	erro = "Erro: Preencha a tabela"
end if


if erro="" then

	'rateios
    if newRep()=0 then
        sqlExecute = "delete rr from rateiorateios rr left join itensinvoice ii on rr.ItemInvoiceID=ii.id where ii.InvoiceID="&InvoiceID&" and (isnull(rr.ItemContaAPagar) OR rr.ItemContaAPagar=0)"
    	db_execute(sqlExecute)
    end if
	splInv = split(ref("inputs"), ", ")

	itensStr = ""

    Valor = ref("Valor")
    ZeradoComRepasse = False

    if Valor&"" = "" then
        Valor=0
    end if

    if ccur(Valor)=0 and ref("NaoAlterarExecutante")<>"" then
		'variavel nao sendo utilizada mais. #6765
        ZeradoComRepasse=True
    end if

	if existePagto="" then
		'itens

		'--- Verifica se o profissional executa o procedimento antes do delete.
		for i=0 to ubound(splInv)
            ii = splInv(i)

            if itensStr="" then
                itensStr=ii
            else
                itensStr=itensStr&","&ii
            end if

            if instr(ref("ProfissionalID"&ii), "_")>0 then
                splAssoc = split(ref("ProfissionalID"&ii), "_")
                Associacao = splAssoc(0)
                ProfissionalID = splAssoc(1)
            else
                Associacao = 0
                ProfissionalID = 0
            end if


            procedimentoID = ref("ItemID"&ii)
            EspecialidadeID = ref("EspecialidadeID"&ii)
            Executado = ref("Executado"& ii)

            if procedimentoID<>"" and Executado="S" then
                if ProfissionalID&""="" or ProfissionalID&""="0" then
                    erro = "Preencha o profissional"
                end if

                if Associacao="5" or Associacao="2" or Associacao="8"  then

                    if validaProcedimentoProfissional(Associacao, ProfissionalID, EspecialidadeID, ProcedimentoID,0)=False then


						set ProcedimentoErroSQL = db.execute("SELECT NomeProcedimento FROM procedimentos where id="&ProcedimentoID)
						if not ProcedimentoErroSQL.eof then
							NomeProcedimentoErro = ProcedimentoErroSQL("NomeProcedimento")
						end if

                        erro = "Procedimento "&NomeProcedimentoErro&" não permitido para este Profissional e/ou Especialidade"

                    end if
                END IF
            END IF


            if erro<>"" then
            %>
            showMessageDialog('<%=erro%>');
            $("#btnSave").prop("disabled", false);
            <%
            Response.End
            end if
        next
        '---- Termina a verificação de o profissional pod executar o procedimento


        if session("Banco")="clinic5760" then
            db.execute("insert into itensinvoice_bck (`id`, `InvoiceID`, `Tipo`, `Quantidade`, `CategoriaID`, `ItemID`, `ValorUnitario`, `Desconto`, `Descricao`, `Executado`, `DataExecucao`, `HoraExecucao`, `GrupoID`, `AgendamentoID`, `sysUser`, `sysDate`, `ProfissionalID`, `EspecialidadeID`, `HoraFim`, `Acrescimo`, `AtendimentoID`, `Associacao`, `CentroCustoID`, `OdontogramaObj`, `PacoteID`, `DHUp`, `GeradoAutomaticamente`) select `id`, `InvoiceID`, `Tipo`, `Quantidade`, `CategoriaID`, `ItemID`, `ValorUnitario`, `Desconto`, `Descricao`, `Executado`, `DataExecucao`, `HoraExecucao`, `GrupoID`, `AgendamentoID`, `sysUser`, `sysDate`, `ProfissionalID`, `EspecialidadeID`, `HoraFim`, `Acrescimo`, `AtendimentoID`, `Associacao`, `CentroCustoID`, `OdontogramaObj`, `PacoteID`, `DHUp`, `GeradoAutomaticamente` from itensinvoice where InvoiceID="&InvoiceID)
        end if

        sqlExecute = "delete from itensinvoice where InvoiceID="&InvoiceID
        if itensStr&""<>"" then
		    sqlExecute = "delete from itensinvoice where InvoiceID="&InvoiceID&" AND id not in ("&itensStr&")"
			db.execute("DELETE FROM tissguiasinvoice WHERE InvoiceID="&InvoiceID&" AND ItemInvoiceID not in ("&itensStr&")")			
		end if

		call gravaLogs(sqlExecute ,"AUTO", "Item excluído manualmente","InvoiceID")
		db_execute(sqlExecute)

		'-> roda de novo o processo de cima
		totInvo = 0


		for i=0 to ubound(splInv)
			ii = splInv(i)

			Row = ccur(ii)
			valInv = ref("ValorUnitario"&splInv(i))
			quaInv = ref("Quantidade"&splInv(i))
			desInv = ref("Desconto"&splInv(i))
			acrInv = ref("Acrescimo"&splInv(i))
			if isnumeric(valInv) and valInv<>"" then valInv=ccur(valInv) else valInv=0 end if
			if isnumeric(quaInv) and quaInv<>"" then quaInv=ccur(quaInv) else quaInv=1 end if
			if isnumeric(desInv) and desInv<>"" then desInv=ccur(desInv) else desInv=0 end if
			if isnumeric(acrInv) and acrInv<>"" then acrInv=ccur(acrInv) else acrInv=0 end if
			if Row>0 then
				camID = "id,"
				valID = ii&","
			else
				camID = ""
				valID = ""
			end if

            Tipo = ref("Tipo"&ii)

			if instr(ref("ProfissionalID"&ii), "_")>0 then
				splAssoc = split(ref("ProfissionalID"&ii), "_")
				Associacao = splAssoc(0)
				ProfissionalID = splAssoc(1)
			else
				Associacao = 0
				ProfissionalID = 0
			end if


            procedimentoID = ref("ItemID"&ii)
            EspecialidadeID = ref("EspecialidadeID"&ii)
            Executado = ref("Executado"& ii)

            if ref("Cancelado"& ii)="C" then
                Executado = "C"
            end if

			ValorDesconto = ref("Desconto"&ii)
			DescontoMaximo = 0
			VDesconto = 0
			if temregradesconto=1 then
				'Response.write("Desconto Maximo" & VDesconto & "  -- Valod desconto " & ValorDesconto)
				'Validar se o o valor do desconto esta conforme o valor limite para o desconto na regra dele
				if temdescontocadastrado=1 then
					'Existem descontos cadastrados rsDescontosUsuario
					descontoIgual = False
					idItensInvoice = splInv(i)
					'Verificar se o desconto enviado é o mesmo ja
					sqlIntesInvoice = "select ValorUnitario, IFNULL(Desconto, 0) Desconto from itensinvoice where id = " & idItensInvoice
                    set itensInvoice = db.execute(sqlIntesInvoice)
                    if not itensInvoice.eof then
						if ValorDesconto&"" <> "" then
							if ccur(itensInvoice("Desconto")) = ccur(ValorDesconto) then
								descontoIgual = True
							end if
						end if
                    end if

                    valorUnitario = ref("ValorUnitario"&ii)
                    if valorUnitario="" then
                        valorUnitario="0"
                    end if

					if descontoIgual = False then 
						if not rsDescontosUsuario.eof then
							while not rsDescontosUsuario.eof
								procedimentoText = rsDescontosUsuario("Procedimentos")
								if  (instr(procedimentoText, "|"&ref("ItemID"&ii)&"|" ) AND "S"=Tipo) OR trim(procedimentoText)="" then
									if rsDescontosUsuario("idUser")&"" = Session("User")&"" then 
										VDesconto = rsDescontosUsuario("DescontoMaximo")
										if rsDescontosUsuario("TipoDesconto")="P" then
											VDesconto = valorUnitario * rsDescontosUsuario("DescontoMaximo") / 100
										end if

										if VDesconto > DescontoMaximo then DescontoMaximo = VDesconto end if
									end if
								end if

								'Response.write("["& procedimentoText & "] || V="&VDesconto&" -- DescontoMaximo "&DescontoMaximo)
								rsDescontosUsuario.movenext
							wend
							rsDescontosUsuario.movefirst
						else
							ValorDesconto=0
						end if
					end if

                    if ValorDesconto="" then
                        ValorDesconto=0
                    end if

					if DescontoMaximo < CCUR(ValorDesconto) and DescontoMaximo <> 0 then
						'Nao pode inserir o desconto (nao permitido)
						ValorDesconto = 0
					end if
				end if
			end if

			if ref("RepasseGerado"&ii)="S" then
			    sqlInsert = "update itensinvoice set Descricao='"&ref("Descricao"&II)&"', HoraExecucao="&mytime(ref("HoraExecucao"&ii))&", HoraFim="&mytime(ref("HoraFim"&ii))&" WHERE id="&ii

				call gravaLogs(sqlInsert, "AUTO", "Item com repasse alterado", "")
            else
			
				if session("Odonto")=1 then
					sqlInsert = "REPLACE into itensinvoice ("&camID&" InvoiceID, Tipo, Quantidade, CategoriaID, CentroCustoID, ItemID, ValorUnitario, Desconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, Associacao, OdontogramaObj, PacoteID, EspecialidadeID) values ("&valID&" "&InvoiceID&", '"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&", "&treatvalzero(ref("CentroCustoID"&ii))&", "&treatvalzero(ref("ItemID"&ii))&", "&treatvalzero(ref("ValorUnitario"&ii))&", "&treatvalzero(ValorDesconto)&", '"&ref("Descricao"&ii)&"', '"& Executado &"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&", "&Associacao&", '"&replace(ref("OdontogramaObj"&ii), "\", "\\")&"', "& treatvalnull(ref("PacoteID"&ii)) &", "& treatvalnull(ref("EspecialidadeID"&ii)) &")"
				else
					sqlInsert = "REPLACE into itensinvoice ("&camID&" InvoiceID, Tipo, Quantidade, CategoriaID, CentroCustoID, ItemID, ValorUnitario, Desconto, Descricao, Executado, DataExecucao, HoraExecucao, AgendamentoID, sysUser, ProfissionalID, HoraFim, Acrescimo, AtendimentoID, Associacao, PacoteID, EspecialidadeID) values ("&valID&" "&InvoiceID&", '"&Tipo&"', "&quaInv&", "&treatvalzero(ref("CategoriaID"&ii))&", "&treatvalzero(ref("CentroCustoID"&ii))&", "&treatvalzero(ref("ItemID"&ii))&", "&treatvalzero(ref("ValorUnitario"&ii))&", "&treatvalzero(ValorDesconto)&", '"&ref("Descricao"&ii)&"', '"& Executado &"', "&mydatenull(ref("DataExecucao"&ii))&", "&mytime(ref("HoraExecucao"&ii))&", "&treatvalzero(ref("AgendamentoID"&ii))&", "&session("User")&", "&treatvalzero(ProfissionalID)&", "&mytime(ref("HoraFim"&ii))&", "&treatvalzero(ref("Acrescimo"&ii))&", "&treatvalnull(ref("AtendimentoID"&ii))&", "&Associacao&", "& treatvalnull(ref("PacoteID"&ii)) &", "& treatvalnull(ref("EspecialidadeID"&ii)) &")"
				end if
			end if

            'call gravaLogs(sqlInsert ,"E", "Item alterado manualmente","InvoiceID")

			valido = true
			if (Tipo="S" and ref("ItemID"&ii) = "0") or (Tipo="O" and ref("ItemID"&ii) = "0") then
				valido = false
			end if

			if valido=true then
				db.execute(sqlInsert)
			end if


			if Row<0 then
				set pult = db.execute("select id from itensinvoice order by id desc limit 1")
				NewItemID = pult("id")
			else
				NewItemID = Row
			end if

			if temregradesconto=1 then
				'Gravar esses dados em outra tabela

				DescontoInput = ref("Desconto"&ii)

				if ValorDesconto="" then
				    ValorDesconto=0
				end if
				if DescontoInput="" then
				    DescontoInput=0
				end if

				if temdescontocadastrado=1 and CCUR(DescontoInput) > 0  then
					msgExtra = "Alguns itens necessitam de aprovação para o desconto"
					set DescontosSQL = db.execute("select * from descontos_pendentes where ItensInvoiceID = "&NewItemID&"")
					if not DescontosSQL.eof then
						sqlInsertpendente = "update descontos_pendentes set DataHora=NOW(),Desconto = "&treatvalzero(ref("Desconto"&ii))&", sysUserAutorizado=null,DataHoraAutorizado=null,  Status = 0, SysUser = "&session("User")&" where id = " & DescontosSQL("id")
						db.execute(sqlInsertpendente)
					else
						sqlInsertpendente = "insert into descontos_pendentes values (null, "&NewItemID&", "&treatvalzero(ref("Desconto"&ii))&", 0, "&session("User")&", now(), null, null, now())"
						db.execute(sqlInsertpendente)

						set DescontosSQL = db.execute("select * from descontos_pendentes where ItensInvoiceID = "&NewItemID&" order by id desc limit 1")
					end if

					'Gravar na tabela notificacao
					idsU = Split(idUsuariosDesconto,",")
					for j = 0 to ubound(idsU) 
						idUsuario = idsU(j)

						if idUsuario&"" <> "0" then 
							sqlNotificacao = "insert into notificacoes(TipoNotificacaoID, UsuarioID, NotificacaoIDRelativo, CriadoPorID, Prioridade, StatusID) " &_ 
								" values(4, "&idUsuario&", "&DescontosSQL("id")&", "&session("User")&", 1,1)" 
							db.execute(sqlNotificacao)

						end if

					next
				end if
			end if

            call saveIIO (InvoiceID, NewItemID, Row)

            rows = rows & "|" & Row
            ids = ids & "|" & NewItemID

		next
		'<-


        set ArquivosAnexosSQL = db.execute("SELECT GROUP_CONCAT(arq.id)Arquivos FROM arquivos arq LEFT JOIN sys_financialmovement mov ON arq.MovementID=mov.id WHERE mov.InvoiceID="&InvoiceID)
        if not ArquivosAnexosSQL.eof then
            ArquivosAnexos = ArquivosAnexosSQL("Arquivos")
        else
            ArquivosAnexos=""
        end if

        set MovementSQL = db.execute("SELECT CodigoDeBarras FROM sys_financialmovement WHERE InvoiceID="&InvoiceID)
        if not MovementSQL.eof then
            CodigoDeBarras = MovementSQL("CodigoDeBarras")
        end if

		'parcelas
		'-> --------------------------------------------------------------------------
		sqlExecute = "delete from sys_financialmovement where InvoiceID="&InvoiceID
		db_execute(sqlExecute)
		splPar = split(ref("ParcelasID"), ", ")
		totParc = 0
		c=0
		fim =  ubound(splPar)
		for i=0 to ubound(splPar)
			valPar = ref("Value"&splPar(i))
			ii = splPar(i)
			if isnumeric(valPar) and valPar<>"" then
				c=c+1
				valPar = ccur(valPar)
				totParc = totParc+valPar
				if ccur(ii)>0 then
					camID = "id,"
					valID = ii&","
				else
					camID = ""
					valID = ""
				end if
				
				'Pegar a soma dos descontos que foram zerados por permissão e adicionar nas parcelas
				'totalValorDescontado
				valorInserido = ref("Value"&ii)

				if temregradesconto=1 then
					if temdescontocadastrado=1 then
						if totalValorDescontadoEnvio > 0 then
							valorInserido = ref("Value"&ii) + (  totalValorDescontado /  (fim + 1))
						end if
					end if
				end if

				
                Description = ref("Name"&ii)
				sqlFM = "insert into sys_financialmovement ("&camID&" AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID, CodigoDeBarras, Name) values ("&valID&"  "&AccountAssociationIDCredit&", "&AccountIDCredit&", "&AccountAssociationIDDebit&", "&AccountIDDebit&", "&treatvalzero(valorInserido)&", "&mydatenull(ref("Date"&ii))&", '"&inv("CD")&"', 'Bill', 'BRL', "&treatvalnull(ii)&", "&InvoiceID&", "&c&", "&session("User")&", "&treatvalnull(CaixaID)&", "&treatvalzero(ref("CompanyUnitID"))&", '"&CodigoDeBarras&"', '"&Description&"')"
				'response.Write("//|||||||||||||||||||||| sqlFM: "&sqlFM & "--"& Description)
				db.execute(sqlFM)
				'call gravaLog(sqlFM, "AUTO")
			end if
		next

		if ArquivosAnexos<>"" and camID="" then
            set InsertSQL = db.execute("SELECT id FROM sys_financialmovement ORDER BY id DESC LIMIT 1")
            MovementInsertID=InsertSQL("id")
            db_execute("update arquivos SET MovementID="&treatvalzero(MovementInsertID)&" WHERE id IN ("&ArquivosAnexos&")")
        end if

        DescricaoLog = "Conta alterada diretamente"
        TipoLogOp="E"

        if ref("sysActive")="0" then
            sqlCaixaID = ",CaixaID="&treatvalnull(session("CaixaID"))
            sqlUsuario = ",sysUser="&session("User")

            TipoLogOp = "I"
            DescricaoLog=""
        end if
        if scp()=1 then
			sqlInvoice = "update sys_financialinvoices set Rateado="&contaRateada&", AccountID="&AccountID&", AssociationAccountID="&AssociationAccountID&", Value="&treatvalzero(ref("Valor"))&", Tax=1, Currency='BRL', Recurrence="&treatvalnull(ref("Recurrence"))&", RecurrenceType='"&ref("RecurrenceType")&"', FormaID="&treatvalzero(splForma(0))&", ContaRectoID="&treatvalzero(splForma(1))&", TabelaID="& treatvalnull(ref("invTabelaID")) &", ProfissionalSolicitante='"&ref("ProfissionalSolicitante")&"', nroNFe='"& ref("nroNFe") &"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", sysActive=1 "& sqlCaixaID & sqlUsuario & gravaData &" where id="&InvoiceID
			'call gravaLog(sqlInvoice, "AUTO")
	    	db_execute(sqlInvoice)
        else
			sqlInvoice = "update sys_financialinvoices set Rateado="&contaRateada&", AccountID="&AccountID&", AssociationAccountID="&AssociationAccountID&", Value="&treatvalzero(ref("Valor"))&", Tax=1, Currency='BRL', Recurrence="&treatvalnull(ref("Recurrence"))&", RecurrenceType='"&ref("RecurrenceType")&"', FormaID="&treatvalzero(splForma(0))&", ContaRectoID="&treatvalzero(splForma(1))&", TabelaID="& treatvalnull(ref("invTabelaID")) &", ProfissionalSolicitante='"&ref("ProfissionalSolicitante")&"', nroNFe='"& ref("nroNFe") &"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", sysActive=1 "& sqlCaixaID & sqlUsuario & gravaData &" where id="&InvoiceID
		' 	call gravaLog(sqlInvoice, "AUTO")

			db_execute(sqlInvoice)
        end if
	else
		'ou seja, se já existem pagamentos, ele apenas atualiza os dados de execução dos itens desta invoice
		'-> roda de novo o processo de cima
		for i=0 to ubound(splInv)
			ii = splInv(i)
			Row = ccur(ii)
			if Row>0 then
				camID = "id"
				valID = ii
			else
				camID = ""
				valID = ""
			end if
			if instr(ref("ProfissionalID"&ii), "_")>0 then
				splAssoc = split(ref("ProfissionalID"&ii), "_")
				Associacao = splAssoc(0)
				ProfissionalID = splAssoc(1)
			else
				Associacao = 0
				ProfissionalID = 0
			end if

			'pega atendimento baseado na data e na hora
			AtendimentoID = 0'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            Executado = ref("Executado"&ii)
            if ref("Cancelado"& ii)="C" then
                Executado = "C"
            end if

            if ref("RepasseGerado"&ii)="S" then
			    sqlUpdate = "update itensinvoice set Descricao='"&ref("Descricao"&II)&"', HoraExecucao="&mytime(ref("HoraExecucao"&ii))&", HoraFim="&mytime(ref("HoraFim"&ii))&" WHERE id="&valID
            else
			    sqlUpdate = "update itensinvoice set Descricao='"&ref("Descricao"&II)&"', Executado='"& Executado &"', DataExecucao="&mydatenull(ref("DataExecucao"&ii))&", HoraExecucao="&mytime(ref("HoraExecucao"&ii))&", AgendamentoID="&treatvalzero(ref("AgendamentoID"&ii))&", CategoriaID="&treatvalzero(ref("CategoriaID"&ii))&", CentroCustoID="&treatvalzero(ref("CentroCustoID"&ii))&", ProfissionalID="&treatvalzero(ProfissionalID)&", HoraFim="&mytime(ref("HoraFim"&ii))&", AtendimentoID="&AtendimentoID&", Associacao="&treatvalzero(Associacao)&", EspecialidadeID="& treatvalnull(ref("EspecialidadeID"&ii)) &" WHERE id="&valID
            end if

			call gravaLogs(sqlUpdate, "AUTO", "Itens alterados", "")
			db.execute(sqlUpdate)
			'->itens do rateio irão aqui-----
'			if Row<0 then
'				set pult = db.execute("select id from itensinvoice order by id desc limit 1")
'				NewItemID = pult("id")
'			else
				NewItemID = Row
'			end if
            rows = rows & "|" & Row
            ids = ids & "|" & NewItemID

            set TemRepasseConsolidadeSQL = db.execute("SELECT rat.id FROM rateiorateios rat WHERE rat.ItemInvoiceID="&treatvalzero(NewItemID))
            if TemRepasseConsolidadeSQL.eof then
                call saveIIO (InvoiceID, NewItemID, Row)
            end if
		next
		'<-

	end if

    sqlAtualizaTabela = ""
    if existePagto="" or aut("|tabelacontapagaA|")=1 then
        sqlAtualizaTabela=" TabelaID="& treatvalnull(ref("invTabelaID")) &", "
    end if

  if scp()=1 then
    sqlUp = "update sys_financialinvoices set "&sqlAtualizaTabela&" Value="&treatvalzero(ref("Valor"))&", Description='"&ref("Description")&"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", sysDate="&mydatenull(ref("sysDate"))&", nroNFe='"& ref("nroNFe") &"', dataNFe="& mydatenull(ref("dataNFe")) &", valorNFe="& treatvalzero(ref("valorNFe")) &", ProfissionalSolicitante='"&ref("ProfissionalSolicitante")&"' where id="&InvoiceID
  else
    sqlUp = "update sys_financialinvoices set "&sqlAtualizaTabela&" Value="&treatvalzero(ref("Valor"))&", Description='"&ref("Description")&"', CompanyUnitID="&treatvalzero(ref("CompanyUnitID"))&", sysDate="&mydatenull(ref("sysDate"))&", nroNFe='"& ref("nroNFe") &"', ProfissionalSolicitante='"&ref("ProfissionalSolicitante")&"' where id="&InvoiceID
  end if

  call gravaLogs(sqlUp, TipoLogOp, DescricaoLog, "")

  db_execute(sqlUp)

  call reconsolidar("invoice", InvoiceID)

	if treatvalzero(ref("CompanyUnitID")) > "-1" then
		db_execute("delete from invoice_rateio where InvoiceID = "&InvoiceID)
	end if

    splRows = split(rows, "|")
    splIds = split(ids, "|")

    for r=1 to ubound(splIds)
        LinhaID = splRows(r)
        ItemID = splIds(r)
        if newRep()=0 then
            call salvaRepasse(LinhaID, ItemID)
        end if
    next


	action = "nova_conta_a_receber"
	category = "conta_a_receber"

	if CD="D" then
		action = "nova_conta_a_pagar"
		category = "conta_a_pagar"
	end if
	%>

	gtag('event', '<%=action%>', {
		'event_category': '<%=category%>',
		'event_label': "Botão 'Salvar' clicado.",
	});
	
	new PNotify({
		title: 'Salvo com sucesso!<%=msgExtra%>',
		text: '',
		type: 'success',
        delay: 1000
	});
	geraParcelas('N');
	$("#sysActive").val("1");

    if( $.isNumeric($("#PacienteID").val()) && $("#PendPagar").val()=="" )
    {
        $('#btnSave').prop('disabled', true);
        $('#btnSave').html('AGUARDE...');
        ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
    }else{
        $('#btnSave').prop('disabled', false);
    }

    itens('<%=CD%>', '', '');
	<%

else
	%>
	new PNotify({
		title: 'ERRO AO TENTAR SALVAR!',
		text: '<%=erro%>',
		type: 'danger',
        delay: 3000
	});
    $("#btnSave").prop("disabled", false);
	<%
end if
%>
<!--#include file="disconnect.asp"-->