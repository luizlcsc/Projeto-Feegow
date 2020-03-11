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



<!-- Instantiate Feather -->
<!--#include file="connect.asp"-->

<script type="text/javascript" src="https://uicdn.toast.com/tui.code-snippet/v1.5.0/tui-code-snippet.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/3.6.0/fabric.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.3/FileSaver.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.js"></script>





<img id="image1" src="https://clinic7.feegow.com.br/uploads/105/Imagens/4e00ee4c1dab29a0bfc8050d8ecc6079.png" />
<button type="button" title="Editar Imagem" onclick="return launchEditor('image1', 'https://clinic7.feegow.com.br/uploads/105/Imagens/4e00ee4c1dab29a0bfc8050d8ecc6079.png');">EDITA</button>

<div id="injection_site" >

</div>

<script type="text/javascript">

    var blackTheme = {
        'common.bi.image': 'https://uicdn.toast.com/toastui/img/tui-image-editor-bi.png',
        'common.bisize.width': '251px',
        'common.bisize.height': '21px',
        'common.backgroundImage': 'none',
        'common.backgroundColor': '#1e1e1e',
        'common.border': '0px',

        // header
        'header.backgroundImage': 'none',
        'header.backgroundColor': 'transparent',
        'header.border': '0px',

        // load button
        'loadButton.backgroundColor': '#fff',
        'loadButton.border': '1px solid #ddd',
        'loadButton.color': '#222',
        'loadButton.fontFamily': '\'Noto Sans\', sans-serif',
        'loadButton.fontSize': '12px',

        // download button
        'downloadButton.backgroundColor': '#fdba3b',
        'downloadButton.border': '1px solid #fdba3b',
        'downloadButton.color': '#fff',
        'downloadButton.fontFamily': '\'Noto Sans\', sans-serif',
        'downloadButton.fontSize': '12px',

        // main icons
        'menu.normalIcon.color': '#8a8a8a',
        'menu.activeIcon.color': '#555555',
        'menu.disabledIcon.color': '#434343',
        'menu.hoverIcon.color': '#e9e9e9',
        'menu.iconSize.width': '24px',
        'menu.iconSize.height': '24px',

        // submenu icons
        'submenu.normalIcon.color': '#8a8a8a',
        'submenu.activeIcon.color': '#e9e9e9',
        'submenu.iconSize.width': '32px',
        'submenu.iconSize.height': '32px',

        // submenu primary color
        'submenu.backgroundColor': '#1e1e1e',
        'submenu.partition.color': '#3c3c3c',

        // submenu labels
        'submenu.normalLabel.color': '#8a8a8a',
        'submenu.normalLabel.fontWeight': 'lighter',
        'submenu.activeLabel.color': '#fff',
        'submenu.activeLabel.fontWeight': 'lighter',

        // checkbox style
        'checkbox.border': '0px',
        'checkbox.backgroundColor': '#fff',

        // range style
        'range.pointer.color': '#fff',
        'range.bar.color': '#666',
        'range.subbar.color': '#d1d1d1',

        'range.disabledPointer.color': '#414141',
        'range.disabledBar.color': '#282828',
        'range.disabledSubbar.color': '#414141',

        'range.value.color': '#fff',
        'range.value.fontWeight': 'lighter',
        'range.value.fontSize': '11px',
        'range.value.border': '1px solid #353535',
        'range.value.backgroundColor': '#151515',
        'range.title.color': '#fff',
        'range.title.fontWeight': 'lighter',

        // colorpicker style
        'colorpicker.button.border': '1px solid #1e1e1e',
        'colorpicker.title.color': '#fff'
    };

    var imageEditor = new tui.ImageEditor('#injection_site', {
        includeUI: {
            loadImage: {
                path: 'https://clinic7.feegow.com.br/uploads/105/Imagens/4e00ee4c1dab29a0bfc8050d8ecc6079.png',
                name: 'SampleImage'
            },
            theme: blackTheme, // or whiteTheme
            initMenu: 'draw',
            menuBarPosition: 'bottom'
        },
        cssMaxWidth: 800, // Component default value: 1000
        cssMaxHeight: 800  // Component default value: 800
    });
   

    function launchEditor(id, src) {
        imageEditor.loadImageFromURL(src, id);

    }

</script>

