<!--#include file="connect.asp"-->
<%
ProcedimentoID = req("ProcedimentoID")
RestricaoExcecaoID = req("I")
Add = req("Add")
X = req("X")

if Add<>"" and isnumeric(Add) then
    db.execute("insert into procedimentosrestricaofrase (ExcecaoID, ProcedimentoID, RestricaoID) values ("& RestricaoExcecaoID &", "& ProcedimentoID &", "& Add &")")
end if

if X<>"" and isnumeric(X) then
    db.execute("delete from procedimentosrestricaofrase where id="& X)
end if
%>
<div class="row">
    <%= quickfield("simpleSelect", "AddRestricao", "Restricao", 9, "", "select id, Descricao from sys_restricoes where sysActive=1 order by Descricao", "Descricao", "") %>
    <div class="col-md-3">
        <button type="button" class="btn btn-success btn-block mt25" onclick="ajxContent('procedimentosrestricaoexcecao&ProcedimentoID=<%= ProcedimentoID %>&Add='+ $('#AddRestricao').val(), <%= RestricaoExcecaoID %>, 1, 'restricaoexcecoes');"><i class="far fa-plus"></i> Adicionar</button>
    </div>
</div>
<hr class="short alt" />
<div class="row">
    <div class="col-md-12">
        <table class="table table-condensed table-bordered table-hover table-striped">
            <thead>
                <tr class="info">
                    <th>Restrição</th>
                    <th>Valor Início</th>
                    <th>Valor Final</th>
                    <th>Restringir</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set ex = db.execute("select pef.id, p.Descricao, p.Tipo, pef.Horas, pef.Dias, pef.Inicio, pef.Fim, pef.Restringir from procedimentosrestricaofrase pef LEFT JOIN sys_restricoes p ON p.id=pef.RestricaoID where ProcedimentoID="& ProcedimentoID &" and ExcecaoID="& RestricaoExcecaoID &" order by pef.id")
                while not ex.eof
                    disHoras = " disabled "
                    disDias = " disabled "
                    disInicio = " disabled "
                    disFim = " disabled "
                    colspan = 1
                    select case ex("Tipo")
                        case 1
                            colspan = 3
                        case 2
                            disInicio = ""
                            disFim = ""
                        case 3
                            disRestringir = ""
                    end select
                    %>
                    <tr>
                        <td colspan="<%= colspan %>"><%= ex("Descricao") %></td>
                        <% if ex("Tipo")<>1 then %>
                        <td><%= quickfield("text", "Inicio_"&ex("id"), "", 12, ex("Inicio"), " prePar ", "", disInicio ) %></td>
                        <td><%= quickfield("text", "Fim_"&ex("id"), "", 12, ex("Fim"), " prePar ", "", disFim ) %></td>
                        <% end if %>
                        <td><%= quickfield("simpleCheckbox", "Restringir_"&ex("id"), "", 12, ex("Restringir"), " prePar ", "", "" ) %></td>
                        <td><button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja apagar esta frase?')) ajxContent('procedimentosrestricaoexcecao&ProcedimentoID=<%= ProcedimentoID %>&X=<%= ex("id") %>', <%= RestricaoExcecaoID %>, 1, 'restricaoexcecoes')"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <%
                ex.movenext
                wend
                ex.close
                set ex = nothing
                %>
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">

    $(".prePar").change(function () {
        $.post("restricaoVal.asp?FraseID=<%= RestricaoExcecaoID %>", { Item: $(this).attr("id"), Val: $(this).val() }, function (data) { eval(data) });
    });


<!--#include file="JQueryFunctions.asp"-->
</script>