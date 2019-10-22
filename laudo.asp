<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<link rel="stylesheet" href="vendor/plugins/dropzone/css/dropzone.css">
<!--#include file="mfp.asp"-->
<link rel="stylesheet" type="text/css" href="site/jquery.gridster.css">
<link rel="stylesheet" type="text/css" href="site/demo.css">
<link rel="stylesheet" type="text/css" href="buiforms.css">
<link rel="stylesheet" type="text/css" href="assets/css/colorbox.css" />
<script src="site/jquery.gridster.js" type="text/javascript" charset="utf-8"></script>


<script type="text/javascript">
    $(".crumb-active a").html("Laudo");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("detalhes do laudo");
    $(".crumb-icon a span").attr("class", "fa fa-file-text");
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
if LaudoID="" then
    set pproc = db.execute("select ifnull(DiasLaudo, 0) DiasLaudo, FormulariosLaudo, NomeProcedimento FROM procedimentos where id="&ProcedimentoID)
    if not pproc.eof then
        DiasLaudo = ccur(pproc("DiasLaudo"))
        PrevisaoEntrega = dateadd("d", DiasLaudo, Execucao)
        FormulariosLaudo = pproc("FormulariosLaudo")&""
        FormulariosLaudo = replace(FormulariosLaudo, "|", "")
        NomeProcedimento = pproc("NomeProcedimento")
        if FormulariosLaudo<>"" then
            splFormulariosLaudo = split(FormulariosLaudo, ", ")
            FormID = splFormulariosLaudo(0)
        else
            FormID = 0
        end if
        set vca = db.execute("select id from laudos where Tabela='"& Tabela &"' and IDTabela="& IDTabela)
        if vca.eof then
            db.execute("insert into laudos (PacienteID, ProcedimentoID, Tabela, IDTabela, FormID, PrevisaoEntrega, StatusID) values ("& PacienteID &", "& ProcedimentoID &", '"& Tabela &"', "& IDTabela &", "& FormID &", "& mydatenull(PrevisaoEntrega) &", 1)")
            set pult = db.execute("select id from laudos where Tabela='"& Tabela &"' and IDTabela="& IDTabela &" order by id desc limit 1")
            LaudoID = pult("id")
        else
            LaudoID = vca("id")
        end if
    end if
    response.Redirect("./?P=Laudo&Pers=1&I="& LaudoID)
else
    set l = db.execute("select l.*, p.NomePaciente from laudos l LEFT JOIN pacientes p ON p.id=l.PacienteID where l.id="& LaudoID)
    if not l.eof then
        PacienteID = l("PacienteID")
        NomePaciente = l("NomePaciente")
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
    <p><strong>Paciente:</strong> <%=NomePaciente%></p>
    <p><strong>Procedimento:</strong> <%=NomeProcedimento%></p>
        <div class="tab-pane cel_input active" id="folha">

        </div>

        <div class="tab-pane" id="divAnexos">
            <div class="panel-heading">
                <span class="panel-title">Anexos</span>
                <span class="panel-controls">
                    <button class="btn-primary btn btn-sm btn-primary" onclick="saveLaudo('Texto')"><i class="fa fa-save"></i> Salvar</button>
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
                            <span class="panel-title"><i class="fa fa-camera"></i> Imagens do Paciente</span>
                        </div>
                        <div id="divImagens" class="panel-body pn">
                            <iframe width="100%" height="170" frameborder="0" scrolling="no" src="dropzone.php?PacienteID=<%=PacienteID %>&LaudoID=<%= LaudoID %>&L=<%= replace(session("Banco"), "clinic", "") %>&Pasta=Imagens&Tipo=I"></iframe>

                            <div id="ImagensPaciente">
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    function callForm(F, I) {
        //alert(I);
        $.get("iPront.asp?t=L&p=<%= PacienteID %>&m="+ F +"&i="+ I +"&a=&LaudoSC=1", function (data) { $("#folha").html(data) });    
    }

    $("#FormularioID").change(function () {
        callForm($(this).val(), 'N');
    });



    $(document).ready(function () {

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
        $.post("saveLaudo.asp?L=<%= LaudoID %>&T="+ T, $("#Texto, #StatusID, #ProfissionalID, #Restritivo, #DataEntrega, #HoraEntrega, #ObsEntrega, #Receptor").serialize(), function(data){
            eval(data);
            
            if(print){
//                window.open('printForm.asp?PacienteID=<%= PacienteID %>&ModeloID=<%= FormID %>&FormID=<%= FormPID %>&LaudoID=<%= LaudoID %>');
            }
        });
    }

    function entrega() {
        if ($("#StatusID").val() == 3) {
            $("#modal-table").modal("show");
            $("#modal").html("Carregando...");
            $.post("laudoEntrega.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
        } else {
            alert("Não é possível entregar o laudo pois o mesmo ainda não foi liberado.");
        }
    }

    function protocolo() {
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.post("laudoProtocolo.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
     }


    function LogLaudos() {
        $("#modal-table").modal("show");
        $("#modal").html("Carregando...");
        $.post("laudoLog.asp?L=<%=LaudoID%>", "", function (data) { $("#modal").html(data) });
    }

    function syncLabResult(invoices) {
        $("#syncInvoiceResultsButton").prop("disabled", true);
        postUrl("labs-integration/matrix/sync-invoice", {
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

    $("#rbtns").html("<a class='btn btn-sm btn-default' href='./?P=Laudos&Pers=1'><i class='fa fa-list'></i></a>");

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
		url:"Arquivos.asp?PacienteID=<%=request.QueryString("I")%>&X="+X,
		success:function(data){
			$("#ArquivosPaciente").html(data);
		}
	});
}


</script>
    <script src="assets/js/jquery.colorbox-min.js"></script>
