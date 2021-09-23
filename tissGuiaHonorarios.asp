<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<%posModalPagar="fixed" %>
<!--#include file="invoiceEstilo.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

if not reg.eof then
	if reg("sysActive")=1 then
		DataEmissao = reg("DataEmissao")
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
    	Procedimentos = reg("Procedimentos")
	else
		DataEmissao = date()
		sqlExecute = "delete from tissprocedimentoshonorarios where GuiaID="&reg("id")
        db_execute(sqlExecute)

		sqlExecute = "delete from tissprofissionaishonorarios where GuiaID="&reg("id")
        db_execute(sqlExecute)
'		set procs = db.execute("select id from tissprocedimentoshonorarios where GuiaID="&reg("id"))
'		while not procs.eof
'			db_execute("delete from rateiorateios rr where rr.Temp=1 and ItemGuiaID="&procs("id"))
'		procs.movenext
'		wend
'		procs.movenext
'		set procs=nothing
		sqlExecute = "update tissguiahonorarios set Procedimentos=0 where id="&reg("id")
		db_execute(sqlExecute)
		if cdate(formatdatetime(reg("sysDate"),2))<date() then
			sqlExecute = "update tissguiahonorarios set sysDate=NOW() where id="&reg("id")
            db_execute(sqlExecute)
		end if
		UnidadeID = session("UnidadeID")
        Procedimentos = 0
	end if

	TotalProcedimentos = 0

	PacienteID = reg("PacienteID")
	CNS = reg("CNS")
	ConvenioID = reg("ConvenioID")
	PlanoID = reg("PlanoID")
	RegistroANS = reg("RegistroANS")
	NGuiaPrestador = reg("NGuiaPrestador")
	NGuiaOperadora = reg("NGuiaOperadora")
	Senha = reg("Senha")
	NumeroCarteira = reg("NumeroCarteira")
	AtendimentoRN = reg("AtendimentoRN")
	AtendimentoRN = reg("AtendimentoRN")
	NGuiaSolicitacaoInternacao = reg("NGuiaSolicitacaoInternacao")
    Contratado = reg("Contratado")
	CodigoNaOperadora = reg("CodigoNaOperadora")
	CodigoCNES = reg("CodigoCNES")
	ContratadoLocalCodigoNaOperadora = reg("ContratadoLocalCodigoNaOperadora")
	ContratadoLocalNome = reg("ContratadoLocalNome")
	LocalExternoID = reg("LocalExternoID")
	ContratadoLocalCNES = reg("ContratadoLocalCNES")
	DataInicioFaturamento = reg("DataInicioFaturamento")
	DataFimFaturamento = reg("DataFimFaturamento")
	Observacoes = reg("Observacoes")
    DataEmissao = reg("DataEmissao")
	Procedimentos = reg("Procedimentos")
	TotalProcedimentos = Procedimentos
	'identificadorBeneficiario = reg("identificadorBeneficiario")


	if reg("sysActive")=0 and isnumeric(ConvenioID) then
		set maiorGuia = db.execute("select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from tissguiahonorarios where not isnull(NGuiaPrestador) and NGuiaPrestador>0 and ConvenioID like '"&ConvenioID&"' order by cast(NGuiaPrestador as signed integer) desc limit 1")
		if maiorGuia.eof then
			NGuiaPrestador = 1
		else
			if not isnull(maiorGuia("NGuiaPrestador")) then
				'if len(NGuiaPrestador)<10 then
					NGuiaPrestador = maiorGuia("NGuiaPrestador")
				'else
				'	NGuiaPrestador = ""
				'end if
			else
				NGuiaPrestador = 1
			end if
		end if
	end if

	'Auto-preenche a guia baseado no lancto
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
                                set ProcedimentosSQL = db.execute("SELECT a.TipoCompromissoID from agendamentos a where a.id like '"&splAEA(0)&"' UNION ALL select ap.TipoCompromissoID from agendamentosprocedimentos ap where ap.agendamentoid = '"&splAEA(0)&"' ")
                            else
                                set ProcedimentosSQL = db.execute("select ap.ProcedimentoID TipoCompromissoID FROM atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID where ap.id like '"&splAEA(0)&"' ")
                            end if


						    while not ProcedimentosSQL.eof
						        ProcedimentoID=ProcedimentosSQL("TipoCompromissoID")

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
                                            if pvp("Codigo")<>"" and not isnull(pvp("Codigo")) then
                                                CodigoProcedimento = pvp("Codigo")
                                            end if
                                        end if
                                    end if

                                    'verifica se ha procedimentos anexos e adiciona
                                    set ProcedimentosAnexosSQL = db.execute("SELECT * FROM tissprocedimentosanexos WHERE ConvenioID="&ConvenioID&" AND ProcedimentoPrincipalID="&tpv("ProcedimentoID"))
                                    if not ProcedimentosAnexosSQL.eof then
                                        while not ProcedimentosAnexosSQL.eof
                                            TotalProcedimentos = TotalProcedimentos + ProcedimentosAnexosSQL("Valor")
                                            ProcAnexoCodigo = ProcedimentosAnexosSQL("Codigo")&""
                                            if ProcAnexoCodigo="" then
                                                set codProd = db.execute("select Codigo from procedimentos where id="& treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID")) )
                                                if not codProd.eof then
                                                    ProcAnexoCodigo = codProd("Codigo")
                                                end if
                                            end if
                                            sqlExecute = "insert into tissprocedimentoshonorarios (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ("&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&treatvalzero(ProcedimentosAnexosSQL("ProcedimentoAnexoID"))&", 22, '"&rep(ProcAnexoCodigo)&"', '"&rep(ProcedimentosAnexosSQL("Descricao"))&"', 1, 1, "&treatvalzero(1)&", 1, "&treatvalzero(ProcedimentosAnexosSQL("Valor"))&", "&treatvalzero(ProcedimentosAnexosSQL("Valor"))&", "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"
                                            db_execute(sqlExecute)
                                        ProcedimentosAnexosSQL.movenext
                                        wend
                                        ProcedimentosAnexosSQL.close
                                        set ProcedimentosAnexosSQL=nothing
                                    end if
                                end if

                                TotalProcedimentos = TotalProcedimentos+ValorProcedimento

                                sqlExecute = "insert into tissprocedimentoshonorarios (GuiaID, ProfissionalID, Data, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, ViaID, TecnicaID, Fator, ValorUnitario, ValorTotal, sysUser, AgendamentoID, AtendimentoID, HoraInicio, HoraFim) values ("&reg("id")&", "&ProfissionalID&", "&mydatenull(DataAtendimento)&", "&ProcedimentoID&", "&treatvalzero(TabelaID)&", '"&rep(CodigoProcedimento)&"', '"&rep(Descricao)&"', 1, 1, "&treatvalzero(TecnicaID)&", 1, "&treatvalzero(ValorProcedimento)&", "&treatvalzero(ValorProcedimento)&", "&session("User")&", "&AgendamentoID&", "&AtendimentoID&", "&mytime(HoraInicio)&", "&mytime(HoraFim)&")"
                                db_execute(sqlExecute)

                                set pult = db.execute("select id from tissprocedimentoshonorarios order by id desc limit 1")
                                if not conv.eof then
                                    if ( conv("MesclagemMateriais")="Maior" and ccur(conv("NMateriais"))=0 ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
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
				    IndicacaoAcidenteID = 9
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
				    'verifica se nesta guia já consta este profissional
				    set vcaProf = db.execute("select * from tissprofissionaishonorarios where GuiaID="&reg("id")&" and ProfissionalID="&ProfissionalID)
				    if vcaProf.eof then
					    'response.Write("insert into tissprofissionaissadt (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&reg("id")&", 1, 1, "&ProfissionalID&", '"&CPF&"', '"&ConselhoProfissionalSolicitanteID&"', '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&session("User")&")")
					    sqlExecute = "insert into tissprofissionaishonorarios (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser) values ("&reg("id")&", 1, 12, "&ProfissionalID&", '"&CPF&"', "&treatvalnull(ConselhoProfissionalSolicitanteID)&", '"&NumeroNoConselhoSolicitante&"', '"&UFConselhoSolicitante&"', '"&CodigoCBOSolicitante&"', "&session("User")&")"
				        db_execute(sqlExecute)

				        sqlProfissionaisEquipe = (" SELECT p.id ProfissionalID, p.CPF, COALESCE(a.Funcao, 0) GrauParticipacaoID, p.DocumentoConselho, p.UFConselho, p.CBOS, p.Conselho ConselhoID FROM procedimentosequipeconvenio a"&_
                                                  " inner JOIN profissionais p ON p.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '5'"&_
                                                  " WHERE a.ProcedimentoID = "&ProcedimentoID&_
                                                  " UNION ALL"&_
                                                  " SELECT proext.id, proext.cpf, COALESCE(a.Funcao, 0), proext.DocumentoConselho, proext.UFConselho, proext.CBOS, proext.Conselho FROM procedimentosequipeconvenio a "&_
                                                  " inner JOIN profissionalexterno proext ON proext.id = SUBSTRING_INDEX(a.ContaPadrao,'_' , -1) AND SUBSTRING_INDEX(a.ContaPadrao,'_' , 1) = '8'"&_
                                                  " WHERE a.ProcedimentoID = "&ProcedimentoID)

                        set ProfissionaisEquipe = db.execute(sqlProfissionaisEquipe)
                        while not ProfissionaisEquipe.eof
                            set SequencialSQL = db.execute("SELECT Sequencial From tissprofissionaissadt WHERE GuiaID="&reg("id")&" order by Sequencial desc")

                            Sequencial=1

                            if not SequencialSQL.eof then
                                Sequencial = SequencialSQL("Sequencial") + 1
                            end if

                            sqlInsert = "INSERT INTO tissprofissionaishonorarios (GuiaID, Sequencial, GrauParticipacaoID, ProfissionalID, CodigoNaOperadoraOuCPF, ConselhoID, DocumentoConselho, UFConselho, CodigoCBO, sysUser)" &_
                                                            "VALUES ("&reg("id")&", "&treatvalzero(Sequencial)&", "&ProfissionaisEquipe("GrauParticipacaoID")&", "&ProfissionaisEquipe("ProfissionalID")&", '"&ProfissionaisEquipe("CPF")&"', "&_
                                                            treatvalzero(ProfissionaisEquipe("ConselhoID"))&", '"&ProfissionaisEquipe("DocumentoConselho")&"', '"&ProfissionaisEquipe("UFConselho")&"', "&treatvalzero(ProfissionaisEquipe("CBOS"))&", "&session("User")&")"

                            db.execute(sqlInsert )

                        ProfissionaisEquipe.movenext
                        wend
                                                ProfissionaisEquipe.close
                                                set ProfissionaisEquipe=nothing



				    end if
				    've se é primeira consulta ou seguimento
				    set vesecons = db.execute("select id from tissguiaconsulta where PacienteID="&PacienteID&" and sysActive=1 UNION ALL select id from tissguiahonorarios where PacienteID="&PacienteID&" and sysActive=1")
				    if vesecons.eof then
					    TipoConsultaID = 1
				    else
					    TipoConsultaID = 2
				    end if
				    CaraterAtendimentoID = 1
				    ItemLancto = ItemLancto+1
                end if
			next
			set guia = db.execute("select * from tissguiahonorarios where id="&reg("id"))
			sqlExecute = "update tissguiahonorarios set Procedimentos="&treatvalzero(n2z(guia("Procedimentos")))&" where id="&reg("id")
			db_execute(sqlExecute)
        end if
    end if


end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Guia de Honorários Individuais");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>
<form id="GuiaHonorarios" action="" method="post">
		<div class="row">
			<div class="col-md-10 page-header">
			</div>
			<%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
		</div>

		<input type="hidden" name="tipo" value="GuiaHonorarios" />
	<div class="admin-form theme-primary">
		<div class="panel heading-border panel-primary">
			<div class="panel-body">
				<div class="section-divider mt20 mb40">
					<span> Dados do Benefici&aacute;rio </span>
				</div>
				
				<div class="row">
					<div class="col-md-3"><%= selectInsert("* Nome", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""tissCompletaDados(1, this.value);""", "required", "") %></div>
					<%= quickField("simpleSelect", "gConvenioID", "* Conv&ecirc;nio", 2, ConvenioID, "select * from Convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
					<div class="col-md-2" id="tissplanosguia"><!--#include file="tissplanosguia.asp"--></div>
					<%= quickField("text", "NumeroCarteira", "* N&deg; da Carteira", 2, NumeroCarteira, " lt", "", " required""   required title=""O padrão da matrícula deste convênio está configurado para 10 caracteres""") %>
					<%= quickField("text", "RegistroANS", "* Reg. ANS", 1, RegistroANS, "", "", " required") %>
					<%= quickField("text", "CNS", "CNS", 1, CNS, "", "", "") %>
					<input type="hidden" name="identificadorBeneficiario" value="<%=identificadorBeneficiario%>" />
				</div>
			<br />
				<div class="row">
					<%= quickField("text", "NGuiaPrestador", "* N&deg; da Guia no Prestador", 2, NGuiaPrestador, "", "", " required") %>
					<%= quickField("text", "NGuiaSolicitacaoInternacao", "* N&deg; da Guia de Solicitação de Internação", 3, NGuiaSolicitacaoInternacao, "", "", " required ") %>
					<%= quickField("text", "Senha", "Senha", 2, Senha, "", "", "") %>
					<%= quickField("text", "NGuiaOperadora", "N&deg; da Guia na Operadora", 2, NGuiaOperadora, "", "", "") %>
					<%= quickField("simpleSelect", "AtendimentoRN", "* Atendimento RN", 2, AtendimentoRN, "select 'S' id, 'Sim' SN UNION ALL select 'N', 'Não'", "SN", " empty='' required='required'") %>
				</div>
			<br />
            <div class="section-divider mt20 mb40">
                <span> Dados do Contratado - Onde se Realizou o Procedimento </span>
            </div>
				<div class="row">
					<%= quickField("text", "ContratadoLocalCodigoNaOperadora", "* C&oacute;digo na Operadora", 2, ContratadoLocalCodigoNaOperadora, "", "", " required ") %>
					<input type="hidden" id="ContratadoLocalNome" value="<%=ContratadoLocalNome%>"/>
					<%= quickField("simpleSelect", "LocalExternoID", "* Nome do Hospital/Local", 7, LocalExternoID, "select id, nomelocal from locaisexternos where sysActive=1 order by nomelocal", "nomelocal", " empty="""" required=""required""") %>
					<%= quickField("text", "ContratadoLocalCNES", "* C&oacute;digo CNES", 2, ContratadoLocalCNES, "", "", " required='required'") %>
				</div>
			<br />
            <div class="section-divider mt20 mb40">
                <span> Dados do Contratado Executante </span>
            </div>			
				<div class="row">
					<div class="col-md-3" id="divContratado"><% server.Execute("listaContratado.asp") %></div>
					<%= quickField("text", "CodigoNaOperadora", "* C&oacute;digo na Operadora", 2, CodigoNaOperadora, "", "", "") %>
					<%= quickField("text", "CodigoCNES", "* C&oacute;digo CNES", 2, CodigoCNES, "", "", " required='required'") %>
				</div>
			<br />
				<br />
            <div class="section-divider mt20 mb40">
                <span> Dados da Internação </span>
            </div>
				<div class="row">
					<%= quickField("datepicker", "DataInicioFaturamento", "Data Início Faturamento", 2, DataInicioFaturamento, "", "", "") %>
					<%= quickField("datepicker", "DataFimFaturamento", "Data Fim Faturamento", 2, DataFimFaturamento, "", "", "") %>
				</div>
				
				<h5 class="page-header blue">Procedimentos Realizados</h5>
				<div class="row">
					<div class="col-md-12" id="tissprocedimentoshonorarios">
						<%server.Execute("tissprocedimentoshonorarios.asp")%>
					</div>
				</div>
				<h5 class="page-header blue">Indica&ccedil;&atilde;o do(s) Prossional(is) Executante(s)</h5>
				<div class="row">
					<div class="col-md-12" id="tissprofissionaishonorarios">
						<%server.Execute("tissprofissionaishonorarios.asp")%>
					</div>
				</div>
				<div class="row">
					<div class="col-md-9">
						<div class="row">
							<%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, Observacoes, "", "", "") %>
						</div>
					</div>
					<div class="col-md-3 row">
						<span id="divTotais">
							<%= quickField("currency", "vProcedimentos", "Total Honorários", 12, TotalProcedimentos, "", "", "") %>
						</span>
						<%= quickField("datepicker", "DataEmissao", "* Data de Emissão *", 12, DataEmissao, "", "", " required ") %>
					</div>
				</div>
			<br />
				<div class="clearfix form-actions no-margin">
					<button class="btn btn-primary btn-md"><i class="far fa-save"></i> Salvar</button>
					<button type="button" class="btn btn-md btn-default pull-right" onclick="guiaTISS('GuiaHonorarios', 0)"><i class="far fa-file"></i> Imprimir Guia em Branco</button>
				</div>
			</div>
		</div>
	</div>
