<!--#include file="connect.asp"-->
<%
Acao = req("A")
id = req("I")
if Acao="I" then
    Response.write("")
    if ref("bPacienteID") = "" or ref("bProcedimentoID") = "" then
        Response.write("<div class='alert alert-warning'>Selecione os campos para adicionar ao carrinho</div>")
    else
       db.execute("insert into agendacarrinho (PacienteID, TabelaID, ProcedimentoID, ComplementoID, Zona, EspecialidadeID, EspecializacaoID, ProfissionalID, sysUser) values ("& treatvalnull(ref("bPacienteID")) &", "& treatvalnull(ref("bageTabela")) &", "& treatvalnull(ref("bProcedimentoID")) &", "& treatvalnull(ref("bComplementoID")) &", '"& ref("Zona") &"', "& treatvalnull(ref("bEspecialidadeID")) &", "& treatvalnull(ref("bSubespecialidadeID")) &", "& treatvalnull(ref("bProfissionalID")) &", "& session("User") &")")
    end if
end if
if Acao="X" then
    db.execute("update agendacarrinho SET Arquivado=NOW() WHERE id="& id)
end if
if Acao="ALL" then 
    db.execute("update agendacarrinho SET Arquivado=NOW() WHERE sysUser="& session("User"))
end if
%>

<table class="table table-condensed table-bordered table-hover">
    <thead>
        <tr class="system">
            <th colspan="10"><i class="far fa-calendar"></i> 0 procedimentos selecionados</th>
        </tr>
        <%
        set cart = db.execute("select ac.AgendamentoID,ac.id, proc.NomeProcedimento, comp.NomeComplemento, prof.NomeProfissional, ac.Zona, a.Data, a.Hora FROM agendacarrinho ac LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID LEFT JOIN complementos comp ON comp.id=ac.ComplementoID LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID WHERE ac.sysUser="& session("User") &" and isnull(ac.Arquivado)")
        if not cart.eof then
        %>
        <tr>
            <th>Procedimento</th>
            <th>Complemento</th>
            <th>Executor</th>
            <th>Local</th>
            <th>Data</th>
            <th>Hora</th>
            <th>À vista</th>
            <th>3x</th>
            <th>6x</th>
            <th width="1%"></th>
        </tr>
        <%
            while not cart.eof
                if not isnull(cart("AgendamentoID")) then
                    set AgendamentoSQL = db.execute("SELECT loc.NomeLocal, a.ValorPlano FROM agendamentos a LEFT JOIN locais loc ON loc.id=a.LocalID WHERE a.id="&cart("AgendamentoID"))
                    if not AgendamentoSQL.eof then
                        AVista = fn(AgendamentoSQL("ValorPlano"))
                        NomeLocal = AgendamentoSQL("NomeLocal")
                    end if
                end if
                %>
                <tr>
                    <td><%= cart("NomeProcedimento") %></td>
                    <td><%= cart("NomeComplemento") %></td>
                    <td><%= cart("NomeProfissional") %></td>
                    <td><%= NomeLocal %></td>
                    <td><%= cart("Data") %></td>
                    <td><%= cart("Hora") %></td>
                    <td><%= AVista %></td>
                    <td><%'= cart("") %></td>
                    <td><%'= cart("") %></td>
                    <td><button class="btn btn-xs btn-danger" onclick="cart('X', <%= cart("id") %>)" type="button"><i class="far fa-remove"></i></button></td>
                </tr>
                <%
            cart.movenext
            wend
            cart.close
            set cart = nothing
        end if
        %>
    </thead>
</table>
