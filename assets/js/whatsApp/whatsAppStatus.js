$(document).ready(function(){

    if(localStorage.getItem('Admin') == "true")
    {
        runWhatsAppTest()
    }

});

function runWhatsAppTest(){
    if(!localStorage.getItem('whatsAppStatus'))
    {
        return whatsAppConnection();
    }
    return footerWhatsapButton();
}
function whatsAppConnection(){
    $.ajax({
        type:"GET",
        url: domain + "chat-pro/get-status",
        success:function(data){
            if(data.connected == true){
                whatsAppStatusTrue();
                localStorage.setItem('whatsAppStatus',true);
                return true;
            }
            localStorage.setItem('whatsAppStatus',false);
            whatsAppStatusFalse();
        },
        error: function (data){
            whatsAppStatusFalse();
        }
    });
}
function footerWhatsapButton(){
    if(localStorage.getItem('whatsAppStatus')=="true")
    {
        whatsAppStatusTrue()
        return;
    }
    whatsAppStatusFalse();
    return;
}

function whatsAppStatusTrue(){
    $("#footer-whats").css({"background-color":"#70ca63"});
    $("#footer-whats").attr("data-original-title","Conectado!");
}

function whatsAppStatusFalse(){
    new PNotify({
        title: 'ALERTA!',
        text: 'Atenção: Sua conta do WhatsApp não está conectada!<br />' +
            '<a onclick="location.href=\'?P=OutrasConfiguracoes&Pers=1&whatsApp=true\'"  style="color:#FFFFFF;cursor:pointer;font-weight: bolder;"><span class="fa fa-whatsapp" style="margin-right: 15px"></span>Clique aqui para conectar!\n' +'</a>',
        type: 'danger',
        delay: 20000
    });
}