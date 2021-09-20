<!--#include file="connect.asp"-->
<%
I = req("I")
tipoContratadoSolicitante = ref("tipoContratadoSolicitante")
tipoProfissionalSolicitante = ref("tipoProfissionalSolicitante")
if tipoContratadoSolicitante="I" then
	ContratadoSolicitanteID = ref("ContratadoSolicitanteID")
	'Completa os dados do convenio x contratado interno como na guia de consulta
else
	ContratadoSolicitanteID = ref("ContratadoExternoID")
	'Complata os dados convenio x contratado externo
end if
if tipoProfissionalSolicitante="I" then
	ProfissionalSolicitanteID = ref("ProfissionalSolicitanteID")
	'Completa os dados do convenio x contratado interno como na guia de consulta
else
	ProfissionalSolicitanteID = ref("ProfissionalSolicitanteExternoID")
	'Complata os dados convenio x contratado externo
end if

'1. verifica se já tem guia com esse numero nesse convenio prestador
set vca = db.execute("select NGuiaPrestador from tissguiainternacao where ConvenioID like '"&ref("gConvenioID")&"' and NGuiaPrestador like '"&ref("NGuiaPrestador")&"' and id!="&I)
if not vca.eof then
	erro = "J&aacute; existe uma guia com este n&uacute;mero no prestador."
end if

ObrigarValidade = 0
BloquearAlteracoes = 0
set vcaBloq = db.execute("select ifnull(BloquearAlteracoes, 0) BloquearAlteracoes, ifnull(ObrigarValidade, 0) ObrigarValidade from convenios where id="&treatvalzero(ref("gConvenioID")))
if not vcaBloq.EOF then
    BloquearAlteracoes = ccur(vcaBloq("BloquearAlteracoes"))
    ObrigarValidade = ccur(vcaBloq("ObrigarValidade"))
end if
if ObrigarValidade=1 then
    if not isdate(ref("ValidadeCarteira")) then
        erro = "É obrigatório o preenchimento da validade da carteira para este convênio."
    end if
end if

set vcaProc = db.execute("select * from tissprocedimentosinternacao where GuiaID="&I)
if vcaProc.eof and session("Banco")<>"clinic3882" then
	erro = "Insira ao menos um procedimento na guia."
end if
'set vcaProf = db.execute("select * from tissprofissionaisinternacao where GuiaID="&I)
'if vcaProf.eof then
'	erro = "Insira ao menos um profissional executante na guia."
'end if

if erro<>"" then
	%>
    new PNotify({
        title: ' ERRO!',
        text: '<%=erro%>',
        type: 'danger',
    });
    <%
