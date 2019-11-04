<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<!--#include file="tissFuncs.asp"-->
<!--#include file="Classes/ValorProcedimento.asp"-->
<!--#include file="Classes/JSON.asp"-->
<%posModalPagar="fixed" %>
<!--#include file="invoiceEstilo.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
close = req("close")

MinimoDigitos = 0
MaximoDigitos = 100

'set AutorizadorTissSQL = db.execute("SELECT id FROM sys_config WHERE RecursosAdicionais LIKE '%|AutorizadorTiss|%'")
recursoUnimed = recursoAdicional(12)
recursoAutorizadorTISS = recursoAdicional(3)
AutorizadorTiss = False

if recursoAutorizadorTISS= 4 or recursoUnimed = 4 then
    AutorizadorTiss=True
end if

if not reg.eof then
	if reg("sysActive")=1 then
		DataSolicitacao = reg("DataSolicitacao")
		UnidadeID = reg("UnidadeID")

        if not isnull(reg("ConvenioID")) and reg("ConvenioID")<>0 then
            set convBloq=db.execute("select BloquearAlteracoes from convenios where id="&reg("ConvenioID"))
            if not convBloq.eof then
                if convBloq("BloquearAlteracoes")=1 then
                %>
                <script type="text/javascript">
                    $(document).ready(function(){
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #_NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #_UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
                        //proc -> TabelaID, CodigoProcedimento, Descricao, ViaID, TecnicaID, ValorUnitario
                        //prof -> CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO
                    });
                </script>
                <%
                end if
            end if
        end if
	else
		DataSolicitacao = date()
		sqlExecute = "delete from tissprocedimentossadt where GuiaID="&reg("id")
		db_execute(sqlExecute)

		sqlExecute = "delete from tissprofissionaissadt where GuiaID="&reg("id")
        db_execute(sqlExecute)

		sqlExecute = "delete from tissguiaanexa where GuiaID="&reg("id")
        db_execute(sqlExecute)

