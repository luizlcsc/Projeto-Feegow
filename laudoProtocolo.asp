<!--#include file="connect.asp"-->
	<div class="modal-header">
		<h1 class="lighter blue">Impressão do Protocolo</h1>
	</div>
<iframe width="100%" height="500" src="printLaudoProtocolo.asp?L=<%=req("L")%>&AgendamentoID=<%=req("AgendamentoID")%>" frameborder="0"></iframe>