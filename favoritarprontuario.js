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
                tag.removeClass('fa-star-o').addClass('fa-star').attr('data-favorito', 0);
            }else{
                tag.removeClass('fa-star').addClass('fa-star-o').attr('data-favorito', 1);
            }
        })
    })
})