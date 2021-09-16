<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<%
I = rep(req("I"))
GuiaStatus = rep(req("GuiaStatus"))
redirecionar = false
ProcedimentoID=ref("gProcedimentoID")
ConvenioID = ref("gConvenioID")

if req("isRedirect")="S" then
    redirecionar =true
end if

'1. verifica se já tem guia com esse numero nesse convenio, tanto operador quanto prestador

'2. testar se pode guia com data de atendimento futuro e passado, se tiver bloqueio repetir o bloqueio

if isdate(ref("ValidadeCarteira")) and ref("ValidadeCarteira")<>"" then
	ValidadeCarteira = "'"&mydate(ref("ValidadeCarteira"))&"'"
else
	ValidadeCarteira = "NULL"
end if

ObrigarValidade = 0
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


sqlPermitido = "SELECT COALESCE(tpvp.NaoCobre, tpv.NaoCobre)NaoCobre, p.NomeProcedimento FROM tissprocedimentosvalores tpv "&_
"LEFT JOIN tissprocedimentosvaloresplanos tpvp ON tpvp.AssociacaoID=tpv.id AND tpvp.PlanoID="&treatvalzero(PlanoID)&" "&_
"LEFT JOIN procedimentos p ON p.id=tpv.ProcedimentoID "&_
"WHERE tpv.ProcedimentoID="&treatvalzero(ProcedimentoID)&" AND tpv.ConvenioID="&ConvenioID

set ProcedimentoPermitidoSQL = db.execute(sqlPermitido)

if not ProcedimentoPermitidoSQL.eof then
    IF ProcedimentoPermitidoSQL("NaoCobre")="S" then
        erro = "Procedimento "&ProcedimentoPermitidoSQL("NomeProcedimento")&" não é coberto para o convênio/plano selecionado."
    END IF
end if

if erro<>"" then
	%>
    new PNotify({
        title: 'ERRO!',
        text: '<%=erro%>',
        type: 'danger',
        delay: 3500
    });
	<%
