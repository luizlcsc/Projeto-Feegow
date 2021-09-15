<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<% hasPermissaoTela("tabelasprecos") %>
<%

pagNumber = 1

IF req("pagNumber") <> "" THEN
    pagNumber = req("pagNumber")
END IF

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
    sqlExclusao = "delete from procedimentostabelas where id="& X
    call gravaLogs(sqlExclusao ,"X", "Valor do procedimento na tabela alterada"&LogDetalhe,"")
    db.execute(sqlExclusao)

    sqlExclusao = "delete from procedimentostabelasvalores where TabelaID="& X
    call gravaLogs(sqlExclusao ,"X", "Valor do procedimento na tabela alterada"&LogDetalhe,"")
    db.execute(sqlExclusao)
end if

TipoTabela = req("Tipo")
Especialidades = req("Especialidades")
TabelasParticulares = req("TabelasParticulares")
ProcedimentoID = req("ProcedimentoID")
Unidades = req("Unidades")
ConvenioID = req("ConvenioID")
Tabela = req("Tabela")

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
if Unidades&""="|0|" then
    Unidades=""
end if
if ConvenioID&""="0" then
    ConvenioID=""
end if

%>
<div class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true" id="confirmacao-modal">
  <div class="modal-dialog modal-sm">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">Aviso </h4>
        <div class="modal-body" id="alertmodalbody">
        
        </div>
      </div>
      <div class="modal-footer">
        <input type="hidden" id="registroid">
        <input type="hidden" id="tabelaid">
        <input type="hidden" id="tipo">
        <button type="button" class="btn btn-default" id="modal-btn-sim" onclick="confirmaRestauracao('1');">Sim</button>
        <button type="button" class="btn btn-primary" id="modal-btn-nao" onclick="confirmaRestauracao('0');">Não</button>
      </div>
    </div>
  </div>
</div>

<div class="alert" role="alert" id="result" style="border: none"></div>

<!-- Modal -->
<!-- <div class="modal fade modal-lg" id="snapModal" tabindex="-1" role="dialog" aria-labelledby="snapModalLabel" aria-hidden="true"> -->
<div class="modal fade bd-example-modal-lg" tabindex="-1" role="dialog" aria-labelledby="myLargeModalLabel" aria-hidden="true" id="snapModal">
  <div class="modal-dialog  modal-lg" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="snapModalLabel">Históricos</h5>
      </div>
      <div class="modal-body" id="modalbody">
        ...
      </div>
      
      <div class="modal-footer">
        <!-- <button type="button" class="btn btn-primary" onclick="criarsnapshot()" id="btn-criar">Criar Ponto de Restauração</button> <button type="button" class="btn btn-secondary" data-dismiss="modal">Fechar</button> -->
      </div>
    </div>
  </div>
</div>

