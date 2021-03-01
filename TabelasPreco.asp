<!--#include file="connect.asp"-->

<%
DT = req("DT")
X = req("X")
if DT<>"" then
    db.execute("insert into procedimentostabelas (Tipo, NomeTabela, Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, Unidades, ConvenioID, sysUser, sysActive) select Tipo, concat(NomeTabela, ' (Cópia)'), Inicio, Fim, TabelasParticulares, Profissionais, Especialidades, Unidades, ConvenioID, "& session("User") &", 1 from procedimentostabelas where id="& DT)
    set pult = db.execute("select id from procedimentostabelas where sysUser="& session("User") &" order by id desc limit 1")
    NovaTabelaID = pult("id")
    db.execute("insert into procedimentostabelasvalores (ProcedimentoID, TabelaID, Valor) select ProcedimentoID, "& NovaTabelaID &", Valor from procedimentostabelasvalores where TabelaID="&DT)

    response.Redirect("./?P=TabelasPreco&Pers=1")
end if

if X<>"" then
    db.execute("delete from procedimentostabelas where id="& X)
    db.execute("delete from procedimentostabelasvalores where TabelaID="& X)
end if

TipoTabela = req("Tipo")
Especialidades = req("Especialidades")
TabelasParticulares = req("TabelasParticulares")
ProcedimentoID = req("ProcedimentoID")

if TipoTabela&""="0" then
    TipoTabela=""
end if
if Especialidades&""="0" then
    Especialidades=""
end if
if TabelasParticulares&""="0" then
    TabelasParticulares=""
end if
if ProcedimentoID&""="0" then
    ProcedimentoID=""
end if

