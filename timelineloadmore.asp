<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
<%
ProfessionalID = req("ProfissionalID")
Tipo = req("Tipo")
PacienteID = req("PacienteID")
ComEstilo = req("ComEstilo")
loadMore = req("loadMore")
BtnShowMore = req("BtnShowMore")="true"
CallbackShowMore = req("CallbackShowMore")
MaximoLimit = 40

%>

<!--#include file="timelineload.asp"-->
<%
if BtnShowMore AND HasMoreRegisters then
    %>
    <div onclick="<%=CallbackShowMore%>(<%=cint(loadMore)+MaximoLimit%>);$(this).fadeOut();" class="col-md-12 text-center"><a href="#">Ver mais</a></div>
    <%
end if
%>