'		set procs = db.execute("select id from tissprocedimentossadt where GuiaID="&reg("id"))
'		while not procs.eof
'			db_execute("delete from rateiorateios rr where rr.Temp=1 and ItemGuiaID="&procs("id"))
'		procs.movenext
'		wend
'		procs.movenext
'		set procs=nothing
		sqlExecute = "update tissguiasadt set Procedimentos=0, TaxasEAlugueis=0, Materiais=0, OPME=0, Medicamentos=0, GasesMedicinais=0 where id="&reg("id")
        db_execute(sqlExecute)

		sqlExecute = "update tissguiasadt set TotalGeral=0 where id="&reg("id")
        db_execute(sqlExecute)

		if cdate(formatdatetime(reg("sysDate"),2))<date() then
			sqlExecute = "update tissguiasadt set sysDate=NOW() where id="&reg("id")
            db_execute(sqlExecute)
		end if
		UnidadeID = session("UnidadeID")
	end if

	TotalProcedimentos = 0

	PacienteID = reg("PacienteID")
	CNS = reg("CNS")
	ConvenioID = reg("ConvenioID")
	PlanoID = reg("PlanoID")
	StatusGuia = reg("GuiaStatus")
	RegistroANS = reg("RegistroANS")
	NGuiaPrestador = reg("NGuiaPrestador")
	NGuiaOperadora = reg("NGuiaOperadora")
	NGuiaPrincipal = reg("NGuiaPrincipal")
	DataAutorizacao = reg("DataAutorizacao")
	Senha = reg("Senha")
	DataValidadeSenha = reg("DataValidadeSenha")
	NumeroCarteira = reg("NumeroCarteira")
	ValidadeCarteira = reg("ValidadeCarteira")
	AtendimentoRN = reg("AtendimentoRN")
	ContratadoSolicitanteID = reg("ContratadoSolicitanteID")
	ContratadoSolicitanteCodigoNaOperadora = reg("ContratadoSolicitanteCodigoNaOperadora")
	ProfissionalSolicitanteID = reg("ProfissionalSolicitanteID")
	ConselhoProfissionalSolicitanteID = reg("ConselhoProfissionalSolicitanteID")
	NumeroNoConselhoSolicitante = reg("NumeroNoConselhoSolicitante")
	UFConselhoSolicitante = reg("UFConselhoSolicitante")
	CodigoCBOSolicitante = reg("CodigoCBOSolicitante")
	CaraterAtendimentoID = reg("CaraterAtendimentoID")
	IndicacaoClinica = reg("IndicacaoClinica")
	Contratado = reg("Contratado")
	CodigoNaOperadora = reg("CodigoNaOperadora")
	CodigoCNES = reg("CodigoCNES")
	TipoAtendimentoID = reg("TipoAtendimentoID")
	IndicacaoAcidenteID = reg("IndicacaoAcidenteID")
	TipoConsultaID = reg("TipoConsultaID")
	MotivoEncerramentoID = reg("MotivoEncerramentoID")
	Observacoes = reg("Observacoes")
	Procedimentos = reg("Procedimentos")
	TaxasEAlugueis = reg("TaxasEAlugueis")
	Materiais = reg("Materiais")
	OPME = reg("OPME")
	Medicamentos = reg("Medicamentos")
	GasesMedicinais = reg("GasesMedicinais")
	TotalGeral = reg("TotalGeral")
    tipoContratadoSolicitante = reg("tipoContratadoSolicitante")
    if getConfig("OcultarSolicitanteInterno") = 1 then
        tipoProfissionalSolicitante = "E"
    else
        tipoProfissionalSolicitante = reg("tipoProfissionalSolicitante")
    end if 
    'if session("Banco")="clinic522" then
    	identificadorBeneficiario = reg("identificadorBeneficiario")
    'end if
    sysUser = reg("sysUser")
    sysActive = reg("sysActive")
    sysDate = reg("sysDate")

    if sysActive=0 and session("Banco")="clinic5856" then
        DataAutorizacao = date()
    end if

	'Auto-preenche a guia baseado no lancto
	ItemLancto = 1
	if req("Lancto")<>"" then
		if instr(req("Lancto"), "Paciente") then
			spl = split(req("Lancto"), "|")
			PacienteID = spl(0)
            set convPac = db.execute("select p.ConvenioID1, p.Matricula1, p.Validade1 from pacientes p where id="&PacienteID&" and not isnull(p.ConvenioID1) and p.ConvenioID1!=0")
            if not convPac.EOF then
                trocaConvenioID = convPac("ConvenioID1")
                ConvenioID = convPac("ConvenioID1")
                drCD = "tissCompletaDados('Convenio', "&ConvenioID&");"
            end if
            set vcaAte = db.execute("select * from atendimentos where PacienteID="&PacienteID&" and Data=date(now())")
            if not vcaAte.eof then
                ProfissionalSolicitanteID = vcaAte("ProfissionalID")
            else
                set vcaAge = db.execute("select ProfissionalID from agendamentos where PacienteID="&PacienteID&" and Data=date(now())")
                if not vcaAge.eof then
                    ProfissionalSolicitanteID = vcaAge("ProfissionalID")
                end if
            end if
            if ProfissionalSolicitanteID<>"" then
                drCD = drCD &"tissCompletaDados('ProfissionalSolicitante', "&ProfissionalSolicitanteID&");"
            end if

		else
			spl = split(req("Lancto"), ", ")
			for i=0 to ubound(spl)
                if spl(i)<>"" then
				    splAEA = split(spl(i), "|")
				    if splAEA(1)="agendamento" then
					    set aEa = db.execute("select ag.id, ag.Data, ag.Hora as HoraInicio, ag.HoraFinal as HoraFim, ag.TipoCompromissoID as ProcedimentoID, ag.ProfissionalID, ag.Notas as Obs, ag.ValorPlano, ag.rdValorPlano, ag.PacienteID, ag.StaID as Icone, 'agendamento' as Tipo, ag.id as AgendamentoID, ag.EspecialidadeID from agendamentos as ag where ag.id like '"&splAEA(0)&"' order by ag.Data desc, ag.Hora desc, ag.HoraFinal desc")
				    else
					    set aEa = db.execute("select ap.id, at.Data, at.HoraInicio, at.HoraFim, ap.ProcedimentoID, at.ProfissionalID, ap.Obs, ap.ValorPlano, ap.rdValorPlano, at.PacienteID, 'executado' Tipo, 'executado' Icone, at.AgendamentoID, ag.EspecialidadeID FROM  atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ag ON ag.id=at.AgendamentoID where ap.id like '"&splAEA(0)&"' order by at.Data desc, at.HoraInicio desc, at.HoraFim desc")
				    end if
				    if not aEa.eof then
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
						    set conv = db.execute("select c.*, (select count(id) from tissguiaanexa where GuiaID="& req("I") &") NMateriais from convenios c where c.id="&ConvenioID)
						    if not conv.eof then
							    RegistroANS = conv("RegistroANS")
                                RepetirNumeroOperadora = conv("RepetirNumeroOperadora")
							    set contratoExecutante = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and (ExecutanteOuSolicitante like '%|E|%' or  ExecutanteOuSolicitante='') and not isnull(Contratado)")
							    'response.write("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and (ExecutanteOuSolicitante like '%|E|%' or  ExecutanteOuSolicitante='') and not isnull(Contratado)")

							    if not contratoExecutante.eof then
								    Contratado = contratoExecutante("Contratado")

								    CodigoNaOperadora = contratoExecutante("CodigoNaOperadora") 'conv("NumeroContrato")
							    end if

                                set contratoSolicitante = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and (ExecutanteOuSolicitante like '%|S|%' or  ExecutanteOuSolicitante='') and not isnull(Contratado)")
                                if not contratoSolicitante.eof then
                                    ContratadoSolicitanteID = contratoSolicitante("Contratado")
                                    ContratadoSolicitanteCodigoNaOperadora = contratoSolicitante("CodigoNaOperadora") ' conv("NumeroContrato")
                                end if
							    if not isnull(Contratado) and Contratado<>"" then
								    if Contratado=0 then
									    set contr = db.execute("select * from empresa")
									    if not contr.eof then
										    CodigoCNES = contr("CNES")
									    end if
								    elseif Contratado<0 then
									    set contr = db.execute("select * from sys_financialcompanyunits where id="&(Contratado*(-1)))
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
								    PlanoID = vpac("PlanoID"&Numero)
							    end if
						    end if




						    if HoraInicio=HoraFim then
                                HoraInicio = "NULL"
                                HoraFim = "NULL"
                            end if
						    've se há valor definido pra este procedimento neste convênio

                            if splAEA(1)="agendamento" then
                                set ProcedimentosSQL = db.execute("SELECT a.TipoCompromissoID from agendamentos a where a.id like '"&splAEA(0)&"' UNION ALL select ap.TipoCompromissoID from agendamentosprocedimentos ap where ap.agendamentoid like '"&splAEA(0)&"' ")
                            else
                                set ProcedimentosSQL = db.execute("select ap.ProcedimentoID TipoCompromissoID FROM atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID where ap.id like '"&splAEA(0)&"'")
                            end if

                            Dim ProcedimentoIncluidos
                            Set ProcedimentoIncluidos=Server.CreateObject("Scripting.Dictionary")

						    while not ProcedimentosSQL.eof
						        ProcedimentoID=ProcedimentosSQL("TipoCompromissoID")

                                sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC "
                                'sqlCodigoNaOperador = "SELECT * FROM contratosconvenio WHERE ConvenioID = "&ConvenioID&" AND (Contratado = "&session("idInTable")&" OR Contratado = "&session("UnidadeID")&"*-1) ORDER BY Contratado DESC "
                                'response.write(sqlCodigoNaOperador)

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
                                        set CalculaValorProcedimentoConvenioPaiObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,null)
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
                                                set CalculaValorProcedimentoConvenioPaiObj = CalculaValorProcedimentoConvenio(null,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,null)
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

                                            IF getConfig("calculostabelas") THEN
                                                set CalculaValorProcedimentoConvenioObj = CalculaValorProcedimentoConvenio(AssociacaoID,ConvenioID,ProcedimentoID,PlanoID,CodigoNaOperadoraNew,null,ProcedimentosAnexosSQL("id"))
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
                                            sqlExecute = "insert into tissprocedimentossadt (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ("&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID"))&", 22, '"&rep(ProcAnexoCodigo)&"', '"&rep(ProcedimentosAnexosSQL("Descricao"))&"', 1, 1, "&treatvalzero(1)&", 1, "&treatvalzero(ValorFinalAnexo)&", "&treatvalzero(ValorFinalAnexo)&", "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"
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
                                    if ( conv("MesclagemMateriais")="Maior" and ccur(conv("NMateriais"))=0 ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
                                        call matProcGuia(pult("id"), ConvenioID)
                                    end if
                                end if


                                '-> materiais deste procedimento nesta guia
        '						set vDesp = db.execute("select pp.id as ppid, pp.*, pv.*, pt.*, p.CD, p.NomeProduto, p.RegistroANVISA, p.AutorizacaoEmpresa, p.ApresentacaoUnidade, p.Codigo as CodigoNoFabricante from tissprodutosprocedimentos as pp left join tissprodutosvalores as pv on pv.id=pp.ProdutoValorID left join tissprodutostabela as pt on pt.id=pv.ProdutoTabelaID left join produtos as p on p.id=pt.ProdutoID left join tissprocedimentosvalores as procval on procval.id=pp.AssociacaoID where procval.ConvenioID like '"&ConvenioID&"' and procval.ProcedimentoID like '"&ProcedimentoID&"'")
        '						while not vDesp.eof
        '							Valor = vDesp("Valor")
        '							if isnull(Valor) then Valor=0 end if
        '							Quantidade = vDesp("Quantidade")
        '							if isnull(Quantidade) then Quantidade=1 end if
        '							ValorTotal = Quantidade*Valor
        '							if not isnull(vDesp("ProdutoID")) then
        '								db_execute("insert into tissguiaanexa (GuiaID, CD, Data, ProdutoID, TabelaProdutoID, CodigoProduto, Quantidade, UnidadeMedidaID, Fator, ValorUnitario, ValorTotal, RegistroANVISA, CodigoNoFabricante, AutorizacaoEmpresa, Descricao) values ("&reg("id")&", "&treatvalzero(vDesp("CD"))&", "&DataAtendimento&", "&treatvalzero(vDesp("ProdutoID"))&", "&treatvalzero(vDesp("TabelaID"))&", '"&vDesp("Codigo")&"', "&treatvalzero(Quantidade)&", "&treatvalzero(vDesp("ApresentacaoUnidade"))&", '1', "&treatvalzero(Valor)&", "&treatvalzero(ValorTotal)&", '"&vDesp("RegistroANVISA")&"', '"&vDesp("CodigoNoFabricante")&"', '"&vDesp("AutorizacaoEmpresa")&"', '"&rep(vDesp("NomeProduto"))&"')")
        '							end if
        '						vDesp.movenext
        '						wend
        '						vDesp.close
        '						set vDesp=nothing
                                '<- materiais deste procedimento nesta guia
        '						db_execute("update tissguiasadt set "&_
        '						"Procedimentos=(select sum(ValorTotal) from tissprocedimentossadt where GuiaID="&reg("id")&"),"&_
        '						"GasesMedicinais=(select sum(ValorTotal) from tissguiaanexa where CD=1 and GuiaID="&reg("id")&"), "&_
        '						"Medicamentos=(select sum(ValorTotal) from tissguiaanexa where CD=2 and GuiaID="&reg("id")&"), "&_
        '						"Materiais=(select sum(ValorTotal) from tissguiaanexa where CD=3 and GuiaID="&reg("id")&"), "&_
        '						"TaxasEAlugueis=(select sum(ValorTotal) from tissguiaanexa where CD=7 and GuiaID="&reg("id")&"), "&_
        '						"OPME=(select sum(ValorTotal) from tissguiaanexa where CD=8 and GuiaID="&reg("id")&") "&_
        '						"where id="&reg("id"))


                            ProcedimentosSQL.movenext
    						wend
    						ProcedimentosSQL.close
    						set ProcedimentosSQL=nothing

					    end if
				    end if
				    AtendimentoRN = "N"
				    IndicacaoAcidenteID = 9
				    GrauParticipacaoID = 12
				    'dados do profissional
				    ProfissionalSolicitanteID = aEa("ProfissionalID")
				    set prof = db.execute("select p.*, e.* from profissionais as p left join especialidades as e on p.EspecialidadeID=e.id where p.id="&ProfissionalID)
				    if not prof.eof then
					    ConselhoProfissionalSolicitanteID = prof("Conselho")
                                            'response.Write("{{{"&ConselhoProfissionalSolicitanteID&"}}}")
					    NumeroNoConselhoSolicitante = prof("DocumentoConselho")
					    UFConselhoSolicitante = prof("UFConselho")
					    CodigoCBOSolicitante = prof("codigoTISS")
					    CPF = trim( replace(replace(prof("CPF")&" ", ".", ""), "-","") )
					    GrauParticipacaoID = prof("GrauPadrao")
				    end if
				    if EspecialidadeID&""<>"" AND EspecialidadeID<>0  then
                        set profEsp = db.execute("SELECT profEsp.ProfissionalID, profEsp.EspecialidadeID, profEsp.RQE, profEsp.Conselho, profEsp.UFConselho, profEsp.DocumentoConselho, esp.codigoTISS FROM profissionais p "&_
                                                 "LEFT JOIN (SELECT ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionaisespecialidades "&_
                                                 "UNION ALL  "&_
                                                 "SELECT  id ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionais) profEsp ON profEsp.ProfissionalID=p.id "&_
                                                 "LEFT JOIN especialidades esp ON esp.id=profEsp.EspecialidadeID "&_
                                                 "WHERE p.id="&ProfissionalSolicitanteID&" AND profEsp.EspecialidadeID="&EspecialidadeID)
                        if not profEsp.eof then
                            ConselhoProfissionalSolicitanteID = profEsp("Conselho")
                            NumeroNoConselhoSolicitante = profEsp("DocumentoConselho")
                            UFConselhoSolicitante = profEsp("UFConselho")
                            CodigoCBOSolicitante = profEsp("codigoTISS")
                        end if
				    end if
				    if GrauParticipacaoID&""="" then
				        GrauParticipacaoID = 12
				    end if
				    'verifica se nesta guia já consta este profissional
				    set vcaProf = db.execute("select * from tissprofissionaissadt where GuiaID="&reg("id")&" and ProfissionalID="&ProfissionalID)
				    if vcaProf.eof then
                        if ProfissionalID&"" <> "" and ProfissionalID&"" <> "0" then
					    'response.Write("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&reg("id")&", 1, 1, "&ProfissionalID&", '"&CPF&"', '"&ConselhoProfissionalSolicitanteID&"', '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&session("User")&")")
					    sqlExecute = "insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&reg("id")&", 1, "&GrauParticipacaoID&", "&ProfissionalID&", '"&CPF&"', "&treatvalnull(ConselhoProfissionalSolicitanteID)&", '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&session("User")&")"
				        db_execute(sqlExecute)
                        end if 
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
                end if
			next
			set guia = db.execute("select * from tissguiasadt where id="&reg("id"))
			sqlExecute = "update tissguiasadt set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&reg("id")
			db_execute(sqlExecute)
		end if
    else
        if ConvenioID<> "" then
            set conv = db.execute("select RepetirNumeroOperadora,NaoPermitirAlteracaoDoNumeroNoPrestador,coalesce(MinimoDigitos,0) as MinimoDigitos,coalesce(MaximoDigitos,0) as MaximoDigitos  from convenios c where c.id="&ConvenioID)
            if not conv.eof then
                MinimoDigitos = conv("MinimoDigitos")
                MaximoDigitos = conv("MaximoDigitos")

                if conv("NaoPermitirAlteracaoDoNumeroNoPrestador")=1 then
                    %>
                    <script >
                    $(document).ready(function(){
                        $('#NGuiaPrestador').attr("readonly", true);
                    })
                    </script>
                    <%
                end if
                if conv("RepetirNumeroOperadora")=1 then
                    %>
                    <script >
                    $(document).ready(function(){
                        $("#NGuiaOperadora").keyup(function(){
                            $('#NGuiaPrestador').val( $(this).val() );

                        });
                    })
                    </script>
                    <%
                end if
            end if
        end if
	end if
	if reg("sysActive")=0 and isnumeric(ConvenioID) then
        NGuiaPrestador = numeroDisponivel(ConvenioID)
	end if
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Guia de SP/SADT");
    $(".crumb-icon a span").attr("class", "fa fa-credit-card");
