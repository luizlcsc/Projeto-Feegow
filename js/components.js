var isProduction = window.location.href.indexOf("clinic.feegow") || window.location.href.indexOf("clinic4.feegow") > 0;
var currentUrl = window.location.href;
var urlSplit = currentUrl.split(".br");
var mainDomain = urlSplit[0] + ".br/";


var env = "production";
if(window.location.href.indexOf('local') == 7){
    env = "local";
}

if(window.location.href.indexOf('homolog') > 0){
    env = "homolog";
}

if(window.location.href.indexOf('sandbox') > 0){
    env = "homolog";
}

var domain = null;
var api = null;

switch (env){
    case "local":
        domain = "http://localhost:8000/";
        labServiceURL = "http://localhost:8001/"
        api = "./api/";
        break;
    case "production":
        domain = "https://app.feegow.com.br/";
        labServiceURL = "https://labservice.feegow.com/"
        api = "/main/api/";
        break;
    case "homolog":
        domain = "https://api-homolog.feegow.com/index.php/";
        labServiceURL = "https://labservice.feegow.com/"
        api = "/main/api/";
        break;
}

var modalTimeout = 1000;

var modal = "<div id=\"modal-components\" class=\"modal fade\" tabindex=\"-1\">" +
    "    <div \[MODAL-WIDTH]\ class=\"modal-dialog [MODAL-SIZE]\"> " +
    "       <form id='form-components' method='post'>" +
    "           <div class=\"modal-content fgw-modal-content\" id=\"modal\">" +
    "           " +
    "           </div>" +
    "       </form>" +
    "    </div>" +
    "</div>";



function getModal(loading, modalSize, modalWidth,force) {
    var modalComponents = "#modal-components";
    var $modalComponents = $(modalComponents);

    if ($modalComponents.length === 0) {

        if (!modalSize) {
            modalSize = "";
        } else if (modalSize === "lg") {
            modalSize = "modal-lg";
        } else if (modalSize === "sm") {
            modalSize = "modal-sm";
        } else if (modalSize === "md") {
            modalSize = "modal-md";
        }

        if (!modalWidth) {
            modalWidth = "";
        } else {
            modalWidth = "style='width:" + modalWidth + "'"
        }


        modal = modal.replace("[MODAL-SIZE]", modalSize);
        modal = modal.replace("[MODAL-WIDTH]", modalWidth);

        $("body").append(modal);

        $modalComponents = $(modalComponents);
    }

    if (loading) {
        setModalContent("    <div style=\"text-align: center; margin-bottom: 100px\" class=\"row\">\n" +
            "        <div class=\"col-md-12\">\n" +
            "            <i class=\"fa fa-2x fa-circle-o-notch fa-spin\" style=\"color: rgba(0,0,0,0.2); margin-top: 50px\"></i>\n" +
            "        </div>\n" +
            "    </div>");
    }

    return $modalComponents;
}

function getFormData($form){
    var unindexed_array = $form.serializeArray();
    var indexed_array = {};

    $.map(unindexed_array, function(n, i){

        if(indexed_array[n['name']]){

            if(typeof indexed_array[n['name']] !== "object"){
                indexed_array[n['name']] = [indexed_array[n['name']]];
            }

            indexed_array[n['name']].push(n['value']);
            return;
        }
        indexed_array[n['name']] = n['value'];
    });

    return indexed_array;
}

function setModalContent(body, title, closeBtn, saveBtn, params) {
    var $modalComponents = $("#modal-components");
    var content = "";

    if (title) {
        content += "<div class=\"modal-header\">\n" +
            "        <button type=\"button\" class=\"close\" data-dismiss=\"modal\">&times;</button>\n" +
            "        <h4 class=\"modal-title\">" + title + "</h4>\n" +
            "      </div>";
    }

    if (body) {
        content += "<div class=\"modal-body\">\n" +
            "        " + body +
            "      </div>";
    }

    if (closeBtn) {
        content += "<div class=\"modal-footer\">\n" +
            "        <button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Fechar</button>\n";

        if (saveBtn) {
            if (saveBtn === true) {
                saveBtn = "Salvar";
            }
            var onclickEvent = "";

            if(typeof saveBtn === "function"){
                var paramsEncoded = JSON.stringify(params);
                onclickEvent = `type='button' onclick='(${saveBtn})(${paramsEncoded})'`;
                saveBtn = "Salvar";
            }


            content += "<button "+onclickEvent+" class=\"btn btn-primary components-modal-submit-btn\" ><i class='fa fa-save'/> " + saveBtn + "</button>\n";
        }

        content += "      </div>";
    }

    $modalComponents.find(".fgw-modal-content").html(content);


    return $modalComponents;
}

