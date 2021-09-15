<!--#include file="connect.asp"-->
<!--#include file="Classes/Connection.asp"-->
<%
if ref("Helpdesk")<>"" then
licencaCliente = 5459
set dblicense = newConnection("clinic5459", "")
end if
if ref("De")<>"" then
    sqlDe = " AND t.De="& treatvalnull(ref("De")) &" "
end if
if ref("Responsavel")<>"" then
    sqlResponsavel = " AND p.sysUser="& treatvalnull(ref("Responsavel")) &" "
end if
if ref("Para")<>"" then
    sqlPara = " AND t.Para LIKE '%|"& ref("Para") &"|%' "
end if
if ref("StatusDe")<>"" then
    sqlStatusDe = " AND t.staDe='"&ref("StatusDe")&"' "
end if
if ref("StatusPara")<>"" then
    sqlStatusPara = " AND t.staPara='"&ref("StatusPara")&"' "
end if

if ref("AberturaDe")<>"" and isdate(ref("AberturaDe")) then
    sqlAberturaDe = " AND t.DtAbertura>="& mydatenull(ref("AberturaDe")) &" "
end if
if ref("AberturaAte")<>"" and isdate(ref("AberturaAte")) then
    sqlAberturaAte = " AND t.DtAbertura<="& mydatenull(ref("AberturaAte")) &" "
end if

if ref("PrazoDe")<>"" and isdate(ref("PrazoDe")) then
    sqlPrazoDe = " AND t.DtPrazo>="& mydatenull(ref("PrazoDe")) &" "
end if
if ref("PrazoAte")<>"" and isdate(ref("PrazoAte")) then
    sqlPrazoAte = " AND t.DtPrazo<="& mydatenull(ref("PrazoAte")) &" "
end if

if ref("Prioridade")<>"" then
    sqlPrioridade = " AND t.Urgencia="& treatvalnull(ref("Prioridade")) &" "
end if

if ref("TipoTarefa")<>"" AND ref("TipoTarefa")<>"0"  then
    sqlTipoTarefa = " AND t.Tipo="& treatvalnull(ref("TipoTarefa")) &" "
end if

if ref("Solicitante")<>"" and instr(ref("Solicitante"), "_")>0 then
    sqlSolicitante = " AND t.Solicitantes LIKE '%"& ref("Solicitante") &"%' "
end if

if ref("CategoriaID")<>"" and ref("CategoriaID")<>"0" then
    sqlCategoria = " AND t.CategoriaID="& ref("CategoriaID") &" "
elseif ref("CategoriaID")="0" then
    sqlCategoria = " AND (t.CategoriaID="& ref("CategoriaID") &" OR ISNULL(CategoriaID)) "
end if


if ref("Filtrar")<>"" then
    sqlFiltrar = " AND (t.id = '"&ref("Filtrar")&"' OR t.Titulo LIKE '%"& ref("Filtrar") &"%' OR t.ta LIKE '%"& ref("Filtrar") &"%') "
end if

if ref("Projeto")<>"" then
    if ref("Projeto")="0" then
        sqlProjeto = " AND t.ProjetoID IS NULL "
    else
        sqlProjeto = " AND t.ProjetoID="& treatvalnull(ref("Projeto")) &" "
    end if
end if

if ref("Para")<>"" then
    sqlCusto = "select CentroCustoID from "& session("Table") &" WHERE id="& session("idInTable") &" AND CentroCustoID<>0 AND NOT ISNULL(CentroCustoID)"

    if ref("Helpdesk") <> "" then
        set dblicense = db.execute(sqlCusto)
    else
        set cc = db.execute(sqlCusto)
    end if
    if not cc.eof then
        sqlCC = " OR t.Para LIKE '%|-"& cc("CentroCustoID") &"|%' "
    end if
end if

tdHidden = ""

if ref("Helpdesk") <> "" then
    tdHidden = " hidden "
end if
%>
<div class="col-md-12">
    <table class="table table-striped table-hover table-bordered table-condensed">
        <thead>
          <tr class="success ">
            <th>#</th>
            <th>Tipo</th>
            <th class="<%=tdHidden%>">Prioridade</th>
            <th>Abertura</th>
            <th>Prazo</th>
            <%'if ref("Tipo")="R" then %>
              <th>De</th>
            <%'else %>
              <th >Para</th>
            <%'end if %>
            <th>Título</th>
            <th>Projeto</th>
            <th class="<%=tdHidden%>">Solicitantes</th>
            <th class="hidden-print <%=tdHidden%>">Pontos</th>
            <th width="1%" ></th>
          </tr>
        </thead>
        <tbody>
        <%
