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

    const onReconnect = () => {
        telemedicine.reconnect();
    }



    return (
        <div>
            <div className="modal-backdrop fade in" id={"tm-popup-backdrop"} style={{display: "none"}}/>

            <div id={"tm-popup-dialog"}>
                <div id={"tm-popup-content"}>
                    <Header renderMode={"absolute"} onMaximize={() => onMaximize()}  onReconnect={() => onReconnect()} onClose={() => onClose()} onMinimize={() => onMinimize()}/>
                    <Video/>

                    <div className={"tm-parent-controls-content"}>
                        <Controls isConnecting={isConnecting}/>
                    </div>
                </div>

            </div>
        </div>
    );
};
