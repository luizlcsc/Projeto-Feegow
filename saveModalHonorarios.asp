<!--#include file="connect.asp"-->
<!--#include file="testaCPF.asp"-->
<%

ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")

rfAssociacao = 5
rfProfissionalID = ref("ProfissionalID"&ItemID)
if instr(rfProfissionalID, "_")>0 then
	splProf = split(rfProfissionalID, "_")
	rfAssociacao = splProf(0)
	rfProfissionalID = splProf(1)
end if


if Tipo="Profissionais" then
	if erro="" then
		Associacao = ref("tipoProfissional")
		ProfissionalID = ref("gProfissionalID")
		if Associacao = "" then
			Associacao = 5
		end if
		if Associacao = 8 then
			ProfissionalID = ref("gProfissionalExternoID")
		end if
        if Associacao = 5 and ref("GrauParticipacaoID")<>"0" then
            db_execute("update profissionais set GrauPadrao="&ref("GrauParticipacaoID")&" where id="&ProfissionalID&" and (isnull(GrauPadrao) or GrauPadrao=0)")
        end if
		if CalculaCPF(ref("CodigoNaOperadoraOuCPF"))=True then
			cpf = replace(replace(replace(ref("CodigoNaOperadoraOuCPF"), " ", ""), ".", ""), "-", "")
			cpf = left(cpf, 3)&"."&mid(cpf, 4, 3)&"."&mid(cpf, 7, 3)&"-"&right(cpf, 2)
			sqlCPF = ", CPF = '"&cpf&"'"
		end if
		set cbo=db.execute("select * from especialidades where codigoTISS like '"&ref("CodigoCBO")&"'")
		if not cbo.eof then
			EspecialidadeID = cbo("id")
		else
			EspecialidadeID = 0
		end if
		'db_execute("update profissionais set Conselho='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', EspecialidadeID="&EspecialidadeID&sqlCPF&" where id="&ref("gProfissionalID"))
		if ItemID="0" then
			db_execute("insert into tissprofissionaishonorarios (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser, Associacao) values ("&GuiaID&", '"&ref("Sequencial")&"', '"&ref("GrauParticipacaoID")&"', '"&ProfissionalID&"', '"&ref("CodigoNaOperadoraOuCPF")&"', '"&ref("ConselhoID")&"', '"&ref("DocumentoConselho")&"', '"&ref("UFConselho")&"', '"&ref("CodigoCBO")&"', '"&session("User")&"',"&Associacao&")")
		else
			db_execute("update tissprofissionaishonorarios set Sequencial='"&ref("Sequencial")&"', GrauParticipacaoID='"&ref("GrauParticipacaoID")&"', ProfissionalID='"&ref("gProfissionalID")&"', CodigoNaOperadoraOuCPF='"&ref("CodigoNaOperadoraOuCPF")&"', ConselhoID='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', CodigoCBO='"&ref("CodigoCBO")&"', sysUser='"&session("User")&"', Associacao="&Associacao&" where id="&ItemID)
		end if
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprofissionaishonorarios", "tissprofissionaishonorarios.asp?I=<%=GuiaID%>");
		<%
	end if
elseif Tipo="Procedimentos" then
	if erro="" then

		'procedimento na tabela
		sqlPT = "select * from tissprocedimentostabela where Codigo='"&trim(ref("CodigoProcedimento"))&"' and TabelaID="&ref("TabelaID")
		set pt = db.execute(sqlPT)
		if pt.eof then
			db_execute("insert into tissprocedimentostabela (Codigo, Descricao, TabelaID, sysActive, sysUser) values ('"&trim(ref("CodigoProcedimento"))&"', '"&trim(ref("Descricao"))&"', '"&ref("TabelaID")&"', 1, "&session("User")&")")
			set pt = db.execute(sqlPT)
		else
			db_execute("update tissprocedimentostabela set Descricao='"&ref("Descricao")&"' where id="&pt("id"))
		end if



		if ref("gConvenioID")<>"" and ref("gConvenioID")<>"0" then
		
		
		
