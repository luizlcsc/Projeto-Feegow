<!--#include file="connect.asp"-->
<h3 class="blue">Modelos de Contratos</h3>
<table class="table table-striped table-hover">
    <thead>
        <th>Nome do Modelo</th>
        <th width="1%"></th>
    </thead>
    <tbody>
        <%
        set pcont = db.execute("select * from contratosmodelos")
        %>
    </tbody>
</table>