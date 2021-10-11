<!--#include file="connect.asp"-->
<!--#include file="Classes/StringFormat.asp"-->
<% hasPermissaoTela("tabelasprecos") %>

<script src="modulos/filterProcedimentos.js"></script>
<script src="modulos/utilitarios.js"></script>
<style>
    .tr-disabled{
        color: #9b9b9b;
        cursor: not-allowed;
    }

    .painel-header-flex{
        display:flex;
        justify-content: space-between;
        align-items: center;
    }
   #filtros #qfprofissionais, #filtros #qftabelasparticulares {
        height: 63px;
        display: flex;
        align-items: flex-end;
    }
    .listAlert{
        list-style: none;
        margin: 0;
        padding: 0;
    }
</style>

<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>

<%

call insertRedir("procedimentostabelas", req("I"))
set reg = db_execute("select * from procedimentostabelas where id="&req("I"))

TabelaID = req("I")
TipoTabela = req("TipoTabela")
TabelasParticulares = reg("TabelasParticulares")
Profissionais = reg("Profissionais")
Especialidades = reg("Especialidades")
Unidades = reg("Unidades")
NomeTabela = reg("NomeTabela")
exibirpreco = req("exibirpreco")
Convenios = reg("Convenios")

if TipoTabela="V" then
    prefixoPermissao = "tabelasprecos"
else
    prefixoPermissao = "tabelasprecoscusto"
end if

tiposAutorizados = ""

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

PermissaoParaEditar = aut(prefixoPermissao&"A")=1
PermissaoParaInserir = aut(prefixoPermissao&"I")=1


PermiteSolicitarAlteracao = not PermissaoParaEditar and ModoFranquia

IF reg("sysActive") = "0" THEN
    db.execute("UPDATE procedimentostabelas SET Unidades = null WHERE id = "&reg("id"))
    Unidades = ""
END IF

TipoTabela = reg("Tipo")


Tipo = "V"
label = "Valor Venda"

if  reg("Tipo") = "V" then
    label = "Valor Custo"
    Tipo = "C"
end if

queryTabelaParticular = " AND TabelasParticulares = '"&TabelasParticulares&"' "
if TabelasParticulares = "" then
    queryTabelaParticular = " AND (TabelasParticulares = '"&TabelasParticulares&"' or TabelasParticulares IS NULL) "
end if

queryprofissionais = " AND profissionais = '"&profissionais&"' "
if profissionais = "" then
    queryprofissionais = " AND (profissionais = '"&profissionais&"' or profissionais IS NULL) "
end if

queryespecialidade = " AND especialidades = '"&Especialidades&"' "
if Especialidades = "" then
    queryespecialidade = " AND (especialidades = '"&Especialidades&"' or especialidades IS NULL) "
end if
'Procurar referencia da outra tabela
'response.write("select * from procedimentostabelas where 1= 1 " & queryTabelaParticular & queryprofissionais & queryespecialidade &_
'    " and Unidades = '"&Unidades&"' and tipo = '"&Tipo&"' AND sysActive = 1 AND Inicio = "&mydatenull(reg("Inicio"))&" AND Fim = "&mydatenull(reg("Fim"))&" ")

sqlLimit = ""
nregistros = 3000
pag = req("pag")&""

set rsTotal = db_execute("select count(p.id) total from procedimentos p INNER join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& TabelaID &") where sysActive=1 and ativo='on'")
total = ccur(rsTotal("total"))
if total > nregistros then
    if pag = "" then
        pag = 1
    elseif pag <= 0 then
        pag =  1
    end if

    sqlLimit = " LIMIT " & ((pag - 1) * nregistros) & ", " & nregistros
end if


set regOutraTabela = db_execute("select *,IF(NomeTabela = '"&NomeTabela&"', 1,0) ordenacao  from procedimentostabelas where 1= 1 " & queryTabelaParticular & queryprofissionais & queryespecialidade &_
    " and Unidades = '"&Unidades&"' and tipo = '"&Tipo&"' AND sysActive = 1 AND Inicio = "&mydatenull(reg("Inicio"))&" AND Fim = "&mydatenull(reg("Fim"))&" ORDER BY ordenacao DESC LIMIT 1 ")

