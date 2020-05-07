<!--#include file="../../connect.asp"-->
<%
profissionalId = session("idInTable")
pacienteId= Request.QueryString("I")
licencaId= replace(session("Banco"),"clinic","")


set shellExec = createobject("WScript.Shell")
Set objSystemVariables = shellExec.Environment("SYSTEM")
AppEnv = objSystemVariables("FC_APP_ENV")

atendimentos = replace(session("Atendimentos"), "|", "")
sqlAgendamento = "SELECT age.id FROM agendamentos age INNER JOIN atendimentos ate ON ate.AgendamentoID=age.id AND ate.id IN ("&atendimentos&") WHERE age.PacienteID="&pacienteId&" AND age.ProfissionalID="&profissionalID&" AND age.StaID in (2)"
set AgendamentoSQL = db.execute(sqlAgendamento)

if not AgendamentoSQL.eof then
    agendamentoId=AgendamentoSQL("id")
    %>
    <script crossorigin  src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
    <script crossorigin  src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>
    <script crossorigin  src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script crossorigin  src="https://unpkg.com/peerjs@1.0.0/dist/peerjs.min.js"></script>
<%
if AppEnv="development" then
%>
    <script crossorigin  src="http://localhost:8000/modules/patientinterface/js/Telemedicine.js?time=123"></script>
<%
else
%>
    <script crossorigin  src="https://api.feegow.com.br/modules/patientinterface/js/Telemedicine.js?time=123"></script>
<%
end if
%>

    <script crossorigin type="text/babel" src="react/telemedicina/Services/TelemedicinaService.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Video.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Controls.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Popup.js?v=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/WherebyiFrame.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/ZoomiFrame.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Header.js"></script>
    <link type="text/css" rel="stylesheet" href="react/telemedicina/src/css/telemedicina.css" />

    <script type="text/babel">
        // document.getElementById('root').innerHTML = `
        //    <div id='tm-popup'>dsadsadsa
    // </div>
    //     `;
        const implementationType = "zoom";

        if(implementationType==="whereby"){
            ReactDOM.render(<WherebyiFrame profissionalId={"<%=profissionalId%>"} licencaId={"<%=licencaId%>"} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }else if(implementationType==="zoom"){
            ReactDOM.render(<ZoomiFrame profissionalId={"<%=profissionalId%>"} licencaId={"<%=licencaId%>"} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }else{
            ReactDOM.render(<Popup profissionalId={"<%=profissionalId%>"} licencaId={"<%=licencaId%>"} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }
    </script>

    <div id="root" class="container-popup">
        <div style="font-size: 50px;text-align: center; padding: 40px">
            <i class="fa fa-spin fa-circle-o-notch"></i>
        </div>
    </div>
    <script >
    setTimeout(() => {
        $(document).ready(function(){
          $('[data-toggle="tooltip"]').tooltip();
        });
    }, 3000);
    $("#root").draggable();
    </script>
<%
end if
%>
