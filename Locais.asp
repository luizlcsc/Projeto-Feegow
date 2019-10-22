<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from "&req("P")&" where id="&request.QueryString("I"))
%>
<br />
<div class="panel">
    <div class="panel-body">
        <form method="post" id="frm" name="frm" action="save.asp">
            <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
            <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
            <%=header(req("P"), "Cadastro de Local de Atendimento", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
            <div class="row">
                <%=quickField("text", "NomeLocal", "Nome do Local", 4, reg("NomeLocal"), "", "", " required")%>
                <%=quickField("empresa", "UnidadeID", "Unidade", 4, reg("UnidadeID"), "", "", " required")%>
                <%=quickField("text", "MaximoAgendamentos", "Máx. pac. no horário", 4, reg("MaximoAgendamentos"), "", "", " ")%>

            </div>
            <input type="hidden" name="d1" value="1" />
            <input type="hidden" name="d2" value="2" />
            <input type="hidden" name="d3" value="3" />
            <input type="hidden" name="d4" value="4" />
            <input type="hidden" name="d5" value="5" />
            <input type="hidden" name="d6" value="6" />
            <input type="hidden" name="d7" value="7" />
        </form>
    </div>
</div>
<script type="text/javascript">
    $(document).ready(function(e) {
        <%call formSave("frm", "save", "")%>
        });
</script>
<!--#include file="disconnect.asp"-->
