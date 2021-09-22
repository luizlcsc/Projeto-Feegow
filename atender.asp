<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="tissFuncs.asp"-->
<!--#include file="Classes/ValorProcedimento.asp"-->
<%

AgendamentoID = req("Atender")
PacienteID = ccur(req("I"))
Acao = req("Acao")

if AgendamentoID="" or not isnumeric(AgendamentoID) then
	AgendamentoID = 0
	set getAgendamentoID = db.execute("SELECT id FROM agendamentos WHERE Data= '"&mydate(date())&"' AND PacienteID="&PacienteID&" AND ProfissionalID="&treatvalzero(session("idInTable"))&" AND sysActive = 1  LIMIT 1 ")
	if not getAgendamentoID.eof then
	    AgendamentoID = getAgendamentoID("id")
	end if
else
	AgendamentoID = ccur(AgendamentoID)
end if

function incluirGuiaSADT(atendimentoid, agendamentoid)
    
    ' verifica se já existem guias incluidas para este atendimento ou agendamento 
    sql = "SELECT * FROM tissguiasadt WHERE atendimentoid='"&atendimentoid&"' OR agendamentoid  = '"&agendamentoid&"' "
    set rs_guia = db.execute(sql)
    ' caso não exista criar conforme os dados do atendimento e as confirgurações padrão do atendimento / agendamento
    if rs_guia.eof then
        'response.write("<script> console.log('incluindo guia para atendimento: "& atendimentoid&" agendamento: "&agendamentoid&"'); </script>")
        db_execute("insert into tissguiasadt (sysUser, sysActive,atendimentoid,agendamentoid) values ("&session("User")&", 0,'"&atendimentoid&"','"&agendamentoid&"')")
        sqlVie = "select id, sysUser, sysActive from tissguiasadt where sysUser="&session("User")&" and sysActive=0 ORDER BY id DESC"
		set reg = db.execute(sqlVie)
        set aEa = db.execute("select ag.id, ag.Data, ag.Hora as HoraInicio, ag.HoraFinal as HoraFim, ag.TipoCompromissoID as ProcedimentoID, ag.ProfissionalID, ag.Notas as Obs, ag.ValorPlano, ag.rdValorPlano, ag.PacienteID, ag.StaID as Icone, 'agendamento' as Tipo, ag.id as AgendamentoID, ag.EspecialidadeID, ag.PlanoID from agendamentos as ag where ag.id = '"&agendamentoid&"' order by ag.Data desc, ag.Hora desc, ag.HoraFinal desc")
        if not aEa.eof then
            PlanoID =  aEa("PlanoID")
            DataAtendimento = aEa("Data")
            PacienteID = aEa("PacienteID")
            ProcedimentoID = aEa("ProcedimentoID")
            ProfissionalID = aEa("ProfissionalID")
            HoraInicio = aEa("HoraInicio")
            HoraFim = aEa("HoraFim")
            EspecialidadeID = aEa("EspecialidadeID")
            if aEa("Tipo")="executado" then
                AtendimentoID = aEa("id")
                ObsIndicacaoClinica = aEa("Obs")
                if IndicacaoClinica="" or isnull(IndicacaoClinica) then
                    IndicacaoClinica = ObsIndicacaoClinica
                else
                    IndicacaoClinica = IndicacaoClinica & ", " & ObsIndicacaoClinica
                end if
            else
                AtendimentoID = 0
            end if
            AgendamentoID = aEa("AgendamentoID")
            if aEa("rdValorPlano")="P" then
                trocaConvenioID = aEa("ValorPlano")
                ConvenioID = aEa("ValorPlano")
            else
                set vpac = db.execute("select * from pacientes where id="&PacienteID)
                if not vpac.eof and not isnull(ConvenioID) and isnumeric(ConvenioID) then
                    if not isnull(vpac("ConvenioID1")) AND vpac("ConvenioID1")=ccur(ConvenioID) then
                        Numero = 1
                    elseif not isnull(vpac("ConvenioID2")) AND vpac("ConvenioID2")=ccur(ConvenioID) then
                        Numero = 2
                    elseif not isnull(vpac("ConvenioID3")) AND vpac("ConvenioID3")=ccur(ConvenioID) then
                        Numero = 3
                    else
                        Numero = ""
                    end if
                    if Numero<>"" then
                        trocaConvenioID = vpac("ConvenioID"&Numero)
                        ConvenioID = vpac("ConvenioID"&Numero)
                        Matricula = vpac("Matricula"&Numero)
                        Validade = vpac("Validade"&Numero)
                    end if
                end if
            end if
            if not isnull(ConvenioID) and isnumeric(ConvenioID) and ConvenioID<>"" then
                set conv = db.execute("select c.* from convenios c where c.id="&ConvenioID)
                if not conv.eof then
                    RegistroANS = conv("RegistroANS")
                    RepetirNumeroOperadora = conv("RepetirNumeroOperadora")
                    TipoAtendimentoID = conv("TipoAtendimentoID")
                    IndicacaoAcidenteID = conv("IndicacaoAcidenteID")
                    set contratoExecutante = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and (ExecutanteOuSolicitante like '%|E|%' or  ExecutanteOuSolicitante='') and not isnull(Contratado)")
                    if not contratoExecutante.eof then
                        Contratado = contratoExecutante("Contratado")
                        CodigoNaOperadora = contratoExecutante("CodigoNaOperadora") 
                    end if

                    set contratoSolicitante = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and (ExecutanteOuSolicitante like '%|S|%' or  ExecutanteOuSolicitante='') and not isnull(Contratado)")
                    if not contratoSolicitante.eof then
                        ContratadoSolicitanteID = contratoSolicitante("Contratado")
                        ContratadoSolicitanteCodigoNaOperadora = contratoSolicitante("CodigoNaOperadora") ' conv("NumeroContrato")
                    end if
                    if not isnull(Contratado) and Contratado<>"" then
                        if Contratado=0 then
                            set contr = db.execute("select id,CNES from empresa")
                            if not contr.eof then
                                CodigoCNES = contr("CNES")
                            end if
                        elseif Contratado<0 then
                            set contr = db.execute("select id,CNES from sys_financialcompanyunits where id="&(Contratado*(-1)))
                            if not contr.eof then
                                CodigoCNES = contr("CNES")
                            end if
                        else
                            CodigoCNES = "9999999"
                        end if
                    end if
                end if
                set vpac = db.execute("select * from pacientes where id="&PacienteID)
                if not vpac.eof and not isnull(ConvenioID) and isnumeric(ConvenioID) then
                    if not isnull(vpac("ConvenioID1")) AND vpac("ConvenioID1")=ccur(ConvenioID) then
                        Numero = 1
                    elseif not isnull(vpac("ConvenioID2")) AND vpac("ConvenioID2")=ccur(ConvenioID) then
                        Numero = 2
                    elseif not isnull(vpac("ConvenioID3")) AND vpac("ConvenioID3")=ccur(ConvenioID) then
                        Numero = 3
                    else
                        Numero = ""
                    end if
                    if Numero<>"" then
                        ConvenioID = vpac("ConvenioID"&Numero)
                        NumeroCarteira = vpac("Matricula"&Numero)
                        ValidadeCarteira = vpac("Validade"&Numero)
                        IF PlanoID&"" = "" or PlanoID = "0" THEN
                            PlanoID = vpac("PlanoID"&Numero)
                        END IF
                    end if
                end if


                if getConfig("HorarioAtendimentoGuia")=1 then
                    if HoraInicio=HoraFim then
                        HoraInicio = "NULL"
                        HoraFim = "NULL"
                    end if
                end if
                've se há valor definido pra este procedimento neste convênio
                'AgendamentoID=agendamentoid
                sqlExecute = "update tissguiasadt set agendamentoid='"&AgendamentoID&"' where id="&reg("id")
                db_execute(sqlExecute)

                set ProcedimentosSQL = db.execute("select TipoCompromissoID FROM (SELECT a.TipoCompromissoID from agendamentos a where a.id = '"&AgendamentoID&"' UNION ALL select ap.TipoCompromissoID from agendamentosprocedimentos ap where ap.agendamentoid = '"&AgendamentoID&"')t WHERE true "&sqlProcedimentosJaFaturados)


                Dim ProcedimentoIncluidos
                Set ProcedimentoIncluidos=Server.CreateObject("Scripting.Dictionary")

                while not ProcedimentosSQL.eof
                    ProcedimentoID=ProcedimentosSQL("TipoCompromissoID")

                    sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC "

                    set ContratosConvenio = db.execute(sqlCodigoNaOperador)

                    IF NOT ContratosConvenio.eof THEN
                        CodigoNaOperadoraNew = ContratosConvenio("CodigoNaOperadora")
                        Contratado = ContratosConvenio("Contratado")
                        CodigoNaOperadora = CodigoNaOperadoraNew
                    END IF

                    set tpv = db.execute("select pv.id, pv.Valor, pv.TecnicaID, pv.ProcedimentoID, pt.TabelaID, pt.Codigo, pt.Descricao from tissprocedimentosvalores as pv left join tissprocedimentostabela as pt on pv.ProcedimentoTabelaID=pt.id where pv.ProcedimentoID="&ProcedimentoID&" and pv.ConvenioID="&ConvenioID)
                    if not tpv.eof then
                        TabelaID = tpv("TabelaID")
                        ValorProcedimento = tpv("Valor")
                        CodigoProcedimento = tpv("Codigo")
                        TecnicaID = tpv("TecnicaID")
                        if tpv("Descricao")<>"" and not isnull(tpv("Descricao")) then
                            Descricao = tpv("Descricao")
                        end if
                        'ver se há específico para este plano

                        IF getConfig("calculostabelas") THEN
                            IF AgendamentoID > "0" THEN
                                set agPlano = db.execute("SELECT * FROM agendamentos WHERE id ="&AgendamentoID)
                                IF not agPlano.EOF then
                                    PPlanoID= agPlano("PlanoID")
                                    IF PPlanoID > "0" THEN
                                        PlanoID = agPlano("PlanoID")
                                    END IF
                                end if
                            END IF
                            set CalculaValorProcedimentoConvenioPaiObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,null,1)
                            ValorProcedimento = CalculaValorProcedimentoConvenioPaiObj("TotalGeral")
                            AssociacaoID = CalculaValorProcedimentoConvenioPaiObj("AssociacaoID")
                        END IF
                        set pvp = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&tpv("id")&" and PlanoID like '"&PlanoID&"'")
                        if not pvp.eof then
                            'se houver, mas como "não cobre", dispara um alert
                            if pvp("NaoCobre")="S" and not isnull(pvp("NaoCobre")) then
                                %>
                                <script language="javascript">
                                    alert('O plano informado não cobre este procedimento.');
                                </script>
                                <%
                            else
                                if pvp("Valor")> 0 then
                                    ValorProcedimento = pvp("Valor")
                                end if

                                IF getConfig("calculostabelas") THEN
                                    set CalculaValorProcedimentoConvenioPaiObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,null,1)
                                    ValorProcedimento = CalculaValorProcedimentoConvenioPaiObj("TotalGeral")
                                END IF

                                if pvp("Codigo")<>"" and not isnull(pvp("Codigo")) then
                                    CodigoProcedimento = pvp("Codigo")
                                end if
                            end if
                        end if

                        'verifica se ha procedimentos anexos e adiciona
                        IF  getConfig("calculostabelas") THEN
                            set ProcedimentosAnexosSQL = db.execute("SELECT * FROM tissprocedimentosanexos WHERE coalesce(tissprocedimentosanexos.Planos like CONCAT('%|',NULLIF('"&PlanoID&"',''),'|%'),true) AND  AssociacaoID=(('"&AssociacaoID&"')) AND ConvenioID="&ConvenioID&" AND ProcedimentoPrincipalID="&tpv("ProcedimentoID"))
                        ELSE
                            set ProcedimentosAnexosSQL = db.execute("SELECT * FROM tissprocedimentosanexos WHERE ConvenioID="&ConvenioID&" AND ProcedimentoPrincipalID="&tpv("ProcedimentoID"))
                        END IF

                        if not ProcedimentosAnexosSQL.eof then
                            while not ProcedimentosAnexosSQL.eof

                                TotalProcedimentos = TotalProcedimentos + ProcedimentosAnexosSQL("Valor")
                                ValorFinalAnexo = ProcedimentosAnexosSQL("Valor")
                                IF getConfig("calculostabelas") THEN
                                    set CalculaValorProcedimentoConvenioObj = CalculaValorProcedimentoConvenio(AssociacaoID,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,ProcedimentosAnexosSQL("id"),null)
                                    ValorFinalAnexo = (CalculaValorProcedimentoConvenioObj("TotalGeral"))
                                    TotalProcedimentos = TotalProcedimentos + ValorFinalAnexo
                                END IF

                                ProcAnexoCodigo = ProcedimentosAnexosSQL("Codigo")&""
                                if ProcAnexoCodigo="" then
                                    set codProd = db.execute("select Codigo from procedimentos where id="& treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID")) )
                                    if not codProd.eof then
                                        ProcAnexoCodigo = codProd("Codigo")
                                    end if
                                end if
                                sqlExecute = "insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, Anexo, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ("&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID"))&", 22, '"&rep(ProcAnexoCodigo)&"', '"&rep(ProcedimentosAnexosSQL("Descricao"))&"', 1, 1, "&treatvalzero(1)&", 1, "&treatvalzero(ValorFinalAnexo)&", "&treatvalzero(ValorFinalAnexo)&", 1, "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"
                                db_execute(sqlExecute)
                                IF getConfig("calculostabelas") THEN
                                    set lastInsert = db.execute("SELECT LAST_INSERT_ID() as Last")
                                    set ProcedimentoIncluidos.Item(lastInsert("Last")&"") = CalculaValorProcedimentoConvenioObj
                                END IF

                            ProcedimentosAnexosSQL.movenext
                            wend
                            ProcedimentosAnexosSQL.close
                            set ProcedimentosAnexosSQL=nothing
                        end if
                    end if

                    TotalProcedimentos = TotalProcedimentos+ValorProcedimento

                    sqlExecute = "insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ("&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&ProcedimentoID&", "&treatvalzero(TabelaID)&", '"&rep(CodigoProcedimento)&"', '"&rep(Descricao)&"', 1, 1, "&treatvalzero(TecnicaID)&", 1, "&treatvalzero(ValorProcedimento)&", "&treatvalzero(ValorProcedimento)&", "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"

                    db_execute(sqlExecute)

                    IF getConfig("calculostabelas") THEN
                        set lastInsert = db.execute("SELECT LAST_INSERT_ID() as Last")
                        IF IsObject(CalculaValorProcedimentoConvenioPaiObj) THEN
                            set ProcedimentoIncluidos.Item(lastInsert("Last")&"") = CalculaValorProcedimentoConvenioPaiObj
                        END IF

                        call CalculaEscalonamento(ProcedimentoIncluidos)
                    END IF


                    sqlExecute = "insert into tissprocedimentossadt_log (Obs, GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ('Adicionado a partir de agendamento', "&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&ProcedimentoID&", "&treatvalzero(TabelaID)&", '"&rep(CodigoProcedimento)&"', '"&rep(Descricao)&"', 1, 1, "&treatvalzero(TecnicaID)&", 1, "&treatvalzero(ValorProcedimento)&", "&treatvalzero(ValorProcedimento)&", "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"
                    db_execute(sqlExecute)

                    set pult = db.execute("select id from tissprocedimentossadt order by id desc limit 1")
                    if not conv.eof then
                        if ( conv("MesclagemMateriais")="Maior" ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
                            call matProcGuia(pult("id"), ConvenioID)
                        end if
                    end if

                ProcedimentosSQL.movenext
                wend
                ProcedimentosSQL.close
                set ProcedimentosSQL=nothing

            end if
        end if
        AtendimentoRN = "N"
        GrauParticipacaoID = 12
        'dados do profissional
        ProfissionalSolicitanteID = aEa("ProfissionalID")

        'verifica se possui profissional especificado para o procedimento 
        'se houver, usa as informações dele na guia de executantes
        sqlExecutante = "select * from tissprocedimentosvalores where ProcedimentoID="&ProcedimentoID&" and ConvenioID="&ConvenioID&" limit 1"
        sqlE = db.execute(sqlExecutante)
        if sqlE("profissionalExecutanteGuia") <> "" then
            ProfissionalSolicitanteID = sqlE("profissionalExecutanteGuia")
        end if
        set prof = db.execute("select p.*, e.* from profissionais as p left join especialidades as e on p.EspecialidadeID=e.id where p.id="&ProfissionalSolicitanteID)
        if not prof.eof then
            EspecialidadeProfissionalGuia = prof("EspecialidadeID")
            ConselhoProfissionalSolicitanteID = prof("Conselho")
            NumeroNoConselhoSolicitante = prof("DocumentoConselho")
            UFConselhoSolicitante = prof("UFConselho")
            CodigoCBOSolicitante = prof("codigoTISS")
            CPF = trim( replace(replace(prof("CPF")&" ", ".", ""), "-","") )
            GrauParticipacaoID = prof("GrauPadrao")
        end if
        if EspecialidadeProfissionalGuia&""<>"" AND EspecialidadeProfissionalGuia<>0  then
            set profEsp = db.execute("SELECT profEsp.ProfissionalID, profEsp.EspecialidadeID, profEsp.RQE, profEsp.Conselho, profEsp.UFConselho, profEsp.DocumentoConselho, esp.codigoTISS FROM profissionais p "&_
                                        "LEFT JOIN (SELECT ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionaisespecialidades "&_
                                        "UNION ALL  "&_
                                        "SELECT  id ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionais) profEsp ON profEsp.ProfissionalID=p.id "&_
                                        "LEFT JOIN especialidades esp ON esp.id=profEsp.EspecialidadeID "&_
                                        "WHERE p.id="&ProfissionalSolicitanteID&" AND profEsp.EspecialidadeID="&EspecialidadeProfissionalGuia)
            if not profEsp.eof then
                ConselhoProfissionalSolicitanteID =profEsp("Conselho")
                NumeroNoConselhoSolicitante = profEsp("DocumentoConselho")
                UFConselhoSolicitante = profEsp("UFConselho")
                CodigoCBOSolicitante = profEsp("codigoTISS")
            end if
        end if
        if GrauParticipacaoID&""="" then
            GrauParticipacaoID = 12
        end if
        'verifica se nesta guia já consta este profissional
        set vcaProf = db.execute("select * from tissprofissionaissadt where GuiaID="&reg("id")&" and ProfissionalID="&ProfissionalSolicitanteID)

        if vcaProf.eof then
            if ProfissionalSolicitanteID&"" <> "" and ProfissionalSolicitanteID&"" <> "0" then
            sqlExecute = "insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&reg("id")&", 1, "&GrauParticipacaoID&", "&ProfissionalSolicitanteID&", '"&CPF&"', "&treatvalnull(ConselhoProfissionalSolicitanteID)&", '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&session("User")&")"
            db_execute(sqlExecute)
            end if  

                sqlProfissionaisEquipe = (" SELECT p.id ProfissionalID, p.CPF, COALESCE(a.Funcao, 0) GrauParticipacaoID, p.DocumentoConselho, p.UFConselho, esp.codigoTISS CBOS, p.Conselho ConselhoID FROM procedimentosequipeconvenio a"&_
                                                    " inner JOIN profissionais p ON p.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '5'"&_
                                                    " LEFT JOIN especialidades esp ON esp.id=p.EspecialidadeID "&_
                                                    " WHERE a.ProcedimentoID = "&ProcedimentoID&_
                                                    " UNION ALL "&_
                                                    " SELECT proext.id, proext.cpf, COALESCE(a.Funcao, 0), proext.DocumentoConselho, proext.UFConselho, esp.codigoTISS CBOS, proext.Conselho FROM procedimentosequipeconvenio a "&_
                                                    " inner JOIN profissionalexterno proext ON proext.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '8'"&_
                                                    " LEFT JOIN especialidades esp ON esp.id=proext.EspecialidadeID "&_
                                                    " WHERE a.ProcedimentoID = "&ProcedimentoID)
                                                    

            set ProfissionaisEquipe = db.execute(sqlProfissionaisEquipe)
            while not ProfissionaisEquipe.eof
                set SequencialSQL = db.execute("SELECT Sequencial From tissprofissionaissadt WHERE GuiaID="&reg("id")&" order by Sequencial desc")

                Sequencial=1

                if not SequencialSQL.eof then
                    Sequencial = SequencialSQL("Sequencial") + 1
                end if

                sqlInsert = "INSERT INTO tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser)" &_
                                                "VALUES ("&reg("id")&", "&treatvalzero(Sequencial)&", "&ProfissionaisEquipe("GrauParticipacaoID")&", "&ProfissionaisEquipe("ProfissionalID")&", '"&ProfissionaisEquipe("CPF")&"', "&_
                                                treatvalzero(ProfissionaisEquipe("ConselhoID"))&", '"&ProfissionaisEquipe("DocumentoConselho")&"', '"&ProfissionaisEquipe("UFConselho")&"', "&treatvalzero(ProfissionaisEquipe("CBOS"))&", "&session("User")&")"
                db.execute(sqlInsert )

            ProfissionaisEquipe.movenext
            wend
            ProfissionaisEquipe.close
            set ProfissionaisEquipe=nothing


        end if
        've se é primeira consulta ou seguimento
        set vesecons = db.execute("select id from tissguiaconsulta where PacienteID="&PacienteID&" and sysActive=1 UNION ALL select id from tissguiasadt where PacienteID="&PacienteID&" and sysActive=1")
        if vesecons.eof then
            TipoConsultaID = 1
        else
            TipoConsultaID = 2
        end if
        CaraterAtendimentoID = 1
        ItemLancto = ItemLancto+1
        if reg("sysActive")=0 and isnumeric(ConvenioID) then
           NGuiaPrestador = numeroDisponivel(ConvenioID)
        end if

        sqlupdate = "UPDATE tissguiasadt SET "&_
                    "    PacienteID='"&PacienteID&"',"&_
                    "    CNS='"&vpac("cns")&"', "&_
                    "    NumeroCarteira='"&NumeroCarteira&"', "&_
                    "    AtendimentoRN='"&AtendimentoRN&"', "&_
                    "    ConvenioID='"&ConvenioID&"', "&_
                    "    RegistroANS='"&RegistroANS&"', "&_
                    "    NGuiaPrestador='"&NGuiaPrestador&"', "&_
                    "    Contratado=0, "&_
                    "    CodigoNaOperadora='"&CodigoNaOperadora&"', "&_
                    "    CodigoCNES='"&CodigoCNES&"', "&_
                    "    IndicacaoAcidenteID="&IndicacaoAcidenteID&", "&_
                    "    TipoConsultaID='"&TipoConsultaID&"', "&_
                    "    Observacoes='"&ObsIndicacaoClinica&"', "&_
                    "    DataAutorizacao=NOW(), "&_
                    "    ContratadoSolicitanteID='"&ContratadoSolicitanteID&"', "&_
                    "    ContratadoSolicitanteCodigoNaOperadora='"&ContratadoSolicitanteCodigoNaOperadora&"', "&_
                    "    ProfissionalSolicitanteID='"&ProfissionalSolicitanteID&"', "&_
                    "    ConselhoProfissionalSolicitanteID='"&Cint(ConselhoProfissionalSolicitanteID)&"', "&_
                    "    NumeroNoConselhoSolicitante='"&NumeroNoConselhoSolicitante&"', "&_
                    "    UFConselhoSolicitante='"&UFConselhoSolicitante&"', "&_
                    "    CodigoCBOSolicitante='"&CodigoCBOSolicitante&"', "&_
                    "    CaraterAtendimentoID="&CaraterAtendimentoID&", "&_
                    "    DataSolicitacao=NOW(), "&_
                    "    IndicacaoClinica='', "&_
                    "    TipoAtendimentoID="&TipoAtendimentoID&", "&_
                    "    IdentificadorBeneficiario='', "&_
                    "    Procedimentos=0, "&_                       
                    "    sysActive=1, "&_
                    "    sysDate=NOW(), "&_
                    "    AtendimentoID="&AtendimentoID&", "&_
                    "    AgendamentoID="&AgendamentoID&", "&_
                    "    PlanoID='"&PlanoID&"', "&_
                    "    tipoContratadoSolicitante='I', "&_
                    "    tipoProfissionalSolicitante='I', "&_
                    "    UnidadeID='"&session("UnidadeID")&"', "&_
                    "    ValorPago='0', "&_
                    "    GuiaStatus=15 "&_
                    "    WHERE id='"&reg("id")&"'"  
        db_execute (sqlupdate) 
        updateAgendamento = "UPDATE agendamentos SET formapagto = 1 WHERE id = '"&AgendamentoID&"'"
        db_execute (updateAgendamento)

        Procedimentos = 0
        TaxasEAlugueis = 0
        Materiais = 0
        OPME = 0
        Medicamentos = 0
        GasesMedicinais = 0
        TotalGeral = 0

        db_execute("update tissguiasadt set TotalGeral=0 where id="&reg("id"))
        TotalGeral = Procedimentos+TaxasEAlugueis+Materiais+OPME+Medicamentos+GasesMedicinais
        db_execute("update tissguiasadt set "&_ 
        "Procedimentos=(select sum(ValorTotal) from tissprocedimentossadt where GuiaID="&reg("id")&")"&_ 
        "where id="&reg("id"))
        set guia = db.execute("select * from tissguiasadt where id="&reg("id"))
        db_execute("update tissguiasadt set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&reg("id"))

    else 
        'Caso já exista a guia gerada atualizar o status da guia para 15 (aprovado e atendido)
        sqlupdate = "UPDATE tissguiasadt SET  GuiaStatus=15  WHERE id='"&rs_guia("id")&"'" 
        db_execute (sqlupdate) 
    end if 

end function 


if Acao="Iniciar" then
	set vesehapac = db.execute("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and isnull(HoraFim) and Data='"&myDate(date())&"'")
	if vesehapac.eof then

		sqlInsert = "insert into atendimentos (PacienteID, AgendamentoID, Data, HoraInicio, sysUser, ProfissionalID, UnidadeID) values ("&PacienteID&", "&AgendamentoID&", '"&mydate(date())&"', '"&time()&"', "&session("User")&", "&treatvalzero(session("idInTable"))&", "&treatvalzero(session("UnidadeID"))&")"
		sqlPult = "select * from atendimentos where PacienteID="&PacienteID&" order by id desc LIMIT 1"
		db_execute(sqlInsert)
		set pult = db.execute(sqlPult)
		
		'Ver o que estava agendado e lançar conta a receber ou guia
		set agendamento = db.execute("select age.*, l.UnidadeID from agendamentos age LEFT JOIN locais l ON l.id=age.LocalID where age.id="&AgendamentoID)
		if not agendamento.eof then
            UnidadeIDAgendamento = agendamento("UnidadeID")

            StaIDTriagem = req("StaID")
            if StaIDTriagem = "200" or StaIDTriagem = "204" or StaIDTriagem = "206" then
                StaIDTriagem = "202"
            elseif StaIDTriagem = "201" or StaIDTriagem = "205" or StaIDTriagem = "207" then
                StaIDTriagem = "203"
            else
                StaIDTriagem = "2"
            end if

			'triagem
            set ConfigSQL = db.execute("SELECT Triagem,PosConsulta FROM sys_config WHERE id=1")

            if not ConfigSQL.eof then
                if (ConfigSQL("Triagem")="S" or ConfigSQL("PosConsulta")="S") and agendamento("ProfissionalID")<>session("idInTable") then
                    db_execute("UPDATE atendimentos SET Triagem='S' WHERE id="&pult("id"))
                end if
            end if

            db_execute("update agendamentos SET StaID = "&StaIDTriagem&" WHERE id="&AgendamentoID)

            call logAgendamento(AgendamentoID, "Atendimento iniciado pela sala de espera", "R")

            if UnidadeIDAgendamento&""<>session("UnidadeID") then
                db.execute("update atendimentos SET UnidadeID = "&treatvalzero(UnidadeIDAgendamento)&" WHERE id="&pult("id"))
            end if
			if agendamento("rdValorPlano")="P" then
				ValorFinal = valConvenio(agendamento("ValorPlano"), "", PacienteID, agendamento("TipoCompromissoID"))
			else
				ValorFinal = agendamento("ValorPlano")
			end if
			db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&pult("id")&", "&agendamento("TipoCompromissoID")&", '', "&treatvalzero(agendamento("ValorPlano"))&", '"&agendamento("rdValorPlano")&"', 1, "&treatvalzero(ValorFinal)&")")
			if agendamento("Procedimentos")&"" <> "" then
			    set ProcedimentosAnexosSQL = db.execute("SELECT * FROM agendamentosprocedimentos WHERE AgendamentoID="&agendamento("id"))
			    if not ProcedimentosAnexosSQL.eof then
			        while not ProcedimentosAnexosSQL.eof
                        if agendamento("rdValorPlano")="P" then
                            ValorFinal = valConvenio(ProcedimentosAnexosSQL("ValorPlano"), "", PacienteID, ProcedimentosAnexosSQL("TipoCompromissoID"))
                        else
                            ValorFinal = ProcedimentosAnexosSQL("ValorPlano")
                        end if
                        db_execute("insert into atendimentosprocedimentos (AtendimentoID, ProcedimentoID, Obs, ValorPlano, rdValorPlano, Fator, ValorFinal) values ("&pult("id")&", "&ProcedimentosAnexosSQL("TipoCompromissoID")&", '', "&treatvalzero(ProcedimentosAnexosSQL("ValorPlano"))&", '"&ProcedimentosAnexosSQL("rdValorPlano")&"', 1, "&treatvalzero(ValorFinal)&")")

			        ProcedimentosAnexosSQL.movenext
                    wend
                    ProcedimentosAnexosSQL.close
                    set ProcedimentosAnexosSQL=nothing
                end if
            end if
			set pultAP = db.execute("select id from atendimentosprocedimentos where AtendimentoID="&pult("id")&" order by id desc limit 1")
			'Coleta os dados pra identificar o dominio do rateio
			if agendamento("rdValorPlano")="V" then
				FormaID = "P"
			else
				FormaID = agendamento("ValorPlano")
			end if
'			DominioID = dominioRepasse(FormaID, agendamento("ProfissionalID"), agendamento("TipoCompromissoID"), UnidadeID, agendamento("TabelaParticularID"), agendamento("EspecialidadeID"))
'			call materiaisInformados(DominioID, session("User"), pultAP("id"))
		end if
		pultID = pult("id")
	else
		pultID = vesehapac("id")
	end if
    AtendimentoID=pultID
	if instr(session("Atendimentos"), "|"&pultID&"|")=0 then
		session("Atendimentos")=session("Atendimentos")&"|"&pultID&"|"
	end if
end if

if Acao="" then
	set buscaAtendimento = db.execute("select id from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' and isnull(HoraFim)")
	if buscaAtendimento.eof then
		set buscaAtendimento = db.execute("select id from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' order by id desc limit 1")
	end if
	if not buscaAtendimento.eof then
	    AtendimentoID=buscaAtendimento("id")
    end if
end if

if Acao="PreEncerrar" then
	set buscaAtendimento = db.execute("select id from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' and isnull(HoraFim)")
	if buscaAtendimento.eof then
		set buscaAtendimento = db.execute("select id from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' order by id desc limit 1")
	end if
	if not buscaAtendimento.eof then
	    AtendimentoID=buscaAtendimento("id")
''		db_execute("update atendimentos set HoraFim='"&time()&"' where id="&buscaAtendimento("id"))
		'fecha possível lista de espera com este paciente
''		set lista = db.execute("select * from agendamentos where PacienteID="&PacienteID&" and Data='"&mydate(date())&"' and StaID<>3 and ProfissionalID="&session("idInTable")&" order by Hora")
''		session("Atendimentos") = replace(session("Atendimentos"), "|"&buscaAtendimento("id")&"|", "")
		set lista = db.execute("select StaID from agendamentos where id="&req("Atender"))
		StaID = ""
        if not lista.EOF then
			StaID = lista("StaID")
		end if
		%>
		<script language="javascript">
    <%
        set AtendimentoSQL = db.execute("SELECT PacienteID, agendamentoid FROM atendimentos WHERE id="&buscaAtendimento("id"))
        set FormPreenchidoSQL = db.execute("SELECT count(id)n FROM buiformspreenchidos WHERE PacienteID="&AtendimentoSQL("PacienteID")&" AND sysUser="&session("User")&" AND sysActive=1 AND date(DataHora)="&mydatenull(date()))
        'Caso esteja configurado para gerar a guia automaticamente
        sqlconfigplano = "SELECT conve.GerarGuiaAutomatica " &_
                         "  FROM agendamentos ag " &_
                         " INNER JOIN convenios conve ON conve.id = ag.ValorPlano  " &_
                         " WHERE ag.id =  '" &AtendimentoSQL("agendamentoid")&"'"
        'response.write(sqlconfigplano)
        set configPlano = db.execute(sqlconfigplano)
        'response.write("------->" &configPlano("GerarGuiaAutomatica"))
        IF not configPlano.eof THEN
            IF configPlano("GerarGuiaAutomatica") = 1 or configPlano("GerarGuiaAutomatica") = true THEN 
                call incluirGuiaSADT(buscaAtendimento("id"), AtendimentoSQL("agendamentoid"))
            END IF
        END IF

        if  FormPreenchidoSQL("n") = "0" and getConfig("QuestionarPreenchimentoDeFormulario") = "S" then
            %>  
                setTimeout(function(){
                $.ajax({
                    type:"POST",
                    url:"modalConfirmaFinalizarAtendimento.asp?AgendamentoID=<%=req("Atender")%>&AtendimentoID=<%=buscaAtendimento("id")%>&Origem=Atendimento&PacienteID=<%=PacienteID%>&Solicitacao=<%=req("Solicitacao")%>",
                    success: function(data){
                        $("#modal").html(data);
                        setTimeout(function() {
                            $("#modal-table").modal("show");
                        }, 400);
                    }
                });
                }, 200);
            <%  
        else
            %>
                setTimeout(function(){
                $.ajax({
                    type:"POST",
                    url:"modalInfAtendimento.asp?AgendamentoID=<%=req("Atender")%>&AtendimentoID=<%=buscaAtendimento("id")%>&Origem=Atendimento&PacienteID=<%=PacienteID%>&Solicitacao=<%=req("Solicitacao")%>",
                    success: function(data){
                        $("#modal").html(data);
                        setTimeout(function() {
                            $("#modal-table").modal("show");
                        }, 400);
                    }
                });
                }, 200);
            <%  
        end if 
        %>

		
		</script>
		<%
	end if
end if


if Acao="Solicitar" then
'	response.Write("select * from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"'")
	set buscaAtendimento = db.execute("select id from atendimentos where sysUser="&session("User")&" and PacienteID="&PacienteID&" and Data='"&myDate(date())&"' and isnull(HoraFim)")
	if not buscaAtendimento.eof then
	    AtendimentoID=buscaAtendimento("id")
		'db_execute("update atendimentos set HoraFim='"&time()&"' where id="&buscaAtendimento("id"))
		'fecha possível lista de espera com este paciente
		'set lista = db.execute("select * from agendamentos where PacienteID="&PacienteID&" and Data='"&mydate(date())&"' and StaID<>3 and ProfissionalID="&session("idInTable")&" order by Hora")
		'if not lista.EOF then
		'	db_execute("update agendamentos set StaID=3 where id="&lista("id"))
		'end if
		'session("Atendimentos") = replace(session("Atendimentos"), "|"&buscaAtendimento("id")&"|", "")
		db_execute("update sys_users set UsuariosNotificar='"&ref("UsuariosNotificar")&"' where id="&session("User"))
		splNotificar = split(ref("UsuariosNotificar"), "|")
		for	h=0 to ubound(splNotificar)
			if isnumeric(splNotificar(h)) and splNotificar(h)<>"" then
				db_execute("update sys_users as u set notiflanctos=concat( u.notiflanctos, '|"&buscaAtendimento("id")&"|' ) where id="&splNotificar(h))
			end if
		next
		%>
		<script language="javascript">
		$("#modal-table").modal("hide");
		//$("#agePac<%=PacienteID%>").css("display", "none");
/*		$.ajax({
			type:"POST",
			url:"modalFimAtendimento.asp?AtendimentoID=<%=buscaAtendimento("id")%>",
			success: function(data){
				$("#modal").html(data);
				$("#modal-table").modal("show");
			}
		});*/
		//location.href='./?P=ListaEspera&Pers=1';
		</script>
		<%
	end if
end if

'Agora verifica se quando carrega diretamente via server.Execute o paciente em questão está sendo atendido
if session("Atendimentos")<>"" then
	spl = split(session("Atendimentos"), "|")
	for i=0 to ubound(spl)
		if spl(i)<>"" and isnumeric(spl(i)) then
			set vePac = db.execute("select * from atendimentos where id="&spl(i))
			if not vePac.eof then
				if vePac("PacienteID")=PacienteID then
					Conteudo = "Contador"
					HoraInicio = cdate( hour(vePac("HoraInicio"))&":"&minute(vePac("HoraInicio"))&":"&second(vePac("HoraInicio")) )
					Tempo = cdate( time()-HoraInicio )
				end if
			end if
		end if
	next
end if

if Conteudo="" then
	Conteudo = "Play"
end if


iniciarDisabled = ""
if lcase(session("Table")) <> "profissionais" then
    iniciarDisabled = " disabled "
end if

set ConfigObrigarPagamentoSQL = db.execute("SELECT ChamarAposPagamento, ObrigarIniciarAtendimento FROM sys_config WHERE id=1")

if not ConfigObrigarPagamentoSQL.eof then
    if ConfigObrigarPagamentoSQL("ChamarAposPagamento")="S" and ConfigObrigarPagamentoSQL("ObrigarIniciarAtendimento")=1 then

        if session("table")="profissionais" then

            set EncontraAgendamentoSQL = db.execute("SELECT FormaPagto FROM agendamentos WHERE Data=CURDATE() AND ProfissionalID="&session("idInTable")&" AND PacienteID="&PacienteID)

            if not EncontraAgendamentoSQL.eof then
                if EncontraAgendamentoSQL("FormaPagto")=-2 then
                    iniciarDisabled = "disabled"

                    avisoIniciarAtendimento = "Não é possível iniciar atendimento pois há pendências financeiras."
                end if
            end if
        end if

    end if
end if

if Conteudo="Play" then
        if getConfig("ExibirIniciarAtendimento") then
            %>
                    <button <%=iniciarDisabled%> type="button" class="btn btn-success btn-gradient btn-acao-atendimento btn-alt btn-block" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'Iniciar', '')"><i class="fa fa-play"></i> Iniciar Atendimento </button>
            <%
            else
            %>
            <script>
                $("#divContador").parent().removeClass("tray-bin")
            </script>
            <%
        end if
        if avisoIniciarAtendimento<>"" then
            %>
            <small><%=avisoIniciarAtendimento%></small>
            <%
        end if
      else
        %>
        <h3 class="text-center light"><i class="far fa-clock-o"></i> <span id="counter"><%=Tempo%></span></h3>
          <div class="row">
            <% if getConfig("SolicitacaoDeProcedimentosEspera")="1" then %>

                <div class="col-sm-6">
                    <button class="btn btn-danger btn-gradient btn-alt btn-block col-sm-6" type="button" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'PreEncerrar', 'N')"><i class="far fa-stop"></i> Finalizar</button>
                </div>
                <div class="col-sm-6">
                    <button class="btn btn-warning btn-gradient btn-alt btn-block col-sm-6" type="button" onClick="atEspera()"><i class="far fa-pause"></i> Espera</button>
                </div>
                <% IF session("AtendimentoTelemedicina")&""<>"" THEN %>
                <div class="col-sm-12">
                    <button class="btn btn-warning btn-gradient btn-alt btn-block col-sm-6" type="button" onClick="cancelarAtendimento()"><i class="far fa-times"></i> Cancelar Atendimento</button>
                </div>
                <% END IF %>

                <script type="text/javascript">
                    function cancelarAtendimento(){
                        let conf= confirm("Deseja realmente cancelar o atendimento?");
                        if (!conf) return;
                        location.href = "./?P=Pacientes&Acao=CancelarTelemedicina&Pers=1&I=<%=req("I") %>"
                    }

                    function encerrar() {
                        $.post("saveInf.asp?AgendamentoID=<%= AgendamentoID %>&Atendimentos=<%= session("Atendimentos") %>&AtendimentoID=<%=AtendimentoID%>&rPacienteID=<%= PacienteID %>&Origem=Atendimento&Solicitacao=N",
                            {
                                'inf-ProfissionalID': '<%= session("idInTable") %>',
                                UnidadeID: '<%= session("UnidadeID") %>'
                        }, function (data) { eval(data) });
                    }

                    function atEspera() {
                        $.get("atEspera.asp?PacienteID=<%= PacienteID %>&Atendimentos=<%= session("Atendimentos")%>", function (data) {
                            $("#modal").html("Carregando...");
                            $("#modal-table").modal("show");
                            $("#modal").html(data);
                        });
                    }
                </script>

            <% else %>
                <div class="col-sm-6">
                    <button class="btn btn-danger btn-gradient btn-alt btn-block col-sm-6" type="button" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'PreEncerrar', 'N')"><i class="far fa-stop"></i> Finalizar</button>
                </div>
                <div class="col-sm-6">
                    <button class="btn btn-warning btn-gradient btn-alt btn-block col-sm-6 <% if session("Banco")="clinic5351" then response.write(" hidden ") end if %> " type="button" onClick="atender(<%= AgendamentoID %>, <%= PacienteID %>, 'PreEncerrar', 'S')"><i class="far fa-pause"></i> Solicitar</button>
                </div>
            <% end if %>
          </div>
          <%
          if lcase(session("Table")) = "profissionais" and recursoAdicional(20)=4 or True then

            set AssinaturaDigitalConfiguradaSQL = db_execute("select id from dc_pdfstampconfigs WHERE UsuarioID="&treatvalzero(session("User")))

            if not AssinaturaDigitalConfiguradaSQL.eof then
            %>
                <script type="text/javascript" src="https://get.webpkiplugin.com/Scripts/LacunaWebPKI/lacuna-web-pki-2.12.0.js"></script>

                <div class="col-md-12">
                    <div style="float: left; opacity: 0.4; cursor: default" id="content-assinatura" data-toggle="tooltip" data-placement="bottom" title="Carregando...">
                        <div class="switch round switch-xs " style="float: left;">
                            <input disabled onchange="persistAssinaturaAuto(this)" name="AssinaturaAuto" id="AssinaturaAuto" type="checkbox">
                            <label for="AssinaturaAuto"></label>
                        </div>
                        <span style="position: relative; top: 3px;" class="ml10 ">Assinatura digital</span>
                    </div>
                    <div style="display:none" id="conteudo-assinatura-auto">

                    </div>

                </div>
                <script>
                    $(document).ready(function(){
                        assinaturaAuto = localStorage.getItem("assinaturaAuto");
                        if(assinaturaAuto == "1"){
                            $("#AssinaturaAuto").attr("checked", "checked")
                        }

                        function lacunaNotAvailable(){
                            const $contentAssinatura = $("#content-assinatura");

                            $contentAssinatura.attr("data-original-title", "Você precisa instalar a extensão WebPki para usar o certificado digital.");
                            $contentAssinatura.tooltip();
                        }

                        function lacunaIsAvailable(){
                            const $contentAssinatura = $("#content-assinatura");
                            const $inputAssinar = $("#AssinaturaAuto");

                            $inputAssinar.attr("disabled", false);
                            $contentAssinatura.css("opacity", 1);
                            $contentAssinatura.attr("data-original-title", "");
                            $contentAssinatura.tooltip();
                        }

                        try{
                            var pki = new LacunaWebPKI();
                            function start() {
                                pki.init({
                                    ready: lacunaIsAvailable,
                                    notInstalled: lacunaNotAvailable
                                });
                            }
                            start();
                        }catch (e){
                            lacunaNotAvailable();
                        }

                    })
                </script>
            <%
            end if
          end if
          %>
      <script type="text/javascript">
      var stopTime;
      /**********************************************************************************************
      * CountUp script by Praveen Lobo (http://PraveenLobo.com/techblog/javascript-countup-timer/)
      * This notice MUST stay intact(in both JS file and SCRIPT tag) for legal use.
      * http://praveenlobo.com/blog/disclaimer/
      **********************************************************************************************/
      function CountUp(initDate, id){
          this.beginDate = new Date(initDate);

          this.countainer = document.getElementById(id);
          this.numOfDays = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
          this.borrowed = 0, this.years = 0, this.months = 0, this.days = 0;
          this.hours = 0, this.minutes = 0, this.seconds = 0;
          this.updateNumOfDays();
          this.updateCounter();
      }

      var c = 0;
      function getNow() {
            var now = "<%=now()%>";

            now = now.split(" ");

            var nowS = now[0].split('/');


            now = nowS[2]+"-"+nowS[1]+"-"+nowS[0]+"T"+now[1];


            var Now = new Date(now);

            if(c > 0){
                Now.setSeconds(Now.getSeconds() + c);
            }

            c += 1;

            return Now;
      }

      CountUp.prototype.updateNumOfDays=function(){
          var dateNow = new Date();
          var currYear = dateNow.getFullYear();
          if ( (currYear % 4 == 0 && currYear % 100 != 0 ) || currYear % 400 == 0 ) {
              this.numOfDays[1] = 29;
          }
          var self = this;
          setTimeout(function(){self.updateNumOfDays();}, (new Date((currYear+1), 1, 2) - dateNow));
      }

      CountUp.prototype.datePartDiff=function(then, now, MAX){
          var diff = now - then - this.borrowed;
          this.borrowed = 0;
          if ( diff > -1 ) return diff;
          this.borrowed = 1;
          return (MAX + diff);
      };

      var is_iPad = navigator.userAgent.match(/iPad/i) != null;

      CountUp.prototype.calculate=function(){
//          var currDate = new Date();
          var currDate = getNow();

          var prevDate = this.beginDate;
          this.seconds = this.datePartDiff(prevDate.getSeconds(), currDate.getSeconds(), 60);
          this.minutes = this.datePartDiff(prevDate.getMinutes(), currDate.getMinutes(), 60);

          this.hours = this.datePartDiff(prevDate.getHours(), currDate.getHours(), 24);
          if(is_iPad){
            this.hours -= 21;
          }
          this.days = this.datePartDiff(prevDate.getDate(), currDate.getDate(), this.numOfDays[currDate.getMonth()]);
          this.months = this.datePartDiff(prevDate.getMonth(), currDate.getMonth(), 12);
          this.years = this.datePartDiff(prevDate.getFullYear(), currDate.getFullYear(),0);
      };

      CountUp.prototype.addLeadingZero=function(value){
          return value < 10 ? ("0" + value) : value;
      };

      CountUp.prototype.formatTime=function(){
          this.seconds = this.addLeadingZero(this.seconds);
          this.minutes = this.addLeadingZero(this.minutes);
          this.hours = this.addLeadingZero(this.hours);
      };

      CountUp.prototype.updateCounter=function(){
          this.calculate();
          this.formatTime();
          var time = this.hours + ":" + this.minutes + ":" + this.seconds;
          this.countainer.innerHTML = time;

          $("title").html(time + " - Em atendimento");
          var self = this;
          stopTime = setTimeout(function(){self.updateCounter();}, 1000);
      };

      //window.onload=function(){ new CountUp('April 16, 2014 <%=HoraInicio%>', 'counter'); }
      $( document ).ready(function() {
          clearTimeout(stopTime);
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth()+1; //January is 0!
            var yyyy = today.getFullYear();

            if(dd<10) {
                dd = '0'+dd
            }

            if(mm<10) {
                mm = '0'+mm
            }

            today = yyyy + '/' + mm  + '/' + dd;

            var dateTime = today+' <%=HoraInicio%>';
            clearTimeout(stopTime);

            new CountUp(dateTime, 'counter');
        });

        callbackAssinatura = {fn: undefined}
        function callbackFinishSign(res) {
            if(res == "SUCCESS"){
                showMessageDialog("Atendimento assinado com sucesso!", "success")
            }else{
                showMessageDialog("Ocorreu um erro ao assinar o documento.", "danger")
            }

            gtag('event', 'assinatura_automatica_finalizada', {
                'event_category': 'atendimento',
                'event_label': res == "SUCCESS" ? "Assinatura realizada com sucesso." : "Erro na assinatura.",
            });


            callbackAssinatura.fn(res);
        }

        function assinarAtendimento(cbFinalizar){


            gtag('event', 'assinatura_automatica_iniciada', {
                'event_category': 'atendimento',
                'event_label': "Assinatura iniciada - Finalizando atendimento",
            });

            var modal =
                    `<div class="modal fade" >
            <div class="modal-dialog modal-sm">
                <div class="modal-content">
                    <div class="modal-body " id="alertmodalassinaturabody" style="text-align:center">
                        <i class="fa fa-2x fa-circle-o-notch fa-spin"></i>
                        <p>Assinando documento...</p>
                    </div>
                </div>
            </div>
            </div>`;

            var modal = $(modal);
            modal.modal("show");

            callbackAssinatura.fn = function(res){
                $(".btn-acao-atendimento").attr("disabled", true);
                modal.modal("hide");
                cbFinalizar(res);
            }

            getUrl("/digital-certification/assinar-avulso", {
                tipo: "ATENDIMENTO",
                id: "<%=AtendimentoID%>"
            }, function(data){
                if(data === "ERROR"){
                    closeComponentsModal();
                    showMessageDialog("Não assinado", "warning");
                    cbFinalizar("error");
                }else{
                    $("#conteudo-assinatura-auto").html(data);
                }
            });
        }

        function persistAssinaturaAuto(el){
            v = $(el).prop("checked") ? 1 : 0
            localStorage.setItem("assinaturaAuto", v);

            gtag('event', 'assinatura_auto_alterada', {
                'event_category': 'atendimento',
                'event_label': v ? "Assinatura automática ativada" : "Assinatura automática desativada.",
            });

        }

      </script>

        <%
end if
%>
