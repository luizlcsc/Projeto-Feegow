<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<style type="text/css">
.tags, .chosen-container {
	width:100%!important;
}
.select-group{
	background: none; 
	border: none; 
	padding: 0;
	margin: 0; 
	height: 16px;
}
  .table-absolute{
    padding: 10px;
    background: #ffffff;
    border: #dfdfdf;
    border-radius: 10px;
    position: absolute;
    z-index: 1000;
  }
  .table-absolute-content{
      overflow: auto;
      max-width: 600px;
      max-height:200px;
  }
</style>
<div class="app" style="padding-top: 11px;">
<i style="text-align: center; margin: 30px;" class="fa fa-spin fa-spinner"></i>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/vue/2.5.16/vue.min.js"></script>
<script type="text/javascript">
    getUrl("labs-integration/conferencia-de-amostras",{}, function(data) {
        $(".app").hide();
        $(".app").html(data);
        $(".app").fadeIn('slow');
    });

</script>