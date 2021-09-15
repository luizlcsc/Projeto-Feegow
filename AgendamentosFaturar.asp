<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
DataInicio=req("DataInicio")
DataFim=req("DataAte")
StatusID=req("StatusID")
Offset=req("Offset")

if StatusID="" then
    StatusID="T"
end if

if Offset="" then
    Offset=20
end if

%>

<div class="row">

     <div class="col-md-12">
    <%=quickField("datepicker", "FiltroDataDe", "De", 3, DataInicio, "", "", "")%>
    <%=quickField("datepicker", "FiltroDataAte", "At&eacute;", 3, DataFim, "", "", "")%>
    <%=quickfield("simpleSelect", "FiltroStatusID", "Status", 3, StatusID, "select 'T' id, 'Todos' StaConsulta union all select id, StaConsulta from staconsulta WHERE ID IN (1, 2, 3, 6, 7) order by StaConsulta", "StaConsulta", " semVazio no-select2 ") %>
    <div class="col-md-3">
        <br>
        <button class="btn btn-primary" type="button" onclick="FiltrarAgendamentosFaturar()"><i class="far fa-search"></i> Filtrar</button>
    </div>

    <div class="col-md-12">
        <br>
        <h4 class="lighter blue no-margin header"><i class="far fa-calendar" id="icon-Agendamentos"></i> Agendamentos</h4>

            <table class="table table-striped table-condesed">
                <thead>
                    <tr class="primary">
                        <th width="2%"><label><input type="checkbox" onchange="SelecionaTodosAgendamentos($(this))" value="1"><span class="lbl"></span></label></th>
                        <th>Data</th>
                        <th>Hora</th>
                        <th>Profissional</th>
                        <th>Status</th>
                        <th>Procedimento</th>
                        <th>Valor/Convênio</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                <%
                if DataInicio<>"" then
                    sqlData = " AND ag.Data BETWEEN "&mydatenull(DataInicio)&" AND "&mydatenull(DataFim)
                end if

                if StatusID<>"" and StatusID<>"T" then
                    sqlStatus = " AND ag.StaID IN ("&StatusID&")"
                end if


                i=0

                set qtdAg = db.execute("select FLOOR(COUNT(*)/20) AS totalPaginas from agendamentos ag LEFT JOIN staconsulta sta on sta.id=ag.StaID LEFT JOIN profissionais prof on prof.id=ag.ProfissionalID LEFT JOIN procedimentos proc on proc.id=ag.TipoCompromissoID LEFT JOIN convenios conv on ag.ValorPlano=conv.id where ag.sysActive=1 AND PacienteID="&PacienteID &" "& sqlData & sqlStatus)
                qtdAgAux = CInt(qtdAg("totalPaginas"))*20
                set ag = db.execute("select ii.id ItemInvoiceID, ag.id, ag.Data, ag.Hora, ag.rdValorPlano, ag.ValorPlano, prof.NomeProfissional, proc.NomeProcedimento, conv.NomeConvenio, sta.StaConsulta "&_
                "from agendamentos ag "&_
                "LEFT JOIN staconsulta sta on sta.id=ag.StaID  "&_
                "LEFT JOIN profissionais prof on prof.id=ag.ProfissionalID  "&_
                "LEFT JOIN procedimentos proc on proc.id=ag.TipoCompromissoID  "&_
                "LEFT JOIN convenios conv on ag.ValorPlano=conv.id  "&_
                "LEFT JOIN itensinvoice ii ON ii.AgendamentoID=ag.id  "&_
                "where PacienteID="&PacienteID &" "& sqlData & sqlStatus&" AND ag.sysActive=1  "&_
                "GROUP BY ag.id  "&_
                "order by Data desc  "&_
                "limit " & Offset)

                while not ag.eof
                    ItemInvoiceID=ag("ItemInvoiceID")
                    if ag("rdValorPlano")="V" then
                        ValorConvenio = ag("ValorPlano")
                        if not isnull(ValorConvenio) and ValorConvenio<>"" and isnumeric(ValorConvenio) then
                            ValorConvenio = formatnumber(ValorConvenio, 2)
                        end if
                    else
                        ValorConvenio = ag("NomeConvenio")
                    end if

                    badgeFaturado = ""

                    if ItemInvoiceID&""<>"" then
                        badgeFaturado = "<div class='badge badge-warning'><i class='far fa-exclamation-circle'></i> Faturado</div>"
                    end if

                    %><tr>
                        <td  width="2%"><label><input type="checkbox" class="fromAgenda" name="Lancto" value="<%=ag("id")%>|agendamento"><span class="lbl"></span></label></td>
                        <td><%=ag("Data")%></td>
                        <td><%if not isnull(ag("Hora")) then response.Write(formatdatetime(ag("Hora"), 4)) end if%></td>
                        <td><%=ag("NomeProfissional")%></td>
                        <td><%=ag("StaConsulta")%></td>
                        <td><%=ag("NomeProcedimento")%></td>
                        <td class="text-center"><%=ValorConvenio%></td>
                        <td><%=badgeFaturado%></td>
                    </tr><%
                    i = i + 1
                ag.movenext
                wend
                ag.close
                set ag=nothing
                %>
                <tr >
                    <td colspan="8" class="dark">
                    <button style="float: left;<%if (CInt(Offset) > qtdAgAux) then%> <%=";display:none"%> <% end if %> " class="btn btn-sm btn-primary" type="button" onclick="FiltrarAgendamentosFaturar(<%=Offset+20%>)">Mostrar mais</button>
                    <strong style="float: right;"><%=i%> agendamentos</strong>
                    </td>
                </div>
                </tbody>
            </table>
    <hr>
    </div>

</div>
<script type="text/javascript">
    $(".fromAgenda").click(function () {
        $("#hiddenLanctoAgenda").val("");
    })

    function  SelecionaTodosAgendamentos($checkbox) {
        $(".fromAgenda").prop("checked", $checkbox.prop("checked"));
    }

    function FiltrarAgendamentosFaturar(Offset = 20) {

        $.get("AgendamentosFaturar.asp", {
            PacienteID: '<%=PacienteID%>',
            DataInicio: $("#FiltroDataDe").val(),
            DataAte: $("#FiltroDataAte").val(),
            StatusID: $("#FiltroStatusID").val(),
            Offset: Offset
        }, function(data){
            $("#divFatAgendamento").html(data);
        });
    }

<!--#include file="JQueryFunctions.asp"-->
</script>