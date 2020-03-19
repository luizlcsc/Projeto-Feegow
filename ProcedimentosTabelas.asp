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
nregistros = 1500
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

%>
<form id="frmPT">
    <div class="panel mt20 mtn hidden-print">
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeTabela", "Nome da tabela", 3, reg("NomeTabela"), "", "", " required ") %>
                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2, reg("Tipo"), "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 semVazio required ") %>
                <%= quickfield("datepicker", "Inicio", "Vigência de", 2, reg("Inicio"), "", "", " required ") %>
                <%= quickfield("datepicker", "Fim", "até", 2, reg("Fim"), "", "", " required ") %>
                <div class="col-md-2">
                    <button type="button" class="btn btn-warning mt25" onclick="$('#filtros').slideDown()">Parâmetros adicionais <i class="fa fa-chevron-down"> </i></button>
                </div>
                <div class="col-md-1">
                    <label>&nbsp;</label><br />
                    <button class="btn btn-info" name="Filtrate" onclick="print()" type="button"><i class="fa fa-print bigger-110"></i></button>
                </div>
            </div>
            <div class="row mt15" id="filtros" style="display:none">
                <%= quickfield("multiple", "TabelasParticulares", "Tabelas Particulares", 3, TabelasParticulares, "select * from tabelaparticular where sysActive=1 order by NomeTabela", "NomeTabela", "") %>
                <%= quickfield("multiple", "Profissionais", "Executantes", 3, Profissionais, "select id, NomeProfissional from profissionais where sysActive=1 and ativo='on' UNION ALL select concat('2_', id), concat(NomeFornecedor, ' - Fornecedor') from fornecedores where sysActive=1 and (TipoPrestadorID is null or TipoPrestadorID=1) and Ativo='on' UNION ALL (select concat('8_', id), concat(NomeProfissional, ' - Externo') from profissionalexterno where sysActive=1 order by NomeProfissional limit 1000)", "NomeProfissional", "") %>
                <%= quickfield("multiple", "Especialidades", "Especialidades", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
                <%=quickField("simpleCheckbox", "ExibirApenasPreco", "Exibir procedimentos com preço", "5", exibirpreco, " exibirpreco", "  ", "")%>
            </div>
            
        </div>
    </div>
    <div class="panel">
        <div class="panel-body">
            <table class="table table-condensed table-hover">
            <%
            sqlApenasValor = ""
            if exibirpreco = "S" then
                sqlApenasValor = " AND ptv.Valor IS NOT NULL "
            end if

            c = 0
            idOutraTabela = 0
            set tt = db.execute("select 1 from sys_config where false")
            set t = db.execute("select p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela from procedimentos p left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& TabelaID &") where sysActive=1 and ativo='on' "& sqlApenasValor &" order by NomeProcedimento " & sqlLimit)
            if not regOutraTabela.eof then
                idOutraTabela = regOutraTabela("id")
                set tt = db.execute("select p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela from procedimentos p left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& regOutraTabela("id") &") where sysActive=1 and ativo='on' order by NomeProcedimento " & sqlLimit)
            end if
            %>
                <thead>
                    <tr>
                        <th width="1%" class="hidden-print"><input type="checkbox" onclick="$('.chk').prop('checked', $(this).prop('checked'))" /></th>
                        <th>Procedimento</th>
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
                        <tr>
                            <td class="hidden-print"><input type="checkbox" class="chk" name="chk<%= t("id") %>" /></td>
                            <td><%= t("NomeProcedimento") %></td>
                            <td class="text-right"><%= fn(t("Valor")) %></td>
                            <%
                            if idOutraTabela<>0 then
                            %>
                            <td class="text-right" width="150"><%= quickfield("currency", "ValorTabela2_"& id2, "", 12, ValorTabela2, "", "", "") %></td>
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
                    <tr>
                        <td colspan="10"><%= c %> procedimentos</td>
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
                
        
        <div>
            Gerado em <%=reg("sysDate")%> por <%=nameInTable(reg("sysUser"))%>
        </div>

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

</script>