</script>
<style>
.select2-container{
width: 100%!important;
}

#qfdatavalidadesenha, #qfdataautorizacao{
min-width: 150px;
}
.input-mask-date {
    padding: 5px !important;
}
</style>

<style>
  .table-absolute{
    padding: 10px;
    background: #ffffff;
    border: #dfdfdf 1px solid;
    border-radius: 10px;
    position: absolute;
    z-index: 1000;
  }

  #ConvenioMateriaisProcedimentos .table-absolute{
        right:0px;
  }

  .table-absolute-content{
      overflow:   auto;
      max-width:  700px;
      width:      700px;
      max-height: 200px;
  }
</style>
<form id="GuiaSADT" action="" method="post" >
            <div class="row">
	            <div class="col-md-10">
                <%
                set vcaCont = db.execute("select id, NomeModelo from contratosmodelos where sysActive=1")
                if not vcaCont.eof then
                    %>
                    <label>&nbsp;</label><br />
                    <div class='btn-group pull-right'><button class='btn btn-info dropdown-toggle' data-toggle='dropdown' title='Adicionar Contrato'><i class='fa fa-file'></i></button>
                    <ul class='dropdown-menu dropdown-info pull-right'>
                    <%
                    while not vcaCont.eof
                        %>
                        <li><a href='javascript:addContrato(<%=vcaCont("id")%>, <%=req("I")%>, $("#AccountID").val())'><i class='fa fa-plus'></i> <%=vcaCont("NomeModelo")%></a></li>
                        <%
                    vcaCont.movenext
                    wend
                    vcaCont.close
                    set vcaCont=nothing
                    %>
                    </ul></div>
                    <%
                end if
                %>
                </div>
                <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
            </div>
