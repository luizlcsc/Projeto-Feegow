<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
        <iframe width="100%" height="600px" src="printForm.asp?PacienteID=<%=request.QueryString("PacienteID")%>&ModeloID=<%=request.QueryString("ModeloID")%>&FormID=<%=request.QueryString("FormID")%>" id="ImpressaoFicha" name="ImpressaoFicha" frameborder="0"></iframe>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
</div>