</form>
</body>
</html>
    
<script type="text/javascript">
function tissCompletaDados(T, I){
	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T,
		data:$("#GuiaHonorarios").serialize(),
		success:function(data){
			eval(data);
		}
	});
}
    $("#gConvenioID, #UnidadeID").change(function(){
        tissCompletaDados("Convenio", $("#gConvenioID").val());
    });

    $("#Contratado, #UnidadeID").change(function(){
        tissCompletaDados("Contratado", $(this).val());
    });

    $("#ContratadoSolicitanteID").change(function(){
        tissCompletaDados("ContratadoSolicitante", $(this).val());
    });

	$("#LocalExternoID").change(function(){
        tissCompletaDados("LocalExterno", $(this).val());
    });


$("#GuiaHonorarios").submit(function(){
	$.ajax({
		type:"POST",
		url:"SaveGuiahonorarios.asp?Tipo=Honorarios&I=<%=req("I")%>",
		data:$("#GuiaHonorarios").serialize(),
		success:function(data){
			eval(data);
		}
	});
	return false;
});
/*
	function itemhonorarios(T, I, II){
	    $("#modal-table").modal('show');
	    $.ajax({
	        type:"POST",
	        url:"modalhonorarios.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#Guiahonorarios").serialize(),
	        success:function(data){
	            $("#modal").html(data);
	        }
	    });
	}

function itemhonorarios(T, I, II){
	$("#pagar").fadeIn();
	$.ajax({
	    type:"POST",
	    url:"modalhonorarios.asp?T="+T+"&I="+I+"&II="+II,
	    data:$("#Guiahonorarios").serialize(),
	    success:function(data){
	        $("#pagar").html(data);
	    }
	});
}*/

