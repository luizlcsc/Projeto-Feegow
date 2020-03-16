<link rel="stylesheet" href="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.css">
<link type="text/css" href="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.css" rel="stylesheet">
<!--#include file="connect.asp"-->

<script type="text/javascript" src="https://uicdn.toast.com/tui.code-snippet/v1.5.0/tui-code-snippet.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/3.6.0/fabric.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.min.js"></script>
<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/1.3.3/FileSaver.min.js"></script>
<script type="text/javascript" src="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.js"></script>

    <div style="height:600px;">
        <div id="injection_site"  >

        </div>
    </div>
<script type="text/javascript">

    let FeegowTheme = {
        'common.bi.image': 'assets/img/logo_white.png',
        'common.bisize.width': '156px',
        'common.bisize.height': '32px',
        'common.backgroundImage': 'none',
        'common.backgroundColor': '#217dbb',
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

        // main icons
        'menu.normalIcon.color': '#fff',
        'menu.activeIcon.color': '#3498db',
        'menu.disabledIcon.color': '#000',
        'menu.hoverIcon.color': '#3498db',
        'menu.iconSize.width': '24px',
        'menu.iconSize.height': '24px',

        // submenu icons
        'submenu.normalIcon.color': '#BBB',
        'submenu.activeIcon.color': '#fff',
        'submenu.iconSize.width': '32px',
        'submenu.iconSize.height': '32px',

        // submenu primary color
        'submenu.backgroundColor': '#3498db',
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
                path: '<%=urlImagem%>',
                name: '<%=nomeImagem%>'
            },
            menu: ['crop', 'flip', 'rotate', 'draw', 'text'],
            theme: FeegowTheme, // or whiteTheme
            initMenu: 'draw',
            menuBarPosition: 'bottom'
        },
        cssMaxWidth: 800, // Component default value: 1000
        cssMaxHeight: 800,  // Component default value: 800
        usageStatistics:false
    });

</script>