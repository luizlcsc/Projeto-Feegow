<!--#include file="connect.asp"-->
<%
call insertRedir("procedimentostabelas", req("I"))
set reg = db.execute("select * from procedimentostabelas where id="&req("I"))

TabelaID = req("I")
TabelasParticulares = reg("TabelasParticulares")&""
Profissionais = reg("Profissionais")&""
Especialidades = reg("Especialidades")&""
Unidades = reg("Unidades")&""
NomeTabela = reg("NomeTabela")&""
exibirpreco = req("exibirpreco")&""




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

set rsTotal = db.execute("select count(p.id) total from procedimentos p left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& TabelaID &") where sysActive=1 and ativo='on' order by NomeProcedimento")
total = ccur(rsTotal("total"))
if total > nregistros then
    if pag = "" then 
        pag = 1
    elseif pag <= 0 then 
        pag =  1
    end if
    
    sqlLimit = " LIMIT " & ((pag - 1) * nregistros) & ", " & nregistros
end if


set regOutraTabela = db.execute("select *,IF(NomeTabela = '"&NomeTabela&"', 1,0) ordenacao  from procedimentostabelas where 1= 1 " & queryTabelaParticular & queryprofissionais & queryespecialidade &_
    " and Unidades = '"&Unidades&"' and tipo = '"&Tipo&"' AND sysActive = 1 AND Inicio = "&mydatenull(reg("Inicio"))&" AND Fim = "&mydatenull(reg("Fim"))&" ORDER BY ordenacao DESC LIMIT 1 ")


sqlProfissionais = "select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' UNION ALL select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor') from fornecedores where sysActive=1 and (TipoPrestadorID is null or TipoPrestadorID=1) and Ativo='on' UNION ALL (select concat('8_', id), concat(NomeProfissional, ' - Externo') from profissionalexterno where sysActive=1 order by NomeProfissional limit 1000)"
sqlProfissionais = " select id, NomeProfissional,profissionais.Unidades                    "&chr(13)&_
                   " from profissionais                                                    "&chr(13)&_
                   " where sysActive = 1                                                   "&chr(13)&_
                   "   and ativo = 'on'                                                    "&chr(13)&_
                   " UNION ALL                                                             "&chr(13)&_
                   " select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor'),null "&chr(13)&_
                   " from fornecedores                                                     "&chr(13)&_
                   " where sysActive = 1                                                   "&chr(13)&_
                   "   and (TipoPrestadorID is null or TipoPrestadorID = 1)                "&chr(13)&_
                   "   and Ativo = 'on'                                                    "&chr(13)&_
                   " UNION ALL                                                             "&chr(13)&_
                   " (select concat('8_', id), concat(NomeProfissional, ' - Externo'),null "&chr(13)&_
                   "  from profissionalexterno                                             "&chr(13)&_
                   "  where sysActive = 1                                                  "&chr(13)&_
                   "  order by NomeProfissional                                            "&chr(13)&_
                   "  limit 1000)                                                          "

sqlProfissionais = "SELECT * FROM ("&sqlProfissionais&") AS t "&franquia(" WHERE COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")

