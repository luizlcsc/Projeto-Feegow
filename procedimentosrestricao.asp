<!--#include file="connect.asp"-->
<%
ProcedimentoID = req("I")
Acao = req("A")
Conta = req("Conta")

if Acao="Ex" and Conta<>"" then
    db.execute("insert into procedimentosrestricoesexcecao set Conta='"& Conta &"', ProcedimentoID="& ProcedimentoID)
end if
if Acao="XEx" and Conta<>"" then
    db.execute("delete from procedimentosrestricoesexcecao where Conta='"& Conta &"' and ProcedimentoID="& ProcedimentoID)
end if
%>
<div class="col-md-6">
    <div class="row">
        <div class="col-md-9">
                <%= selectInsertCA("Prestador", "Prestador", "", "5, 2", "", "", "") %>
        </div>
        <div class="col-md-3">
            <button type="button" class="btn btn-success mt25 btn-block" onclick="ajxContent('procedimentosrestricao&A=Ex&Conta='+ $('#Prestador').val(), <%= ProcedimentoID %>, 1, 'divEquipe')"><i class="far fa-plus"></i> Adicionar</button>
        </div>
    </div>
    <hr class="short alt" />
    <div class="row">
        <div class="col-md-12">
            <table class="table table-striped table-hover table-bordered table-condensed">
                <thead>
                    <tr class="info">
                        <th>Nome</th>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr class="linhaCX" onclick="$('.linhaCX').removeClass('system'); $(this).closest('tr').addClass('system')" style="cursor:pointer">
                        <td colspan="2" onclick="ajxContent('procedimentosrestricaoexcecao&ProcedimentoID=<%= ProcedimentoID %>', 0, 1, 'restricaoexcecoes');">RESTRIÇÃO PADRÃO</td>
                    </tr>
                    <%
                    set prepEx = db.execute("select * from procedimentosrestricoesexcecao where ProcedimentoID="& ProcedimentoID)
                    while not prepEx.eof
                        %>
                        <tr class="linhaCX" onclick="$('.linhaCX').removeClass('system'); $(this).closest('tr').addClass('system')" style="cursor:pointer">
                            <td onclick="ajxContent('procedimentosrestricaoexcecao&ProcedimentoID=<%= ProcedimentoID %>', <%= prepEx("id") %>, 1, 'restricaoexcecoes');"><%= accountName(NULL, prepEx("Conta")) %></td>
                            <td>
                                <button type="button" class="btn btn-danger btn-xs" onclick="if(confirm('Tem certeza de que deseja apagar esta exceção e todos as restrições relacionados a elas?')) ajxContent('procedimentosrestricao&A=XEx&Conta=<%= prepEx("Conta") %>', <%= ProcedimentoID %>, 1, 'divEquipe')"><i class="far fa-remove"></i></button>
                            </td>
                        </tr>
                        <%
                    prepEx.movenext
                    wend
                    prepEx.close
                    set prepEx = nothing
                    %>
                </tbody>
            </table>
        </div>
    </div>
</div>



<div class="col-md-6" id="restricaoexcecoes">
    <div class="alert alert-default mt15">
        Selecione ao lado a restrição padrão ou a exceção por prestador desejada.
    </div>
</div>