else
	'atualiza os dados do paciente, profissional, convenio, contratado e procedimento

	'Paciente
    'if BloquearAlteracoes=0 then
    '	db_execute("update pacientes set CNS='"&ref("CNS")&"' where id="&ref("gPacienteID"))
	'    call gravaConvPac(ref("gConvenioID"), ref("gPacienteID"))
    'end if

	set vpac = db.execute("select * from pacientes where id="&ref("gPacienteID"))
	if not vpac.eof then
		if not isnull(vpac("ConvenioID1")) AND vpac("ConvenioID1")=ccur(ref("gConvenioID")) then
			Numero = 1
		elseif not isnull(vpac("ConvenioID2")) AND vpac("ConvenioID2")=ccur(ref("gConvenioID")) then
			Numero = 2
		elseif not isnull(vpac("ConvenioID3")) AND vpac("ConvenioID3")=ccur(ref("gConvenioID")) then
			Numero = 3
		else
			Numero = ""
		end if
	end if
	'if Numero<>"" and BloquearAlteracoes=0 then
	'	response.Write("update pacientes set PlanoID"&Numero&"='"&ref("PlanoID")&"', Matricula"&Numero&"='"&ref("NumeroCarteira")&"', Validade"&Numero&"="&ValidadeCarteira&" where id="&ref("PacienteID"))
	'	db_execute("update pacientes set Matricula"&Numero&"='"&ref("NumeroCarteira")&"', Validade"&Numero&"="&mydatenull(ref("ValidadeCarteira"))&" where id="&ref("gPacienteID"))
	'end if


	'Convenio
    'if BloquearAlteracoes=0 then
	'    db_execute("update convenios set RegistroANS='"&ref("RegistroANS")&"' where id="&ref("gConvenioID"))
	'    set vcaConvenioContratado = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado="&ref("Contratado"))
	'    if not vcaConvenioContratado.eof then
	'	    db_execute("update contratosconvenio set CodigoNaOperadora='"&ref("CodigoNaOperadora")&"' where id="&vcaConvenioContratado("id"))
	'    else
	'	    db_execute("insert into contratosconvenio (ConvenioID, Contratado, ContaRecebimento, CodigoNaOperadora, sysUser, sysActive) values ("&ref("gConvenioID")&", "&ref("Contratado")&", 0, '"&ref("CodigoNaOperadora")&"', "&session("User")&", 1)")
	'    end if
    'end if

	'Dados do profissional solicitante
	set cbo=db.execute("select * from especialidades where codigoTISS like '"&ref("CodigoCBOSolicitante")&"'")
	if not cbo.eof then
		EspecialidadeID = cbo("id")
	else
		EspecialidadeID = 0
	end if
    'if BloquearAlteracoes=0 then
	'    if ref("tipoProfissionalSolicitante")="I" then
	'	    db_execute("update profissionais set Conselho='"&ref("ConselhoProfissionalSolicitanteID")&"', DocumentoConselho='"&ref("NumeroNoConselhoSolicitante")&"', UFConselho='"&ref("UFConselhoSolicitante")&"', EspecialidadeID="&EspecialidadeID&" where id="&ref("ProfissionalSolicitanteID"))
	'    else
	'	    if isnumeric(ref("ContratadoExternoID")) and ref("ContratadoExternoID")<>"" then
	'		    sqlAtuContNoProf = "ContratadoExternoID='"&ref("ContratadoExternoID")&"',"
	'	    end if
    '        sqlUp = "update profissionalexterno set "&sqlAtuContNoProf&" Conselho='"&ref("ConselhoProfissionalSolicitanteID")&"', DocumentoConselho='"&ref("NumeroNoConselhoSolicitante")&"', UFConselho='"&ref("UFConselhoSolicitante")&"', EspecialidadeID="&EspecialidadeID&" where id = '"&ref("ProfissionalSolicitanteExternoID")&"'"
    '        response.Write("//"& sqlUp )
	'	    db_execute(sqlUp)
	'    end if
    'end if

	'Contratado executante
	'Contratado = ccur(ref("Contratado"))
    'if BloquearAlteracoes=0 then
	'    if Contratado=0 then
	'	    db_execute("update empresa set CNES='"&ref("CodigoCNES")&"'")
	'    elseif Contratado<0 then
	'	    db_execute("update sys_financialcompanyunits set CNES='"&ref("CodigoCNES")&"' where id="&(Contratado*(-1)))
	'    end if
    'end if
	'Contratado solicitante
	if ref("tipoContratadoSolicitante")="E" and BloquearAlteracoes=0 then
		set vca = db.execute("select * from contratadoexternoconvenios where ConvenioID like '"&ref("gConvenioID")&"' and ContratadoExternoID like '"&ref("ContratadoExternoID")&"'")
		if vca.eof then
			db_execute("insert into contratadoexternoconvenios (ContratadoExternoID, ConvenioID, CodigoNaOperadora) values ("&treatvalzero(ref("ContratadoExternoID"))&", "&treatvalzero(ref("gConvenioID"))&", '"&ref("ContratadoSolicitanteCodigoNaOperadora")&"')")
		else
			db_execute("update contratadoexternoconvenios set ContratadoExternoID="&treatvalzero(ref("ContratadoExternoID"))&", ConvenioID="&treatvalzero(ref("gConvenioID"))&", CodigoNaOperadora='"&ref("ContratadoSolicitanteCodigoNaOperadora")&"' where id="&vca("id"))
		end if
	end if
    'set datant = db.execute("select gs.PacienteID, gis.Data from tissguiainternacao gs left join tissprocedimentosinternacao gis on gis.GuiaID=gs.id where not isnull(gis.Data) and gs.id="&I&" group by gis.Data")'tem q ser antes pra pegar os dados antes do update
    set datant = db.execute("select gs.PacienteID from tissguiainternacao gs left join tissprocedimentosinternacao gis on gis.GuiaID=gs.id where gs.id="&I)'tem q ser antes pra pegar os dados antes do update

	'//-> fim do atualiza os dados do paciente, profissional, convenio, contratado e procedimento
	sql = "update tissguiainternacao set UnidadeID='"&ref("UnidadeID")&"', PacienteID='"&ref("gPacienteID")&"', CNS='"&ref("CNS")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', ValidadeCarteira="&mydatenull(ref("ValidadeCarteira"))&", AtendimentoRN='"&ref("AtendimentoRN")&"', ConvenioID='"&ref("gConvenioID")&"', RegistroANS='"&ref("RegistroANS")&"', NGuiaPrestador='"&ref("NGuiaPrestador")&"', NGuiaOperadora='"&ref("NGuiaOperadora")&"',  CodigoNaOperadora='"&ref("CodigoNaOperadora")&"', CodigoCNES='"&ref("CodigoCNES")&"', IndicacaoAcidenteID='"&ref("IndicacaoAcidenteID")&"', Observacoes='"&ref("Observacoes")&"',  DataAutorizacao="&mydatenull(ref("DataAutorizacao"))&", Senha='"&ref("Senha")&"', DataValidadeSenha="&mydatenull(ref("DataValidadeSenha"))&",ContratadoSolicitanteID='"&ContratadoSolicitanteID&"', ContratadoSolicitanteCodigoNaOperadora='"&ref("ContratadoSolicitanteCodigoNaOperadora")&"', ProfissionalSolicitanteID="&treatvalzero(ProfissionalSolicitanteID)&", ConselhoProfissionalSolicitanteID='"&ref("ConselhoProfissionalSolicitanteID")&"', NumeroNoConselhoSolicitante='"&ref("NumeroNoConselhoSolicitante")&"', UFConselhoSolicitante='"&ref("UFConselhoSolicitante")&"', CodigoCBOSolicitante='"&ref("CodigoCBOSolicitante")&"', CaraterAtendimentoID='"&ref("CaraterAtendimentoID")&"', DataSolicitacao="&mydatenull(ref("DataSolicitacao"))&", IndicacaoClinica='"&ref("IndicacaoClinica")&"', Procedimentos="&treatValZero(ref("Procedimentos"))&", sysActive=1, tipoContratadoSolicitante='"&tipoContratadoSolicitante&"', tipoProfissionalSolicitante='"&tipoProfissionalSolicitante&"', NomeHospitalSol='"&ref("NomeHospitalSol")&"',DataSugInternacao="&mydatenull(ref("DataSugInternacao"))&",TipoInternacao="&treatValZero(ref("TipoInternacao"))&", RegimeInternacao="&treatValZero(ref("RegimeInternacao"))&", QteDiariasSol="&treatValZero(ref("QteDiariasSol"))&", PrevUsoOPME='"&ref("PrevUsoOPME")&"', PrevUsoQuimio='"&ref("PrevUsoQuimio")&"', Cid1="&treatValZero(ref("Cid1"))&", Cid2="&treatValZero(ref("Cid2"))&", Cid3="&treatValZero(ref("Cid3"))&", Cid4="&treatValZero(ref("Cid4"))&", DataAdmisHosp="&mydatenull(ref("DataAdmisHosp"))&",QteDiariasAut="&treatValZero(ref("QteDiariasAut"))&", TipoAcomodacao="&treatValZero(ref("TipoAcomodacao"))&", CodigoOperadoraAut="&treatValZero(ref("CodigoOperadoraAut"))&", NomeHospitalAut='"&ref("NomeHospitalAut")&"', LocalExternoID='"&ref("LocalExternoID")&"' where id="&I
	db_execute(sql)
    'if session("Banco")="clinic522" then
    '    db_execute("update tissguiainternacao set IdentificadorBeneficiario='"&ref("IdentificadorBeneficiario")&"' where id="&I)
    'end if


	set guia = db.execute("select * from tissguiainternacao where id="&I)
	%>
    if( $.isNumeric($("#gPacienteID").val()) )
    {
		redirect()

    }else{
        location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaInternacao&LoteID=<%=guia("LoteID")%>&Pers=1';
    }

	function redirect(){
		modalPrint((valor)=>{
			if(valor = "true"){
				ajxContent('Conta', $('#gPacienteID').val(), '1', 'divHistorico');
				if(typeof loadAgenda === "function"){
					loadAgenda($("#Data").val(), $("#gProfissionalID").val());
				}else{
					location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaInternacao&LoteID=<%=guia("LoteID")%>&Pers=1';
				}				
			}
		})
	}

	function modalPrint(callback=false){
		let print = <%=req("Print")%>
		let convenioId = '<%=guia("ConvenioID")%>'

		if(print == 1 && convenioId != ''){
			guiaTISS('GuiaInternacao', <%=guia("id")%>, convenioId, (valor)=>{
				if(typeof callback === "function"){
					window.onafterprint =callback("true")
					return true
				}
			});
		}else{
			location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaInternacao&LoteID=<%=guia("LoteID")%>&Pers=1';
		}		
		return false
	}
    <%
end if
%>