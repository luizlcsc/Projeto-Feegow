const WhatsappPopup = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    return (
        <div id="popup-comunicado" className={"popup-tm"} style={{backgroundImage: "linear-gradient(to right, #29b53f, #51cd5e)"}}>
            <div className="">
                <div><img src="react/popup-comunicados/src/img/whatsapp-popup.png" width="90%"/></div>
                <div className="botoes" style={{
                    marginTop: 10
                }}>
                    <button id="ocultar1" type="button" onClick={() => {
                        props.onActionButton(1, props.comunicadoId)
                    }}
                            style={{background: "#ffeb00"}}

                            data-toggle="modal" data-target="#modalWhatsapp" className={"popup-tm-button"}>
                        <strong>Ativar gratuitamente!</strong>
                    </button>
                    <button id="ocultar2" type="button" className="btn btn-recusar marginleft5 popup-tm-button-deny"
                            style={{background: "#37903f"}}
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
                    <strong>Confirmação</strong> de consulta</p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    <strong>Pesquisa</strong> de satisfação</p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    <strong>Notificação</strong> de falta</p>
            </div>
        </div>
    );
};