<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<link rel="stylesheet" href="vendor/plugins/dropzone/css/dropzone.css">
<!--#include file="mfp.asp"-->
<link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
<link rel="stylesheet" type="text/css" href="site/demo.css">
<link rel="stylesheet" type="text/css" href="buiforms.css">
<link rel="stylesheet" type="text/css" href="assets/css/colorbox.css" />
<script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>
<script crossorigin type="text/babel" src="react/telemedicina/Services/TelemedicinaService.js"></script>

<script type="text/javascript">
    $(".crumb-active a").html("Laudo");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("detalhes do laudo");
    $(".crumb-icon a span").attr("class", "far fa-file-text");
</script>


<style type="text/css">
#folha{
		font-family: Arial, sans-serif;
		list-style-type: none;
		margin: 0px;
		padding: 0px;
		width: 960px;
		height:1200px;
		background-color:#FFFFFF;
		border:1px solid #fff;
		position:relative;
}
.campos{
		position:absolute;
		margin: 0;
		border: 2px dotted #fff;
		text-align: center;
		padding: 10px;
		background-color: #fff;
		text-align:left;
		min-height:80px!important;
}
.lembrar{
	position:absolute;
	right:0;
	display:none;
}
.campos:hover .lembrar{
	display:block;
}
.campo:hover .lembrar{
	display:block;
}
.gridster .gs-w {
    cursor:default!important;
}
@media print{
    .panel-controls{
        display: none;
    }
    #timeline.timeline-single .timeline-icon{
        background-color: #EEEEEE;
        border-radius: 50%;
        height: 35px;
        width: 35px;
        z-index: 99;
    }
}
.btn-primary.disabled{
    pointer-events:auto;
}
</style>


<%
LaudoID = req("I")
IDTabela = req("IDT")
Tabela = req("T")
PacienteID = req("Pac")
ProcedimentoID = req("Proc")
Execucao = req("E")
NomePaciente = ""
NomeProcedimento = ""

invoiceid = req("invoiceid")
formid    = req("formid")

if invoiceid <> "" then
    sql = "SELECT lau.id, lau.pacienteID "&_
          "FROM sys_financialinvoices fi "&_
          "INNER JOIN laudos lau ON (lau.PacienteID = fi.AccountID AND fi.AssociationAccountID =3 AND lau.IDTabela = fi.id) "&_
          "WHERE fi.id = "&invoiceid&" AND tabela = 'sys_financialinvoices' AND formid = '"&formid&"' order by lau.id desc limit 1"
    set laudobyinvoiceid  = db.execute(sql)
    if laudobyinvoiceid.eof then
        sql ="insert into laudos (PacienteID, ProcedimentoID, Tabela, IDTabela, FormID,  StatusID) "&_ 
             "values ("& PacienteID &", "& treatvalzero(ProcedimentoID) &", 'sys_financialinvoices', "& invoiceid &", '"&formid&"', 1)"
        'response.write (sql)
        db.execute(sql)

        sql = "select id from laudos where Tabela='sys_financialinvoices' and IDTabela="& invoiceid &" and pacienteid = "&PacienteID&" and procedimentoid="&treatvalzero(ProcedimentoID) &" and formid='"&formid&"' order by id desc limit 1"
        set pult = db.execute(sql)

        if not pult.eof then
            LaudoID = pult("id")
        end if 
    else 
        LaudoID = laudobyinvoiceid("id")
    end if 
    'response.write(LaudoID)
    'response.end 
    redir = "./?P=Laudo&Pers=1&I="& LaudoID    
    response.Redirect(redir)
end if 


