<!--#include file="connect.asp"-->
<%
I = req("i")
PacienteID = req("p")
if I="" then
    set pult = db.execute("select id from pedidossadt order by id desc limit 1")
    if pult.eof then
        I = 1
    else
        I = pult("id")+1
    end if
end if

if ref("Codigo")<>"" then
    set conta = db.execute("select count(id) total from pedidossadtprocedimentos where PedidoID="& I)
    total = ccur(conta("total"))
    if total<5 then
        set vca = db.execute("select id from pedidossadt where id="& I)
        if vca.eof then
            db_execute("insert into pedidossadt (PacienteID, ProfissionalID, Data, sysUser, sysDate, sysActive) values ("& PacienteID &", "& session("idInTable") &", curdate(), "& session("User") &", curdate(), 1)")
        end if

        db_execute("insert into pedidossadtprocedimentos set PedidoID="& I &", TabelaID="& ref("Tabela") &", CodigoProcedimento='"& ref("Codigo") &"', Descricao=(select descricao from cliniccentral.procedimentos where TipoTabela='"& ref("Tabela") &"' AND Codigo='"& ref("Codigo") &"' LIMIT 1)")
    else
        %>
        <div class="alert alert-danger">
            O máximo de permitido por guia é de 5 (cinco) procedimentos. Para inserir uma quantidade maior, crie uma nova guia de solicitação.
        </div>
        <%
    end if
end if

if ref("X")<>"" then
    db_execute("delete from pedidossadtprocedimentos where id="& ref("X"))
end if
%>
<input type="hidden" name="PedidoSADTID" id="PedidoSADTID" value="<%= I %>" />

<table class="table table-condensed table-hover">
    <thead>
        <tr>
            <th width="10%">Código</th>
            <th>Descrição</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
        set pprocs = db.execute("select * from pedidossadtprocedimentos where PedidoID="& I)
            while not pprocs.eof
                %>
                <tr>
                    <td><%= pprocs("CodigoProcedimento") %></td>
                    <td><%= pprocs("Descricao") %></td>
                    <td>
                        <button onclick="xPedidoSADT(<%= pprocs("id") %>)" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button>
                    </td>
                </tr>
                <%
            pprocs.movenext
            wend
            pprocs.close
            set pprocs=nothing
            %>
    </tbody>
</table>
<br>
