<!--#include file="connect.asp"-->
<!--#include file="testaCPF.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<!--#include file="Classes\Json.asp"-->

<%
ItemID = req("II")
GuiaID = req("I")
Tipo = req("T")
QuantidadeFilme = treatvalzero(ref("QuantidadeFilme"))
ValorFilme = treatvalzero(ref("ValorFilmeADD"))
ConvenioID=ref("gConvenioID")

if ConvenioID="" then
    %>
    showMessageDialog("Selecione o convênio", "warning");
    <%
    Response.End
end if


Dim ProcedimentoIncluidos
Set ProcedimentoIncluidos=Server.CreateObject("Scripting.Dictionary")

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
        if ref("GrauParticipacaoID")<>"0" then
         '   db.execute("update profissionais set GrauPadrao="&ref("GrauParticipacaoID")&" where id="&ref("gProfissionalID")&" and (isnull(GrauPadrao) or GrauPadrao=0)")
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


		AlterarEspecialidadeProfissional = True

		if ref("gConvenioID")<>""  then
		    set ConvenioBloquearAlteracoesSQL = db.execute("SELECT BloquearAlteracoes FROM convenios WHERE id="&treatvalzero(ref("gConvenioID")))
		    if not ConvenioBloquearAlteracoesSQL.eof then
		        if ConvenioBloquearAlteracoesSQL("BloquearAlteracoes")=1 then
		            AlterarEspecialidadeProfissional=False
		        end if
		    end if
		end if

        'if AlterarEspecialidadeProfissional then
		'    sqlExecute = "update profissionais set Conselho='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', EspecialidadeID="&EspecialidadeID&sqlCPF&" where id="&ref("gProfissionalID")
        '    db.execute(sqlExecute)
        'end if

		if ItemID="0" then
			sqlExecute = "insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser, Associacao) values ("&GuiaID&", '"&ref("Sequencial")&"', '"&ref("GrauParticipacaoID")&"', '"&ProfissionalID&"', '"&ref("CodigoNaOperadoraOuCPF")&"', '"&ref("ConselhoID")&"', '"&ref("DocumentoConselho")&"', '"&ref("UFConselho")&"', '"&ref("CodigoCBO")&"', '"&session("User")&"',"&Associacao&")"
		    db.execute(sqlExecute)
		else
			sqlExecute = "update tissprofissionaissadt set Sequencial='"&ref("Sequencial")&"', GrauParticipacaoID="& treatvalnull(ref("GrauParticipacaoID")) &", ProfissionalID='"&ProfissionalID&"', CodigoNaOperadoraOuCPF='"&ref("CodigoNaOperadoraOuCPF")&"', ConselhoID='"&ref("ConselhoID")&"', DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', CodigoCBO='"&ref("CodigoCBO")&"', sysUser='"&session("User")&"', Associacao="&Associacao&" where id="&ItemID
            db.execute(sqlExecute)
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
                sqlExecute = "insert into tissprocedimentostabela (Codigo, Descricao, TabelaID, sysActive, sysUser) values ('"&trim(ref("CodigoProcedimento"))&"', '"&trim(ref("Descricao"))&"', '"&ref("TabelaID")&"', 1, "&session("User")&")"
                db.execute(sqlExecute)

                set pt = db.execute(sqlPT)
            else
                sqlExecute = "update tissprocedimentostabela set Descricao='"&ref("Descricao")&"' where id="&pt("id")
                db.execute(sqlExecute)
            end if
        end if



		if ref("gConvenioID")<>"" and ref("gConvenioID")<>"0" then



'original
'			set proc = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&ref("ProcedimentoID")&" and ConvenioID="&ref("ConvenioID"))
'			if proc.eof then
'				db.execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, TabelaID, CodigoProcedimento, Valor, TecnicaID) values ('"&ref("ProcedimentoID")&"', '"&ref("ConvenioID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&treatval(ref("ValorUnitario"))&"', '"&ref("TecnicaID")&"')")
'			else
'				db.execute("update tissprocedimentosvalores set TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Valor='"&treatval(ref("ValorUnitario"))&"', TecnicaID='"&ref("TecnicaID")&"' where id="&proc("id"))
'			end if