<br />
<div class="admin-form theme-primary">
   <div class="panel heading-border panel-primary">
        <div class="panel-body">

            <input type="hidden" name="tipo" value="GuiaSADT" />
            <input type="hidden" name="GuiaID" value="<%=req("I")%>" />

            <div class="section-divider mt20 mb40">
                <span> Dados do Benefici&aacute;rio </span>
            </div>

            <div class="row">
                <div class="col-md-3"><%= selectInsert("* Nome  <button onclick=""if($('#gPacienteID').val()==''){alert('Selecione um paciente')}else{window.open('./?P=Pacientes&Pers=1&I='+$('#gPacienteID').val())}"" class='btn btn-xs btn-default' type='button'><i class='fa fa-external-link'></i></button>", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""tissCompletaDados(1, this.value);""", "required", "") %></div>
                <%= quickField("simpleSelect", "gConvenioID", "* Conv&ecirc;nio", 2, ConvenioID, "select * from Convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
                <div class="col-md-2" id="tissplanosguia"><!--#include file="tissplanosguia.asp"--></div>
                <%
                pattern = ""
                if MaximoDigitos&"" <> "" then
                    pattern= "'.{"&MinimoDigitos&","&MaximoDigitos&"}'"
                end if
                %>
                <%= quickField("text", "NumeroCarteira", "* N&deg; da Carteira", 2, NumeroCarteira, " lt", "", " required""  autocomplete='matricula' required "&pattern&" title=""O padrão da matrícula deste convênio está configurado para 10 caracteres""") %>
                <%= quickField("datepicker", "ValidadeCarteira", "Data Validade da Carteira", 2, ValidadeCarteira, " input-mask-date ", "", "") %>
                <%= quickField("text", "RegistroANS", "* Reg. ANS", 1, RegistroANS, "", "", " required") %>
            </div>
            <br />
            <div class="row">
                <%= quickField("datepicker", "DataAutorizacao", "Data da Autoriza&ccedil;&atilde;o", 1, DataAutorizacao, "", "", "") %>
                <%= quickField("text", "Senha", "Senha", 2, Senha, "", "", "") %>
                <%= quickField("datepicker", "DataValidadeSenha", "Validade da Senha", 1, DataValidadeSenha, "", "", "") %>
                <%= quickField("text", "NGuiaPrestador", "* N&deg; da Guia no Prestador", 2, NGuiaPrestador, "", "", " autocomplete='nro-prestador' required") %>
                <%
                if RepetirNumeroOperadora=1 then
                    fcnRepetirNumeroOperadora = " onkeyup=""$('#NGuiaPrestador').val( $(this).val() )"" "
                end if
                %>
                <%= quickField("text", "NGuiaOperadora", "N&deg; da Guia na Operadora", 2, NGuiaOperadora, "", "", fcnRepetirNumeroOperadora) %>
                <%= quickField("text", "NGuiaPrincipal", "N&deg; da Guia Principal", 2, NGuiaPrincipal, "", "", "") %>
                <%= quickField("text", "CNS", "CNS", 1, CNS, "", "", "") %>
            </div>

            <% if AutorizadorTiss then %>
            <div class="row">
                <%= quickField("text", "IdentificadorBeneficiario", "Identificador - código de barras da carteira", 12, identificadorBeneficiario, "", "", "") %>
            </div>
            <% end if %>


            <br />
            <div class="section-divider mt20 mb40">
                <span> Dados da Solicitação </span>
            </div>

            <div class="row">
	            <div class="col-md-3">
    	            <label>Contratado Solicitante</label>
        	            <span class="pull-right">
                        <label><input type="radio" name="tipoContratadoSolicitante" id="tipoContratadoSolicitanteI" value="I"<% If tipoContratadoSolicitante="I" Then %> checked="checked"<% End If %> class="ace" onclick="tc('I');" /> <span class="lbl">Interno</span></label>
                        <label><input type="radio" name="tipoContratadoSolicitante" id="tipoContratadoSolicitanteE" value="E"<% If tipoContratadoSolicitante="E" Then %> checked="checked"<% End If %> class="ace" onclick="tc('E');" /> <span class="lbl">Externo</span></label>
                        </span>
                    <br />
                    <span id="spanContratadoI"<%if tipoContratadoSolicitante="E" then%> style="display:none"<% End If %>>
			            <%= quickField("contratado", "ContratadoSolicitanteID", "", 12, ContratadoSolicitanteID, "", "", " required") %>
                    </span>
                    <span id="spanContratadoE"<%if tipoContratadoSolicitante="I" then%> style="display:none"<% End If %>>
			            <%= selectInsert("", "ContratadoExternoID", ContratadoSolicitanteID, "contratadoexterno", "NomeContratado", " onchange=""tissCompletaDados(7, this.value);""", "", "") %>
                    </span>
                </div>
                <%= quickField("text", "ContratadoSolicitanteCodigoNaOperadora", "C&oacute;digo na Operadora", 2, ContratadoSolicitanteCodigoNaOperadora, "", "", " autocomplete='codigo-na-operadora' ") %>
                <%= quickField("datepicker", "DataSolicitacao", "Data da Solicita&ccedil;&atilde;o", 2, DataSolicitacao, "", "", " required") %>
                <%= quickField("text", "IndicacaoClinica", "Indica&ccedil;&atilde;o Cl&iacute;nica", 5, IndicacaoClinica, "", "", "") %>
            </div>

            <br />
            <%
                if not isnull(ConselhoProfissionalSolicitanteID) and ConselhoProfissionalSolicitanteID<>"" and isnumeric(ConselhoProfissionalSolicitanteID) then
                    ConselhoProfissionalSolicitanteID=cint(ConselhoProfissionalSolicitanteID)
                end if
            %>

            <div class="row">
                <div class="col-md-3">
                    <label>Profissional Solicitante <% if getConfig("OcultarSolicitanteInterno") = 1 then%> (EXTERNO) <% end if %></label>
                        <span class="pull-right">
                        <% if getConfig("OcultarSolicitanteInterno") = 1 then%>
                            <input type="hidden" name="tipoProfissionalSolicitante" value="E">
                        <% else %>
                            <label><input type="radio" name="tipoProfissionalSolicitante" id="tipoProfissionalSolicitanteI" value="I"<% If tipoProfissionalSolicitante="I" Then %> checked="checked"<% End If %> class="ace" onclick="tps('I');" /> <span class="lbl">Interno</span></label>
                            <label><input type="radio" name="tipoProfissionalSolicitante" id="tipoProfissionalSolicitanteE" value="E"<% If tipoProfissionalSolicitante="E" Then %> checked="checked"<% End If %> class="ace" onclick="tps('E');" /> <span class="lbl">Externo</span></label>
                        <% end if %>
                        </span>
                    <br />
                    <span id="spanProfissionalSolicitanteI"<%if tipoProfissionalSolicitante="E" then%> style="display:none"<% End If %>>
                    <%= quickField("simpleSelect", "ProfissionalSolicitanteID", "", 12, ProfissionalSolicitanteID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('ProfissionalSolicitante', this.value);"" empty=''") %>
                    </span>
                    <span id="spanProfissionalSolicitanteE"<%if tipoProfissionalSolicitante="I" then%> style="display:none"<% End If %>>
                        <%= selectInsert("", "ProfissionalSolicitanteExternoID", ProfissionalSolicitanteID, "profissionalexterno", "NomeProfissional", " onchange=""tissCompletaDados(8, this.value);""", "", "") %>
                    </span>
                </div>
                <%= quickField("simpleSelect", "ConselhoProfissionalSolicitanteID", "* Conselho Profissional", 2, ConselhoProfissionalSolicitanteID, "select * from conselhosprofissionais order by descricao", "descricao", " empty='' required='required' no-select2") %>
                <%= quickField("text", "NumeroNoConselhoSolicitante", "* N&deg; no Conselho", 2, NumeroNoConselhoSolicitante, "", "", " empty='' required='required' autocomplete='numero-conselho'") %>
                <%= quickField("text", "UFConselhoSolicitante", "* UF", 1, UFConselhoSolicitante, "", "", " empty='' required='required' pattern='[A-Za-z]{2}'") %>
                <%
                   ' quickField("text", "CodigoCBOSolicitante", "* C&oacute;digo CBO", 2, CodigoCBOSolicitante, "", "", " empty='' required='required' pattern='[0-9-]{6,7}' autocomplete='cbos' ")
        		    call quickField("simpleSelect", "CodigoCBOSolicitante", "* C&oacute;digo CBO", 4, CodigoCBOSolicitante, "select * from (select e.codigoTiss as id, concat( e.codigoTiss,' - ',e.especialidade) as Nome from especialidades as e where e.codigoTiss<>'' and e.codigoTiss is not null order by id)t", "Nome", "empty='' required='required' ")
                %>
            </div>
            <br />
            <div class="section-divider mt20 mb40">
                <span> Dados da Execução </span>
            </div>
            <div class="row">
                <div class="col-md-3" id="divContratado"><% server.Execute("listaContratado.asp") %></div>
                <%= quickField("text", "CodigoNaOperadora", "* C&oacute;digo na Operadora", 2, CodigoNaOperadora, "", "", "") %>
                <%= quickField("text", "CodigoCNES", "* C&oacute;digo CNES", 2, CodigoCNES, "", "", " pattern='[0-9]{7}'") %>
            </div>
            <br />
            <div class="row">
                <%= quickField("simpleSelect", "TipoAtendimentoID", "* Tipo de Atendimento", 2, TipoAtendimentoID, "select * from tisstipoatendimento order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "AtendimentoRN", "* Atendimento RN", 2, AtendimentoRN, "select 'S' id, 'Sim' SN UNION ALL select 'N', 'Não'", "SN", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "IndicacaoAcidenteID", "* Indica&ccedil;&atilde;o de acidente", 2, IndicacaoAcidenteID, "select * from tissindicacaoacidente order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "TipoConsultaID", "* Tipo de Consulta", 2, TipoConsultaID, "select * from tisstipoconsulta order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "CaraterAtendimentoID", "* Car&aacute;ter do Atendimento", 2, CaraterAtendimentoID, "select * from cliniccentral.tisscarateratendimento order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "MotivoEncerramentoID", "Motivo de Encerramento", 2, MotivoEncerramentoID, "select * from tissmotivoencerramento order by descricao", "descricao", " no-select2 ") %>
            </div>
            <br />
            <div class="section-divider mt20 mb40">
                <span> Procedimentos e Exames Realizados </span>
            </div>
            <div class="row">
                <div class="col-md-12" id="tissprocedimentossadt">
                    <%server.Execute("tissprocedimentossadt.asp")%>
                </div>
            </div>
            <h5 class="page-header blue">Indica&ccedil;&atilde;o do(s) Prossional(is) Executante(s)</h5>
            <div class="row">
                <div class="col-md-12" id="tissprofissionaissadt">
                    <%server.Execute("tissprofissionaissadt.asp")%>
                </div>
            </div>

            <h5 class="page-header blue">Adicionar Itens para Gera&ccedil;&atilde;o da Guia Anexa de Outras Despesas</h5>
            <div class="row">
                <div class="col-md-12" id="tissoutrasdespesas">
                    <%server.Execute("tissoutrasdespesas.asp")%>
                </div>
            </div>
            <div class="section-divider mt20 mb40">
                <span> Data de Realiza&ccedil;&atilde;o de Procedimentos em S&eacute;rie </span>
            </div>

            <div class="row">
                <div class="col-md-10">
                    <div class="row">
    	                <%= quickField("datepicker", "DataSerie01", "01", 2, reg("DataSerie01"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie02", "02", 2, reg("DataSerie02"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie03", "03", 2, reg("DataSerie03"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie04", "04", 2, reg("DataSerie04"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie05", "05", 2, reg("DataSerie05"), "", "", "") %>
                    </div>
                    <div class="row">
    	                <%= quickField("datepicker", "DataSerie06", "06", 2, reg("DataSerie06"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie07", "07", 2, reg("DataSerie07"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie08", "08", 2, reg("DataSerie08"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie09", "09", 2, reg("DataSerie09"), "", "", "") %>
    	                <%= quickField("datepicker", "DataSerie10", "10", 2, reg("DataSerie10"), "", "", "") %>
                    </div>
                </div>
                <div class="col-md-2">
                    <div class="row">
                        <%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, Observacoes, "", "", "") %>
                    </div>
                </div>
            </div>


            <br />
            <div class="row">
                <div class="col-md-12">

                    <table class="" style="width: 100%">
                        <tr>
    	                    <td id="divTotais">
                                <%server.Execute("tissRecalcGuiaSADT.asp")%>
                            </td>
                        </tr>
	                </table>
                </div>
            </div>
        <% if sysActive=1 then response.write("<hr class='short alt'> Inserida por "& nameInTable(sysUser) &" em "& sysDate) end if %>

        </div>
    </div>


</div>



<div class="clearfix form-actions no-margin">
    <button class="btn btn-primary btn-md" id="btnSalvar" onclick="isSolicitar = false;" ><i class="fa fa-save"></i> Salvar</button>
    <button type="button" class="btn btn-md btn-default pull-right" onclick="guiaTISSPrint()"><i class="fa fa-file"></i> Imprimir Guia em Branco</button>
    <button type="button" class="btn btn-md btn-primary mr5 pull-right" id="imprimirGuia" onclick="imprimirGuiaSADT()"><i class="fa fa-file"></i> Imprimir Guia</button>
    <%if AutorizadorTiss then %>
                  <button type="button" onclick="AutorizarGuiaTisss();" class="btn btn-warning btn-md feegow-autorizador-tiss-method" data-method="autorizar"><i class="fa fa-expand"></i> Solicitar</button>
                  <button type="button" onclick="Autorizador.cancelarGuia(1)" class="btn btn-danger btn-md feegow-autorizador-tiss-method" data-method="cancelar"><i class="fa fa-times"></i> Cancelar guia</button>
                  <button type="button" onclick="Autorizador.verificarStatusGuia(1)" class="btn btn-default btn-md feegow-autorizador-tiss-method" data-method="status"><i class="fa fa-search"></i> Verificar status</button>
    <%end if %>
</div>
	</form>
<br />
<br />
<!-- modificado por André Souza em 19/09/2019 (id da tarefa: 723) -->
<!--<script type="text/javascript" src="/feegow_components/assets/modules-assets/autorizador-tiss/js/autorizador-tiss.js"></script>-->
<script type="text/javascript" src="js/autorizador-tiss.js"></script>

<script type="text/javascript">

    function selecionarConselho(Conselho,Estado,Nome,IdProfissional,EspecialidadeID){

    if(IdProfissional){
       	$("#ProfissionalSolicitanteExternoID").append(`<option value="${IdProfissional}">${Nome}</option>`)
        $("#ProfissionalSolicitanteExternoID").val(IdProfissional).trigger("change");
        return;
    }

     $.post("TabelaProfissionais.asp",  { Conselho, Estado,Nome,EspecialidadeID }, function(data){
         let temp1 = JSON.parse(data);
         if(temp1.length > 0){
         	temp1 = temp1[0]
         	$("#ProfissionalSolicitanteExternoID").append(`<option value="${temp1.id}">${temp1.NomeProfissional}</option>`)
         }
         setTimeout(() => {
            $("#ProfissionalSolicitanteExternoID").val(temp1.id).trigger("change");
            $("#CodigoCBOSolicitante").val("9999999");
         },500);
    })
}

let dentro = false;

$(function() {
       document.addEventListener("click", () => {
           if(!dentro)
           {
               $(".table-absolute").remove();
           }
       }, true);

       $("input").attr("autocomplete","off");

       document.addEventListener("keyup", (arg) => {
            $("input").attr("autocomplete","off");
            let id = arg.target.id;

            if(!(id.indexOf("NumeroNoConselhoSolicitante") !== -1)){
                return false;
            }
            <% IF getConfig("OcultarSolicitanteInterno") <> "1" THEN %>
            if(!$("#tipoProfissionalSolicitanteE").is(":checked")){
                return false;
            }
            <% END IF %>


            idAnexo = null;

           let componentCodigo         = $(arg.target);
           let Codigo                  = $(arg.target).val();

           if(Codigo){
               fetch(`TabelaProfissionais.asp?Codigo=${Codigo}`)
               .then((data)=>{
                    return data.json();
               }).then((json) => {
                   $(".table-absolute").remove();

                   if(!(json && json.length > 0)){
                      return ;
                   }
                   sugestoes = json;

                   let linhas = json.map((j) => {
                       return `<tr>
                                    <td>${j.Nome}</td>
                                    <td>${j.Conselho}</td>
                                    <td>${j.Estado}</td>
                                    <td>
                                        <button type="button" class="btn btn-sm btn-success" onclick="selecionarConselho('${j.Conselho}','${j.Estado}','${j.Nome}','${j.idProfissional}','${j.EspecialidadeID}')">Selecionar</button>
                                    </td>
                               </tr>`
                   });

                   let linhasstr = linhas.join(" ");

                   let html = `<div class="table-absolute">
                                    <div class="table-absolute-content">
                                        <table class="table table-bordered table-striped">

                                            <tbody>
                                            ${linhasstr}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>`;

                   $(arg.target).parent().append(html);

                   $( ".table-absolute" )
                   .mouseenter(function() {
                       dentro = true;
                   })
                   .mouseleave(function() {
                       dentro = false;
                   });
               });
           }
       }, true);
    });


<%if AutorizadorTiss then %>
if(typeof AutorizadorTiss === "function"){
    var Autorizador = new AutorizadorTiss();
    Autorizador.userId = "<%=session("User")%>";
    Autorizador.guideId = "<%=req("I")%>";
    Autorizador.sadt = true;
}
<%end if %>

$(document).ready(function() {
    <%if AutorizadorTiss then %>
    Autorizador.bloqueiaBotoes(1);
    <%
    end if
    %>
  <%
  if aut("|guiasA|")=1 then

  set GuiaStatusSQL = db.execute("SELECT * FROM cliniccentral.tissguiastatus order by id")

  Status = "<select id='GuiaStatus' name='GuiaStatus' class='form-control input-sm'>"
  while not GuiaStatusSQL.eof
      CheckedStatus = ""
      if GuiaStatusSQL("id")=StatusGuia then
          CheckedStatus = " selected "
      end if
      Status = Status&"<option "&CheckedStatus&"  value='"&GuiaStatusSQL("id")&"'>"&GuiaStatusSQL("Status")&"</option>"
  GuiaStatusSQL.movenext
  wend
  GuiaStatusSQL.close
  set GuiaStatusSQL = nothing
  Status = Status&"</select>"
  %>
      $("#rbtns").html("<%=Status%>");

      $("select[name='GuiaStatus']").change(function(data) {
          $.get("AlteraStatusGuia.asp", {GuiaID:"<%=req("I")%>", TipoGuia:$("input[name='tipo']").val(), Status: $(this).val()}, function() {

          })
      });

  <%
  end if
  %>
});

function ExibeHistoricoSADT(GuiaID) {
     openComponentsModal("HistoricoGuiaSADT.asp", {
            GuiaID: GuiaID
        }, "Histórico de alterações", true);
}

function tissCompletaDados(T, I){

	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T,
		data:$("#GuiaSADT").serialize(),
		success:function(data){
			eval(data);
			var convenio = $("#gConvenioID").val();
            $.get(
                'CamposObrigatoriosConvenio.asp?ConvenioID=' + convenio,
                function(data){
                    eval(data)
                }
            );
		}
	});
}

$("#gConvenioID, #UnidadeID").change(function(){
    tissCompletaDados("Convenio", $("#gConvenioID").val());
});

$("#Contratado, #UnidadeID").change(function(){
    //	    alert(1);
    tissCompletaDados("Contratado", $(this).val());
});

$("#ContratadoSolicitanteID").change(function(){
    tissCompletaDados("ContratadoSolicitante", $(this).val());
});

var isSolicitar = false;
$("#GuiaSADT").submit(function(){
    var $plano = $("#PlanoID"),
        planoId = $plano.val();

    if(planoId=='0' && $plano.attr("required") === "required"){
        showMessageDialog("Preencha o plano", "danger");
        return false;
    }

    setTimeout(() => {
        
        let isRedirect = "";
        if(isSolicitar)
            isRedirect="S";

        $.ajax({
            type:"POST",
            url:"SaveGuiaSADT.asp?Tipo=SADT&I=<%=request.QueryString("I")%>"+"&close=<%=close%>&isRedirect="+isRedirect,
            data:$("#GuiaSADT").serialize(),
            success:function(data){
                let result = eval(data);
                
                if(isSolicitar && !data.includes("ERRO")){
                    Autorizador.autorizaProcedimentos();
                }
                isSolicitar = false;
            },
            error:function(data){
                alert("error ao salvar")
                //eval(data);
            }
        });
    }, 120);
	return false;
});

function AutorizarGuiaTisss()
{
    $("#btnSalvar").click();
    setTimeout(() => {
        isSolicitar = true;
    }, 50);
}


function guiaTISSPrint() {
    var convenioSelecionado = $('#gConvenioID').select2('data')[0].id;
    convenioSelecionadoTratado = ((convenioSelecionado != undefined && convenioSelecionado != "") ? convenioSelecionado : undefined)
    guiaTISS('GuiaSADT', 0,  convenioSelecionadoTratado)
}

function guiaPrint(){

}
/*
	function itemSADT(T, I, II){
	    $("#modal-table").modal('show');
	    $.ajax({
	        type:"POST",
	        url:"modalSADT.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#GuiaSADT").serialize(),
	        success:function(data){
	            $("#modal").html(data);
	        }
	    });
	}

function itemSADT(T, I, II){
	$("#pagar").fadeIn();
	$.ajax({
	    type:"POST",
	    url:"modalSADT.asp?T="+T+"&I="+I+"&II="+II,
	    data:$("#GuiaSADT").serialize(),
	    success:function(data){
	        $("#pagar").html(data);
	    }
	});
}*/

function itemSADT(T, I, II, A){
//    $("[id^="+T+"]").fadeOut();
    $("[id^="+T+"]").html('');
//    $("[id^=l"+T+"]").fadeIn();
    if(A!='Cancela'){
//	    $("#l"+T+II).fadeOut();
        $("#"+T+II).removeClass('hidden');
//	    $("#"+T+II).html("Carregando...");
	    $.ajax({
	        type:"POST",
	        url:"modalSADT.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#GuiaSADT").serialize(),
	        success:function(data){
                $("#"+T+II).fadeIn();
                $("#"+T+II).html(data);
	            $("#Fator").trigger("keyup")
	        }
	    });
	}
}

function atualizaTabela(D, U){
	$.ajax({
	   type:"GET",
	   url:U,
	   success:function(data){
		   $("#"+D).html(data);
		   tissRecalcGuiaSADT('Recalc');
	   }
   });
}


function tissplanosguia(ConvenioID){
	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?PlanoID=<%=PlanoID %>&ConvenioID="+ConvenioID,
		data:$("#GuiaSADT").serialize(),
		success: function(data){
			$("#tissplanosguia").html(data);
		}
	});
}

