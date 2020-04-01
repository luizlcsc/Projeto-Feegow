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

<link rel="stylesheet" href="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.css">
<link type="text/css" href="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.css" rel="stylesheet">

<script type="text/javascript" src="https://uicdn.toast.com/tui.code-snippet/v1.5.0/tui-code-snippet.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/3.6.0/fabric.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.3/FileSaver.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.js"></script>

<!--#include file="connect.asp"-->

<img id="image1" width="500px" src="assets\img\stock\1.jpg" onclick=" launchEditor('image1', this.src)" />


<script >
   function launchEditor(id, src) {
        openComponentsModal(
            "ImageEditor.asp",
            {
                nomeImagem:id,
                urlImagem: src
            },
            false, 
            true, 
            function(){
                
                let imageId =imageEditor.getImageName();
                let objFile = dataURLtoFile(imageEditor.toDataURL(),imageId);
                let objURL = window.URL.createObjectURL(objFile);

                $("#"+imageId).attr("src", objURL );
                $("#"+imageId).attr("data-type", objFile.type );
                
                newSaveImage(imageEditor.toDataURL());

                closeComponentsModal();
            },
            "lg",
            'auto'
        );
    }

    function newSaveImage(base64){
        //https://clinic7.feegow.com.br/imagesave.php
        //http://localhost:3333/imagesave.php
            $.post("https://clinic7.feegow.com.br/imagesave.php?IP=<%=sServidor%>&PacienteID=<%=req("PacienteID")%>&B=<%=session("Banco")%>", 
                {
                    data: base64
                }, 
                function(data){
                    console.log(data);
                    //atualizaAlbum(0);
            });
    }
    
    function dataURLtoFile(dataurl, filename) {
 
        var arr = dataurl.split(','),
            mime = arr[0].match(/:(.*?);/)[1],
            bstr = atob(arr[1]), 
            n = bstr.length, 
            u8arr = new Uint8Array(n);
            
        while(n--){
            u8arr[n] = bstr.charCodeAt(n);
        }
        
        return new File([u8arr], filename, {type:mime});
    }

</script>
