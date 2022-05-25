
<!--#include file="./Classes/ServerPath.asp"-->
<%
'on error resume next
FormID = Id

ExibeForm = true
FormInativo = false
if FormID <> "N" then
    set getFormPreenchido = db.execute("SELECT date(DataHora) dataAtendimento, sysActive FROM buiformspreenchidos WHERE sysActive != 0 AND id = "&FormID)
    if not getFormPreenchido.eof then
        if getFormPreenchido("sysActive") = -1 then
            FormInativo = true
        else
            dataAtendimento = getFormPreenchido("dataAtendimento")
            'Bloquea a edição após o dia do atendimento (configuração)
            if getConfig("BloquearEdicaoFormulario") = 1 and dataAtendimento <> date()  then
                ExibeForm = false
                DisabledBotao = " style='pointer-events:none;' "
            end if
        end if
    end if
end if

set getForm = db.execute("select * from buiforms where id="& ModeloID )
if not getForm.eof then
    if req("IFR")="" then
    %>
<head>
  <meta charset="utf-8">

<meta http-equiv="Content-Language" content="pt-br">

</head>
<body>
    <div class="panel-heading">
        <span class="panel-title">
        <i class="far fa-bar-chart"></i> <%=getForm("Nome") %>
            <code id="nomeProfissionalPreen"></code>
        </span>
        <span class="panel-controls">
            <button type="button" class="btn btn-alert btn-sm hidden-xs btn-sensitive-action" onclick="showLog()"><i class="far fa-history"></i> Logs</button>
            <% if req("LaudoSC")="" then %>
                <button class="btn btn-default btn-sm btn-print-form hidden-xs btn-sensitive-action" type="button" onclick="saveForm('P')"><i class="far fa-print"></i> Imprimir</button>
            <% end if %>

            <% if ExibeForm <> false then %>
                <button class="btn btn-primary btn-sm btn-save-form btn-sensitive-action" type="button" onclick="saveForm(0, 0);"><i class="far fa-save"></i> <span class="btn-save-form-text">Salvar</span></button>
            <% end if %>

            <% if req("LaudoSC")="" then %>
                <button class="btn btn-default btn-sm" type="button" onclick="fecharForm()"><i class="far fa-remove"></i> Fechar </button>
            <% end if %>
        </span>
    </div>
        <div class="panel-menu text-center">
            <a href="./?P=Pacientes&I=<%=PacienteID %>&Pers=1" target="_blank" class=" nomePacientePreen btn btn-default btn-block btn-primary"></a>
        </div>
             <div class="alert alert-warning internetFail text-center" style="display:none">Sua internet está apresentando lentidão</div>
    <% end if %>
<div class="panel-body p25 sensitive-data" id="iProntCont">
    <span class="form-status-holder"></span>
    <br />

    <%

    if getForm("Versao")=1 then
	    %>
        <!--#include file="callOldForm.asp"-->
        <%
    else
        if getForm("useHTML") then
            %>
            <!--#include file="callHTMLForm.asp"-->
            <%
        else
	        %>
            <!--#include file="callNewForm.asp"-->
            <%
        end if
    end if
    %>
    
    <div class="text-left mt20">
        <a href="#" class="btn btn-default btn-sm" id="showTimeline">Mostrar/Ocultar Histórico <i class="fas fa-caret-down ml5"></i></a>
    </div>

    <div id="conteudo-timeline"></div>

    </div>
</div>
    <% if req("IFR")="" then %>
        <div class="panel-footer text-right">
            <button type="button" class="btn btn-default hidden-xs btn-sm btn-sensitive-action" onclick="showLog()"><i class="far fa-history"></i> Logs</button>

            <button type="button" class="btn btn-default btn-sm hidden" onclick="window.open('<%=appUrl(False)%>/feegow_components/api/FormLogs?P=<%=req("p") %>')"><i class="far fa-history"></i> Logs</button>
            <% if req("LaudoSC")="" then %>
                <button class="btn btn-default btn-sm hidden-xs btn-print-form btn-sensitive-action" type="button" onclick="saveForm('P')"><i class="far fa-print"></i> Imprimir</button>
            <% end if %>
            
            <% if ExibeForm <> false then %>
                <button class="btn btn-primary btn-sm btn-save-form btn-sensitive-action" type="button" onclick="saveForm(0, 0);"><i class="far fa-save"></i> <span class="btn-save-form-text">Salvar</span></button>
            <% end if %>
        </div>
    <% end if %>