'       response.write("select t.*, u.Nome, tsDe.Classe ClasseDe, tsPara.Classe ClassePara, (LENGTH(t.solicitantes) - LENGTH(REPLACE(t.solicitantes, '_', ''))) nSol, (((t.Urgencia * (LENGTH(t.solicitantes) - LENGTH(REPLACE(t.solicitantes, '_', ''))))) + IF (SIGN(DtPrazo - CURRENT_DATE()) = -1, ABS(DtPrazo - CURRENT_DATE()), 0)) Pontos, proj.Titulo AS Projeto, tp.Prioridade from tarefas t LEFT JOIN cliniccentral.licencasusuarios u on u.id=t.De LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara LEFT JOIN projetos proj ON proj.id = t.ProjetoID LEFT JOIN cliniccentral.tarefasprioridade tp on tp.id = t.urgencia WHERE t.sysActive=1 AND (t.De="& session("User") &" OR t.Para LIKE '%|"& session("User") &"|%' "& sqlCC &" ) " & sqlDe & sqlPara & sqlStatusDe & sqlStatusPara & sqlAberturaDe & sqlAberturaAte & sqlPrazoDe & sqlPrazoAte & sqlPrioridade & sqlTipoTarefa& sqlSolicitante & sqlFiltrar & sqlProjeto &" ORDER BY Pontos desc, t.DtPrazo, t.HrPrazo LIMIT 300")

        if ref("Helpdesk") <> "" then
            licencaPaciente = dblicense.execute("SELECT p.id FROM cliniccentral.licencas l JOIN pacientes p ON p.id = l.Cliente WHERE l.id = '"&replace(session("Banco"),"clinic","")&"'")
            sqlLicencaPaciente = " AND t.Solicitantes LIKE CONCAT('%3_','"&licencaPaciente("id")&"','%') "
        else
            sqlLicencaPaciente = ""
        end if

        'sqlLicencaPaciente = ""


        sqlLista = "select t.*, u.Nome, tsDe.Classe ClasseDe, tsPara.Classe ClassePara, (LENGTH(t.solicitantes) - LENGTH(REPLACE(t.solicitantes, '_', ''))) nSol, (((t.Urgencia * (LENGTH(t.solicitantes) - LENGTH(REPLACE(t.solicitantes, '_', ''))))) + IF (SIGN(DtPrazo - CURRENT_DATE()) = -1, ABS(DtPrazo - CURRENT_DATE()), 0)) Pontos, proj.Titulo AS Projeto, tp.Prioridade, tp.Classe PrioridadeClasse, tt.Descricao DescricaoTipo "&_
                   "from tarefas t "&_
                   "LEFT JOIN cliniccentral.licencasusuarios u on u.id=t.De "&_
                   "LEFT JOIN cliniccentral.tarefasstatus tsDe on tsDe.id=t.StaDe "&_
                   "LEFT JOIN cliniccentral.tarefasstatus tsPara on tsPara.id=t.StaPara "&_
                   "LEFT JOIN projetos proj ON proj.id = t.ProjetoID LEFT JOIN cliniccentral.tarefasprioridade tp on tp.id = t.urgencia "&_
                   "LEFT JOIN tarefastipos tt on tt.id = t.Tipo "&_
                   "LEFT JOIN pacientes p ON t.Solicitantes LIKE CONCAT('%3_',p.id,'%') "&_
                   "WHERE t.sysActive=1 AND (t.TarefaPaiID=0 OR t.TarefaPaiID IS NULL) AND ( 1=1 "& sqlCC &" ) " & sqlDe & sqlPara & sqlStatusDe & sqlStatusPara & sqlAberturaDe & sqlAberturaAte & sqlPrazoDe & sqlPrazoAte & sqlPrioridade & sqlTipoTarefa & sqlSolicitante & sqlResponsavel & sqlFiltrar & sqlProjeto & sqlLicencaPaciente & sqlCategoria &" "&_
                   "GROUP BY t.id ORDER BY Pontos desc, t.DtPrazo, t.HrPrazo LIMIT 1000"
                   'dd(sqlLista)
        if ref("Helpdesk") <> "" then
