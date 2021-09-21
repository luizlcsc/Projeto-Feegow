<!--#include file="connect.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
set DadosConsulta=db.execute("select * from agendamentos where id="&req("ConsultaID"))
rfTempo=DadosConsulta("Tempo")
rfHora=ref("Hora")
rfProfissionalID=DadosConsulta("ProfissionalID")
rfData=ref("Data")
rfProcedimento=DadosConsulta("TipoCompromissoID")
rfrdValorPlano=DadosConsulta("rdValorPlano")
rfValorPlano=DadosConsulta("ValorPlano")
rfPaciente=DadosConsulta("PacienteID")
rfStaID=ref("StaID")
rfLocal=DadosConsulta("LocalID")
rfNotas=ref("Notas")
ConsultaID="0"
%><!--#include file="errosPedidoAgendamento.asp"--><%
if erro="" then
'"Hora=&Paciente=&Procedimento=&StaConsulta=&Local=&rdValorPlano=&ValorPlano=&DrId=&Data=&Tempo=
		db_execute("insert into agendamentos (PacienteID, ProfissionalID, Data, Hora, TipoCompromissoID, StaID, ValorPlano, rdValorPlano, Notas, FormaPagto, LocalID, Tempo, HoraFinal, sysUser) values ('"&rfPaciente&"','"&rfProfissionalID&"','"&mydate(rfData)&"','"&rfHora&"','"&rfProcedimento&"','"&rfStaID&"',"&treatvalzero(rfValorPlano)&",'"&rfrdValorPlano&"','"&rfNotas&"','0', '"&rfLocal&"','"&rfTempo&"','"&HoraSolFin&"', "&session("User")&")")
		set pultCon=db.execute("select id from agendamentos order by id desc LIMIT 1")
		
        call agendaUnificada("insert", pultCon("id"), rfProfissionalID)

        db_execute("insert into LogsMarcacoes (PacienteID, ProfissionalID, ProcedimentoID, DataHoraFeito, Data, Hora, Sta, Usuario, Motivo, Obs, ARX, ConsultaID, UnidadeID) values ('"&rfPaciente&"', '"&rfProfissionalID&"', '"&rfProcedimento&"', '"&now()&"', '"&mydate(rfData)&"', '"&rfHora&"', '"&rfStaID&"', '"&session("User")&"', '0', '"&rfNotas&"', 'A', '"&pultCon("id")&"'), "&treatvalzero(session("UnidadeID"))&")
		%>
        $.gritter.add({
            title: '<i class="far fa-save"></i> Repetido com sucesso!',
            text: 'Para <%=rfData%> &agrave;s <%=rfHora%>.',
            class_name: 'gritter-success gritter-light'
        });
        loadAgenda('<%=rfData%>', <%= rfProfissionalID %>);
	<%
else
	%>
    $.gritter.add({
        title: '<i class="far fa-thumbs-down"></i> N&Atilde;O REPETIDO!',
        text: '<%=erro%>',
        class_name: 'gritter-error gritter-light'
    });
	<%
end if
%>