const ZoomiFrame = (props) => {
    const [isVerified,setIsVerified] = React.useState(false);
    const [isLoading,setIsLoading] = React.useState(true);


    const onClose = () => {
        if (confirm("Tem certeza que deseja fechar?")) {
            const $popup = document.getElementById("root");

            $popup.remove();
            telemedicine.close();
            TelemedicinaService.base("Finaliza");
        }
    }
    const changeToFeegowVideo = async () => {
        try{
            const response = await TelemedicinaService.endpointEndZoomMeeting(props.agendamentoId, props.env);
        }catch(e){
            console.log(e.message);
        }
            localStorage.setItem("telemedicine_default_app","");
            location.reload();
    };

    const onZoomClick = () => {
        localStorage.setItem("telemedicine_default_app","zoom");
        location.reload();
    };
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

    const getUserZoom = async () => {
        const userZoom = await TelemedicinaService.endpointCreateZoomUser(props.agendamentoId, props.env);

        setIsLoading(false);
        setIsVerified(userZoom.isUserVerified);
    }
    const reloadUser = async () => {
        setIsLoading(true);
        await getUserZoom();
    }
    React.useEffect(() => {
        getUserZoom();
    },[]);


    if(isLoading)
    {
        return(
            <div style={{fontSize: 50,textAlign: "center", padding: 40}}>
                <i className="fa fa-spin fa-circle-o-notch"></i>
            </div>
        );
    }

    const baseEndpointUrl = TelemedicinaService.getEnvUrl(env,"");
    const allowVideoChange = parseInt(props.licencaId) === 100000 ? true : false;

    return isVerified ?
        (
            <div>
                <div className="modal-backdrop fade in" id={"tm-popup-backdrop"} style={{display: "none"}}/>

                <div id={"tm-popup-dialog"}>
                    <div id={"tm-popup-content"}>
                        <Header allowVideoChange={true} bgColor={"#fff"} buttonColor={"rgb(21, 21, 21)"} onMaximize={() => onMaximize()}  onReconnect={() => onReconnect()} onClose={() => onClose()} onMinimize={() => onMinimize()} changeToFeegowVideo={()=>changeToFeegowVideo()} onZoomClick={()=>onZoomClick()} />
                        <div style={{
                            display: "flex"
                        }}>
                            <iframe id={"tm-iframe"} style={{
                                width: "100%"
                            }} frameBorder="0" src={baseEndpointUrl+`zoom-integration/zoom-host-meeting/${props.agendamentoId}?tk=`+localStorage.getItem("tk")}
                                    allow="camera;microphone;fullscreen;speaker;chat"/>
                        </div>
                    </div>

                </div>
            </div>


        ): (
                <div className="alert alert-light">Um link de verificação da sua conta Zoom foi enviado para o e-mail cadastrado.
                    <br />
                    <br />
                    <button className="btn-rounded btn btn-primary btn-sm" style={{marginBottom:15,float:"right"}} onClick={() => {reloadUser()}}>Já confirmei meu e-mail</button>
                </div>
        );
};