'/original
			sqlPV = "select * from tissprocedimentosvalores where ProcedimentoID="&ref("gProcedimentoID")&" and ConvenioID="&ref("gConvenioID")
			set pv = db.execute(sqlPV)
			if pv.eof then
			    if session("Banco")<>"clinic3882" and 1=2 then
				    sqlExecute = "insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, TecnicaID, NaoCobre) values ('"&ref("gProcedimentoID")&"', '"&ref("gConvenioID")&"', "&pt("id")&", "&treatvalzero(ref("ValorUnitario"))&", 1, '')"
                    db.execute(sqlExecute)
                end if
                ' set pv = db.execute(sqlPV)
			else


                if session("Banco")<>"clinic3882" and 1=2 then
                    if ref("PlanoID")="0" then
                        sqlExecute = "update tissprocedimentosvalores set ProcedimentoTabelaID="&pt("id")&", Valor="&treatvalzero(ref("ValorUnitario"))&" where id="&pv("id")
                        db.execute(sqlExecute)
                    end if
                end if
			end if
			if session("Banco")<>"clinic3882" and 1=2 then
                if ref("PlanoID")<>"0" then
                    set pvp = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&pv("id")&" and PlanoID="&ref("PlanoID"))
                    if pvp.eof then
                        sqlExecute = "insert into tissprocedimentosvaloresplanos (AssociacaoID, PlanoID, Valor, NaoCobre) values ("&pv("id")&", "&ref("PlanoID")&", "&treatvalzero(ref("ValorUnitario"))&", '')"
                        db.execute(sqlExecute)
                    else
                        sqlExecute = "update tissprocedimentosvaloresplanos set Valor="&treatvalzero(ref("ValorUnitario"))&" where id="&pvp("id")
                        db.execute(sqlExecute)
                    end if
                end if
            end if
		end if

        rfAssociacao = 5
        rfProfissionalID = ref("ProfissionalID"&ItemID)
        if instr(rfProfissionalID, "_")>0 then
            splProf = split(rfProfissionalID, "_")
            rfAssociacao = splProf(0)
            rfProfissionalID = splProf(1)
        end if

        AssociacaoID=rfAssociacao

        set ConvenioConfigSQL = db.execute("SELECT AdicionarProfissionalExecutanteVinculadoAoProcedimento FROM convenios WHERE id="&treatvalzero(ref("gConvenioID")))
        if not ConvenioConfigSQL.eof then
            AdicionarProfissionalExecutanteVinculadoAoProcedimento=ConvenioConfigSQL("AdicionarProfissionalExecutanteVinculadoAoProcedimento")
        end if

		if ItemID="0" then
            sqlExecute = "insert into tissprocedimentossadt (CalcularEscalonamento,GuiaID, ProfissionalID, Data, HoraInicio, HoraFim, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, Associacao,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral,CalculoConvenioID,CalculoPlanoID,CalculoContratos)"&_
                         "values (COALESCE(NULLIF('"&treatval(ref("CalcularEscalonamento"))&"',''),1),"&GuiaID&", "& treatvalzero(rfProfissionalID) &", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("gProcedimentoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&ref("Descricao")&"', '"&ref("Quantidade")&"', '"&ref("ViaID")&"', '"&ref("TecnicaID")&"', "&treatvalzero(ref("Fator"))&", "&treatvalzero(ref("ValorUnitario"))&", "&treatvalzero(ref("ValorTotal"))&", '"&session("User")&"', "& treatvalnull(rfAssociacao)&", "&treatvalzero(ref("TotalCH"))&", "&treatvalzero(ref("TotalValorFixo"))&", "&treatvalzero(ref("TotalUCO"))&", "&treatvalzero(ref("TotalPORTE"))&", "&treatvalzero(ref("TotalFILME"))&", "&treatvalzero(ref("xTotalGeral"))&", "&ref("gConvenioID")&", "&treatvalzero(ref("PlanoID"))&",NULLIF('"&ref("ContratadoSolicitanteCodigoNaOperadora")&"',''))"
            db.execute(sqlExecute)

			set pult = db.execute("select id from tissprocedimentossadt where GuiaID="&GuiaID&" and sysUser="&session("User")&" order by id desc LIMIT 1")
			EsteItem = pult("id")
            ProcedimentoID = ref("gProcedimentoID")
            if AdicionarProfissionalExecutanteVinculadoAoProcedimento=1 then
                'adiciona os profissionais executantes
                sqlProfissional = "(SELECT prof.id ProfissionalID, IFNULL(ps.CodigoNaOperadoraOuCPF,prof.CPF)CPF, IF(( ps.GrauParticipacaoID IS NULL or ps.GrauParticipacaoID = 0), prof.GrauPadrao, ps.GrauParticipacaoID) GrauParticipacaoID, IFNULL(ps.DocumentoConselho, "&_
                                  "prof.DocumentoConselho)DocumentoConselho, IFNULL(ps.UFConselho, prof.UFConselho)UFConselho, IFNULL(ps.CodigoCBO, esp.codigo)CBOS,IFNULL(ps.ConselhoID, prof.Conselho )ConselhoID  "&_
                                  "FROM  profissionais prof  "&_
                                  "LEFT JOIN tissprofissionaissadt ps ON ps.ProfissionalID=prof.id "&_
                                  "LEFT JOIN tissguiasadt tg ON tg.id = ps.GuiaID "&_
                                  "LEFT JOIN especialidades esp ON esp.id=prof.EspecialidadeID "&_
                                  "WHERE prof.id="&rfProfissionalID&" "&_
                                  "AND (tg.ConvenioID="&ref("gConvenioID")&" or tg.ConvenioID is null) "&_
                                  "ORDER BY ps.sysDate DESC "&_
                                  "LIMIT 1)"&_
                                  " UNION ALL"&_
                                  " (SELECT p.id, p.CPF, COALESCE(a.Funcao, 0) GrauParticipacaoID, p.DocumentoConselho, p.UFConselho, p.CBOS, p.Conselho ConselhoID FROM procedimentosequipeconvenio a"&_
                                  " inner JOIN profissionais p ON p.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '5'"&_
                                  " WHERE a.ProcedimentoID = "&ProcedimentoID&_
                                  ") UNION ALL"&_
                                  " (SELECT proext.id, proext.cpf, COALESCE(a.Funcao, 0), proext.DocumentoConselho, proext.UFConselho, proext.CBOS, proext.Conselho FROM procedimentosequipeconvenio a "&_
                                  " inner JOIN profissionalexterno proext ON proext.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '8'"&_
                                  " WHERE a.ProcedimentoID = "&ProcedimentoID&")"

                set DadosDoProfissionalParaAdicionarSQL = db.execute(sqlProfissional)

                while not DadosDoProfissionalParaAdicionarSQL.eof
                    set SequencialSQL = db.execute("SELECT Sequencial From tissprofissionaissadt WHERE GuiaID="&GuiaID&" order by Sequencial desc")

                    Sequencial=1

                    if not SequencialSQL.eof then
                        Sequencial = SequencialSQL("Sequencial") + 1
                    end if

                    sqlInsert = "INSERT INTO tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser,Associacao)" &_
                                                    "VALUES ("&GuiaID&", "&treatvalzero(Sequencial)&", "&DadosDoProfissionalParaAdicionarSQL("GrauParticipacaoID")&", "&DadosDoProfissionalParaAdicionarSQL("ProfissionalID")&", '"&DadosDoProfissionalParaAdicionarSQL("CPF")&"', "&_
                                                    treatvalzero(DadosDoProfissionalParaAdicionarSQL("ConselhoID"))&", '"&DadosDoProfissionalParaAdicionarSQL("DocumentoConselho")&"', '"&DadosDoProfissionalParaAdicionarSQL("UFConselho")&"', "&treatvalzero(DadosDoProfissionalParaAdicionarSQL("CBOS"))&", "&session("User")&","&Associacao&")"


                    db.execute(sqlInsert )

                DadosDoProfissionalParaAdicionarSQL.movenext
                wend
                DadosDoProfissionalParaAdicionarSQL.close
                set DadosDoProfissionalParaAdicionarSQL=nothing
                RecarregaProfissional=True


            end if

            ObsLog = "Procedimento adicionado pelo usuário"
		else
			sqlExecute = "update tissprocedimentossadt set CalcularEscalonamento="&treatval(ref("CalcularEscalonamento"))&", ProfissionalID="& treatvalzero(rfProfissionalID) &", Data="&myDatenull(ref("Data"))&", HoraInicio="&myTime(ref("HoraInicio"))&", HoraFim="&myTime(ref("HoraFim"))&", ProcedimentoID='"&ref("gProcedimentoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', Descricao='"&ref("Descricao")&"', Quantidade='"&ref("Quantidade")&"', ViaID='"&ref("ViaID")&"', TecnicaID='"&ref("TecnicaID")&"', Fator='"&treatval(ref("Fator"))&"', ValorUnitario='"&treatval(ref("ValorUnitario"))&"', ValorTotal='"&treatval(ref("ValorTotal"))&"', sysUser='"&session("User")&"', Associacao="& treatvalnull(rfAssociacao) &",TotalCH = "&treatvalzero(ref("TotalCH"))&",TotalValorFixo = "&treatvalzero(ref("TotalValorFixo"))&",TotalUCO="&treatvalzero(ref("TotalUCO"))&",TotalPORTE="&treatvalzero(ref("TotalPORTE"))&",TotalFILME="&treatvalzero(ref("TotalFILME"))&",TotalGeral="&treatvalzero(ref("xTotalGeral"))&",CalculoConvenioID="&ref("gConvenioID")&",CalculoPlanoID="&ref("PlanoID")&",CalculoContratos=NULLIF('"&ref("ContratadoSolicitanteCodigoNaOperadora")&"','') where id="&ItemID
            db.execute(sqlExecute)

			EsteItem = ItemID

			ObsLog = "Procedimento alterado pelo usuário"
		end if

		sqlExecute = "insert into tissprocedimentossadt_log (GuiaID, ProfissionalID, Data, HoraInicio, HoraFim, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, Associacao, Obs)"&_
		             " values ("&GuiaID&", "& treatvalzero(rfProfissionalID) &", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("gProcedimentoID")&"', '"&ref("TabelaID")&"', '"&ref("CodigoProcedimento")&"', '"&ref("Descricao")&"', '"&ref("Quantidade")&"', '"&ref("ViaID")&"', '"&ref("TecnicaID")&"', "&treatvalzero(ref("Fator"))&", "&treatvalzero(ref("ValorUnitario"))&", "&treatvalzero(ref("ValorTotal"))&", '"&session("User")&"', "& treatvalnull(rfAssociacao) &", '"&ObsLog&"')"
        db.execute(sqlExecute)

        if ItemID="0" and not pv.eof then
            've se tem procedimento anexo
            set QuantidadeProcedimentos = db.execute("SELECT count(*) as Quantidade FROM tissprocedimentossadt WHERE GuiaID="&ref("GuiaID"))
            QuantidadeProcedimento = QuantidadeProcedimentos("Quantidade")

            IF getConfig("calculostabelas") THEN
                set ValorCalculo = CalculaValorProcedimentoConvenio(null,ref("gConvenioID"),pv("ProcedimentoID"),ref("PlanoID"),ref("ContratadoSolicitanteCodigoNaOperadora"),QuantidadeProcedimento,null,null)
                AssociacaoIDNovo = ValorCalculo("AssociacaoID")
            END IF

            set ProcedimentosAnexosSQL = db.execute("SELECT * FROM tissprocedimentosanexos WHERE coalesce(tissprocedimentosanexos.Planos like CONCAT('%|',NULLIF('"&ref("PlanoID")&"',''),'|%'),true) AND COALESCE(AssociacaoID=(NULLIF('"&AssociacaoIDNovo&"','')),ConvenioID="&treatvalzero(ref("gConvenioID"))&" AND ProcedimentoPrincipalID="&pv("ProcedimentoID")&")")

            if not ProcedimentosAnexosSQL.eof then

                Fator = calculaFator(ref("GuiaID"))

                while not ProcedimentosAnexosSQL.eof
                    DataAtendimento=mydate(ref("Data"))
                    ProfissionalID = rfProfissionalID

                    FatorReal = Fator
                    set TipoProcedimentoSQL = db.execute("SELECT TipoProcedimentoID FROM procedimentos WHERE id="&ProcedimentosAnexosSQL("ProcedimentoAnexoID"))
                    if TipoProcedimentoSQL("TipoProcedimentoID")=3 then
                        FatorReal = 1
                    end if

                    ValorAnexo = ProcedimentosAnexosSQL("Valor")
                    ValorTotalAnexo = treatvalzero(1 * FatorReal * ValorAnexo)
                    TotalCH         = 0
                    TotalValorFixo  = 0
                    TotalUCO        = 0
                    TotalPORTE      = 0
                    TotalFILME      = 0
                    TotalGeral      = 0

                    CodigoProcedimento = ProcedimentosAnexosSQL("Codigo")

                    IF getConfig("calculostabelas") THEN
                        set ValorCalculoAnexo = CalculaValorProcedimentoConvenio(null,null,null,null,null,null,ProcedimentosAnexosSQL("id"),null)
                        %>console.log(<%=fieldToJSON(ValorCalculoAnexo)%>); <%
                        ValorAnexo         = treatvalzero(ValorCalculoAnexo("TotalGeral"))
                        ValorTotalAnexo    = treatvalzero(ValorCalculoAnexo("TotalGeral"))
                        TotalCH            = treatvalzero(ValorCalculoAnexo("TotalCH"))
                        TotalValorFixo     = treatvalzero(ValorCalculoAnexo("TotalValorFixo"))
                        TotalUCO           = treatvalzero(ValorCalculoAnexo("TotalUCO"))
                        TotalPORTE         = treatvalzero(ValorCalculoAnexo("TotalPORTE"))
                        TotalFILME         = treatvalzero(ValorCalculoAnexo("TotalFILME"))
                        TotalGeral         = treatvalzero(ValorCalculoAnexo("TotalGeral"))
                        CodigoProcedimento = ValorCalculoAnexo("CodigoProcedimento")
                    END IF

                    sqlIns = "insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, Anexo, sysUser, Associacao,TotalCH,TotalValorFixo,TotalUCO,TotalPORTE,TotalFILME,TotalGeral,CalculoConvenioID,CalculoPlanoID,CalculoContratos)"&_
                            " values ("&ref("GuiaID")&", "& treatvalzero(ProfissionalID) &", "&mydatenull(DataAtendimento)&", "&treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID"))&", 22, '"&rep(CodigoProcedimento)&"', '"&rep(ProcedimentosAnexosSQL("Descricao"))&"', 1, 1, "&treatvalzero(1)&", "&treatvalzero(FatorReal)&","&(ValorTotalAnexo)&", "&(ValorTotalAnexo)&", 1, "&session("User")&", "& treatvalnull(rfAssociacao)&","& TotalCH &", "& TotalValorFixo &", "& TotalUCO &", "& TotalPORTE &", "& TotalFILME &", "& TotalGeral &",NULLIF('"&ref("gConvenioID")&"',''),NULLIF('"&ref("PlanoID")&"',''),NULLIF('"&ref("ContratadoSolicitanteCodigoNaOperadora")&"',''));"

                    db.execute( sqlIns )

                ProcedimentosAnexosSQL.movenext
                wend
                ProcedimentosAnexosSQL.close
                set ProcedimentosAnexosSQL=nothing
            end if
        end if

        AdicionaMaterial = True
        if ref("gConvenioID")<>"" and EsteItem&""<>"" then
            set conv = db.execute("select c.MesclagemMateriais, (select count(id) from tissguiaanexa where GuiaID="&GuiaID&") NMateriais from convenios c where c.id="&ref("gConvenioID"))
            if not conv.eof then
                if ( conv("MesclagemMateriais")="Maior" and ccur(conv("NMateriais"))=0 ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
                    AdicionaMaterial=True
                else
                    AdicionaMaterial=False
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
				    ' db.execute("insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", '"&vDesp("CD")&"', "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(vDesp("ProdutoID"))&", "&treatvalzero(vDesp("TabelaID"))&", '"&vDesp("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(vDesp("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotal)&", '"&vDesp("RegistroANVISA")&"', '"&vDesp("CodigoNoFabricante")&"', '"&vDesp("AutorizacaoEmpresa")&"', '"&rep(vDesp("NomeProduto"))&"')")
			    end if
		    vDesp.movenext
		    wend
		    vDesp.close
		    set vDesp=nothing
       end if
       ' aqui entra nova forma de valores de itens
       ProcedimentoID = ref("gProcedimentoID")
       ConvenioID = ref("gConvenioID")

       if ConvenioID<>"" and ItemID="0" and AdicionaMaterial then
           set ProdutoValorSQL = db.execute("SELECT p.*, tpp.Quantidade,IF (tpt.Valor = 0, tpv.Valor,tpt.Valor)Valor,tpt.TabelaID,tpt.Codigo,tpt.ProdutoID,p.Codigo as CodigoNoFabricante FROM tissprocedimentosvalores pv LEFT JOIN tissprodutosprocedimentos tpp ON tpp.AssociacaoID=pv.id LEFT JOIN tissprodutostabela tpt ON tpt.id=tpp.ProdutoTabelaID LEFT JOIN tissprodutosvalores tpv ON tpv.ProdutoTabelaID=tpt.id AND tpv.ConvenioID=pv.ConvenioID LEFT JOIN produtos p ON p.id = tpt.ProdutoID WHERE pv.ProcedimentoID= "&ProcedimentoID&" AND pv.ConvenioID="&  ConvenioID)

           if not ProdutoValorSQL.eof then
                while not ProdutoValorSQL.eof
                    Valor = ProdutoValorSQL("Valor")
                    Quantidade = ProdutoValorSQL("Quantidade") * ref("Quantidade")
                    ValorTotalProduto = Quantidade *  Valor

                    if Valor > 0 then
                        sqlExecute = "insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", "&treatvalzero(ProdutoValorSQL("CD"))&", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(ProdutoValorSQL("ProdutoID"))&", "&treatvalzero(ProdutoValorSQL("TabelaID"))&", '"&ProdutoValorSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutoValorSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutoValorSQL("RegistroANVISA")&"', '"&ProdutoValorSQL("CodigoNoFabricante")&"', '"&ProdutoValorSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutoValorSQL("NomeProduto"))&"')"
                        db.execute(sqlExecute)
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
                            sqlExecute = "insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", "&treatvalzero(ProdutosKitSQL("CD"))&", "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", "&treatvalzero(ProdutosKitSQL("ProdutoID"))&", "&treatvalzero(ProdutosKitSQL("TabelaID"))&", '"&ProdutosKitSQL("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(ProdutosKitSQL("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotalProduto)&", '"&ProdutosKitSQL("RegistroANVISA")&"', '"&ProdutosKitSQL("CodigoNoFabricante")&"', '"&ProdutosKitSQL("AutorizacaoEmpresa")&"', '"&rep(ProdutosKitSQL("NomeProduto"))&"')"
                            db.execute(sqlExecute)
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

        '-- Adicionando data seriada
        set getProcedimentoSeriado = db.execute("SELECT IntervaloSerie FROM procedimentos WHERE ProcedimentoSeriado='S' AND id="&ProcedimentoID)
        if not getProcedimentoSeriado.eof then
            IntervaloSerie = getProcedimentoSeriado("IntervaloSerie")
            Quantidade = ref("Quantidade")
            DataAtual = ref("Data")
            DataSerie = ""
            if IntervaloSerie&""<>"" AND IntervaloSerie<>0 AND isnumeric(IntervaloSerie) then
                '-- Passa apagando todos os registros.
                for i=1 to 10
                    Serie = i
                    if len(i)=1 then
                        Serie = "0"&i
                    end if
                    %>
                        $("#DataSerie<%=Serie%>").val("");
                    <%
                    if i <= ccur(Quantidade) then
                        DataSerie = DataAtual
                        if i <> 1 then
                            DataSerie = DateAdd("d", IntervaloSerie , UltimaData)
                            if weekday(DataSerie)=1 then
                                DataSerie = DateAdd("d", (IntervaloSerie + 1) , UltimaData)
                            end if
                        end if
                        UltimaData = DataSerie
                        %>
                            $("#DataSerie<%=Serie%>").val('<%=formatdatetime(DataSerie, 2)%>');
                        <%
                    end if
                next
            end if
        end if
        '-> inserindo o profissional executor nesta guia se ele nao existe

        if rfProfissionalID&""<>"0" then
            sqlProfissional = "select id from tissprofissionaissadt where ProfissionalID="& treatvalzero(rfProfissionalID) &" and Associacao="&AssociacaoID&" and GuiaID="&GuiaID
            set vca = db.execute(sqlProfissional)

            if vca.eof then
                if Associacao = 8 then
					sqlProf = "select p.*, e.codigoTISS, '' as GrauPadrao from profissionalexterno p left join especialidades e on e.id=p.EspecialidadeID where p.id="&ProfissionalID&" and not isnull(p.Conselho) and p.Conselho<>'' and p.DocumentoConselho not like '' and p.UFConselho not like '' and not isnull(p.EspecialidadeID) and p.EspecialidadeID!=0"
				else
					sqlProf = "select p.*, e.codigoTISS from profissionais p left join especialidades e on e.id=p.EspecialidadeID where p.id="&rfProfissionalID&" and not isnull(p.GrauPadrao) and p.GrauPadrao!=0 and not isnull(p.Conselho) and p.Conselho<>'' and p.DocumentoConselho not like '' and p.UFConselho not like '' and not isnull(p.EspecialidadeID) and p.EspecialidadeID!=0"
			    end if

               set prof = db.execute(sqlProf)
               if not prof.eof then
                    if len(prof("CPF"))>3 then
                        CodigoNaOperadora = prof("CPF")
                    end if
                    set vcaContrato = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado="& treatvalzero(rfProfissionalID) &" and CodigoNaOperadora != ''")
                    if not vcaContrato.eof then
                        CodigoNaOperadora = vcaContrato("CodigoNaOperadora")
                    end if

                    if CodigoNaOperadora<>"" then
                        sqlExecute = "insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, Associacao) values ("&GuiaID&", "&getSequencial(GuiaID)&", "&treatvalnull(prof("GrauPadrao"))&", "&prof("id")&", '"&rep(CodigoNaOperadora)&"', "&treatvalzero(prof("Conselho"))&", '"&rep(prof("DocumentoConselho"))&"', '"&rep(left(prof("UFConselho")&" ", 2))&"', '"&prof("codigoTISS")&"',"&AssociacaoID&")"
                        db.execute(sqlExecute)

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
                            sqlExecute = "insert into rateiorateios (ItemGuiaID, Funcao, TipoValor, Sobre, Valor, ContaCredito, sysDate, FM, ProdutoID, ValorUnitario, Quantidade, sysUser) values ("&EsteItem&", '"&ref("Funcao"&n&"-"&nRep)&"', '"&ref("TipoValor"&n&"-"&nRep)&"', '"&ref("Sobre"&n&"-"&nRep)&"', "&treatvalzero(ref("Valor"&n&"-"&nRep))&", '"&ref("ContaCredito"&n&"-"&nRep)&"', '"&mydate(date())&"', '"&ref("FM"&n&"-"&nRep)&"', "&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", "&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", "&treatvalzero(ref("Quantidade"&n&"-"&nRep))&", "&session("User")&")"
                            db.execute(sqlExecute)
                        else
                            sqlExecute = "update rateiorateios set Funcao='"&ref("Funcao"&n&"-"&nRep)&"', TipoValor='"&ref("TipoValor"&n&"-"&nRep)&"', Sobre='"&ref("Sobre"&n&"-"&nRep)&"', Valor="&treatvalzero(ref("Valor"&n&"-"&nRep))&", ContaCredito='"&ref("ContaCredito"&n&"-"&nRep)&"', sysDate='"&mydate(date())&"', ProdutoID="&treatvalzero(ref("ProdutoID"&n&"-"&nRep))&", ValorUnitario="&treatvalzero(ref("ValorUnitario"&n&"-"&nRep))&", Quantidade="&treatvalzero(ref("Quantidade"&n&"-"&nRep))&" where id="&nRep
                            db.execute(sqlExecute)
                        end if
                        sobraRep = replace(sobraRep, "|"&nRep&"|", "")
                    end if
                next
            'end if

            splSobraRep = split(sobraRep, "|")
            for h=0 to ubound(splSobraRep)
                if splSobraRep(h)<>"" and isnumeric(splSobraRep(h)) then
                    sqlExecute = "delete from rateiorateios where id="&splSobraRep(h)
                    db.execute(sqlExecute)
                end if
            next
        end if
		'--------------> fim da gravacao dos repasses
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissprocedimentossadt", "tissprocedimentossadt.asp?I=<%=GuiaID%>");
		<%
		if RecarregaProfissional then
		%>
		atualizaTabela("tissprofissionaissadt", "tissprofissionaissadt.asp?I=<%=GuiaID%>");
		<%
		end if
		%>
		atualizaTabela("tissoutrasdespesas", "tissoutrasdespesas.asp?I=<%=GuiaID%>");
        tissRecalcGuiaSADT('Recalc');
		<%
	end if
elseif Tipo="Despesas" then
    Qtd = treatvalzero(replace(ref("Quantidade"),".",","))
	if ItemID="0" then
		sqlExecute = "insert into tissguiaanexa (GuiaID, CD, Data, HoraInicio, HoraFim, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&GuiaID&", '"&ref("CD")&"', "&myDateNULL(ref("Data"))&", "&myTime(ref("HoraInicio"))&", "&myTime(ref("HoraFim"))&", '"&ref("ProdutoID")&"', '"&ref("TabelaProdutoID")&"', '"&ref("CodigoProduto")&"', "&Qtd&", '"&ref("UnidadeMedidaID")&"', "&treatvalzero(ref("Fator"))&", "&treatvalzero(ref("ValorUnitario"))&", "&treatvalzero(ref("ValorTotal"))&", '"&ref("RegistroANVISA")&"', '"&ref("CodigoNoFabricante")&"', '"&ref("AutorizacaoEmpresa")&"', '"&ref("Descricao")&"')"
	    db.execute(sqlExecute)
	else
		sqlExecute = "update tissguiaanexa set GuiaID="&GuiaID&", CD='"&ref("CD")&"', Data="&myDateNULL(ref("Data"))&", HoraInicio="&myTime(ref("HoraInicio"))&", HoraFim="&myTime(ref("HoraFim"))&", ProdutoID='"&ref("ProdutoID")&"', TabelaProdutoID='"&ref("TabelaProdutoID")&"', CodigoProduto='"&ref("CodigoProduto")&"', Quantidade="&Qtd&", UnidadeMedidaID='"&ref("UnidadeMedidaID")&"', Fator="&treatvalzero(ref("Fator"))&", ValorUnitario="&treatvalzero(ref("ValorUnitario"))&", ValorTotal="&treatvalzero(ref("ValorTotal"))&", RegistroANVISA='"&ref("RegistroANVISA")&"', CodigoNoFabricante='"&ref("CodigoNoFabricante")&"', AutorizacaoEmpresa='"&ref("AutorizacaoEmpresa")&"', Descricao='"&ref("Descricao")&"' where id="&ItemID
    	db.execute(sqlExecute)
	end if
		%>
		$("#modal-table").modal("hide");
		atualizaTabela("tissoutrasdespesas", "tissoutrasdespesas.asp?I=<%=GuiaID%>");
		<%
end if
%>