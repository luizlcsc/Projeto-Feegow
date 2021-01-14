<!--#include file="connect.asp"-->
<!--#include file="testaCPF.asp"-->
<%
ItemID = request.QueryString("II")
GuiaID = request.QueryString("I")
Tipo = request.QueryString("T")

if Tipo="Profissionais" then
	if erro="" then
        if ref("GrauParticipacaoID")<>"0" then
         '   db_execute("update profissionais set GrauPadrao="&ref("GrauParticipacaoID")&" where id="&ref("gProfissionalID")&" and (isnull(GrauPadrao) or GrauPadrao=0)")
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
		db_execute("update profissionais set Conselho='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', EspecialidadeID="&EspecialidadeID&sqlCPF&" where id="&ref("gProfissionalID"))
		if ItemID="0" then
			db_execute("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&GuiaID&", '"&ref("Sequencial")&"', '"&ref("GrauParticipacaoID")&"', '"&ref("gProfissionalID")&"', '"&ref("CodigoNaOperadoraOuCPF")&"', '"&ref("ConselhoID")&"', '"&ref("DocumentoConselho")&"', '"&ref("UFConselho")&"', '"&ref("CodigoCBO")&"', '"&session("User")&"')")
		else
			db_execute("update tissprofissionaissadt set Sequencial='"&ref("Sequencial")&"', GrauParticipacaoID="& treatvalnull(ref("GrauParticipacaoID")) &", ProfissionalID='"&ref("gProfissionalID")&"', CodigoNaOperadoraOuCPF='"&ref("CodigoNaOperadoraOuCPF")&"', ConselhoID='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', CodigoCBO='"&ref("CodigoCBO")&"', sysUser='"&session("User")&"' where id="&ItemID)
		end if
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprofissionaissadt", "tissprofissionaissadt.asp?I=<%=GuiaID%>");
		<%
	end if
