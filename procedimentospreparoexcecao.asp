<!--#include file="connect.asp"-->
<%
ProcedimentoID = req("ProcedimentoID")
PreparoExcecaoID = req("I")
Add = req("Add")
X = req("X")

if Add<>"" and isnumeric(Add) then
    db.execute("insert into procedimentospreparofrase (ExcecaoID, ProcedimentoID, PreparoID) values ("& PreparoExcecaoID &", "& ProcedimentoID &", "& Add &")")
end if

if X<>"" and isnumeric(X) then
    db.execute("delete from procedimentospreparofrase where id="& X)
end if
%>
<div class="row">
    <%= quickfield("simpleSelect", "AddPreparo", "Preparo", 9, "", "select id, Descricao from sys_preparos where sysActive=1 order by Descricao", "Descricao", "") %>
    <div class="col-md-3">
        <button type="button" class="btn btn-success btn-block mt25" onclick="ajxContent('procedimentospreparoexcecao&ProcedimentoID=<%= ProcedimentoID %>&Add='+ $('#AddPreparo').val(), <%= PreparoExcecaoID %>, 1, 'preparoexcecoes');"><i class="far fa-plus"></i> Adicionar</button>
    </div>
</div>
<hr class="short alt" />
<div class="row">
    <div class="col-md-12">
        <table class="table table-condensed table-bordered table-hover table-striped">
            <thead>
                <tr class="info">
                    <th>Preparo</th>
                    <th>Horas</th>
                    <th>Dias</th>
                    <th>Valor Início</th>
                    <th>Valor Final</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                set ex = db.execute("select pef.id, p.Descricao, p.Tipo, pef.Horas, pef.Dias, pef.Inicio, pef.Fim from procedimentospreparofrase pef LEFT JOIN sys_preparos p ON p.id=pef.PreparoID where ProcedimentoID="& ProcedimentoID &" and ExcecaoID="& PreparoExcecaoID &" order by pef.id")
                while not ex.eof
                    disHoras = " disabled "
                    disDias = " disabled "
                    disInicio = " disabled "
                    disFim = " disabled "
                    colspan = 1
                    select case ex("Tipo")
                        case 1
                            colspan = 5
                        case 2
                            disInicio = ""
                            disFim = ""
                        case 3
                            disDias = ""
                        case 4
                            disHoras = ""
                    end select
                    %>
                    <tr>
                        <td colspan="<%= colspan %>"><%= ex("Descricao") %></td>
                        <% if ex("Tipo")<>1 then %>
                        <td><%= quickfield("text", "Horas_"&ex("id"), "", 12, ex("Horas"), " prePar ", "", disHoras ) %></td>
                        <td><%= quickfield("text", "Dias_"&ex("id"), "", 12, ex("Dias"), " prePar ", "", disDias ) %></td>
                        <td><%= quickfield("text", "Inicio_"&ex("id"), "", 12, ex("Inicio"), " prePar ", "", disInicio ) %></td>
                        <td><%= quickfield("text", "Fim_"&ex("id"), "", 12, ex("Fim"), " prePar ", "", disFim ) %></td>
                        <% end if %>
                        <td><button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja apagar esta frase?')) ajxContent('procedimentospreparoexcecao&ProcedimentoID=<%= ProcedimentoID %>&X=<%= ex("id") %>', <%= PreparoExcecaoID %>, 1, 'preparoexcecoes')"><i class="far fa-remove"></i></button></td>
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
        $.post("preparoVal.asp?FraseID=<%= PreparoExcecaoID %>", { Item: $(this).attr("id"), Val: $(this).val() }, function (data) { eval(data) });
    });


<!--#include file="JQueryFunctions.asp"-->
</script>