<!--#include file="connect.asp"-->
<% call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from tabelasportes where id="& req("I"))
%>
<div class="panel">
    <div class="panel-body">
        <form method="post" id="frm" name="frm" action="save.asp">
            <%=header(req("P"), "Tabelas de Portes", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
            <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
            <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
            <div class="row">
                <%=quickField("text", "Descricao", "Descricao", 6, reg("Descricao"), "", "", " required")%>
                <%=quickField("text", "CodigoTabela", "CodigoTabela", 3, reg("CodigoTabela"), "", "", " maxlength=3 ")%>
                <%=quickField("currency", "UCO", "UCO", 3, fn(reg("UCO")), "", "", "") %>
            </div>

            <div class="row pt15">
                <div class="col-md-12">
                    <%call Subform("tabelasconveniosportes", "TabelaPorteID", request.QueryString("I"), "frm")%>
                </div>
            </div>
        </form>
    </div>
</div>
<script>
<!--#include file="jQueryFunctions.asp"-->
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


</script>
<!--#include file="disconnect.asp"-->