elseif Tipo="Procedimentos" then
	if erro="" then

		'procedimento na tabela
		if session("Banco")<>"clinic3882" and 1=2 then
            sqlPT = "select * from tissprocedimentostabela where Codigo='"&trim(ref("CodigoProcedimento"))&"' and TabelaID="&ref("TabelaID")
            set pt = db.execute(sqlPT)
            if pt.eof then
                db_execute("insert into tissprocedimentostabela (Codigo, Descricao, TabelaID, sysActive, sysUser) values ('"&trim(ref("CodigoProcedimento"))&"', '"&trim(ref("Descricao"))&"', '"&ref("TabelaID")&"', 1, "&session("User")&")")
                set pt = db.execute(sqlPT)
            else
                db_execute("update tissprocedimentostabela set Descricao='"&ref("Descricao")&"' where id="&pt("id"))
            end if
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
			    if session("Banco")<>"clinic3882" and 1=2 then
				    db_execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, TecnicaID, NaoCobre) values ('"&ref("gProcedimentoID")&"', '"&ref("gConvenioID")&"', "&pt("id")&", "&treatvalzero(ref("ValorUnitario"))&", 1, '')")
                end if
                ' set pv = db.execute(sqlPV)
			else


                if session("Banco")<>"clinic3882" and 1=2 then
                    if ref("PlanoID")="0" then
                        db_execute("update tissprocedimentosvalores set ProcedimentoTabelaID="&pt("id")&", Valor="&treatvalzero(ref("ValorUnitario"))&" where id="&pv("id"))
                    end if
                end if
			end if
			if session("Banco")<>"clinic3882" and 1=2 then
                if ref("PlanoID")<>"0" then
                    set pvp = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&pv("id")&" and PlanoID="&ref("PlanoID"))
                    if pvp.eof then
                        db_execute("insert into tissprocedimentosvaloresplanos (AssociacaoID, PlanoID, Valor, NaoCobre) values ("&pv("id")&", "&ref("PlanoID")&", "&treatvalzero(ref("ValorUnitario"))&", '')")
                    else
                        db_execute("update tissprocedimentosvaloresplanos set Valor="&treatvalzero(ref("ValorUnitario"))&" where id="&pvp("id"))
                    end if
                end if
            end if




		end if










		if ItemID="0" then

            db_execute("insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, HoraInicio, HoraFim, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser) values ("&GuiaID&", "&refnull("ProfissionalID"&ItemID)&", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("gProcedimentoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&ref("Descricao")&"', '"&ref("Quantidade")&"', '"&ref("ViaID")&"', '"&ref("TecnicaID")&"', "&treatvalzero(ref("Fator"))&", "&treatvalzero(ref("ValorUnitario"))&", "&treatvalzero(ref("ValorTotal"))&", '"&session("User")&"')")
			set pult = db.execute("select id from tissprocedimentossadt where GuiaID="&GuiaID&" and sysUser="&session("User")&" order by id desc LIMIT 1")
			EsteItem = pult("id")
		else
			db_execute("update tissprocedimentossadt set ProfissionalID="&refnull("ProfissionalID"&ItemID)&", Data="&myDatenull(ref("Data"))&", HoraInicio="&myTime(ref("HoraInicio"))&", HoraFim="&myTime(ref("HoraFim"))&", ProcedimentoID='"&ref("gProcedimentoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Descricao='"&ref("Descricao")&"', Quantidade='"&ref("Quantidade")&"', ViaID='"&ref("ViaID")&"', TecnicaID='"&ref("TecnicaID")&"', Fator='"&treatval(ref("Fator"))&"', ValorUnitario='"&treatval(ref("ValorUnitario"))&"', ValorTotal='"&treatval(ref("ValorTotal"))&"', sysUser='"&session("User")&"' where id="&ItemID)
			EsteItem = ItemID
		end if
        if ItemID="0" and not pv.eof then
            ' ve se tem procedimento anexo
            set ProcedimentosAnexosSQL = db.execute("SELECT * FROM tissprocedimentosanexos WHERE ConvenioID="&treatvalzero(ref("gConvenioID"))&" AND ProcedimentoPrincipalID="&pv("ProcedimentoID"))
            if not ProcedimentosAnexosSQL.eof then

                Fator = calculaFator(ref("GuiaID"))

                while not ProcedimentosAnexosSQL.eof
                    DataAtendimento=mydate(ref("Data"))
                    ProfissionalID=ref("ProfissionalID"&ItemID)

                    FatorReal = Fator
                    set TipoProcedimentoSQL = db.execute("SELECT TipoProcedimentoID FROM procedimentos WHERE id="&ProcedimentosAnexosSQL("ProcedimentoAnexoID"))
                    if TipoProcedimentoSQL("TipoProcedimentoID")=3 then
                        FatorReal = 1
                    end if

                    ValorAnexo = ProcedimentosAnexosSQL("Valor")
                    ValorTotalAnexo = 1 * FatorReal * ValorAnexo

                    db_execute("insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser) values ("&ref("GuiaID")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID"))&", 22, '"&rep(ProcedimentosAnexosSQL("Codigo"))&"', '"&rep(ProcedimentosAnexosSQL("Descricao"))&"', 1, 1, "&treatvalzero(1)&", "&treatvalzero(FatorReal)&", "&treatvalzero(ValorAnexo)&", "&treatvalzero(ValorTotalAnexo)&", "&session("User")&")")

                ProcedimentosAnexosSQL.movenext
                wend
                ProcedimentosAnexosSQL.close
                set ProcedimentosAnexosSQL=nothing
            end if
        end if
        if ref("gConvenioID")<>"" then
            set conv = db.execute("select c.MesclagemMateriais, (select count(id) from tissguiaanexa where GuiaID="&GuiaID&") NMateriais from convenios c where c.id="&ref("gConvenioID"))
            if not conv.eof then
                if ( conv("MesclagemMateriais")="Maior" and ccur(conv("NMateriais"))=0 ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
                    ' call matProcGuia(EsteItem, ref("gConvenioID"))
                end if
            end if
        end if
		'verifica se na regra deste procedimento para este convenio existem despesas adicionais e insere (EsteItem é o id IDProcedimentoSADT)
		'antes ele da um select pra ver se ja foi adicionado antes - criar coluna de IDProcedimentosSADT

       if 1=2 then
		    set vDesp = db.execute("select pp.id as ppid, pp.*, pv.*, pt.*, p.CD, p.NomeProduto, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo as CodigoNoFabricante from tissprodutosprocedimentos as pp left join tissprodutosvalores as pv on pv.id=pp.ProdutoValorID left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID left join produtos as p on p.id=pt.ProdutoID left join tissprocedimentosvalores as procval on procval.id=pp.AssociacaoID where procval.ConvenioID like '"&ref("ConvenioID")&"' and procval.ProcedimentoID like '"&ref("ProcedimentoID")&"'")
		    while not vDesp.eof
			    Valor = vDesp("Valor")
			    if isnull(Valor) then Valor=0 end if
			    Quantidade = vDesp("Quantidade")
			    if isnull(Quantidade) then Quantidade=1 end if
			    ValorTotal = Quantidade*Valor
			    if not isnull(vDesp("ProdutoID")) then
				    ' db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", '"&vDesp("CD")&"', "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(vDesp("ProdutoID"))&", "&treatvalzero(vDesp("TabelaID"))&", '"&vDesp("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(vDesp("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotal)&", '"&vDesp("RegistroANVISA")&"', '"&vDesp("CodigoNoFabricante")&"', '"&vDesp("AutorizacaoEmpresa")&"', '"&rep(vDesp("NomeProduto"))&"')")
			    end if
		    vDesp.movenext
		    wend
		    vDesp.close
		    set vDesp=nothing
       end if
       ' aqui entra nova forma de valores de itens
       ProcedimentoID = ref("gProcedimentoID")
       ConvenioID = ref("gConvenioID")

       if ConvenioID<>"" then
           set ProdutoValorSQL = db.execute("SELECT p.*, tpp.Quantidade,IF (tpt.Valor = 0, tpv.Valor,tpt.Valor)Valor,tpt.TabelaID,tpt.Codigo,tpt.ProdutoID,p.Codigo as CodigoNoFabricante FROM tissprocedimentosvalores pv LEFT JOIN tissprodutosprocedimentos tpp ON tpp.AssociacaoID=pv.id LEFT JOIN tissprodutostabela tpt ON tpt.id=tpp.ProdutoTabelaID LEFT JOIN tissprodutosvalores tpv ON tpv.ProdutoTabelaID=tpt.id AND tpv.ConvenioID=pv.ConvenioID LEFT JOIN produtos p ON p.id = tpt.ProdutoID WHERE pv.ProcedimentoID= "&ProcedimentoID&" AND pv.ConvenioID="&  ConvenioID)

           if not ProdutoValorSQL.eof then
                while not ProdutoValorSQL.eof
                    Valor = ProdutoValorSQL("Valor")
                    Quantidade = ProdutoValorSQL("Quantidade") * ref("Quantidade")
                    ValorTotalProduto = Quantidade *  Valor

                    if Valor > 0 then
                        db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", "&treatvalzero(ProdutoValorSQL("CD"))&", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(ProdutoValorSQL("ProdutoID"))&", "&treatvalzero(ProdutoValorSQL("TabelaID"))&", '"&ProdutoValorSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutoValorSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutoValorSQL("RegistroANVISA")&"', '"&ProdutoValorSQL("CodigoNoFabricante")&"', '"&ProdutoValorSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutoValorSQL("NomeProduto"))&"')")
                    end if
                ProdutoValorSQL.movenext
                wend
                ProdutoValorSQL.close
                set ProdutoValorSQL = nothing
           end if



           ' nova por kit ate morrer ----------------
           sqlKit="select pckit.*,pkit.id, pkit.TabelaID  from procedimentoskits pckit left join produtoskits pkit on pckit.KitID=pkit.id where pckit.ProcedimentoID="&ProcedimentoID&" and (pckit.Casos like '%|ConvALL|%' OR (pckit.Casos like '%|ConvEXCEPT|%' and not pckit.Casos like '%|"&ConvenioID&"|%') OR (pckit.Casos like '%|ConvONLY|%' and pckit.Casos like '%|"&ConvenioID&"|%'))"
           set KitSQL = db.execute(sqlKit)
           if not KitSQL.eof then
                 while not KitSQL.eof
                    TabelaID = KitSQL("TabelaID")
                    sqlProdutosDoKit = "select p.*, pt.Codigo, pt.Valor, pt.TabelaID, pt.id ProdutoTabelaID, p.Codigo as CodigoNoFabricante, pt.ProdutoID ,pdk.Quantidade FROM produtosdokit pdk LEFT JOIN produtos p ON p.id=pdk.ProdutoID LEFT JOIN tissprodutostabela pt ON pt.ProdutoID=p.id WHERE NOT ISNULL(p.NomeProduto) AND pdk.KitID="& KitSQL("KitID") &" GROUP BY p.id ORDER BY p.NomeProduto"
                    ' response.write(sqlProdutosDoKit)
                    set ProdutosKitSQL = db.execute(sqlProdutosDoKit)

                    while not ProdutosKitSQL.eof
                        Valor = ProdutosKitSQL("Valor")
                        if not isnull(ProdutosKitSQL("ProdutoTabelaID")) then
                            set ProdutoValorSQL = db.execute("select * from tissprodutosvalores pv where pv.ConvenioID="& ref("gConvenioID") &" and pv.ProdutoTabelaID="& ProdutosKitSQL("ProdutoTabelaID"))
                            if not ProdutoValorSQL.eof then
                                Valor = ProdutoValorSQL("Valor")
                            end if
                        end if
                        Quantidade = ProdutosKitSQL("Quantidade")
                        ValorTotalProduto = Quantidade *  Valor

                        if Valor>0 then
                            db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", "&treatvalzero(ProdutosKitSQL("CD"))&", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(ProdutosKitSQL("ProdutoID"))&", "&treatvalzero(ProdutosKitSQL("TabelaID"))&", '"&ProdutosKitSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutosKitSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutosKitSQL("RegistroANVISA")&"', '"&ProdutosKitSQL("CodigoNoFabricante")&"', '"&ProdutosKitSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutosKitSQL("NomeProduto"))&"')")
                        end if
                     ProdutosKitSQL.movenext
                     wend
                     ProdutosKitSQL.close
                     set ProdutosKitSQL = nothing
                 KitSQL.movenext
                 wend
                 KitSQL.close
                 set KitSQL = nothing
           end if
       end if



        '-> inserindo o profissional executor nesta guia se ele nao existe
        if ref("ProfissionalID"&ItemID)<>"0" then
            set vca = db.execute("select id from tissprofissionaissadt where ProfissionalID="&ref("ProfissionalID"&ItemID)&" and GuiaID="&GuiaID)
            if vca.eof then
               sqlProf = "select p.*, e.codigoTISS from profissionais p left join especialidades e on e.id=p.EspecialidadeID where p.id="&ref("ProfissionalID"&ItemID)&" and not isnull(p.GrauPadrao) and p.GrauPadrao!=0 and not isnull(p.Conselho) and p.Conselho<>'' and p.DocumentoConselho not like '' and p.UFConselho not like '' and not isnull(p.EspecialidadeID) and p.EspecialidadeID!=0"
  '             response.write(sqlProf)
               set prof = db.execute(sqlProf)
               if not prof.eof then
                    if len(prof("CPF"))>3 then
                        CodigoNaOperadora = prof("CPF")
                    end if
                    set vcaContrato = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado="&ref("ProfissionalID"&ItemID)&" and CodigoNaOperadora not like ''")
                    if not vcaContrato.eof then
                        CodigoNaOperadora = vcaContrato("CodigoNaOperadora")
                    end if
                    if CodigoNaOperadora<>"" then
                        db_execute("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO) values ("&GuiaID&", "&getSequencial(GuiaID)&", "&treatvalnull(prof("GrauPadrao"))&", "&prof("id")&", '"&rep(CodigoNaOperadora)&"', "&treatvalzero(prof("Conselho"))&", '"&rep(prof("DocumentoConselho"))&"', '"&rep(left(prof("UFConselho")&" ", 2))&"', '"&prof("codigoTISS")&"')")
                        %>
        		        atualizaTabela("tissprofissionaissadt", "tissprofissionaissadt.asp?I=<%=GuiaID%>");
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
        end if
		'--------------> fim da gravacao dos repasses
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprocedimentossadt", "tissprocedimentossadt.asp?I=<%=GuiaID%>");
		atualizaTabela("tissoutrasdespesas", "tissoutrasdespesas.asp?I=<%=GuiaID%>");
        tissRecalcGuiaSADT('Recalc');
		<%
	end if
elseif Tipo="Despesas" then
    Qtd = treatvalzero(replace(ref("Quantidade"),".",","))
	if ItemID="0" then
		db_execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", '"&ref("CD")&"', "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("ProdutoID")&"', '"&ref("TabelaProdutoID")&"', '"&ref("CodigoProduto")&"', "&Qtd&", '"&ref("UnidadeMedidaID")&"', "&treatvalzero(ref("Fator"))&", "&treatvalzero(ref("ValorUnitario"))&", "&treatvalzero(ref("ValorTotal"))&", '"&ref("RegistroANVISA")&"', '"&ref("CodigoNoFabricante")&"', '"&ref("AutorizacaoEmpresa")&"', '"&ref("Descricao")&"')")
	else
		db_execute("update tissguiaanexa set GuiaID="&GuiaID&", CD='"&ref("CD")&"', Data="&myDateNULL(ref("Data"))&", HoraInicio="&myTime(ref("HoraInicio"))&", HoraFim="&myTime(ref("HoraFim"))&", ProdutoID='"&ref("ProdutoID")&"', TabelaProdutoID='"&ref("TabelaProdutoID")&"', CodigoProduto='"&ref("CodigoProduto")&"', Quantidade="&Qtd&", UnidadeMedidaID='"&ref("UnidadeMedidaID")&"', Fator="&treatvalzero(ref("Fator"))&", ValorUnitario="&treatvalzero(ref("ValorUnitario"))&", ValorTotal="&treatvalzero(ref("ValorTotal"))&", RegistroANVISA='"&ref("RegistroANVISA")&"', CodigoNoFabricante='"&ref("CodigoNoFabricante")&"', AutorizacaoEmpresa='"&ref("AutorizacaoEmpresa")&"', Descricao='"&ref("Descricao")&"' where id="&ItemID)
	end if
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissoutrasdespesas", "tissoutrasdespesas.asp?I=<%=GuiaID%>");
		<%
end if
%>