function getUrl(url, data, callback,ms = null) {
    if (!data) {
        data = {};
    }


    if (url.indexOf(".asp") === -1) {
        if (ms=="integracaolaboratorial")
        {
            url = labServiceURL + url;
        }
        else
        {
            url = domain + url;
        }
        

    }

	var token="";
	if(localStorage.getItem("tk")){
		token= localStorage.getItem("tk")
	}
	$.ajaxSetup({
        headers: { 'x-access-token': token }
    });

	$.ajax({
		type: 'GET',
		url: url,
		data: data,
		//OR
		//beforeSend: function(xhr) {
		//  xhr.setRequestHeader("My-First-Header", "first value");
		//  xhr.setRequestHeader("My-Second-Header", "second value");
		//}
        error: function(data) {
            if (callback) {
                callback("ERROR");
            }
        }
	}).done(function(data) {
		if (callback) {
            callback(data);
        }
    });
}

function postUrl(url, data, callback) {
    if (!data) {
        data = {};
    }

    if (url.indexOf(".asp") === -1) {
        url = domain + url;

    }

    var token="";
    if(localStorage.getItem("tk")){
        token= localStorage.getItem("tk")
    }

    $.ajax({
        type: 'POST',
        url: url,
        data: data,
        headers: {
            "x-access-token":token
        }
        //OR
        //beforeSend: function(xhr) {
        //  xhr.setRequestHeader("My-First-Header", "first value");
        //  xhr.setRequestHeader("My-Second-Header", "second value");
        //}
    }).done(function(data) {
        if (callback) {
            callback(data);
        }}).fail(function(xhr, textStatus, error) {
            //Ajax request failed.
            var mensagem  = error;
            var data = {success:false, message:mensagem};
            callback(data);
      });
}

function openModal(data, title, closeBtn, saveBtn, modalSize) {
    if (!modalSize) {
        modalSize = "lg";
    }

    var $modal = getModal(true, modalSize);
    $modal.modal("show");
    setModalContent(data, title, closeBtn, saveBtn);
}

function openComponentsModal(url, params, title, closeBtn, saveBtn, modalSize, modalWidth) {
    if (!modalSize) {
        modalSize = "lg";
    }

    var $modal = getModal(true, modalSize, modalWidth);
    $modal.modal("show");

    if (url.indexOf(".asp") === -1) {
        if (params.microservico === 'integracaolaboratorial')
        {
            url = labServiceURL + url;
        }
        else
        {
            url = domain + url;
        }
    }

	var token="";
	if(localStorage.getItem("tk")){
		token= localStorage.getItem("tk")
	}

	$.ajax({
		type: 'GET',
		url: url,
		data: params,
		headers: {
			"x-access-token":token
		}
		//OR
		//beforeSend: function(xhr) {
		//  xhr.setRequestHeader("My-First-Header", "first value");
		//  xhr.setRequestHeader("My-Second-Header", "second value");
		//}
	}).done(function(data) {
        var $modal = setModalContent(data, title, closeBtn, saveBtn, params);

        setTimeout(function () {
            setListeners($modal)
        }, modalTimeout);
	}).fail(function(xhr, textStatus, error) {
        showMessageDialog("Ocorreu um erro. Tente novamente mais tarde.", "error");
        closeComponentsModal();
    });
}

function openComponentsModalPost(url, params, title, closeBtn, saveBtn, modalSize, modalWidth) {
    if (!modalSize) {
        modalSize = "lg";
    }

    var $modal = getModal(true, modalSize, modalWidth);
    $modal.modal("show");

    if (url.indexOf(".asp") === -1) {
        url = domain + url;
    }

    var token="";
    if(localStorage.getItem("tk")){
        token= localStorage.getItem("tk")
    }

    $.ajax({
        type: 'POST',
        url: url,
        data: params,
        headers: {
            "x-access-token":token
        }
    }).done(function(data) {
        var $modal = setModalContent(data, title, closeBtn, saveBtn, params);

        setTimeout(function () {
            setListeners($modal)
        }, modalTimeout);
    }).fail(function(xhr, textStatus, error) {
        showMessageDialog("Ocorreu um erro. Tente novamente mais tarde.", "error");
        closeComponentsModal();
    });
}

function setListeners($modal) {
    $(".components-modal-submit-btn", $modal).click(function () {
        var $btn = $(this);

        setTimeout(function () {
            $btn.attr("disabled", true);
            $btn.find("i").removeClass();
            $btn.find("i").addClass("fa fa-circle-o-notch fa-spin");
        }, 100);
    });

    $modal.on('hidden.bs.modal', function () {
        $(this).remove()
    });

    if (typeof initComponents === "function") {
        initComponents($modal);
    }
}

function getComponentUrl(url){
	var tk = localStorage.getItem("tk");

	return domain + url +	"?tk="+tk
}

function get$ComponentsForm(action) {
    var $form = $("#form-components");

    if (action) {
        $form.attr("action", action);
    }

    return $form;
}