else

	'atualiza os dados do paciente, profissional, convenio, contratado e procedimento
    NGuiaPrestador = ref("NGuiaPrestador")
    PlanoID = treatvalzero(ref("PlanoID"))
    've se ja existe alguma guia deste convenio, com esta numeracao no prestador. se existir, mostra mensagem
    sqlGuia = "SELECT numero, id, Tipo FROM  ((SELECT cast(gc.NGuiaPrestador as signed integer) numero, id, 'Consulta' as Tipo FROM tissguiaconsulta gc WHERE gc.ConvenioID = '"&ConvenioID&"' AND gc.NGuiaPrestador='"&NGuiaPrestador&"') UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer) numero, id, 'SADT' as Tipo FROM tissguiasadt gs WHERE gs.ConvenioID = '"&ConvenioID&"' AND gs.NGuiaPrestador='"&NGuiaPrestador&"') UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer) numero, id, 'Honorário' as Tipo FROM tissguiahonorarios gh WHERE gh.ConvenioID = '"&ConvenioID&"' AND gh.NGuiaPrestador='"&NGuiaPrestador&"')) as numero WHERE id != "&I&" AND numero = '"&NGuiaPrestador&"'"
    set guiaExiste = db.execute(sqlGuia)

    forcarSalvar = req("Forcar")

    if guiaExiste.eof or ForcarSalvar = "1" then

        if BloquearAlteracoes=0 then
            db_execute("update pacientes set CNS='"&ref("CNS")&"' where id="&ref("gPacienteID"))
        end if

        call gravaConvPac(ref("gConvenioID"), ref("gPacienteID"))

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
            db_execute("update pacientes set PlanoID"&Numero&"='"&ref("PlanoID")&"', Matricula"&Numero&"='"&ref("NumeroCarteira")&"', Validade"&Numero&"="&ValidadeCarteira&" where id="&ref("gPacienteID"))
        end if

        set cbo=db.execute("select * from especialidades where codigoTISS = '"&ref("CodigoCBO")&"' and sysActive=1")
        if not cbo.eof then
            EspecialidadeID = cbo("id")
        else
            EspecialidadeID = 0
        end if
        if BloquearAlteracoes=0 and false then
            db_execute("update profissionais set Conselho="&treatvalnull(ref("Conselho"))&", DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"' where id="&ref("gProfissionalID"))

            db_execute("update convenios set RegistroANS='"&ref("RegistroANS")&"' where id="&ref("gConvenioID"))
            set vcaConvenioContratado = db.execute("select * from contratosconvenio where ConvenioID="&ref("gConvenioID")&" and Contratado="&ref("Contratado"))
            if not vcaConvenioContratado.eof then
                db_execute("update contratosconvenio set CodigoNaOperadora='"&ref("CodigoNaOperadora")&"' where id="&vcaConvenioContratado("id"))
            else
                db_execute("insert into contratosconvenio (ConvenioID, Contratado, ContaRecebimento, CodigoNaOperadora, sysUser, sysActive) values ("&ref("gConvenioID")&", "&ref("Contratado")&", 0, '"&ref("CodigoNaOperadora")&"', "&session("User")&", 1)")
            end if
        end if



        if BloquearAlteracoes=0 and ref("Contratado")<>"" and ref("Contratado")<>"FALSE" then
            Contratado = ccur(ref("Contratado"))

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

        if BloquearAlteracoes=0 then
            'procedimento na tabela
            sqlPT = "select * from tissprocedimentostabela where Codigo='"&trim(ref("CodigoProcedimento"))&"' and TabelaID="&ref("TabelaID")
            set pt = db.execute(sqlPT)
            if pt.eof then
                db_execute("insert into tissprocedimentostabela (Codigo, Descricao, TabelaID, sysActive, sysUser) values ('"&trim(ref("CodigoProcedimento"))&"', '"&trim(ref("searchProcedimentoID"))&"', '"&ref("TabelaID")&"', 1, "&session("User")&")")
                set pt = db.execute(sqlPT)
            end if

            'tabela de valores gerais do proc. no convênio (não no plano)
            set pv = db.execute("select * from tissprocedimentosvalores where ProcedimentoID="&treatvalzero(ProcedimentoID)&" and ConvenioID="&treatvalzero(ref("gConvenioID")))
            if pv.eof then
                db_execute("insert into tissprocedimentosvalores (ProcedimentoID, ConvenioID, ProcedimentoTabelaID, Valor, TecnicaID, NaoCobre) values ('"&ProcedimentoID&"', '"&ref("gConvenioID")&"', "&pt("id")&", "&treatvalzero(ref("ValorProcedimento"))&", 1, '')")
            else
                if ref("PlanoID")="0" or ref("PlanoID")="" then
                    db_execute("update tissprocedimentosvalores set ProcedimentoTabelaID="&pt("id")&", Valor="&treatvalzero(ref("ValorProcedimento"))&" where id="&pv("id"))
                else
                    set pvp = db.execute("select * from tissprocedimentosvaloresplanos where AssociacaoID="&pv("id")&" and PlanoID="&PlanoID)
                    if pvp.eof then
                        db_execute("insert into tissprocedimentosvaloresplanos (AssociacaoID, PlanoID, Valor, NaoCobre) values ("&pv("id")&", "&PlanoID&", "&treatvalnull(ref("ValorProcedimento"))&", '')")
                    else
                        db_execute("update tissprocedimentosvaloresplanos set Valor="&treatvalnull(ref("ValorProcedimento"))&" where id="&pvp("id"))
                    end if
                end if
            end if
        end if
        set datant = db.execute("select PacienteID, DataAtendimento from tissguiaconsulta where id="&I)'tem q ser antes pra pegar os dados antes do update
        '//-> fim do atualiza os dados do paciente, profissional, convenio, contratado e procedimento
            if GuiaStatus <> "" then 
                GuiaStatus = "guiastatus="&GuiaStatus&" , "
            end if
            if ref("GuiaSimplificada") = 1 then
                GuiaSimplificada = 1
            else
                GuiaSimplificada = 0
            end if
            sql = "update tissguiaconsulta set "&GuiaStatus&"  UnidadeID='"&ref("UnidadeID")&"', PacienteID='"&ref("gPacienteID")&"', CNS='"&ref("CNS")&"', NumeroCarteira='"&ref("NumeroCarteira")&"', ValidadeCarteira="&ValidadeCarteira&", AtendimentoRN='"&ref("AtendimentoRN")&"', ConvenioID='"&ref("gConvenioID")&"', PlanoID='"&ref("PlanoID")&"', RegistroANS='"&ref("RegistroANS")&"', NGuiaPrestador='"&NGuiaPrestador&"', NGuiaOperadora='"&ref("NGuiaOperadora")&"', Contratado='"&ref("Contratado")&"', CodigoNaOperadora='"&ref("CodigoNaOperadora")&"', CodigoCNES='"&ref("CodigoCNES")&"', ProfissionalID='"&ref("gProfissionalID")&"', Conselho="&treatvalnull(ref("Conselho"))&", DocumentoConselho='"&ref("DocumentoConselho")&"', UFConselho='"&ref("UFConselho")&"', CodigoCBO='"&ref("CodigoCBO")&"', IndicacaoAcidenteID='"&ref("IndicacaoAcidenteID")&"', DataAtendimento='"&mydate(ref("DataAtendimento"))&"', TipoConsultaID='"&ref("TipoConsultaID")&"', ProcedimentoID='"&ref("gProcedimentoID")&"', TabelaID='"&ref("TabelaID")&"', CodigoProcedimento='"&ref("CodigoProcedimento")&"', ValorProcedimento='"&treatval(ref("ValorProcedimento"))&"', Observacoes='"&ref("Observacoes")&"', sysActive=1, AtendimentoID="&treatvalzero(ref("AtendimentoID"))&", AgendamentoID="&treatvalzero(ref("AgendamentoID"))&", ProfissionalEfetivoID="&treatvalnull(ref("ProfissionalEfetivoID"))&", identificadorBeneficiario='"&ref("IdentificadorBeneficiario")&"', GuiaSimplificada='"&GuiaSimplificada&"' where id="&I

            call gravaLogs(sql ,"AUTO", "Guia alterada manualmente","")
            db_execute(sql)

            set guia = db.execute("select * from tissguiaconsulta where id="&I)

            if not redirecionar then
            %>

        
            gtag('event', 'nova_consulta', {
                'event_category': 'guia_consulta',
                'event_label': "Guia Consulta > Salvar",
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

                location.href='./?P=tissbuscaguias&ConvenioID=<%=guia("ConvenioID")%>&T=GuiaConsulta&LoteID=<%=guia("LoteID")%>&Pers=1';
            }
            <%
            else
             %>
             
            <%
            end if

            if not datant.eof then
                if not isnull(datant("DataAtendimento")) then
                    DataAnterior = datant("DataAtendimento")
                    PacienteAnterior = datant("PacienteID")
                end if
                if isdate(ref("DataAtendimento")) then
                    DataAtual = cdate(ref("DataAtendimento"))
                    if DataAtual<>DataAnterior then
                        if DataAnterior<>"" and isdate(DataAnterior) then
                            call statusPagto("", PacienteAnterior, DataAnterior, "P", 0, 0, 0, 0)
                        end if
                    end if
                   call statusPagto("", ref("gPacienteID"), ref("DataAtendimento"), "P", 0, 0, 0, 0)
                    %>
                     loadAgenda($("#Data").val(), $("#ProfissionalID").val());
                    <%
                end if
            end if
    else
        sqlGuiaDisponivel = "SELECT numero, id, Tipo FROM  ((SELECT cast(gc.NGuiaPrestador as signed integer) numero, id, 'Consulta' as Tipo FROM tissguiaconsulta gc WHERE gc.ConvenioID = '"&ConvenioID&"' and gc.sysActive=1) UNION ALL "&_
         "(SELECT cast(gs.NGuiaPrestador as signed integer) numero, id, 'SADT' as Tipo FROM tissguiasadt gs WHERE gs.ConvenioID = '"&ConvenioID&"' and gs.sysActive=1) UNION ALL "&_
         "(SELECT cast(gh.NGuiaPrestador as signed integer) numero, id, 'Honorário' as Tipo FROM tissguiahonorarios gh WHERE gh.ConvenioID = '"&ConvenioID&"' AND gh.sysActive=1)) as numero WHERE id != "&I&" AND cast(numero as signed integer) >= "&NGuiaPrestador &" AND cast(numero as signed integer) < ( 100 + "&NGuiaPrestador &") ORDER BY cast(numero as signed integer) DESC LIMIT 1"

        set GuiaDisponivelSQL = db.execute(sqlGuiaDisponivel)

        if not GuiaDisponivelSQL.eof then
            GuiaDisponivel = ccur(GuiaDisponivelSQL("numero")) + 1
        end if

        %>
        new PNotify({
            title: 'Atenção!',
            text: 'Já existe uma Guia de <%=guiaExiste("Tipo")%> com esta numeração no prestador (<strong><%=NGuiaPrestador%></strong>). Sugestão: <%=GuiaDisponivel%>',
            icon: 'glyphicon glyphicon-question-sign',
            hide: false,
            type: 'default',
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
                            url:"SaveGuia.asp?Tipo=Consulta&I=<%=I%>&Forcar=1",
                            data:$("#GuiaConsulta").serialize(),
                            success:function(data){
                                eval(data);
                            }
                        });
                    }
                }]
            },
            buttons: {
                closer: true,
                sticker: false
            }
        });
        <%
    end if
end if
%>