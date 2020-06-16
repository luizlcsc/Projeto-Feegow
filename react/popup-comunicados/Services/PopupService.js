class PopupService {
    static base = (action, qs, call, shift) => {
        let queryString = "&" + qs;

        fetch(`react/popup-comunicados/api/popup-api.asp?action=${action}` + queryString)
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
    }

    static getComunicadoById = (comunicadoId, call) => {
        fetch(`react/popup-comunicados/api/popup-api.asp?action=GetComunicadoById&ComunicadoID=` + comunicadoId)
            .then((r) => r.json())
            .then((r) => {
                if (call) {
                    call(r);
                }
            })
        ;
    }

    static getComunicadoByIdUnvisualized = (comunicadoId, call) => {
        fetch(`react/popup-comunicados/api/popup-api.asp?action=GetComunicadoNaoVisualizado&ComunicadoID=` + comunicadoId)
            .then((r) => r.json())
            .then((r) => {
                if (call) {
                    call(r);
                }
            })
        ;
    }
}