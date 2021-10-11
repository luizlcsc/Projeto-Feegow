const GenericImagePopup = (props) => {
    React.useEffect(() => {

    }, []);

    const script = document.createElement("script");


    setTimeout(function(){
        $("#popup-comunicado").addClass("in");
    }, 200);

    return (
            
            <div id="popup-comunicado" className={"container-popup box-teaser fade"}>
                  <link type="text/css" rel="stylesheet" href="react/popup-comunicados/src/css/generic-image.css" />

                  <div className="conteudo-popup">
                        <div class="chamada"><a onClick={() => {
                                props.onActionButton(1, props.comunicadoId, true)
                            }} target="_blank" href={props.linkCallToAction}><img class="popup-image" src={props.imageUrl} alt=""/></a></div>
                          <div class="botoes">
                             <button id="ocultar2" type="button" class="btn btn-recusar marginleft5"><a href="#"
                              onClick={() => {
                                    props.onActionButton(0, props.comunicadoId, true)
                                }}
                              > Não, obrigado!</a></button>
                        </div>
                  </div>
            </div>
    );
};