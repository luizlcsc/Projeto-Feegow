<script language="javascript">
function guiaTISS(T, I, ConvenioID, LoteID , callback=false){
    if(T == 'GuiaHonorarios'){
        window.open("guiaHonorariosPrint.asp?I="+I, '_blank');
        return ;
    }

	$.ajax({
	   type:"GET",
	   url:"modalGuiaTISS.asp?T="+T+"&I="+I+"&ConvenioID="+ConvenioID+"&LoteID="+LoteID,
	   success: (suc) => {
		$("#modal").html(suc);
		$("#modal-table").modal("show");
		if(typeof callback === "function"){
			$('#modal-table').on('hidden.bs.modal', function (e) {
				callback("true")
			})			
		}
	   }
	   ,error: (err) => {
        alert("Preencha todos os campos obrigatórios")
	   }
   });
}
</script>