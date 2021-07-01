<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select g.*, (select group_concat('|', id, '|') from protocolos where GrupoID=g.id) protocolos from protocolosgrupos g where g.id="&req("I"))
%>



<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Cadastro de Grupo de Protocolos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />

    <br />
    <div class="panel">
        <div class="panel-body">
            <%=quickField("text", "NomeGrupo", "Nome do Grupo", 6, reg("NomeGrupo"), "", "", " required")%>
            <%=quickfield("multiple", "Protocolos", "Protocolos do Grupo", 4, reg("Protocolos"), "select id, NomeProtocolo from protocolos where sysActive=1 order by NomeProtocolo", "NomeProtocolo", "")%>
        </div>
    </div>
</form>
<script type="text/javascript">
    $(document).ready(function(e) {
        <%call formSave("frm", "save", "")%>
        });
<!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->
