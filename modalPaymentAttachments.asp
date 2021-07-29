<!--#include file="connect.asp"-->
<%
if ref("movementID")&""<>"" then
    MovementID = "&MovementID="&ref("movementID")
end if
%>
<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h4 class="modal-title">Anexos do pagamento</h4>
</div>
<div class="modal-body">
    <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=0<%=MovementID%>&Tipo=A&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Arquivos"></iframe>
    
    <div id="albumArquivos">
        Carregando...
    </div>
</div>
<div class="modal-footer">
    <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
</div>

<script >

function atualizaArquivos(X) {

    $.ajax({
        type:"POST",
        url:"Arquivos.asp?PacienteID=0&MovementID=<%=ref("movementID")%>&X="+X,
        success:function(data){
            $("#albumArquivos").html(data);
        }
    });
}

atualizaArquivos(0);

</script>