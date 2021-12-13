<!--#include file="connect.asp"-->

<%
I = req("i")
PacienteID = req("p")
if I="" then
    set convPac = db.execute("select ConvenioID1 from pacientes where id="& PacienteID)
    if not convPac.eof then
        ConvenioID = convPac("ConvenioID1")
    end if
    set pult = db.execute("select id from pedidossadt order by id desc limit 1")
    if pult.eof then
        I = 1
    else
        I = pult("id")+1
    end if
end if

Executante = ""

set cPedido = db.execute("select * from pedidossadt where id="& I)
if not cPedido.EOF then
    ConvenioID = cPedido("ConvenioID")
    IndicacaoClinica = cPedido("IndicacaoClinica")
    Observacoes = cPedido("Observacoes")
    Executante = cPedido("ProfissionalExecutante")
    Solicitante = cPedido("ProfissionalID")
    GuiaID = cPedido("GuiaID")
    DataSolicitacao = cPedido("Data")
end if
if GuiaID&""="" then
    GuiaID=0
end if

%>
<script>

function abreModal(){ $('#modalOpcoesImpressao').modal('toggle'); }

</script> 

<!-- Modal -->
<div class="modal fade" id="modalOpcoesImpressao" tabindex="-1" role="dialog" aria-labelledby="modalOpcoesImpressaoLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalOpcoesImpressaoLabel">Impressão de Pedido Simplificado</h5>
        <!--<button type="button" class="close" data-dismiss="modal" aria-label="Fechar">-->
          <!--<span aria-hidden="true">&times;</span>-->
        <!--</button>-->
      </div>
      <div class="modal-body">
        <form>
            <div class="form-group">
                <input type="checkbox" id="cabecalho" value="1" checked> <label for="cabecalho">Imprimir cabecalho e Rodapé </label><BR>
            </div>
            <div class="form-group">
                Quantidade de Registros: <input type="text" id="quantidade" size="5" value="10" class="form-control">
            </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
        <button type="button" class="btn btn-primary" id="savePedidoExameProtocolo">Imprimir</button>        
      </div>
    </div>
  </div>
</div>
<!----------------------------------------------------------------->

<div class="panel-heading">
    <ul class="nav panel-tabs-border panel-tabs panel-tabs-left">
        <li class="active"><a data-toggle="tab" href="#divpedido" id="btnpedido"><i class="far fa-file-text"></i> Guia de Solicitação</a></li>
        <li><a data-toggle="tab" class="hidden" id="btnpedidosmodelos" href="#pedidosmodelos"><i class="far fa-list"></i> <span class="hidden-480">Modelos</span></a></li>
	</ul>