if LaudoID="" then
    sql = "select ifnull(DiasLaudo, 0) DiasLaudo, FormulariosLaudo, NomeProcedimento FROM procedimentos where id='"&ProcedimentoID&"'"
    set pproc = db.execute(sql)
    
    FormID = 0

    if not pproc.eof then
        DiasLaudo = ccur(pproc("DiasLaudo"))
        PrevisaoEntrega = dateadd("d", DiasLaudo, Execucao)
        FormulariosLaudo = pproc("FormulariosLaudo")&""
        FormulariosLaudo = replace(FormulariosLaudo, "|", "")
        NomeProcedimento = pproc("NomeProcedimento")
        if FormulariosLaudo<>"" then
            splFormulariosLaudo = split(FormulariosLaudo, ", ")
            FormID = splFormulariosLaudo(0)
        end if
    end if
        sql = "select id from laudos where Tabela='"& Tabela &"' and IDTabela="& IDTabela
        
        set vca = db.execute(sql)
        if vca.eof then
            db.execute("insert into laudos (PacienteID, ProcedimentoID, Tabela, IDTabela, FormID, PrevisaoEntrega, StatusID) values ("& PacienteID &", "& treatvalzero(ProcedimentoID) &", '"& Tabela &"', "& IDTabela &", "& FormID &", "& mydatenull(PrevisaoEntrega) &", 1)")
            set pult = db.execute("select id from laudos where Tabela='"& Tabela &"' and IDTabela="& IDTabela &" order by id desc limit 1")
            LaudoID = pult("id")
        else
            LaudoID = vca("id")
        end if
        
    redir = "./?P=Laudo&Pers=1&I="& LaudoID
    
    response.Redirect(redir)
else
    set l = db.execute("SELECT proc.NomeProcedimento, pac.NomePaciente, l.*, "&_
                       " "&_
                       "COALESCE(ii.ItemID, tpsadt.ProcedimentoID) ProcedimentoID "&_
                       "FROM laudos l  "&_
                       " "&_
                       "INNER JOIN pacientes pac ON pac.id=l.PacienteID "&_
                       "LEFT JOIN itensinvoice ii ON ii.id=l.IDTabela AND l.Tabela='itensinvoice' "&_
                       "LEFT JOIN tissprocedimentossadt tpsadt ON tpsadt.id=l.IDTabela AND l.Tabela='tissprocedimentossadt' "&_
                       "LEFT JOIN procedimentos proc ON proc.id=COALESCE(ii.ItemID, tpsadt.ProcedimentoID) "&_
                       "WHERE l.id="& LaudoID)
    if not l.eof then
        PacienteID = l("PacienteID")
        NomePaciente = l("NomePaciente")
        NomeProcedimento = l("NomeProcedimento")
        Texto = l("Texto")
        FormPID = l("FormPID")
        if isnull(FormPID) then
            FormPID = "'N'"
        end if

        FormID=l("FormID")

        if isnull(FormID) then
            FormID=0
        end if
        chamaFP = "callForm("& FormID &", "& FormPID &");"
    end if
end if
    
%>

<input type="hidden" name="LaudoID" id="LaudoID" value="<%= LaudoID %>" />

<input type="hidden" id="NomePaciente" value="<%= NomePaciente %>" />



<div class="tabbable panel mt20">
    <div class="tab-content panel-body">
    <p><strong>Paciente:</strong> <%=NomePaciente%> <span class="pull-right"><button class="btn btn-primary" id="btnSoliciaRetorna">Comunicar ao Paciente</button></span></p>
    <p><strong>Procedimento:</strong> <%=NomeProcedimento%></p>
        <div class="tab-pane cel_input active" id="folha">

        </div>

        <div class="tab-pane" id="divAnexos">
            <div class="panel-heading">
                <span class="panel-title">Anexos</span>
                <span class="panel-controls">
                    <button class="btn-primary btn btn-sm btn-primary" onclick="saveLaudo('Texto')"><i class="far fa-save"></i> Salvar</button>
                </span>
            </div>
            <div class="panel-body">
                <div class="col-md-6">
                    <label for="Texto">Texto</label>
                    <textarea name="Texto" id="Texto" rows="10" class="form-control"><%=Texto%></textarea>
                </div>
                <div class="col-md-6">
                    <div class="panel">
                        <div class="panel-heading">
                            <span class="panel-title"><i class="far fa-camera"></i> Imagens do Paciente</span>
                        </div>
                        <div id="divImagens" class="panel-body pn">
                            <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&LaudoID=<%= LaudoID %>&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Imagens&Tipo=I"></iframe>
                            <script>
                                   function loadImagensLaudo(){
                                       	 <% IF getConfig("NovaGaleria") = "1" THEN %>
                                               if($(".galery-ajax").length === 0){
                                                  $("#ImagensPaciente").prepend("<div class='galery-ajax'></div>");
                                                  fetch("ImagensNew.asp?PacienteID=<%=req("PacienteID")%>&LaudoID=<%= LaudoID %>")
                                                    .then(data => data.text())
                                                    .then(data => {
                                                       $(".galery-ajax").html(data);
                                                    });
                                               }
                                          <%  ELSE %>
                                               ajxContent('Imagens&PacienteID=<%= PacienteID %>', 0, 1, 'ImagensPaciente')
                                          <%  END IF %>
                                   }
                            </script>
                            <div id="ImagensPaciente"></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script>

