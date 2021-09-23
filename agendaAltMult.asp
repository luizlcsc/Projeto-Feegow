<!--#include file="connect.asp"-->
<!--#include file="AgendamentoUnificado.asp"-->
<%
ProfissionalID = ref("ProfissionalID")
Data = ref("Data")
DataOri = req("DataOri")
ProfOri = req("ProfOri")

if Data<>"" then
    %>

    <div class="panel-heading">
        <span class="panel-title">Alterações em Massa - <%= nameInAccount("5_"& ProfissionalID) %> <small id="especialidadesProfissional"></small> - <%= Data %></span>
    </div>
    <div class="panel-body">

        <div class="row">
            <div class="col-md-6">
                <label>Transferir para agenda de</label>
                <select class="form-control" id="NovoProfissionalID" name="NovoProfissionalID">
                    <%
                    set p = db.execute("select p.id, p.NomeSocial, p.NomeProfissional, p.EspecialidadeID, e.Especialidade from profissionais p LEFT JOIN especialidades e ON e.id=p.EspecialidadeID where p.sysActive=1 and p.ativo='on' order by p.NomeProfissional")
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
                        <option value="<%= p("id") %>" <% if p("id")=ccur(ProfissionalID) then response.write(" selected ") end if %> ><%= NomeProfissional &" - "& Especialidades %></option>
                        <%
                        if p("id")=ccur(ProfissionalID) then
                            despecialidadesProfissional = Especialidades
                        end if
                    p.movenext
                    wend
                    p.close
                    set p = nothing
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
            <%= quickfield("datepicker", "NovaData", "Nova Data", 4, Data, "", "", "") %>
        </div>

        <hr class="short alt" />

        <div class="row">
            <div class="col-md-12">
                <table class="table table-hover">
                    <thead>
                        <tr class="warning">
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
                    set ag = db.execute("select a.id, a.Hora, a.StaID, p.NomePaciente, proc.NomeProcedimento, e.Especialidade from agendamentos a LEFT JOIN pacientes p ON p.id=a.PacienteID LEFT JOIN procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN especialidades e ON e.id=a.EspecialidadeID where a.ProfissionalID="& ProfissionalID &" and Data="& mydatenull(Data) &" order by a.Hora")
                    while not ag.eof
                        %>
                        <tr>
                            <td>
                                <input type="checkbox" id="ag<%= ag("id") %>" name="agMassa" value="<%= ag("id") %>" />
                            </td>
                            <td width="1%"><img src="assets/img/<%= ag("StaID") %>.png" /></td>
                            <td><%= ft(ag("Hora")) %></td>
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
            $.post("agendaAltMult.asp?DataOri=<%=Data%>&ProfOri=<%=ProfissionalID%>", $("input[name=agMassa], #NovoProfissionalID, #NovaData").serialize(), function (data) {
                $("#ProfissionalID").val($("#NovoProfissionalID").val());
                $("#ProfissionalID").select2();
                $("#Data").val($("#NovaData").val());
                loadAgenda($("#NovaData").val(), $("#NovoProfissionalID").val());
                $("#modal-table").modal("hide");
            });
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

end if
    %>