</div>
<div class="panel-body p25" id="iProntCont">
    <div class="tab-content">
      <div id="divpedido" class="tab-pane in active">
        <div class="row">
            <div class="col-xs-8">
                <div class="row">
                    <div>
                        <%
                        disabledProf = " required"
                        if Solicitante&""<>"" then
                            disabledProf = " disabled"
                        end if
                        if lcase(session("Table"))="profissionais" then
                            Solicitante = session("IdInTable")
                            disabledProf = " disabled"
                        end if
                        %>
                        <%=quickField("simpleSelect", "ProfissionalID", " ", 3, Solicitante, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", "  empty='' "&disabledProf) %>
                    </div>

                    <div class="col-md-2 ">
                          <div class="btn-group text-left">
                              <button data-toggle="dropdown" class="btn btn-default dropdown-toggle">
                                  Grupos
                                  <span class="caret ml5"></span>
                              </button>

                              <ul class="dropdown-menu btn-block dropdown-default">
                                    <%
                                    set g = db.execute("select distinct trim(NomeGrupo) NomeGrupo from procedimentosgrupos where not NomeGrupo like '' order by trim(NomeGrupo)")
                                    while not g.eof
                                    %>
                                  <li>
                                      <a href="javascript:grupo('<%=g("NomeGrupo") %>')"><small> <%=g("NomeGrupo") %></small></a>
                                  </li>
                                    <%
                                    g.movenext
                                    wend
                                    g.close
                                    set g=nothing
                                    %>
                              </ul>
                          </div>

                    </div>

                    <div class="col-md-2">
                    </div>

                    <div class="col-md-2">
                        <form method="post">
                            <div class="btn-group ">

                                <button type="button" class="btn btn-default btn-block dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                                    <i class="far fa-print"></i> Imprimir
                                    <span class="caret ml5"></span>
                                </button>
                                <ul class="dropdown-menu" role="menu">
                                    <%
                                    if GuiaID<>0 then
                                    %>
                                    <li><a id="PedidoSADTPrint"> Guia SP/SADT</a></li>
                                    <%
                                    else
                                    %>
                                    <li><a id="savePedidoSADT"> Pedido SP/SADT</a></li>
                                    <%
                                    end if
                                    %>
                                    <li><a  id="savePedidoExameProtocoloS"> Pedido Simplificado </a></li>
                                    <li><a  onclick="abreModal();"> Pedido Personalizado</a></li>

                                </ul>
                            </div>

                        </form>
                    </div>

                    <div class="col-md-1">
                        <button type="button" class="btn btn-success btn-block" onClick="GerarNovo('PedidosSADT', '<%=PacienteID%>', '0', '', '');"><i class="far fa-plus"></i></button>
                    </div>
                    <div class="col-md-2">
                        <button type="button" onclick="saveConteudoPedidoSADT('E')" class="btn btn-primary btn-block"><i class="far fa-save"></i> Salvar</button>
                    </div>

                </div>
                <%
                set PedidosNoMesmoDiaSQL = db.execute("SELECT id, GuiaID FROM pedidossadt ps "&_
                        "WHERE ps.PacienteID="&PacienteID&" AND ps.sysUser="&session("User")&" AND ps.sysActive=1 AND date(ps.sysDate)=curdate() order by id desc LIMIT 6")

                set GruposExamesSQL = db.execute("SELECT tc.Capitulo, count(pp.id) qtd FROM pedidossadtprocedimentos pp "&_
                "JOIN cliniccentral.tusscorrelacao tc ON tc.Codigo=pp.CodigoProcedimento and tc.Tabela=pp.TabelaID "&_
                " WHERE pp.PedidoID="&treatvalzero(I)&" GROUP BY tc.Capitulo")

                qtdGrupos = 0

                while not GruposExamesSQL.eof
                    qtdGrupos = qtdGrupos + 1
                GruposExamesSQL.movenext
                wend
                GruposExamesSQL.close
                set GruposExamesSQL=nothing

                if qtdGrupos > 1 then
                    HasGrupoDiferente = True
                end if

                if not PedidosNoMesmoDiaSQL.eof then
                    %>
                    <h4 class="mt15">Pedidos de exame recentes</h4>

                    <div class="btn-group  mb15">
                    <%
                    while not PedidosNoMesmoDiaSQL.eof
                    %>
                        <button type="button" onclick="iPront('PedidosSADT', '<%=PacienteID%>', '', '<%=PedidosNoMesmoDiaSQL("id")%>', '');" class="btn btn-sm btn-<% if ccur(I)=PedidosNoMesmoDiaSQL("id") then response.write("primary") else response.write("default") end if %>">
                            <%
                            if isnull(PedidosNoMesmoDiaSQL("GuiaID")) then
                                %>
                                <i class="far fa-exclamation-circle text-warning" title="Guia não gerada"></i>
                                <%
                            else
                                %>
                                <i class="far fa-check-circle text-success" title="Guia gerada"></i>
                                <%
                            end if
                            %>
                            Pedido <span>#<%=PedidosNoMesmoDiaSQL("id")%></span>
                        </button>
                    <%
                    PedidosNoMesmoDiaSQL.movenext
                    wend
                    PedidosNoMesmoDiaSQL.close
                    set PedidosNoMesmoDiaSQL=nothing
                    %>
                    <div class="btn-group">
                        <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown">
                            <span class="caret"></span>
                        </button>
                        <ul class="dropdown-menu" role="menu">
                            <%
                            set g = db.execute("SELECT id, GuiaID FROM pedidossadt ps "&_
                        "WHERE ps.PacienteID="&PacienteID&" AND ps.sysUser="&session("User")&" AND ps.sysActive=1 AND date(ps.sysDate)=curdate() order by id desc LIMIT 6,10")

                            while not g.eof
                            %>
                                    <li><a href="#" onclick="iPront('PedidosSADT', '<%=PacienteID%>', '', '<%=g("id")%>', '');"><i class="far fa-exclamation-circle text-warning"></i> <%="Pedido #"&g("id")%></a></li>
                            <%
                                g.movenext
                                wend
                                g.close
                                set g=nothing
                            %>
                        </ul>
                    </div>
                    </div>
                    <%
                end if
                %>
                <br />
                <div class="row">
                    <div class="col-md-12">
                        <h4 >Exames</h4>
                    </div>
                    <div class="col-md-12" id="PedidoSADT">
                        <!--#include file="PedidoSADT.asp"-->
                    </div>
                    <div class="col-md-12">
                        <div class="row">
                            <%=quickfield("simpleSelect", "ConvenioIDPedidoSADT", "Convênio", 4, ConvenioID, "select id, NomeConvenio from convenios where sysActive=1 order by NomeConvenio", "NomeConvenio", "") %>
                            <%=quickField("text", "IndicacaoClinicaPedidoSADT", "Indicação Clínica", 7, IndicacaoClinica, "", "", "")%>
                            <input type="hidden" name="GuiaID" id="GuiaID" value="<%=GuiaID%>" />
                        </div>
                    </div>
                    <br>
                    <div class="col-md-12">
                        <div class="row">
                            <div class="col-md-4">
                                <label>Executante</label><br>
                                <%=simpleSelectCurrentAccounts("ProfissionalExecutanteIDPedidoSADT", "5, 8", Executante, "","")%>
                            </div>
                            <%=quickfield("datepicker", "DataSolicitacao", "Data Solicitação", 3, DataSolicitacao, "", "", "")%>
                            <%=quickField("memo", "ObservacoesPedidoSADT", "Observações", 4, Observacoes, "", "", "")%>
                        </div>
                    </div>
                </div>
                <br />

                <div class="clearfix form-actions">


                    <%
                    if lcase(session("Table"))="profissionais" then %>
                      <button type="button" onclick="GerarGuiaSADT()" id="GerarGuiaSADT" class="btn btn-primary btn-md"><i class="far fa-external-link"></i> Gerar Guia</button>
                      <a class="btn btn-success btn-md" target="_blank" href="?P=tissguiasadt&I=<%=GuiaID%>&Pers=1" id="AbrirGuiaSADT" ><i class="far fa-expand"></i> Guia <%=GuiaID%></a>
                    <%end if %>

                    <button style="display: <% if HasGrupoDiferente then response.write("inline") else response.write("none") end if %>" type="button" onclick="SepararPedidoPorGrupo()" id="SepararPedidoPorGrupo" class="btn btn-warning btn-md"><i class="far fa-copy"></i> Separar pedido por grupo</button>
                </div>
            </div>
            <div class="col-xs-4 pn">
                <div class="panel">
                    <div class="panel-heading">
                        <span class="panel-title">
                            <i class="far fa-file-text"></i>
                            Busca de procedimentos - TUSS
                        </span>
                        <div class="panel-controls">
                                 <a href="#" onclick="modalPastas('', 'Lista')" class="btn btn-xs btn-dark" data-placement="top" title="">
                                    <i class="far fa-folder text-white"></i>
                                </a>
                        </div>
                    </div>
                    <style>
                        #FiltroP.form-control[readonly] {
                            cursor: text;
                            background: white;
                        }
                    </style>
                    <div class="panel-menu">
                        <div class="input-group">
                            <div id="FiltroP" contenteditable="true" class="form-control input-sm refina" readonly onfocus="this.removeAttribute('readonly');" placeholder="Digite o código ou descrição..." type="text"></div>
                            <span class="input-group-btn">
                                <button class="btn btn-sm btn-default" onclick="ListaTextosPedidosSADT($('#FiltroP').html(), '', '')" type="button">
                                    <i class="far fa-filter icon-filter bigger-110"></i>
                                    Buscar
                                </button>
                            </span>
                        </div>
                    </div>
                    <div class="panel-body panel-scroller scroller-md scroller-pn pn">
                        <table class="table mbn tc-icon-1 tc-med-2 tc-bold-last">
                            <tbody id="ListaTextosPedidosSADT">
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
    <div class="tab-pane" id="pedidosmodelos">
        Carregando...
    </div>


