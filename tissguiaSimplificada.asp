<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<!--#include file="tissFuncs.asp"-->
<%
call insertRedir("tissguiaconsulta", request.QueryString("I"))
set reg = db.execute("select * from tissguiaconsulta where id="&request.QueryString("I"))
ClasseStatus = "primary"

if not reg.eof then
	PacienteID = reg("PacienteID")
	CNS = reg("CNS")
	StatusGuia = reg("GuiaStatus")
	ConvenioID = reg("ConvenioID")
	PlanoID = reg("PlanoID")
	RegistroANS = reg("RegistroANS")
	NGuiaPrestador = reg("NGuiaPrestador")
	NGuiaOperadora = reg("NGuiaOperadora")
	NumeroCarteira = reg("NumeroCarteira")
	ValidadeCarteira = reg("ValidadeCarteira")
	AtendimentoRN = reg("AtendimentoRN")
	Contratado = reg("Contratado")
	CodigoNaOperadora = reg("CodigoNaOperadora")
	CodigoCNES = reg("CodigoCNES")
	ProfissionalID = reg("ProfissionalID")
	Conselho = reg("Conselho")
	DocumentoConselho = reg("DocumentoConselho")
	UFConselho = reg("UFConselho")
	CodigoCBO = reg("CodigoCBO")
	IndicacaoAcidenteID = reg("IndicacaoAcidenteID")
	DataAtendimento = reg("DataAtendimento")
	TipoConsultaID = reg("TipoConsultaID")
	ProcedimentoID = reg("ProcedimentoID")
	TabelaID = reg("TabelaID")
	CodigoProcedimento = reg("CodigoProcedimento")
	ValorProcedimento = reg("ValorProcedimento")
	Observacoes = reg("Observacoes")
	AtendimentoID = reg("AtendimentoID")
	AgendamentoID = reg("AgendamentoID")
	UnidadeID = reg("UnidadeID")
    ProfissionalEfetivoID = reg("ProfissionalEfetivoID")
    IdentificadorBeneficiario = reg("IdentificadorBeneficiario")
    sysUser = reg("sysUser")
    sysActive = reg("sysActive")
    sysDate = reg("sysDate")
	%>
	<script>
	$(document).ready(function(){
		$("#ContratadoID").val('<%=Contratado%>');
		$("#Contratado").attr("disabled",false);
		$("#ContratadoID").attr("disabled",true);
	});

	</script>
	<%
    if reg("sysActive")=1 and not isnull(ConvenioID) and ConvenioID<>0 then
        set convBloq=db.execute("select BloquearAlteracoes,BloquearAlteracoesContratado from convenios where id="&ConvenioID)
        if not convBloq.eof then
            if convBloq("BloquearAlteracoes")=1 then
				if aut("|guiasA|")=0 then
					%>
					<script>
						$("#NGuiaPrestador").prop("readonly", true);
					</script>
					<%
				end if
				%>
				<script type="text/javascript">
					$(document).ready(function(){
						$("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento").prop("readonly", true);					
					});
				</script>
				<%
            end if
			if convBloq("BloquearAlteracoesContratado")=1 then
			%>
				<script type="text/javascript">
					$(document).ready(function(){
						$("#CodigoNaOperadora, #CodigoCNES").prop("readonly", true);							
						$("#Contratado").attr("disabled",true);
						$("#ContratadoID").attr("disabled",false);
					});
				</script>
			<%
			end if


            set StatusSQL = db.execute("SELECT Cor FROM cliniccentral.tissguiastatus WHERE id="&treatvalzero(reg("GuiaStatus")&""))
            if not StatusSQL.eof then
                ClasseStatus = StatusSQL("Cor")
            end if
        end if
    end if
	'Auto-preenche a guia baseado no lancto
	if request.QueryString("Lancto")<>"" then
		spl = split(request.QueryString("Lancto"), "|")
		if spl(1)="Paciente" then
			PacienteID = spl(0)
					set vpac = db.execute("select * from pacientes where id="&PacienteID)
					if not vpac.eof then
						if not isnull(vpac("ConvenioID1")) then
							Numero = 1
						elseif not isnull(vpac("ConvenioID2")) then
							Numero = 2
						elseif not isnull(vpac("ConvenioID3")) then
							Numero = 3
						else
							Numero = ""
						end if
						if Numero<>"" then
							trocaConvenioID = vpac("ConvenioID"&Numero)
                            ConvenioID = vpac("ConvenioID"&Numero)
			                drCD = "tissCompletaDados('Convenio', "&ConvenioID&");"
							'Matricula = vpac("Matricula"&Numero)
							'Validade = vpac("Validade"&Numero)
						end if
                    end if
		else
			if spl(1)="agendamento" then
			    sqlaEa = "select ag.id, ag.Data, ag.Hora as HoraInicio, ag.HoraFinal as HoraFim, ag.TipoCompromissoID as ProcedimentoID, ag.ProfissionalID, ag.Notas as Obs, ag.ValorPlano, ag.rdValorPlano, ag.PacienteID, ag.StaID as Icone, 'agendamento' as Tipo, ag.id as AgendamentoID, l.UnidadeID, ag.EspecialidadeID, ag.PlanoID from agendamentos as ag left join locais l on l.id=ag.LocalID where ag.id = '"&spl(0)&"' order by ag.Data desc, ag.Hora desc, ag.HoraFinal desc"
			else
			    sqlaEa =("select ap.id, at.Data, at.HoraInicio, at.HoraFim, ap.ProcedimentoID, at.ProfissionalID, ap.Obs, ap.ValorPlano, ap.rdValorPlano, at.PacienteID, 'executado' Tipo, 'executado' Icone, at.AgendamentoID, at.UnidadeID, ag.EspecialidadeID, ag.PlanoID  FROM  atendimentosprocedimentos ap LEFT JOIN atendimentos at on at.id=ap.AtendimentoID LEFT JOIN agendamentos ag ON ag.id=at.AgendamentoID where ap.id like '"&spl(0)&"' order by at.Data desc, at.HoraInicio desc, at.HoraFim desc")
			end if


			set aEa = db.execute(sqlaEa)
			if not aEa.eof then
			    PlanoID =  aEa("PlanoID")
			    ProfissionalID = aEa("ProfissionalID")
			    ConvenioID = aEa("ValorPlano")
				PacienteID = aEa("PacienteID")
				ProcedimentoID = aEa("ProcedimentoID")
				UnidadeID = aEa("UnidadeID")
                EspecialidadeID = aEa("EspecialidadeID")
				if aEa("Tipo")="executado" then
					AtendimentoID = aEa("id")
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
							'Matricula = vpac("Matricula"&Numero)
							'Validade = vpac("Validade"&Numero)
						end if
					end if
				end if
				if not isnull(ConvenioID) and isnumeric(ConvenioID) and ConvenioID<>"" then
					set conv = db.execute("select * from convenios where id="&ConvenioID)
					if not conv.eof then
						BloquearAlteracoes = conv("BloquearAlteracoes")
						BloquearAlteracoesContratado = conv("BloquearAlteracoesContratado")
						RegistroANS = conv("RegistroANS")
                        RepetirNumeroOperadora = conv("RepetirNumeroOperadora")
                        SemprePrimeiraConsulta = conv("SemprePrimeiraConsulta")

                        if UnidadeId&"" <> "" then
                            UnidadeIDContratado = "-"&UnidadeID
                            SQLUnidadeIDContratado = "and Contratado = "&UnidadeIDContratado
                        else
                            UnidadeID=session("UnidadeID")
                        end if

						set contrato = db.execute("SELECT * FROM contratosconvenio WHERE sysActive=1 and ConvenioID = "&conv("id")&" ORDER BY (Contratado = "&session("idInTable")&") DESC, coalesce(SomenteUnidades like CONCAT('%|',nullif('"&session("UnidadeID")&"',''),'|%'),TRUE) DESC ")

						if not contrato.eof then
							Contratado = contrato("Contratado")
							ContratadoSolicitanteID = contrato("Contratado")
							CodigoNaOperadora = contrato("CodigoNaOperadora") 'conv("NumeroContrato")
							ContratadoSolicitanteCodigoNaOperadora = contrato("CodigoNaOperadora") ' conv("NumeroContrato")
						end if

                        if UnidadeID&""<>"" then
                            UnidadeID = cint(UnidadeID)
                        end if

						if isnull(Contratado) or UnidadeID&""="" then
							if session("UnidadeID") = 0 and isnull(Contratado) then

								set contr = db.execute("select CNES,id from empresa")
								if not contr.eof then
									CodigoCNES = contr("CNES")
									Contratado = session("UnidadeID")
								end if
							elseif session("UnidadeID")>0 then
								set contr = db.execute("select CNES,id from sys_financialcompanyunits where id="&session("UnidadeID"))
								if not contr.eof then
									CodigoCNES = contr("CNES")
									Contratado = "-"&contr("id")

								end if
							else
								CodigoCNES = "9999999"
							end if

                        elseif UnidadeID = 0 then
                                set contr = db.execute("select CNES,id from empresa")
                                if not contr.eof then
                                	CodigoCNES = contr("CNES")
                                end if
                        else
                            set contr = db.execute("select CNES,id from sys_financialcompanyunits where id="&UnidadeID)
                            if not contr.eof then
                            	CodigoCNES = contr("CNES")
                            end if
						end if
			
                            set ContratadoID = db.execute("select id, CodigoNaOperadora from contratosconvenio where Contratado ="&ProfissionalID&" and ConvenioID = "&ConvenioID)
                            if not ContratadoID.eof then
                               Contratado = ProfissionalID
                               CodigoNaOperadora = ContratadoID("CodigoNaOperadora")&""
                               CodigoCNES = "9999999"
                            end if
                            'response.write(Contratado)
						%>
						<script >
						$(document).ready(function(){
						    $("#Contratado, #ContratadoID").val("<%=Contratado%>");
						    $("#CodigoNaOperadora").val("<%=CodigoNaOperadora%>");
							$("#CodigoCNES").val("<%=CodigoCNES%>");
							
							$("#Contratado").attr("disabled",false);
							$("#ContratadoID").attr("disabled",true);

							<% if BloquearAlteracoes then %>					
		                    	$("#RegistroANS, #CodigoNaOperadora, #CodigoCNES, #Conselho, #DocumentoConselho, #UFConselho, #CodigoCBO, #CodigoProcedimento, #ValorProcedimento").prop("readonly", true);								
							<% end if %>

							<% if BloquearAlteracoesContratado = 1 then %>
		                    	$("#CodigoNaOperadora, #CodigoCNES").prop("readonly", true);							
								$("#Contratado").attr("disabled",true);
								$("#ContratadoID").attr("disabled",false);
							<% end if %>

						});

						</script>
						<%

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


					've se há valor definido pra este procedimento neste convênio
					set tpv = db.execute("select pv.id, pv.Valor, pt.TabelaID, pt.Codigo from tissprocedimentosvalores as pv left join tissprocedimentostabela as pt on pv.ProcedimentoTabelaID=pt.id where pv.ProcedimentoID="&ProcedimentoID&" and pv.ConvenioID="&ConvenioID)
					if not tpv.eof then
						TabelaID = tpv("TabelaID")
						ValorProcedimento = tpv("Valor")
						CodigoProcedimento = tpv("Codigo")
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
								ValorProcedimento = pvp("Valor")
							end if
						end if
					end if
				end if
			end if
			AtendimentoRN = "N"
			IndicacaoAcidenteID = 9
			'dados do profissional
			ProfissionalID = aEa("ProfissionalID")
			set prof = db.execute("select p.*, e.* from profissionais as p left join especialidades as e on p.EspecialidadeID=e.id where p.id="&ProfissionalID)
			if not prof.eof then
				Conselho = prof("Conselho")
				DocumentoConselho = prof("DocumentoConselho")
				UFConselho = prof("UFConselho")
				CodigoCBO = prof("codigoTISS")
			end if
			if EspecialidadeID&""<>"" AND EspecialidadeID<>0  then
                set profEsp = db.execute("SELECT profEsp.ProfissionalID, profEsp.EspecialidadeID, profEsp.RQE, profEsp.Conselho, profEsp.UFConselho, profEsp.DocumentoConselho, esp.codigoTISS FROM profissionais p "&_
                                         "LEFT JOIN (SELECT ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionaisespecialidades "&_
                                         "UNION ALL  "&_
                                         "SELECT  id ProfissionalID, EspecialidadeID, RQE, Conselho, UFConselho, DocumentoConselho FROM profissionais) profEsp ON profEsp.ProfissionalID=p.id "&_
                                         "LEFT JOIN especialidades esp ON esp.id=profEsp.EspecialidadeID "&_
                                         "WHERE p.id="&ProfissionalID&" AND profEsp.EspecialidadeID="&EspecialidadeID)
                if not profEsp.eof then
                    Conselho = profEsp("Conselho")
                    DocumentoConselho = profEsp("DocumentoConselho")
                    UFConselho = profEsp("UFConselho")
                    CodigoCBO = profEsp("codigoTISS")
                end if
            end if
			've se é primeira consulta ou seguimento
			set vesecons = db.execute("select id from tissguiaconsulta where PacienteID="&PacienteID&" and sysActive=1 UNION ALL select id from tissguiasadt where PacienteID="&PacienteID&" and sysActive=1")
			if vesecons.eof then
				TipoConsultaID = 1
			else
				TipoConsultaID = 2
			end if
			DataAtendimento = aEa("Data")
		end if
    else
        if ConvenioID<> "" then
            set conv = db.execute("select RepetirNumeroOperadora,NaoPermitirAlteracaoDoNumeroNoPrestador, SemprePrimeiraConsulta from convenios c where c.id="&ConvenioID)
            if not conv.eof then

                if conv("SemprePrimeiraConsulta")=1 then
                %>
                <script >
                    $(document).ready(function(){
                        $("#TipoConsultaID").val("1").attr("readonly","true");
                        $("#TipoConsultaID option:not(:selected)").prop('disabled', true);
                    });
                </script>
                <%
                end if

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
'	response.Write(formatdatetime(reg("sysDate"),2)&" - "&date() )
	if reg("sysActive")=0 and cdate(formatdatetime(reg("sysDate"),2))<date() then
		db_execute("update tissguiaconsulta set sysDate=NOW() where id="&reg("id"))
	end if
	if reg("sysActive")=0 then
		UnidadeID = session("UnidadeID")
	end if
