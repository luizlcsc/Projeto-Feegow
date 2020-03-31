const TelemedicinaPopup = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    return (
        <div id="popup-comunicado" className={"popup-tm"} style={{backgroundImage: "linear-gradient(to right, #2b9dc8, #10bed8)"}}>
            <div className="a123">
                <div><img src="react/popup-comunicados/src/img/telemedicina-popup.png" width="90%"/></div>
                <div className="botoes" style={{
                    marginTop: 10
                }}>
                    <button id="ocultar1" type="button" onClick={() => {
                        props.onActionButton(1, props.comunicadoId)
                    }}
                            style={{background: "#44e044"}}

                            data-toggle="modal" data-target="#modalWhatsapp" className={"popup-tm-button"}>
                        <strong>Ativar agora!</strong>
                    </button>
                    <button id="ocultar2" type="button" className="btn btn-recusar marginleft5 popup-tm-button-deny"
                            style={{background: "#1a81ae"}}
                            onClick={() => {
                                props.onActionButton(0, props.comunicadoId)
                            }}>
                        <strong>Não, obrigado!</strong>
                    </button>
                </div>
            </div>
            <div className={"popup-tm-details-container"}>
                <i className="fa fa-remove pull-right" onClick="$('#comunicado').fadeOut();"/>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    <strong>Teleconsultas</strong></p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    Pagamento <strong>Online</strong></p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    <strong>Integrado</strong> ao agendamento online</p>
            </div>
        </div>
    );
};