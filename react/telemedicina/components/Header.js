const Header = (props) => {
    const [isMaximized, setIsMaximized] = React.useState(false);

    React.useEffect(() => {

    }, []);


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

            <div className="btn-group " style={{zIndex: 999999999}}>
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
                    <li>
                        <button
                        style={{border: "none", background: "transparent"  }}
                        onClick={() => {
                            props.onZoomClick();
                        }} className={""}>
                            <img style={{width: 25}} src="react/telemedicina/src/img/icon.png" alt=""/> Utilizar Zoom
                            </button>
                    </li>
                </ul>
            </div>


        </div>
    );
};