<%else %>
    Este modelo de formulário foi apagado.
<%end if


urlPost = "saveNewForm.asp?A='+A+'&t="&req("t")&"&p="&req("p")&"&m="&req("m")
%>
<script type="text/javascript">
/*
    function saveForm(A) {
        var $form = $('.tbl');
        var dados = {
            <%
            set pcampos = db.execute("select id, TipoCampoID from buicamposforms where FormID="&intval(req("m")))
            while not pcampos.eof
                select case pcampos("TipoCampoID")
                    case 1, 2, 6
                        postVal = "$('#input_"& pcampos("id")&"').val()"
                    case 8
                        postVal = "$('#input_"& pcampos("id")&"').html()"
                    case 4
                        postVal = "$('.campoCheck[name=input_"& pcampos("id") &"]:checked').map(function() { return $(this).val().toString(); } ).get().join("","")"
                    case 5
                        postVal = "$('.campoInput[name=input_"& pcampos("id") &"]:checked').val()"
                    case 9
                        postVal = "$('.tbl').serialize()"
                    case else
                        postVal= ""
                end select
                if postVal<>"" then
                    %>
                    input_<%=pcampos("id")%>: <%=postVal%>,
                    <%
                end if
            pcampos.movenext
            wend
            pcampos.close
            set pcampos=nothing
            %>
        };

        dados = $form.serialize() + '&' + $.param(dados);

        $.ajax({
            type: 'POST',
            url: '<%=urlPost%>',
            data: dados,

            success: function (data) {
                eval(data);
            }
        });

    }
*/
    <%
    'Duplica o formulário se o atual for Inativo ou se a configuração para Gerar novo formulário ao editar estiver habilitada
    if getConfig("GerarNovoFormulario")=1 or FormInativo = true then
        FormID="N"
    end if
    %>

    var FormID = "<%=FormID%>";
    var Inserir="0";
    var TipoForm="<%=req("t")%>";

    if(FormID==="N"){
        Inserir="1";
    }

    function saveForm(A, AutoSave,inicio=false) {
        var $btnSave = $(".btn-save-form"),
            $btnPrint = $(".btn-print-form"),
            $btnSaveText = $btnSave.find(".btn-save-form-text");

        if (FormID === "N"){
            var newFormId = parseInt($("#FormID").val());

            if(newFormId > 0){
                FormID = newFormId;
            }
        }

        if(!inicio){
            let formdata = $(".campoInput, .campoCheck, .tbl, .bloc, #ProfissionaisLaudar, #LaudoID")
            let erro = false;
            let campoCheck = ""
            formdata.map((key,input)=>{
                let required =  $(input).prop('required')
                if (required){
                    if ($(input).prop('type')== 'checkbox'){
                        if(campoCheck != $(input).attr("data-campoid")){
                            campoCheck = $(input).attr("data-campoid")
                            var inputs = $(input).parent().parent().find('input');
                            let temcheckboxselecionado = false
                            inputs.each(function(key,input){
                                if ($(input).is(":checked")){
                                    temcheckboxselecionado = true
                                }
                            });
                            if(!temcheckboxselecionado){
                                let nome = $(input).data('name').trim()
                                new PNotify({
                                        title: 'Ocorreu um erro!',
                                        text: 'O campo '+nome+' é obrigatório!',
                                        type: 'danger',
                                        delay: 3000
                                    });
                                    erro = true
                                    return false
                            }
                        }
                    }else{
                        let valor = $(input).val()
                        if(valor.length<=0){
                            let nome = $(input).data('name').trim()
                            new PNotify({
                                title: 'Ocorreu um erro!',
                                text: 'O campo '+nome+' é obrigatório!',
                                type: 'danger',
                                delay: 3000
                            });
                            erro = true
                            return false
                        }
                    }
                }
            })
            if(erro){
                return false
            }
        }
        formdata = $(".campoInput, .campoCheck, .tbl, .bloc, #ProfissionaisLaudar, #LaudoID").serialize()

        if (FormID != "N")
        {
            SaveOnLocal(FormID, formdata);
        }

        $btnSaveText.html("Salvando");
        $btnSave.attr("disabled", true);
        $btnPrint.attr("disabled", true);
        $.post('<%=urlPost%>&i='+FormID+"&auto="+AutoSave+"&Inserir="+Inserir,
         formdata,
         function(data){
            $btnSave.attr("disabled", false);
            $btnPrint.attr("disabled", false);
            $btnSaveText.html("Salvar");

            if(AutoSave==0){
                DescartarLog('<%=FormID%>');
            }

            if(typeof data !== "undefined"){
                eval(data);
            }

        }).fail(function() {
              $btnSave.attr("disabled", false);
              $btnPrint.attr("disabled", false);
              $btnSaveText.html("Salvar");
              SaveOnLocal(FormID, formdata, true);

              showMessageDialog("Ocorreu um erro ao tentar salvar.")
            });
    }

    function SaveOnLocal(formID, dataForm, errorForm = false)
    {
        let jsonForm = $(".campoInput, .campoCheck, .tbl, .bloc, #ProfissionaisLaudar, #LaudoID").serializeFormJSON();
        let localStorageKey = errorForm ? "logErrorForms" : "logForms";

        let local = localStorage.getItem(localStorageKey);

        let data_hora = new Date();;
        let data = {
            formID:String(formID),
            pacienteID: <%=req("p")%>,
            modeloID: <%=req("m")%>,
            tipo:TipoForm,
            dataHora: data_hora.toLocaleDateString() +" "+ data_hora.toLocaleTimeString(),
            jsonForm:jsonForm ,
            formData: dataForm
             };
        let ret = [];

        if(local != null)
        {
            ret = JSON.parse(local);

            let element = ret.findIndex((elem,index)=>{
                   return (elem.formID === data.formID
                            && elem.pacienteID === data.pacienteID
                            && elem.tipo === data.tipo);
            }) ;

            if(element>=0){
                ret[element].formData = data.formData;
                ret[element].jsonForm = data.jsonForm;
                ret[element].dataHora = data.dataHora;
            }else
            {
                if(ret.length >= 10)
                {
                    ret.pop();
                    ret.push(data);
                }
                    ret.push(data);
            }
        }else
        {
            ret.push(data);
        }
        localStorage.setItem(localStorageKey, JSON.stringify(ret));
    }

    function DescartarLog(id){
        let local = localStorage.getItem("logForms");
        let pacienteID = "<%=PacienteID%>";
        let tipo = "<%=req("t")%>";

        if(local){
            let ret = JSON.parse(local);

            let element = ret.findIndex((elem,index)=>{
                        return (elem.formID == id && elem.pacienteID == pacienteID && elem.tipo == tipo);
                    }) ;

            ret.splice(element,1);
            localStorage.setItem("logForms", JSON.stringify(ret));
        }
    }

    function alt(){
        $("#Alterado").val('S');
        if (TipoForm!="L"){
            saveForm(0, 1);
        }
        saveLog("update");
        //$.post("formsLog.asp?m=<%=req("m")%>&p=<%=req("p")%>&i="+FormID, $(".campoInput, .campoCheck, .tbl").serialize(), function(data){});
    }

    //inicio log do formulario

    var timeoutId;
    $("#divLay").on('input propertychange change keyup','.campoInput, .campoCheck, .tbl, .tbl input, .text', function() {

        clearTimeout(timeoutId);
        timeoutId = setTimeout(function() {
            alt();
        }, 8000);
    });

    var ultimo="";
    var timeout  = null;
    function saveLog(action = "updated"){

        let atual =  $(".campoInput, .campoCheck, .tbl").serializeFormJSON();


        if(atual!=ultimo){

            //desabilita feature
            // return;

            ultimo=atual;

            recordLog({
                category:"forms",
                event: action,
                licenseId: "<%=LicenseId%>",
                userId: "<%=Session("User")%>",
                oldData: {},
                newData: {
                    'pacienteID': <%=req("p")%>,
                    'modeloID': <%=req("m")%>,
                    'formID': FormID,
                    data: atual
                }
            });
        }
    }


    function showLog(){
        $.ajax({
                url: domain+"log/getFormLog",
                method: 'POST',
                dataType: 'json',
                data:
                {
                    'pacienteID': <%=req("p")%>,
                    'modeloID': <%=req("m")%>,
                    'formID': FormID,
                },
                success: (data) => {
                    var list="<div class='logTimeLine' style='overflow:auto; max-height:600px;'>";

                    $.each(data, function (key, value) {
                        jsonContent = JSON.parse(value.JSON);
                        let content = "";

                        $.each(jsonContent, function(k, v) {
                            content +="<p>" + v +"</p>";
                        });
                        let data = new Date(value.DataHora);
                        list += `<div  class="logTimeLine-item">
                                    <h3 >${data.toLocaleDateString() +" "+ data.toLocaleTimeString()}</h3>
                                    ${content}
                                </div>`;
                        });
                        list +="</div>";

                        openModal(list, "Log de modificações", true, false);
                }
            });

    }

    (function ($) {
    $.fn.serializeFormJSON = function () {

        var o = {};
        var a = this.serializeArray();
        $.each(a, function () {
            if (o[this.name]) {
                if (!o[this.name].push) {
                    o[this.name] = [o[this.name]];
                }
                o[this.name].push(this.value || '');
            } else {
                o[this.name] = this.value || '';
            }
        });
        return o;
    };
    })(jQuery);





    //fim do novo log do formulario
