<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<br>
<div class="panel">
<div class="panel-body">
<form method="post" id="frm" name="frm" action="save.asp">
    <%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

    %>
    <%=header(req("P"), "Cadastro de Kit de Produto", reg("sysActive"), req("I"), req("Pers"), "Follow")%>





    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
    <div class="row">
        <div class="col-md-12">
            <div class="row">
                <%=quickField("text", "NomeKit", "Nome do Kit", 8, reg("NomeKit"), "", "", " required")%>
                <%=quickField("simpleSelect", "TabelaID", "Tabela", 4, reg("TabelaID"), "select concat(id, ' - ', Descricao) DescTab, id, descricao from tisstabelas order by Descricao", "DescTab", " empty")%>
            </div>
        </div>
    </div>
    <div class="row">
    <br>
        <div class="col-md-12">
            <%call Subform("produtosdokit", "KitID", req("I"), "frm")%>
        </div>
    </div>
</form>

</div>
</div>

<script type="text/javascript">
    function produtoParametros(LID, PID){
        $.post("produtoparametros.asp?LID="+LID+"&PID="+PID, $("#frm").serialize(), function(data){
            eval(data);
        });
    }


    $(document).ready(function(e) {




        <%call formSave("frm", "save", "$('.btnLancto').removeAttr('disabled');")%>
        });



</script>


<!--#include file="disconnect.asp"-->
