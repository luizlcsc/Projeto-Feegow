<!--#include file="connect.asp"-->
<%
if req("InsRap")<>"" then
    db.execute("insert into procedimentos (NomeProcedimento, MaximoAgendamentos, sysActive, Auxiliares, CH, UCO, Filme, PorteAnestesico, sysUser, Codigo, Ativo, Descricao) select Descricao, 1, 1, NAux_CBHPM, CH, CO, Filme_CBHPM, PA_CBHPM, "& session("User") &", TUSS, 'on', Descricao from cliniccentral.tabelascompletas where id="& req("InsRap"))
end if


txt = replace(req("txt"), " ", "%")

set procs = db.execute("select id, NomeProcedimento, Codigo, Valor, TempoProcedimento from procedimentos where sysActive=1 and Ativo='on' and (NomeProcedimento like '%"& txt &"%' or Codigo like '%"& txt &"%')")
if not procs.eof then
%>

<h4>Procedimentos Encontrados</h4>
<table class="table table-striped table-bordered table-condensed">
    <thead>
        <tr class="primary">
            <th>Nome do Procedimento</th>
            <th>Código TUSS</th>
            <th>Valor</th>
            <th>Tempo</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
        while not procs.eof
            %>
            <tr>
                <td><%= procs("NomeProcedimento") %></td>
                <td><%= procs("Codigo") %></td>
                <td><%= procs("Valor") %></td>
                <td><%= procs("TempoProcedimento") %></td>
                <td nowrap>
                    <% if aut("|procedimentosA|")=1 then %><a href="./?P=Procedimentos&I=<%=procs("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-edit"></i></a><%end if %>
                    <% if aut("|procedimentosX|")=1 then %><a class="btn btn-xs btn-danger tooltip-danger" title="" data-rel="tooltip" href="javascript:if(confirm('Tem certeza de que deseja excluir este registro?'))location.href='?P=Procedimentos&X=<%= procs("id") %>&Pers=Follow';"><i class="fa fa-remove bigger-130"></i></a><% end if %>
                </td>
            </tr>
            <%
        procs.movenext
        wend
        procs.close
        set procs = nothing
        %>
    </tbody>
</table>
<%
else
    %>
    Nenhum procedimento ativo com o termo '<%= txt %>'.
    <%
end if

if len(txt)>2 then
    set vcaTC = db.execute("select * from cliniccentral.tabelascompletas where TUSS like '%"& txt &"%' or Descricao like '%"& txt &"%' or AMB92 like '%"& txt &"%' or CBHPM like '%"& txt &"%' limit 100")
    if not vcaTC.eof then
        %>
        <h4><i class="fa fa-star"></i> Ativação Rápida de Procedimento</h4>

        <table class="table table-striped table-bordered table-condensed">
            <thead>
                <tr class="warning">
                    <th>Descrição</th>
                    <th>Código TUSS</th>
                    <th>Código AMB-92</th>
                    <th>Código CBHPM</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>
                <%
                while not vcaTC.eof
                    %>
                    <tr>
                        <td><%= vcaTC("Descricao") %></td>
                        <td><%= vcaTC("TUSS") %></td>
                        <td><%= vcaTC("AMB92") %></td>
                        <td><%= vcaTC("CBHPM") %></td>
                        <td><a href="#" class="btn btn-sm btn-warning" type="button" onclick="ajxContent('divProcedimentoRapidoResult&txt=<%= txt %>&InsRap=<%= vcaTC("id") %>', '', 1, 'divProcedimentoRapido')"><i class="fa fa-star"></i> ATIVAR</i></a></td>
                    </tr>
                    <%
                vcaTC.movenext
                wend
                vcaTC.close
                set vcaTC = nothing
                    %>
            </tbody>
        </table>

        <%
    end if
end if
%>