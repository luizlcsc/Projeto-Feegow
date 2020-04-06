<!--#include file="connect.asp"-->

    <div id="image_panel" style="min-height: 800px;"></div>

<script type="text/javascript">

    let FeegowTheme = {
    'common.bi.image': 'https://clinic7.feegow.com.br/v7/assets/img/logo_white.png',
    'common.bisize.width': '20%',
    'common.bisize.height': '20%',
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
    'loadButton.display': 'none',

    // download button
    'downloadButton.backgroundColor': '#fdba3b',
    'downloadButton.border': '1px solid #fdba3b',
    'downloadButton.color': '#fff',
    'downloadButton.fontFamily': '\'Noto Sans\', sans-serif',
    'downloadButton.fontSize': '12px',
    'downloadButton.display': 'none',

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

var locale_pt_BR = { 
    'Undo': 'Desfazer',
    'Redo': 'Refazer',
    'Reset': 'Reiniciar',
    'Delete': 'Deletar',
    'DeleteAll': 'Deletar tudo',
    'Crop': 'Cortar', 
    'Flip': 'Virar', 
    'Rotate': 'Girar',
    'Draw': 'Desenhar',
    'Text': 'Texto',
    'Shape': 'Formas',
    'Cancel': 'Cancelar',
    'Color': 'Cor',
    'Free': 'Livre',
    'Straight': 'Reta',
    'Text size': 'Tamanho',
    'Rectangle': 'Retângulo',
    'Circle': 'Circulo',
    'Triangle': 'Triângulo',
    'Fill': 'Preenchimento',
    'Stroke': 'Contorno',
    'Bold': 'Negrito',
    'Italic': 'Itálico',
    'Underline': 'Sublinhar',
    'Left': 'Esquerda',
    'Center': 'Centro',
    'Right': 'Direita',
    'Apply': 'Ok',
    'Square': 'Quadrado',
    'Custom': 'Livre',
    'Range': 'Valor',
    'Flip X': 'Horizontal',
    'Flip Y': 'Vertical',
    
};

    var imageEditor = new tui.ImageEditor('#image_panel', {
        includeUI: {
                loadImage: {
                    path: '<%=req("urlImagem")%>',
                    name: '<%=req("nomeImagem")%>'
                },
                locale: locale_pt_BR,
                menu: ['crop', 'flip', 'rotate', 'draw', 'text', 'shape'],
                theme: FeegowTheme,
                initMenu: 'draw',
                menuBarPosition: 'botton'
                
            },
        usageStatistics: false
        });

        window.onresize = function() {
            imageEditor.ui.resizeEditor();
        }

</script>