function closeComponentsModal() {
    var $modal = getModal(false);

    $modal.modal('hide');
}

const notifyEvent = ({description, moduleName, criticity = 1}) => {
    //gravar no analytics
    try{
        ga('send', 'event', 'UserError', moduleName, description);
    }catch(e){
        console.error("Erro ao registrar evento GA:"+e)
    }
}

function showMessageDialog(message, messageType, title, delay=3000) {
    if (!messageType) {
        messageType = "danger";
    }

    if (!delay) {
        delay = 3000;
    }

    var $modal = $("#form-components");

    if ($modal) {
        setTimeout(function () {
            $(".components-modal-submit-btn", $modal).attr("disabled", false);
        }, 200);
    }

    if (!title) {
        if (messageType === "danger") {
            title = "Ocorreu um erro!"
        } else if (messageType === "success") {
            title = "Sucesso!"
        } else if (messageType === "warning") {
            title = "Atenção!"
        }
    }

    new PNotify({
        title: title,
        text: message,
        type: messageType,
        delay: delay
    });
}

function authenticate(u, l = false, cupom="") {
    getUrl("auth", {l: l,_u: u, _p: cupom}, function(data) {
        if(data.success==true){
            $.post("confAut.asp", data);

            localStorage.setItem("tk", data.t);


            $.ajaxSetup({
                headers: { 'x-access-token': data.t }
            });


        }
    });
}

function replicarRegistro(id,tabela){
    $.post("ReplicarRegistros.asp", {id,tabela}, function(data){
        $("#importa-replicar").html(data);
        $('.multisel').multiselect({
            includeSelectAllOption: true,
            enableFiltering: true,
            numberDisplayed: 1,
        });
    });
}

function abrirSelecaoLaboratorio(vartabela, varid, versao){
    if (versao !='2')
    {
        openComponentsModal("labs-integration/modal-lab-select", {microservico:'x', tabela:vartabela, id: varid },'',false,false,'md');
    }
    else
    {
        openComponentsModal("labs-integration/modal-lab-select", {microservico:'integracaolaboratorial', tabela:vartabela, id: varid },'',false,false,'md');
    }
}

function abrirSolicitacao(varid, versao){
    if (versao !='2')
    {
        openComponentsModal("labs-integration/modal-detalhes-solicitacao", {microservico:'x', id: varid },'',false,false,'md');
    }
    else
    {
        openComponentsModal("labs-integration/modal-detalhes-solicitacao", {microservico:'integracaolaboratorial', id: varid },'',false,false,'md');
    }
}

const uploadProfilePic = async ({userId, db, table, content, contentType, elem = false}) => {
    let response = false;
    let enpoint = domain + "file/perfil/uploadPerfilFile";

    if (contentType === "form") {
        let objct = new FormData();
        objct.append('userType', table);
        objct.append('userId', userId);
        objct.append('licenca', db);
        objct.append('upload_file', content);
        objct.append('folder_name', "Perfil");

        response = await $.ajax({
            url: enpoint,
            type: 'POST',
            processData: false,
            contentType: false,
            data: objct,
            // Now you should be able to do this:
            mimeType: 'multipart/form-data',    //Property added in 1.5.1
        });

    }else{

        response = await jQuery.ajax({
            url: enpoint,
            type: 'post',
            dataType: 'json',
            data: JSON.stringify(content),
            beforeSend:function () {
                $('#divAvatar').show();
            }
        });

        $('#divAvatar').show();
        $('#divAvatar video').hide();
        $('#divDisplayFoto').css('display','block');
        $("#take-photo").hide();
        $("#cancelar").hide();

    }

    if (elem) {
        elem.attr("src", response.url);
    }

    return response;
}
  
const recordLog = async (
    {
        category,
        licenseId,
        userId,
        oldData,
        newData,
        event
    }) => {

        $.ajax({
            url: `https://galahad.feegow.com/logs?tk=${localStorage.getItem("tk")}`,
            method: 'POST',
            dataType: 'json',
            contentType: 'application/json',
            data:
                JSON.stringify({
                    "licenseId": licenseId,
                    "type": "event",
                    "category": category,
                    "event": event,
                    "userId": userId,
                    "dateTime": (new Date()).toISOString(),
                    "payload": {
                        "oldData": oldData,
                        "newData": newData
                    },
                    "request": {
                        "url": window.location.href
                    }
                }),
            success:function(data) {
                
            },
            error: function (xhr, statustext, thrownError) {
               
            }
        });
    }

const doApiRequest = async (
    {
        url,
        params,
        method="get"
    }) => {


    return new Promise(function (resolve, reject) {
        $.get(api + url, params, function (data) {
            resolve({
                success: true,
                data: data,
                params: params
            });
        }).error(function (err) {
            reject({
                success: false,
                error: err
            })
        });
    })
};

