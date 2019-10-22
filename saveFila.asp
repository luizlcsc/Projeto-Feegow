<!--#include file="connect.asp"--><!--#include file="connectCentral.asp"--><%
rfTempo=request.Form("Tempo")
rfProfissionalID=request.Form("ProfissionalID")
rfData=request.Form("Data")
rfProcedimento=request.Form("ProcedimentoID")
rfrdValorPlano=request.Form("rdValorPlano")
if rfrdValorPlano="V" then
	rfValorPlano=request.Form("Valor")
	if rfValorPlano="" or not isnumeric(rfValorPlano) then
		rfValorPlano=0
	end if
else
	rfValorPlano=request.Form("ConvenioID")
end if
rfPaciente=request.Form("PacienteID")
rfStaID=request.Form("StaID")
if ref("LocalID")="" then
	rfLocal=0
else
	rfLocal=request.Form("LocalID")
end if
rfNotas=ref("Notas")
rfSubtipoProcedimento=0'request.Form("SubtipoProcedimento")'VERIFICAR

if ref("ProcedimentoID")="0" or ref("ProcedimentoID")="" then
	erro = "Selecione um procedimento"
end if

if erro="" then
	'-->Verifica se paciente já tem esse convênio. Se não, cria esse convênio para esse paciente
	if rfrdValorPlano="P" then
		call gravaConvPac(rfValorPlano, rfPaciente)
	end if
	'<--Verifica se paciente, profissional e procedimento já está na fila
	db_execute("update pacientes set Tel1='"&ref("ageTel1")&"', Cel1='"&ref("ageCel1")&"', Email1='"&ref("ageEmail1")&"' where id="&rfPaciente)
	set vca = db.execute("select * from filaespera where PacienteID="&rfPaciente&" and ProfissionalID="&rfProfissionalID)
	if vca.eof then
		sql = "insert into filaespera (PacienteId, ProfissionalID, TipoCompromissoID, ValorPlano, rdValorPlano, Notas, LocalID, Tempo, SubtipoProcedimentoID, sysUser) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&treatVal(rfValorPlano)&"', '"&rfrdValorPlano&"', '"&rfNotas&"', '0', '"&rfTempo&"', '"&rfSubtipoProcedimento&"', '"&session("User")&"')"
	else
		sql = "update filaespera set PacienteId='"&rfPaciente&"', ProfissionalID='"&rfProfissionalID&"', TipoCompromissoID='"&rfProcedimento&"', ValorPlano='"&treatVal(rfValorPlano)&"', rdValorPlano='"&rfrdValorPlano&"', Notas='"&rfNotas&"', LocalID='0', Tempo='"&rfTempo&"', SubtipoProcedimentoID='"&rfSubtipoProcedimento&"', sysUser='"&session("User")&"' where id="&vca("id")
	end if
	db_execute(sql)
	%>
        new PNotify({
            title: 'Fila de espera salva!',
            text: '',
            type: 'success',
            delay:1000
        });
        loadAgenda('<%=rfData%>', <%= rfProfissionalID %>);
       	af('f');
        filaEspera('');
	<%
else
	%>
    new PNotify({
        title: 'ERRO!',
        text: '<%=erro%>',
        type: 'danger',
        delay: 3000
    });
	<%
end if
%>