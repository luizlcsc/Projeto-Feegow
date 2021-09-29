<!--#include file="connect.asp"-->
<%
I = req("I")

if I<>"0" then
    set desc = db.execute("select * from repassesdescontos where id="&I)
    if not desc.eof then
        MetodoID = desc("MetodoID")
        Contas = desc("Contas")
        Desconto = desc("Desconto")
        tipoValor = desc("tipoValor")
        De = desc("De")
        Ate = desc("Ate")
    end if
else
    De = 1
    Ate = 1
end if

if req("S")="S" then
    if I="0" then
        db_execute("insert into repassesdescontos (MetodoID, Contas, Desconto, tipoValor, De, Ate) values ("&ref("MetodoID")&", '"&ref("Contas")&"', "&treatvalzero(ref("Desconto"))&", '"&ref("tipoValor")&"', "&treatvalzero(ref("De"))&", "&treatvalzero(ref("Ate"))&")")
    else
        db_execute("update repassesdescontos set MetodoID="&ref("MetodoID")&", Contas='"&ref("Contas")&"', Desconto="&treatvalzero(ref("Desconto"))&", tipoValor='"&ref("tipoValor")&"', De="&treatvalzero(ref("De"))&", Ate="&treatvalzero(ref("Ate"))&" where id="&I)
    end if
    %>
    <script type="text/javascript">
        $("#modal-table").modal("hide");
        ajxContent('repassesDescontos', '', 1, 'repassesDescontos');
    </script>
    <%
end if
%>

<form id="formDR">
    <div class="modal-header">
        <h5>
            Desconto adicional de repasse por forma de recebimento
        </h5>
    </div>
    <div class="modal-body">
        <div class="row">
            <%=quickfield("simpleSelect", "MetodoID", "Método", 3, MetodoID, "select id, PaymentMethod from sys_financialpaymentmethod where id IN(1, 2, 8, 9)", "PaymentMethod", "") %>
            <div class="col-md-3">
                <label>Desconto</label><br />
                <div class="input-group">
				    <%=quickField("text", "Desconto", "", 12, fn(Desconto), " input-mask-brl text-right", "", "")%>
                    <span class="input-group-addon">
                        <select class="select-group" name="tipoValor">
                            <option value="P"<% If tipoValor="P" Then %> selected<% End If %>>%</option>
                            <option value="V"<% If tipoDesconto="V" Then %> selected<% End If %>>R$</option>
                        </select>
                    </span>
                </div>
            </div>
            <%
                classe = ""

                if cint(MetodoID) = 1 then
                    classe = " hidden"
                    de = 1
                    ate = 1
                end if
            %>

            <%=quickfield("number", "De", "Parcelas de", 2&" "&classe, De, "", "", "") %>
            <%=quickfield("number", "Ate", "até", 2&" "&classe, Ate, "", "", "") %>
       </div>
        <hr />
        <%
        arrContas = split("8, 9", ", ")
        for i=0 to ubound(arrContas)
            %>
            <div class="row hidden contas" id="contas<%=arrContas(i) %>">
                <%
                set pcontas = db.execute("select c.id, c.AccountName, c.AccountType, m.id MetodoID from sys_financialcurrentaccounts c left join sys_financialpaymentmethod m on m.AccountTypesC=c.AccountType where m.id="&arrcontas(i))
                while not pcontas.eof
                    %>
                    <div class="col-md-2">
                        <label><input type="checkbox" class="ace" name="Contas" value="|<%=pcontas("id") %>|" <%if instr(Contas, "|" & pcontas("id") & "|") then response.write("checked") end if %> />
                        <span class="lbl"> <%=pcontas("AccountName") %></span></label> &nbsp;
                    </div>
                    <%
                pcontas.movenext
                wend
                pcontas.close
                set pcontas=nothing
                %>
            </div>
            <%
        next
        %>
    </div>
    <div class="modal-footer">
        <button class="btn btn-sm btn-success"><i class="far fa-save"></i> SALVAR</button>
    </div>
</form>

<script type="text/javascript">
    function contas(M){
        $(".contas").addClass("hidden");
        $("#contas"+M).removeClass("hidden");
    }

    contas($("#MetodoID").val());

    $("#MetodoID").change(function(){
        contas($(this).val());
        if($("#MetodoID").val() == '1'){
            $("#De").val(1)
            $("#De").parent().addClass('hidden')
            $("#Ate").val(1)
            $("#Ate").parent().addClass('hidden')
        }else{
            $("#De").parent().removeClass('hidden')
            $("#Ate").parent().removeClass('hidden')
        }
    });

    $("#formDR").submit(function(){
        $.post('repasseDesconto.asp?I=<%=req("I")%>&S=S', $(this).serialize(), function(data){
            $("#modal").html(data);
        });
        return false;
    });

    <!--#include file="JQueryFunctions.asp"-->
</script>