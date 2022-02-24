$(document).ready(function(){
    clearLocalStorage();
    if(localStorage.getItem('Admin') == "true")
    {
        runWhatsAppTest()
    }

});
function clearLocalStorage(){
    // Clear on startup if expired
    let hours = 12; // Reset when storage is more than 24hours
    let now = new Date().getTime();
    let setupTime = localStorage.getItem('setupTime');
    if (setupTime == null) {
       return;
    } else {
        if(now-setupTime > hours*60*60*1000) {
            localStorage.removeItem("whatsAppStatus");
            localStorage.removeItem('setupTime');
        }
    }
}

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
        "x-access-token": localStorage.getItem("tk"),
        success:function(data){
            if(data.connected == true){
                whatsAppStatusTrue();
                localStorage.setItem('whatsAppStatus',true);
                localStorage.setItem('setupTime',new Date().getTime());
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