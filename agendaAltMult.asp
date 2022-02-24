<!--#include file="connect.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
ProfissionalID = ref("ProfissionalID")
Data = ref("Data")
DataOri = req("DataOri")
ProfOri = req("ProfOri")
NovaData = ref("NovaData")
NovoProfissionalID = ref("NovoProfissionalID")

if NovaData="" then
    NovaData=Data
end if
if NovoProfissionalID="" then
    NovoProfissionalID=ProfissionalID
end if

if Data<>"" then
    if cdate(Data)<date() then

        %>
    <div class="panel">
        <div class="panel-body">
            <div class="alert alert-warning"><i class="far fa-exclamation-circle"></i> Não é possível transferir agendas de datas passadas.</div>
        </div>
    </div>
        <%
        Response.End
    end if
    %>
<div class="panel">
    <div class="panel-heading">
        <span class="panel-title">Alterações em Massa - <%= nameInAccount("5_"& ProfissionalID) %> <small id="especialidadesProfissional"></small> - <%= Data %></span>
    </div>
    <div class="panel-body">

        <div class="row">
            <%= quickfield("datepicker", "NovaData", "Nova Data", 4, NovaData, "", "", "") %>
            <div class="col-md-6">
                <label>Transferir para agenda de</label>
                <select class="form-control" id="NovoProfissionalID" name="NovoProfissionalID">
                    <%
                    DiaSemana = weekday(NovaData)
                    set ProfissionaisComGradeSQL = db.execute("SELECT GROUP_CONCAT(DISTINCT ProfissionalID) profissionaisComGrade FROM ( "&_
                                                              "SELECT ProfissionalID FROM assfixalocalxprofissional WHERE DiaSemana = "&DiaSemana&" AND CURDATE() BETWEEN COALESCE(InicioVigencia,CURDATE())AND COALESCE(FimVigencia,CURDATE()) "&_
                                                              "UNION ALL "&_
                                                              "SELECT ProfissionalID FROM assperiodolocalxprofissional WHERE DataDe BETWEEN "&mydatenull(NovaData)&" AND "&mydatenull(NovaData)&" "&_
                                                              ")t")

                    profissionaisComGrade = ProfissionaisComGradeSQL("profissionaisComGrade")
                    set p = db.execute("select p.id, p.NomeSocial, p.NomeProfissional, p.EspecialidadeID, e.Especialidade from profissionais p LEFT JOIN especialidades e ON e.id=p.EspecialidadeID where p.sysActive=1 and p.ativo='on' and p.id IN ("&profissionaisComGrade&") order by p.NomeProfissional")
                    
                    if p.eof then
                        %>
                        <option>Nenhum profissional disponível</option>
                        <%
                    else
                        while not p.eof
                            if p("NomeSocial")&""="" then
                                NomeProfissional = p("NomeProfissional")
                            else
                                NomeProfissional = p("NomeSocial")
                            end if
                            if isnull(p("EspecialidadeID")) then
                                sqlEsp = " "
                            else
                                sqlEsp = " or e.id= "& p("EspecialidadeID") &" "
                            end if
                            Especialidades = p("Especialidade")&""
                            set pesp = db.execute("select group_concat(e.Especialidade SEPARATOR ', ') esps from especialidades e left join profissionaisespecialidades pe on pe.EspecialidadeID=e.id where pe.ProfissionalID="& p("id") )
                            if not pesp.eof then
                                Especialidades = Especialidades & ", "& pesp("esps")
                            end if
                            if right(Especialidade, 1)="," then
                                'Especialidades = left(Especialidades, len(Especialidades)-2)
                            end if
                            Especialidades = replace(lcase(Especialidades), "médico ", "")
                            %>
                            <option value="<%= p("id") %>" <% if p("id")=ccur(NovoProfissionalID) then response.write(" selected ") end if %> ><%= NomeProfissional &" - "& Especialidades %></option>
                            <%
                            if p("id")=ccur(ProfissionalID) then
                                despecialidadesProfissional = Especialidades
                            end if
                        p.movenext
                        wend
                        p.close
                        set p = nothing
                    end if
                    
                    %>
                </select>
                <%
                if despecialidadesProfissional<>"" then
                    %>
                    <script>
                    $("#especialidadesProfissional").html("<%= despecialidadesProfissional %>");
                    </script>
                    <%
                end if
                    
                %>
            </div>
        </div>

        <hr class="short alt" />

        <div class="row">
            <div class="col-md-12">
                <table class="table table-hover">
                    <thead>
                        <tr class="success">
                            <th width="1%">
                                <input type="checkbox" id="checkAll" onclick="$('input[name=agMassa]').prop('checked', $(this).prop('checked'))" />
                            </th>
                            <th width="1%"></th>
                            <th>Hora</th>
                            <th>Paciente</th>
                            <th>Procedimento</th>
                            <th>Especialidade</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    sqlAgendamentos = "select (select ag_ocupada.id FROM agendamentos ag_ocupada WHERE ag_ocupada.ProfissionalID="&treatvalzero(NovoProfissionalID)&" AND ag_ocupada.Data="&mydatenull(NovaData)&" AND ag_ocupada.Hora=a.Hora LIMIT 1) HorarioOcupado, a.id, a.Hora, a.StaID, p.NomePaciente, proc.NomeProcedimento, e.Especialidade "&_
                    "from agendamentos a "&_
                    "INNER JOIN pacientes p ON p.id=a.PacienteID  "&_
                    "LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID  "&_
                    "LEFT JOIN especialidades e ON e.id=a.EspecialidadeID  "&_
                    "where a.ProfissionalID="& ProfissionalID &" and a.Data="& mydatenull(Data) &"  "&_
                    "order by a.Hora"
                    set ag = db.execute(sqlAgendamentos)

                    while not ag.eof
                        ClasseTR=""
                        if ag("HorarioOcupado")&"" <> "" then
                            ClasseTR="warning"
                        end if

                        %>
                        <tr class="<%=ClasseTR%>">
                            <td>
                                <input type="checkbox" id="ag<%= ag("id") %>" name="agMassa" value="<%= ag("id") %>" />
                            </td>
                            <td width="1%"><%=imoon(ag("StaID"))%></td>
                            <td>
                                <span <% if ag("HorarioOcupado")&"" <> "" then %>class="text-danger" data-toggle="tooltip" title="Horário já preenchido na grade do profissional" <% end if%>>
                                <%= ft(ag("Hora")) %>
                                <%
                                if ag("HorarioOcupado")&"" <> "" then
                                    %>
                                    <i class="far fa-info-circle " ></i>
                                    <%
                                end if
                                %>
                                </span>
                            </td>
                            <td><%= ag("NomePaciente") %></td>
                            <td><%= ag("NomeProcedimento") %></td>
                            <td><%= ag("Especialidade") %></td>
                        </tr>
                        <%
                    ag.movenext
                    wend
                    ag.close
                    set ag = nothing
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="panel-footer">
        <div class="row">
            <div class="col-md-12 text-right">
                <button class="btn btn-primary" type="button" onclick="transMassa()"><i class="far fa-exchange"></i> Transferir</button>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function transMassa() {
            if(confirm("Tem certeza que deseja transferir os agendamentos selecionados? Esta ação não poderá ser desfeita.")){
                $.post("agendaAltMult.asp?DataOri=<%=Data%>&ProfOri=<%=ProfissionalID%>", $("input[name=agMassa], #NovoProfissionalID, #NovaData").serialize(), function (data) {
                    $("#ProfissionalID").val($("#NovoProfissionalID").val());
                    $("#ProfissionalID").select2();
                    $("#Data").val($("#NovaData").val());
                    loadAgenda($("#NovaData").val(), $("#NovoProfissionalID").val());
                    $("#modal-table").modal("hide");
                });
            }
        }

        <!--#include file="JQueryFunctions.asp"-->
    </script>
    <%
else
    if ref("agMassa")<>"" then

        set profissionalAntigoSQL = db.execute("SELECT ProfissionalID FROM agendamentos WHERE id in("& ref("agMassa") &")")
        if not profissionalAntigoSQL.eof then
            ProfissionalIDAntigo=profissionalAntigoSQL("ProfissionalID")
        end if

        db.execute("update agendamentos set Data="& mydatenull(ref("NovaData")) &", ProfissionalID="& ref("NovoProfissionalID") &" where id in("& ref("agMassa") &")")

        call agendaUnificada("update", ref("agMassa"), ProfissionalIDAntigo)
    end if
%>
</div>
<%
end if
    %>
<script>
$('[data-toggle="tooltip"]').tooltip();

$(document).ready(function(){
    $("#NovaData, #NovoProfissionalID").change(function(){
        altMult('<%=ProfissionalID%>', '<%=Data%>', $("#NovaData").val(), $("#NovoProfissionalID").val());
    });
});
</script>