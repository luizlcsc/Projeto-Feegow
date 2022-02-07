var data = '{"success":true,"content":[{"especialidade_id":263,"nome":"Acupuntura","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"225105"},{"especialidade_id":281,"nome":"Agente Comunit\u00e1rio de Sa\u00fade","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"515105"},{"especialidade_id":258,"nome":"Alergia e imunologia","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"225110"},{"especialidade_id":270,"nome":"Anestesiologista","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"225151"},{"especialidade_id":212,"nome":"Auxiliar de enfermagem","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"322230"},{"especialidade_id":84,"nome":"Biol\u00f3go","consulta_id":426,"consulta_online_id":1846,"exibir_agendamento_online":1,"codigo_tiss":"221105"}]}'

function run(data) {
    var count = 0
    var objeto = JSON.parse(data);
    var stringArray = []

    objeto.content.forEach(mostrarNome);

    function mostrarNome(especialidade) {
        count++ //começa de 0 e soma +1 a cada vez do loop (0, 1, 2, 3 ...)
        stringArray.push(count)
        // console.log(formattedString)
    }
    console.log(stringArray.join("\r\n"))
}
run(data)



// 1 - Biologo
// 2 - Cardiologista
// 3 - Pediatra