<div class="text-left mt20">
    <a href="#" class="btn btn-default btn-sm" id="showTimeline">Mostrar/Ocultar Histórico <span class="caret ml5"></span> </a>
    </div>
    <div id="conteudo-timeline"></div>

  </div>
</div>

  </div>
</div>
<script type="text/javascript">
<%
    recursoPermissaoUnimed = recursoAdicional(12)
    if session("User")="14128" or session("Banco")="clinic5351" or session("Banco")="clinic100000" or recursoPermissaoUnimed=4 then
    %>
    if('<%=req("IFR")%>'!=="S" && false){
        $.get("timeline.asp", {PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
            $("#conteudo-timeline").html(data)
        });
    }
    <%
    end if
    %>
    $(function(){
        $("#conteudo-timeline").hide();
        $("#showTimeline").on('click', function(){
            $.get("timeline.asp", {PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
                $("#conteudo-timeline").html(data)
                $("#conteudo-timeline").toggle(1000);
            });
        })
    });

$(document).ready(function(){
    <%if GuiaID=0 then%>
        $("#AbrirGuiaSADT").addClass("hidden");
    <%else%>
        $("#GerarGuiaSADT").addClass("hidden");
    <%end if%>
});
function grupo(G){
    $("#FiltroP").val("Grupo: "+G);
    $("#btnP").click();
}


