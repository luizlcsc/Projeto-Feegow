$(document).ready(function(){


});
function getProfilePic(userId,db,table,isFunc = false)
{

    let objct = new FormData();
    objct.append('userId',userId);
    objct.append('licenca' ,db);
    objct.append('folder_name' ,"Perfil");
    objct.append('userType' ,table);
    let image = '';
    //
    if(localStorage.getItem('perfilImg'))
    {
        image = localStorage.getItem('perfilImg');
        $('li a #avatarFoto').attr('src',image);
        if(table == 'profissionais')
        {
            
            if(isFunc == true){

                $('#divDisplayFoto #avatarFoto').attr('src',image);
            }

        }else{
            $('#divDisplayFoto #avatarFoto').attr('src',image);
        }
        return false;
    }
    $.ajax(
        {
            url: domain + "api/image/perfil",
            type: 'POST',
            processData: false,
            contentType: false,
            data: objct,
            // Now you should be able to do this:
            success: function (data) {
                image = "https://functions.feegow.com/load-image?licenseId=" + db + "&folder=Perfil&file="+ data +"&type=user"
                localStorage.setItem("perfilImg",image);
                if(table == 'profissionais')
                {
                    $('li a #avatarFoto').attr('src',image);
                    if(isFunc == true){

                        $('#divDisplayFoto #avatarFoto').attr('src',image);
                    }

                }else{
                    $('#divDisplayFoto #avatarFoto').attr('src',image);
                }
            }
        });
}