const Controls = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    const btnSize = 40;


    return (
        <div className={"tm-controls-content"}>

            <div className={"mh5 control-button-content"}>
                <button data-placement="bottom" title={"Ligar/Desligar microfone"} data-toggle="tooltip" disabled data-control="audio" data-active="true" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control tm-panel-control-black btn-sm btn btn-rounded btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-mic-on.png" alt="Ligar/Desligar microfone"/>
                </button>
            </div>
            <div className={"mh5 control-button-content"}>
                <button data-placement="bottom" title={"Ligar/Desligar câmera"}  data-toggle="tooltip" disabled data-control="camera" data-active="false" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control tm-panel-control-black btn btn-sm btn-rounded  btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-cam-on.png" alt="Ligar/Desligar câmera"/>
                </button>
            </div>
            <div className={"mh5 control-button-content"} style={{display: 'none'}}>
                <button data-placement="bottom" title={"Compartilhar tela"}  data-toggle="tooltip" data-control="share" data-active="false" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control tm-panel-control-black btn btn-sm btn-rounded  btn-block">
                    <img style={{width: 20}} src="react/telemedicina/src/img/compartilhar-tela.png" alt="Compartilhar tela"/>
                </button>
            </div>
            <div className={"mh5 control-button-content"} style={{display: 'none'}}>
                <button data-placement="bottom" title={"Encerrar chamada"}  data-toggle="tooltip" data-control="end-call" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control btn btn-sm btn-rounded btn-danger btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-call-off.png" alt="Encerrar"/>
                </button>
            </div>
            <div className={"mh5 control-button-content"}>
                <button data-placement="bottom" title={"Iniciar chamada"}  data-toggle="tooltip" disabled data-control="start-call" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control btn btn-sm btn-rounded btn-success btn-block">

                    { props.isConnecting ? (
                        <div style={{fontSize: 20, display: "flex", textAlign: "center"}}>
                            <i className="fa fa-spin fa-circle-o-notch"></i>
                        </div>
                    ) : (<img style={{width: 35}} src="react/telemedicina/src/img/icone-call-on.png" alt="Iniciar chamada"/>)}
                </button>
            </div>
        </div>
    );
};
