<!--#include file="connect.asp"-->
$(".chamada").fadeOut();
$(".atendimento").fadeOut();

<%
usersCha = ""
set cha = db.execute("select c.StaID, c.sysUserAtend, c.DataHoraAtend, c.RE, p.NomePaciente, can.NomeCanal, can.Icone, sta.NomeStatus from chamadas c LEFT JOIN pacientes p on p.id=substring_index(c.contato, '_', -1) LEFT JOIN chamadascanais can on can.id=c.RE LEFT JOIN chamadasconstatus sta on sta.id=p.ConstatusID WHERE StaID=1")
while not cha.eof
    usersCha = usersCha & "|" & cha("sysUserAtend") &"|"
    tempo = datediff("s", ft(cha("DataHoraAtend")), time())
    tempo = dateadd("s", tempo, "00:00")
    %>
    $("#chamada<%=cha("sysUserAtend") %>").fadeIn();
    $("#chamada<%=cha("sysUserAtend") %>").html("<%=ucase( cha("NomeCanal") &" - "& cha("NomeStatus") ) %> <br /> <h3><%=cha("NomePaciente")%></h3> <h1 class='no-margin'><i class='far fa-<%=cha("Icone") %>'></i> <%=tempo %></h1>");
    <%
cha.movenext
wend
cha.close
set cha=nothing

usersAte = ""
set ate = db.execute("select a.*, p.NomePaciente from atendimentos a LEFT JOIN pacientes p on p.id=a.PacienteID WHERE a.Data=CURDATE() and ISNULL(a.HoraFim)")
while not ate.eof
    usersAte = usersAte & "|" & ate("sysUser") &"|"
    tempo = datediff("s", ft(ate("HoraInicio")), time())
    tempo = dateadd("s", tempo, "00:00")

    Titulo = ""
    set ap = db.execute("select p.NomeProcedimento from agendamentos ag LEFT JOIN procedimentos p on p.id=ag.TipoCompromissoID WHERE ag.PacienteID="&ate("PacienteID")&" and ag.ProfissionalID="&ate("ProfissionalID"))
    if ap.eof then
        Titulo = "Execução"
    else
        while not ap.eof
            Titulo = ap("NomeProcedimento") &"<br>" & Titulo
        ap.movenext
        wend
        ap.close
        set ap=nothing
    end if
    %>
    $("#atendimento<%=ate("sysUser") %>").fadeIn();
    $("#atendimento<%=ate("sysUser") %>").html("<%=Titulo %> <h3><%=ate("NomePaciente")%></h3> <h1 class='no-margin'><i class='far fa-play'></i> <%=tempo %></h1>");
    <%
ate.movenext
wend
ate.close
set ate=nothing

set p=db.execute("select p.*, u.id User from profissionais p left join sys_users u on (u.table='profissionais' and u.idInTable=p.id) where ativo='on' and sysActive=1")
while not p.eof
        %>
        $('#presenca<%=p("User")%>').html('<h1 class="no-margin"><%=replace(p("NomeProfissional"), "'", "\'") %>  <%=replace(tempoTrab(p("User"), "Status"), "'", "\'") %></h1><div class="row"><div class="col-md-12"><%=replace(tempoTrab(p("User"), "Grafico"), "'", "\'") %></div></div>');

        <%
    if instr(usersCha & usersAte, "|"&p("User")&"|") or tempoTrab(p("User"), "strStatus")="Ausente" then
        session("Livre"&p("User"))=""
        %>
        $("#livre<%=p("User") %>").fadeOut();
        <%
    else
        if session("Livre"&p("User"))="" then
            session("Livre"&p("User"))=time()
        end if
        TempoLivre = session("Livre"&p("User"))
        TempoLivre = datediff("s", TempoLivre, time())
        TempoLivre = dateadd("s", TempoLivre, "00:00")
        %>
        $("#livre<%=p("User") %>").fadeIn();
        $("#livre<%=p("User") %>").html("<h3 class='no-margin'>LIVRE</h3><h1><b><%=TempoLivre %></b></h1>");
        <%
    end if
    'oportunidades gráfico->
    if p("CentroCustoID")=2 then
        dataOportunidades = dataOportunidades & "{data: ["
            dataOportunidades = dataOportunidades & "[9, 81, 63],"
        dataOportunidades = dataOportunidades & "], marker: {"
        dataOportunidades = dataOportunidades & "fillColor: {"
        dataOportunidades = dataOportunidades & "radialGradient: { cx: 0.4, cy: 0.3, r: 0.7 },"
        dataOportunidades = dataOportunidades & "stops: ["
        dataOportunidades = dataOportunidades & "[0, 'rgba(255,255,255,0.5)'],"
        dataOportunidades = dataOportunidades & "[1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0.5).get('rgba')]]}}},"
    end if
    '<- oportunidades gráfico


p.movenext
wend
p.close
set p=nothing
%>

                        $(function () {
                            Highcharts.chart('oportunidadesAbertas', {

                                chart: {
                                    type: 'bubble',
                                    plotBorderWidth: 1,
                                    zoomType: 'xy'
                                },

                                title: {
                                    text: 'OPORTUNIDADES ABERTAS'
                                },

                                xAxis: {
                                    gridLineWidth: 1
                                },

                                yAxis: {
                                    startOnTick: false,
                                    endOnTick: false
                                },

                                series: [ <%=dataOportunidades %>]

                            });
                        });
