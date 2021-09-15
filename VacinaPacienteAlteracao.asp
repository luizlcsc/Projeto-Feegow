<!--#include file="connect.asp"-->
<!--#include file="Classes/DateFormat.asp"-->
<%
dosagem = db.execute("SELECT DataPrevisao, StatusID, Observacao FROM vacina_aplicacao WHERE id = "&ref("valor2"))
%>

<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Alterar aplicação</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>
</div>
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
        <div class="tab-pane in active">
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-md-4">
                            <label for="InputDataAplicacao">Data de aplicação</label>
							<div class="input-group">
								<input id="InputDataAplicacao" autocomplete="off" class="form-control input-mask-date date-picker" type="text" data-date-format="dd/mm/yyyy" value="<%=dosagem("DataPrevisao")%>">
								<span class="input-group-addon">
								<i class="far fa-calendar bigger-110"></i>
								</span>
							</div>	
                        </div>
                        <div class="col-md-8">
                            <label for="SelectStatus">Status</label>
                            <select id="SelectStatus" name="SelectStatus" class="select-status">
                                <option value="0">Selecione
    <%
                                set status = db.execute(" SELECT id, NomeStatus FROM cliniccentral.vacina_aplicacao_status ORDER BY 2")
                                
                                while not status.EOF

                                    selected = ""
                                    if dosagem("StatusID") = status("id") then selected = "selected" end if

                                    response.Write("<option value='"&status("id")&"' "&selected&">"&status("NomeStatus"))
                                    status.movenext
                                wend

                                status.close
                                set status = nothing
    %>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-md-12">
                            <label for="InputObservacao">Observação</label>
                            <textarea class="form-control" id="InputObservacao"><%=dosagem("Observacao")%></textarea>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>     
<div class="modal-footer no-margin-top">
    <button class="btn btn-sm btn-primary pull-right" id="saveVacinaPaciente"><i class="far fa-save"></i> Salvar</button>
</div>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

$('.input-mask-date').mask('99/99/9999');

$('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
    $(this).prev().focus();
});

$('.select-status').select2();
$('.select-profissionais').select2();

$("#saveVacinaPaciente").click(function(){

    strDataInicio = $("#InputDataAplicacao").val();
    arrDataInicio = strDataInicio.split("/");
    novaDataInicio = arrDataInicio[2]+"-"+arrDataInicio[1]+"-"+arrDataInicio[0];

	$.post("saveVacinaPaciente.asp",{
           Tipo:"Alterar",
		   PacienteID:'<%=ref("valor1")%>',
           AplicacaoID: '<%=ref("valor2")%>',
           VacinaPacienteSerieID: '<%=ref("valor3")%>',
           Ordem: '<%=ref("valor4")%>',
		   StatusID: $("#SelectStatus").val(),
		   DataInicio: novaDataInicio,
           Observacao: $("#InputObservacao").val(),
		   },function(data,status){
	         eval(data);
             $("#modal-table").modal("hide");
	});
});
</script>
