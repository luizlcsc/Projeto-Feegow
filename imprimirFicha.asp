<!--#include file="connect.asp"-->
<div class="modal-header">
    <button type="button" class="close" data-dismiss="modal">&times;</button>
    <h4 class="modal-title">Impressão da ficha do paciente</h4>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
            <span class="radio-custom radio-primary">
                <input type="radio" name="ImpressaoSolicitadaPor" id="SolicitadoPaciente" value="Paciente">
                <label for="SolicitadoPaciente"> Solicitado pelo paciente</label>
            </span><br>
            <span class="radio-custom radio-primary">
                <input type="radio" name="ImpressaoSolicitadaPor" id="SolicitadoProfissional" value="Profissional">
                <label for="SolicitadoProfissional"> Solicitado pelo profissional</label>
            </span><br>
        </div>
        <div class="col-md-4" id="ImpressaoFichaProfissional" style="display: none;">
           <%=quickField("simpleSelect", "gProfissionalID", "Profissional", 12, ProfissionalID, "select * from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
        </div>
        <div id="ImpressaoFichaConteudo" style="display: none;">
        <div class="col-md-9">

            <iframe  width="100%" height="600px" src="FichaImpressao.asp?PacienteID=<%=req("PacienteID")%>" id="ImpressaoFicha" name="ImpressaoFicha" frameborder="0"></iframe>
        </div>
        <div class="col-md-3">
            <div class="row">
                <div class="hidden">
                    <%= quickField("datepicker", "ImpressaoDataDe", "De", 12, Data, "ImpressaoDataFiltro", "", " required") %>
                    <%= quickField("datepicker", "ImpressaoDataAte", "Até", 12, Data, "ImpressaoDataFiltro" , "", " required") %>

                    <div class="col-md-12">
                        <label for="TamanhoPapel">Tamanho do papel</label>
                       <select name="TamanhoPapel" id="TamanhoPapel" class="form-control">
                           <option selected value="900">A4</option>
                           <option value="1054">Carta</option>
                           <option value="1334">A5</option>
                           <option value="944">B5</option>
                       </select>
                   </div>
               </div>
            </div><br>
            <script >$(".date-picker").datepicker()</script>
		    <%
		    if aut("pacientesV")=1 then
		    %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirHistoricoAcoes" value="Log">
                <label for="ImprimirHistoricoAcoes"> Histórico de ações</label>
            </div>
            <%
            end if

            if aut("formsae")=1 then
		    %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirAnamneseEvolucao" value="AE">
                <label for="ImprimirAnamneseEvolucao"> Anamnese e evolução</label>
            </div>
            <%
            end if

		    if aut("formsl")=1 then
		    %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirLaudosForms" value="L">
                <label for="ImprimirLaudosForms"> Laudos e Formulários</label>
            </div>
            <%
            end if

		    if aut("prescricoes")=1 then
		    %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirPrescricoes" value="Prescricao">
                <label for="ImprimirPrescricoes"> Prescrições</label>
            </div>
            <%
            end if

		    if aut("diagnosticos")=1 then
            %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirDiagnosticos" value="Diagnostico">
                <label for="ImprimirDiagnosticos"> Diagnósticos</label>
            </div>
            <%
            end if
		    if aut("atestados")=1 then
            %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirAtestados" value="Atestado">
                <label for="ImprimirAtestados"> Atestados</label>
            </div>
            <%
            end if

		    if aut("pedidosexame")=1 then
            %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="Pedido" value="Pedido">
                <label for="Pedido"> Pedidos de Exame</label>
            </div>
            <%
            end if


            if aut("imagens")=1 then
		    %>
            <div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirImagens" value="Imagens">
                <label for="ImprimirImagens"> Imagens</label>
            </div>
            <%
            end if


            'if aut("arquivos")=1 then
		    %>
            <!--<div class="checkbox-custom checkbox-default">
                <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirArquivos" value="Arquivos">
                <label for="ImprimirArquivos"> Arquivos</label>
            </div> -->
            <%
            'end if

            %>
        </div>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
    <button type="button" class="btn btn-default" data-dismiss="modal">Fechar</button>
</div>
<script type="text/javascript">
    var $PrintOpt = $(".PacienteImpressaoOpt");
    $PrintOpt.change(function() {
        iframeUrl();
    });
    var $SolicitadoPor = $("input[name='ImpressaoSolicitadaPor']");
    var $SelectProfissional = $("#ImpressaoFichaProfissional");

    var $HistoricoAcoes = $("#ImprimirHistoricoAcoes");

    var iframeUrl = function() {
        var SolicitadoPor = $SolicitadoPor.val();
        var HistoricoAcoes = $HistoricoAcoes.is(":checked");
        var ProfissionalID = $("#gProfissionalID").val();
        var DataDe = $("#ImpressaoDataDe").val();
        var DataAte = $("#ImpressaoDataAte").val();
        var TamanhoPapel = $("#TamanhoPapel").val();
        var $checked = $PrintOpt.filter(":checked");
        var checked = "";

        $.each($checked,function() {
            checked += "|"+$(this).val();
        });

        checked = checked+"|";
        var url = "FichaImpressao.asp?PacienteID=<%=req("PacienteID")%>&HistoricoAcoes="+(HistoricoAcoes?1:0)+"&Opts="+checked+"&SolicitadoPor="+SolicitadoPor+"&ProfissionalID="+ProfissionalID+"&DataDe="+DataDe+"&DataAte="+DataAte+"&TamanhoPapel="+TamanhoPapel;
//        console.log(url)
        $("#ImpressaoFicha").attr("src",url);
    };

    $SolicitadoPor.change(function() {
        $("#ImpressaoFichaConteudo").fadeIn();

        if($(this).val() === "Profissional"){
            $SelectProfissional.fadeIn();
        }else{
            $SelectProfissional.fadeOut();
        }

        iframeUrl();
    });

    $("#gProfissionalID, .ImpressaoDataFiltro, #TamanhoPapel,#ImprimirHistoricoAcoes").change(function() {
        iframeUrl();
    });

    $(".VisualizarImpressoesAnteriores").click(function() {
        $.get("ListaRecibosImpressao.asp",{PacienteID: "<%=req("PacienteID")%>"}, function(data) {
            $("#ImpressoesAnteriores").html(data)
        });
    });
</script>