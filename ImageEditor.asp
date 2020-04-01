<!--#include file="connect.asp"-->

    <div id="image_panel" style="min-height: 800px;"></div>

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
        'downloadButton.display': 'none',

        // main icons
        'menu.normalIcon.color': '#fff',
        'menu.activeIcon.color': '#3498db',
        'menu.disabledIcon.color': '#484b54',
        'menu.hoverIcon.color': '#3498db',
        'menu.iconSize.width': '24px',
        'menu.iconSize.height': '24px',

        // submenu icons
        'submenu.normalIcon.color': '#fff',
        'submenu.activeIcon.color': '#3498db',
        'submenu.hoverIcon.color': '#3498db',
        'submenu.iconSize.width': '24px',
        'submenu.iconSize.height': '24px',

        // submenu primary color
        'submenu.backgroundColor': '#226b9c',
        'submenu.partition.color': '#3c3c3c',

        // submenu labels
        'submenu.normalLabel.color': '#fff',
        'submenu.normalLabel.fontWeight': 'lighter',
        'submenu.activeLabel.color': '#3498db',
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
        'colorpicker.title.color': '#fff',

    };

    var imageEditor = new tui.ImageEditor('#image_panel', {
        includeUI: {
                loadImage: {
                    path: '<%=req("urlImagem")%>',
                    name: '<%=req("nomeImagem")%>'
                },
                menu: ['crop', 'flip', 'rotate', 'draw', 'text'],
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