function tissRecalcGuiaSADT(Action){
	$.ajax({
		type:"POST",
		url:"tissRecalcGuiaSADT.asp?I=<%=request.QueryString("I")%>&Action="+Action,
		data:$("#GuiaSADT").serialize(),
		success: function(data){
			$("#divTotais").html(data);
		}
	});
}

function autorizaProcedimentos(procID){
    $(".btn-warning [data-value="+procID+"]").prop('disabled',true);
    $.post("feegow_components/autorizador_tiss/solicitarSADT?I=<%=req("I")%>&U=<%=session("User")%>", $("#GuiaSADT").serialize() + "&procID="+procID+"&db=<%=session("Banco")%>" + "&ContratadoSolicitante="+$("#ContratadoSolicitanteID option:selected").text() + "&ProfissionalSolicitante=" + $("#ProfissionalSolicitanteID option:selected").text() + "&ContratadoExecutante=" + $("#Contratado option:selected").text(), function(data){
        //    eval(data);
        data = JSON.parse(data);
        if(data.response == '1'){
            $(".btn-warning [data-value="+procID+"]").prop('disabled',false);
            alert('Autorizado');
        }else{
            alert('Glosado');
        }
    });
}

function tc(T){
	if(T=="I"){
		$("#spanContratadoE").css("display", "none");
		$("#spanContratadoI").css("display", "block");
	}else{
		$("#spanContratadoE").css("display", "block");
		$("#spanContratadoI").css("display", "none");
	}
}
function tps(T){
	if(T=="I"){
		$("#spanProfissionalSolicitanteE").css("display", "none");
		$("#spanProfissionalSolicitanteI").css("display", "block");
	}else{
		$("#spanProfissionalSolicitanteE").css("display", "block");
		$("#spanProfissionalSolicitanteI").css("display", "none");
	}
}

