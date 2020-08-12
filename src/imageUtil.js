const deleteSignature = async (profID) => {
    let response = false;
    let enpoint = "./Assinatura.asp?ProfissionalID=" + profID + "&X=S";


    response = await $.ajax({
        url: enpoint,
        type: 'GET',
        processData: false,
        contentType: false,
        success:function (data){
            $("#iframeDropZone").show();
            $("#assinatura-img").attr("src","");
            signature();
        },
        error:function (data){
            console.log(data);
        }
    });
}


const signature = () => {
    if($("#assinatura-img").attr("src") == "")
    {
        $("#iframeDropZone").show();
        $("#buttonDeleteSignature").hide();
    }
    if($("#assinatura-img").attr("src") != "")
    {
        $("#iframeDropZone").hide();
        $("#buttonDeleteSignature").show();
    }
}


$(document).ready(function () {
    signature();
})