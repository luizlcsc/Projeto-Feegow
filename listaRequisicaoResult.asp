<!--#include file="connect.asp"-->
<%

if ref("StatusID")<>"" then
    sqlStatus = " AND t.StatusID='"&ref("StatusID")&"' "
end if

if ref("DataPrazo")<>"" and isdate(ref("DataPrazo")) then
    sqlPrazo = " AND t.DataPrazo<="& mydatenull(ref("DataPrazo")) &" "
end if

if ref("PrioridadeID")<>"" then
    sqlPrioridade = " AND t.PrioridadeID="& treatvalnull(ref("PrioridadeID")) &" "
end if

if ref("SolicitanteID")<>"" and instr(ref("SolicitanteID"), "_")>0 then
    sqlSolicitante = " AND t.SolicitanteID = '"& ref("SolicitanteID") &"' "
end if

%>
<div class="col-md-12">
    <table class="table table-striped table-hover table-bordered table-condensed">
        <thead>
          <tr class="success">
            <th>#</th>
            <th>Abertura</th>
            <th>Prazo</th>
            <th>Status</th>
            <th>Solicitante</th>
            <th>Produtos</th>
            <th>Localização destino</th>
            <th width="1%"></th>
          </tr>
        </thead>
        <tbody>
        <%

        sqlLista = "select t.*, u.Nome, l.NomeLocalizacao, s.NomeStatus from estoque_requisicao t INNER JOIN estoque_requisicao_status s ON s.id=t.StatusID LEFT JOIN produtoslocalizacoes l ON l.id=t.LocalizacaoID LEFT JOIN cliniccentral.licencasusuarios u on u.id=t.sysUser LEFT JOIN estoque_requisicao_status sta on sta.id=t.StatusID WHERE t.sysActive=1 "&sqlPrioridade&sqlPrazo&sqlStatus&sqlSolicitante&" ORDER BY t.sysDate DESC LIMIT 300"

        'response.write( sqlLista )
        set lista = db.execute(sqlLista)
        if lista.eof then
            %>
            <tr>
                <td class="text-center" colspan="7">Nenhuma requisição encontrada com os critérios selecionados.</td>
            </tr>
            <%
        end if
        NumeroTarefas = 0
        while not lista.eof
            set ProdutosSolicitadosSQL = db.execute("SELECT group_concat(concat(' ',p.NomeProduto, ' (',r.Quantidade,'x)'))Produtos FROM estoque_requisicao_produtos r INNER JOIN produtos p ON p.id=r.ProdutoID WHERE r.sysActive=1 AND r.RequisicaoID="&lista("id"))
            if not ProdutosSolicitadosSQL.eof then
                Produtos = ProdutosSolicitadosSQL("Produtos")
            end if

            NumeroTarefas = NumeroTarefas + 1
            Virgula = ""

            Solicitante = lista("Nome")
            %>
            <tr>
                <td><%=lista("id") %></td>
                <td><%=lista("sysDate") %></td>
                <td><%=lista("DataPrazo") %> </td>
                <td><%=lista("NomeStatus") %> </td>
                <td><%=nameInTable(lista("SolicitanteID")) %></td>
                <td><%= Produtos %></td>
                <td><%=lista("NomeLocalizacao") %> </td>
                <td><a href="./?P=Estoque_requisicao&Pers=1&I=<%=lista("id") %>" class="btn btn-success btn-xs"><i class="far fa-edit"></i></a> </td>
            </tr>
            <%
        lista.movenext
        wend
        lista.close
        set lista=nothing
        %>
        </tbody>
    </table>
    <strong><%=NumeroTarefas%> requisições</strong>
</div>