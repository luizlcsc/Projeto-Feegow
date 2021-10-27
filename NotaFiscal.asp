<!--#include file="connect.asp"-->
<%
De = date()
Ate = De

if session("Banco")="clinic6102" then
    Response.End
end if
%>
<script type="text/javascript">
    $(".crumb-active a").html("Nota fiscal");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("administração de notas fiscais");
    $(".crumb-icon a span").attr("class", "far fa-file-text");
</script>
    <br>
    <div class="panel">
        <div class="panel-body">
            <form id="frmCC" method="get">
            <input type="hidden" name="P" value="<%=req("P")%>">
            <input type="hidden" name="Pers" value="<%=req("Pers")%>">

            <%= quickField("simpleSelect", "UnidadeID", "Unidade", 4, session("UnidadeID")&"", "select '0' id, concat('        ', NomeFantasia) NomeFantasia from empresa UNION ALL select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 order by NomeFantasia", "NomeFantasia", "")%>
            <%= quickField("datepicker", "De", "De", 2, De, "", "", "") %>
            <%= quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
            <%= quickField("text", "Numero", "Número", 2, "", "", "", "") %>
            <div class="col-md-2">
                <label>&nbsp;</label><br>
                <button id="btnBuscar" class="btn btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
            <div class="col-md-2">
                    <label for="NotaFiscalStatus">Status da NF-e</label>
                    <select name="NotaFiscalStatus" id="NotaFiscalStatus" class="form-control">
                        <option value="">Todas</option>
                        <option value="1">Emitida</option>
                        <option value="13">Aguardando envio</option>
                        <option value="3">Cancelada</option>
                        <option value="2">Rejeitada</option>
                        <option value="0">Recibo</option>
                    </select>
            </div>

            <div class="col-md-2">
                <button class="btn btn-success" type="button" id="btnExportar" onclick="exportarExcel()">
                    <i class="far fa-download"></i> Exportar
                </button>
            
            <%

            set NotaAguardandoEnvioSQL = db.execute("SELECT id FROM nfe_notasemitidas WHERE situacao=13")

            if not NotaAguardandoEnvioSQL.eof then
            %>
            

            <button class="btn btn-warning" type="button" id="ReceberRetornoBtn" onclick="NFeBaixarRetorno()">
                <i class="far fa-download"></i> Receber retorno
            </button>
            
            <%
            end if
            %>
            </div>

            <div class="col-md-2">
                <button class="btn btn-system" type="button" onclick="openNFe2()">
                    Acessar NFS-e V2
                </button>
            </div>
            <div class="col-md-2">
                <button class="btn btn-primary hidden" id="btn-gerar-recibos" type="button" onclick="GerarRecibos()">
                    Gerar Recibos
                </button>
            </div>

            <%=quickField("multiple", "Executantes", "Executantes", 4, req("Executantes"), "select concat('5_',id)id, NomeProfissional from profissionais where ativo='on' order by NomeProfissional", "NomeProfissional", "")%>
            <%=quickField("multiple", "GrupoProcedimentos", "Grupo de procedimentos", 4, req("GrupoProcedimentos"), "select id, NomeGrupo from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "")%>
            <button type="button" id="ConsultarEmLote2" class="btn btn-primary dropdown-toggle" >Consultar Em Lote</button>
            <div class="col-md-2">
            <br>
                 <div class="btn-group" id="acoes-notas-fiscais" style="display:none;">
                      <div class="btn-group">
                        <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        Ações <span class="caret"></span></button>
                        <ul class="dropdown-menu" role="menu">
                          <li><a href="#" id="EmitirEmLote">Emitir em lote</a></li>
                          <!--<li><a href="#" id="ConsultarEmLote">Consultar em lote</a></li>-->
                        </ul>
                      </div>
                    </div>
            </div>
            <div class="col-md-2">
                <br>

                <input type="checkbox" class="selecionar-todas" id="selecionar-todas">
                <label for="selecionar-todas">Selecionar Todas</label>
            </div>
            </form>

            <form name="form1" action="./UploadCargaNota.asp?Pers=1" method="post" enctype="multipart/form-data">
                <div class="row">
                    <div class="col-md-6">
                        <input required type="file" name="arquivo">
                        <button type="submit" class="btn btn-primary btn-xs mt15" name="submit"><i class="far fa-save"></i> Salvar</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

<div class="panel">
    <div class="panel-body pn" id="resultado">
        <%if getconfig("ListarAutomaticamenteNF") = 1 then
            server.Execute("NotaFiscalResultado.asp")
        end if%>
    </div>
</div>
<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script type="text/javascript">
    var $btnAcoes = $("#acoes-notas-fiscais");
    var $checkboxRps = $(".nfe-rps");

    $("#frmCC").submit(function () {
        $.post("NotaFiscalResultado.asp", $(this).serialize(), function (data) {
            $("#resultado").html(data);


            $checkboxRps = $(".nfe-rps");
        });
        return false;
    });

    $("#resultado").on("click",".nfe-rps",function() {
        var display = $checkboxRps.filter(":checked").length > 0 ? "block" : "none";

        $btnAcoes.css("display", display);
    });

    $("#EmitirEmLote").click(function() {
         var nfe = [];
         $("#acoes-notas-fiscais").fadeOut();
         $("#EmitirEmLote").attr("disabled", true);

         $.each($checkboxRps.filter(":checked"), function() {
             nfe.push($(this).val());
         });
         var test = false;

         $.post(feegow_components_path+"nota_fiscal_eletronica/EmitirEmLote",{nfe: nfe, invoiceId:1, test:test,'NFe[DataNota]':$("#De").val()},function(data){
             $("#btnBuscar").click();
             $("#acoes-notas-fiscais").fadeIn();
             alert("Envio com sucesso. Aguarde para receber o retorno.");
         }).error(function() {
           alert("Ocorreu um erro.");
           $("#btnBuscar").click();
         });

        //alert("Serviço adicional em manutenção")
    });

     $("#ConsultarEmLote2").click(async function(){
            var nfe = [];
            var nfeAguardando = $(".notaAguardando");

            await $.each(nfeAguardando, async function() {
                var nota = [];
                await nota.push($(this).data('notainvoiceid'));
                await nota.push($(this).data('notatoken'));
                await nota.push($(this).data('origemcnpj'));
                await nfe.push(nota)
             });

           setTimeout(async function(){
               for (const notaFiscal of nfe){
                    try{
                     const response = await $.get(feegow_components_path+`nota_fiscal_eletronica/ConsultarNFe?invoiceId=${notaFiscal[0]}&nfType=nota_fiscal_servico_eletronica&token=${notaFiscal[1]}`)

                     const res = await $.get(feegow_components_path+`nota_fiscal_eletronica/ObterRetorno/ObterRetornoConsultaNFSe?protocol=${response.protocolo}&cnpj=${notaFiscal[2]}&ci_csrf_token=&invoiceId=${notaFiscal[0]}&nfType=nota_fiscal_servico_eletronica&token=${notaFiscal[1]}`)
                        }catch (e) {
                          console.log(e)
                        }

                 }
           }, 4000)

        });

    $("#ConsultarEmLote").click(function() {
         var nfe = [];
         $("#acoes-notas-fiscais").fadeOut();
         $("#ConsultarEmLote").attr("disabled", true);

         $.each($checkboxRps.filter(":checked"), function() {
             nfe.push($(this).val());
         });
         var test = false;

         $.post(feegow_components_path+"nota_fiscal_eletronica/ConsultarEmLote",{nfe: nfe, invoiceId:1, test:test,'NFe[DataNota]':$("#De").val()},function(data){
             $("#btnBuscar").click();
             $("#acoes-notas-fiscais").fadeIn();
             alert("Envio com sucesso. Aguarde para receber o retorno.");
         }).error(function() {
           alert("Ocorreu um erro.");
           $("#btnBuscar").click();
         });

        //alert("Serviço adicional em manutenção")
    });

    function NFeBaixarRetorno() {
        $("#ReceberRetornoBtn").attr("disabled", true);
        $.get(feegow_components_path+"nota_fiscal_eletronica/ReceberRetorno",{invoiceId:1},function(data){
            $("#btnBuscar").click();
            alert("Retorno recebido");
        });
    }

function exportarExcel()
{
    $("#htmlTable").val($("#resultado").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"/reports/download-excel?title=Extrato&tk="+tk).submit();
}

    $(".selecionar-todas").click(function() {
            $checkboxRps = $(".nfe-rps");

            $checkboxRps.prop("checked", $(this).prop("checked"));

        var display = $checkboxRps.filter(":checked").length > 0 ? "block" : "none";

        $btnAcoes.css("display", display);
    });


    function xNf(id) {
        if(confirm("Tem certeza que deseja excluir essa NF?")){
            $(".linha-nf-"+id).remove();
            $.post("excluiNF.asp",{id:id}, function(data) {
            });
        }
    }

    function openNFe2() {
        // alert("Prezado cliente, por favor aguarde alguns instantes para acessar o relatório.")
        // return;

        var tk = localStorage.getItem("tk");

      window.open(
        domain + 'electronicinvoice/bills-receive?tk='+tk,
        '_blank' // <- This is what makes it open in a new window.
      );
    }

    function GerarRecibos() {
        var invoices = [];
        $("#btn-gerar-recibos").attr("disabled", true);

        var count = $(".recibo-com-problema").length;

        let i = 0;

        $.each($(".recibo-com-problema"), function() {
            var invoiceId = $(this).data("id");

            $.post("RegerarNFSe.asp", {InvoiceID: invoiceId}, function(data) {
              eval(data);
              i++;

              if(i >= count){
                  alert(i +  " recibos emitidos com sucesso.")
                $("#btn-gerar-recibos").attr("disabled", false);

                  $("#frmCC").submit();
              }
            });
        });


    }


</script>