<!--#include file="connect.asp"-->
<%

'if ref("i")<>"" then
'    set pp = db.execute("select * from pacientespedidos where id="& ref("i"))
'    if not pp.eof then
'        PedidoExame = pp("PedidoExame")
'        set ProcedimentosPedidoSQL = db.execute("SELECT pe.*,proc.NomeProcedimento FROM pedidoexameprocedimentos pe INNER JOIN procedimentos proc ON proc.id=pe.ProcedimentoID WHERE pe.PedidoExameID="&ref("i"))
'    end if
'end if
%>

<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Adicionar Série</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>
</div>

<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
        <div class="tab-pane in active">
<%
    set serie = db.execute(" SELECT vs.id, "&_ 
                           " vs.titulo as descricao "&_
                           " FROM vacina_serie vs "&_
                           " JOIN vacina v ON v.id = vs.VacinaID "&_
                           " JOIN cliniccentral.vacina_tipo vt ON vt.id = v.TipoVacinaID "&_
                           " WHERE v.TipoVacinaID = "&ref("valor2")&_
                           " AND vs.sysActive = 1 "&_
                           " AND v.sysActive = 1 "&_
                           " ORDER BY descricao ")

    if not serie.EOF then
%>
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-md-4">

                            <label for="SelectSerieID">Série</label>
                            <select id="SelectSerieID" name="SerieID" class="select-serie">
                                <option value="0">Selecione</option>
                                <%
                                while not serie.EOF
                                    response.Write("<option value='"&serie("id")&"'>"&serie("descricao")&"</option>")

                                    serie.movenext
                                wend

                                serie.close
                                set serie = nothing
%>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label for="InputDataInicio">Data de início</label>
                            <div class="input-group">
                                <input id="InputDataInicio" autocomplete="off" class="form-control input-mask-date date-picker" type="text" data-date-format="dd/mm/yyyy" value="<%=Right("00"&Day(date),2)&"/"&Right("00"&Month(date),2)&"/"&Year(date)%>">
                                <span class="input-group-addon">
                                <i class="far fa-calendar bigger-110"></i>
                                </span>
                            </div>
                        </div>
                        <!--div class="col-md-5">
                       <% 
                            'usuario = db.execute("SELECT idInTable FROM sys_users WHERE id = "&session("User"))
                       %>
                            <label for="SelectProfissionalID">Profissional</label>
                            <select id="SelectProfissionalID" name="ProfissionalID" class="select-profissionais">
                                <option value="0">Selecione</option>
<%
                           ' set profissionais = db.execute("select p.id, "&_
                           '                                " t.Tratamento, "&_
                           '                                " (IF (COALESCE(trim(NomeSocial), p.NomeProfissional)='',p.NomeProfissional,COALESCE(trim(NomeSocial), p.NomeProfissional))) as descricao "&_
                           '                                " from profissionais p "&_
                           '                                " left join tratamento t on t.id = p.TratamentoID "&_
                           '                                " WHERE p.sysActive = 1 "&_
                           '                                " AND ativo = 'on' "&_
                           '                                " order by 3")

                           ' while not profissionais.EOF
                           '     selected = ""
                           '     if profissionais("id") = usuario("idInTable") then selected = "selected" end if
                           '     response.Write("<option value='"&profissionais("id")&"' "&selected&">"&profissionais("Tratamento")&" "&profissionais("descricao")&"</option>")
                           '     profissionais.movenext
                           ' wend

                           ' profissionais.close
                           ' set profissionais = nothing
%>
                            </select>
                        </div -->
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12">
                    <div class="row">
                        <div class="col-md-12">
                            <label for="InputObservacao">Observação</label>
                            <textarea class="form-control" id="InputObservacao"></textarea>
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
<%
else
    set tipoVacina = db.execute("SELECT UPPER(NomeTipoVacina) AS descricao FROM cliniccentral.vacina_tipo WHERE id = "&ref("valor2"))

    if not tipoVacina.EOF then
        response.write("Nenhuma série encontrada para o tipo de vacina: "&tipoVacina("descricao"))
    else 
        response.write("Nenhuma série encontrada")
    end if

end if
%>
<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->

$('.input-mask-date').mask('99/99/9999');

$('.date-picker').datepicker({autoclose:true}).next().on(ace.click_event, function(){
    $(this).prev().focus();
});

$('.select-serie').select2();

$("#saveVacinaPaciente").click(function(){

    strDataInicio = $("#InputDataInicio").val();
    arrDataInicio = strDataInicio.split("/");
    novaDataInicio = arrDataInicio[2]+"-"+arrDataInicio[1]+"-"+arrDataInicio[0];

	$.post("saveVacinaPaciente.asp",{
           Tipo:"Inserir",
		   PacienteID:'<%=ref("valor1")%>',
		   SerieID: $("#SelectSerieID").val(),
		   DataInicio: novaDataInicio,
           Observacao: $("#InputObservacao").val(),
		   },function(data,status){
	         eval(data);
             $("#modal-table").modal("hide");
	});
});
</script>
