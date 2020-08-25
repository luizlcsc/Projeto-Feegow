<script language="javascript">
function guiaTISS(T, I, ConvenioID){
    if(T == 'GuiaHonorarios'){
        window.open("guiaHonorariosPrint.asp?I="+I, '_blank');
        return ;
    }

	$.ajax({
	   type:"GET",
	   url:"modalGuiaTISS.asp?T="+T+"&I="+I+"&ConvenioID="+ConvenioID,
	   success: (suc) => {
		$("#modal").html(suc);
		$("#modal-table").modal("show");
	   }
	   ,error: (err) => {
        lert("Preencha todos os campos obrigatórios")
	   }
   });
}
</script>