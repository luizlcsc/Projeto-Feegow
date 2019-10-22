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
%>

<div class="panel mt20">
    <div class="panel-body">
        <table class="table table-condensed table-hover table-bordered table-striped">
            <thead>
                <tr class="info">
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
                'set t = db.execute("select pt.* from procedimentostabelas pt where pt.sysActive=1 group by pt.Inicio, pt.Fim, pt.TabelasParticulares")
                set t = db.execute("select pt.* from procedimentostabelas pt where pt.sysActive=1")
                while not t.eof
                    TabelasParticulares = t("TabelasParticulares")&""
                    if TabelasParticulares<>"" then
                        set tp = db.execute("select group_concat(NomeTabela separator ', ') tps from tabelaparticular where id in("& replace(TabelasParticulares, "|", "") &")")
                        TabelasParticulares = tp("tps")&""
                    end if
                    %>
                    <tr>
                        <td><%= t("NomeTabela") %></td>
                        <td><%= TabelasParticulares %></td>
                        <td><%= t("Tipo") %></td>
                        <td><%= t("Inicio") &" a "& t("Fim") %></td>
                        <td><button type="button" class="btn btn-xs btn-info"><i class="fa fa-copy" title="Duplicar tabela" onclick="location.href='./?P=TabelasPreco&Pers=1&DT=<%= t("id") %>'"></i></button></td>
                        <% if aut("|tabelasprecosA|")=1 then %>
                        <td><a href="./?P=ProcedimentosTabelas&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-success"><i class="fa fa-edit"></i></a></td>
                        <% end if %>
                        <% if aut("|tabelasprecosX|")=1 then %>
                            <td><a href="javascript:if(confirm('Tem certeza de que deseja excluir esta tabela?'))location.href='./?P=TabelasPreco&I=<%= t("id") %>&Pers=1&X=<%= t("id") %>'" class="btn btn-xs btn-danger"><i class="fa fa-remove"></i></a></td>
                        <% end if %>
                    </tr>
                    <%
                t.movenext
                wend
                t.close
                set t=nothing
                %>
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
</script>