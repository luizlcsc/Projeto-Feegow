function af(a){
    var w = $("body").width();
    
    
//    console.log(w);
//    console.log( $("body").attr("class") );

    if(a=='a'){
        $("#GradeAgenda").addClass("hidden");
        $("#div-agendamento").removeClass("hidden");

        if(w<1400){
            if(!$("body").hasClass("sb-l-m")){
                $("#toggle_sidemenu_l").click();
            }
        }
    }
    if(a=='f'){
        $("#GradeAgenda").removeClass("hidden");
        $("#div-agendamento").addClass("hidden");

        if(w<1400){
            if($("body").hasClass("sb-l-m")){
                $("#toggle_sidemenu_l").click();
            }
        }

        $("#AgAberto").val("");
    }
    $("#rbtns").html("");
}



        
/*	$.magnificPopup.close({
    removalDelay: 500,
    items: {
    src: "#div-agendamento"
},
    // overflowY: 'hidden', // 
    callbacks: {
    beforeClose: function(e) {
	            this.st.mainClass = "mfp-zoomIn";
}
}
});*/

function abreAgenda(horario, id, data, LocalID,ProfissionalID,GradeID){
	$("#div-agendamento").html('<div class="panel"><div class="panel-body"><i class="far fa-spinner fa-spin orange bigger-125"></i> Carregando...</div></div>');
//	$("#modal-agenda").modal({
//        backdrop: 'static',
//        keyboard: false
    //});
    //$("#toggle_sidemenu_l").click();

/*	$.magnificPopup.open({
	    removalDelay: 500,
	    closeOnBgClick:true,
	    items: {
	        src: "#div-agendamento"
	    },
	    // overflowY: 'hidden', // 
	    callbacks: {
	        beforeOpen: function(e) {
	            this.st.mainClass = "mfp-zoomIn";
	            $.ajax({
	                type:"POST",
	                url:"divAgendamento.asp?horario="+horario+"&id="+id+"&data="+data+"&profissionalID="+$("#ProfissionalID").val()+"&LocalID="+LocalID,
	                success:function(data){
	                    $("#div-agendamento").html(data);
	                }
	            });
	        }
	    }
	});
*/



	af('a');
    $.ajax({
    type:"POST",
    url:"divAgendamento.asp?horario="+horario+"&id="+id+"&data="+data+"&profissionalID="+$("#ProfissionalID").val()+"&LocalID="+LocalID+"&GradeID="+GradeID,
    success:function(data){
        $("#div-agendamento").html(data);
        }
    });
}
    function abreBloqueio(BloqueioID, Data, Hora, LocalID){
        if(BloqueioID==-1){
            return;
        }
        af('a');
        
        if(typeof LocalID=="undefined"){
            LocalID=""
        }

        var ProfissionalID = $("#ProfissionalID").val();

        if(typeof ProfissionalID === "undefined"){
            ProfissionalID=""
        }

        $.ajax({
            type:"POST",
            url:"divBloqueio.asp?BloqueioID="+BloqueioID+"&Data="+Data+"&Hora="+Hora+"&ProfissionalID="+ProfissionalID+"&LocalID="+LocalID,
            success:function(data){
                $("#div-agendamento").html(data);
            }
        });
    }
    function changeMonth(newDate){
        $.ajax({
            type:"GET",
            url:"AgendamentoCalendario.asp?Data="+newDate+"&ProfissionalID="+$("#ProfissionalID").val(),
            success:function(data){
                $("#divCalendario").html(data);
            }
        });
    }
    $("#AbrirEncaixe").click(function(){
        abreAgenda('00:00', 0, $('#Data').val(), $("#LocalEncaixe").val());
    });
    $("#AgendaObservacoes").change(function(){
        var data = $("#Data").val();
        if (typeof data === "undefined"){
            data = $("#hData").val();
        }
        $.post("saveAgendaObservacoes.asp?Data="+data+"&ProfissionalID="+$("#ProfissionalID").val(),
        {Observacoes:$(this).val()},
        function(data,status){
            eval(data);
        });
    });	

    function filaEspera(A,ProfissionalID,Data,LocalID){
        
        if(ProfissionalID == null)
        {
            ProfissionalID = $("#ProfissionalID").val();
        }
        if(Data == null)
        {
            Data = $("#Data").val();
        }
        

        $.ajax({
            type:"POST",
            url:"FilaEspera.asp?ProfissionalID="+ProfissionalID+"&Data="+Data+"&A="+A+"&LocalID="+LocalID,
            success: function(data){
                $("#fila").html(data);
            }
        });
    }
    function remarcar(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
        var _ProfissionalID = ProfissionalID;

        if(ProfissionalID==undefined || (ProfissionalID.indexOf("/") > 0) ){
            ProfissionalID = $("#ProfissionalID").val();
        }
        if($("#Data").val()==undefined){
            Data = $("#hData").val();
        }else{
            Data = $("#Data").val();
        }

        if (_ProfissionalID){
            if (_ProfissionalID.indexOf("/") > 0) {
                Data = _ProfissionalID;
            }
        }
        $.ajax({
            type:"POST",
            url:"Remarcar.asp?ProfissionalID="+ProfissionalID+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
            success: function(data){
                eval(data);
            }
        });
    }
    function repetir(AgendamentoID, Acao, Hora, LocalID, ProfissionalID){
        var _ProfissionalID = ProfissionalID;
        if(ProfissionalID==undefined || (ProfissionalID.indexOf("/") > 0) ){
            ProfissionalID = $("#ProfissionalID").val();
        }
        if($("#hData").val()==undefined){
            Data = $("#Data").val();
        }else{
            Data = $("#hData").val();
        }
        if (_ProfissionalID){
            if (_ProfissionalID.indexOf("/") > 0) {
                Data = _ProfissionalID;
            }
        }

        $.ajax({
            type:"POST",
            url:"Repetir.asp?ProfissionalID="+ProfissionalID+"&Data="+Data+"&Hora="+Hora+"&AgendamentoID="+AgendamentoID+"&Acao="+Acao+"&LocalID="+LocalID,
            success: function(data){
                eval(data);
            }
        });
    }
    function detalheFilaEspera(PacienteID, ProfissionalID, Acao){
        $.ajax({
            type:"POST",
            url:"detalheFilaEspera.asp?PacienteID="+PacienteID+"&ProfissionalID="+ProfissionalID+"&Acao="+Acao,
            success: function(data){
                $("#div-agendamento").html(data);
                af('a');
            }
        });
    }
