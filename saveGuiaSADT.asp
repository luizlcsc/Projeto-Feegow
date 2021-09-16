<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
I = req("I")
ConvenioID = ref("gConvenioID")
PlanoID = ref("PlanoID")
isClose = req("close")

redirecionar = false
if req("isRedirect")="S" then
    redirecionar =true
end if

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

ObrigarIndicacaoClinica=False

set ProcedimentosGuiaSQL = db.execute("SELECT tsadt.ProcedimentoID, proc.SolIC ObrigarIndicacaoClinica FROM tissprocedimentossadt tsadt INNER JOIN procedimentos proc ON proc.id=tsadt.ProcedimentoID WHERE tsadt.GuiaID="&I)

while not ProcedimentosGuiaSQL.eof
    if ProcedimentosGuiaSQL("ObrigarIndicacaoClinica")&""="S" then
        ObrigarIndicacaoClinica=True
    end if

    sqlPermitido = "SELECT p.NomeProcedimento, COALESCE(tpvp.NaoCobre, tpv.NaoCobre)NaoCobre FROM tissprocedimentosvalores tpv "&_
    "LEFT JOIN tissprocedimentosvaloresplanos tpvp ON tpvp.AssociacaoID=tpv.id AND tpvp.PlanoID="&treatvalzero(PlanoID)&" "&_
    "LEFT JOIN procedimentos p ON p.id=tpv.ProcedimentoID "&_
    "WHERE tpv.ProcedimentoID="&treatvalzero(ProcedimentosGuiaSQL("ProcedimentoID"))&" AND tpv.ConvenioID="&ConvenioID

    set ProcedimentoPermitidoSQL = db.execute(sqlPermitido)

    if not ProcedimentoPermitidoSQL.eof then
        IF ProcedimentoPermitidoSQL("NaoCobre")="S" then
            erro = "Procedimento "&ProcedimentoPermitidoSQL("NomeProcedimento")&" não é coberto para o convênio/plano selecionado."
        END IF
    end if

ProcedimentosGuiaSQL.movenext
wend
ProcedimentosGuiaSQL.close
set ProcedimentosGuiaSQL=nothing

if ObrigarIndicacaoClinica and ref("IndicacaoClinica")="" then
    erro = "O campo ""Indicação Clínica"" é obrigatório para um dos procedimentos."
end if

set vcaProc = db.execute("select * from tissprocedimentossadt where GuiaID="&I)
if vcaProc.eof and (session("Banco")<>"clinic3882" and session("Banco")<>"clinic5868") then
	erro = "Insira ao menos um procedimento na guia."
end if
'set vcaProf = db.execute("select * from tissprofissionaissadt where GuiaID="&I)
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
    if BloquearAlteracoes=0 then
    	db_execute("update pacientes set CNS='"&ref("CNS")&"' where id="&ref("gPacienteID"))

	    call gravaConvPac(ref("gConvenioID"), ref("gPacienteID"))
    end if

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
	if Numero<>"" and BloquearAlteracoes=0 then
