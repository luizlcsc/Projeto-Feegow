class TelemedicinaService {
    static base = (action, call, shift) => {
        fetch(`react/telemedicina/api/telemedicina.asp?action=${action}`)
            .then((r) => r.json())
            .then((r) => {
                if (shift) {
                    r.unshift({value: "", label: ""});
                }
                if (call) {
                    call(r);
                }
            })
        ;
    };

    static endpointCreateZoomUser = (url, agendamentoId) => {
        // AJAX request
        let objct = {};
        objct.agendamentoId = agendamentoId;
        jQuery.ajax({
            url: url,
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(objct),
            success: function (response) {
                return TelemedicinaService.endpointCreateZoomMeeting("http://localhost:8000/zoom-integration/17vqr/create-zoom-meeting/",response,agendamentoId);
            },
            error: function(response) {
                return response;
            }
        });
    };

    static endpointCreateZoomMeeting = (url, zoomUser, agendamentoId) =>{
        // AJAX request
        let object = {};
        object.zoomUserId = zoomUser.zoomUserId;
        object.agendamentoId = agendamentoId;
        $.ajax({
            url: url,
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(object),
            success: function (response) {
                console.log(response);
                return response;
            },
            error: function(response) {
                return response;
            }
        });
    }
}
