<!--#include file="connect.asp"-->
<%
LoteID = req("LoteID")

if req("T")="GuiaConsulta" then
	src = "GuiaConsultaPrint"
elseif req("T")="GuiaSADT" then
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

elseif req("T")="GuiaHonorarios" then
	src = "guiaHonorariosPrint"
elseif req("T")="GuiaInternacao" then
	src = "guiaInternacaoPrint"
elseif req("T")="GuiaQuimioterapia" then
	src = "guiaQuimioterapiaPrint"
elseif req("T")="EspelhoConta" then
	src = "EspelhoContaPrint"
end if
%>
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <%if req("T")="EspelhoConta" then%>
        <h4 class="modal-title">Impress&atilde;o &raquo; Espelho de Conta</h4>
    <%else%>
        <h4 class="modal-title">Impress&atilde;o de Guia<span id="btnAnexa" style="visibility:hidden"> &raquo; <a class="btn btn-xs btn-info" href="GuiaAnexa.asp?I=<%=req("I")%>" target="GuiaTISS">Imprimir Guia Anexa de Outras Despesas</a></span></h4>
    <%end if%>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
        <%
		src = src&".asp?I="&req("I")&"&LoteID="&LoteID
		%>
        <iframe width="100%" height="600px" src="<%=src%>" id="GuiaTISS" name="GuiaTISS" frameborder="0"></iframe>
        </div>
    </div>
</div>