'INICIO DE CONDIÇÃO DE BLOQUEIO VALOR TABELA PARA UNIDADE - Airton 17-08-2020
sql = " SELECT  COALESCE( COUNT(*) > 1 OR unidades LIKE '%|0|%',false) AS bloquear          "&chr(13)&_
" FROM procedimentostabelas                                                           "&chr(13)&_
" JOIN vw_unidades ON cliniccentral.overlap(CONCAT('|',vw_unidades.id,'|'), unidades) "&chr(13)&_
"  WHERE procedimentostabelas.id = "&req("I")&";                                            "

set bloquearValor = db_execute(sql)

bloquearValorBool = false

IF  NOT bloquearValor.EOF THEN
    bloquearValorBool = (bloquearValor("bloquear")&"" = "1") AND ModoFranquiaUnidade
END IF

'FIM DE CONDIÇÃO DE BLOQUEIO VALOR TABELA PARA UNIDADE - Airton 17-08-2020


set SolicitacaoTabelaSQL = db_execute("SELECT s.*, count(sp.id) procedimentos  " &_
" FROM solicitacao_tabela_preco s " &_
" INNER JOIN solicitacao_tabela_preco_procedimentos sp ON sp.SolicitacaoID=s.id " &_
" WHERE TabelaPrecoID="&TabelaID & " AND Status='PENDENTE' HAVING procedimentos > 0")


