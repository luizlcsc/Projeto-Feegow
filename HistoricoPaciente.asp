<!--#include file="connect.asp"-->
<%

IF req("AgendamentoPaciente") <> "" THEN
    session("PacienteIDSelecionado")=req("AgendamentoPaciente")
    response.redirect("./?P=AgendaMultipla&Pers=1")
    response.end
END IF

PacienteID = req("PacienteID")

set pac = db.execute("select NomePaciente from pacientes where id="&req("PacienteID"))
if not pac.eof then
	NomePaciente = pac("NomePaciente")
end if
%>
<div class="panel">
    <div class="panel-heading">
        <div class="col-md-6">
	        <span class="panel-title"><i class="far fa-calendar"></i> Histórico de Agendamentos</span>
        </div>

        <%
        if aut("agendaI") then
        %>
        <div class="col-md-6 text-right">
            <a href="HistoricoPaciente.asp?AgendamentoPaciente=<%=PacienteID%>" class="btn btn-success  btn-sm">
            <i class="far fa-plus"></i>
            Agendamento</a>
        </div>
        <%
        end if
        %>
    </div>
    <div class="panel-body">



    <table class="table footable fw-labels" data-page-size="20">
        <thead>
            <tr class="primary">
                <th>Status</th>
                <th>Data/Hora</th>
                <th>Profissional</th>
                <th>Equipamento</th>
                <th>Especialidade</th>
                <th>Procedimento</th>
                <th>Valor/Convênio</th>
                <th width="12%"></th>
            </tr>
        </thead>
        <tbody>

        <%
	    c = 0

	    agends = ""
        set pCons = db.execute("select a.sysActive, a.id, a.rdValorPlano, a.ValorPlano, a.Data, a.Hora, a.StaID, a.Procedimentos, s.StaConsulta, p.NomeProcedimento, eq.NomeEquipamento, c.NomeConvenio, prof.NomeProfissional, esp.Especialidade NomeEspecialidade FROM agendamentos a LEFT JOIN equipamentos eq ON eq.id=a.EquipamentoID LEFT JOIN profissionais prof on prof.id=a.ProfissionalID LEFT JOIN especialidades esp ON esp.id=a.EspecialidadeID or (a.EspecialidadeID is null and prof.EspecialidadeID=esp.id) LEFT JOIN procedimentos p on a.TipoCompromissoID=p.id LEFT JOIN staconsulta s ON s.id=a.StaID LEFT JOIN convenios c on c.id=a.ValorPlano WHERE a.PacienteID="&PacienteID&"  ORDER BY a.Data DESC, a.Hora DESC")
        while not pCons.EOF
		    c = c+1
		    if pCons("rdValorPlano")="V" then
                if aut("areceberareceberpaciente") then
    			    Pagto = "R$ " & formatnumber(0&pCons("ValorPlano"), 2)
                else
                    Pagto = ""
                end if
		    else
			    Pagto = pCons("NomeConvenio")
		    end if
		    agends = agends & pCons("id") & ","

		    consHora = pCons("Hora")
		    if not isnull(consHora) then
			    consHora = formatdatetime(consHora, 4)
		    end if
            disabledAbrir = " " 

            if pCons("sysActive")&""="-1" then
                disabledAbrir = " disabled " 
            end if


            select case pCons("StaID")
                case 1
                    classe = "alert"
                case 2, 3
                    classe = "success"
                case 4
                    classe = "warning"
                case 5, 8
                    classe = "primary"
                case 6, 11
                    classe = "danger"
                case else
                    classe = "dark"
            end select

            NomeProcedimento = pCons("NomeProcedimento")
            VariosProcedimentos = pCons("Procedimentos")&""
            if VariosProcedimentos<>"" then
                NomeProcedimento = VariosProcedimentos
            end if

            staconsulta = pCons("StaConsulta")


            if pCons("sysActive")&""= "-1" then
                staconsulta = "Excluído"
                classe = "danger"
            end if



            %>
            <tr class="row-<%=classe %>" onclick="">
                <td class="pn">
                    <span class="label label-<%=classe %> mn">
                        <%=left(staconsulta, 18) %>
                    </span>
                </td>
                <td><%="<img src=""assets/img/"&pCons("StaID")&".png"">"%> &nbsp; <%=pCons("Data")&" - "&consHora %></td>
                <td><%=left(pCons("NomeProfissional"), 30) %></td>
				<td><%=left(pCons("NomeEquipamento"), 30) %></td>
                <td><%=left(pCons("NomeEspecialidade"), 30) %></td>
                <td><%=left(NomeProcedimento, 30) %></td>
                <td><%=Pagto%></td>
                <td>
                    <div class="btn-group">
                        <button class="btn btn-primary btn-xs" data-agendamentoid="<%= pCons("id") %>" id="hist<%=pCons("id")%>">Detalhes</button>
                        <a <%=disabledAbrir%> class="btn btn-primary btn-xs" href="./?P=Agenda-1&Pers=1&AgendamentoID=<%=pCons("id")%>" target="_blank" title="Ir para agendamento"><i class="far fa-external-link"></i></a>
                    </div>
                    <div id="divhist<%=pCons("id")%>" style="position:absolute; display:none;z-index: 99999; background-color:#fff; margin-left:-740px; border:1px solid #2384c6; width:800px; height:200px; overflow-y:scroll">Carregando...</div>
                </td>
            </tr>
            <%
        pCons.MoveNext
        wend
        pCons.close
        set pCons=nothing

	    if c=0 then
		    txt = "Nenhum agendamento."
	    elseif c=1 then
		    txt = "1 agendamento."
	    else
		    txt = c& " agendamentos."
	    end if
    %>
    </tbody>
    </table>










    <div class="row">
	    <div class="col-xs-12">
    	    <%=txt%>
        </div>
    </div>
    <%

	if agends<>"" then
		agends = left(agends, len(agends)-1)
		set logs = db.execute("select l.*, p.NomeProcedimento, prof.NomeProfissional, s.StaConsulta FROM logsmarcacoes l LEFT JOIN procedimentos p on p.id=l.ProcedimentoID LEFT JOIN staconsulta s on s.id=l.Sta LEFT JOIN profissionais prof on prof.id=l.ProfissionalID WHERE l.PacienteID="&PacienteID&" AND l.ConsultaID NOT IN("&agends&") GROUP BY l.ConsultaID")
    else
		set logs = db.execute("select l.*, p.NomeProcedimento, prof.NomeProfissional, s.StaConsulta FROM logsmarcacoes l LEFT JOIN procedimentos p on p.id=l.ProcedimentoID LEFT JOIN staconsulta s on s.id=l.Sta LEFT JOIN profissionais prof on prof.id=l.ProfissionalID WHERE l.PacienteID="&PacienteID&" GROUP BY l.ConsultaID")
    end if
		    if not logs.eof then
		    %>
		    <h4>Agendamentos excluídos</h4>
		    <%
		    end if
		    while not logs.eof
			    %>

                <div class="panel panel-default" style="margin-bottom: 5px !important;">
                    <div class="panel-heading">
                        <h4 class="panel-title">
                            <a class="accordion-toggle red" data-toggle="collapse" data-parent="#accordion" onClick="log(<%=logs("ConsultaID")%>)" href="#collapse<%=logs("ConsultaID")%>">
                              <div class="row" style="padding: 15px;">
                                <div class="col-xs-3"><%="<img src=""assets/img/"&logs("Sta")&".png"">"%>&nbsp;<%=formatdatetime(logs("Data"), 2)%> -  <%=formatdatetime(logs("Hora"),4)%></div>
                                <div class="col-xs-3"><%=left(logs("NomeProfissional")&" ", 30)%></div>
                                <div class="col-xs-2"><%=left(logs("NomeProcedimento")&" ", 15)%></div>

                                <div class="col-xs-2">
                                    <%=left(logs("StaConsulta"), 18)%>
                                </div>
                                <div class="col-xs-2">
                                    <%=Pagto%>
                                    <i class="far fa-angle-down bigger-110 pull-right" data-icon-hide="far fa-angle-down" data-icon-show="far fa-angle-right"></i>
                                </div>

                              </div>
                            </a>
                        </h4>
                    </div>

                    <div class="panel-collapse collapse" id="collapse<%=logs("ConsultaID")%>">
                        <div class="panel-body" id="hist<%=logs("ConsultaID")%>">
                            Carregando...
                        </div>
                    </div>
                </div>
			    <%
		    logs.movenext
		    wend
		    logs.close
		    set logs=nothing
        %>
        </div>
    </div>


<script type="text/javascript">
function log(id){
    $.get("logsAgendamentos.asp?PacienteID=<%=PacienteID%>&AgendamentoID=" + id, function (data) {
        $("#hist"+id).next().find("td").html(data);
        $(".panel-body").filter("#hist"+id).html(data);
    });
    }

    $("[id^=hist]").on("click", function () {
        AI = $(this).attr("data-agendamentoid");
        $("#agendativo").val(AI);
        $("#div" + $(this).attr("id")).css("display", "block");
        if($("#div" + $(this).attr("id")).html()=="Carregando..."){
            $.get("logsAgendamentos.asp?PacienteID=<%=PacienteID%>&AgendamentoID="+ AI, function (data) {
                $("#divhist" + AI).html( data );
                return false;
            });
        }
        return false;
    });

</script>









<script type="text/javascript">
//    $('.footable').footable();

</script>