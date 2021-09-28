<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<%posModalPagar="fixed" %>
<!--#include file="invoiceEstilo.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

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
                        $("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ContratadoSolicitanteCodigoNaOperadora, #_NumeroNoConselhoSolicitante, #ConselhoProfissionalSolicitanteID, #_UFConselhoSolicitante, #CodigoCBOSolicitante").prop("readonly", true);
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
		db_execute("delete from tissprocedimentosinternacao where GuiaID="&reg("id"))
'		db_execute("delete from tissguiaanexa where GuiaID="&reg("id"))
'		set procs = db.execute("select id from tissprocedimentossadt where GuiaID="&reg("id"))
'		while not procs.eof
'			db_execute("delete from rateiorateios rr where rr.Temp=1 and ItemGuiaID="&procs("id"))
'		procs.movenext
'		wend
'		procs.movenext
'		set procs=nothing

		if cdate(formatdatetime(reg("sysDate"),2))<date() then
			db_execute("update tissguiainternacao set sysDate=NOW() where id="&reg("id"))
		end if
		UnidadeID = session("UnidadeID")
	end if

	TotalProcedimentos = 0

	PacienteID = reg("PacienteID")
	CNS = reg("CNS")
	ConvenioID = reg("ConvenioID")
	RegistroANS = reg("RegistroANS")
	NGuiaPrestador = reg("NGuiaPrestador")
	NGuiaOperadora = reg("NGuiaOperadora")
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
    IndicacaoAcidenteID = reg("IndicacaoAcidenteID")
	CodigoNaOperadora = reg("CodigoNaOperadora")
	CodigoCNES = reg("CodigoCNES")
	Observacoes = reg("Observacoes")
	Procedimentos = reg("Procedimentos")
	tipoContratadoSolicitante = reg("tipoContratadoSolicitante")
	tipoProfissionalSolicitante = reg("tipoProfissionalSolicitante")
    sysUser = reg("sysUser")
    sysActive = reg("sysActive")
    sysDate = reg("sysDate")
    NomeHospitalSol = reg("NomeHospitalSol")
    LocalExternoID = reg("LocalExternoID")
    DataSugInternacao = reg("DataSugInternacao")
    TipoInternacao = reg("TipoInternacao")
    RegimeInternacao = reg("RegimeInternacao")
    QteDiariasSol = reg("QteDiariasSol")
    PrevUsoOPME = reg("PrevUsoOPME")
    PrevUsoQuimio = reg("PrevUsoQuimio")
    Cid1 = reg("Cid1")
    Cid2 = reg("Cid2")
    Cid3 = reg("Cid3")
    Cid4 = reg("Cid4")
    DataAdmisHosp = reg("DataAdmisHosp")
    QteDiariasAut = reg("QteDiariasAut")
    TipoAcomodacao = reg("TipoAcomodacao")
    CodigoOperadoraAut = reg("CodigoOperadoraAut")
    NomeHospitalAut = reg("NomeHospitalAut")





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
					    set aEa = db.execute("select ap.id, at.Data, at.HoraInicio, at.HoraFim, ap.ProcedimentoID, at.ProfissionalID, ap.Obs, ap.ValorPlano, ap.rdValorPlano, at.PacienteID, 'executado' Tipo, 'executado' Icone, at.AgendamentoID, ag.EspecialidadeID  FROM  atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ag ON ag.id=at.AgendamentoID where ap.id like '"&splAEA(0)&"' order by at.Data desc, at.HoraInicio desc, at.HoraFim desc")
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
							    set contrato = db.execute("select * from contratosconvenio where ConvenioID="&conv("id")&" and sysActive=1 and not isnull(Contratado)")
							    if not contrato.eof then
								    Contratado = contrato("Contratado")
								    ContratadoSolicitanteID = contrato("Contratado")
								    CodigoNaOperadora = contrato("CodigoNaOperadora") 'conv("NumeroContrato")
								    ContratadoSolicitanteCodigoNaOperadora = contrato("CodigoNaOperadora") ' conv("NumeroContrato")
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
						    set tpv = db.execute("select pv.id, pv.Valor, pv.TecnicaID, pv.ProcedimentoID, pt.TabelaID, pt.Codigo, pt.Descricao from tissprocedimentosvalores as pv left join tissprocedimentostabela as pt on pv.ProcedimentoTabelaID=pt.id where pv.ProcedimentoID="&ProcedimentoID&" and pv.ConvenioID="&ConvenioID)
						    if not tpv.eof then
							    TabelaID = tpv("TabelaID")
							    ValorProcedimento = tpv("Valor")
							    CodigoProcedimento = tpv("Codigo")
							    TecnicaID = tpv("TecnicaID")
							    if tpv("Descricao")<>"" and not isnull(tpv("Descricao")) then
							        Descricao = tpv("Descricao")
                                end if
						    end if


						    db_execute("insert into tissprocedimentosinternacao (GuiaID, ProcedimentoID, TabelaID, CodigoProcedimento, Descricao, Quantidade, QuantidadeAutorizada, sysUser, AgendamentoID, AtendimentoID) values ("&reg("id")&", "&ProcedimentoID&", "&treatvalzero(TabelaID)&", '"&rep(CodigoProcedimento)&"', '"&rep(Descricao)&"', '1', '1', "&session("User")&", "&AgendamentoID&", "&AtendimentoID&")")
                            set pult = db.execute("select id from tissprocedimentosinternacao order by id desc limit 1")
                            if not conv.eof then
                                if ( conv("MesclagemMateriais")="Maior" and ccur(conv("NMateriais"))=0 ) or (conv("MesclagemMateriais")<>"Maior" or isnull(conv("MesclagemMateriais")) ) then
                                    call matProcGuia(pult("id"), ConvenioID)
                                end if
                            end if
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
				    've se é primeira consulta ou seguimento
				    set vesecons = db.execute("select id from tissguiaconsulta where PacienteID="&PacienteID&" and sysActive=1 UNION ALL select id from tissguiainternacao where PacienteID="&PacienteID&" and sysActive=1")
				    if vesecons.eof then
					    TipoConsultaID = 1
				    else
					    TipoConsultaID = 2
				    end if
				    CaraterAtendimentoID = 1
				    ItemLancto = ItemLancto+1
                end if
			next
			set guia = db.execute("select * from tissguiainternacao where id="&reg("id"))
			'db_execute("update tissguiainternacao set TotalGeral="&treatvalzero(n2z(guia("Procedimentos"))+n2z(guia("Medicamentos"))+n2z(guia("Materiais"))+n2z(guia("TaxasEAlugueis"))+n2z(guia("OPME")))&" where id="&reg("id"))
		end if
    else
        if ConvenioID<> "" then
            set conv = db.execute("select c.* from convenios c where c.id="&ConvenioID)
            if not conv.eof then
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
		set maiorGuia = db.execute("select cast(NGuiaPrestador as signed integer)+1 as NGuiaPrestador from tissguiainternacao where not isnull(NGuiaPrestador) and NGuiaPrestador>0 and ConvenioID like '"&ConvenioID&"' order by cast(NGuiaPrestador as signed integer) desc limit 1")
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
end if
%>

