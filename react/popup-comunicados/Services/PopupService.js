class PopupService {
    static base = (action, call, shift) => {
        fetch(`react/popup-comunicados/api/popup.asp?action=${action}`)
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