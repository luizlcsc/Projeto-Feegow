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
    novo = ""
else
    ProfissionalID = "5_"&session("idInTable")
    novo = "disabled"
end if
%>

<style>
    #qftipoprotocolo label,#qftipoprotocolo br{
        display:none
    }
    
</style>

<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#divprotocolos" id="btnprotocolos"><i class="far fa-flask"></i> Protocolos</a></li>
	</ul>
</div>
<form method="post" id="formProtocolos" name="formProtocolos" action="save.asp">
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
      <div id="divpedido" class="tab-pane in active">
        <input type="hidden" name="ID" id="ID" value="<%=ID%>" />
        <input type="hidden" name="tipoPrescricao" id="tipoPrescricao" value="<%=ID%>" />
        <div class="row">
            <div class="col-xs-8">
                <div class="row">
                    <div class="col-md-2">
                        <button type="button" class="btn btn-info btn-block" onClick="GerarNovo('Protocolos', '<%=PacienteID%>', '0', '', '');"><i class="far fa-plus"></i> Novo</button>
                    </div>
                    <div class="col-md-2">
                        <!--<button type="button" onClick="saveProtocolo('<%=ID%>')" class="btn btn-primary "><i class="far fa-save"></i></button> -->
                        <button type="button" class="btn btn-info" onClick="prontPrint('Protocolos', <%=ID%>)">
                            <i class="far fa-print"></i>
                        </button>
                    </div>
                    <div class='col-md-3'>
                        <input name="type" id="prescricao" type="radio" value="P" checked="checked" /> &nbsp; Prescrição
                        </br>
                        <input name="type" id="transcricao" type="radio" value="T" /> &nbsp; Transcrição
                    </div>
                    <div class="col-md-4 ">
                        <%= simpleSelectCurrentAccounts("ProfissionalID", "5, 8", ProfissionalID, " "&novo,"Selecione um profissional") %>
                    </div>
                    <div class="btn-group text-left hidden">
			            <button data-toggle="dropdown" class="btn btn-default dropdown-toggle">
				            Grupos
				            <span class="far fa-caret-down icon-on-right"></span>
			            </button>

			            <ul class="dropdown-menu dropdown-default">
                            <%
                            set g = db.execute("SELECT * FROM protocolosgrupos order by 2 ")
                            while not g.eof
                            %>
				            <li>
					            <a href="javascript:grupo('<%=g("id") %>')"><small> <%=g("NomeGrupo") %></small></a>
				            </li>
                            <%
                            g.movenext
                            wend
                            g.close
                            set g=nothing
                            %>
			            </ul>
		            </div>
                    <div class="col-md-4 hidden">
                        <button type="button" class="btn btn-info btn btn-xs"><i class="far fa-credit-card"></i></button> <span>Gerar Guia de Tratamento</span>
                        <br>
                        <button type="button" class="btn btn-success btn btn-xs mt5"><i class="far fa-files-o"></i></button> <span>Gerar Proposta</span>
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
                        <i class="far fa-file-text"></i>
                        Protocolos Sugeridos
                    </span>
                </div>

                <div class="panel-menu">
                    <div class="input-group">
                    <input id="FiltroP" class="form-control input-sm refina" autocomplete="off" placeholder="Buscar..." type="text">
                    <span class="input-group-btn">
                    <button class="btn btn-sm btn-default" onclick="ListaProtocolos($('#FiltroP').val(), '')" type="button">
                    <i class="far fa-filter icon-filter bigger-110"></i>
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


    function ListaProtocolos(Filtro, Grupo){
        $.post("ListaProtocolos.asp", {
            PacienteID: '<%=req("p")%>',
            Filtro:Filtro,
            Grupo: Grupo
        }, function(data) {
            $("#ListaProtocolos").html(data);
            Core.init();
        });
    }

    function grupo(idGrupo) {
        ListaProtocolos($('#FiltroP').val(), idGrupo);
        $('#iProntCont').click();
    }

    $('#FiltroP').keypress(function(e){
        if ( e.which == 13 ){
    		ListaProtocolos($('#FiltroP').val(), '');
    		return false;
    	}
    });

    ListaProtocolos('', '');

    function GerarNovo(t, p, m, i, a) {
        $("#modal-form .panel").html("<center><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
        $.get("iPront.asp?t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
            $("#modal-form .panel").html(data);
        })
    }
    function saveProtocolo(ID){
        $.post("savePacientesProtocolos.asp?I="+ID, $("#formProtocolos").serialize(), function(data){
            eval(data);
        });
    };
    $("#transcricao").change(ev=>{
        $("#ProfissionalID").attr("disabled",false)
        $("#select2-ProfissionalID-container").html('Selecione um profissional  ')
        $("#ProfissionalID").val('')
    })
    $("#prescricao").change(ev=>{
        $("#ProfissionalID").attr("disabled",true)
        let name = $("#ProfissionalID option[value='<%=ProfissionalID%>']").html()
        $("#select2-ProfissionalID-container").html(name)
        $("#ProfissionalID").val('<%=ProfissionalID%>')
    })
</script>