function changeTexto(arg){
        let texto = `Olá [NomePaciente],
                 Após análise dos documentos enviados, Dr(a). [NomeProfissional] identificou alguns detalhes que necessitam de acompanhamento.
                 Favor entrar em contato para agendar um retorno próximo para dar continuidade ao tratamento.`


    $(".btn-texto").removeClass("btn-dark");

    $(".btn-texto").removeClass("btn-default");
    if(arg === 2){

        texto = `Olá [NomePaciente],
                 Após análise dos arquivos enviados, Dr(a). [NomeProfissional] identificou que não há problemas imediatos.
                 Caso haja alguma dúvida você pode entrar em contato com a clínica e solicitar um novo acompanhamento.`;

        $(".btn-texto-2").addClass("btn-dark");
        $(".btn-texto-1").addClass("btn-default");
        $(".btn-texto-1").attr("data-return",0);
    }else{
        $(".btn-texto-1").attr("data-return",1);
        $(".btn-texto-1").addClass("btn-dark");
        $(".btn-texto-2").addClass("btn-default");
    }


    $("#texto").val(texto);
}
</script>

<!-- Modal -->
<div class="modal fade" id="modalPreecherTexto" tabindex="-1" role="dialog" aria-labelledby="modalPreecherTexto" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Resposta ao Paciente</h5>
      </div>
      <div class="modal-body">
        <button class="btn btn-sm btn-dark btn-texto btn-texto-1" type="button" onclick="changeTexto(1,this)">Retorno</button>
        <button class="btn btn-sm btn-default btn-texto btn-texto-2" onclick="changeTexto(2,this)" type="button">Não Retorno</button>
            <textarea class="form-control mt15" id="texto" style="height: 250px"></textarea>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button>
        <button type="button" class="btn btn-primary" onclick="enviarEmailLaudo()">Enviar</button>
      </div>
    </div>
  </div>
</div>


