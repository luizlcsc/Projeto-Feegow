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
<!-- Instantiate Feather -->
<!--#include file="connect.asp"-->

<img id="image1" width="100px" src="assets\img\stock\1.jpg" />
<button type="button" title="Editar Imagem" onclick=" launchEditor('image1', 'assets\img\stock\1.jpg')">EDITA</button>


<script >
   function launchEditor(id, src) {
        openComponentsModal("ImageEditor.asp",{nomeImagem:id,urlImagem: src},"");
    }
</script>
