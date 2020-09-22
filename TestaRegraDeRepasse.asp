<!--#include file="connect.asp"-->
<%
ID = req("I")
Tabela = req("Tabela")


if Tabela="itensinvoice" then
    set AtendimentoSQL = db.execute("SELECT ")
end if



%>
<br>
<div class="panel">
    <div class="panel-body">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Especialidade</th>
                    <th>Executante</th>
                    <th>Forma de pagamento</th>
                    <th>Tabela Particular</th>
                    <th>Unidade</th>
                    <th>Procedimento</th>
                    <th>Grupo de procedimento</th>
                    <th>Convênio</th>
                    <th>Dia da Semana</th>
                </tr>
            </thead>
            <tbody>
                <%
                while not
                %>
            </tbody>
        </table>
    </div>
</div>