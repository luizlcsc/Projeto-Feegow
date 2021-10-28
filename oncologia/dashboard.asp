<!--#include file="../connect.asp"-->
<!--
<div class="app" style="padding-top: 11px;">

<i style="text-align: center; margin: 30px;" class="far fa-spin fa-spinner"></i>
</div>
-->
<style>
    #filtros{
        background-color:grey;
        height:10vh;
    }
    #tabela{
        height:60vh;
        padding:0
    }
    .tableActionBtns{
        display: flex;
        justify-content: flex-end;
        align-items: center;
    }
</style>

<div id="app" style="padding: 30px;" class="container-fluid">
    <div id="filtros" class='col-md-12'></div>
    <div id="tabela" class='panel col-md-12 mt10'>
        <div class="panel-heading tableActionBtns">
            <button class='btn btn-xs btn-primary' id='max'><i class="far fa-arrows" aria-hidden="true" style="transform: rotate(45deg);"></i></button>
        </div>
    </div>

</div>

<!--
<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">
    getUrl("oncologia/", {}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });
</script>
-->

<script>
    var originalPos = {}
    const startPage = () =>{
        $('#toggle_sidemenu_l').click()

        $(".crumb-active a").html("Protocolos");
        $(".crumb-link").removeClass("hidden");
        $(".crumb-link").addClass("hidden");
        $(".crumb-icon").addClass("hidden");
    }

    const maximize = () =>{
        let seletor = $('#tabela')
        var clone = $(seletor).clone().addClass('active');
        var clone = $(seletor).clone().removeClass('mt10');
        var pos = $(seletor).position();
        originalPos = pos
        $("#main").prepend(clone);
        
        console.log(pos);

        clone.css({
            'position' : 'absolute', 
            left: pos.left + 'px', 
            top: pos.top + 'px',
            'z-index': '9999',
            }).animate({
            width: '100%', 
            height : '100vh',
            top: 0,
            left: 0,
            'margin-top':'0!important'
        },300);
        clone.find('.tableActionBtns button').attr('id','max2')

        $('#max2').click(function(){
            let time = 300
            $(this).parent().parent().animate({
                opacity:0
            },time)
            setTimeout(() => {
                $(this).parent().parent().detach()
            }, time);
       })
    }

    $(document).ready(function () {
       startPage()

       $('#max').click(function(){
            maximize()
       })
    });
</script>