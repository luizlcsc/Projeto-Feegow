const NFSePopup = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    return (
        <div id="popup-comunicado" className={"popup-tm"} style={{backgroundImage: "linear-gradient(to right, #11B7D3, #11B7D3)"}}>
            <div className="a123">
                <div style={{
                    fontSize: 18,
                    fontWeight: 600,
                    color: "#fff"
                }}>
                    <img src="react/popup-comunicados/src/img/notafiscal-popup.png" width="30px"/>
                    NFS-e 2.0
                </div>
                <div className="botoes" style={{
                    marginTop: 10
                }}>
                    <button id="ocultar1" type="button" onClick={() => {
                        props.onActionButton(1, props.comunicadoId)
                    }}
                            style={{background: "#44e044"}}

                            data-toggle="modal" data-target="#modalWhatsapp" className={"popup-tm-button"}>
                        <strong>Configurar agora!</strong>
                    </button>

                </div>
            </div>
            <div className={"popup-tm-details-container"}>
                <i className="fa fa-remove pull-right" onClick="$('#comunicado').fadeOut();"/>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    <strong>Emissão em lote</strong></p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    Integrado à <strong>prefeitura</strong></p>
                <p className={"popup-tm-detail"}>
                    <span className="glyphicon glyphicon-ok popup-tm-defail-icon"
                          aria-hidden="true"/>
                    Configuração simplificada</p>
            </div>
        </div>
    );
};