'original
'			set proc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&ref("ProcedimentoID")&" and ConvenioID="&ref("ConvenioID"))
'			if proc.eof then
'				db_execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, TabelaID, CodigoProcedimento, Valor, TecnicaID) values ('"&ref("ProcedimentoID")&"', '"&ref("ConvenioID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&treatval(ref("ValorUnitario"))&"', '"&ref("TecnicaID")&"')")
'			else
'				db_execute("update tissprocedimentosvalores set TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Valor='"&treatval(ref("ValorUnitario"))&"', TecnicaID='"&ref("TecnicaID")&"' where id="&proc("id"))
'			end if
			
			
'/original
			sqlPV = "select * from tissprocedimentosvalores where ProcedimentoID="&ref("gProcedimentoID")&" and ConvenioID="&ref("gConvenioID")
			set pv = db.execute(sqlPV)
			if pv.eof then
				db_execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, TecnicaID, NaoCobre) values ('"&ref("gProcedimentoID")&"', '"&ref("gConvenioID")&"', "&pt("id")&", "&treatvalzero(ref("ValorUnitario"))&", 1, '')")
				set pv = db.execute(sqlPV)
			else
				if ref("PlanoID")="0" then
					db_execute("update tissprocedimentosvalores set ProcedimentoTabelaID="&pt("id")&", Valor="&treatvalzero(ref("ValorUnitario"))&" where id="&pv("id"))
				end if
			end if
			if ref("PlanoID")<>"0" then
				set pvp = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&pv("id")&" and PlanoID="&ref("PlanoID"))
				if pvp.eof then
					db_execute("insert into tissprocedimentosvaloresplanos (AssociacaoID, PlanoID, Valor, NaoCobre) values ("&pv("id")&", "&ref("PlanoID")&", "&treatvalnull(ref("ValorUnitario"))&", '')")
				else
					db_execute("update tissprocedimentosvaloresplanos set Valor="&treatvalnull(ref("ValorUnitario"))&" where id="&pvp("id"))
				end if
			end if
		end if

		if ItemID="0" then
			db_execute("insert into tissprocedimentoshonorarios (GuiaID, ProfissionalID,Associacao, Data, HoraInicio, HoraFim, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser) values ("&GuiaID&", "&rfProfissionalID&", "&rfAssociacao&",'"&myDate(ref("Data"))&"', "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("gProcedimentoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&ref("Descricao")&"', '"&ref("Quantidade")&"', '"&ref("ViaID")&"', '"&ref("TecnicaID")&"', '"&treatval(ref("Fator"))&"', '"&treatval(ref("ValorUnitario"))&"', '"&treatval(ref("ValorTotal"))&"', '"&session("User")&"')")
			set pult = db.execute("select id from tissprocedimentoshonorarios where GuiaID="&GuiaID&" and sysUser="&session("User")&" order by id desc LIMIT 1")
			EsteItem = pult("id")
		else
			db_execute("update tissprocedimentoshonorarios set ProfissionalID="&rfProfissionalID&", Associacao="&rfAssociacao&", Data="&myDatenull(ref("Data"))&", HoraInicio="&myTime(ref("HoraInicio"))&", HoraFim="&myTime(ref("HoraFim"))&", ProcedimentoID='"&ref("gProcedimentoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Descricao='"&ref("Descricao")&"', Quantidade='"&ref("Quantidade")&"', ViaID='"&ref("ViaID")&"', TecnicaID='"&ref("TecnicaID")&"', Fator='"&treatval(ref("Fator"))&"', ValorUnitario='"&treatval(ref("ValorUnitario"))&"', ValorTotal='"&treatval(ref("ValorTotal"))&"', sysUser='"&session("User")&"' where id="&ItemID)
			EsteItem = ItemID
		end if
		'verifica se na regra deste procedimento para este convenio existem despesas adicionais e insere (EsteItem é o id IDProcedimentohonorarios)
		'antes ele da um select pra ver se ja foi adicionado antes - criar coluna de IDProcedimentoshonorarios

       'if 1=2 then
		    set vDesp = db.execute("select pp.id as ppid, pp.*, pv.*, pt.*, p.CD, p.NomeProduto, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo as CodigoNoFabricante from tissprodutosprocedimentos as pp left join tissprodutosvalores as pv on pv.id=pp.ProdutoValorID left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID left join produtos as p on p.id=pt.ProdutoID left join tissprocedimentosvalores as procval on procval.id=pp.AssociacaoID where procval.ConvenioID like '"&ref("ConvenioID")&"' and procval.ProcedimentoID like '"&ref("ProcedimentoID")&"'")
		    while not vDesp.eof
			    Valor = vDesp("Valor")
			    if isnull(Valor) then Valor=0 end if
			    Quantidade = vDesp("Quantidade")
			    if isnull(Quantidade) then Quantidade=1 end if
			    ValorTotal = Quantidade*Valor
			    if not isnull(vDesp("ProdutoID")) then
				    db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", '"&vDesp("CD")&"', "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(vDesp("ProdutoID"))&", "&treatvalzero(vDesp("TabelaID"))&", '"&vDesp("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(vDesp("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotal)&", '"&vDesp("RegistroANVISA")&"', '"&vDesp("CodigoNoFabricante")&"', '"&vDesp("AutorizacaoEmpresa")&"', '"&rep(vDesp("NomeProduto"))&"')")
			    end if
		    vDesp.movenext
		    wend
		    vDesp.close
		    set vDesp=nothing
        'end if
		
        '-> inserindo o profissional executor nesta guia se ele nao existe
        if rfProfissionalID&""<>"0" and ref("gConvenioID")&""<>"" then
            set vca = db.execute("select id from tissprofissionaishonorarios where ProfissionalID="&rfProfissionalID&" and Associacao="&rfAssociacao&" and GuiaID="&GuiaID)
            if vca.eof then
				if Associacao = 8 then
					sqlProf = "select p.*, e.codigoTISS, '' as GrauPadrao from profissionalexterno p left join especialidades e on e.id=p.EspecialidadeID where p.id="&ProfissionalID&" and not isnull(p.Conselho) and p.Conselho<>'' and p.DocumentoConselho not like '' and p.UFConselho not like '' and not isnull(p.EspecialidadeID) and p.EspecialidadeID!=0"
				else
					sqlProf = "select p.*, e.codigoTISS from profissionais p left join especialidades e on e.id=p.EspecialidadeID where p.id="&rfProfissionalID&" and not isnull(p.GrauPadrao) and p.GrauPadrao!=0 and not isnull(p.Conselho) and p.Conselho<>'' and p.DocumentoConselho not like '' and p.UFConselho not like '' and not isnull(p.EspecialidadeID) and p.EspecialidadeID!=0"
				end if
  '             response.write(sqlProf)
               set prof = db.execute(sqlProf)
               if not prof.eof then
                    if len(prof("CPF"))>3 then
                        CodigoNaOperadora = prof("CPF")
                    end if
                    set vcaContrato = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado="&prof("id")&" and CodigoNaOperadora not like ''")
                    if not vcaContrato.eof then
                        CodigoNaOperadora = vcaContrato("CodigoNaOperadora")
                    end if
                    if CodigoNaOperadora<>"" then
                        db_execute("insert into tissprofissionaishonorarios (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, Associacao) values ("&GuiaID&", "&getSequencial(GuiaID)&", "&treatvalzero(prof("GrauPadrao"))&", "&prof("id")&", '"&rep(CodigoNaOperadora)&"', "&treatvalzero(prof("Conselho"))&", '"&rep(prof("DocumentoConselho"))&"', '"&rep(left(prof("UFConselho")&" ", 2))&"', '"&prof("codigoTISS")&"',"&rfAssociacao&")")
                        %>
        		        atualizaTabela("tissprofissionaishonorarios", "tissprofissionaishonorarios.asp?I=<%=GuiaID%>");
                        <%
                    end if
                end if
            end if
        end if
        '<- inserindo o prof...
		
		if 0 then
		'--------------> inicio da gravacao dos repasses
		n = ItemID
		SobraRep = ""
		splRep = split(ref("strRep"&n), "|")
		set pSobraRep = db.execute("select id from rateiorateios where ItemGuiaID="&EsteItem)
		while not pSobraRep.eof
			SobraRep = SobraRep&"|"&pSobraRep("id")&"|"
		pSobraRep.movenext
		wend
		pSobraRep.close
		set pSobraRep=nothing

		'if ref("ProfissionalID"&n)<>0 then
			for g=0 to ubound(splRep)
				if splRep(g)<>"" and isnumeric(splRep(g)) then
					nRep = ccur(splRep(g))
					if nRep<0 then
						db_execute("insert into rateiorateios (ItemGuiaID, Funcao, TipoValor, Sobre, Valor, ContaCredito, sysDate, FM, ProdutoID, ValorUnitario, Quantidade, sysUser) values ("&EsteItem&", '"&ref("Funcao"&n&"-"&nRep)&"', '"&ref("TipoValor"&n&"-"&nRep)&"', '"&ref("Sobre"&n&"-"&nRep)&"', "&treatvalzero(ref("Valor"&n&"-"&nRep))&", '"&ref("ContaCredito"&n&"-"&nRep)&"', '"&mydate(date())&"', '"&ref("FM"&n&"-"&nRep)&"', "&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", "&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", "&treatvalzero(ref("Quantidade"&n&"-"&nRep))&", "&session("User")&")")
					else
						db_execute("update rateiorateios set Funcao='"&ref("Funcao"&n&"-"&nRep)&"', TipoValor='"&ref("TipoValor"&n&"-"&nRep)&"', Sobre='"&ref("Sobre"&n&"-"&nRep)&"', Valor="&treatvalzero(ref("Valor"&n&"-"&nRep))&", ContaCredito='"&ref("ContaCredito"&n&"-"&nRep)&"', sysDate='"&mydate(date())&"', ProdutoID="&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", ValorUnitario="&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", Quantidade="&treatvalzero(ref("Quantidade"&n&"-"&nRep))&" where id="&nRep)
					end if
					sobraRep = replace(sobraRep, "|"&nRep&"|", "")
				end if
			next
		'end if

		splSobraRep = split(sobraRep, "|")
		for h=0 to ubound(splSobraRep)
			if splSobraRep(h)<>"" and isnumeric(splSobraRep(h)) then
				db_execute("delete from rateiorateios where id="&splSobraRep(h))
			end if
		next
		'--------------> fim da gravacao dos repasses
		end if
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprocedimentoshonorarios", "tissprocedimentoshonorarios.asp?I=<%=GuiaID%>");
        tissRecalcGuiaHonorarios('Recalc');
		<%
	end if
end if
%>