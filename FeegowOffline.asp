<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Feegow Offline");
    $(".crumb-icon a span").attr("class", "far fa-table");
</script>

<br>
<%
AgendaDe = date()
AgendaAte = dateadd("d",7,AgendaDe)
%>
<div class="row">
    <div class="col-md-12">
        <div class="panel">
            <div class="panel-body">
                <form action="https://clinic.feegow.com.br/feegow_components/api/FeegowOffline" method="get">
                    <%= quickField("datepicker", "DataDe", "Agendamentos de", 2, AgendaDe, "", "", " placeholder='De'") %>
                    <%= quickField("datepicker", "DataAte", "Agendamentos até", 2, AgendaAte, "", "", " placeholder='At&eacute;'") %>
                    <br>
                    <button class="btn btn-primary"><i class="far fa-download"></i> Baixar agenda</button>
                </form>
            </div>
        </div>
    </div>
</div>