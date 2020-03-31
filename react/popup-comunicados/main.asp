<%

%>

<script crossorigin  src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
<script crossorigin  src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>
<script crossorigin  src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/TelemedicinaPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/WhatsappPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/Services/PopupService.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/Popup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/ModalPopup.js"></script>

<link type="text/css" rel="stylesheet" href="react/popup-comunicados/src/css/popup.css" />

<script type="text/babel">
    const onActionButton = (action, comunicadoId) => {
        PopupService.base("PopupVisualizado", "ComunicadoID="+comunicadoId+"&Interesse="+action);
        $('#popup-comunicado').fadeOut();

        if(action === 1){
            $('#popup-modal').modal("show");
        }
    };

    let comunicadoId = 3    ;
    PopupService.getComunicadoByIdUnvisualized(comunicadoId, (comunicadoObj) => {
        let component = null;

        if(comunicadoObj[0]){
            if(comunicadoId === 3){
                component = <TelemedicinaPopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(comunicadoId === 2){
                component = <WhatsappPopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }

            ReactDOM.render(<Popup modalContentEndpoint={comunicadoObj[0].EndpointModal} component={component}/>,document.getElementById('react-popup-root'));
        }

    });

</script>

<div id="react-popup-root">

</div>