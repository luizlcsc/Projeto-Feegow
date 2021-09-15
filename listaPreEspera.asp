<!--#include file="connect.asp"-->
<%
set gui = db.execute("select * from guiche where Sta IN('Espera', 'Atendimento', 'Chamando', 'Chamando pós','Espera pós','Atendimento pós') and (isnull(sysUser) or sysUser="&session("User")&") AND UnidadeID="&treatvalzero(session("UnidadeID"))&" order by DataHoraChegada")

while not gui.eof
    %>
    <div class="well col-sm-3" style="margin: 25px">
        <div class="widget-box">
            <div class="widget-header item-guiche" data-id="<%=gui("id")%>">
                <h5>
                    <%=gui("Sta") %>
                </h5>
                <div class="widget-toolbar">
                <%
                btnChamar = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Chamando')"" class=""btn btn-xs btn-success"">CHAMAR</button> "
                btnChamarPos = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Chamando pós')"" class=""btn btn-xs btn-success"">CHAMAR</button> "
                btnAtender = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Atendimento')"" class=""btn btn-xs btn-primary"">ATENDER!</button> "
                btnAtenderPos = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Atendimento pós')"" class=""btn btn-xs btn-primary"">ATENDER!</button> "
                btnCancelar = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Cancelado')"" class=""btn btn-xs btn-danger""><i class='far fa-remove'></i></button> "
                btnFinalizar = "<button type=""button"" onclick=""saveGuiche('Sta', "&gui("id") &", 'Atendido')"" class=""btn btn-xs btn-info"">FINALIZAR</button> "

                select case gui("Sta")
                    case "Espera"
                        response.Write(btnChamar & btnCancelar)
                    case "Espera pós"
                        LinkPaciente = "#"

                        if gui("PacienteID")&""<>"" then
                            LinkPaciente = "?P=Pacientes&I="&gui("PacienteID")&"&Pers=1"
                            set PacienteSQL = db.execute("SELECT NomePaciente FROM pacientes WHERE id="&gui("PacienteID"))
                            NomePaciente = PacienteSQL("NomePaciente")
                        end if
                        %>
                        <div class="row">
                            <div class="col-md-8">
                                <br>
                                <div class="label label-dark"><a href="<%=LinkPaciente%>" target="_blank"><%=NomePaciente%></a></div>
                            </div>
                            <div class="col-md-4">
                                <br>
                                <%= btnChamarPos %>
                            </div>
                        </div>
                        <%
                    case "Chamando pós"
                        LinkPaciente = "#"
                        NomePaciente=""

                        if gui("PacienteID")&""<>"" then
                            LinkPaciente = "?P=Pacientes&I="&gui("PacienteID")&"&Pers=1"
                            set PacienteSQL = db.execute("SELECT NomePaciente FROM pacientes WHERE id="&gui("PacienteID"))
                            NomePaciente = PacienteSQL("NomePaciente")
                        end if
                        %>
                        <div class="row">
                            <div class="col-md-5">
                                <br>
                                <div class="label label-dark"><a href="<%=LinkPaciente%>" target="_blank"><%=NomePaciente%></a></div>
                            </div>
                            <div class="col-md-2">
                                <br>
                                <%= btnCancelar %>
                            </div>
                            <div class="col-md-5">
                                <br>
                                <%= btnAtenderPos %>
                            </div>
                        </div>
                        <%
                    case "Atendimento pós"
                        LinkPaciente = "#"
                        NomePaciente=""

                        if gui("PacienteID")&""<>"" then
                            LinkPaciente = "?P=Pacientes&I="&gui("PacienteID")&"&Pers=1"
                            set PacienteSQL = db.execute("SELECT NomePaciente FROM pacientes WHERE id="&gui("PacienteID"))
                            NomePaciente = PacienteSQL("NomePaciente")
                        end if
                        %>
                        <div class="row">
                            <div class="col-md-7">
                                <br>
                                <div class="label label-dark"><a href="<%=LinkPaciente%>" target="_blank"><%=NomePaciente%></a></div>
                            </div>
                            <div class="col-md-5">
                                <br>
                                <%= btnFinalizar %>
                            </div>
                        </div>
                        <%
                    case "Chamando"
                        response.Write(btnAtender & btnCancelar)
                    case "Atendimento"
                        LinkPaciente = "#"

                        if gui("PacienteID")&""<>"" then
                            LinkPaciente = "?P=Pacientes&I="&gui("PacienteID")&"&Pers=1"
                        end if
                        %>
                        <div class="row">
                            <div class="col-md-6">
                                <%= selectInsert("", "PacienteID"&gui("id"), gui("PacienteID"), "pacientes", "NomePaciente", " onchange=""atualizaPacienteGuiche(this.id, this.value, '"&gui("id")&"');""", "required", "") %>
                            </div>
                            <div class="col-md-2">
                                <br><a href="<%=LinkPaciente%>" class="btn btn-system btn-xs btn-paciente-pre-espera" target="_blank"><i class="far fa-external-link"></i></a>
                            </div>
                            <div class="col-md-4">
                                <br>
                                <%= btnFinalizar %>
                            </div>
                        </div>
                        <%
                end select
                %>
                </div>
            </div>
            <div class="widget-body text-center">
        
        <h1>
            <small><%=formatdatetime(gui("DataHoraChegada"), 4) %> &raquo; </small>
            <%=zeroEsq(gui("Senha"), 4) %></h1>
            </div>
        </div>
    </div>
    <%
gui.movenext
wend
gui.close
set gui=nothing
%>
