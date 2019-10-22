<div id="modal-table" class="modal fade" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content" id="modal" style="width:860px; margin-left:-130px;">
        <iframe frameborder="0" width="100%" height="700" src="upload_crop.php?MedicoID=30"></iframe>
        </div><!-- /.modal-content -->
    </div><!-- /.modal-dialog -->
</div>

<button id="AlterarFoto" type="button" class="btn">Clique aqui para alterar sua foto</button>

<script>
$("#AlterarFoto").click(function(){
	$("#modal-table").modal("show");
})
</script>