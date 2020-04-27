const ModalPopup = (props) => {
    const [] = React.useState([]);

    React.useEffect(() => {

    }, []);

    let modalContent = "";

    getUrl(props.modalContentEndpoint, {}, function(data) {
        $(".popup-modal-content").html(data);
    });

    return (


        <div className="modal fade popup-modal-details" id="popup-modal" tabIndex="-1" role="dialog"
             aria-hidden="true">
            <div className="modal-dialog popup-modal-content" role="document" style={{
                width: 900
            }}>
                {modalContent}
            </div>
        </div>

    );
};