%>
<form id="frmPT" class="mt20">
    <%
    if PermissaoParaEditar then
    %>
    <div class="panel  mtn hidden-print">
        <div class="panel-heading">
            <span class="panel-title"><i class="far fa-info-circle"></i> Filtros</span>
            <span class="panel-controls">
                <button type="button" onclick="HistoricoAlteracoes()" class="btn btn-default btn-sm" title="Histórico de alterações"><i class="far fa-history"></i> </button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeTabela", "Descrição", 3, reg("NomeTabela"), "", "", " required ") %>
                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2, reg("Tipo"), "select * from (select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda')t where id in ("&tiposAutorizados&")", "Tipo", " no-select2 semVazio required onchange='showTabela()' ") %>
                <%= quickfield("datepicker", "Inicio", "Vigência de", 2, reg("Inicio"), "", "", " required ") %>
                <%= quickfield("datepicker", "Fim", "até", 2, reg("Fim"), "", "", " required ") %>
                <div class="col-md-2">
                    <button type="button" class="btn btn-default mt25" onclick="openSlide()">Parâmetros adicionais <i class="far fa-chevron-down"> </i></button>
                </div>
            </div>
            <div class="row mt15" id="filtros" style="display:none;<%=franquia("display:block")%>">
                <div class="row mt15" >
                <%= quickField("multipleModal", "TabelasParticulares", "Tabelas / Parcerias", 3, TabelasParticulares, "", "columnToShow", "") %>
                <%= quickfield("multiple", "Especialidades", "Especialidades", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
                <%= quickField("multipleModal", "Profissionais", "Executantes", 3, Profissionais, "", "columnToShow", "") %>
                <%= quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
                </div>                                                                                                                                                                                                                                                                                                                                                                                                                                              
                <div class="row mt15" >
                <div id="campoconvenio" <% if reg("Tipo") <> "C" THEN %>style="display:none" <%end if%>> <%= quickField("multipleModal", "Convenios", "Convênios", 3, Convenios, "", "columnToShow", "") %> </div>
                <%= quickField("simpleCheckbox", "ExibirApenasPreco", "Exibir procedimentos com preço", "5", exibirpreco, " exibirpreco", "  ", "")%>
                </div>
                
            </div>
            
        </div>
    </div>
    <%
    end if
    %>

    <div class="panel">
        <div class="panel-heading">
            <div class='painel-header-flex'>
                <span class="panel-title"><i class="far fa-list"></i> Procedimentos</span>
                <!--<button class='btn btn-success text-right'><i class="far fa-plus"></i></button>-->
                <span class="panel-controls">
                    <button id="seach-tipo" class="btn btn-default btn-sm" type="button" onclick="toogleBtns('seach-tipo')">
                        <i class="far fa-search" aria-hidden="true"></i>
                    </button>
                    <%
                    if PermissaoParaInserir then
                    %>
                    <button id="add-procedimento" class="btn btn-success btn-sm" type="button" onclick="toogleBtns('add-procedimento')">
                        <i class="far fa-plus" aria-hidden="true"></i>
                    </button>
                    <%
                    end if
                    %>

                    <button class="btn btn-info btn-sm" name="Filtrate" onclick="print()" title="Imprimir" type="button"><i class="far fa-print bigger-110"></i></button>

                    <button type="button" class="btn btn-sm btn-success" title="Gerar Excel" onclick="downloadExcel()"><i class="far fa-table"></i></button>
                </span>
            </div>
        </div>
        <div class="panel-body">

                <div id='actions'>
                    <div class="seach-tipo" style="display: none;">
                        <div class="row">
                            <div class="col-md-6"></div>
                            <%=quickField("simpleSelect", "GrupoID", "Grupo", 3, "", "select * from procedimentosgrupos where sysActive=1 order by NomeGrupo", "NomeGrupo", "")%>
                            <div class="col-md-3">
                                <label>Procurar</label>
                                <input type="text" class="form-control " name="procurar" id="procurar" value="" placeholder="Filtre pelo nome...">
                            </div>
                            <!--<div id='nqfProcedimentos' class='col-md-3 ajaxFilter'></div>-->
                        </div>
                        <hr style="margin: 15px 0px"/>
                    </div>
                    <div class="add-procedimento" style="display: none;">
                        <div class="row">
                            <div class="col-md-9"></div>
                            <div id='nqfProcedimentos' class='col-md-3 ajaxFilter'></div>
                        </div>
                        <hr style="margin: 15px 0px"/>
                    </div>
                </div>

            <%


            if not SolicitacaoTabelaSQL.eof then
            %>
            <div class="alert alert-warning"><i class="far fa-exclamation-circle"></i> Existem solicitações em aberto para esta tabela de preço.</div>
            <%
            end if

            if PermiteSolicitarAlteracao then
                %>
            <div class="row">
                <div class="col-md-10"></div>
                <div class="col-md-2">
                    <button onclick="solicitarMudancas()" style="display: none;" class="btn-submit-solicitar-mudancas btn btn-sm btn-success " type="button"><i class="far fa-check-circle"></i> Solicitar mudanças</button>
                </div>
            </div>
                <%
            end if

            procedimentosIds="0"

            set ProcedimentosIdsSQL = db_execute("SELECT group_concat(idOrigem)ids FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID"))

            if not ProcedimentosIdsSQL.eof then
                procedimentosIds=ProcedimentosIdsSQL("ids")
            end if

            if procedimentosIds&""="" then
                procedimentosIds = "0"
            end if

            sql  = "SELECT p.PermiteAlteracaoDePrecoPelasUnidades, p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela,p.TipoProcedimentoID,TipoProcedimento, ptv.RecebimentoParcial "&_
                   "FROM procedimentos p "&_
                   "LEFT JOIN TiposProcedimentos ON TiposProcedimentos.id = p.TipoProcedimentoID "&_
                   "LEFT JOIN procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& TabelaID &") "&_
                   "WHERE "&franquiaUnidade("p.id in "&_ 
                   "( "&procedimentosIds&" ) AND ")&" sysActive=1 and ativo='on' AND ptv.Valor IS NOT NULL order by NomeProcedimento "

            set t = db_execute(sql)

            %>
            <div id="table-precos">
            <table class="table table-condensed table-hover mt25" >
                <thead>
                    <tr class="primary">
                        <th width="1%" class="hidden hidden-print"><input type="checkbox" onclick="$('.chk').prop('checked', $(this).prop('checked'))" /></th>
                        <th>Procedimento</th>
                        <th class="text-right">Tipo Procedimento</th>
                        <th class="text-right">Valor Base</th>
                        <th class="text-right hidden">Recebimento Parcial</th>
                        <th class="text-right">Valor Tabela</th>
                        <%
                        if PermiteSolicitarAlteracao then
                            %>
                            <th class="text-right">Solicitação</th>
                            <%
                        end if
                        %>
                    </tr>
                </thead>
                <tbody id='resultProcedimento'>

                <%
                    ProcedimentoBloqueadoParaUnidade = false
                    while not t.eof
                        response.Flush()
                        c = c+1

                        PermiteAlteracao = True

                        ValorBase = fn(t("Valor"))
                        TitleTr = ""

                        if t("PermiteAlteracaoDePrecoPelasUnidades")&""="" AND TipoTabela="V" and session("UnidadeID")<>0 and ModoFranquia then
                            PermiteAlteracao = False
                            ValorBase = ""
                            ProcedimentoBloqueadoParaUnidade = True
                            TitleTr = "Alteração de valor não permitida pela unidade"
                        end if

                        ValorTabela = t("ValorTabela")
                        ValorTabela2 = ""
                        id2 = ""
                        %>
                        <tr title="<%=TitleTr%>" data-toggle="tooltip" class="<% if not PermiteAlteracao then %>tr-disabled<% end if%> linha-procedimento" data-id="<%= (t("id")) %>" data-name="<%= UCASE(t("NomeProcedimento")&"") %>">
                            <td class="hidden hidden-print"><input type="checkbox" class="chk" name="chk<%= t("id") %>" /></td>
                            <td><span class="linha-nome-procedimento"><%= t("NomeProcedimento") %></span></td>
                            <td class="text-right"><%= t("TipoProcedimento") %></td>
                            <td class="text-right"  width="100"><%= ValorBase %></td>
                            <td class="text-right hidden" width="150"><%= quickfield("currency", "RecebimentoParcial_"& t("id"), "", 12, t("RecebimentoParcial"), "", "", " onchange=changeValorTabela(this,'"&t("id")&"','"&TabelaID&"','RecebimentoParcial') ") %></td>
                            <% if idOutraTabela <> 0 then %>
                            <td class="text-right" width="150">
                            <%= quickfield("currency", "ValorTabela"&idOutraTabela&"_"& id2, "", 12, ValorTabela2, "", "",  " onchange=changeValorTabela(this,'"&t("id")&"','"&idOutraTabela&"','Valor') ") %></td>
                            <% end if %>
                            <td class="text-right" width="150">
                                <% if not PermissaoParaEditar then %>
