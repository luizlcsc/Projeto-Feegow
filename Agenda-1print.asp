	  <link rel="stylesheet" type="text/css" href="assets/skin/default_skin/css/theme.css">

      <script src="vendor/jquery/jquery-1.11.1.min.js"></script>
      <script src="vendor/jquery/jquery_ui/jquery-ui.min.js"></script>
      <script src="vendor/plugins/select2/select2.min.js"></script> 
      <script src="vendor/plugins/select2/select2.full.min.js"></script> 



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

        .modal-dialog {
            width: 90%;
            min-width: 380px;
            max-width: 1080px;
        }

        #div-secundario {
            width: 60%;
        }

        .nomePac {
            display: inline-block;
            max-width: 300px;
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

        table tr td{
            font-size:10px;
        }
    </style>
    <!--#include file="connect.asp"-->
    <!--#include file="modalSecundario.asp"-->
<div style=" position: absolute;left: 0;top: 0;width: 100%;color: black;">
  <small>Feegow Clinic : v. 7.0</small>
</div>
<h3 class="text-center" id="NomeProfissional">Nome do Profissional</h3>
<h5 class="text-center"><%=req("Data") %></h5>





    <div class="panel-body bg-light">
       <div class="row col-xs-12" id="div-agendamento"></div>
       <div class="row col-sm-12" id="GradeAgenda"></div>
    </div>




<script type="text/javascript">
    $("#NomeProfissional").html( window.parent.$("#ProfissionalID option:selected").html() );
    function loadAgenda(Data, ProfissionalID){
        $("#GradeAgenda").html('<center>Carregando...</center>');
        $.ajax({
            type:"POST",
            url:"GradeAgenda-1print.asp?Data=<%=req("Data")%>&ProfissionalID=<%=req("ProfissionalID")%>",
            success:function(data){
                $("#GradeAgenda").html(data);
                print();
            }
        });
    }
    <%
    if req("Conf")="" and req("AgendamentoID")="" then
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
        $("#ProfissionalID").val(<%=age("ProfissionalID")%>);
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
        //$("#modal-agenda").modal("show");
        //	$("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' data-dismiss='modal' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgendaPrint.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");
        af('a');
        $("#div-agendamento").html("<div class='row'><div class='col-xs-12 text-right'><button class='btn btn-xs btn-default' onclick='af(\"f\")' type='button'><i class='far fa-remove'></i> Fechar</button></div></div><div class='row'><div class='col-xs-12 text-right'><iframe src='GradeAgenda1Print.asp?Data="+$("#Data").val()+"&ProfissionalID="+$("#ProfissionalID").val()+"' width='100%' height='800' scrolling='auto' frameborder='0'></iframe></div></div>");

    }
</script>
