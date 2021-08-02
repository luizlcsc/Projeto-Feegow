<!--#include file="connect.asp"-->
<%
PacienteID = ref("PacienteID")
if PacienteID&"" = "" then
    PacienteID = 0
end if

%>
<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h4 class="modal-title">Anexos da guia</h4>
</div>
<div class="modal-body">
    <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID%>&tipoGuia=<%=ref("tipoGuia")%>&L=<%=replace(session("Banco"),"clinic","")%>&guiaID=<%=ref("guiaID")%>&Pasta=Arquivos&Tipo=A&ExameID=<%=ref("ExameID")%>"></iframe>



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
        url:"Arquivos.asp?PacienteID=<%=PacienteID%>&tipoGuia=<%=ref("tipoGuia")%>&guiaID=<%=ref("guiaID")%>&ExameID=<%=ref("ExameID")%>&X="+X,
        success:function(data){
            $("#albumArquivos").html(data);
        }
    });
}

atualizaArquivos(0);

</script>