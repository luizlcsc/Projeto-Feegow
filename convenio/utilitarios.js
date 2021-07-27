/* ----------------------------------------------------------------------------------------------------------------------
	JS MEDICAMENTOS
---------------------------------------------------------------------------------------------------------------------- */

var utilitarios  = function(){

    function request (caminho,parametros,callback=false){
        let url = `${caminho}.asp?${parametros}`
        $.get( url )
        .done(function(data) {
            callback(data)
        })
    }

    function setDefaults(params, defaults){
        var recursive = true;
        return $.extend(recursive, {}, defaults, params);
    }

    /**
     * Funções externadas
     */
    return {
        request             : request,
        setDefaults         : setDefaults,
    };
}() 