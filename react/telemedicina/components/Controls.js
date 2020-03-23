const Controls = () => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    const btnSize = 40;


    return (
        <div className={"tm-controls-content"}>

            <div className={"mh5 control-button-content"}>
                <button disabled data-control="audio" data-active="true" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control tm-panel-control-black btn-sm btn btn-rounded btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-mic-on.png" alt=""/>
                </button>
            </div>
            <div className={"mh5 control-button-content"}>
                <button disabled data-control="camera" data-active="false" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control tm-panel-control-black btn btn-sm btn-rounded  btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-cam-on.png" alt=""/>
                </button>
            </div>
            <div className={"mh5 control-button-content"} style={{display: 'none'}}>
                <button data-control="end-call" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control btn btn-sm btn-rounded btn-danger btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-call-off.png" alt=""/>
                </button>
            </div>
            <div className={"mh5 control-button-content"}>
                <button disabled data-control="start-call" style={{width: btnSize, height: btnSize, borderRadius: btnSize/2}} type="button" className="tm-panel-control btn btn-sm btn-rounded btn-success btn-block">
                    <img style={{width: 35}} src="react/telemedicina/src/img/icone-call-on.png" alt=""/>
                </button>
            </div>
        </div>
    );
};
