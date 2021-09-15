<!--#include file="connect.asp"-->

<%
Tipo = req("Tipo")
I = req("I")

if Tipo="I" then
    db.execute("UPDATE buiforms SET TextoPersonalizado='"&ref("TextoPersonalizado")&"' WHERE id="&I)
end if

%>
<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h3 class="lighter blue">Formulário Personalizado</h3>
        </div>

        <div class="col-md-4" style="margin-top: 15px;">
            <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
        </div>
    </div>

</div>
<form method="post" id="frmFormPersonalizado" name="frmFormPersonalizado">
    <div class="modal-body">
        <div class="row">
            <input type="hidden" name="I" id="I" value="<%=req("I")%>" />
            <div class="col-md-9">
            <%
            set getTextoPersonalizado = db.execute("SELECT TextoPersonalizado FROM buiforms WHERE id="&req("I"))
            if not getTextoPersonalizado.eof then
                TextoPersonalizado = getTextoPersonalizado("TextoPersonalizado")
            end if
            call quickField("memo", "TextoPersonalizado", "Texto Personalizado", 12, TextoPersonalizado, "", "", "")

            %>
            <script>
            $(function () {
                CKEDITOR.config.shiftEnterMode= CKEDITOR.ENTER_P;
                CKEDITOR.config.enterMode= CKEDITOR.ENTER_BR;
                CKEDITOR.config.height = 300;
                $('#TextoPersonalizado').ckeditor();
            });
            </script>
            </div>
            <div class="col-md-3">
                <label>Campos para utilizar</label><br />
                <div style="border:#777 1px dotted; height:350px; overflow-x:hidden; overflow-y:scroll">
                    <%
                    set pcampos = db.execute("select id, NomeCampo from buicamposforms where TipoCampoID IN (1, 2, 4, 5, 6, 8) and FormID="&req("I"))
                    while not pcampos.eof
                        %>
                        <input readonly type="text" style="cursor:copy" class="form-control" value="[<%= pcampos("id")&"_"&pcampos("NomeCampo") %>]" id="copy<%= pcampos("id") %>" onclick="myFunction('copy<%= pcampos("id") %>')" />
                        <%
                    pcampos.movenext
                    wend
                    pcampos.close
                    set pcampos = nothing
                        %>
                </div>
            </div>

        </div>
        <br>
    </div>
    <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
    </div>
</form>


<script type="text/javascript">

$(document).ready(function(){
    $("#frmFormPersonalizado").submit(function(){
    	$.post("ConfigFormPersonalizado.asp?Tipo=I&I=<%=req("I")%>", $(this).serialize(), function(data, status){ window.location.reload(); });
    	return false;
    });

});




    function myFunction(i) {
      /* Get the text field */
      var copyText = document.getElementById(i);

      /* Select the text field */
      copyText.select();

      /* Copy the text inside the text field */
      document.execCommand("copy");

      /* Alert the copied text */
    //      alert("Texto copiado: " + copyText.value);
            new PNotify({
            title: '<i class="far fa-copy"></i> Texto copiado!',
            text: copyText.value,
            type: 'success'
        });

    }


<!--#include file="JQueryFunctions.asp"-->
</script>