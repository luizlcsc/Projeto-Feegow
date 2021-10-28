<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalSecundario.asp"-->
<!--div class="tray tray-center"-->

    <style type="text/css">
.select2-container--open {
    z-index: 10003;          /* form dialog z-index:10002 (computed)*/
}
        .popover {
            z-index: 2000;
        }

        .nomeProf {
            color: #fff;
            font-weight: bold;
            text-align: center;
            text-shadow: 1px 1px #000;
        }

        .carinha {
            margin: -2px 4px 1px 3px;
        }

        .item-agenda-1 {
            width: 35%;
        }


        <%if getConfig("ColorirLinhaAgendamento")=1 then%>
        .table-striped > tbody > tr:nth-child(odd) > td, .table-striped > tbody > tr:nth-child(odd) > th{
            background-color: inherit !important;
        }
        .table-hover > tbody > tr:hover > td:not(.nomeProf), .table-hover > tbody > tr:hover > th:not(.nomeProf){
            background-color: inherit !important;
            opacity: 0.8;

        }
        <%end if%>

        .item-agenda-2 {
            width: 25%;
        }

        .item-agenda-3 {
            width: 20%;
        }

        .item-agenda-4 {
            width: 9%;
        }

        .hand {
            cursor: pointer;
        }

            .hand:hover {
                background-color: #F5FDEA;
            }

        .intervalo {
            background-color: #f3f3f3;
        }

        .spanNomePaciente {
            text-overflow: ellipsis;
            overflow: hidden;
            text-align: left;
            width: 100%;
        }


        #div-secundario {
            width: 60%;
        }

        .nomePac {
            display: inline-block;
            max-width: 200px;
            overflow: hidden;
            position: relative;
            text-align: left;
            text-overflow: ellipsis;
            top: 6px;
            vertical-align: top;
            white-space: nowrap;
        }

        .nomeConv {
            max-width: 100px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .table-agenda td {
            cursor: pointer;
            padding: 3px !important;
        }

        .Locais {
                        -webkit-transform: rotate(90deg);
            -moz-transform: rotate(90deg);
            -o-transform: rotate(90deg);
            -ms-transform: rotate(90deg);
            transform: rotate(90deg);
            max-width: 24px;
            height: auto;
            white-space: nowrap;

        /*writing-mode: tb-rl;*/
        }
        #tblCalendario td {
            padding: 0;
            /*height:30px!important;*/
        }

        .table thead > tr > th, .table tbody > tr > th, .table tfoot > tr > th, .table thead > tr > td, .table tbody > tr > td, .table tfoot > tr > td {
            padding: 5px !important;
        }
    </style>


<br />

        


    <div class="panel-body bg-light">
       <div class="row col-xs-12" id="div-agendamento"></div>
       <div class="row col-sm-12" id="GradeAgenda"></div>
    </div>




<script type="text/javascript">
    function loadAgenda(Data, ProfissionalID, loading) {
        if (loading != 'no') {
            $("#GradeAgenda").html('<center>Carregando...</center>');
        }
        $.ajax({
            type:"POST",
            url:"GradeAgenda-1.asp?Data="+Data+"&ProfissionalID="+ProfissionalID,
            success:function(data){
                $("#GradeAgenda").html(data);
            }
        });
    }
    <%
    if req("Conf")="" and req("AgendamentoID")="" then
        DataGet = req("Data")
        ProfissionalGet = req("ProfissionalID")

        if DataGet<>"" then
        %>
        $("#Data").val("<%=DataGet%>");
        $("#ProfissionalID").val("<%=ProfissionalGet%>");
        <%
        end if
        %>

        loadAgenda($("#Data").val(), $("#ProfissionalID").val());
    <%
    else
        if req("Conf")<>"" then
    set conf = db.execute("select ar.*, a.ProfissionalID, a.Data from agendamentosrespostas ar LEFT JOIN agendamentos a on a.id=ar.AgendamentoID LEFT JOIN pacientes p on p.id=a.PacienteID where ar.id= "&req("Conf")&" limit 1")
    %>
    loadAgenda('<%=formatdatetime(conf("Data"),2)%>', '<%=conf("ProfissionalID")%>');
    <%
elseif req("AgendamentoID")<>"" then
    set age = db.execute("select * from agendamentos where id="&req("AgendamentoID"))
    if not age.EOF then
        %>
        $("#ProfissionalID").val('<%=age("ProfissionalID")%>');
    loadAgenda('<%=formatdatetime(age("Data"), 2)%>', '<%=age("ProfissionalID")%>');
    $(document).ready(function(e) {
        abreAgenda('<%= replace(formatdatetime(age("Hora"),4), ":", "") %>', '<%= age("id") %>', "", "")
    });
    <%
end if
end if
end if
%>

<!--#include file="funcoesAgenda1.asp"-->


    $("#ProfissionalID").change(function(){
        af('f');
        loadAgenda($('#Data').val(), $(this).val());
        $("#ProfissionalID").val($(this).val());
        filaEspera('');
    });
    /*$.post("financialPaymentAccounts.asp",{
			   PaymentMethod:$("#PaymentMethod").val(),
			   T:$("#T").val(),
			   },function(data,status){
		  $("#divPaymentMethod").html(data);
		});
	
	
	
	
	$.ajax({
		type:"POST",
		url:"saveAgendaObservacoes.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val(),
		data: $(this).val(),
		success:function(data){
			alert('salvo');
		}
	});
*/
    function imprimir(){



        gtag('event', 'imprimir', {
            'event_category': 'agenda',
            'event_label': "Agenda Diária > Imprimir",
        });
        
        //$("#modal-agenda").modal("show");
        //	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
        // af('a');
        var tk = localStorage.getItem("tk");
        var url = domain + "appointment/print-daily?date="+$("#Data").val()+"&professionalId="+$("#ProfissionalID").val()+"&tk="+tk;
        $("#div-agendamento").append("<iframe style='display:none' src='"+url+"' frameborder='0'></iframe>");

    }

    function altMult(ProfissionalID, Data) {
        $("#modal-table").modal("show");
        $("#div-table").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`);
        $.post("agendaAltMult.asp", {
            ProfissionalID: ProfissionalID,
            Data: Data
        }, function(data){ $('#modal').html(data) });
    }

    function oa(P){
        $("#modal").html("Carregando informa��es do profissional...");
        $("#modal-table").modal("show");
        $.get("ObsAgenda.asp?ProfissionalID=" + P, function (data) {
            $("#modal").html(data);
        });
    }


    setInterval(function (){
        //loadAgenda( $("#Data").val(), $("#ProfissionalID").val(), 'no' );
    }, 10000);
</script>