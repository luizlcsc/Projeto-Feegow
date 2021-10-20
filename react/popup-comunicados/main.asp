<%

%>

<script crossorigin  src="react/src/react.production.min.js"></script>
<script crossorigin  src="react/src/react-dom.production.min.js"></script>
<script crossorigin  src="react/src/babel.min.js"></script>

<script crossorigin type="text/babel" src="react/popup-comunicados/components/TelemedicinaPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/WhatsappPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/Services/PopupService.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/Popup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/ModalPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/NFSePopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/FeegowHubPopup.js"></script>
<script crossorigin type="text/babel" src="react/popup-comunicados/components/GenericImagePopup.js"></script>

<script src="https://unpkg.com/vue-select@3.0.0"></script>
<link rel="stylesheet" href="https://unpkg.com/vue-select@3.0.0/dist/vue-select.css">

<link type="text/css" rel="stylesheet" href="react/popup-comunicados/src/css/popup.css" />


<script type="text/babel">
    const onActionButton = (action, comunicadoId, close = false) => {
        PopupService.base("PopupVisualizado", "ComunicadoID="+comunicadoId+"&Interesse="+action);
        $('#popup-comunicado').fadeOut();

        if(action === 1 && !close){
            $('#popup-modal').modal("show");
        }
    };

    const onCloseModal = () => {
        $("#react-popup-root").fadeOut();
    }


   let comunicadoId=8;
    let userId = "<%=Session("User")%>";
    let licenseId = "<%=replace(Session("Banco"),"clinic","")%>";

    PopupService.getComunicadoByIdUnvisualized(comunicadoId, (comunicadoObj) => {
        let component = null;

        for(const index in comunicadoObj){
        if(comunicadoObj[index]){
            comunicadoId = comunicadoObj[index].id;
            component = comunicadoObj[index].Componente;

            if(comunicadoId == 3){
                component = <TelemedicinaPopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(comunicadoId == 2){
                component = <WhatsappPopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(comunicadoId == 4){
                component = <NFSePopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(comunicadoId == 5){
                component = <NFSePopup comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(comunicadoId == 6){

            }else if(comunicadoId == 7){
                component = <FeegowHubPopup userId={userId} licenseId={licenseId} onClosePopup={()=>{onCloseModal()}} comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }else if(component == "GenericImagePopup"){
                component = <GenericImagePopup imageUrl={comunicadoObj[index].LinkImagem} linkCallToAction={comunicadoObj[index].LinkCallToAction} userId={userId} licenseId={licenseId} onClosePopup={()=>{onCloseModal()}} comunicadoId={comunicadoId} onActionButton={onActionButton}/>;
            }
            if(component){
                ReactDOM.render(<Popup  modalContentEndpoint={comunicadoObj[index].EndpointModal} component={component}/>,document.getElementById('react-popup-root'));
            }
       } }

    });

</script>

<div id="react-popup-root">

</div>