<script type="text/javascript">

    function enviarEmailLaudo(){
        endpointSendMailToPatient($("#LaudoID").val(),env);
                showMessageDialog("Email de retorno enviado com sucesso.", "success");
    }

    function callForm(F, I) {
        //alert(I);
        $.get("iPront.asp?t=L&p=<%= PacienteID %>&m="+ F +"&i="+ I +"&a=&LaudoSC=1&pl="+$("#ProfissionalID").val(), function (data) { console.log(data);$("#folha").html(data) });    
    }

    endpointSendMailToPatient = (laudoID,env) => {
        let objct = {};
        objct.laudoID = laudoID;
        objct.retorno = $(".btn-texto-1").attr("data-return");
        objct.mensagemLaudo = $("#texto").val();
        return $.ajax({
            url: getEnvUrl(env,"medical-report-integration/send-mail-medical-reply"),
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(objct)
        });
    };

    getEnvUrl = (env, endpoint) => {
        return (env === "production" ? "https://app.feegow.com.br/":"http://localhost:8000/") + endpoint;
    }

    $("#btnSoliciaRetorna").click(function(){
            $('#modalPreecherTexto').modal('toggle');
            changeTexto();
    });

    $("#FormularioID").change(function () {
        callForm($(this).val(), 'N');
    });



    $(document).ready(function () {
        $(".btn-texto-1").attr("data-return",1);
        <% if chamaFP= "" then %>
        alert('chamando form preenchido: '+ $("#FormularioID").val() );
        if ($("#FormularioID").val() != "0") {
            callForm($("#FormularioID").val(), 'N');
        }

        
        <% else
        response.write(chamaFP)
        end if


        %>
        if ($("#StatusID").val() == 3) {
            <%if getConfig("NaoAlterarLaudo")=1 then%>
            $("#ProfissionalID").attr("disabled", "true");
            $("#qfformularioid").attr("style", "pointer-events: none;");
            <%end if%>

            setTimeout(function() {
                $("#iProntCont").attr("style", "pointer-events: none;");
            }, 200);
        }

    });

    function saveLaudo(T, print){
        $.post("saveLaudo.asp?L=<%= LaudoID %>&T="+ T, $("#Texto, #StatusID, #ProfissionalID, #Restritivo, #DataEntrega, #HoraEntrega, #ObsEntrega, #Receptor, #CPFReceptor").serialize(), function(data){
            eval(data);
            
            if(print){
//                window.open('printForm.asp?PacienteID=<%= PacienteID %>&ModeloID=<%= FormID %>&FormID=<%= FormPID %>&LaudoID=<%= LaudoID %>');
            }
        });
    }

    function entrega() {
        if ($("#StatusID").val() == 3) {
            $("#modal-table").modal("show");
            $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
            $.post("laudoEntrega.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
        } else {
            alert("Não é possível entregar o laudo pois ainda não foi liberado.");
        }
    }

    function protocolo() {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("laudoProtocolo.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
     }


    function LogLaudos() {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.post("laudoLog.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
    }

    function syncLabResult(invoices, labid =2) {
        var caminhointegracao = "";
        $("#syncInvoiceResultsButton").prop("disabled", true);  
        switch (labid.toString()) {
            case '1':      
                caminhointegracao = "matrix"; 
                break;
            case '2': 
                caminhointegracao = "diagbrasil";
                break;
            default:
                alert ('Erro ao integrar com Laboratório');
                return false;
        }  
        postUrl("labs-integration/"+caminhointegracao+"/sync-invoice", {
            "invoices": invoices
        }, function (data) {
            $("#syncInvoiceResultsButton").prop("disabled", false);
            if(data.success) {
                location.reload();
            } else {
                alert(data.content)
            }
        })
    }

    $("#StatusID").change(function () {
        $(".btn-save-form-text").first().click();
        saveLaudo('StatusID');
        window.location.reload();
    });

    $("#ProfissionalID").change(function () {
        saveLaudo('ProfissionalID');
    });

    $("#rbtns").html("<a class='btn btn-sm btn-default' href='./?P=Laudos&Pers=1'><i class='far fa-list'></i></a>");

function ChangeButtonHistorico(valor)
{
        if(valor !="3")
        {
            $("#liHistorico").hide();
        }else
        {
            $("#liHistorico").show();
        }
}

function atualizaAlbum(X, LaudoID){
    //apenas chamar pront
	$.ajax({
		type:"POST",
		url:"Imagens.asp?PacienteID=<%=PacienteID%>&X="+X,
		success:function(data){
		    $("#ImagensPaciente").html(data);
		}
	});
}

	function atualizaArquivos(X){
        //apenas chamar pront
	$.ajax({
		type:"POST",
		url:"Arquivos.asp?PacienteID=<%=req("I")%>&X="+X,
		success:function(data){
			$("#ArquivosPaciente").html(data);
		}
	});
}


</script>
    <script src="assets/js/jquery.colorbox-min.js"></script>
