<!--#include file="connect.asp"-->

<%
ID = req("i")
PacienteID = req("p")

if ID="" then
    set pult = db.execute("select id from pacientesprotocolos order by id desc limit 1")
    if pult.eof then
        ID = 1
    else
        ID = pult("id")+1
    end if
end if
set getProtocolo = db.execute("SELECT * FROM pacientesprotocolos WHERE id="&ID)
if not getProtocolo.eof then
    ProfissionalID = getProtocolo("ProfissionalID")
else
    ProfissionalID = "5_"&session("idInTable")
end if
%>



<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#divprotocolos" id="btnprotocolos"><i class="fa fa-flask"></i> Protocolos</a></li>
	</ul>
</div>
<form method="post" id="formProtocolos" name="formProtocolos" action="save.asp">

<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
      <div id="divpedido" class="tab-pane in active">
      <input type="hidden" name="ID" id="ID" value="<%=ID%>" />
        <div class="row">
            <div class="col-xs-8">
                <div class="row">
                    <div class="col-md-2">
                        <button type="button" class="btn btn-info btn-block" onClick="GerarNovo('Protocolos', '<%=PacienteID%>', '0', '', '');"><i class="fa fa-plus"></i> Novo</button>
                    </div>
                    <div class="col-md-2">
                        <button type="button" onClick="saveProtocolo('<%=ID%>')" class="btn btn-primary btn-block"><i class="fa fa-save"></i> Salvar</button>
                    </div>
                    <div class="col-md-4">
                        <%= simpleSelectCurrentAccounts("ProfissionalID", "5, 8", ProfissionalID, " ") %>
                    </div>
                    <div class="col-md-4 hidden">
                        <button type="button" class="btn btn-info btn btn-xs"><i class="fa fa-credit-card"></i></button> <span>Gerar Guia de Tratamento</span>
                        <br>
                        <button type="button" class="btn btn-success btn btn-xs mt5"><i class="fa fa-files-o"></i></button> <span>Gerar Proposta</span>
                    </div>
                <br />
                <div class="row">
                    <div class="col-md-12" id="PacientesProtocolosConteudo">
                    <!--#include file="PacientesProtocolosConteudo.asp"-->
                    </div>
                </div>
            </div>
        </div>
        <div class="col-xs-4 pn">
            <div class="panel">
                <div class="panel-heading">
                    <span class="panel-title">
                        <i class="fa fa-file-text-o"></i>
                        Protocolos Sugeridos
                    </span>
                </div>

                <div class="panel-menu">
                    <div class="input-group">
                    <input id="FiltroP" class="form-control input-sm refina" autocomplete="off" placeholder="Buscar..." type="text">
                    <span class="input-group-btn">
                    <button class="btn btn-sm btn-default" onclick="ListaProtocolos($('#FiltroP').val(), '', '')" type="button">
                    <i class="fa fa-filter icon-filter bigger-110"></i>
                    Buscar
                    </button>
                    </span>
                    </div>
                </div>
                <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                    <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                        <tbody id="ListaProtocolos">
                            <tr>
                                <td>
                                    Carregando...
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            </div>

        </div>
      </div>
    </div>

    <div class="text-left mt20">
        <a href="#" class="btn btn-info btn-sm" id="showTimeline">Mostrar/Ocultar Histórico</a>
    </div>
    <div id="conteudo-timeline"></div>

  </div>
</div>

  </div>
</div>
</form>
<script type="text/javascript">

    if('<%=req("IFR")%>'!=="S"){
        $.get("timeline.asp", {PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
            $("#conteudo-timeline").html(data)
        });
    }
    $(function(){
        $("#conteudo-timeline").hide();
        $("#showTimeline").on('click', function(){
            $("#conteudo-timeline").toggle(1000);
        })
    });


    function ListaProtocolos(Filtro, X, Aplicar){
    	$.post("ListaProtocolos.asp",{
    		   Filtro:Filtro,
    		   X: X,
    		   Aplicar: Aplicar,
    		   },function(data,status){
    	  $("#ListaProtocolos").html(data);
    	  Core.init();
    		   });
    }

    $('#FiltroP').keypress(function(e){
        if ( e.which == 13 ){
    		ListaProtocolos($('#FiltroP').val(), '', '');
    		return false;
    	}
    });

    ListaProtocolos('', '', '');

    function GerarNovo(t, p, m, i, a) {
        $("#modal-form .panel").html("<center><i class='fa fa-2x fa-circle-o-notch fa-spin'></i></center>");
        $.get("iPront.asp?t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
            $("#modal-form .panel").html(data);
        })
    }
    function saveProtocolo(ID){
        $.post("savePacientesProtocolos.asp?I="+ID, $("#formProtocolos").serialize(), function(data){
            eval(data);
        });
    };
</script>