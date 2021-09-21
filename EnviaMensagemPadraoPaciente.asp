<!--#include file="connect.asp"-->
<%
ModeloID=req("ModeloID")
AgendamentoID=req("AgendamentoID")
Celular=req("Celular")

set ModeloSQL = db.execute("SELECT TextoWhatsApp From cliniccentral.modelo_mensagem_paciente WHERE id="&ModeloID)
%>
<p>Ao enviar, o paciente receberá um WhatsApp com o texto abaixo.</p>
<label for="NumeroPaciente">Número:</label>
<span><%=Celular%></span>

<br>
<label for="TextoMensagem">Texto</label>
<textarea name="TextoMensagem" id="TextoMensagem" cols="30" rows="10" class="form-control"><%=ModeloSQL("TextoWhatsApp")%></textarea>
<span class="help-block mt5">
    <i class="far fa-bell"></i> As tags serão substituídas antes do envio
</span>