<!--#include file="Classes/Connection.asp"--><!--#include file="connect.asp"-->

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
            title: '<i class="far fa-copy"></i> Texto copiado!',
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

function getWppLink(Celular, Mensagem)
    getWppLink=""
    if len(Celular) > 7 then
        getWppLink="<a target='_blank' href='whatsapp://send?phone="&clearPhone(Celular) &"&text="&Mensagem&"' class='badge'>"&Celular&"</a>"
    end if
end function

Data = req("Data")
Status = req("Status")

if Status="" then
   ' Status= "|1|,|7|,|11|"
    Status= "|1|"
end if
if Data="" then
    Data = date()
end if

%>
<script >

    $(".crumb-active a").html("Confirmação de agendamentos");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-icon a span").attr("class", "far fa-check");

</script>
<%
if session("Partner")="" and LicenseId<>5459 then
    Response.End
end if

queryLicencas = "select lic.Servidor, lic.id, lic.NomeEmpresa FROM cliniccentral.licencas lic WHERE lic.status='C' AND lic.Cupom='"& session("Partner") &"' "
if LicenseId=5459 then
    queryLicencas = "select lic.Servidor, lic.id, lic.NomeEmpresa FROM cliniccentral.licencas lic JOIN cliniccentral.clientes_servicosadicionais sa ON sa.LicencaID=lic.id WHERE lic.status='C' AND sa.`Status`=4 AND sa.ServicoID=47  "
end if
%>
<div class="row">
    <br>
    <div class="col-md-12">
        <div class="panel">
            <div class="panel-body">
                <form method="get">
                    <input type="hidden" name="P" value="ConfirmAll" />
                    <input type="hidden" name="Pers" value="1" />
                    <%= quickfield("datepicker", "Data", "Data", 3, Data, "", "", "") %>
                    <%=quickfield("multiple", "Licencas", "Licenças", 3, req("Licencas"), queryLicencas& "order by NomeEmpresa" , "NomeEmpresa", "") %>
                    <%=quickfield("multiple", "Status", "Status", 3, Status, "select id, StaConsulta FROM staconsulta order by StaConsulta" , "StaConsulta", "") %>
                    <div class="col-md-2">
                        <label>&nbsp;</label><br />
                        <button class="btn btn-sm btn-primary"><i class="far fa-search"></i> BUSCAR</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
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

Licencas = req("Licencas")

if Licencas="" then
    %>
    <div class="alert alert-default"><i class="far fa-exclamation-circle"></i> Selecione uma licença acima.</div>
    <%
elseif session("Partner")<>"" or LicenseId=5459 then
    response.Buffer


    if Licencas<>"" then
        queryLicencas = queryLicencas&" AND lic.id IN ("&replace(Licencas, "|", "")&") "
    end if

    set l = db.execute(queryLicencas)
    while not l.eof
        Servidor=l("Servidor")
        LicencaID = l("id")
        LicencaModelo = 5459

        Set dbS = newConnection("clinic"& LicencaID, Servidor)

        sqlProf = "select prof.id, CONCAT(IFNULL(concat(trat.Tratamento,' '),''),prof.NomeProfissional)NomeProfissional from clinic"& LicencaID &".profissionais prof LEFT JOIN clinic"& LicencaID &".agendamentos ag ON ag.Data="& mydatenull(Data) &" AND ag.ProfissionalID=prof.id AND ag.StaID IN ("&replace(Status,"|","")&") LEFT JOIN clinic"& LicencaID &".tratamento trat on trat.id=prof.TratamentoID where prof.sysActive=1 and prof.ativo='on'  GROUP BY prof.id HAVING count(ag.id) > 0 order by prof.NomeProfissional"
        set p = dbs.execute(sqlProf)

        if not p.eof then

        NomeEmpresa=ucase(l("NomeEmpresa"))

%>
<div class="panel">
    <div class="panel-heading mt10"><span class="panel-title"><code>#<%= LicencaID %></code>  <strong><%= NomeEmpresa %></strong></span></div>
<div class="panel-body">

<%


        sqlData="  a.Data="&mydatenull(data)


     set NumeroConfirmadosSQL = dbs.execute("SELECT count(a.id)numero FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE "&sqlData&" AND a.sysActive=1 AND StaID=7" )
        sqlAgendados = "SELECT count(a.id)numero FROM agendamentos a LEFT JOIN locais l ON l.id=a.LocalID WHERE "&sqlData&" AND a.sysActive=1 AND StaID IN (1,7)"

        set NumeroAgendadosSQL = dbs.execute(sqlAgendados)

        NumeroConfirmados=cint(NumeroConfirmadosSQL("numero"))
        NumeroAgendados=cint(NumeroAgendadosSQL("numero"))


        if NumeroAgendados=0 then
            Percentual = 0
        else
            Percentual = (NumeroConfirmados / NumeroAgendados) * 100
        end if

        if Percentual < 30 then
            PercentualClasse="danger"
        elseif Percentual < 70 then
            PercentualClasse="warning"
        else
            PercentualClasse="success"
        end if

        Percentual= round(Percentual, 0)
        %>
        <div class="row">
            <div class="col-md-4">

                <div class="progress">
                  <div class="progress-bar progress-bar-<%=PercentualClasse%>" role="progressbar" aria-valuenow="<%=Percentual%>"
                  aria-valuemin="0" aria-valuemax="100" style="width:<%=Percentual%>%">
                    <%=Percentual%>% Confirmada
                  </div>
                </div>
            </div>

        </div>
