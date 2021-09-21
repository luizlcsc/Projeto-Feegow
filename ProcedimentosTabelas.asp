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
    "and Unidades = '"&Unidades&"' and tipo = '"&Tipo&"' AND sysActive = 1 AND Inicio = "&mydatenull(reg("Inicio"))&" AND Fim = "&mydatenull(reg("Fim"))&" ORDER BY ordenacao DESC LIMIT 1 ")


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
            <span class="panel-title"><i class="far fa-info-circle"></i> Detalhes da tabela de preço</span>
            <span class="panel-controls">
                <button type="button" onclick="HistoricoAlteracoes()" class="btn btn-default btn-sm" title="Histórico de alterações"><i class="far fa-history"></i> </button>
                <button class="btn btn-info btn-sm" name="Filtrate" onclick="print()" type="button"><i class="far fa-print bigger-110"></i></button>
            </span>
        </div>
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "NomeTabela", "Nome da tabela", 3, reg("NomeTabela"), "", "", " required ") %>
                <%= quickfield("simpleSelect", "Tipo", "Tipo", 2, reg("Tipo"), "select 'C' id, 'Custo' Tipo UNION ALL select 'V', 'Venda'", "Tipo", " no-select2 semVazio required ") %>
                <%= quickfield("datepicker", "Inicio", "Vigência de", 2, reg("Inicio"), "", "", " required ") %>
                <%= quickfield("datepicker", "Fim", "até", 2, reg("Fim"), "", "", " required ") %>
                <div class="col-md-3">
                    <button type="button" class="btn btn-default btn-sm mt25 btn-block" onclick="$('#filtros').slideToggle()">Parâmetros adicionais <i class="fa fa-chevron-down"> </i></button>
                    <button type="button" class="btn btn-default btn-sm mt5 btn-block" onclick="$('#inflatorDeflator').slideToggle()">Inflator / Deflator <i class="fa fa-chevron-down"> </i></button>                    
                    <button type="button" class="btn btn-default btn-sm mt5 btn-block" onclick="$('#atuacaoContent').slideToggle()">Despesas anexas <i class="fa fa-chevron-down"> </i></button>
                </div>

            </div>
            
            <div class="row mt5" id="inflatorDeflator" style="display:none">
                <div class="col-md-12  mt14" style="margin-top:30px;">
                    <h4>Inflator / Deflator</h4>

                    <div class="col-md-4" >
                        <label for="Tipo">Tipo de variação</label>  
                        <div class="btn-group" style="width: 98%;">
                            <select name="TipoDeVariacao" id="TipoDeVariacao" class=" form-control">
                                <option  value="+">Inflator(+)</option>
                                <option  value="-">Deflator(-)</option>
                            </select>                            
                        </div>
                    </div>
            
                    <div class="col-md-3">       
                        <label for="Valor">Valor (%)</label>        
                        <input type="text" class="form-control " name="Valor" id="Valor" value="20">
                    </div>
            
                    <div class="col-md-2 mt15" style="width:9.8em;">       
                        <div type="submit" class="form-control btn-success"  id="AplicarRegra" value="Aplicar Agora" style="margin-top:10px; cursor: pointer;" >Aplicar Regra</div>
                    </div>
                </div>
            </div>

            <div class="row mt5" id="filtros" style="display:none;<%=franquia("display:block")%>">
                <%= quickfield("multiple", "TabelasParticulares", "Tabelas Particulares", 3, TabelasParticulares, "select * from tabelaparticular where  sysActive=1 order by NomeTabela", "NomeTabela", "") %>
                <%= quickfield("multiple", "Profissionais", "Executantes", 3, Profissionais, sqlProfissionais, "NomeProfissional", "") %>
                <%= quickfield("multiple", "Especialidades", "Especialidades", 3, Especialidades, "select id, especialidade from especialidades where sysActive=1 order by especialidade", "especialidade", "") %>
                <%=quickField("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", "")%>
                <%=quickField("simpleCheckbox", "ExibirApenasPreco", "Exibir procedimentos com preço", "5", exibirpreco, " exibirpreco", "  ", "")%>
            </div>

            <div class="row mt5" id="atuacaoContent" style="display:none;" >
                <div class="col-md-4 mt15"  >
                
                    <div class="btn-group open" style="width: 98%;">
                        <label for="Atuacao">Atuação</label>  
                        <select name="Atuacao" id="Atuacao" class=" form-control">
                            <option value="|procedimentos|" selected>Procedimentos</option>
                            <option value="|Materiais|">Materiais ou Medicamentos</option>
                        </select>
                            
                    </div>
                </div>
                
            <div class="col-md-3 mt15" id="tabelas" style="display:none;" >
                <div class="btn-group open" style="width: 98%;">
                <label for="NomeTabela">Tabela Base</label> 
                <select name="TabelaBase" id="TabelaBase" class="form-control ClassTabelaBase">
            
            <div id="inflatorDeflatorContent" class="row mt15 " style="display:none;" >
                <div class="col-md-2" >
                    <label for="Tipo">Tipo de variação</label>  
                    <div class="btn-group" style="width: 98%;">
                        <select name="TipoDeVariacao" id="TipoDeVariacao" class=" form-control">
                                <option  value="+">Inflator(+)</option>
                                <option  value="-">Deflator(-)</option>
                                
                        </select>                            
                            
                    
                    </div>
                </div>

                <div class="col-md-2">       
                    <label for="Valor">Valor (%)</label>        
                    <input type="text" class="form-control " name="Valor" id="Valor" value="20">
                </div>
            </div>
            
    

        </div>
    </div>

    <div class="panel">

        <div class="panel-heading">
            <span class="panel-title">
            <i class="far fa-list">
            </i> Procedimentos da tabela
            </span>
        </div>
        
        <div class="panel-body">
            <div class="pull-right" style="position: absolute; right: 0%; margin-right: 15px;z-index: 2"><a id="openConsulta" class="btn btn-dark btn-xs" href="javascript:void(0)" onclick="$('.seach-tipo').toggle()"><i class="far fa-search" aria-hidden="true"></i></a></div>
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
                            
             sqlProdutos = ("SELECT * , prod.id as IDproduto   , proc.PrecoPFB as PFB , proc.PrecoPMC as PMC  FROM produtos AS prod LEFT JOIN produtosvalores AS proc ON (proc.ProdutoID = prod.id) WHERE prod.sysActive = 1 AND prod.TipoProduto IN(1) OR prod.TipoProduto IN(5)")
                set produtos = db.execute(sqlProdutos)
            sql = ("select DISTINCT p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela,p.TipoProcedimentoID,TipoProcedimento from procedimentos p LEFT JOIN TiposProcedimentos ON TiposProcedimentos.id = p.TipoProcedimentoID left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id AND ptv.TabelaID = "&req("I")&") where "&franquiaUnidade("p.id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&" ) AND ")&" sysActive=1 and ativo='on' "& sqlApenasValor &"  order by NomeProcedimento " & sqlLimit)
                set t = db.execute(sql)
            if not regOutraTabela.eof then
                idOutraTabela = regOutraTabela("id")
                set tt = db.execute("select p.id, p.NomeProcedimento, p.Valor, ptv.Valor ValorTabela from procedimentos p left join procedimentostabelasvalores ptv on (ptv.ProcedimentoID=p.id and ptv.TabelaID="& regOutraTabela("id") &") where  "&franquiaUnidade("p.id in (SELECT idOrigem FROM registros_importados_franquia WHERE tabela = 'procedimentos' AND unidade = "&session("UnidadeID")&" ) AND ")&"  sysActive=1 and ativo='on' order by NomeProcedimento " & sqlLimit)
            end if
            %>
                <thead>
                    <tr class="primary">
                        <th width="1%" class="">
                        <input type="checkbox" onclick="$('.chk').prop('checked', $(this).prop('checked'))"      id="checkbox-proc" />
                        <input type="checkbox" onclick="$('.ProdutoId').prop('checked', $(this).prop('checked'))" id="checkbox-prod" style="display:none;"/>
                        </th>
                
                        <th class="procOu">Procedimento</th>
                        <th class="text-right tipo_proc">Tipo Procedimento</th>
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
                <tbody class="procedimento-body">
                    <%
                    produtoCount = 0
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
                        <tr data-tipo="<%= (t("TipoProcedimentoID")) %>" data-name="<%= UCASE(t("NomeProcedimento")&"") %>" id="<%=t("TipoProcedimentoID") %>">
                            <td class=""><input type="checkbox" class="chk" name="chk<%= t("id") %>"  value="<%= t("id") %>"/></td>
                            <td><%= t("NomeProcedimento") %></td>
                            <td class="text-right"><%= t("TipoProcedimento") %></td>
                            <td class="text-right" id="Valor-base<%= t("id") %>" width="100"><%= fn(t("Valor")) %></td>
                            <%
                            if idOutraTabela<>0 then
                            %>
                            <td class="text-right" width="150"><%= quickfield("currency", "ValorTabela"&idOutraTabela&"_"& id2, "", 12, ValprodutosorTabela2, "", "", "") %></td>
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
                <tbody class="produto-body">
               <div class="container spiner-tabela">               
               <div class="col-md-6">
               <div class="configdiv">
               </div>
               </div>
                    <i class='far fa-spin fa-spinner center spinner'></i>
                    <div class="col-md-6">
                        <div class="configdiv">
                            ...
                        </div>
                     </div>
                </div>
               
                 
                    <%               
                        while not produtos.eof
                        response.Flush()
                        
                        produtoCount =  produtoCount +1
                        id2 = ""
                        Base = produtos("PFB")
                        Tabela = produtos("PMC")
                    
                    produtos.movenext
                    wend
                    produtos.close
                    set produtos=nothing
                    set produtos=nothing
                    %>
                </tbody>
                <tfoot>
                    <tr class="dark">
                        <th colspan="10" class="footer-count-product" style="display:none;"><%= produtoCount %> Produtos</th>
                        <th colspan="10" class="footer-count-procedimento"><%= c %> Procedimentos</th>
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
        <div class="criadoEM">
            Criado em <%=reg("sysDate")%> por <%=nameInTable(reg("sysUser"))%>
        </div>
</form>
<script type="text/javascript">
    $(".crumb-active a").html("Tabelas de Preço");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("edição de tabela de preço");
    $(".crumb-icon a span").attr("class", "far fa-table");
    <%
    if aut("tabelasprecosA")=1 then
    %>
    $("#rbtns").html('<a class="btn btn-sm btn-default" href="./?P=TabelasPreco&Pers=1"><i class="far fa-list"></i></a><button onclick="" class="btn btn-sm btn-primary Salvar"><i class="far fa-save"></i> SALVAR</button>');
    <%
        end if
    %>



   
      
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

function salvarTabela(){
    var Inicio = $("#Inicio").val();
    var Fim = $("#Fim").val();
        if(Inicio == "" || Fim == ""){
        new PNotify({
                    title: 'ERRO!',
                    text: 'As Datas Inicio e Fim são obrigatórias!',
                    type: 'danger',
                    delay: 2500
                });
        }else{
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
       $.post("saveProcedimentosTabela.asp?I=<%=req("I")%>", $("#frmPT").serialize(), function (data) { 
            eval(data) });
    return false;
    }
}

function spinner(){
    $('.spiner-tabela').show();
    setTimeout(() => {
    $('.spiner-tabela').hide();
    }, 800);                   
}   

function AnimateRotate(angle) {
    var $elem = $('.spin-update');
    $({deg: 0}).animate({deg: angle}, {
        duration: 1000,
        step: function(now) {      
            $elem.css({
                transform: 'rotate(' + now + 'deg)'
            });
        }
    });
}
    $('.spiner-tabela').hide();
    function Show_Produtos(tipo){
                if(tipo === '|Materiais|'){
                $('.produto-body > tr').remove();
                
            AnimateRotate(360)
                        $('.tipo_proc').text('Tipo');
                        $('.panel-title').text('Produtos');
                        $('.procOu').text("Produtos");
                        $('#AplicarRegra').attr('id','AplicarRegraProduto');                       
                        $('.ClassTabelaBase').attr('id','TabelaBase');                    
                        $('input:checkbox').not(this).prop('checked', this.checked);
                        $("#atualizar").show();
                        $('#checkbox-proc').hide();
                        $('#checkbox-prod').show();
                        $('.produtos-body').fadeIn(800);                       
                        $('.footer-count-product').show();
                        $('.procedimento-body').fadeOut(800);
                        $('.footer-count-procedimento').hide();
                        $(".table").hide();
                        $(".pull-right").hide();
                        $('.criadoEM').hide();
                          spinner();    
                        setTimeout(() => {
                          $(".pull-right").show();
                        BuscarProdutos();
                        BuscarBase();
                        BuscarValorProduto("<%= req("I")%>");
                        showBaseTable()
                         $('.criadoEM').show();
                         $(".table").fadeIn("slow");
                       
                        }, 2000);
	        
                                   
                        
                    }else{
                    spinner();
            AnimateRotate(360)
                        $('.produto-body > tr').remove();
                        $('.procedimento-body').fadeIn(800);
                        $('.footer-count-procedimento').show();
                        $('.footer-count-product').hide();
                        $('#checkbox-proc').show();
                        $('#checkbox-prod').hide();
                        $('.produtos-body').hide(800);
                        $('#tabelas').hide();
                        $('.panel-title').text('Procedimentos da Tabela');
                        $('.procOu').text("Procedimento");
                        $('#AplicarRegraProduto').attr('id','AplicarRegra');
                        $('.panel-title').text('Procedimento da tabela ');
                        $('.tipo_proc').text('Tipo Procedimento');                      
                        $('.ClassTabelaBase').val('');                      
                        $('.procOu').text('Procedimentos');
                        }
                    }
                    
function porcentagem_tabela(operador,ValorBase , ValorRegra ){
    if( operador == "+" ){
        porcentagem = ( ValorBase * ValorRegra ) / 100
        Total =  ValorBase + porcentagem;
        Total = (Total <= 0 ? 0 : Total);
            if ( Number.isNaN(Total) ){
                Total = 0;
            }
    }else{
        porcentagem = ( ValorBase * ValorRegra ) / 100
        Total =  ValorBase - porcentagem; 
        Total = ( Total <= 0 ? 0 : Total );
            if (Number.isNaN( Total ) ){
            Total = 0;
            }
        }
}
function HistoricoAlteracoes() {
    openComponentsModal("LogUltimasAlteracoes.asp", {
        Tabelas: "procedimentostabelas,procedimentostabelasvalores",
        ID: "<%=TabelaID%>",
        PaiID: "<%=TabelaID%>",
        TipoPai: "TabelaID",
    }, "Log de alterações", true);
}
function msg(aviso,msg){
    if(aviso == 0) {
    new PNotify({
    title: 'ERRO!',
    text: 'Por Favor, Selecione '+msg+'!',
    type: 'danger',
    delay: 2500
});
}
}

function ValidateField(){
    new PNotify({
    title: 'ERRO!',
    text: 'Por Favor, O nome da tabela é obrigátorio',
    type: 'danger',
    delay: 2500
});
}

function BuscarProdutos(){
    tabela = $('#TabelaBase').val();
    $.ajax({
        method: "POST",
        url: "saveTabelaValores.asp",
        data: { Action: "BuscarProdutos",tabela:tabela},
        success:function(data){
        zero();
        data = JSON.parse(data)
        count  = data.length;
        var string = "";
        for(x=0; x<=count ; x++){
            try {
    $('.produto-body').append(criarLinha(data));
        } catch (e) {
        }
        } 
    }
})
}

function zero(){
    baseID  = document.querySelectorAll('.Valor-base-produto');  
    baseID.forEach(function(e , i){
        if(e.innerHTML == 'NaN'){
    e.innerHTML = "0,00";
    }
});
}
function convertToPounds(data){
    if(data.indexOf(',') == '-1'){
    ValorBase = parseFloat(data).toFixed(2).replace(".",",");
    }  else {
    ValorBase = data
    }
    return ValorBase;
}

function BuscarBase( tabela){
        tabela = $('#TabelaBase').val();
    $.ajax({
            method: "POST",
            url: "saveTabelaValores.asp",
            data: { Action: "BuscarBase",tabela:tabela},
            success:function(data){  
            data = JSON.parse(data)
           
            ValorBase = 0;
            count  = data.length;
            var string = "";
            try{
            for(x=0; x<=count ; x++){
                zero(); 
                $('#Valor-base-produto'+data[x].id).text(stringParaDecimal(data[x].PFB));  
                }
        }catch{
        }
        }
    })
    
}

function showBaseTable(data){
    $('.procedimento-body').fadeOut(800);
    $('#Atuacao').val('|Materiais|');

    $('#tabelas').show();
            if(data == '5'){
                $('#TabelaBase').val('5');               
            }else  if(data == '12'){
                $('#TabelaBase').val('12');
            }else{
            
            }
}

function BuscarValorProduto(tabela){
    $.ajax({
            method: "POST",
            url: "saveTabelaValores.asp",
            data: { Action: "BuscarValorProduto",tabela:tabela},
            success:function(data){         
            data = JSON.parse(data)
            ValorBase = 0;
            count  = data.length;
            var string = "";          
            try{
            for(x=0; x<=count ; x++){
                $('#Valor-Tabela-Produto'+data[x].itemID).val(stringParaDecimal(data[x].Valor));  
            }
        }catch{
            }
        }
    })
}

function stringParaDecimal(num1){
        string = num1.split(",")
        num = string[1];
    if( num ) {
        if(num.length == 2){
            num = num1;
        } else {
            num = num1+"0";
        }
        } else {
        num = num1+",00"; 
    }
        return num;
}
buscarValorTabela("<%= req("I")%>");
function buscarValorTabela(tabela){
    $.ajax({
            method: "POST",
            url: "saveTabelaValores.asp",
            data: { Action: "buscarValorTabela",tabela:tabela},
            success:function(data){            
            data = JSON.parse(data)
            ValorBase = 0;
            count  = data.length;
            var string = "";
            try{
            for(x=0; x<=count ; x++){
                  $('#ValorTabela'+data[x].id).removeClass('input-mask-brl')
                $('#ValorTabela'+data[x].id).val(stringParaDecimal(data[x].valorTabela));  
                }
        }catch{
        }
        }
    })
}
function produtoInicial(tabela){
    $.ajax({
            method: "POST",
            url: "saveTabelaValores.asp",
            data: { Action: "produtoInicial",TabelaID:tabela},
            success:function(data){   
                console.log(data);
                    try{         
            data = JSON.parse(data)
            Atuacao = data[0].Atuacao;
             tabelaBase = data[0].tabelabase;
             console.log(tabelaBase)
            if(Atuacao == "|procedimentos|"){
                $('#Atuacao').prop('disabled', true);
            
            }else if(Atuacao == "|Materiais|"){
                $('#Atuacao').val('|Materiais|');
                $('#tabelas').show(500);
                $('.ClassTabelaBase').append(add_option());
                $('#Atuacao').prop('disabled', true);
                $('.procedimento-body').remove();
                Show_Produtos('|Materiais|');
                showBaseTable(tabelaBase)
                ValorBase(tabelaBase);
                $("#TabelaBase").val(tabelaBase);
            }else{ 

            }
            }catch{
            
            }
        }
        
    });

}

produtoInicial("<%= req("I")%>");
function AllChecked(){
    "$('.chk').prop('checked', $(this).prop('checked'))";
}

function AplicarRegraProcedimento(){                       
    var aviso         = 0;
    var TabelaBase    = "Procedimento";
    var Atuacao       = $('#Atuacao').val();
    var Classe    = (Atuacao == '|Materiais|' ? 'ProdutoId' : 'chk');
    var TabelaId  =  "<%=TabelaID%>"   ;
    var ProdutoId  = $('.ProdutoId').val();             
    var Valor      = $('#Valor').val();
    var TableValue       = [];

$('.'+Classe).each(function(i,e) {                                                                           
        if ($(this).is(':checked')) {
            aviso  = 1;
            Tabela       =   JSON.stringify(TableValue);
            Tabela       =   string_paper(Tabela);
            ValorRegra   =   parseFloat($('#Valor').val());
            ValorBase    =   parseFloat($("#Valor-base"+e.value).text());                        
            ValorTabela  =   parseFloat($('#ValorTabela'+e.value).val());
            Operador     =   $('#TipoDeVariacao').val();
        if(Operador == "-"){
            porcentagem_tabela("-",ValorBase , ValorRegra ,ValorTabela);
        }else{
            porcentagem_tabela("+",ValorBase , ValorRegra ,ValorTabela);
        }
        $('#Atuacao').prop('disabled', true);
        $('#ValorTabela'+e.value).val(Total.toFixed(2).replace(".",",")); 
        $.post("saveTabelaValores.asp", {  
            Action:"procedimentos",                           
            Codigo:Tabela,                                
            ItemID:"proc-"+e.value,
            TabelaID:TabelaId,
            Atuacao:TabelaBase,
            Valor:Total.toFixed(2),
            ProcedimentoID:e.value},
            function (data) {
            eval(data) 
            });
        }
    });
        msg(aviso,"no minímo um produto!");
}

function salvarRegraProduto(){
    var aviso         = 0;
    var TabelaBase         = $('#TabelaBase').val();
    var Atuacao        = $('#Atuacao').val();                     
    var TabelaId       = "<%=TabelaID%>";
    var ProdutoId      = $('.ProdutoId').val();            
    var ValorRegra     = parseFloat($('#Valor').val());
    var Operador       = $('#TipoDeVariacao').val();
$('.ProdutoId').each( function ( i, e){
    if ($(this).is(':checked')) {
        aviso  = 1;
        ValorBase    =   parseFloat($("#Valor-base-produto"+e.value).text());
        ValorTabela  =   parseFloat($('#Valor-Tabela-Produtoprod-'+e.value).val());
    if( Operador == "-" ){                                 
        porcentagem_tabela("-",ValorBase , ValorRegra ,ValorTabela);
            }else{
        porcentagem_tabela("+",ValorBase , ValorRegra ,ValorTabela);
    }
        
        $('#Atuacao').prop('disabled', true);
        $('#Valor-Tabela-Produtoprod-'+e.value).val(Total.toFixed(2).replace(".",",")); 
       
        $.post("saveTabelaValores.asp", 
        {   
        Action:"Produtos",                                                          
        ItemID:"prod-"+e.value,
        TabelaID:TabelaId,
        Atuacao:TabelaBase,
        Valor:Total.toFixed(2),
        ProcedimentoID:e.value
    },
        function (data) {
        eval(data) 
        });  
        
    }
});
    msg(aviso,"no minímo um Produto!");
}

function exame(tipo){
    switch (tipo) {
            case "1":
            case  1:
            return "Geral";                                 
            break;
            case  2:
            case "2":
            return "Produto";                                 
            break;
            case "3":
            case  3:
            return "Material";                                 
            break;
            case  4:
            case '4':
            return "Medicamento";                                 
            break;
            
        default:
        break;
        }
}

function criarLinha(data){
        ValorBase = (data == "" ? 0 : data   );
        ValorTabela =  data[x].Valor;

var Row = `
    <tr data-tipo="${data[x].NomeProduto}" data-name="${data[x].NomeProduto}">
        <td class=""><input type="checkbox" class="ProdutoId" onclick="AllChecked()" name="chk${data[x].id}" value="${data[x].id}"></td>
                <td>${data[x].NomeProduto}</td>
                <td class="text-right">${exame(data[x].TipoProduto) ?? 'Geral'}</td>
                <td class="text-right Valor-base-produto" id="Valor-base-produto${data[x].id}" width="100">${parseFloat(ValorBase).toFixed(2)}</td>                            
                <td class="text-right" width="150">
            <div class="input-group">
                <span class="input-group-addon TabelaID" data-table="${data[x].TabelaID}">
                    <strong>R$</strong>
                </span>
                <input id="Valor-Tabela-Produtoprod-${data[x].id}" class="form-control input-mask-brl" type="text" style="text-align:right" name="ValorTabela${data[x].itemID}" value="${ValorTabela}">
            </div>
        </td>
    </tr>`;
    return Row;
}
    
function add_option(){
    var TableValue =
    `<option value="5">Brasindice</option>
	<option value="12" selected="selected">Simpro</option>`;
    return TableValue;
}

$(document).on('change','#Atuacao',function(){
    var tipo  =  $('#Atuacao').val();  
    if( tipo === '|Materiais|' ) {
            $('.ClassTabelaBase').append(add_option());
            $('#tabelas').fadeIn(500);                        
    } else {
            $('.ClassTabelaBase option').remove();
            $('#tabelas').fadeOut(500);
    }                   
});

$(document).on('click','#atualizar',function(event){ 
    var tipo = $('#Atuacao').val();                     
    Show_Produtos(tipo);
    $('.chk').prop('checked',false);
    $('.ProdutoId').prop('checked',false);
});


function string_paper(TableValue){
    string1 =  TableValue.replace(/"/gi, "|");
    string2 =   string1.replace("[", " ");
    result  = string2.replace("]", " ");
    return result;
}

$(document).on('click','#AplicarRegra',function(event){
    NomeTabela = $('#NomeTabela').val();
    $('#Atuacao').prop('disabled', false);
    if(NomeTabela == ""){
    ValidateField();
    }else{
    setTimeout(() => {
    $('#Atuacao').prop('disabled', true);  
    }, 1000);
    salvarTabela()
    AplicarRegraProcedimento();
}
});


$(document).on('click','#AplicarRegraProduto',function(event){
    NomeTabela = $('#NomeTabela').val();
     $('#Atuacao').prop('disabled', false);
    if(NomeTabela == ""){
    ValidateField();
    }else{
    setTimeout(() => {
    $('#Atuacao').prop('disabled', true);  
    }, 1000);
    salvarTabela() 
    salvarRegraProduto();
}
});

$(".Salvar").click(function () {
    $('#Atuacao').prop('disabled', false);
    setTimeout(() => {
    $('#Atuacao').prop('disabled', true);  
    }, 100);
    salvarTabela() 
});

</script>