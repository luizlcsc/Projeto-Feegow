const Header = (props) => {
    const [isMaximized, setIsMaximized] = React.useState(false);

    React.useEffect(() => {

    }, []);


    return (
        <div className={"tm-header-content"}>
            {!isMaximized ? (
                <button onClick={() => {
                    setIsMaximized(true);

                    props.onMaximize();
                }} className={"tm-header-btn tm-panel-control btn btn-xs btn-primary"}>
                    <img style={{width: 25}} src="react/telemedicina/src/img/icone-maximizar.png" alt=""/>
                </button>
            ) : (
                <button onClick={() => {
                    setIsMaximized(false);

                    props.onMinimize();
                }} className={"tm-header-btn tm-panel-control btn-xs btn-primary"}>
                    <img style={{width: 25}} src="react/telemedicina/src/img/icone-minimizar.png" alt=""/>
                </button>
            )}

            <button onClick={() => {
                props.onClose();
            }} className={"tm-header-btn tm-panel-control btn-xs btn-primary"}>
                <img style={{width: 25}} src="react/telemedicina/src/img/icone-fechar.png" alt=""/>
            </button>

        </div>
    );
};
