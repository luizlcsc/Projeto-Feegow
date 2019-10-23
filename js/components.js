var isProduction = window.location.href.indexOf("clinic.feegow") || window.location.href.indexOf("clinic4.feegow") > 0;
var currentUrl = window.location.href;
var urlSplit = currentUrl.split(".br");
var mainDomain = urlSplit[0] + ".br/";


var env = "production";
if(window.location.href.indexOf('local') == 7){
    env = "local";
}

var domain = null;

switch (env){
    case "local":
        domain = "http://localhost:8000/";
        break;
    case "production":
        domain = "https://app.feegow.com.br/";
        break;
    case "homolog":
        domain = "http://homolog.feegow.com.br/";
        break;
}

var modalTimeout = 1000;

var modal = "<div id=\"modal-components\" class=\"modal fade\" tabindex=\"-1\">" +
    "    <div \[MODAL-WIDTH]\ class=\"modal-dialog [MODAL-SIZE]\"> " +
    "       <form id='form-components' method='post'>" +
    "           <div class=\"modal-content\" id=\"modal\">" +
    "           " +
    "           </div>" +
    "       </form>" +
    "    </div>" +
    "</div>";

    

function getModal(loading, modalSize, modalWidth) {
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

function setModalContent(body, title, closeBtn, saveBtn) {
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

            content += "<button class=\"btn btn-primary components-modal-submit-btn\" >" + saveBtn + "</button>\n";
        }

        content += "      </div>";
    }

    $modalComponents.find(".modal-content").html(content);


    return $modalComponents;
}

function getUrl(url, data, callback) {
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
	}).done(function(data) { 
		if (callback) {
            callback(data);
        }
    })
    .fail(function(data) { 
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
        }
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

function openComponentsModal(url, data, title, closeBtn, saveBtn, modalSize, modalWidth) {
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
		type: 'GET',
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
        var $modal = setModalContent(data, title, closeBtn, saveBtn);

        setTimeout(function () {
            setListeners($modal)
        }, modalTimeout);
	});
}

function setListeners($modal) {
    $(".components-modal-submit-btn", $modal).click(function () {
        var $btn = $(this);

        setTimeout(function () {
            $btn.attr("disabled", true);
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

function showMessageDialog(message, messageType, title, delay) {
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
            title = "ERRO!"
        } else if (messageType === "success") {
            title = "SUCESSO!"
        } else if (messageType === "warning") {
            title = "ATENÇÃO!"
        }
    }

    new PNotify({
        title: title,
        text: message,
        type: messageType,
        delay: delay
    });
}

function authenticate(u) {
    getUrl("auth", {_u: u}, function(data) {
        if(data.success==true){
            $.post("confAut.asp", data);

            localStorage.setItem("tk", data.t);


            $.ajaxSetup({
                headers: { 'x-access-token': data.t }
            });


        }
    });
}