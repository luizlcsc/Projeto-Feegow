<!--#include file="../../connect.asp"-->
<%
profissionalId = session("idInTable")
pacienteId= req("I")
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
<%
if AppEnv="development" then
%>
        <script crossorigin  src="react/src/react.development.js"></script>
        <script crossorigin  src="react/src/react-dom.development.js"></script>
        <script crossorigin  src="http://localhost:8000/modules/patientinterface/js/Telemedicine.js?time=123"></script>
<%
else
%>
        <script crossorigin  src="react/src/react.production.min.js"></script>
        <script crossorigin  src="react/src/react-dom.production.min.js"></script>
        <script crossorigin  src="https://api.feegow.com.br/modules/patientinterface/js/Telemedicine.js?time=123"></script>
<%
end if
%>

        <script crossorigin  src="react/src/babel.min.js"></script>
        <script crossorigin  src="react/src/peerjs.min.js"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/Services/TelemedicinaService.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Video.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Controls.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Popup.js??ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/WherebyiFrame.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/ZoomiFrame.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/PopupNative.js?ch=1"></script>
    <script crossorigin type="text/babel" src="react/telemedicina/components/Header.js?ch=1"></script>
    <link type="text/css" rel="stylesheet" href="react/telemedicina/src/css/telemedicina.css?ch=1" />
    <style>
        .screen{
            min-width:400px !important;

        }
        iframe{
            height: 350px;
        }
    </style>
    <script type="text/babel">
        var implementationType = "native";
        const licencaId="<%=licencaId%>";

        let allowVideoChange = false;

        if(localStorage.getItem("telemedicine_default_app") === "zoom" && allowVideoChange )
        {
            implementationType = "zoom";
        }

        if(implementationType==="whereby"){
            ReactDOM.render(<WherebyiFrame profissionalId={"<%=profissionalId%>"} licencaId={"<%=licencaId%>"} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }else if(implementationType==="zoom"){
            $("#root").addClass("screen");
            ReactDOM.render(<ZoomiFrame allowVideoChange={allowVideoChange} profissionalId={"<%=profissionalId%>"} licencaId={licencaId} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }else if(implementationType==="native"){
            $("#root").addClass("screen");
            ReactDOM.render(<PopupNative allowVideoChange={allowVideoChange} profissionalId={"<%=profissionalId%>"} licencaId={licencaId} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }else{
            ReactDOM.render(<Popup allowVideoChange={allowVideoChange} profissionalId={"<%=profissionalId%>"} licencaId={"<%=licencaId%>"} pacienteId={"<%=pacienteId%>"} agendamentoId={"<%=agendamentoId%>"} env={"<%=AppEnv%>"}/>,document.getElementById('root'));
        }
    </script>

    <div id="root" class="container-popup" >
        <div style="font-size: 50px;text-align: center; padding: 40px">
            <i class="far fa-spin fa-circle-o-notch"></i>
        </div>
    </div>
    <script >
        $("#root").on('load',function(){
            if(implementationType == "zoom"){
                 $("#root").css({"min-width":"400px !important"});
            }

        });
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
