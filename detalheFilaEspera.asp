<!--#include file="connect.asp"-->
<%
ProfissionalID = req("ProfissionalID")
PacienteID = req("PacienteID")
Data = req("Data")
oti = "agenda"
ConvenioID = ""
set pac = db.execute("select * from pacientes where id like '"&PacienteID&"' and sysActive=1")
if not pac.EOF then
	Tel1 = pac("Tel1")
	Cel1 = pac("Cel1")
	Email1 = pac("Email1")
    ConvenioID = pac("ConvenioID1")
    if isnull(ConvenioID) or ConvenioID=0 then
        ConvenioID = pac("ConvenioID2")
    end if
    if isnull(ConvenioID) or ConvenioID=0 then
        ConvenioID = pac("ConvenioID3")
    end if
    if isnull(ConvenioID) or ConvenioID=0 then
        ConvenioID = ""
    end if
end if

set pfila = db.execute("select * from filaespera where PacienteID like '"&PacienteID&"' and ProfissionalID="&ProfissionalID)
if not pfila.eof then
	rdValorPlano = pFila("rdValorPlano")
	Valor = pFila("ValorPlano")
	Tempo = pFila("Tempo")
	ProcedimentoID = pFila("TipoCompromissoID")
	Notas = pFila("Notas")
	DataEspera = pFila("sysDate")
end if
%>
<div class="panel">
    <div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left" id="myTab4">
            <li class="active"><a data-toggle="tab" href="#tabFila"><i class="far fa-calendar"></i> <span class="hidden-xs">Fila de espera</span></a></li>
            <li id="abaFicha" class="abasAux"><a data-toggle="tab" onclick="ajxContent('Pacientes&Agenda=1', $('#PacienteID').val(), '1', 'divDadosPaciente'); $('#alertaAguardando').removeClass('hidden');" href="#divDadosPaciente"><i class="far fa-user"></i> <span class="hidden-xs">Ficha</span></a></li>
            <li class="abasAux"><a data-toggle="tab" onclick="ajxContent('HistoricoPaciente&PacienteID='+$('#PacienteID').val(), '', '1', 'divHistorico'); crumbAgenda();" href="#divHistorico"><i class="far fa-list"></i> <span class="hidden-xs">Hist&oacute;rico</span></a></li>

    	        <li class="abasAux"><a data-toggle="tab" onclick="$('#divHistorico').html('Carregando...'); ajxContent('Conta', $('#PacienteID').val(), '1', 'divHistorico'); crumbAgenda();$('#alertaAguardando').removeClass('hidden');" href="#divHistorico"><i class="far fa-money"></i> <span class="hidden-xs">Conta</span></a></li>

    	</ul>



    <span class="panel-controls" onclick="javascript:af('f'); crumbAgenda();">
        <i class="far fa-arrow-left"></i> <span class="hidden-xs">Voltar</span>
    </span>
    </div>
    <div class="panel-body">
        <div class="tabbable">

            <div class="tab-content">
                <div id="tabFila" class="tab-pane in active">
                    <form method="post" action="" id="formFila" name="formFila">

                        <div class="modal-body">
                            <div class="bootbox-body">
                                <div class="row">
                                    <%if DataEspera<>"" then%>
                                    <h5 class="red">Adicionado em <%=formatdatetime(DataEspera,1)%> &agrave;s <%=formatdatetime(DataEspera,4)%></h5>
                                    <hr />
                                    <%end if%>
                                    <input type="hidden" name="ProfissionalID" id="ProfissionalID" value="<%=ProfissionalID%>" />
                                    <div class="col-md-6">
                                        <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", " onchange=""parametros(this.id, this.value);""", "required", "") %>
                                    </div>
                                    <%= quickField("phone", "ageTel1", "Telefone", 2, Tel1, "", "", "") %>
                                    <%= quickField("mobile", "ageCel1", "Celular", 2, Cel1, "", "", "") %>
                                    <%= quickField("text", "ageEmail1", "E-mail", 2, Email1, "", "", "") %>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <%= selectInsert("Procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " onchange=""parametros(this.id, this.value);""", oti, "") %>
                                    </div><br>
                                    <div class="col-md-12"><br>
                                        <div>
                                            <div class="row">
                                                <div class="col-md-3">
                                                    <label>
                                                        <input type="radio" name="rdValorPlano" id="rdValorPlanoV" required value="V" <% If rdValorPlano="V" Then %> checked="checked" <% End If %> class="ace valplan" style="z-index: -1" /><span class="lbl"> Particular</span></label>
                                                    <br />
                                                    <label>
                                                        <input type="radio" name="rdValorPlano" id="rdValorPlanoP" required value="P" <% If rdValorPlano="P" Then %> checked="checked" <% End If %> class="ace valplan" style="z-index: -1" /><span class="lbl"> Conv&ecirc;nio</span></label>
                                                </div>
                                                <div class="col-md-4" id="divValor" <% If rdValorPlano<>"V" Then %> style="display: none" <% End If %>>
                                                    <label for="Valor">Valor</label>
                                                    <%=quickField("currency", "Valor", "", 5, Valor, "", "", "")%>
                                                </div>
                                                <div class="col-md-4" id="divConvenio" <% If rdValorPlano<>"P" Then %> style="display: none" <% End If %>>
                                                    <%=selectInsert("Conv&ecirc;nio", "ConvenioID", ConvenioID, "convenios", "NomeConvenio", "", "", "")%>
                                                </div>
                                                <div class="col-md-2 hidden">
                                                    <label>&nbsp;</label><br />
                                                    <div class="btn-toolbar">
                                                        <div class="btn-group">
                                                            <button class="btn btn-warning dropdown-toggle" data-toggle="dropdown">
                                                                <i class="far fa-dollar"></i>
                                                                <span class="far fa-caret-down icon-on-right"></span>
                                                            </button>
                                                            <ul class="dropdown-menu dropdown-warning">
                                                                <li>
                                                                    <a href="#">Action</a>
                                                                </li>
                                                                <li>
                                                                    <a href="#">Another action</a>
                                                                </li>
                                                                <li>
                                                                    <a href="#">Something else here</a>
                                                                </li>
                                                                <li class="divider"></li>
                                                                <li>
                                                                    <a href="#">Separated link</a>
                                                                </li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                                <%=quickField("text", "Tempo", "Tempo (min)", 3, Tempo, "", "", " placeholder='Em minutos'")%>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <%= quickField("memo", "Notas", "Notas", 12, Notas, "", "", "") %>
                                </div>


                            </div>
                        </div>
                        <div class="modal-footer">
                            <button class="btn btn-sm btn-primary" id="btnSalvarFila">
                                <i class="far fa-save"></i>Salvar
                            </button>
                        </div>
                    </form>
                </div>
                <div id="divDadosPaciente" class="tab-pane">
                    Carregando...
                </div>
                <div id="divHistorico" class="tab-pane">
                    Carregando...
                </div>
            </div>
        </div>
    </div>