<input type="hidden" class="linha-valor-tabela" name="<%= "ValorTabela"& t("id") %>" value="<%=ValorTabela%>" />
<i>R$ <%=fn(ValorTabela)%></i>
                                <%elseif not PermiteAlteracao then%>
<input type="hidden" class="linha-valor-tabela" name="<%= "ValorTabela"& t("id") %>" value="<%=ValorTabela%>" />
<i>Padrão</i>
                                <%else%>
                                <%= quickfield("currency", "ValorTabela"& t("id"), "", 12, ValorTabela, "", "", " onchange=changeValorTabela(this,'"&t("id")&"','"&TabelaID&"','Valor') ") %>
                                <%end if%>
                            </td>
                            <%
                            if PermiteSolicitarAlteracao then
                                %>
                                <td class="text-right">
                                    <input style="display: none;" class="solicitar-alteracao-ipt text-right form-control input-sm" placeholder="Digite..." value="<%=fn(ValorTabela)%>"/>

                                    <button onclick="proporValorProcedimento('<%= t("id") %>')" class="solicitar-alteracao-btn btn btn-xs btn-default" type="button" title="Solicitar alteração de valor">
                                        <i class="far fa-edit"></i>
                                    </button>
                                </td>
                                <%
                            end if
                            %>
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
    </div>



    <div>
        Criado em <%=reg("sysDate")%> por <%=nameInTable(reg("sysUser"))%>
    </div>
    <button type="submit" class="hidden" id="Salvar"></button>
</form>