<table class="table table-striped table-hover">
    <thead>
        <tr class="primary">
            <th width="10%">Status</th>
            <th width="50">Data</th>
            <th width="50">Hora</th>
            <th width="20%">Paciente</th>
            <th width="20%">Contato</th>
            <th width="15%">Procedimento</th>
            <th width="23%">Observações</th>
            <th width="23%">Texto whatsapp <i class="far fa-copy"></i> (Clique)</th>
        </tr>
    </thead>
    <tbody>
<%
        while not p.eof
            response.flush()
            set a = dbs.execute("select a.id, a.StaID, a.Data, a.Hora, a.Notas, pac.NomePaciente, pac.Tel1, pac.Tel2, pac.Cel1, pac.Cel2, proc.NomeProcedimento, s.StaConsulta from clinic"& LicencaID &".agendamentos a LEFT JOIN clinic"& LicencaID &".pacientes pac ON pac.id=a.PacienteID LEFT JOIN clinic"& LicencaID &".procedimentos proc ON proc.id=a.TipoCompromissoID LEFT JOIN StaConsulta s ON s.id=a.StaID where a.ProfissionalID="& p("id") &" and a.Data="& mydatenull(Data) &" and a.StaID IN ("&replace(Status,"|","")&") and a.sysActive=1 order by a.Hora")
            if not a.eof then
                %>
                <tr class="dark">
                    <th colspan="8" class="text-center"><%= p("NomeProfissional") %></th>
                </tr>


                        <%
                        while not a.eof
                            QuebraDeLinha="%0a%0a"

                            QuebraDeLinha="  "

                            Texto = "Olá, *"& a("NomePaciente") &"*! Posso confirmar sua consulta com *"& p("NomeProfissional") &"*  no dia *"& Data &"* às *"& ft(a("Hora")) &"*?"&QuebraDeLinha&"_Este horário foi especialmente reservado para você, portanto, se não puder comparecer não deixe de nos avisar, assim podemos liberar seu horário para outro paciente._ "&QuebraDeLinha&" _Obrigada!_"

                            Classe = ""
                            if a("StaID")=7 then
                                Classe = "success"
                            elseif a("StaID")=11 then
                                Classe = "danger"
                            end if
                            %>
                            <tr data-id="<%=a("id")%>" class="<%= Classe %>">
                                <td>
                                <%
                                StatusSelect = "<div class='btn-group mb10'><button style='background-color:#fff' class='btn btn-sm dropdown-toggle' data-toggle='dropdown' aria-expanded='false'  > <span class='label-status'><img data-toggle='tooltip' title='"&a("StaConsulta")&"' src='assets/img/"&a("StaID")&".png' /></span>  <i class='far fa-angle-down icon-on-right'></i></button><ul class='dropdown-menu dropdown-danger'>"
                                set StatusSQL=dbS.execute("SELECT id, StaConsulta FROM staconsulta WHERE id IN (1,11,7, 116)")
                                while not StatusSQL.eof
                                    Active=""
                                    if StatusSQL("id")=a("StaID") then
                                        Active=" active "
                                    end if
            
                                    StatusSelect = StatusSelect&"<li class='"&Active&"'><a data-value='"&StatusSQL("id")&"' onclick=""ChangeStatus("& LicencaID &", '"&StatusSQL("id")&"','"&a("id")&"')"" style='cursor:pointer' class='muda-status'><img src='assets/img/"&StatusSQL("id")&".png'> "&StatusSQL("StaConsulta")&"</a></option>"
                                StatusSQL.movenext
                                wend
                                StatusSQL.close
                                set StatusSQL = nothing
                                StatusSelect= StatusSelect&"</div></ul>"
            
                                response.write(StatusSelect)

            
                                %>
                                </td>
                                <td><%= a("Data") %></td>
                                <td><a href="./?P=ChangeLic&I=<%= LicencaID %>&Pers=1&A=<%= a("id") %>" target="_blank" class="btn btn-primary btn-xs" title="Ver agendamento"><i class="far fa-external-link"></i> <%= ft(a("Hora")) %></a></td>
                                <td><%= a("NomePaciente") %></td>
                                <td>
                                    <%=getWppLink(a("Tel1"), Texto)%>
                                    <%=getWppLink(a("Tel2"), Texto)%>
                                    <%=getWppLink(a("Cel1"), Texto)%>
                                    <%=getWppLink(a("Cel2"), Texto)%>
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

                <%
            end if
        p.movenext
        wend
        p.close
        set p = nothing
        %>
        </tbody>
    </table>
    </div>
</div>
        <%
        end if
    l.movenext
    wend
    l.close
    set l=nothing
end if
%>

<script type="text/javascript">
    function ChangeStatus(L, StaID, A) {
        $.post("ConfirmAllSave.asp", {
            L: L,
            A: A,
            StaID: StaID,
            Notas: $("#Notas" + A).val()
        }, function (data) { eval(data) });
    }
</script>