function aplicarTextoPedido(id){
	$.post("PacientesAplicarFormula.asp?Tipo=E&PacienteID=<%=PacienteID%>", {id:id}, function(data, status){ 
	    $("#pedido").val($("#pedido").val()+data);
    } );
}

function modalTextoPedido(tipo, id){
    $("#btnpedidosmodelos").click();
    $.post("modalTextoPedido.asp?id="+id,{
		   PacienteID:'<%=id%>'
		   },function(data,status){
		       $("#pedidosmodelos").html(data);
		});
}

function modalPastas(tipo, id){
    $.post("pacotesProntuarios.asp?id="+id,{
		   PacienteID:'<%=id%>'
		   },function(data,status){
		       $("#iProntCont").html(data);
		});
}

$("#savePedidoSADT").on('click', function () {
    if($(this).attr("id") == "PedidoSADTPrint"){
        printSADT()
    }else{
        window.open('GuiaSPSADTPrint.asp?I=0&TipoExibicao=Pedido&PedidoSADTID='+ $("#PedidoSADTID").val() +'&close=1&ConvenioIDPedidoSADT='+ $("#ConvenioIDPedidoSADT").val() +'&IndicacaoClinicaPedidoSADT='+ $("#IndicacaoClinicaPedidoSADT").val() +'&ObservacoesPedidoSADT='+ $("#ObservacoesPedidoSADT").val()+'&ProfissionalExecutanteIDPedidoSADT='+ $("#ProfissionalExecutanteIDPedidoSADT").val()+'&ProfissionalID='+ $("#ProfissionalID").val()+'&DataSolicitacao='+ $("#DataSolicitacao").val(), "myWindow", "width=1000, height=800, top=50, left=50");
    }
});

$("#PedidoSADTPrint").on('click', printSADT);



function printSADT() {
    window.open('modalGuiaTISS.asp?T=GuiaSADT&Tipo=PedidoExame&I='+ $("#GuiaID").val()+'&ConvenioID='+ $("#ConvenioIDPedidoSADT").val(), "myWindow", "width=1000, height=800, top=50, left=50");
}
$("#savePedidoExameProtocolo").click(function () {
    if ( $("#cabecalho").is(":checked")) {var cabecalho=1; }else{ var cabecalho=0; }
    window.open('guiaPedidoExamePrint.asp?I=0&cabecalho='+cabecalho +'&maxRegistros='+ $("#quantidade").val() +'&TipoExibicao=Pedido&PedidoSADTID='+ $("#PedidoSADTID").val() +'&ConvenioIDPedidoSADT='+ $("#ConvenioIDPedidoSADT").val() +'&IndicacaoClinicaPedidoSADT='+ $("#IndicacaoClinicaPedidoSADT").val() +'&ObservacoesPedidoSADT='+ $("#ObservacoesPedidoSADT").val()+'&ProfissionalExecutanteIDPedidoSADT='+ $("#ProfissionalExecutanteIDPedidoSADT").val()+'&ProfissionalID='+ $("#ProfissionalID").val()+'&DataSolicitacao='+ $("#DataSolicitacao").val(), "myWindow", "width=1000, height=800, top=50, left=50");
});
$("#savePedidoExameProtocoloS").click(function () {
    window.open('guiaPedidoExamePrint.asp?I=0&cabecalho=0&maxRegistros=20&TipoExibicao=Pedido&PedidoSADTID='+ $("#PedidoSADTID").val() +'&ConvenioIDPedidoSADT='+ $("#ConvenioIDPedidoSADT").val() +'&IndicacaoClinicaPedidoSADT='+ $("#IndicacaoClinicaPedidoSADT").val() +'&ObservacoesPedidoSADT='+ $("#ObservacoesPedidoSADT").val()+'&ProfissionalExecutanteIDPedidoSADT='+ $("#ProfissionalExecutanteIDPedidoSADT").val()+'&ProfissionalID='+ $("#ProfissionalID").val()+'&DataSolicitacao='+ $("#DataSolicitacao").val(), "myWindow", "width=1000, height=800, top=50, left=50");
});