%>
<form id="frmPT">
    <div class="panel mt20 mtn hidden-print">
        <div class="panel-heading">
            <span class="panel-title"><i class="fa fa-info-circle"></i> Detalhes da tabela de preço</span>
            <span class="panel-controls">
                <button type="button" onclick="HistoricoAlteracoes()" class="btn btn-default btn-sm" title="Histórico de alterações"><i class="fa fa-history"></i> </button>
                <button class="btn btn-info btn-sm" name="Filtrate" onclick="print()" type="button"><i class="fa fa-print bigger-110"></i></button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeTabela", "Nome da tabela", 3, reg("NomeTabela"), "", "", " required ") %>
                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2, reg("Tipo"), "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 semVazio required ") %>
                <%= quickfield("datepicker", "Inicio", "Vigência de", 2, reg("Inicio"), "", "", " required ") %>
                <%= quickfield("datepicker", "Fim", "até", 2, reg("Fim"), "", "", " required ") %>
                <div class="col-md-2">
                    <button type="button" class="btn btn-default mt25" onclick="$('#filtros').slideDown()">Parâmetros adicionais <i class="fa fa-chevron-down"> </i></button>
                </div>
            </div>
            <div class="row mt15" id="filtros" style="display:none;<%=franquia("display:block")%>">
                <%= quickfield("multiple", "TabelasParticulares", "Tabelas Particulares", 3, TabelasParticulares, "select * from tabelaparticular where  sysActive=1 order by NomeTabela", "NomeTabela", "") %>
                <%= quickfield("multiple", "Profissionais", "Executantes", 3, Profissionais, sqlProfissionais, "NomeProfissional", "") %>
                <%= quickfield("multiple", "Especialidades", "Especialidades", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
                <%=quickField("simpleCheckbox", "ExibirApenasPreco", "Exibir procedimentos com preço", "5", exibirpreco, " exibirpreco", "  ", "")%>
            </div>
        </div>
    </div>
    <div class="panel">

        <div class="panel-heading">
            <span class="panel-title"><i class="fa fa-list"></i> Procedimentos da tabela</span>
        </div>
        <div class="panel-body">
            <div class="pull-right" style="position: absolute; right: 0%; margin-right: 15px;z-index: 2"><a id="openConsulta" class="btn btn-dark btn-xs" href="javascript:void(0)" onclick="$('.seach-tipo').toggle()"><i class="fa fa-search" aria-hidden="true"></i></a></div>
            <div class="seach-tipo" style="display: none;">
                <div class="row">
                    <div class="col-md-6"></div>
                    <%=quickField("simpleSelect", "TipoProcedimentoID", "Tipo", 3, "", "select * from TiposProcedimentos", "TipoProcedimento", "")%>
                    <%= quickfield("text", "NomeProcedimento", "Procedimento", 3, "", " ", "", "  ") %>
                </div>
                <script>
                     function filterProcedimento(){
                            let arg = $("#NomeProcedimento").val().toUpperCase();
                            let arg2 = $("#TipoProcedimentoID").val();
                            $("[data-name]").show();
                            arg &&  $("[data-name]:not([data-name*='"+arg+"'])").hide();
                            arg2 > 0 &&  $("[data-name]:not([data-tipo*='"+arg2+"'])").hide();

                    }
                    $(document).ready(function () {
                        $("#NomeProcedimento").keyup(filterProcedimento)
                        $("#TipoProcedimentoID").change(filterProcedimento)
                    })
                </script>
                <hr style="margin: 15px 0px"/>
            </div>
            <table class="table table-condensed table-hover mt25">
            <%
            sqlApenasValor = ""
            if exibirpreco = "S" then
                sqlApenasValor = " AND ptv.Valor IS NOT NULL "
            end if

            c = 0
            idOutraTabela = 0
            set tt = db.execute("select 1 from sys_config where false")
            sql = ("select p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela,p.TipoProcedimentoID,TipoProcedimento from procedimentos p LEFT JOIN TiposProcedimentos ON TiposProcedimentos.id = p.TipoProcedimentoID left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& TabelaID &") where "&franquiaUnidade("p.id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&" ) AND ")&" sysActive=1 and ativo='on' "& sqlApenasValor &" order by NomeProcedimento " & sqlLimit)
            set t = db.execute(sql)
            if not regOutraTabela.eof then
                idOutraTabela = regOutraTabela("id")
                set tt = db.execute("select p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela from procedimentos p left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& regOutraTabela("id") &") where  "&franquiaUnidade("p.id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&" ) AND ")&"  sysActive=1 and ativo='on' order by NomeProcedimento " & sqlLimit)
            end if
            %>
                <thead>
                    <tr class="primary">
                        <th width="1%" class="hidden hidden-print"><input type="checkbox" onclick="$('.chk').prop('checked', $(this).prop('checked'))" /></th>
                        <th>Procedimento</th>
                        <th class="text-right">Tipo Procedimento</th>
                        <th class="text-right">Valor Base</th>
                        <%
                        if idOutraTabela<>0 then
                        %>
                        <th class="text-right"><%=label%></th>
                        <%
                        end if
                        %>
                        <th class="text-right">Valor Tabela</th>
                    </tr>
                </thead>
                <tbody>
                    <%

                    response.write("<input type='hidden' name='idoutratabela' value='" & idOutraTabela& "' />")

                    while not t.eof
                        response.Flush()
                        c = c+1

                        ValorTabela = t("ValorTabela")
                        ValorTabela2 = ""
                        id2 = ""
                        
                        if not tt.eof then
                            ValorTabela2 = tt("ValorTabela")
                            id2 = tt("id")

                            tt.movenext
                        end if
                        
                        %>
                        <tr data-tipo="<%= (t("TipoProcedimentoID")) %>" data-name="<%= UCASE(t("NomeProcedimento")&"") %>">
                            <td class="hidden hidden-print"><input type="checkbox" class="chk" name="chk<%= t("id") %>" /></td>
                            <td><%= t("NomeProcedimento") %></td>
                            <td class="text-right"><%= t("TipoProcedimento") %></td>
                            <td class="text-right"  width="100"><%= fn(t("Valor")) %></td>
                            <%
                            if idOutraTabela<>0 then
                            %>
                            <td class="text-right" width="150"><%= quickfield("currency", "ValorTabela"&idOutraTabela&"_"& id2, "", 12, ValorTabela2, "", "", "") %></td>
                            <%
                            end if
                            %>
                            <td class="text-right" width="150"><%= quickfield("currency", "ValorTabela"& t("id"), "", 12, ValorTabela, "", "", "") %></td>
                            
                        </tr>
                        <%
                    t.movenext
                    wend
                    t.close
                    set t=nothing
                    set tt=nothing
                    %>
                </tbody>
                <tfoot>
                    <tr class="dark">
                        <th colspan="10"><%= c %> procedimentos</th>
                    </tr>
                </tfoot>
            </table>
            <div>
        <% if total > nregistros then
                proxima = pag + 1
                anterior = 1
                if pag > 1 then 
                    anterior = pag - 1
                end if
         %>
         <ul class="pagination pagination-sm">
            <li><a href="#" data-value="<%=anterior%>" class="next">Anterior</a></li>
            <li><a href="#" data-value="<%=proxima%>" class="prev">Próximo</a></li>
            </ul>
        <% end if %>
        </div>
        </div>


    </div>



        <div>
            Criado em <%=reg("sysDate")%> por <%=nameInTable(reg("sysUser"))%>
        </div>
    <button type="submit" class="hidden" id="Salvar"></button>
</form>

<script type="text/javascript">
    $(".crumb-active a").html("Tabelas de Preço");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("edição de tabela de preço");
    $(".crumb-icon a span").attr("class", "fa fa-table");
    <%
    if aut("tabelasprecosA")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-default" href="./?P=TabelasPreco&Pers=1"><i class="fa fa-list"></i></a> <button onclick="$(\'#Salvar\').click()" class="btn btn-sm btn-primary"><i class="fa fa-save"></i> SALVAR</button>');
    <%
        end if
    %>

        $("#frmPT").submit(function () {
            <% IF ModoFranquia THEN %>
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

            $.post("saveProcedimentosTabela.asp?I=<%=req("I")%>", $(this).serialize(), function (data) { eval(data) });
            return false;
        });
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

    //
        
               
        })


    function HistoricoAlteracoes() {
        openComponentsModal("LogUltimasAlteracoes.asp", {
            Tabelas: "procedimentostabelas,procedimentostabelasvalores",
            ID: "<%=TabelaID%>",
            PaiID: "<%=TabelaID%>",
            TipoPai: "TabelaID",
        }, "Log de alterações", true);
    }

</script>