<script type="text/javascript">
    setTimeout(() => {
        fetch(`operacaoSnapShot.asp?acao=gravar-tabela&tabelaid=<%=TabelaID%>`)
        .then((res) => {
           console.log(res)
        }).catch(() => {
            console.log(res)
        })
    },1000);

    $(".crumb-active a").html("Preços de Custo e Venda");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("edição de tabela de preço");
    $(".crumb-icon a span").attr("class", "far fa-table");
    <%
    if PermissaoParaEditar then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-default" href="./?P=TabelasPreco&Pers=1"><i class="far fa-list"></i></a> <button onclick="$(\'#Salvar\').click()" class="btn btn-sm btn-primary"><i class="far fa-save"></i> SALVAR</button>');
    <%
        end if
    %>

        $("#frmPT").submit(function () {
            <% IF ModoFranquia THEN %>
                if($(".fa-save").length === 0){
                    return false;
                }

                if(!$("#Unidades").val()){
                        new PNotify({
                            title: 'ERRO!',
                            text: 'Informe ao menos uma unidades.',
                            type: 'danger',
                            delay: 2500
                        });
                    return false;
                }
            <% END IF %>
            // console.log($(this).serialize())
            $.post("saveProcedimentosTabela.asp?I=<%=req("I")%>", $(this).serialize(), function (data) {
                checkTables(()=>{
                    eval(data) 
                })
            });
            return false;
        });

        function checkTables (callback){
            $.get('checkTables.asp?I=<%=req("I")%>')
            .done(function(data) {
                data = JSON.parse(data)
                console.log(data)
                if(data.length>0){
                    msg = `<p>Existem tabelas com configurações semelhantes.</p>`
                    list = '<ul class="listAlert">'
                    data.map(elem=>{

                        let item = `<li><a target='_blank' href='?P=procedimentostabelas2&I=${elem.id}&Pers=1'>${elem.NomeTabela}</a></li>`

                        list += item; 
                    })

                    list+="</ul>"

                    Swal.fire({
                        icon: 'info',
                        allowOutsideClick:false,
                        html:
                            '<h3><b>Existem configurações de preços semelhantes</b></h3>' +
                            msg +
                            list,
                        confirmButtonText: `Ok`
                    }).then((result) => {
                        if (result.isConfirmed) {
                            callback(data)
                        } 
                    })
                }else{
                    callback(true)
                }
            })
        }

        $(function(){
            $(".next, .prev").on('click', function(){
                var pag = $(this).attr("data-value");

                var url = new URL(window.location.href);
                url.searchParams.set('exibirpreco','');
                url.searchParams.set('pag',pag);

                window.location.href = url.href;
            })


            $(".exibirpreco").on('click', function(){
                var url = new URL(window.location.href);
                if($(this).is(":checked")){
                    url.searchParams.set('exibirpreco','S');
                }else{
                    url.searchParams.set('exibirpreco','');
                }
                window.location.href = url.href;
            });
        })

    var valueInterval = null

    const renderLoading = () => {
        const loadingHtml = `<tr>
                                <td colspan="6">
                                    <center><i class="far fa-circle-o-notch fa-spin"></i> <span>Buscando...</span></center>
                                </td>
                            </tr>`;
        $('#resultProcedimento').html(loadingHtml);

    }

    const doSearch = () => {

        let valor = $('#procurar').val();
        let grupoId = $("#GrupoID").val();
        clearResults();
        renderLoading();

        let parametros = `nome=${valor}&grupoId=${grupoId}&tabelaId=<%=TabelaID%>&tipo=<%=Tipo%>`
        if(valor.length >= 3){
            let rows = $('#resultProcedimento > tr')
            utilitarios.request('consulta/getProcedimentos',parametros,(data)=>{
                data = JSON.parse(data)
                clearResults();
                populateResult(data)
            })
        }else if(valor.length === 0){
            utilitarios.request('consulta/getProcedimentos',parametros,(data)=>{
                data = JSON.parse(data)
                clearResults();
                populateResult(data)
            })
        }
    }

    $('#procurar').keyup((event)=>{
        clearInterval(valueInterval);
        valueInterval = setTimeout(() => {
            doSearch();
        },500);
    });

    $('#GrupoID').change((event)=>{
        clearInterval(valueInterval);
        valueInterval = setTimeout(() => {
            doSearch();
        },500);
    });

    function showTabela()
    {
        if ($('#Tipo option:selected').val()=='C')
        {
            $('#campoconvenio').show();
        }
        else
        {
            $('#campoconvenio').hide();
        }
    }

    function populateResult (data){
        data.map(element=>{
            filterProcedimentos.addRow(element,false)
        })
    }
    function clearResults(){
        $('#resultProcedimento > tr').detach()
    }

    function HistoricoAlteracoes() {
        openComponentsModal("LogUltimasAlteracoes.asp", {
            Tabelas: "procedimentostabelas,procedimentostabelasvalores",
            ID: "<%=TabelaID%>",
            PaiID: "<%=TabelaID%>",
            TipoPai: "TabelaID",
        }, "Log de alterações", true);
    }
    <% 'INICIO BLOQUEIO DE VALOR TABELA PARA UNIDADE - Airton 17-08-2020 %>
    <% if bloquearValorBool then %>
        function changeValorTabela(arg,procedimentoId,tabelaID,tipo){
            new PNotify({
                title: 'Cuidado!',
                text: 'Apenas a matriz pode editar este registro',
                type: 'danger',
                delay:1000
            });
        }
        $(document).ready(()=>$("#rbtns").html(""));
    <% else %>
        function changeValorTabela(arg,procedimentoId,tabelaID,tipo){
            let valor = arg.value;
            $.post("SaveValorProcedimentosTabelas.asp",{procedimentoId,tabelaID,tipo,valor})
            .then((data) => {
                showMessageDialog('Valor atualizado com sucesso',"success")
            });
        }

    <% end if %>
    <%'FIM BLOQUEIO DE VALOR TABELA PARA UNIDADE - Airton 17-08-2020 %>

    function toogleBtns(classe){
        let rows = $('#actions > div')
        rows.filter((key,linha)=>{
            if($(linha).hasClass(classe)){
                $(linha).toggle()
            }else{
                $(linha).hide()
            }
        })
    }
    function openSlide(){
        if($('#filtros').css('display') == 'none'){
            $('#filtros').slideDown()
        }else{
            $('#filtros').slideUp()
        }
    }
    filterProcedimentos.init({
        seletor     : 'nqfProcedimentos',
        title       : 'Procedimentos',
        name        : 'procedimentos',
        result      : 'resultProcedimento',
        place       :   'Busque procedimento pelo nome',
        tabelaId    : '<%=TabelaID%>',
        tipo        : '<%=TipoTabela%>',
        filterOn    : 3,
        allowChange : '<% if PermissaoParaEditar then response.write(1) else response.write(0) end if %>',
        allowRequestChange: '<% if PermiteSolicitarAlteracao then response.write(1) else response.write(0) end if %>',
    },utilitarios);

    linhasPropostaAlteracao = [];

    function proporValorProcedimento(linhaId){
        if(linhasPropostaAlteracao.indexOf(linhaId) === -1){
            linhasPropostaAlteracao.push(linhaId);
        }

        $linha = $(".linha-procedimento[data-id="+linhaId+"]")

        $(".btn-submit-solicitar-mudancas").fadeIn();

        $linha.find(".solicitar-alteracao-btn").fadeOut(function(){
            $linha.find(".solicitar-alteracao-ipt").fadeIn().maskMoney({prefix:'', thousands:'.', decimal:',', affixesStay: true}).focus();
        });
    }

    function submitSolicitarMudancas(data){
        parametros = data
        motivo = $("#MotivoSolicitacaoTabela").val()

        $.post("modulos/tabela_preco/SalvarSolicitarMudancaTabelaPreco.asp",{
            alteracoes: data.alteracoes,
            linhas: data.linhas,
            motivo: motivo,
            tabela_preco_id: "<%=req("I")%>"
        }, function(data){
            closeComponentsModal();
            showMessageDialog("Solicitação salva com sucesso.", "success");

            setTimeout(function(){
                location.reload();
            }, 500);
        });

    }

    function getMudancasObj(){
        return linhasPropostaAlteracao.map((item) => {
            let $linha = $(".linha-procedimento[data-id="+item+"]");
            nome = $linha.find(".linha-nome-procedimento").text();
            valorAnterior = $linha.find(".linha-valor-tabela").val();
            valorProposto = $linha.find(".solicitar-alteracao-ipt").val();

            return {
                "procedimento_id": item,
                "nome": nome,
                "valor_anterior": valorAnterior,
                "valor_proposto": valorProposto
            }
        });
    }

    function solicitarMudancas(){

        openComponentsModalPost("modulos/tabela_preco/SolicitarMudancaTabelaPreco.asp", {
            linhas: linhasPropostaAlteracao,
            alteracoes: getMudancasObj()
        }, "Solicitar mudanças na tabela de preço", true, submitSolicitarMudancas);
    }

    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });

    function downloadExcel(){
        $("#htmlTable").val($("#table-precos").html());
        $("#formExcel").attr("action", domain+"reports/download-excel?title=<%=NomeTabela%>&tk=" + localStorage.getItem("tk")).submit();
    }

</script>