</div>


        <script language="javascript">
function abasAux(){
//	alert($("#PacienteID").val());
	if($("#PacienteID").val()=="" || $("#PacienteID").val()=="0"){
		$(".abasAux").css("display", "none");
	}else{
		$(".abasAux").css("display", "block");
	}
}
abasAux();
function parametros(tipo, id){
	$.ajax({
		type:"POST",
		url:"AgendaParametros.asp?tipo="+tipo+"&id="+id,
		data:$("#formFila").serialize(),
		success:function(data){
			eval(data);
			abasAux();
		}
	});
}
$(".valplan").click(function(){
	var tipo =$(this).val();
	if(tipo=="V"){
		$("#divConvenio").hide();
		$("#divValor").show();
	}else{
		$("#divConvenio").show();
		$("#divValor").hide();
	}
});
$("#formFila").submit(function() {
	$("#btnSalvarFila").html('salvando');
	$("#btnSalvarFila").attr('disabled', 'disabled');
	$.post("saveFila.asp", $("#formFila").serialize())
	.done(function(data) {
	  $("#btnSalvarFila").html('<i class="far fa-save"></i> Salvar');
	  $("#btnSalvarFila").removeAttr('disabled');
	  eval(data);
	});
	return false;
});
function excluiAgendamento(ConsultaID, Confirma){
	$.ajax({
		type:"POST",
		url:"excluiAgendamento.asp?ConsultaID="+ConsultaID+"&Confirma="+Confirma+"&token=98b4d9bbfdfe2170003fcb23b8c13e6b",
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
function repeteAgendamento(ConsultaID){
	$.ajax({
		type:"POST",
		url:"repeteAgendamento.asp?ConsultaID="+ConsultaID,
		data:$("#formExcluiAgendamento").serialize(),
		success:function(data){
			$("#div-agendamento").html(data);
		}
	});
}
setInterval(function(){abasAux()}, 3000);
<!--#include file="jQueryFunctions.asp"-->
</script>
