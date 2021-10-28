$(function(){
    $(".btnfavoritos").on('click', function(){
        var idMedicamento = $(this).attr('data-id');
        var tipo = $(this).attr('data-tipo');
        var favorito = $(this).find("i").attr('data-favorito');
        var tag = $(this).find("i");

        $.post('FavoritarProntuario.asp',{
            id : idMedicamento,
            favorito : favorito,
            tipo : tipo

        }, function(result) {
            if(favorito == 1){
                tag.removeClass('far').addClass('fas').attr('data-favorito', 0);
            }else{
                tag.removeClass('fas').addClass('far').attr('data-favorito', 1);
            }
        })
    })
})