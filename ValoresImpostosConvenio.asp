<!--#include file="connect.asp"-->
<%
ConvenioID = req("ConvenioID")

IF req("Acao") = "Update" THEN

    sql = "UPDATE convenios SET ISS="&treatvalzero(ref("ISS"))&",PIS="&treatvalzero(ref("PIS"))&",CSSL="&treatvalzero(ref("CSSL"))&",IR="&treatvalzero(ref("IR"))&",COFINS="&treatvalzero(ref("COFINS"))&" WHERE id = "&req("ConvenioID")

    db.execute(sql)
    %>
            new PNotify({
                  title: 'Sucesso!',
                  text: 'Dados atualizados com sucesso.',
                  type: 'success',
                  delay: 500
            });
    <%
    response.end
END IF

set reg = db.execute("SELECT * FROM convenios WHERE id = "&ConvenioID)
%>


<div class="row">
   <%= quickField("text", "ISS", "ISS", 2, fn(reg("ISS")), " input-mask-brl changeImposto" , " ", " ") %>
   <%= quickField("text", "PIS", "PIS", 2, fn(reg("PIS")), " input-mask-brl changeImposto" , "", "") %>
   <%= quickField("text", "CSSL", "CSSL", 2, fn(reg("CSSL")), " input-mask-brl changeImposto" , "", "") %>
   <%= quickField("text", "IR", "IR", 2, fn(reg("IR")), " input-mask-brl changeImposto" , "", "") %>
   <%= quickField("text", "COFINS", "COFINS", 2, fn(reg("COFINS")), " input-mask-brl changeImposto" , "", "") %>
</div>
<script type="text/javascript">


$(".changeImposto").on("change",(event) => {
        $.post("ValoresImpostosConvenio.asp?Acao=Update&ConvenioID=<%=ConvenioID%>", {
               ISS: $("#ISS").val(),
               PIS:  $("#PIS").val(),
               CSSL: $("#CSSL").val(),
               IR: $("#IR").val(),
               COFINS: $("#COFINS").val()
        }, function(data){
               eval(data);
        });
});


<!--#include file="JQueryFunctions.asp"-->
</script>
