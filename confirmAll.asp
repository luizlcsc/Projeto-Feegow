<!--#include file="connect.asp"-->

<script type="text/javascript">
    function myFunction(i) {
      /* Get the text field */
      var copyText = document.getElementById(i);

      /* Select the text field */
      copyText.select();

      /* Copy the text inside the text field */
      document.execCommand("copy");

      /* Alert the copied text */
    //      alert("Texto copiado: " + copyText.value);
            $.gritter.add({
            title: '<i class="fa fa-copy"></i> Texto copiado!',
            text: copyText.value,
            class_name: 'gritter-success gritter-light'
        });

    }
    function ca(L, A, StaID) {
        $.post("ConfirmAllSave.asp", {
            L: L,
            A: A,
            StaID: $("#StaID" + A).val(),
            Notas: $("#Notas" + A).val()
        }, function (data) { eval(data) });
    }
</script>

<%


Data = req("Data")
if Data="" then
    Data = date()
end if

%>
<div class="row">
    <form method="get">
        <input type="hidden" name="P" value="ConfirmAll" />
        <input type="hidden" name="Pers" value="1" />
        <%= quickfield("datepicker", "Data", "Data", 3, Data, "", "", "") %>
        <div class="col-md-2">
            <label>&nbsp;</label><br />
            <button class="btn btn-sm">BUSCAR</button>
        </div>
    </form>
</div>


<%

function clearPhone(phone)
    phone = phone&""

    if phone<>"" then
        clearPhone = "55"&replace(replace(replace(replace(phone, "(",""),")", "")," ", ""),"-", "")
    else
        clearPhone = ""
    end if
end function

if session("Partner")<>"" then
    response.Buffer
    set l = db.execute("select id, NomeEmpresa, Servidor from cliniccentral.licencas where Status='C' and Cupom='"& session("Partner") &"' order by NomeEmpresa")
    while not l.eof
        Servidor=l("Servidor")
        LicencaID = l("id")
        LicencaModelo = 5459

        ConnStringS = "Driver={MySQL ODBC 8.0 ANSI Driver};Server="& Servidor &";Database=clinic"& LicencaID &";uid=root;pwd=pipoca453;"
        Set dbS = Server.CreateObject("ADODB.Connection")
        dbS.Open ConnStringS

        set p = dbs.execute("select id, NomeProfissional from clinic"& LicencaID &".profissionais where sysActive=1 and ativo='on' order by NomeProfissional")
        while not p.eof
            response.flush()
            set a = dbs.execute("select a.id, a.StaID, a.Data, a.Hora, a.Notas, pac.NomePaciente, pac.Tel1, pac.Tel2, pac.Cel1, pac.Cel2, proc.NomeProcedimento, s.StaConsulta from clinic"& LicencaID &".agendamentos a LEFT JOIN clinic"& LicencaID &".pacientes pac ON pac.id=a.PacienteID LEFT JOIN clinic"& LicencaID &".procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN StaConsulta s ON s.id=a.StaID where a.ProfissionalID="& p("id") &" and a.Data="& mydatenull(Data) &" order by a.Hora")
            if not a.eof then
                %>
                <h3>DATA: <%= Data %>  -  CLÍNICA: <%= ucase(l("NomeEmpresa")) %></h3>
                <h4>PROFISSIONAL: <%= p("NomeProfissional") %></h4>

                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>Status</th>
                            <th width="50">Hora</th>
                            <th width="20%">Paciente</th>
                            <th width="15%">Procedimento</th>
                            <th width="23%">Observações</th>
                            <th width="23%">Texto whatsapp <i class="fa fa-copy"></i> clique</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        while not a.eof

                            Texto = "Olá, "& a("NomePaciente") &"! Posso confirmar sua consulta com Dr. "& p("NomeProfissional") &" no dia "& Data &" às "& ft(a("Hora")) &"?"

                            Classe = ""
                            if a("StaID")=7 then
                                Classe = "success"
                            elseif a("StaID")=11 then
                                Classe = "danger"
                            end if
                            %>
                            <tr class="<%= Classe %>">
                                <td style="min-width:170px!important"><%= quickfield("simpleSelect", "StaID"&a("id"), "", 4, a("StaID"), "select * from clinic"& LicencaModelo &".StaConsulta", "StaConsulta", " semVazio onchange=""ca("& LicencaID &", "& a("id") &")"" ") %></td>
                                <td><a href="./?P=ChangeLic&I=<%= LicencaID %>&Pers=1&A=<%= a("id") %>" target="_blank" class="btn btn-primary btn-sm"><%= ft(a("Hora")) %></a></td>
                                <td><%= a("NomePaciente") %>
                                    <a target="_blank" href="https://api.whatsapp.com/send?phone=<%= clearPhone(a("Tel1")) %>&text=<%=Texto%>" class="badge"><%= a("Tel1") %></a>
                                    <a target="_blank" href="https://api.whatsapp.com/send?phone=<%= clearPhone(a("Tel2")) %>&text=<%=Texto%>" class="badge"><%= a("Tel2") %></a>
                                    <a target="_blank" href="https://api.whatsapp.com/send?phone=<%= clearPhone(a("Cel1")) %>&text=<%=Texto%>" class="badge"><%= a("Cel1") %></a>
                                    <a target="_blank" href="https://api.whatsapp.com/send?phone=<%= clearPhone(a("Cel2")) %>&text=<%=Texto%>" class="badge"><%= a("Cel2") %></a>

                                </td>
                                <td><%= a("NomeProcedimento") %></td>
                                <td><%= quickfield("memo", "Notas"&a("id"), "", 4, a("Notas"), "", "", " onchange=""ca("& LicencaID &", "& a("id") &")"" ")  %></td>
                                <td><%
                                    if a("StaID")=1 then
                                        call quickfield("memo", "Texto"&a("id"), "", 4, Texto, "", "", "  onclick=""myFunction('Texto"&a("id") &"')"" ")
                                    end if
                                    %></td>
                            </tr>
                            <%
                        a.movenext
                        wend
                        a.close
                        set a = nothing
                        %>
                    </tbody>
                </table>
                <%
            end if
        p.movenext
        wend
        p.close
        set p = nothing
    l.movenext
    wend
    l.close
    set l=nothing
end if
%>

<script type="text/javascript">
    function ca(L, A, StaID) {
        $.post("ConfirmAllSave.asp", {
            L: L,
            A: A,
            StaID: $("#StaID" + A).val(),
            Notas: $("#Notas" + A).val()
        }, function (data) { eval(data) });
    }
</script>

