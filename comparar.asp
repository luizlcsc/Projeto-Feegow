<!--#include file="connect.asp"-->

<div class="modal-body">
<%
if request.Form("comparar")="" then
	%>Voc&ecirc; n&atilde;o marcou nenhuma imagem para comparar<%
else
%>
<table width="100%">
  <tr style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: space-evenly; align-items: center; align-content: space-around;">
	<%
	spl = split(request.Form("comparar"), "|, |")
	for i=0 to ubound(spl)
        fullFile = replace(spl(i), "|", "")
		%>
		<td style="max-width:600px; max-height:420px; margin-bottom: 15px;"><img src="<%= fullFile %>" style="max-width:600px; max-height:420px;" border="0"></td>
		<%
	next
	%>
  </tr>
</table>
	<%
end if
%>
</div>

<div class="modal-footer">
	<button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
</div>