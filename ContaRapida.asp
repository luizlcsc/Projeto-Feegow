<!--#include file="connect.asp"-->

<%
'Colocar pra fazer uma lista de guias e receitas desvinculadas de agendamentos e atendimentos.<br>
'Voltar das guias e do a receber para a conta do paciente.

AtendimentoID = req("A")
PacienteID=req("I")
set pac = db.execute("select * from pacientes where id="&PacienteID)
if isnumeric(AtendimentoID) or AtendimentoID<>"" then
	db_execute("update sys_users set notiflanctos=replace(notiflanctos, '|"&AtendimentoID&"|', '')")
end if
%>

<div class="tabbable">
    <ul class="nav nav-tabs" id="myTab">
        <li class="active">
            <a data-toggle="tab" href="#Conta">
                <i class="green icon-money bigger-110"></i>
                Detalhes 
            </a>
        </li>

        <li>
            <a data-toggle="tab" href="#Extrato" id="StatementTab" onclick="getStatement('3_<%=PacienteID%>', '', '')">
                <i class="green icon-exchange bigger-110"></i>
                Extrato
            </a>
        </li>
    </ul>

    <div class="tab-content">
        <div id="Conta" class="tab-pane active">
            <form method="post" id="FormConta" action="./?P=LanctoRapido&Pers=1&PacienteID=<%=PacienteID%>">
                <div class="page-header">
                    <h1>Conta do Paciente <small>&raquo; <a href="./?P=Pacientes&I=<%=PacienteID%>&Pers=1"><i class="far fa-external-link"></i> <%=pac("NomePaciente")%> </a> &raquo; <%= accountBalance("3_"&PacienteID, 1) %></small></h1>
                </div>
                <%
                Data = date()
                set datas = db.execute("select distinct Data from agendamentoseatendimentos where PacienteID="&PacienteID&" and Data="&mydatenull(date())&" order by Data desc")
                if not datas.eof then
                    %>
                    <!--#include file="ContaDetalheRapida.asp"-->
                    <%
                end if
    
                set datas = db.execute("select distinct Data from agendamentoseatendimentos where PacienteID="&PacienteID&" and Data!="&mydatenull(date())&" order by Data desc")
                while not datas.eof
                    Data = datas("Data")
                    %>
					<!--#include file="ContaDetalheRapida.asp"-->
                    <%
                datas.movenext
                wend
                datas.close
                set datas=nothing
                %>
            </form>
        </div>
        <div id="Extrato" class="tab-pane">
        Carregando...
        </div>
    </div>
</div>







































<script>
var myForm = document.getElementById('FormConta');
myForm.onsubmit = function() {
    var w = window.open('about:blank','Popup_Window','toolbar=0,scrollbars=1,location=0,statusbar=0,menubar=0,resizable=1,width=1010,height=700,left = 10,top = 10');
    this.target = 'Popup_Window';
};
<!--#include file="financialCommomScripts.asp"-->
</script>