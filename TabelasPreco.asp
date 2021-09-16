<!--#include file="connect.asp"-->
<% IF getConfig("NovoFormatoDeTabelaDePreco") THEN %>
    <!--#include file="TabelasPreco2.asp"-->
<% ELSE  %>
<%
DT = req("DT")
X = req("X")
Atuacao = req("Atuar")



pagNumber = 1

IF req("pagNumber") <> "" THEN
    pagNumber = req("pagNumber")
END IF

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
Unidades = req("Unidades")
ConvenioID = req("ConvenioID")
Tabela = req("Tabela")


tiposAutorizados = ""

if aut("|tabelasprecoscustoV|")=1 then
    if tiposAutorizados<>"" then
        tiposAutorizados = tiposAutorizados & ", 'C'"
    else
        tiposAutorizados = tiposAutorizados & "'C'"
    end if
end if

if aut("|tabelasprecosV|")=1 then
    if tiposAutorizados<>"" then
        tiposAutorizados = tiposAutorizados & ", 'V'"
    else
        tiposAutorizados = tiposAutorizados & "'V'"
    end if
end if

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

function iif(comparacao, verdadeiro, falso)
   if(comparacao) Then
      iif = verdadeiro
   else
      iif = falso
   end if
end function

if Unidades&""="|0|" then
    Unidades=""
end if
if ConvenioID&""="0" then
    ConvenioID=""
end if