<%if trocaConvenioID<>"" then%>
    $("#gConvenioID").val("<%=trocaConvenioID%>");
tissCompletaDados("Convenio", $("#gConvenioID").val());
<%end if%>

$('#IdentificadorBeneficiario').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        return false;
    }
});

function addContrato(ModeloID, InvoiceID, ContaID){
    if($("#gPacienteID").val()==""){
        alert("Selecione um paciente.");
        $("#gPacienteID").focus();
    }else{
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.post("addContrato.asp?Tipo=SADT&ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID=3_"+$("#gPacienteID").val(), "", function(data){
            $("#modal").html(data);
        });
    }
}

function imprimirGuiaSADT(){

    $.ajax({
    		type:"POST",
    		url:"SaveGuiaSADT.asp?Tipo=SADT&I=<%=request.QueryString("I")%>"+"&close=<%=close%>&isRedirect=S",
    		data:$("#GuiaSADT").serialize(),
    		success:function(data){
    			guiaTISS('GuiaSADT', <%=request.QueryString("I")%> , $("#gConvenioID").val())
    		},
    		error:function(data){
                alert("Preencha todos os campos obrigatórios")
            }
    	});
}
function formatCBOGroup(especialidades, $el)
{
    let $cont = $($el);

    if($cont.is("select")){
        $cont.children().remove("optgroup");
        if (typeof especialidades !== 'undefined' && especialidades.length > 0) {
            let grupo = "<optgroup label='Especialidades do profissional'>";
            let option  = "";

            $cont.children().each((idx, el) => {
                if($.inArray(parseInt(el.value), especialidades)!=-1){
                    option += el.outerHTML ;
                }
            });
            if(option!==""){
                grupo += option+ "</optgroup><optgroup label='Outas especialidades'>"
            }
            $cont.prepend(grupo);
            $cont.append("</optgroup>");
        }
    }
}

<%
if drCD<>"" then
    response.write(drCD)
end if
    %>

<!--#include file="JQueryFunctions.asp"-->
</script>