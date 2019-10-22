<!--#include file="connect.asp"-->
<%
if request.QueryString("T")="GuiaConsulta" then
	src = "GuiaConsultaPrint"
elseif request.QueryString("T")="GuiaSADT" then
    src = "guiaSPSADTPrint"
    if req("ConvenioID")<>"undefined" then
        set ConvenioSQL = db.execute("SELECT SadtImpressao FROM convenios WHERE id="&req("ConvenioID"))
        sadtImpressao = ConvenioSQL("SadtImpressao")

        if sadtImpressao="sus" then
            src = "guiaSUSPrint"
        elseif sadtImpressao="gto" then
            src = "guiaTratamentoOdontologicoPrint"
        else
            src = "guiaSPSADTPrint"
        end if
    end if

elseif request.QueryString("T")="GuiaHonorarios" then
	src = "guiaHonorariosPrint"
elseif request.QueryString("T")="GuiaInternacao" then
	src = "guiaInternacaoPrint"
end if
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title">Impress&atilde;o de Guia<span id="btnAnexa" style="visibility:hidden"> &raquo; <a class="btn btn-xs btn-info" href="GuiaAnexa.asp?I=<%=request.QueryString("I")%>" target="GuiaTISS">Imprimir Guia Anexa de Outras Despesas</a></span></h4>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
        <%
		src = src&".asp?I="&request.QueryString("I")
		%>
        <iframe width="100%" height="600px" src="<%=src%>" id="GuiaTISS" name="GuiaTISS" frameborder="0"></iframe>
        </div>
    </div>
</div>