'dd(sqlLista)
            set lista = dblicense.execute(sqlLista)
        else
            set lista = db.execute(sqlLista)
        end if

        if lista.eof then
            %>
            <tr>
                <td class="text-center" colspan="12">Nenhuma tarefa encontrada com os critérios selecionados.</td>
            </tr>
            <%
        end if
        NumeroTarefas = 0
        while not lista.eof
            'response.write(lista("Prioridade") )
            NumeroTarefas = NumeroTarefas + 1
            Para = lista("Para")
            Virgula = ""
            if Para<>"" and not isnull(Para) then
                set p = db.execute("select group_concat(substring_index(Nome, ' ', 3) SEPARATOR ', ') ParaU from cliniccentral.licencasusuarios where id in("&replace(Para, "|", "")&")")
                ParaU = p("ParaU")
                if instr(Para, "-") then
                    sqlCusto = "select group_concat(NomeCentroCusto SEPARATOR ', ') ParaG from centrocusto where id*(-1) in("&replace(Para, "|", "")&")"
                    if ref("Helpdesk") <> "" then
                        set g = dblicense.execute(sqlCusto)
                    else
                        set g = db.execute(sqlCusto)
                    end if
                    ParaG = g("ParaG")
                end if
                if ParaU<>"" and not isnull(ParaU) then
                    Para = ParaU
                    Virgula = ", "
                end if
                if ParaG<>"" and not isnull(ParaG) then
                    if ParaU&""<>"" then
                        Para = ParaG & Virgula & Para
                    else
                        Para = ParaG
                    end if
                end if
            end if
            StaDe = lista("StaDe")
            StaPara = lista("StaPara")
            ClasseDe = lista("ClasseDe")
            ClassePara = lista("ClassePara")
            DataPrazo = lista("DtPrazo")
            DataAtual = date()
            ClassePrazo = ""
            if DataPrazo&""<>"" AND StaPara="Pendente" then
                if (cdate(DataPrazo) < DataAtual) then
                    ClassePrazo = "text-danger"
                elseif (cdate(DataPrazo) = DataAtual) then
                    ClassePrazo = "text-warning"
                end if
            end if
            Solicitantes = lista("Solicitantes")
            prioridadeClasse =""

            if lista("Prioridade")="Imediata" then
                prioridadeClasse = lista("PrioridadeClasse")

            end if
            classPara = ""
            if inStr(lista("Para"), ",")&""="0" and inStr(lista("Para"), "-")&""<>"0" then
                'classPara = "warning"
            end if


            %>
            <tr class="<%=prioridadeClasse&" "%> <%=classPara%>">
                <td><%=lista("id") %></td>
                <td><%=lista("DescricaoTipo") %></td>
                <td class="<%=tdHidden%>"><%=lista("Prioridade") %></td>
                <td><%=lista("DtAbertura") %></td>
                <td class="<%=ClassePrazo%>"><strong><%=DataPrazo %></strong></td>
                <td><span class="label label-sm arrowed-right label-<%=ClasseDe %>"><%=StaDe %></span> <%=lista("Nome") %></td>
                <td ><span class="label label-sm arrowed-right label-<%=ClassePara %>"><%=StaPara %></span> <%=Para %></td>

                <td><%=lista("Titulo") %></td>
                <td><%=lista("Projeto") %></td>
                <td class="text-right <%=tdHidden%>"><%= lista("nSol") %></td>
                <td class="text-right <%=tdHidden%> hidden-print"><%= lista("Pontos") %></td>

                <%
                    if ref("Helpdesk") <> "" then
                        LinkHelpdesk = "&Helpdesk=1"
                    else
                        LinkHelpdesk = ""
                    end if
                %>

                <td><a href="./?P=tarefas&Pers=1&I=<%=lista("id") %><%=LinkHelpdesk%>" class="btn btn-success btn-xs hidden-print"><i class="far fa-edit"></i></a> </td>
            </tr>
            <%
        lista.movenext
        wend
        lista.close
        set lista=nothing
        %>
        </tbody>
    </table>
    <strong><%=NumeroTarefas%> tarefas</strong>
</div>

<script>

</script>