<script type="text/javascript">
    $(".crumb-active a").html("Guia de Solicitação de Internação");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>
<style>
.select2-container{
width: 100%!important;
}
</style>

<form id="GuiaInternacao" action="" method="post">
            <div class="row">
	            <div class="col-md-10">
                </div>
                <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
            </div>
<br />
<div class="admin-form theme-primary">
   <div class="panel heading-border panel-primary">
        <div class="panel-body">

            <input type="hidden" name="tipo" value="GuiaInternacao" />
            <input type="hidden" name="GuiaID" value="<%=req("I")%>" />

            <div class="section-divider mt20 mb40">
                <span> Dados do Benefici&aacute;rio </span>
            </div>

            <div class="row">
                <div class="col-md-3"><%= selectInsert("* Nome", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""tissCompletaDados(1, this.value);""", "required", "") %></div>
                <%= quickField("simpleSelect", "gConvenioID", "* Conv&ecirc;nio", 2, ConvenioID, "select * from Convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
                <%= quickField("text", "NumeroCarteira", "* N&deg; da Carteira", 3, NumeroCarteira, " lt", "", " required""   required title=""O padrão da matrícula deste convênio está configurado para 10 caracteres""") %>
                <%= quickField("datepicker", "ValidadeCarteira", "Validade da Carteira", 2, ValidadeCarteira, " input-mask-date ", "", "") %>
                <%= quickField("text", "RegistroANS", "* Reg. ANS", 2, RegistroANS, "", "", " required") %>
                <input type="hidden" name="identificadorBeneficiario" value="<%=identificadorBeneficiario%>" />
            </div>
            <br />
            <div class="row">
                <%= quickField("datepicker", "DataAutorizacao", "Data da Autoriza&ccedil;&atilde;o", 2, DataAutorizacao, "", "", "") %>
                <%= quickField("text", "Senha", "Senha", 2, Senha, "", "", "") %>
                <%= quickField("datepicker", "DataValidadeSenha", "Data de Validade da Senha", 2, DataValidadeSenha, "", "", "") %>
                <%= quickField("text", "NGuiaPrestador", "* N&deg; da Guia no Prestador", 2, NGuiaPrestador, "", "", " required") %>
                <%
                if RepetirNumeroOperadora=1 then
                    fcnRepetirNumeroOperadora = " onkeyup=""$('#NGuiaPrestador').val( $(this).val() )"" "
                end if
                %>
                <%= quickField("text", "NGuiaOperadora", "N&deg; da Guia na Operadora", 2, NGuiaOperadora, "", "", fcnRepetirNumeroOperadora) %>
                <%= quickField("text", "CNS", "CNS", 2, CNS, "", "", "") %>
            </div>

            <br />
            <div class="section-divider mt20 mb40">
                <span> Dados do Contratado Solicitante </span>
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
                <%= quickField("text", "ContratadoSolicitanteCodigoNaOperadora", "* Código na Operadora", 2, ContratadoSolicitanteCodigoNaOperadora, "", "", "required='required'") %>
                <%= quickField("datepicker", "DataSolicitacao", "* Data da Solicita&ccedil;&atilde;o", 2, DataSolicitacao, "", "", "required='required'") %>

            </div>

            <br />
            <%
                if not isnull(ConselhoProfissionalSolicitanteID) and ConselhoProfissionalSolicitanteID<>"" and isnumeric(ConselhoProfissionalSolicitanteID) then
                    ConselhoProfissionalSolicitanteID=cint(ConselhoProfissionalSolicitanteID)
                end if
            %>

            <div class="row">
                <div class="col-md-3">
                    <label>Profissional Solicitante</label>
                        <span class="pull-right">
                        <label><input type="radio" name="tipoProfissionalSolicitante" id="tipoProfissionalSolicitanteI" value="I"<% If tipoProfissionalSolicitante="I" Then %> checked="checked"<% End If %> class="ace" onclick="tps('I');" /> <span class="lbl">Interno</span></label>
                        <label><input type="radio" name="tipoProfissionalSolicitante" id="tipoProfissionalSolicitanteE" value="E"<% If tipoProfissionalSolicitante="E" Then %> checked="checked"<% End If %> class="ace" onclick="tps('E');" /> <span class="lbl">Externo</span></label>
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
                <%= quickField("text", "NumeroNoConselhoSolicitante", "* N&deg; no Conselho", 2, NumeroNoConselhoSolicitante, "", "", " empty='' required='required'") %>
                <%= quickField("text", "UFConselhoSolicitante", "* UF", 1, UFConselhoSolicitante, "", "", " empty='' required='required' pattern='[A-Za-z]{2}'") %>
                <%= quickField("text", "CodigoCBOSolicitante", "* C&oacute;digo CBO", 2, CodigoCBOSolicitante, "", "", " empty='' required='required' pattern='[0-9-]{6,7}'") %>
            </div>


            <br />

            <div class="section-divider mt20 mb40">
                <span> Dados do Hospital / Local Solicitado / Dados da Internação </span>
            </div>
            <div class="row">
                <input type="hidden" id="NomeHospitalSol" value="<%=NomeHospitalSol%>"/>
                <%= quickField("simpleSelect", "LocalExternoID", "Nome do Hospital / Local Solicitado", 5, LocalExternoID, "select id, nomelocal from locaisexternos where sysActive=1 order by nomelocal", "nomelocal", " empty="""" ") %>
                <%= quickField("text", "CodigoNaOperadora", "Código na Operadora / CNPJ", 2, CodigoNaOperadora, "", "", "") %>
                <%= quickField("datepicker", "DataSugInternacao", "* Data sugerida para internação", 3, DataSugInternacao, "", "", "required='required'") %>
                <%= quickField("simpleSelect", "AtendimentoRN", "* Atendimento RN", 2, AtendimentoRN, "select 'S' id, 'Sim' SN UNION ALL select 'N', 'Não'", "SN", " empty='' required='required' no-select2 ") %>

            </div>
            <br />
            <div class="row">
                <%= quickField("simpleSelect", "CaraterAtendimentoID", "* Caráter do Atendimento", 2, CaraterAtendimentoID, "select * from cliniccentral.tisscarateratendimento order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "TipoInternacao", "* Tipo de Internação", 2, TipoInternacao, "select * from tisstipointernacao order by descricao", "descricao", " empty='' required='required' no-select2") %>
                <%= quickField("simpleSelect", "RegimeInternacao", "* Regime de Internação", 2, RegimeInternacao, "select * from tissregimeinternacao order by descricao", "descricao", " empty='' required='required' no-select2") %>
                <%= quickField("text", "QteDiariasSol", "Qtde. Diarias Solicitadas", 2, QteDiariasSol, "", "", " pattern='[0-9]'") %>
                <%= quickField("simpleSelect", "PrevUsoOPME", "* Previsão de uso de OPME", 2, PrevUsoOPME, "select 'S' id, 'Sim' SN UNION ALL select 'N', 'Não'", "SN", " empty='' required='required' no-select2 ") %>
                <%= quickField("simpleSelect", "PrevUsoQuimio", "* Previsão de uso de quimioterápico", 2, PrevUsoQuimio, "select 'S' id, 'Sim' SN UNION ALL select 'N', 'Não'", "SN", " empty='' required='required' no-select2 ") %>
                 </div>
            <br />
            <div class="row">
                <%= quickField("memo", "IndicacaoClinica", "* Indica&ccedil;&atilde;o Cl&iacute;nica", 12, IndicacaoClinica, "", "", " required='required' ") %>
            </div>
            <br />
            <div class="row">
                <div class="col-md-2">
                    <%= selectInsert("CID 10 Principal", "Cid1", Cid1, "cliniccentral.cid10", "codigo", "", "", "") %>
                </div>
                <div class="col-md-2">
                    <%= selectInsert("CID 10 (2)", "Cid2", Cid2, "cliniccentral.cid10", "codigo", "", "", "") %>
                 </div>
                <div class="col-md-2">
                    <%= selectInsert("CID 10 (3)", "Cid3", Cid3, "cliniccentral.cid10", "codigo", "", "", "") %>
                 </div>
                <div class="col-md-2">
                    <%= selectInsert("CID 10 (4)", "Cid4", Cid4, "cliniccentral.cid10", "codigo", "", "", "") %>
                 </div>
                  <%= quickField("simpleSelect", "IndicacaoAcidenteID", "* Indica&ccedil;&atilde;o de acidente", 4, IndicacaoAcidenteID, "select * from tissindicacaoacidente order by descricao", "descricao", " empty='' required='required' no-select2 ") %>
            </div>
            <br />
            <div class="section-divider mt20 mb40">
                <span> Procedimentos Solicitados </span>
            </div>
            <div class="row">
                <div class="col-md-12" id="tissprocedimentosinternacao">
                    <%server.Execute("tissprocedimentosinternacao.asp")%>
                </div>
            </div>

            <div class="section-divider mt20 mb40">
                <span> Dados da Autorização </span>
            </div>
            <div class="row">
                <%= quickField("datepicker", "DataAdmisHosp", "Data Provável da Admissão Hospital", 3, DataAdmisHosp, "", "", "") %>
                <%= quickField("text", "QteDiariasAut", "Qtde. Diarias Autorizada", 2, QteDiariasAut, "", "", "pattern='[0-9]'") %>
                <%= quickField("simpleSelect", "TipoAcomodacao", "Tipo da Acomodação Autorizada", 3, TipoAcomodacao, "select * from tisstipoacomodacao order by descricao", "descricao", " empty='' ") %>

            </div>
            <br />
            <div class="row">
                <%= quickField("text", "CodigoOperadoraAut", "Código na Operadora / CNPJ autorizado", 4, CodigoOperadoraAut, "", "", "") %>
                <%= quickField("text", "NomeHospitalAut", "Nome do Hospital / Local Autorizado", 5, NomeHospitalAut, "", "", "") %>
                <%= quickField("text", "CodigoCNES", "C&oacute;digo CNES", 3, CodigoCNES, "", "", " pattern='[0-9]{7}'") %>
            </div>
            <br />
            <div class="row">
                <%= quickField("memo", "Observacoes", "Observação / Justificativa", 12, Observacoes, "", "", "") %>
            </div>
        </div>


        <% if sysActive=1 then response.write("<hr class='short alt'> Inserida por "& nameInTable(sysUser) &" em "& sysDate) end if %>

        </div>
    </div>

<div class="clearfix form-actions no-margin">
    <div class="btn-group">
        <button class="btn btn-primary btn-md" onclick="isPrint(0)"><i class="far fa-save"></i> Salvar</button>
        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
            <span class="caret"></span>
        </button>
        <ul class="dropdown-menu text-center" role="menu">
            <input type="hidden" id="print" value="0">
            <li><button type="submit" class="btn" style="border:none; background-color:#fff!important;" id="GuiaInternacaoPrint" onclick="isPrint(1)"><i class="far fa-print"></i> Salvar e imprimir</button></li>
        </ul>
    </div>
    <button type="button" class="btn btn-md btn-default pull-right" onclick="guiaTISS('GuiaInternacao', 0)"><i class="far fa-file"></i> Imprimir Guia em Branco</button>
    <% if AutorizadorTiss then %>
        <!--<button type="button" onclick="Autorizador.autorizaInternacoes();" class="btn btn-warning btn-md feegow-autorizador-tiss-method" data-method="autorizar"><i class="far fa-expand"></i> Solicitar</button>-->
        <button type="button" onclick="autorizadorguiainternacao()" class="btn btn-warning btn-md feegow-autorizador-tiss-method" data-method="autorizar"><i class="far fa-expand"></i> Solicitar</button>
        <button type="button" onclick="Autorizador.cancelarGuiaInternacao()" class="btn btn-danger btn-md feegow-autorizador-tiss-method" data-method="cancelar"><i class="far fa-times"></i> Cancelar guia</button>
        <button type="button" onclick="Autorizador.verificarStatusGuiaInternacao()" class="btn btn-default btn-md feegow-autorizador-tiss-method" data-method="status"><i class="far fa-search"></i> Verificar status</button>
    <% end if %>
</div>

</div>

</form>

<br />
<br />

<% if AutorizadorTiss then %>
<script type="text/javascript" src="js/autorizador-tiss.js"></script>
<% end if %>
<script type="text/javascript">
<% if AutorizadorTiss then %>
if(typeof AutorizadorTiss === "function"){
    var Autorizador = new AutorizadorTiss();
    Autorizador.userId = "<%=session("User")%>";
    Autorizador.guideId = "<%=req("I")%>";
    Autorizador.sadt = true;
}

$(document).ready(function() {
    Autorizador.bloqueiaBotoes(3);    
});
<% end if %>


function autorizadorguiainternacao(){
	$.ajax({
        type:"POST",
		url:"saveGuiaInternacao.asp?Tipo=Internacao&I=<%=req("I")%>",
		data:$("#GuiaInternacao").serialize(),
		success:function(data){
            Autorizador.autorizaInternacoes();
		},
		error:function(data){
            alert("Preencher todos os campos obrigatórios")
        }
    });
    return false;
}

function tissCompletaDados(T, I){
	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T,
		data:$("#GuiaInternacao").serialize(),
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

function isPrint(value){
    $('#print').val(value);
}

$("#GuiaInternacao").submit(function(){
    let print = $('#print').val();
	$.ajax({
		type:"POST",
		url:"saveGuiaInternacao.asp?Tipo=Internacao&Print="+print+"&I=<%=req("I")%>",
		data:$("#GuiaInternacao").serialize(),
		success:function(data){
			eval(data);
		}
	});
	return false;
});

function itemInternacao(T, I, II, A){
    $("[id^="+T+"]").html('');
    if(A!='Cancela'){
        $("#"+T+II).removeClass('hidden');
	    $.ajax({
	        type:"POST",
	        url:"modalInternacao.asp?T="+T+"&I="+I+"&II="+II,
	        data:$("#GuiaInternacao").serialize(),
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
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("addContrato.asp?Tipo=Internacao&ModeloID="+ModeloID+"&InvoiceID="+InvoiceID+"&ContaID=3_"+$("#gPacienteID").val(), "", function(data){
            $("#modal").html(data);
        });
    }
}
function AutorizarGuiaTisss()
{
    $("#btnSalvar").click();
    setTimeout(() => {
        isSolicitar = true;
    }, 50);
}

<%
if drCD<>"" then
    response.write(drCD)
end if
    %>

<!--#include file="JQueryFunctions.asp"-->
</script>