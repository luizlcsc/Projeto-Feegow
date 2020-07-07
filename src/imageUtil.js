$(document).ready(function(){


});
function getProfilePic(userId,db,table,isFunc = false)
{
    let objct = new FormData();
    objct.append('userId',userId);
    objct.append('licenca' ,db);
    objct.append('folder_name' ,"Perfil");
    objct.append('userType' ,table);
    $.ajax(
        {
            url: domain + "api/image/perfil",
            type: 'POST',
            processData: false,
            contentType: false,
            data: objct,
            // Now you should be able to do this:
            success: function (data) {
                if(table == 'profissionais')
                {
                    $('li a #avatarFoto').attr('src',data);
                    if(isFunc == true){
                        $('#divDisplayFoto #avatarFoto').attr('src',data);
                    }

                }else{
                    $('#divDisplayFoto #avatarFoto').attr('src',data);
                }

            }
        });
}