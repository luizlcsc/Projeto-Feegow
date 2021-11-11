<!--#include file="connect.asp"-->
<%
set p = db.execute("select * from profissionais where id="&req("ProfissionalID"))
%>
<div class="modal-header">
    <h4 class="modal-title">
        <i class='far fa-info-circle'></i> Informa&ccedil;&otilde;es do Profissional: <%= p("NomeProfissional") %>
    </h4>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">

            <%
        if not p.eof then
            %>

            <%
            response.write( p("ObsAgenda") )
        end if
        %>
        </div>
        <%
        if aut("|profissionaisV|")=1 then
        %>
        <div class="col-md-12 text-left">
            Telefones:
            <%= p("Tel1") %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= p("Tel2") %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= p("Cel1") %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%= p("Cel2") %>
        </div>
        <%end if%>
    </div>
</div>
<div class="modal-footer">
    <div class="col-md-2 col-md-offset-10">
        <button type="button" class="btn btn-default btn-block" onclick="$('#modal-table').modal('hide')">Fechar</button>
    </div>
</div>