/*
   $(".campoCheck, .campoInput, .tbl").change(function(){
       console.log("teste");
        if(!$(this).attr("readonly")){
            alt();
        }
    });
*/
    function fecharForm(){
        if($("#Alterado").val()=="S"){
            if(confirm("ATENÇÂO: Você não salvou este formulário. Tem certeza de que deseja fechar sem salvar?")){
                $("#modal-form").magnificPopup("close");
            }
        }else{
            $("#modal-form").magnificPopup("close");
        }
    }
    if("<%=FormID%>" === "N"){
        saveForm(0, 1,true);
        saveLog("create");
    }

    var loadingTimeline = false;

    $(function(){
        $("#conteudo-timeline").hide();
        $("#showTimeline").on('click', function(){

            if(!loadingTimeline){
                loadingTimeline=true;
                toggleBtnLoading("#showTimeline");
                
                $("#conteudo-timeline").html("")
                ProntTimelineLoadMore(0);
            }   
        })
    });

    function ProntTimelineLoadMore(offset){
        $.get("timelineloadmore.asp", {CallbackShowMore: 'ProntTimelineLoadMore' ,BtnShowMore: true, LoadMore: offset, PacienteID:'<%=req("p")%>', Tipo: "|Prescricao|AE|L|Diagnostico|Atestado|Imagens|Arquivos|Pedido|", OcultarBtn: 1}, function(data) {
            $("#conteudo-timeline").append(data)
            if(offset === 0){
                $("#conteudo-timeline").toggle(1000);
                toggleBtnLoading("#showTimeline");
                loadingTimeline=false;
            }
        });
    }

</script>

<style>

#iProntCont .logTimeLine {
  width: 700px;
  margin: 25px auto;
  padding: 10px 20px 10px 20px;
  border-left: 2px solid #3498db;
}

#iProntCont .logTimeLine-item {
  background-color: #fff;
  padding: 10px;
  margin: 10px;
  font-size: 12px;
  border: 1px solid #3498db;
  line-height: 1.5;
  position: relative;
  color: #666;
  border-radius: 4px

}

#iProntCont .logTimeLine-item:before {
  content: "";
  display: block;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background-color: #3498db;  position: absolute;
  top: 7px;
  left: -29px
}

#iProntCont .logTimeLine-item:after {
  content: "";
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 8px;
  border-color: transparent #3498db transparent transparent ;
  position: absolute;
  top: 4px;
  left: -17px
}

</style>
</body>