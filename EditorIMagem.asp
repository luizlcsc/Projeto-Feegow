<link rel="stylesheet" href="assets/css/colorbox.css" />
<style type="text/css">
.ace-thumbnails > li img {
display:block;
min-height:200px;
min-width:200px;
}

#avpw_powered_branding{
	display:none!important;
	visibility:hidden!important;
}
</style>
<script type="text/javascript" src="http://feather.aviary.com/js/feather.js"></script>

<!-- Instantiate Feather -->
<!--#include file="connect.asp"-->
<script type="text/javascript">
    var featherEditor = new Aviary.Feather({
        apiKey: 'e8fb4c93fc2c4946bd4a5725faa30ebb',
        theme: 'light', // Check out our new 'light' and 'dark' themes!
        tools: 'all',
        appendTo: '',
        language: 'pt_BR',
        onSave: function (imageID, newURL) {
            var img = document.getElementById(imageID);
            var fileName = $("#"+imageID).attr("data-path");
            img.src = newURL;
            $.post('save.php?setMain=1', {id:fileName,url: newURL});
            featherEditor.close();
        },
        onSave: function(imageID, newURL) {
            var img = document.getElementById(imageID);
            img.src = newURL;
		   
            $.post("http://clinic.feegow.com.br/save.php?PacienteID=<%=request.QueryString("PacienteID")%>&B=<%=req("B")%>", {url:newURL}, function(data){
                atualizaAlbum(0); 
                featherEditor.close(); 
            });
        },
        postUrl: 'http://clinic.feegow.com.br/save.php?PacienteID=<%=request.QueryString("PacienteID")%>&B=<%=req("B")%>',
        onError: function(errorObj) {
            alert(errorObj.message);
        }
    });
    function launchEditor(id, src) {
        featherEditor.launch({
            image: id,
            url: src
        });
        return false;
    }

</script>


<div id='injection_site'></div>



<img id="image1" src="http://clinic.feegow.com.br/uploads/2582d6db2b07d0286ff3f8f6b11e5c93.jpg" />
<button type="button" title="Editar Imagem" onclick="return launchEditor('image1', 'http://clinic.feegow.com.br/uploads/2582d6db2b07d0286ff3f8f6b11e5c93.jpg');">EDITA</button>