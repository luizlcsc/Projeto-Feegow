<!--#include file="connect.asp"-->
<%
if ref("De")<>"" then
    De = ref("De")
else
    De = date()-30
end if
if ref("Ate")<>"" then
    Ate = ref("Ate")
else
    Ate = date()
end if
%>
<table class="table table-condensed table-hover">
    <thead>
        <tr>
            <th width="1%"></th>
            <th>Data</th>
            <th>Prev. Entrega</th>
            <th>Paciente</th>
            <th>Profissional</th>
            <th>Procedimento</th>
            <th>Convênio</th>
            <th>Status</th>
            <th width="1%"></th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
    <%
    set pProcsLaudar = db.execute("select group_concat(id) ProcsLaudar from procedimentos WHERE Laudo AND Ativo='on'")
    procsLaudar = pProcsLaudar("ProcsLaudar")
    
    if isnull(procsLaudar) then
        %>
        <tr>
            <td colspan="9">
                <em>Nenhum procedimento com laudo habilitado. Habilite a opção de laudo no cadastro dos procedimentos em que deseja utilizar este recurso.</em>
            </td>
        </tr>
        <%
    else
        if ref("ProcedimentoID")<>"0" then
            if instr(ref("ProcedimentoID"), "G")=0 then
                sqlProcP = " AND ii.ItemID="& ref("ProcedimentoID") &" "
                sqlProcGS = " AND gps.ProcedimentoID="& ref("ProcedimentoID") &" "
            else
                set gp = db.execute("select group_concat(id) Procedimentos from procedimentos where Laudo=1 AND GrupoID="& replace(ref("ProcedimentoID"), "G", ""))
                Procedimentos = gp("Procedimentos") &""
                if Procedimentos="" then
                    Procedimentos = 0
                end if
                sqlProcP = " AND ii.ItemID IN("& Procedimentos &") "
                sqlProcGS = " AND gps.ProcedimentoID IN("& Procedimentos &") "
            end if
        end if
        if ref("PacienteID")<>"" then
            sqlPacP = " AND i.AccountID="& ref("PacienteID") &" "
            sqlPacGS = " AND gs.PacienteID="& ref("PacienteID") &" "
        end if

        sql = "SELECT t.id IDTabela, t.Tabela, t.DataExecucao, t.PacienteID, t.NomeConvenio, t.ProcedimentoID, proc.DiasLaudo, proc.NomeProcedimento, prof.NomeProfissional, pac.NomePaciente FROM ("&_ 
            " SELECT ii.id, 'itensinvoice' Tabela, ii.DataExecucao, ii.ItemID ProcedimentoID, i.AccountID PacienteID, ii.ProfissionalID, 'Particular' NomeConvenio FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ii.Tipo='S' AND ii.Executado='S' AND ii.ItemID IN ("& procsLaudar &") AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & sqlProcP & sqlPacP &_
            " UNION ALL "&_
            " SELECT gps.id, 'tissprocedimentossadt', gps.Data, gps.ProcedimentoID, gs.PacienteID, gps.ProfissionalID, conv.NomeConvenio FROM tissguiasadt gs LEFT JOIN tissprocedimentossadt gps ON gps.GuiaID=gs.id LEFT JOIN convenios conv ON conv.id=gs.ConvenioID WHERE gps.ProcedimentoID IN("& procsLaudar &") AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & sqlProcGS & sqlPacGS &_
            ") t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN profissionais prof ON prof.id=t.ProfissionalID"

        'response.write( sql )

        set ii = db.execute( sql )
        while not ii.eof
            Status = ""
            DiasLaudo = ii("DiasLaudo")
            DataExecucao = ii("DataExecucao")
            Tabela = ii("Tabela")
            IDTabela = ii("IDTabela")
            ProcedimentoID = ii("ProcedimentoID")
            PacienteID = ii("PacienteID")
            

            Previsao = dateAdd("d", DiasLaudo, DataExecucao)

            set vca = db.execute("select l.id, ls.Status, l.PrevisaoEntrega from laudos l LEFT JOIN laudostatus ls ON ls.id=l.StatusID where l.Tabela='"& Tabela &"' and l.IDTabela="& IDTabela)
            if not vca.eof then
                Status = vca("Status")
                Previsao = vca("PrevisaoEntrega")
                IDLaudo = vca("id")
                link = "I="& IDLaudo
            else
                link = "T="& Tabela &"&Pac="& PacienteID &"&IDT="& IDTabela &"&Proc="& ProcedimentoID &"&E="& DataExecucao
                Status = "Pendente"
            end if
            %>
            <tr>
                <td><input type="checkbox" /></td>
                <td><%= DataExecucao %></td>
                <td><%= Previsao %></td>
                <td><%= ii("NomePaciente") %></td>
                <td><%= ii("NomeProfissional") %></td>
                <td><%= ii("NomeProcedimento") %></td>
                <td><%= ii("NomeConvenio") %></td>
                <td><%= Status %></td>
                <td><a class="btn btn-xs btn-success" href="./?P=Laudo&Pers=1&<%= link %>"><i class="fa fa-edit"></i></a></td>
                <td><button class="btn btn-xs btn-info"><i class="fa fa-print"></i></button></td>
            </tr>
            <%
        ii.movenext
        wend
        ii.close
        set ii = nothing
    end if
    %>
    </tbody>
</table>
