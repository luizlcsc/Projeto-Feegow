const Popup = (props) => {
    const [isConnecting, setIsConnecting] = React.useState(false);


    const listeners = {
        onPeerReady: () => {
            telemedicine.login(10000);
        }
    }

    const telemedicine = new Telemedicine(props.licencaId, props.profissionalId, props.pacienteId, props.agendamentoId, null, listeners);

    telemedicine.setApiDomain((props.env === "production" ? 'https://api.feegow.com.br' : 'http://localhost:8000') + "/patient-interface/" + props.licencaId);
    telemedicine.setUser("doctor");
    telemedicine.setOnIsConnecting((isConn) => {
        setIsConnecting(isConn);
    });


    setTimeout(() => {
        telemedicine.init();
    }, 500);

    const onClose = () => {
        if (confirm("Tem certeza que deseja fechar?")) {
            const $popup = document.getElementById("root");

            $popup.remove();
            telemedicine.close();
            TelemedicinaService.base("Finaliza");
        }
    }

    const onMaximize = () => {
        const $popup = document.getElementById("root"),
            $popupDialog = document.getElementById("tm-popup-dialog"),
            $popupBackdrop = document.getElementById("tm-popup-backdrop"),
            $videoPatient = document.getElementById("pattern"),
            $videoDoctor = document.getElementById("local"),
            $popupContent = document.getElementById("tm-popup-content");


        $popup.classList.add("modal");
        $popupDialog.style["z-index"] = 99999;
        $popup.classList.remove("container-popup");
        $popup.classList.add("tm-popup-modal-expanded");
        $popupBackdrop.style.display = 'block';
        $popupDialog.classList.add("modal-dialog");
        $popupDialog.classList.add("modal-lg");
        $popupContent.classList.add("tm-popup-content-expanded");
        $popupContent.classList.add("modal-content");

        $videoPatient.classList.add("tm-video-maximized");
        // $videoPatient.style.width = "80%";
        $videoDoctor.style.width = "150px";

        $("#root").draggable("destroy");
    };

    const onMinimize = () => {
        const $popup = document.getElementById("root"),
            $popupDialog = document.getElementById("tm-popup-dialog"),
            $popupBackdrop = document.getElementById("tm-popup-backdrop"),
            $videoPatient = document.getElementById("pattern"),
            $videoDoctor = document.getElementById("local"),
            $popupContent = document.getElementById("tm-popup-content");


        $popup.classList.remove("modal");
        $popupDialog.style["z-index"] = 99999;
        $popup.classList.add("container-popup");
        $popup.classList.remove("tm-popup-modal-expanded");
        $popupBackdrop.style.display = 'none';
        $popupDialog.classList.remove("modal-dialog");
        $popupDialog.classList.remove("modal-lg");
        $popupContent.classList.remove("tm-popup-content-expanded");
        $popupContent.classList.remove("modal-content");

        // $videoPatient.style.width = "100%";
        $videoPatient.classList.remove("tm-video-maximized");
        $videoDoctor.style.width = "75px";

        $("#root").draggable();
    };

    const onZoomClick = () => {
        localStorage.setItem("telemedicineDefaultApp","zoom");
        location.reload();
    };
    const onReconnect = () => {

        location.reload();
        // telemedicine.reconnect();
    };

    const onConfig = () => {
        const $configContainer = document.getElementById("tm-config-container");
        $configContainer.style.display = 'block';
    };


    const onCloseConfig = () => {
        const $configContainer = document.getElementById("tm-config-container");
        $configContainer.style.display = 'none';
    }


    const onApplyConfig = () => {
        const $configContainer = document.getElementById("tm-config-container");
        $configContainer.style.display = 'none';
    }



    return (
        <div>
            <div className="modal-backdrop fade in" id={"tm-popup-backdrop"} style={{display: "none"}}/>

            <div id={"tm-popup-dialog"}>
                <div id={"tm-popup-content"}>
                    <Header renderMode={"absolute"} onMaximize={() => onMaximize()}  onReconnect={() => onReconnect()} onConfig={() => onConfig()} onClose={() => onClose()} onMinimize={() => onMinimize() } onZoomClick={()=> onZoomClick()}/>
                    <Video/>

                    <div className={"tm-parent-controls-content"}>
                        <Controls isConnecting={isConnecting}/>
                    </div>
                </div>

            </div>
            <div className={"tm-config-container"} id={"tm-config-container"}>
                <div className="row">
                    <div className="col-md-6">
                        <label  htmlFor="mic-select">Microfone</label>
                        <select name="mic-select" id="mic-select" className="form-control input-sm"></select>
                    </div>
                    <div className="col-md-6">
                        <label  htmlFor="cam-select">Câmera</label>
                        <select name="cam-select" id="cam-select" className="form-control input-sm"></select>
                    </div>

                    <div className="col-md-3  mt10">
                        <button onClick={() => {
                            onCloseConfig()
                        }} className="btn btn-xs btn-block default">
                            Fechar
                        </button>
                    </div>
                    <div className="col-md-offset-6 col-md-3 mt10">
                        <button onClick={() => {
                            onApplyConfig()
                        }} data-control="apply-config" className="tm-panel-control btn btn-xs btn-block btn-primary">
                            Aplicar
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
};
