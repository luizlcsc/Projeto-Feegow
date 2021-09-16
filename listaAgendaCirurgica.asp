<!--#include file="connect.asp"-->

<%

%>
<br>
<div class="panel">
    <div class="panel-body">
        <form id="formCirurgia">
            <%=quickField("datepicker", "DataDe", "De", 2, dateAdd("m",-1,date()), "", "", "")%>
            <%=quickField("datepicker", "DataAte", "Até", 2, dateAdd("m",1,date()), "", "", "")%>
            <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 2, "|"&session("UnidadeID")&"|", "", "", "")%>
            <%= quickfield("simpleSelect", "ProfissionalID", "Cirurgião", 2, "", "select id, if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial) NomeProfissional from profissionais where sysActive=1 and ativo='on' order by if(isnull(NomeSocial) or NomeSocial='', NomeProfissional, NomeSocial)", "NomeProfissional", "") %>
            <%=quickField("multiple", "Status", "Status da Agenda", 2, "|1|,|2|,|4|,|6|,|7|,|8|", "SELECT * FROM agendacirurgicastatus", "nomeStatus", "")%>
            <div class="col-md-2">
                <BR>
                <button class="btn btn-primary btn-block">
                    Filtrar
                </button>
            </div>
        </form>
    </div>
</div>


<div class="panel">
    <div class="panel-body" id="conteudoCirurgias">
        <%server.Execute("lAgendaCirurgica.asp") %>
    </div>
</div>

<script type="text/javascript">
    $(".crumb-active a").html("Agenda de Cirurgias");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("");
    $(".crumb-icon a span").attr("class", "far fa-medkit");
    <%
    if aut("agendaI")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" data-toggle="modal" href="./?P=AgendaCirurgica&Pers=1&I=N"><i class="far fa-plus"></i><span class="menu-text"> Inserir</span></a>');
    <%
    end if
    %>

    $(document).ready(function() {
      setTimeout(function() {
        $("#toggle_sidemenu_l").click()
      }, 500);

      $("#formCirurgia").submit(function() {
          $.post("lAgendaCirurgica.asp", $(this).serialize(), function(data) {
                $("#conteudoCirurgias").html(data);
          });

          return false;
      });
    })
</script>