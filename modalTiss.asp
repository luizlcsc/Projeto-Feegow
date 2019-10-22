<script language="javascript">
function guiaTISS(T, I, ConvenioID){
    if(T == 'GuiaHonorarios'){
        window.open("guiaHonorariosPrint.asp?I="+I, '_blank');
        return ;
    }

	$.ajax({
	   type:"GET",
	   url:"modalGuiaTISS.asp?T="+T+"&I="+I+"&ConvenioID="+ConvenioID,
	   success:function(data){
		   $("#modal").html(data);
		   $("#modal-table").modal("show");
	   },error:function(data){
            alert("Preencha todos os campos obrigatórios")

	   }
   });
}
</script>