%>
<div class="panel mt20 mtn hidden-print">
    <div class="panel-heading">
        <span class="panel-title"><i class="fal fa-filter"></i> Filtrar</span>
    </div>
    <div class="panel-body">
        <form action="" id="form-filtro-tabela-de-preco" method="get">
            <div class="row">
                <input type="hidden" name="P" value="TabelasPreco">
                <input type="hidden" name="Pers" value="1">

                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2,TipoTabela, "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 empty  ") %>
                <%= quickfield("simpleSelect", "TabelasParticulares", "Tabela Particular", 2, TabelasParticulares, "select * from tabelaparticular where  sysActive=1 order by NomeTabela", "NomeTabela", " empty ") %>
                <%= quickfield("simpleSelect", "Especialidades", "Especialidade", 2, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", " empty ") %>
        
                <div class="col-md-2">
                    <%= selectInsert("Procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
                </div>

            <div class="col-md-2 qf" id="qftipo">
            <label for="Atuar">Atuar</label>
            <br>
            <select name="Atuar" id="Atuar" class=" form-control" no-select2="" empty="">            
            <option selected value="">Selecione</option>
            <option value="|procedimentos|">Procedimentos</option>
			<option value="|Materiais|">Medicacao</option>
				
            </select>
            </div>

                <div class="col-md-2">
                    <button type="button" class="btn btn-default mt25" onclick="LimparFiltros()"><i class="fal fa-eraser"> </i> Limpar </button>
                    <button class="btn btn-primary mt25" ><i class="fal fa-search"> </i> Buscar </button>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="panel mt20">
    <div class="panel-body">
        <table class="table table-condensed table-hover  table-striped">
            <thead>
                <tr class="info">
                    <th>Status</th>
                    <th>Descrição</th>
                    <th>Tabelas Particulares</th>
                    <th>Tipo</th>
                    <th>Vigência</th>
                    <th>Unidades</th>
                    <th width="1%"></th>
                    <th width="1%"></th>
                    <% if aut("|tabelasprecosA|")=1 or aut("|tabelasprecosV|")=1 then %>
                        <th width="1%"></th>
                    <% end if %>
                    <% if aut("|tabelasprecosX|")=1 or aut("|tabelasprecoscustoX|")=1 then %>
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
                    sqlFiltros = sqlFiltros & " AND pt.Tipo= '"&replace(TipoTabela,",","")&"'"
                end if
                if TabelasParticulares<>"" then
                    sqlFiltros = sqlFiltros & " OR pt.TabelasParticulares LIKE '%|"&replace(TabelasParticulares, "|", "")&"|%'"
                end if
                
                if Atuacao<>"" then
                    sqlFiltros = sqlFiltros & " AND pt.Atuacao LIKE '%"&Atuacao&"%'"
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
                if Unidades <>"" then
                    sqlFiltros = sqlFiltros & " AND cliniccentral.overlap('"&Unidades&"', pt.Unidades)"
                end if
                if ConvenioID <>"" then
                    sqlFiltros = sqlFiltros & " AND cliniccentral.overlap(CONCAT('|','"&ConvenioID&"','|'), pt.Convenios)"
                end if
                if Tabela <>"" then
                    sqlFiltros = sqlFiltros & " and NomeTabela like '%"&Tabela&"%'"
                end if

                set count = db_execute("select ceil(count(*)/10) as qtd from procedimentostabelas pt where "&franquiaUnidade(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE) AND ")&" pt.sysActive=1 "&sqlFiltros&" ")

                sql = "select pt.*, tp.id HasSolicitacao,coalesce(Fim,date(Now())) as Fim,coalesce(Inicio,date(Now())) as Inicio,(SELECT group_concat(' ',NomeFantasia) FROM vw_unidades WHERE Unidades like CONCAT('%|',id,'|%')) Unidades, Unidades like '%|0|%' as HasCentral "&_
                "from procedimentostabelas pt "&_
                " LEFT JOIN solicitacao_tabela_preco tp ON tp.TabelaPrecoID=pt.id AND Status='PENDENTE' "&_
                "where "&franquiaUnidade(" ( Unidades LIKE '%|"&session("UnidadeID")&"|%' OR Unidades = '' OR Unidades IS NULL) AND ")&" pt.sysActive=1  "&sqlFiltros&" ORDER BY 2 limit "&((pagNumber-1)*10)&",10"

                set t = db.execute(sql)
                'response.write (sql)
                if t.eof then
                    %>
        <tr>
            <td colspan="8">Nenhuma tabela de preço encontrada</td>
        </tr>
                    <%
                end if

                countTabelas= 0

                while not t.eof

                    if t("Tipo")="V" then
                        prefixoPermissao = "tabelasprecos"
                    else
                        prefixoPermissao = "tabelasprecoscusto"
                    end if

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
                    if not isnull(t("Fim")) then
                        if cdate(t("Fim")) < date() then
                            LabelTabela = "<span class='label label-danger'><i class='fal fa-exclamation-circle'></i> Expirada</span>"
                        end if

                        if cdate(t("Fim")) >= date() and cdate(t("Inicio")) <= date() then
                            LabelTabela = "<span class='label label-success'><i class='fal fa-check-circle'></i> Vigente</span>"
                        end if
                    end if

                    %>
                    <tr>
                        <td><%=LabelTabela%></td>
                        <td><%= t("NomeTabela") %></td>
                        <td><%= TabelasParticulares %></td>
                        <td><%= t("Tipo") %></td>
                        <td><%= t("Inicio") &" a "& t("Fim") %></td>
                        <td style="width: 30%"><%= t("Unidades") %></td>
                        <td>
                            <%
                            if t("HasSolicitacao") then
                                %>
                                <i title="Existem solicitações em aberto para esta tabela." class="text-warning far fa-exclamation-circle"></i>
                                <%
                            end if
                            %>
                        </td>
                        <td>
                            <% IF ModoFranquiaCentral or t("HasCentral") = "0" and aut("|"&prefixoPermissao&"I|")=1 THEN %>
                                <button type="button" class="btn btn-xs btn-info"><i class="far fa-copy" title="Duplicar tabela" onclick="if(confirm('Tem certeza de que deseja duplicar esta tabela? \nIMPORTANTE: Cuidado para não gerar conflito entre tabelas similares.'))location.href='./?P=TabelasPreco&Pers=1&DT=<%= t("id") %>'"></i></button>
                            <% END IF %>
                        </td>
                        <% if aut("|"&prefixoPermissao&"A|")=1  then %>
                        <td><a href="./?P=ProcedimentosTabelas2&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-success"><i class="far fa-edit"></i></a></td>
                        <% else %>
                        <td><a href="./?P=ProcedimentosTabelas2&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="far fa-eye"></i></a></td>
                        <% end if %>
                        <% if aut("|tabelasprecosX|")=1 then %>
                            <td><a href="javascript:if(confirm('Tem certeza de que deseja excluir esta tabela?'))location.href='./?P=TabelasPreco&I=<%= t("id") %>&Pers=1&X=<%= t("id") %>'" class="btn btn-xs btn-danger"><i class="fal fa-remove"></i></a></td>
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
                        <th colspan="10"><%=countTabelas%> tabela(s)</th>
                    </tr>
                </tfoot>
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    $(".crumb-active a").html("Preços de Custo e Venda");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("cadastro de preços de custo e venda por vigência");
    $(".crumb-icon a span").attr("class", "fal fa-table");
    <%
        if aut("snapshottabelasprecosA")=1 and aut("snapshottabelasprecosE")=1 then
        %>
            $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=ProcedimentosTabelas2&Pers=1&I=N"><i class="far fa-plus"></i><span class="menu-text"> INSERIR </span></a>&nbsp;&nbsp;<button type="button" class="btn btn-sm default mr5" data-toggle="modal" onclick="carregaSnapshots(\'geral\',\'0\')"><i class="far fa-history"></i> Histórico </button>');
        <%
    else
        if aut("|tabelasprecosI|")=1 or aut("|tabelasprecoscustoI|")=1 then
        %>
            $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=ProcedimentosTabelas2&Pers=1&I=N"><i class="far fa-plus"></i><span class="menu-text"> INSERIR </span></a>&nbsp;&nbsp;');
        <%
        end if
    end if
    %>

    function LimparFiltros() {
        $("#ProcedimentoID, #Tipo, #Especialidades, #TabelasParticulares").val("").change();

    }
</script>
<% END IF %>