function SepararPedidoPorGrupo(){
    $.post("SepararPedidoPorGrupo.asp", {PedidoID: "<%=I%>"}, function(data){
        iPront('PedidosSADT', '<%=PacienteID%>', '', '<%=I%>', '');
        showMessageDialog("Pedido de exame separar com sucesso", "success");
    })
}

function GerarGuiaSADT(){
    var ConvenioIDPedidoSADT = $("#ConvenioIDPedidoSADT").val();
    if(ConvenioIDPedidoSADT > 0){
        $.post('LanctoPedidoSADT.asp',
        {
            I: 0,
            PacienteID: '<%=req("p")%>',
            PedidoSADTID: $("#PedidoSADTID").val(),
            ConvenioIDPedidoSADT: $("#ConvenioIDPedidoSADT").val(),
            IndicacaoClinicaPedidoSADT: $("#IndicacaoClinicaPedidoSADT").val(),
            ObservacoesPedidoSADT: $("#ObservacoesPedidoSADT").val(),
            ProfissionalExecutanteIDPedidoSADT: $("#ProfissionalExecutanteIDPedidoSADT").val(),
            DataSolicitacao: $("#DataSolicitacao").val()
        },
        function(result){
            if(result.success){

                var GuiaID = result.guia_id;
                var url = result.url_redirect;

                window.open(url);

                $("#GerarGuiaSADT").hide();
                $("#AbrirGuiaSADT").removeClass("hidden");
                $("#AbrirGuiaSADT").show();
                $("#AbrirGuiaSADT").attr('href', '?P=tissguiasadt&I=' + GuiaID + '&Pers=1');
                $("#AbrirGuiaSADT").html('<i class="far fa-expand"></i> Guia ' + GuiaID);

                $("#ConvenioIDPedidoSADT, #IndicacaoClinicaPedidoSADT, #ProfissionalExecutanteIDPedidoSADT, #ObservacoesPedidoSADT, #DataSolicitacao").attr("disabled", true);
                $("#savePedidoSADT").html(" Guia SP/SADT");
                $("#savePedidoSADT").attr('id',"PedidoSADTPrint");
                $("#GuiaID").attr('value', GuiaID);

                reloadTimeline();
            }else{
                showMessageDialog(result.message)
            }
        });
    }else{
        alert("Escolha um convênio");
    }
}

function ListaTextosPedidosSADT(Filtro, X, Aplicar){
	$.post("ListaTextosPedidosSADT.asp",{
		   Filtro:Filtro,
		   X: X,
		   Aplicar: Aplicar,
		   ConvenioID : $("#ConvenioIDPedidoSADT").val()
		   },function(data,status){
	  $("#ListaTextosPedidosSADT").html(data);
	  Core.init();
		   });
}

$('#FiltroP').keypress(function(e){
    if ( e.which == 13 ){
		ListaTextosPedidosSADT($('#FiltroP').html(), '', '');
		return false;
	}
});

ListaTextosPedidosSADT('', '', '');

function xPedidoSADT(X) {
    $.post("PedidoSADT.asp?i=" + $("#PedidoSADTID").val(), {X: X}, function (data) {
        $("#PedidoSADT").html(data);
    });
}

function saveConteudoPedidoSADT(E){
    $.post("savePedidoSADT.asp",{
        E:E,
        ConvenioIDPedidoSADT: $("#ConvenioIDPedidoSADT").val(),
        IndicacaoClinicaPedidoSADT: $("#IndicacaoClinicaPedidoSADT").val(),
        ObservacoesPedidoSADT: $("#ObservacoesPedidoSADT").val(),
        ProfissionalExecutanteIDPedidoSADT: $("#ProfissionalExecutanteIDPedidoSADT").val(),
        PedidoSADTID: $("#PedidoSADTID").val(),
        ProfissionalID: $("#ProfissionalID").val(),
        DataSolicitacao: $("#DataSolicitacao").val()

    }, function(data){
        iPront('PedidosSADT', '<%=PacienteID%>', '', $("#PedidoSADTID").val(), '');
    });
    return false;
}

function GerarNovo(t, p, m, i, a) {
    $("#modal-form .panel").html("<center><i class='far fa-2x fa-circle-o-notch fa-spin'></i></center>");
    $.get("iPront.asp?t=" + t + "&p=" + p + "&m=" + m + "&i=" + i  + "&a=" + a, function (data) {
        $("#modal-form .panel").html(data);
    })
}
<!--#include file="JQueryFunctions.asp"-->
</script>