function itemHonorarios(T, I, II, A){
    $("[id^="+T+"]").fadeOut();
    $("[id^="+T+"]").html('');
    $("[id^=l"+T+"]").fadeIn();
    if(A!='Cancela'){
	    $("#l"+T+II).fadeOut();
	    $("#"+T+II).fadeIn();
	    $("#"+T+II).removeClass('hidden');
	    $("#"+T+II).html("Carregando...");
	    $.ajax({
	        type:"POST",
	        url:"modalhonorarios.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#GuiaHonorarios").serialize(),
	        success:function(data){
	            $("#"+T+II).html(data);
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
		   tissRecalcGuiaHonorarios('Recalc');
	   }
   });
}


function tissplanosguia(ConvenioID){
	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?ConvenioID="+ConvenioID,
		data:$("#GuiaHonorarios").serialize(),
		success: function(data){
			$("#tissplanosguia").html(data);
		}
	})
}

function tissRecalcGuiaHonorarios(Action){
	$.ajax({
		type:"POST",
		url:"tissRecalcGuiahonorarios.asp?I=<%=req("I")%>&Action="+Action,
		data:$("#GuiaHonorarios").serialize(),
		success: function(data){
		    $("#divTotais").html(data);
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

function autorizaProcedimentos(procID){
    $(".btn-warning [data-value="+procID+"]").prop('disabled',true);
    $.post("tiss/solicita.php?I=<%=req("I")%>", $("#GuiaHonorarios").serialize() + "&procID="+procID+"&db=<%=session("Banco")%>" + "&ContratadoSolicitante="+$("#ContratadoSolicitanteID option:selected").text() + "&ProfissionalSolicitante=" + $("#ProfissionalSolicitanteID option:selected").text() + "&ContratadoExecutante=" + $("#Contratado option:selected").text(), function(data){
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

$('#IdentificadorBeneficiario').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        return false;
    }
});


<%
if drCD<>"" then
    response.write(drCD)
end if
    %>

<!--#include file="JQueryFunctions.asp"-->
</script>