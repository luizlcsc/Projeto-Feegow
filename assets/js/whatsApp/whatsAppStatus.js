$(document).ready(function(){
    window.setInterval(function(){
        whatsAppConnection();
    }, 60000);
    runWhatsAppTest();
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
            if(data.connected === true){
                whatsAppStatusTrue();
                localStorage.setItem('whatsAppStatus',true);
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
    $("#footer-whats").css({"background-color":"red"});
    $("#footer-whats").attr("data-original-title","Desconectado!");
}