<div class="panel mt20 mtn hidden-print">
    <div class="panel-heading">
        <span class="panel-title"><i class="far fa-filter"></i> Filtrar</span>
    </div>
    <div class="panel-body">
        <form action="" id="form-filtro-tabela-de-preco" method="get">
            <div class="row">
                <input type="hidden" name="P" value="TabelasPreco">
                <input type="hidden" name="Pers" value="1">
                <%
                    sqlUnidades = "SELECT concat('|',id,'|') as id,NomeFantasia FROM vw_unidades WHERE id = "&session("UnidadeID")&" "
                    sqlConvenios = "select 'P' id, ' PARTICULAR' NomeConvenio UNION ALL select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' "&franquiaUnidade(" AND Unidades LIKE '%|"&session("UnidadeID")&"|%' ")&" AND COALESCE((SELECT CASE WHEN SomenteConvenios LIKE '%|NONE|%' THEN FALSE ELSE NULLIF(SomenteConvenios,'') END FROM profissionais  WHERE id = "&treatvalzero(ProfissionalID)&") LIKE CONCAT('%|',id,'|%'),TRUE) "&franquiaUnidade("AND COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")&" order by NomeConvenio"

                    if session("UnidadeID") = 0 then
                        sqlUnidades = "SELECT concat('|',id,'|') as id,NomeFantasia FROM vw_unidades where sysActive = 1 "
                    end if

                %>
                <div class="row">
                    <%=quickField("text", "Tabela", "Tabela", 3, Tabela, "", "", "")%>
                    <%= quickfield("simpleSelect", "Tipo", "Tipo", 3, TipoTabela, "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 empty  ") %>
                    <%= quickfield("simpleSelect", "TabelasParticulares", "Tabela / Parceria", 3, TabelasParticulares, "select * from tabelaparticular where  "&franquiaUnidade(" COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[|"&session("UnidadeID")&"|]',''),'-999')),TRUE) AND ")&" sysActive=1 order by NomeTabela", "NomeTabela", " empty ") %>
                    <%= quickfield("simpleSelect", "Especialidades", "Especialidade", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", " empty ") %>
                </div>
                <div class="row">
                    <%= quickField("simpleSelect", "Unidades", "Unidade",3, Unidades, sqlunidades, "NomeFantasia", " semVazio ")%>
                    <%= quickfield("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 3, ConvenioID, sqlConvenios , "NomeConvenio", "") %>

                    <div class="col-md-3">
                        <%= selectInsert("Procedimento", "ProcedimentoID", ProcedimentoID, "procedimentos", "NomeProcedimento", " ", "", "") %>
                    </div>
                    <div class="col-md-3 text-right">
                        <button type="button" class="btn btn-default mt25" onclick="LimparFiltros()"><i class="far fa-eraser"> </i> Limpar </button>
                        <button class="btn btn-primary mt25" ><i class="far fa-search"> </i> Buscar </button>
                    </div>
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
                    <th>Unidades</th>
                    <th width="1%"></th>
                    <% if aut("|tabelasprecosA|")=1 then %>
                        <th width="1%"></th>
                    <% end if %>
                    <% if aut("|tabelasprecosX|")=1 then %>
                        <th width="1%"></th>
                    <% end if %>
                    <%
                       if aut("snapshottabelasprecosA")=1 and aut("snapshottabelasprecosE")=1 then
                    %>
                        <td></td>
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
                    db_execute("SET SESSION group_concat_max_len = 10000000; ")
                    set TabelasComProcedimentoSQL = db_execute("SELECT GROUP_CONCAT(TabelaID) Tabelas FROM procedimentostabelasvalores ptv WHERE ProcedimentoID="&ProcedimentoID)
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

                sql = "select pt.*,coalesce(Fim,date(Now())) as Fim,coalesce(Inicio,date(Now())) as Inicio,(SELECT group_concat(' ',NomeFantasia) FROM vw_unidades WHERE Unidades like CONCAT('%|',id,'|%')) Unidades, Unidades like '%|0|%' as HasCentral from procedimentostabelas pt where "&franquiaUnidade(" ( Unidades LIKE '%|"&session("UnidadeID")&"|%' OR Unidades = '' OR Unidades IS NULL) AND ")&" pt.sysActive=1  "&sqlFiltros&" ORDER BY 2 limit "&((pagNumber-1)*10)&",10"
                set t = db_execute(sql)
                'response.write (sql)
                if t.eof then
                    %>
<tr>
    <td colspan="9">Nenhuma tabela de preço encontrada</td>
</tr>
                    <%
                end if

                countTabelas= 0

                while not t.eof
                    TabelasParticulares = t("TabelasParticulares")&""
                    if TabelasParticulares<>"" then
                        set tp = db_execute("select group_concat(NomeTabela separator ', ') tps from tabelaparticular where id in("& replace(TabelasParticulares, "|", "") &")")

                        if len(tp("tps")&"")>100 then
                            TabelasParticulares = left(tp("tps"),100)&"<a href='#' data-toggle='tooltip' data-placement='right' data-original-title='"&tp("tps")&"' > <strong>...</strong></a>"
                        else
                            TabelasParticulares = tp("tps")&""
                        end if
                    end if

                    LabelTabela = ""

                    IF not isnull(t("Fim")) and not isnull(t("Inicio")) THEN
                        if cdate(t("Fim")) < date() then
                            LabelTabela = "<span class='label label-danger'><i class='far fa-exclamation-circle'></i> Expirada</span>"
                        end if

                        if cdate(t("Fim")) >= date() and cdate(t("Inicio")) <= date() then
                            LabelTabela = "<span class='label label-success'><i class='far fa-check-circle'></i> Vigente</span>"
                        end if
                    END IF
                    %>
                    <tr>
                        <td><%=LabelTabela%></td>
                        <td><%= t("NomeTabela") %></td>
                        <td><%= TabelasParticulares %></td>
                        <td><%= t("Tipo") %></td>
                        <td><%= t("Inicio") &" a "& t("Fim") %></td>
                        <td style="width: 30%"><%= t("Unidades") %></td>
                        <td>
                            <button type="button" class="btn btn-xs btn-info"><i class="far fa-copy" title="Duplicar tabela" onclick="if(confirm('Tem certeza de que deseja duplicar esta tabela? \nIMPORTANTE: Cuidado para não gerar conflito entre tabelas similares.'))location.href='./?P=TabelasPreco&Pers=1&DT=<%= t("id") %>'"></i></button>
                        </td>
                        <% if aut("|tabelasprecosA|")=1 then %>
                        <td><a href="./?P=ProcedimentosTabelas2&I=<%= t("id") %>&Pers=1" class="btn btn-xs btn-success"><i class="far fa-edit"></i></a></td>
                        <% end if %>
                        <% if aut("|tabelasprecosX|")=1 then
                        %>
                            <td>
                                    <a href="javascript:if(confirm(`Tem certeza de que deseja excluir esta tabela?`))location.href=`./<%="?P=TabelasPreco&I="&t("id")&"&Pers=1&X="&t("id")&"&Tipo="&req("Tipo")&"&TabelasParticulares="&req("TabelasParticulares")&"&Especialidades="&req("Especialidades")&"&ProcedimentoID="&req("ProcedimentoID")%>`" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></a>
                            </td>
                        <% end if %>
                        <%
                            if aut("snapshottabelasprecosA")=1 and aut("snapshottabelasprecosE")=1 then
                        %>
                             <td><a href="#" class="btn btn-xs btn-waring" onclick="carregaSnapshots('tabela','<%=t("id") %>')"><i class="far fa-history"></i></a></td>
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
         <div class="mypage" style="display: flex;">

        </div>
    </div>
</div>

<script type="text/javascript">
<%
buscaFiltro = replace(replace(request.QueryString&"","'","''"),"&pagNumber="&req("pagNumber"),"")
%>
    function changePagination(numberPag){
        location.href = `?<%=buscaFiltro%>&pagNumber=${numberPag}`
    }

    function paginationHtml(page_number,numberPages) {
        let html = `<ul class="pagination justify-content-center" style="margin: 20px auto;">`;

        for(let i = page_number-3;i < page_number;i++){
            if(i<1){
                continue;
            }

            html += `<li class="page-item" onclick="changePagination(${i});"><a class="page-link" href="#">${i}</a></li>`
        }

        html += `<li class="page-item active"  ><a class="page-link" href="#">${page_number}</a></li>`

        for(let i = page_number+1;i < page_number+1+3;i++){
            if(i>numberPages)
            {
               break;
            }
             html += `<li class="page-item" onclick="changePagination(${i});"><a class="page-link" href="#">${i}</a></li>`
        }
        html += `</ul>`;
        return html;
    }

    $(".mypage").html(paginationHtml(<%=pagNumber %>,<%=count("qtd")&""%>));
    $(".crumb-active a").html("Preços de Custo e Venda");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("cadastro de preços de custo e venda por vigência");
    $(".crumb-icon a span").attr("class", "far fa-table");
    <%
    if aut("snapshottabelasprecosA")=1 and aut("snapshottabelasprecosE")=1 then
    %>
        $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=ProcedimentosTabelas2&Pers=1&I=N"><i class="far fa-plus"></i><span class="menu-text"> INSERIR </span></a>&nbsp;&nbsp;<button type="button" class="btn btn-sm btn-primary" data-toggle="modal" onclick="carregaSnapshots(\'geral\',\'0\')"> Histórico </button>');
    <%
    else
        if aut("tabelasprecosA")=1 then
        %>
            $("#rbtns").html('<a class="btn btn-sm btn-success pull-right" href="./?P=ProcedimentosTabelas2&Pers=1&I=N"><i class="far fa-plus"></i><span class="menu-text"> INSERIR </span></a>&nbsp;&nbsp;');
        <%
        end if
    end if
    %>
    function LimparFiltros() {
        $("#ProcedimentoID, #Tipo, #Especialidades, #TabelasParticulares").val("").change();
    }

    function carregaSnapshots(tipo,id)
    {        
        $.get("TabelasPrecoSnapShot.asp", {
            unidadeid: '<%=session("UnidadeID")%>',
            tabelaid: id,
            tipo: tipo
        }, function(data){
            $('#modalbody').html(data);
            $('#btn-criar').attr("disabled", false);
            if (tipo == 'tabela')
            {
                $('#btn-criar').attr("disabled", true);
            } 
        });
        $('#snapModal').modal("show");        
        $('#confirmacao-modal').modal("hide");
             
    }

    function confirmaRestauracao(confirm){
        registroid = $('#registroid').val();
        tabelaid = $('#tabelaid').val();
        tipo = $('#tipo').val();

        if(confirm=='1'){
           restaurarSnapShot(tipo,registroid,tabelaid);          
        }else{        
           $("#confirmacao-modal").modal("hide");
           $('#snapModal').modal("show"); 
        }        
    };

    function restaurarSnapShot(tipo, snapshotid, tabelaid)
    {
        var gravando = '<h3 style="text-align: center;"><i class="far fa-spinner fa-spin"></i> <BR> Restaurando... </h3>';
        $('#btn-criar').attr("disabled", true);
        $('#modalbody').html(gravando);            
        $.get("operacaoSnapShot.asp", {
            snapshotid: snapshotid, 
            tipo: tipo,
            tabelaid: tabelaid,
            acao:'restaurar' 
        }, function(data){      
            $('#snapModal').modal("hide");
            $('#btn-criar').attr("disabled", false);
        });
        carregaSnapshots(tipo,snapshotid);
        
    }

    function criarsnapshot()
    {
        var gravando = '<h3 style="text-align: center;"><i class="far fa-spinner fa-spin"></i> <BR> Gerando Ponto de Restauração... </h3>';
        $('#btn-criar').attr("disabled", true);
        $('#modalbody').html(gravando);

        fetch(`operacaoSnapShot.asp?unidade=<%=session("UnidadeID")%>&acao=gravar`)
        .then((res) => {
            $('#btn-criar').removeAttr("disabled");
            carregaSnapshots('geral','0');
        }).catch(() => {
            $('#btn-criar').removeAttr("disabled");
            carregaSnapshots('geral','0');
        })


        //$.get("operacaoSnapShot.asp", {
        //    unidadeid: '<%=session("UnidadeID")%>',
        //    acao:'gravar'
        //}, function(data){
        //    console.log(data)
            //$('#snapModal').modal("hide");
        //    $('#btn-criar').removeAttr("disabled");
        //    carregaSnapshots('geral','0');
        //}).then((data) => {
        //    console.log(data)
        //    carregaSnapshots('geral','0');
        //});
    }

    
</script>