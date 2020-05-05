const ZoomiFrame = (props) => {
    const [isConnecting, setIsConnecting] = React.useState(false);


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

    return (
        <div>
            <div className="modal-backdrop fade in" id={"tm-popup-backdrop"} style={{display: "none"}}/>

            <div id={"tm-popup-dialog"}>
                <div id={"tm-popup-content"}>
                    <Header bgColor={"#fff"} buttonColor={"rgb(21, 21, 21)"} onMaximize={() => onMaximize()}  onReconnect={() => onReconnect()} onClose={() => onClose()} onMinimize={() => onMinimize()}/>
                    <div style={{
                        display: "flex"
                    }}>
                        <iframe id={"tm-iframe"} style={{
                            width: "100%"
                        }} frameBorder="0" src="https://localhost:9999/index.html"
                                allow="camera;microphone;fullscreen;speaker;chat"/>
                    </div>
                </div>

            </div>
        </div>


    );
};