'		response.Write("update pacientes set PlanoID"&Numero&"='"&ref("PlanoID")&"', Matricula"&Numero&"='"&ref("NumeroCarteira")&"', Validade"&Numero&"="&ValidadeCarteira&" where id="&ref("PacienteID"))
		db_execute("update pacientes set PlanoID"&Numero&"='"&ref("PlanoID")&"', Matricula"&Numero&"='"&ref("NumeroCarteira")&"', Validade"&Numero&"="&mydatenull(ref("ValidadeCarteira"))&" where id="&ref("gPacienteID"))
	end if


	'Convenio
    if BloquearAlteracoes=0 and false then
	    db_execute("update convenios set RegistroANS='"&ref("RegistroANS")&"' where id="&ref("gConvenioID"))
	    set vcaConvenioContratado = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado=NULLIF('"&ref("Contratado")&"','FALSE')")

	    if not vcaConvenioContratado.eof then
		    db_execute("update contratosconvenio set CodigoNaOperadora='"&ref("CodigoNaOperadora")&"' where id="&vcaConvenioContratado("id"))
	    else
            if trim(ref("CodigoNaOperadora"))<>"" then
		        db_execute("insert into contratosconvenio (ConvenioID, Contratado, ContaRecebimento, CodigoNaOperadora, sysUser, sysActive) values ("&ref("gConvenioID")&", NULLIF('"&ref("Contratado")&"','FALSE'), 0, '"&ref("CodigoNaOperadora")&"', "&session("User")&", 1)")
            end if 
	    end if
    end if

	'Dados do profissional solicitante
	set cbo=db.execute("select * from especialidades where codigoTISS like '"&ref("CodigoCBOSolicitante")&"'")
	if not cbo.eof then
		EspecialidadeID = cbo("id")
	else
		EspecialidadeID = 0
	end if
    if BloquearAlteracoes=0 then
	    if ref("tipoProfissionalSolicitante")="I" then
		    'db_execute("update profissionais set Conselho='"&ref("ConselhoProfissionalSolicitanteID")&"', DocumentoConselho='"&ref("NumeroNoConselhoSolicitante")&"', UFConselho='"&ref("UFConselhoSolicitante")&"', EspecialidadeID="&EspecialidadeID&" where id="&ref("ProfissionalSolicitanteID"))
	    else
		    if isnumeric(ref("ContratadoExternoID")) and ref("ContratadoExternoID")<>"" then
			    sqlAtuContNoProf = "ContratadoExternoID='"&ref("ContratadoExternoID")&"',"
		    end if
            sqlUp = "update profissionalexterno set "&sqlAtuContNoProf&" Conselho='"&ref("ConselhoProfissionalSolicitanteID")&"', DocumentoConselho='"&ref("NumeroNoConselhoSolicitante")&"', UFConselho='"&ref("UFConselhoSolicitante")&"', EspecialidadeID="&EspecialidadeID&" where id = '"&ref("ProfissionalSolicitanteExternoID")&"'"
            ' response.Write("//"& sqlUp )
		    db_execute(sqlUp)
	    end if
    end if

	'Contratado executante
	if ref("Contratado")&""<>"" AND ref("Contratado")&""<>"FALSE" then
	    Contratado = ccur(ref("Contratado"))
    else
	    Contratado = ""
    end if
    if BloquearAlteracoes=0 then
        if Contratado&""<>"" then
            if Contratado=0 then
                set EmpresaCNES = db.execute("select CNES from empresa where (CNES is null or CNES ='')" )
                if not EmpresaCNES.EOF then
                    'db_execute("update empresa set CNES='"&ref("CodigoCNES")&"'")
                end if
            
            elseif Contratado<0 then
                set unitCNES = db.execute("select CNES from sys_financialcompanyunits where id="&(Contratado*(-1))&" and (CNES is null or CNES ='')" )
                if not unitCNES.EOF then
                    'db_execute("update sys_financialcompanyunits set CNES='"&ref("CodigoCNES")&"' where id="&(Contratado*(-1)))
                end if
            end if
	    end if
    end if

	'Contratado solicitante
	if ref("tipoContratadoSolicitante")="E" and BloquearAlteracoes=0 then
		set vca = db.execute("select * from contratadoexternoconvenios where ConvenioID like '"&ref("gConvenioID")&"' and ContratadoExternoID like '"&ref("ContratadoExternoID")&"'")
		if vca.eof then
			db_execute("insert into contratadoexternoconvenios (ContratadoExternoID, ConvenioID, CodigoNaOperadora) values ("&treatvalzero(ref("ContratadoExternoID"))&", "&treatvalzero(ref("gConvenioID"))&", '"&ref("ContratadoSolicitanteCodigoNaOperadora")&"')")
		else
			db_execute("update contratadoexternoconvenios set ContratadoExternoID="&treatvalzero(ref("ContratadoExternoID"))&", ConvenioID="&treatvalzero(ref("gConvenioID"))&", CodigoNaOperadora='"&ref("ContratadoSolicitanteCodigoNaOperadora")&"' where id="&vca("id"))
		end if
	end if
    set datant = db.execute("select gs.PacienteID, gis.Data from tissguiasadt gs left join tissprocedimentossadt gis on gis.GuiaID=gs.id where not isnull(gis.Data) and gs.id="&I&" group by gis.Data")'tem q ser antes pra pegar os dados antes do update


	'atualiza os dados do paciente, profissional, convenio, contratado e procedimento
    NGuiaPrestador = ref("NGuiaPrestador")
    ConvenioID = ref("gConvenioID")
    forcarSalvar = req("Forcar")

    've se ja existe alguma guia deste convenio, com esta numeracao no prestador. se existir, mostra mensagem
    sqlGuia = "SELECT numero, id, Tipo FROM  ((SELECT cast(gc.NGuiaPrestador as signed integer) numero, id, 'Consulta' as Tipo FROM tissguiaconsulta gc WHERE gc.ConvenioID = '"&ConvenioID&"' AND gc.NGuiaPrestador='"&NGuiaPrestador&"') UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer) numero, id, 'SADT' as Tipo FROM tissguiasadt gs WHERE gs.ConvenioID = '"&ConvenioID&"' AND gs.NGuiaPrestador='"&NGuiaPrestador&"') UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer) numero, id, 'Honorário' as Tipo FROM tissguiahonorarios gh WHERE gh.ConvenioID = '"&ConvenioID&"' AND gh.NGuiaPrestador='"&NGuiaPrestador&"')) as numero WHERE id != "&I&" AND numero = '"&NGuiaPrestador&"'"

    set guiaExiste = db.execute(sqlGuia)

    if guiaExiste.eof or Forcar="1" then
        '//-> fim do atualiza os dados do paciente, profissional, convenio, contratado e procedimento
        Contratado = ref("Contratado")
        if isnull(Contratado) then
            Contratado="FALSE"
        end if
        if ref("GuiaSimplificada")&"" = "1" then
            GuiaSimplificada = 1
        else
            GuiaSimplificada = 0
        end if
        sql = "update tissguiasadt set UnidadeID='"&ref("UnidadeID")&"', PacienteID='"&ref("gPacienteID")&"', CNS='"&ref("CNS")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', ValidadeCarteira="&mydatenull(ref("ValidadeCarteira"))&", AtendimentoRN='"&ref("AtendimentoRN")&"', ConvenioID='"&ref("gConvenioID")&"', PlanoID='"&ref("PlanoID")&"', RegistroANS='"&ref("RegistroANS")&"', NGuiaPrestador='"&ref("NGuiaPrestador")&"', NGuiaOperadora='"&ref("NGuiaOperadora")&"', Contratado='"&Contratado&"', CodigoNaOperadora='"&ref("CodigoNaOperadora")&"', CodigoCNES='"&ref("CodigoCNES")&"', IndicacaoAcidenteID='"&ref("IndicacaoAcidenteID")&"', TipoConsultaID='"&ref("TipoConsultaID")&"', Observacoes='"&ref("Observacoes")&"', NGuiaPrincipal='"&ref("NGuiaPrincipal")&"', DataAutorizacao="&mydatenull(ref("DataAutorizacao"))&", Senha='"&ref("Senha")&"', DataValidadeSenha="&mydatenull(ref("DataValidadeSenha"))&",ContratadoSolicitanteID='"&ContratadoSolicitanteID&"', ContratadoSolicitanteCodigoNaOperadora='"&ref("ContratadoSolicitanteCodigoNaOperadora")&"', ProfissionalSolicitanteID="&treatvalzero(ProfissionalSolicitanteID)&", ConselhoProfissionalSolicitanteID='"&ref("ConselhoProfissionalSolicitanteID")&"', NumeroNoConselhoSolicitante='"&ref("NumeroNoConselhoSolicitante")&"', UFConselhoSolicitante='"&ref("UFConselhoSolicitante")&"', CodigoCBOSolicitante='"&ref("CodigoCBOSolicitante")&"', CaraterAtendimentoID='"&ref("CaraterAtendimentoID")&"', DataSolicitacao="&mydatenull(ref("DataSolicitacao"))&", IndicacaoClinica='"&ref("IndicacaoClinica")&"', TipoAtendimentoID='"&ref("TipoAtendimentoID")&"', MotivoEncerramentoID='"&ref("MotivoEncerramentoID")&"', DataSerie01="&myDateNULL(ref("DataSerie01"))&", DataSerie02="&myDateNULL(ref("DataSerie02"))&", DataSerie03="&myDateNULL(ref("DataSerie03"))&", DataSerie04="&myDateNULL(ref("DataSerie04"))&", DataSerie05="&myDateNULL(ref("DataSerie05"))&", DataSerie06="&myDateNULL(ref("DataSerie06"))&", DataSerie07="&myDateNULL(ref("DataSerie07"))&", DataSerie08="&myDateNULL(ref("DataSerie08"))&", DataSerie09="&myDateNULL(ref("DataSerie09"))&", DataSerie10="&myDateNULL(ref("DataSerie10"))&", Procedimentos="&treatValZero(ref("Procedimentos"))&", TaxasEAlugueis="&treatValZero(ref("TaxasEAlugueis"))&", Materiais="&treatValZero(ref("Materiais"))&", OPME="&treatValZero(ref("OPME"))&", Medicamentos="&treatValZero(ref("Medicamentos"))&", GasesMedicinais="&treatValZero(ref("GasesMedicinais"))&", TotalGeral="&treatValZero(ref("TotalGeral"))&", sysActive=1, tipoContratadoSolicitante='"&tipoContratadoSolicitante&"', tipoProfissionalSolicitante='"&tipoProfissionalSolicitante&"' where id="&I
    '	response.Write(sql)

        call gravaLogs(sql ,"AUTO", "Guia alterada manualmente","")
        db_execute(sql)
        if session("Banco")="clinic522" then
            db_execute("update tissguiasadt set IdentificadorBeneficiario='"&ref("IdentificadorBeneficiario")&"' where id="&I)
        end if
        if ref("identificadorBeneficiario")<>"" then
            db_execute("update tissguiasadt set IdentificadorBeneficiario='"&ref("IdentificadorBeneficiario")&"' where id="&I)
        end if 

        while not datant.eof
            mudouStatus = "S"
            call statusPagto("", datant("PacienteID"), datant("Data"), "P", 0, 0, 0, 0)
        datant.movenext
        wend
        datant.close
        set datant=nothing

        set guia = db.execute("select * from tissguiasadt where id="&I)
        if not redirecionar then
        %>

        
        gtag('event', 'nova_guia_sadt', {
            'event_category': 'guia_sadt',
            'event_label': "Guia SP SADT > Salvar",
        });
        
        if( $.isNumeric($("#PacienteID").val()) )
        {
            //caso tenha gerado pelo checkin, voltar para o checkin
            if(typeof showOriginalCheckinTab === 'function'){
                showOriginalCheckinTab();
            }
            ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico');
            if($('#Checkin').val()=='1'){
                $.get("callAgendamentoProcedimentos.asp?Checkin=1&ConsultaID="+ $("#ConsultaID").val() +"&PacienteID="+ $("#PacienteID").val() +"&ProfissionalID="+ $("#ProfissionalID").val() +"&ProcedimentoID="+ $("#ProcedimentoID").val(), function(data){ $("#divAgendamentoCheckin").html(data) });
            }
        }else{

            <%if isClose = "1" then%>
            window.close();
            <%else%>
            location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaSADT&LoteID=<%=guia("LoteID")%>&Pers=1';
            <%end if%>
        }
        <%
        else
        %>
            
        <%
        end if
    else
        sqlGuiaDisponivel = "SELECT cast(numero as signed integer) numero, id, Tipo FROM  ((SELECT cast(gc.NGuiaPrestador as signed integer) numero, id, 'Consulta' as Tipo FROM tissguiaconsulta gc WHERE gc.ConvenioID = '"&ConvenioID&"') UNION ALL "&_
         "(SELECT cast(gs.NGuiaPrestador as signed integer) numero, id, 'SADT' as Tipo FROM tissguiasadt gs WHERE gs.ConvenioID = '"&ConvenioID&"') UNION ALL "&_
         "(SELECT cast(gh.NGuiaPrestador as signed integer) numero, id, 'Honorário' as Tipo FROM tissguiahonorarios gh WHERE gh.ConvenioID = '"&ConvenioID&"')) as numero WHERE id != "&I&" AND cast(numero as signed integer) >= '"&NGuiaPrestador &"' AND cast(numero as signed integer) < ( 100 + '"&NGuiaPrestador &"') ORDER BY cast(numero as signed integer) DESC LIMIT 1"
        set GuiaDisponivelSQL = db.execute(sqlGuiaDisponivel)

        if not GuiaDisponivelSQL.eof then


            if not isnull(GuiaDisponivelSQL("numero")) then

                GuiaDisponivel = formatnumber(GuiaDisponivelSQL("numero"),2) + 1
            end if
        end if

        %>
        new PNotify({
            title: 'Atenção!',
            text: 'Já existe uma Guia de <%=guiaExiste("Tipo")%> com esta numeração no prestador (<strong><%=NGuiaPrestador%></strong>). <% if GuiaDisponivel<>"" then %> Sugestão: <%=GuiaDisponivel%> <% end if %>',
            icon: 'glyphicon glyphicon-question-sign',
            hide: false,
            type: 'default',
            <%
            if GuiaDisponivel<>"" then
            %>
            confirm: {
                confirm: true,
                buttons: [{
                    text: 'Utilizar o número <%=GuiaDisponivel%>',
                    icon: 'far fa-exclamation-circle',
                    addClass: 'btn-primary',
                    click: function(notice) {
                        $("#NGuiaPrestador").val("<%=GuiaDisponivel%>");

                        $.ajax({
                            type:"POST",
                            url:"SaveGuiaSADT.asp?Tipo=SADT&I=<%=I%>&Forcar=1",
                            data:$("#GuiaSADT").serialize(),
                            success:function(data){
                                eval(data);
                            }
                        });
                    }
                }]
            },
            <%
            end if
            %>
            buttons: {
                closer: true,
                sticker: false
            }
        });
        <%
    end if
end if
%>