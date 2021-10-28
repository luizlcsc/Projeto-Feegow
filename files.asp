<!--#include file="connect.asp"-->

<%
PacienteID = 0
%>
        <br><div id="divArquivos" class="tab-pane min-tabs">
        <%if aut("arquivosI") then%>
            <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID%>&Tipo=A&Pasta=Arquivos&L=<%=replace(session("Banco"),"clinic","")%>"></iframe>
        <%end if%>
			<div id="albumArquivos">
				Carregando...
            </div>
        </div>


<script>
$(".crumb-active a").html("Gerenciador de Arquivos");
$(".crumb-icon a span").attr("class", "far fa-file");


function atualizaArquivos(X){
	$.ajax({
		type:"POST",
		url:"Arquivos.asp?PacienteID=<%=PacienteID%>&X="+X,
		success:function(data){
			$("#albumArquivos").html(data);
		}
	});
}

function atualizaAlbum(X){
	$.ajax({
		type:"POST",
		url:"Imagens.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#albumImagens").html(data);
		}
	});
}

atualizaArquivos(0);
</script>