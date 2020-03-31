const Popup = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    const onActionButton = (action) => {
        //    action onde 0 eh nao e 1 eh sim
        if (action === 1) {
            // $(".popup-modal-content").html(data);
        } else {
            $('#comunicado').fadeOut();
        }
    };

    return (
        <div>
            {props.component}
            <ModalPopup modalContentEndpoint={props.modalContentEndpoint}/>
        </div>
    );
};