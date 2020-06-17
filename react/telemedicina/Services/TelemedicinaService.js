const  getEnvUrl = (env, endpoint) => {
    return (env === "production" ? "https://app.feegow.com.br/":"http://localhost:8000/") + endpoint;
};

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

    static endpointCreateZoomUser = async (agendamentoId, env) => {

        let objct = {};
        objct.agendamentoId = agendamentoId;
        const response  = await jQuery.ajax({
            url: getEnvUrl(env,"zoom-integration/create-zoom-user"),
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(objct),

        });
        if(!response.isUserVerified)
        {
            return {'isUserVerified':false};
        }
        const meeting = await TelemedicinaService.endpointCreateZoomMeeting(response,agendamentoId,env);
        return {isUserVerified:true,meeting: meeting};
    };

    static endpointEndZoomMeeting = async (agendamentoId,env) => {
        let objct = {};
        objct.agendamentoId = agendamentoId;
        return await  jQuery.ajax({
            url: getEnvUrl(env,"zoom-integration/end-zoom-meeting/"),
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(objct)
        });
    };

    static endpointCreateZoomMeeting = async (zoomUser, agendamentoId,env) =>{
        // AJAX request
        let object = {};
        object.zoomUserId = zoomUser.zoomUserId;
        object.agendamentoId = agendamentoId;
        return await $.ajax({
            url: getEnvUrl(env,"zoom-integration/create-zoom-meeting"),
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(object)
        });
    }

    static generateRoom = async (doctorId, patientId, appointmentId,env) =>{
        // AJAX request
        let object = {};

        return await $.ajax({
            url: getEnvUrl(env,`/telemedicine-room/generate/${doctorId}/${patientId}/${appointmentId}`),
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(object)
        });
    }
}
