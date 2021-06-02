const FeegowHubPopup = (props) => {
    const [notes, setNotes] = React.useState(null);
    const [scoreRating, setScoreRating] = React.useState(null);
    const [notesPlaceholder, setNotesPlaceholder] = React.useState(null);
    const [afterRatingMessage, setAfterRatingMessage] = React.useState(null);
    

      //opcoes : 

    React.useEffect(() => {

    }, []);

    const endSurvey = () => {
            const $surveyContent = $("#csat-pesquisa");
            const $thanksSurvey = $('#csat-agradecimento');

            $surveyContent.fadeOut(function(){
                  $thanksSurvey.fadeIn();                
            })
    };

    const script = document.createElement("script");

    const triggerActionOnRating = (rating) => {
      const $ratingNotesContent = $('#csat-notes-content');
      const $ratingNotes = $('#csat-notes');
      const $insatisfeitoContent = $("#csat-insatisfeito-content");
      const $naoExibir = $("#csat-nao-exibir");
  


      setTimeout(function(){
            $naoExibir.css("display","none");

            $ratingNotesContent.fadeIn();
            $ratingNotes.focus();
      }, 600);

      if(rating <= 3){
            setAfterRatingMessage("Sentimos muito por isso... Ajude-nos a melhorar!")
            setNotesPlaceholder("Descreva como podemos melhorar");
            
            setTimeout(function(){
                  $insatisfeitoContent.fadeIn();
            }, 400);

                  
      }else{
            setNotesPlaceholder("O que você mais gosta na Feegow?");
            
            setTimeout(function(){
                  $insatisfeitoContent.fadeOut();
            }, 400);

      }
    }

    const cancelSurvey = () => {
          props.onClosePopup();
    }

    const setRating = (rating) => {
      setScoreRating(rating);

      triggerActionOnRating(rating);

      //aguarda animação :)

    };

    setTimeout(function(){
          $("#popup-comunicado").addClass("in");
    }, 200);

    return (
            
            <div id="popup-comunicado" className={"container-popup box-teaser fade"}>
                  <link type="text/css" rel="stylesheet" href="react/popup-comunicados/src/css/feegow-hub.css" />

                  <div className="conteudo-popup">
                        <div class="chamada"><img src="https://feegowclinic.com.br/popup-feegow-hub/assets/img/chamada.png" alt=""/></div>
                              <div class="servicos">
                                    <img src="https://feegowclinic.com.br/popup-feegow-hub/assets/img/servicos.png" alt=""/></div>
                              <div class="botoes">
                              <button id="ocultar1" type="button" class="btn btn-aceitar">
                                    <a onClick={() => {
                                                props.onActionButton(1, props.comunicadoId, true)
                                    }} href={"https://promo.feegowclinic.com.br/landing-page-feegow-hub?u="+props.userId+"&l="+props.licenseId+"&utm_source=internal&utm_campaign=feegow-hub"} target="blank">Tenho interesse!</a></button>
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