%>
<div class="panel mt20 mtn hidden-print">
    <div class="panel-heading">
        <span class="panel-title"><i class="fa fa-filter"></i> Filtrar</span>
    </div>
    <div class="panel-body">
        <form action="" id="form-filtro-tabela-de-preco" method="get">
            <div class="row">
                <input type="hidden" name="P" value="TabelasPreco">
                <input type="hidden" name="Pers" value="1">

                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2, TipoTabela, "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 empty  ") %>
                <%= quickfield("simpleSelect", "TabelasParticulares", "Tabela Particular", 2, TabelasParticulares, "select * from tabelaparticular where  sysActive=1 order by NomeTabela", "NomeTabela", " empty ") %>
                <%= quickfield("simpleSelect", "Especialidades", "Especialidade", 2, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", " empty ") %>
                <div class="col-md-2">
                    <%= selectInsert("Procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
                </div>

                <div class="col-md-2">
                    <button type="button" class="btn btn-default mt25" onclick="LimparFiltros()"><i class="fa fa-eraser"> </i> Limpar </button>
                    <button class="btn btn-primary mt25" ><i class="fa fa-search"> </i> Buscar </button>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="panel mt20">
    <div class="panel-body">
        <table class="table table-condensed table-hover table-bordered table-striped">
            <thead>
                <tr class="info">
                    <th>Status</th>
                    <th>Descrição</th>
                    <th>Tabelas Particulares</th>
                    <th>Tipo</th>
                    <th>Vigência</th>
                    <th width="1%"></th>
                    <% if aut("|tabelasprecosA|")=1 then %>
                        <th width="1%"></th>
                    <% end if %>
                    <% if aut("|tabelasprecosX|")=1 then %>
                        <th width="1%"></th>
                    <% end if %>
                </tr>
            </thead>
            <tbody>
                <%

                sqlFiltros = ""

                if Especialidades<>"" then
                    sqlFiltros = sqlFiltros & " AND pt.Especialidades LIKE '%|"&replace(Especialidades, "|", "")&"|%'"
                end if
                if TipoTabela<>"" then
                    sqlFiltros = sqlFiltros & " AND pt.Tipo= '"&TipoTabela&"'"
                end if
                if TabelasParticulares<>"" then
                    sqlFiltros = sqlFiltros & " AND pt.TabelasParticulares LIKE '%|"&replace(TabelasParticulares, "|", "")&"|%'"
                end if

                if ProcedimentoID<>"" then
                    set TabelasComProcedimentoSQL = db.execute("SELECT GROUP_CONCAT(TabelaID) Tabelas FROM procedimentostabelasvalores ptv WHERE ProcedimentoID="&ProcedimentoID)
                    TabelasComOProcedimento = "0"

                    if not TabelasComProcedimentoSQL.eof then
                        Tabelas = TabelasComProcedimentoSQL("Tabelas")&""

                        if Tabelas&"" <> "" then
                            TabelasComOProcedimento = TabelasComOProcedimento&","&Tabelas
                        end if
                    end if
                    sqlFiltros = sqlFiltros & " AND pt.id IN ("&TabelasComOProcedimento&")"
                end if

                'set t = db.execute("select pt.* from procedimentostabelas pt where pt.sysActive=1 group by pt.Inicio, pt.Fim, pt.TabelasParticulares")
                set t = db.execute("select pt.* from procedimentostabelas pt where pt.sysActive=1 "&sqlFiltros&" ORDER BY YEAR(pt.Fim) DESC, pt.NomeTabela")

                if t.eof then
                    %>
<tr>
    <td colspan="8">Nenhuma tabela de preço encontrada</td>
</tr>
                    <%
                end if

                countTabelas= 0

                while not t.eof
                    TabelasParticulares = t("TabelasParticulares")&""
                    if TabelasParticulares<>"" then
                        set tp = db.execute("select group_concat(NomeTabela separator ', ') tps from tabelaparticular where id in("& replace(TabelasParticulares, "|", "") &")")
                        TabelasParticulares = tp("tps")&""
                    end if

                    LabelTabela = ""
                    dataFimTabela = t("Fim")
                    if isNull (dataFimTabela) then 
                        dataFimTabela = date()
                    end if
                    if cdate(t("Fim")) < date() then
                        LabelTabela = "<span class='label label-danger'><i class='fa fa-exclamation-circle'></i> Expirada</span>"
                    end if

                    if cdate(t("Fim")) >= date() and cdate(t("Inicio")) <= date() then
                        LabelTabela = "<span class='label label-success'><i class='fa fa-check-circle'></i> Vigente</span>"
                    end if

                    %>
                    <tr>
                        <td><%=LabelTabela%></td>
                        <td><%= t("NomeTabela") %></td>
                        <td><%= TabelasParticulares %></td>
                        <td><%= t("Tipo") %></td>
                        <td><%= t("Inicio") &" a "& t("Fim") %></td>
                        <td><button type="button" class="btn btn-xs btn-info"><i class="fa fa-copy" title="Duplicar tabela" onclick="location.href='./?P=TabelasPreco&Pers=1&DT=<%= t("id") %>'"></i></button></td>
                        <% if aut("|tabelasprecosA|")=1 then %>
                        <td>
                            <% IF getConfig("NovoPrecoCusto") THEN %>
                                <a href="./?P=ProcedimentosTabelas2&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-success"><i class="fa fa-edit"></i></a>
                            <% ELSE %>
                                <a href="./?P=ProcedimentosTabelas&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-success"><i class="fa fa-edit"></i></a>
                            <% END IF %>

                        </td>
                        <% end if %>
                        <% if aut("|tabelasprecosX|")=1 then %>
                            <td><a href="javascript:if(confirm('Tem certeza de que deseja excluir esta tabela?'))location.href='./?P=TabelasPreco&I=<%= t("id") %>&Pers=1&X=<%= t("id") %>'" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i></a></td>
                        <% end if %>
                    </tr>
                    <%
                    countTabelas = countTabelas + 1
                t.movenext
                wend
                t.close
                set t=nothing
                %>
                <tfoot>
                    <tr class="dark">
                        <th colspan="8"><%=countTabelas%> tabela(s)</th>
                    </tr>
                </tfoot>
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    $(".crumb-active a").html("Tabelas de Preço");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("cadastro de tabelas de preço por vigência");
    $(".crumb-icon a span").attr("class", "fa fa-table");
    <%
    if aut("procedimentosA")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=ProcedimentosTabelas&Pers=1&I=N"><i class="fa fa-plus"></i><span class="menu-text"> INSERIR</span></a>');
    <%
    end if
    %>

    function LimparFiltros() {
        $("#ProcedimentoID, #Tipo, #Especialidades, #TabelasParticulares").val("").change();

    }
</script>