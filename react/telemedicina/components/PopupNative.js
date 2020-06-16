const PopupNative = (props) => {
    const [isLoading, setIsLoading] = React.useState(true);
    const [error, setErrorMessage] = React.useState(false);
    const [roomUrl, setRoomUrl] = React.useState(null);


    const generateRoom = async () => {
        try{
            const room = await TelemedicinaService.generateRoom(props.profissionalId, props.pacienteId, props.agendamentoId, props.env);

            if(room.room_url){
                setErrorMessage(false);
                setRoomUrl(room.room_url);
            }else{
                setErrorMessage("Não foi possível criar a sala.");
            }
        }catch (e) {
            setErrorMessage("-");
        }


        setIsLoading(false);
    };

    React.useEffect(() => {
        generateRoom();
    }, []);

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
            // $videoPatient = document.getElementById("pattern"),
            // $videoDoctor = document.getElementById("local"),
            $iframe = document.getElementById("tm-iframe"),

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

        // $videoPatient.classList.add("tm-video-maximized");
        // $videoPatient.style.width = "80%";
        // $videoDoctor.style.width = "150px";
        $iframe.classList.add("tm-iframe-maximized");

        $("#root").draggable("destroy");
    };

    const onMinimize = () => {
        const $popup = document.getElementById("root"),
            $popupDialog = document.getElementById("tm-popup-dialog"),
            $popupBackdrop = document.getElementById("tm-popup-backdrop"),
            // $videoPatient = document.getElementById("pattern"),
            $iframe = document.getElementById("tm-iframe"),
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
        $iframe.classList.remove("tm-iframe-maximized");
        // $videoDoctor.style.width = "75px";

        $("#root").draggable();
    };

    const renderVideo = () => {

        if (isLoading ) {
            return (
                <div style={{fontSize: 50,textAlign: "center", padding: 40}}>
                    <i className="fa fa-spin fa-circle-o-notch"></i>
                </div>);

        }else{
            if(error){
                return (
                    <div>
                        {error}
                    </div>
                )
            }else{
                return (<iframe id={"tm-iframe"} style={{
                    width: "100%"
                }} frameBorder="0" src={roomUrl}
                                allow="camera;microphone;fullscreen;speaker;chat"/>);
            }
        }
    }

    return (
        <div>
            <div className="modal-backdrop fade in" id={"tm-popup-backdrop"} style={{display: "none"}}/>

            <div id={"tm-popup-dialog"}>
                <div id={"tm-popup-content"}>
                    <Header renderMode={"absolute"} allowVideoChange={false} bgColor={"transparent"}
                            onMaximize={() => onMaximize()} onReconnect={() => onReconnect()} onClose={() => onClose()}
                            onMinimize={() => onMinimize()} changeToFeegowVideo={() => changeToFeegowVideo()}
                            onZoomClick={() => onZoomClick()}/>
                    <div style={{
                        display: "flex",
                          justifyContent: "center",
                        minHeight: 100,
                        alignItems: "center"
                    }}>
                        {renderVideo()}
                    </div>
                </div>

            </div>
        </div>


    );
};
