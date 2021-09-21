<!--#include file="connect.asp"-->
<%
Tipo = req("Tipo")
GuiaID = req("GuiaID")
TipoGuia = req("TipoGuia")

if TipoGuia="GuiaSADT" or TipoGuia="guiasadt" then
    tabela = "tissguiasadt"
elseif TipoGuia="GuiaHonorarios" or TipoGuia="guiahonorarios" then
    tabela = "tissguiahonorarios"
elseif TipoGuia="GuiaInternacao" then
    tabela = "tissguiainternacao"
elseif TipoGuia="GuiaConsulta" or TipoGuia="guiaconsulta" then
        tabela = "tissguiaconsulta"
end if

if Tipo="I" then
    db_execute("INSERT tissguiastatus_log set GuiaID="&ref("GuiaID")&", StatusID="&ref("StatusID")&", TipoGuia='"&ref("TipoGuia")&"', Observacao='"&ref("Observacao")&"', sysUser="&session("User"))
else
%>
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Observações da Guia</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<div class="modal-body">
<%
set statuslog = db.execute("SELECT tgsl.*, tgs.Status, tgs.Cor FROM tissguiastatus_log tgsl LEFT JOIN cliniccentral.tissguiastatus tgs ON tgs.id=tgsl.StatusID WHERE tgsl.TipoGuia='"&TipoGuia&"' AND tgsl.GuiaID="&GuiaID)
while not statuslog.EOF
%>
    <table  width="100%" class="table table-bordered">
        <tr>
            <td style="padding: 5px" class="bg-<%=statuslog("Cor")%>" width="1%"><i class="far fa-chevron-right"></i></td>
            <td style="padding: 5px" width="20%"><strong>Data: </strong><%=formatdatetime(statuslog("sysDate"),2)%></td>
            <td style="padding: 5px" width="20%"><strong>Status: </strong><%=statuslog("Status")%></td>
            <td style="padding: 5px" width="60%"><strong>Usu&aacute;rio: </strong><%=nameInTable(statuslog("sysUser"))%></td>
        </tr>
        <tr>
            <td colspan="4" class="bg-light">Obs: </strong><%=statuslog("Observacao")%></td>
        </tr>
    </table>
    <hr style="margin:10px !important;">

<%
statuslog.movenext
wend
statuslog.close
set statuslog=nothing

%>
</div>
<form method="post" id="frmTissGuiaStatuslog" name="frmTissGuiaStatuslog">
    <div class="modal-body">
        <div class="row">
            <%
            set sta = db.execute("SELECT tab.GuiaStatus, tgs.Status FROM "&tabela&" tab LEFT JOIN cliniccentral.tissguiastatus tgs ON tgs.id=tab.GuiaStatus WHERE tab.id="&GuiaID)
            if not sta.EOF then
                if isnull(sta("GuiaStatus")) then
                    StatusID = 0
                    StatusNome = "Sem Status"
                else
                    StatusID = sta("GuiaStatus")
                    StatusNome = sta("Status")
                end if
            end if
            %>
            <input type="hidden" name="StatusID" id="StatusID" value="<%=StatusID%>" />
            <input type="hidden" name="GuiaID" id="GuiaID" value="<%=GuiaID%>" />
            <input type="hidden" name="TipoGuia" id="TipoGuia" value="<%=TipoGuia%>" />
            <div class="col-md-12">
                <span><strong>Observação para o status: <%=StatusNome%></strong></span>
                <%= quickField("memo", "Observacao", "", 12, Observacao, "", "", "") %>
            </div>

        </div>
        <br>
    </div>
    <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>
<%
end if
%>
<script>
$("#frmTissGuiaStatuslog").submit(function(){
	$.post("modalTissGuiaStatuslog.asp?Tipo=I", $(this).serialize(), function(data, status){ $("#modal-table").modal("hide") });
	return false;
});
</script>


<script type="text/javascript">

<!--#include file="JQueryFunctions.asp"-->
</script>