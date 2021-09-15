
			<div class="main-container-inner">
				<a class="menu-toggler" id="menu-toggler" href="#">
					<span class="menu-text"></span>
				</a>

				<div class="main-content">
					<div class="page-content">
						<div class="page-header">
							<h1>
								Widgets
								<small>
									<i class="far fa-double-angle-right"></i>
									Draggabble Widget Boxes &amp; Containers
								</small>
							</h1>
						</div><!-- /.page-header -->

						<div class="row">
							<div class="col-xs-12">
								<!-- PAGE CONTENT BEGINS -->
								<div class="row" id="grade">
                                    <%server.execute("widgetContents.asp")%>
								</div>
                            <!-- PAGE CONTENT ENDS -->
							</div><!-- /.col -->
						</div><!-- /.row -->
					</div><!-- /.page-content -->
				</div><!-- /.main-content -->
			</div><!-- /.main-container-inner -->
<script type="text/javascript">
    function drag(){



        // Portlets (boxes)
        $('.widget-container-span').sortable({
            connectWith: '.widget-container-span',
            items: '> .widget-box',
            opacity: 0.8,
            revert: true,
            forceHelperSize: true,
            placeholder: 'widget-placeholder',
            forcePlaceholderSize: true,
            tolerance: 'pointer'
        });

    }

</script>

		<script type="text/javascript">
			
/*$( ".ui-sortable" ).draggable({
stop: function( event, ui ) {alert('oi');}
});*/
//$( ".widget-container-span" ).on( "dragstop", function( event, ui ) {alert('oi');} );
/*$(".widget-container-span").click(function(){
	alert($(this).attr("class"));
});*/


function tam(op, i){
    t = parseInt( $("#w"+i).attr("data-tam") );
    if(op==0){
        nt = t-1;
    }else{
        nt = t+1;
    }
    //alert( 'id='+i + ' \n tam: ' +t +'\n op: '+ op );
    $("#w"+i).removeClass("col-sm-"+t);
    $("#w"+i).addClass("col-sm-"+nt );
    $("#w"+i).attr("data-tam", nt );
    $.post("widgetContents.asp", {html:$("#grade").html()}, function(data){
        $("#grade").html(data);
        drag();
    });
}
</script>
