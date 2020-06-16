const Header = (props) => {
    const [isMaximized, setIsMaximized] = React.useState(false);

    React.useEffect(() => {

    }, []);

    const choosenVideo = () => {
        if(localStorage.getItem("telemedicine_default_app") === "zoom")
        {
            return(
                <button
                    style={{border: "none", background: "transparent" ,marginLeft:10,marginRight:5 }}
                    onClick={() => {
                        props.changeToFeegowVideo();

                    }} className={""}>
                    <i className={"fa fa-info"}  style={{marginRight:5 }}></i> Usar vídeo padrão
                </button>
            )
        }
        return (
            <button
                style={{border: "none", background: "transparent" ,marginLeft:10 ,marginRight:5 }}
                onClick={() => {
                    props.onZoomClick();
                }} className={""}>
                <i className={"fa fa-info"}  style={{marginRight:5 }}></i> Usar Zoom
            </button>)
    }

    return (
        <div className={props.renderMode === "absolute" ? "tm-header-content-abs" : "tm-header-content"}
        style={{
            backgroundColor: props.bgColor
        }}
        >
            {!isMaximized ? (
                <button
                    style={{
                        backgroundColor: props.buttonColor
                    }}
                    onClick={() => {
                    setIsMaximized(true);

                    props.onMaximize();
                }} className={"tm-header-btn tm-panel-control btn btn-xs btn-primary"}>
                    <img style={{width: 25}} src="react/telemedicina/src/img/icone-maximizar.png" alt=""/>
                </button>
            ) : (
                <button
                    style={{
                        backgroundColor: props.buttonColor
                    }}
                    onClick={() => {
                    setIsMaximized(false);

                    props.onMinimize();
                }} className={"tm-header-btn tm-panel-control btn-xs btn-primary"}>
                    <img style={{width: 25}} src="react/telemedicina/src/img/icone-minimizar.png" alt=""/>
                </button>
            )}

            <button
                style={{
                    backgroundColor: props.buttonColor
                }}
                onClick={() => {
                props.onClose();
            }} className={"tm-header-btn tm-panel-control btn-xs btn-primary"}>
                <img style={{width: 25}} src="react/telemedicina/src/img/icone-fechar.png" alt=""/>
            </button>

            <div className="btn-group hidden" style={{zIndex: 999999999}}>
                <button style={{
                    backgroundColor: props.buttonColor
                }}
                        type="button" className={"tm-header-btn tm-panel-control btn-xs btn-primary dropdown-toggle"} data-toggle="dropdown"><i className="fa fa-cog"></i>
                </button>
                <ul className="dropdown-menu pull-left" role="menu">
                    <li>
                        <a href="#" onClick={()=> {
                            props.onConfig()
                        }}><i className="fa fa-cog"></i> Configurações</a>
                    </li>
                    <li>
                        <a href="#" onClick={()=> {
                            props.onReconnect()
                        }}><i className="fa fa-undo"></i> Reconectar</a>
                    </li>
                    <li role="presentation" className="divider"></li>
                    <li>
                        {props.allowVideoChange ? choosenVideo() : null}
                    </li>
                </ul>
            </div>


        </div>
    );
};