end if
%>

<div class="modal fade" id="modalLeitura" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="exampleModalLabel">Leitura de Cartão de Beneficiários</h5>
      </div>
      <div class="modal-body">
	  		<textarea class="form-control" id="campodeleitura" placeholder="Aproxime ou passe o cartão na leitora" required></textarea>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
        <button type="button" class="btn btn-primary" onclick="leitura();">Confirmar</button>
      </div>
    </div>
  </div>
</div>


<script type="text/javascript">
    $(".crumb-active a").html("Guia de Consulta");
    $(".crumb-icon a span").attr("class", "fa fa-credit-card");
</script>


	<form id="GuiaConsulta" action="" method="post">



<div class="row">
	<div class="col-md-10">

    </div>
    <%=quickField("empresa", "UnidadeID", "Unidade", 2, UnidadeID, "", "", "")%>
</div>
<input type="hidden" name="tipo" value="GuiaConsulta" />

<br>
<div class="admin-form theme-primary">
   <div class="panel heading-border panel-<%=ClasseStatus%>">
        <div class="panel-body">

                <input id="check-guia-simplificada" name="GuiaSimplificada" type="hidden" value="1" />
            <div class="row">
    <div class="col-md-12">
	<table width="100%" cellspacing="0" class="table" cellpading="0">

    <div class="section-divider mt20 mb40">
        <span> Dados do Benefici&aacute;rio </span>
    </div>
	<tr><td><table cellpadding="0" cellspacing="0" width="100%"><tr>
	<td width="60%"><div class="col-md-12"><%= selectInsert("* Nome  <button onclick=""if($('#gPacienteID').val()==''){alert('Selecione um paciente')}else{window.open('./?P=Pacientes&Pers=1&I='+$('#gPacienteID').val())}"" class='btn btn-xs btn-default' type='button'><i class='fa fa-external-link'></i></button>", "gPacienteID", PacienteID, "pacientes", "NomePaciente", " required onchange=""tissCompletaDados(1, this.value);""", "required", "") %></div></td>
	<td width="40%"><%= quickField("text", "CNS", "Cart&atilde;o Nacional de Sa&uacute;de", 12, CNS, "", "", "") %></td>
	</tr></table></td></tr>

	<tr><td><table class="table table-bordered"><tr>

	<td width="20%"><%= quickField("simpleSelect", "gConvenioID", "* Conv&ecirc;nio", 12, ConvenioID, "select * from Convenios where sysActive=1 and ativo='on' order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %></td>
    <td width="20%">
    	<div class="col-md-12" id="tissplanosguia">
	    	<!--#include file="tissplanosguia.asp"-->
        </div>
    </td>
	<td width="20%"><%= quickField("text", "RegistroANS", "* Registro ANS", 12, RegistroANS, "", "", " required") %></td>
	<td width="20%"><%= quickField("text", "NGuiaPrestador", "* N&deg; da Guia no Prestador", 12, NGuiaPrestador, "", "", " required") %></td>
    <%
    if RepetirNumeroOperadora=1 then
        fcnRepetirNumeroOperadora = " onkeyup=""$('#NGuiaPrestador').val( $(this).val() )"" "
    end if
    %>

	<td width="20%"><%= quickField("text", "NGuiaOperadora", "N&deg; da Guia na Operadora", 12, NGuiaOperadora, "", "", fcnRepetirNumeroOperadora) %></td>
	</tr></table></td></tr>

	<tr id="tr-carteira">
    <td><table width="100%"><tr>
	<td width="35%"><%= quickField("text", "NumeroCarteira", "* N&deg; da Carteira", 12, NumeroCarteira, " lt ", "", " required") %></td>
	<td width="35%">
	<table width = "100%">
		<tr>
			<td>
				<%= quickField("text", "IdentificadorBeneficiario", "Identificador - Código de barras da carteira", 12, IdentificadorBeneficiario, "", "", " readonly") %>
			</td>
			<td>
				<button id="btn-leitura-cartao" type="button" class="btn btn-xs btn-warning fa fa-credit-card mt20" data-toggle="modal" data-target="#modalLeitura" title="Leitura do Cartão do Beneficiário">
				</button>
			</td>
		</tr>
	</table>
	</td>
	<td width="15%"><%= quickField("datepicker", "ValidadeCarteira", "Validade da Carteira", 12, ValidadeCarteira, "", "", "") %></td>
	<td width="15%">
      <div class="col-md-12">
        <label>* Atendimento a RN</label><br>
	    <select name="AtendimentoRN" id="AtendimentoRN" class="form-control" required>
	    <option value=""></option>
	    <option value="S"<%if AtendimentoRN="S" then%> selected="selected"<%end if%>>Sim</option>
	    <option value="N"<%if AtendimentoRN="N" then%> selected="selected"<%end if%>>N&atilde;o</option>
	    </select>
      </div>
	</td>
	</tr></table></td></tr>
	
	<tr><td>
        <div class="section-divider mt20 mb40">
            <span> Dados do Contratado </span>
        </div>
                                        </td></tr>

	<tr><td><table cellpadding="0" cellspacing="0" width="100%"><tr>
	<td width="60%" id="divContratado">
		<input type="hidden" id="ContratadoID" name="Contratado">
		<% server.Execute("listaContratado.asp") %>
	</td>
	<td width="20%"><%= quickField("text", "CodigoNaOperadora", "* C&oacute;digo na Operadora", 12, CodigoNaOperadora, "", "", " required='required'") %></td>
	<td width="20%"><%= quickField("text", "CodigoCNES", "* C&oacute;digo CNES", 12, CodigoCNES, "", "", " required='required'") %></td>
	</tr></table></td></tr>

	<tr><td><table cellpadding="0" cellspacing="0" width="100%"><tr>
	<td width="40%"><%= quickField("simpleSelect", "gProfissionalID", "* Nome do Profissional Executante <a class='btn btn-xs btn-default btn-efetivo'>+</a>", 12, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " onchange=""tissCompletaDados('Profissional', this.value);"" empty='' required='required' no-select2") %></td>
	<td width="15%"><%= quickField("simpleSelect", "Conselho", "* Conselho", 12, Conselho, "select * from conselhosprofissionais order by descricao", "descricao", " empty='' required='required' no-select2") %></td>
	<td width="15%"><%= quickField("text", "DocumentoConselho", "* N&deg; no Conselho", 12, DocumentoConselho, "", "", "empty='' required='required'") %></td>
	<td width="10%"><%= quickField("text", "UFConselho", "* UF", 12, UFConselho, "", "", "empty='' required='required' maxlength=""2"" ") %></td>
	<td width="20%">
		<%
		'quickField("text", "CodigoCBO", "* C&oacute;digo CBO", 12, CodigoCBO, "", "", "empty='' required='required'")
		 response.write(quickField("simpleSelect", "CodigoCBO", "* C&oacute;digo CBO", 12, CodigoCBO, "select * from (select e.codigoTiss as id, concat( e.codigoTiss,' - ',e.especialidade) as Nome from especialidades as e where e.codigoTiss<>'' and e.codigoTiss is not null order by id)t", "Nome", "empty='' required='required' "))
		%>
	</td>
	</tr></table></td></tr>
    <tr <%if isnull(ProfissionalEfetivoID) then%> class="hidden" <%end if%> id="divPE">
        <td>
            <table cellpadding="0" cellspacing="0" width="40%">
                <tr>
                    <td>
                        <%= quickField("simpleSelect", "ProfissionalEfetivoID", "Profissional Efetivo", 12, ProfissionalEfetivoID, "select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " empty='' no-select2") %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

	<tr><td>
	<div class="section-divider mt20 mb40">
                <span> Dados do Atendimento - Procedimento Realizado </span>
            </div>
	</td></tr>

	<tr><td>
        <table width="100%" border="0">
            <tr>
                <td width="33%"><%= quickField("simpleSelect", "IndicacaoAcidenteID", "* Indica&ccedil;&atilde;o de acidente", 12, IndicacaoAcidenteID, "select * from tissindicacaoacidente order by descricao", "descricao", " empty='' required='required' no-select2") %></td>
                <td width="34%"><%= quickField("datepicker", "DataAtendimento", "* Data do atendimento", 12, DataAtendimento, "", "", " empty='' required='required'") %></td>
                <%
                if SemprePrimeiraConsulta then
                    sqlPrimeiraConsulta = " where id=1"
                end if
                %>
                <td width="33%"><%= quickField("simpleSelect", "TipoConsultaID", "* Tipo de Consulta", 12, TipoConsultaID, "select * from tisstipoconsulta "&sqlPrimeiraConsulta&" order by descricao", "descricao", " empty='' required='required' no-select2") %></td>
            </tr>
        </table>
	</td>
	</tr></table></td></tr>
	
	<tr><td><table cellpadding="0" cellspacing="0"><tr>
	<td nowrap="nowrap" width="30%"><div class="col-md-12"><%= selectInsert("* Procedimento", "gProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " required onchange=""tissCompletaDados(4, this.value);""", "required", "") %></div></td>
	<td width="25%"><%= quickField("simpleSelect", "TabelaID", "* Tabela", 12, TabelaID, "select id, concat(id, ' - ', descricao) descricao from tisstabelas order by descricao", "descricao", " empty='' required='required' no-select2") %></td>
	<td id="td-codprocedimento" nowrap="nowrap" width="30%">
<br>
        <%=selectProc("* Código do Procedimento", "CodigoProcedimento", CodigoProcedimento, "codigo", "TabelaID", "CodigoProcedimento", "", " required='required' ", "", "", "") %>
        <%'= quickField("text", "CodigoProcedimento", "C&oacute;digo do procedimento", 12, CodigoProcedimento, "", "", " required='required'") %></td>
	<td nowrap="nowrap" width="15%" class="<% if aut("valordoprocedimentoV")=0 then %>hidden<%end if%>"><%
	if not isnull(reg("ValorProcedimento")) then
		ValorProcedimento = formatnumber(ValorProcedimento,2)
	end if

	if aut("valorprocedimentoguiaA") then
	    response.Write(quickField("currency", "ValorProcedimento", "* Valor", 12, ValorProcedimento, "", "", " required='required'"))
    elseif aut("valorprocedimentoguiaV") then
        %>
        <div class="col-md-12">
            <strong>R$ <span class="valor-procedimento"><%=fn(ValorProcedimento)%></span></strong>
            <input type="hidden" name="ValorProcedimento" id="ValorProcedimento" value="<%=ValorProcedimento%>">
        </div>
        <%
    else
        %>
        <input type="hidden" name="ValorProcedimento" id="ValorProcedimento" value="<%=ValorProcedimento%>">
        <%
    end if
    %></td>
	</tr></table></td></tr>

	<tr><td><%= quickField("memo", "Observacoes", "Observa&ccedil;&otilde;es", 12, Observacoes, "", "", "") %></td></tr>
	<tr><td style="height:20px; text-align:center">
	</td></tr>
	</table>
    </div>
                </div>
        <% if sysActive=1 then response.write("<hr class='short alt'> Inserida por "& nameInTable(sysUser) &" em "& sysDate) end if %>
    </div>
</div>
</div>
    <div class="clearfix form-actions">
    <%
    recursoUnimed = recursoAdicional(12)
    recursoAutorizadorTISS = recursoAdicional(3)
    AutorizadorTiss = False

    if recursoAutorizadorTISS= 4 or recursoUnimed = 4 then
        AutorizadorTiss=True
    end if

    %>
        <button class="btn btn-primary btn-md" id="salvar-guia"><i class="fa fa-save"></i> Salvar</button>
        <%
        if aut("repassesV")=1 then
            set vcaRep = db.execute("select rr.id from rateiorateios rr where rr.GuiaConsultaID="& req("I") &" AND NOT ISNULL(rr.ItemContaAPagar)")
            if not vcaRep.eof then
                btnrepasse = "<button title='Repasses Gerados' onclick='repasses(`GuiaConsultaID`, "& req("I") &")' type='button' class='btn ml5 btn-dark pull-right'> <i class='fa fa-puzzle-piece'></i>  </button>"
                response.write( btnRepasse )
            end if
        end if
        %>
        <%if AutorizadorTiss then %>
        <button type="button" onclick="AutorizarGuiaTisss()" class="btn btn-warning btn-md feegow-autorizador-tiss-method" data-method="autorizar"><i class="fa fa-expand"></i> Solicitar</button>
        <button type="button" onclick="Autorizador.cancelarGuia(2)" class="btn btn-danger btn-md feegow-autorizador-tiss-method" data-method="cancelar"><i class="fa fa-times"></i> Cancelar guia</button>
        <button type="button" onclick="tissVerificarStatusGuia()" class="btn btn-default btn-md feegow-autorizador-tiss-method" data-method="status"><i class="fa fa-search"></i> Verificar status</button>
        <%end if %>
        <button type="button" class="btn btn-md btn-default pull-right ml5" title="Histórico de alterações" onclick="openComponentsModal('DefaultLog.asp?Impressao=1&R=<%=req("P")%>&I=<%=req("I")%>', {},'Log de alterações', true)"><i class="fa fa-history"></i></button>


        <button type="button" class="btn btn-md btn-default pull-right" onclick="guiaTISS('GuiaConsulta', 0)"><i class="fa fa-file"></i> Imprimir Guia em Branco</button>
        <button type="button" class="btn btn-md btn-primary mr5 pull-right" id="imprimirGuia" onclick="imprimirGuiaConsulta()"><i class="fa fa-file"></i> Imprimir Guia</button>
    </div>
    <input type="hidden" name="AtendimentoID" id="AtendimentoID" value="<%=AtendimentoID%>" />
    <input type="hidden" name="AgendamentoID" id="AgendamentoID" value="<%=AgendamentoID%>" />
	</form>
	</body>
	</html>

	<% if AutorizadorTiss then %>
	<!-- modificado por André Souza em 16/09/2019 (id da tarefa: 614) -->
	 <!--<script type="text/javascript" src="./../feegow_components/assets/modules-assets/autorizador-tiss/js/autorizador-tiss.js"></script>-->
	<script type="text/javascript" src="js/autorizador-tiss.js"></script>
<% end if %>
<script language="javascript">

<%if AutorizadorTiss then %>
if(typeof AutorizadorTiss === "function"){
    var Autorizador = new AutorizadorTiss();
    Autorizador.userId = "<%=session("User")%>";
    Autorizador.guideId = "<%=req("I")%>";
    Autorizador.sadt = false;
}
<%end if %>

function tissCompletaDados(T, I) {
	$.ajax({
		type:"POST",
		url:"tissCompletaDados.asp?I="+I+"&T="+T,
		data:$("#GuiaConsulta").serialize(),
		success:function(data){
			eval(data);

			//não processa campos obrigatórios se for convênio simplificado
			if (!$('#check-guia-simplificada').prop('checked')) {
                var convenio = $("#gConvenioID").val();

                $.get(
                    'CamposObrigatoriosConvenio.asp?ConvenioID=' + convenio,
                    function(data){
                        eval(data);
                    }
                );
            }

		},

	});
}

function simplificaElemento(el)
{
    let oldRequired =  $(el).attr('data-oldrequired');
    if (!oldRequired) {
        oldRequired = typeof $(el).attr('required') !== 'undefined' ? 1 : 0;
    }
    $(el).hide().attr('data-oldrequired', oldRequired).removeAttr('required').find('input, select').each(function() {
        simplificaElemento(this);
    });
}

function restauraElemento(el)
{
    const oldRequired = $(el).attr('data-oldrequired');
    if (oldRequired === 1 || oldRequired === '1') {
        $(el).attr('required', 'required');
    }
    $(el).show().removeAttr('data-oldrequired').find('input, select').each(function() {
        restauraElemento(this);
    });
}

function guiaSimplificada(restore)
{
    const isSimplificada = $('#check-guia-simplificada').prop('checked');

    const elRegistroAns       = $('#qfregistroans').parent();
    const elNGuiaOperadora    = $('#qfnguiaoperadora').parent();
    const elTrCarteira        = $('#tr-carteira');
    const elCodigoNaOperadora = $('#qfcodigonaoperadora').parent();
    const elCodigoCnes        = $('#qfcodigocnes').parent();
    const elCodigoCBO         = $('#qfcodigocbo').parent();
    const elIndicacaoAcidente = $('#qfindicacaoacidenteid').parent();
    const elTipoConsulta      = $('#qftipoconsultaid').parent();
    const elTabela            = $('#qftabelaid').parent();
    const elCodProcedimento   = $('#td-codprocedimento');
    const elConselho          = $('#qfconselho').parent();
    const elNConselho         = $('#qfdocumentoconselho').parent();
    const elUFConselho        = $('#qfufconselho').parent();
    
    simplificaElemento(elRegistroAns);
    simplificaElemento(elNGuiaOperadora);
    simplificaElemento(elTrCarteira);
    simplificaElemento(elCodigoNaOperadora);
    simplificaElemento(elCodigoCnes);
    simplificaElemento(elCodigoCBO);
    simplificaElemento(elIndicacaoAcidente);
    simplificaElemento(elTipoConsulta);
    simplificaElemento(elTabela);
    simplificaElemento(elCodProcedimento);
    simplificaElemento(elConselho);
    simplificaElemento(elNConselho);
    simplificaElemento(elUFConselho);

}

$(document).ready(function(){
    guiaSimplificada();
   <% if aut("|guiasA|")<>1 then
        readOnly = " disabled "
    end if
    set GuiaStatusSQL = db.execute("SELECT * FROM cliniccentral.tissguiastatus order by id")
    Status = "<select id='GuiaStatus' name='GuiaStatus' class='form-control input-sm' "&readOnly&" >"
    while not GuiaStatusSQL.eof
        CheckedStatus = ""
        if GuiaStatusSQL("id")=StatusGuia then
            CheckedStatus = " selected "
        end if
        Status = Status&"<option "&CheckedStatus&" value='"&GuiaStatusSQL("id")&"'>"&GuiaStatusSQL("Status")&"</option>"
    GuiaStatusSQL.movenext
    wend
    GuiaStatusSQL.close
    set GuiaStatusSQL = nothing
    Status = Status&"</select>"

    %>

    $("#rbtns").html("<%=Status %>");

    $("select[name='GuiaStatus']").change(function(data) {
        $.get("AlteraStatusGuia.asp", {GuiaID:"<%=req("I")%>", TipoGuia:$("input[name='tipo']").val(), Status: $(this).val()}, function() {

        })
    });

	$("#gConvenioID, #UnidadeID").change(function(){
		tissCompletaDados("Convenio", $("#gConvenioID").val());
	});

	$("#Contratado, #UnidadeID").change(function(){
		tissCompletaDados("Contratado", $(this).val());
	});
	
});

$("#GuiaConsulta").submit(function(){
    var $plano = $("#PlanoID"),
        planoId = $plano.val();

    if(planoId=='0' && $plano.attr("required") === "required"){
        showMessageDialog("Preencha o plano", "danger");
        return false;
    }

	$.ajax({
		type:"POST",
		url:"SaveGuia.asp?Tipo=Consulta&I=<%=request.QueryString("I")%>&GuiaStatus="+ $("#GuiaStatus").val(),
		data:$("#GuiaConsulta").serialize(),
		success:function(data,obj){
			eval(data);
		}
	});
	return false;
});

function tissplanosguia(ConvenioID){
    let PlanoID = "<%=PlanoID%>";

	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?ConvenioID="+ConvenioID,
		data:$("#GuiaConsulta").serialize(),
		success: function(data){
			$("#tissplanosguia").html(data);
			$("[name='PlanoID']").val(PlanoID);
		}
	})
}

$(".btn-efetivo").click(function(){
    $("#divPE").removeClass("hidden");
});


$("#gConvenioID, #UnidadeID").change(function(){
    tissCompletaDados("Convenio", $("#gConvenioID").val());			
});



$('#IdentificadorBeneficiario').keydown(function(e) {
    if(e.which == 10 || e.which == 13){
        return false;
    }
});

function leitura(){ 
	$('#IdentificadorBeneficiario').val(btoa($('#campodeleitura').val()));	
	$('#modalLeitura').modal('toggle');
	$('#campodeleitura').val("");
}

function AutorizarGuiaTisss()
{
	$.ajax({
		type:"POST",
		url:"SaveGuia.asp?isRedirect=S&Tipo=Consulta&I=<%=request.QueryString("I")%>&GuiaStatus="+ $("#GuiaStatus").val(),
		data:$("#GuiaConsulta").serialize(),
		success:function(data){
			 Autorizador.autorizaProcedimentos();
			//Autorizador.testar();
		},
		error:function(data){
            alert("Preencher todos os campos obrigatórios")
        }
	});
}
function tissVerificarStatusGuia()
{
	$.ajax({
		type:"POST",
		url:"SaveGuia.asp?isRedirect=S&Tipo=Consulta&I=<%=request.QueryString("I")%>&GuiaStatus="+ $("#GuiaStatus").val(),
		data:$("#GuiaConsulta").serialize(),
		success:function(data){
			Autorizador.verificarStatusGuia(2);
			//Autorizador.testar();
		},
		error:function(data){
            alert("Preencher todos os campos obrigatórios")
        }
	});
}

function imprimirGuiaConsulta(){

    $.ajax({
    		type:"POST",
    		url:"SaveGuia.asp?isRedirect=S&Tipo=Consulta&I=<%=request.QueryString("I")%>&GuiaStatus="+ $("#GuiaStatus").val(),
    		data:$("#GuiaConsulta").serialize(),
			success: (suc) => {
				guiaTISS('GuiaConsulta', <%=request.QueryString("I")%> ,$("#gConvenioID").val());
			},
			error: (err) => {
				alert("Preencher todos os campos obrigatórios");
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

function repasses(T, I){
    $("#modal-table").modal("show");
    $.get("repassesGerados.asp?T="+ T +"&I="+ I, function(data){
        $("#modal").html(data);
    });
}

<%
if drCD<>"" then
    response.write(drCD)
end if
    %>

<!--#include file="JQueryFunctions.asp"-->
</script>