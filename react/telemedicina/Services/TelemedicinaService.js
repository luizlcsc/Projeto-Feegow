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
    }
}