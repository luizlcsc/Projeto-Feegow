<!--#include file="connect.asp"-->
<!--#include file="DefaultForm.asp"-->
<%
tableName=req("P")
id=req("I")

call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("SELECT * FROM contasbancarias WHERE id="&id)

%>
<%=header(req("P"), "Cadastro de Conta Corrente", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<form method="post" id="frm" name="frm" action="save.asp">
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
    <input type="hidden" name="AssociacaoID" value="<%=reg("AssociacaoID")%>">
    <input type="hidden" name="ContaID" value="<%=reg("ContaID")%>">

    <div class="row">
        <div class="col-md-12">
            <br>
            <div class="panel">
                <div class="panel-body">
                    <%'=quickField("text", "Descricao", "Descrição do modelo", 3, "", "", "", "")%>
                    <%=quickField("simpleSelect", "BancoID", "Banco", 2, reg("BancoID"), "select id, CONCAT(BankNumber, ' - ', BankName) BankName FROM sys_financialbanks where sysActive=1 order by BankName", "BankName", "")%>
                    <%=quickField("text", "Agencia", "Agência (sem dígito)", 3, reg("Agencia"), "", "", " maxlength='4' ")%>
                    <%=quickField("text", "Conta", "Conta", 3, reg("Conta"), "", "", "")%>
                    <%=quickField("text", "DAC", "Dígito", 1, reg("DAC"), "", "", "")%>
                    <div class="col-md-3">
                        <%=selectInsertCA("Proprietário", "Proprietario", reg("AssociacaoID")&"_"&reg("ContaID"), "5, 8, 2, 4", "", " ", "")%>
                    </div>
                </div>
            </div>
        </div>
    </div>
</form>
<script type="text/javascript">
    <%call formSave("frm", "save", "")%>

    $("#Proprietario").change(function() {
        var valSplit = $(this).val().split("_");

        var associationId = valSplit[0];
        var accountId = valSplit[1];

        $("input[name='ContaID']").val(accountId);
        $("input[name='AssociacaoID']").val(associationId);

    });

    $("#Salvar").click(function() {
      $("#frm").submit();
    })
</script>
