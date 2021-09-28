<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%

TipoProduto = req("TipoProduto")&""
if TipoProduto&""="" then
    TipoProduto = "1"
end if
if TipoProduto <> 1 then
    TipoProdutoReadonly = " disabled "
end if
tableName = "produtos"
I = req("I")
if I="N" then
	sqlVie = "select * from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
	set vie = db.execute(sqlVie)
	if vie.eof then
		db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
		set vie = db.execute(sqlVie)
		vie.close
	end if
    response.Redirect("./?P=produtos&I="&vie("id")&"&TipoProduto="&TipoProduto&"&Pers=1")
else
	set data = db.execute("select * from "&tableName&" where id="&I)
	if data.eof then
        response.Redirect("./?P=produtos&I="&req("I")&"&Pers=1")
        data.close
	end if
end if

call insertRedir(req("P"), req("I"))
sqlTiposproduto  = "select * from "&req("P")&" where id="&req("I")
set reg = db.execute(sqlTiposproduto)

call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
if reg("Foto")="" or isnull(reg("Foto")) then
	divDisplayUploadFoto = "block"
	divDisplayFoto = "none"
else
	divDisplayUploadFoto = "none"
	divDisplayFoto = "block"
end if
if reg("sysActive")=0 then
	disabled = " disabled=""disabled"""
end if

if reg("TipoProduto")&""<>"1" then
    TipoProduto = reg("TipoProduto")
else
    TipoProduto = req("TipoProduto")&""
end if


EstoqueMaximo = reg("EstoqueMaximo")
EstoqueMaximoTipo = reg("EstoqueMaximoTipo")
CodigoTabela = reg("CodigoTabela")
CodigoTabelaSimpro = reg("CodigoTabelaSimpro")
PrincipioAtivo = reg("PrincipioAtivo")
TabelaProduto = reg("TabelaProduto")
DiasAvisoValidade = reg("DiasAvisoValidade")
ApresentacaoNomeDispensacao = reg("ApresentacaoNomeDispensacao")
ApresentacaoQuantidadeDispensacao = reg("ApresentacaoQuantidadeDispensacao")
ApresentacaoUnidadeDispensacao = reg("ApresentacaoUnidadeDispensacao")
UnidadePrescricao = reg("UnidadePrescricao")
DoseMin = reg("DoseMin")
DoseMax = reg("DoseMax")

if ApresentacaoUnidadeDispensacao&""="" then
    ApresentacaoUnidadeDispensacao = treatvalzero(ApresentacaoUnidadeDispensacao&"")
end if
PrecoTabela = reg("PrecoTabela")
PrecoTabelaSimpro = reg("PrecoTabelaSimpro")
PMC = reg("PMC")
PMCSimpro = reg("PMCSimpro")
LocaisEntradas = reg("LocaisEntradas")

if LocaisEntradas&""<>"" then
    sqlLocalizacoes = " AND id IN ("&replace(LocaisEntradas, "|", "")&") "
end if

if 0 then
    set oldLanctos = db.execute("select id, QuantidadeTotal, EntSai from estoquelancamentos where isnull(PosicaoE) and ProdutoID="& req("I") &" order by id")
    while not oldLanctos.eof
        posicaoAnte = ""
        QuantidadeTotal = oldLanctos("QuantidadeTotal")
        EntSai = oldLanctos("EntSai")
        set lanc = db.execute("select distinct Validade, Lote from estoquelancamentos where ProdutoID="&req("I")&" and id<"& oldLanctos("id"))
        while not lanc.eof
            Quantidade = quantidadeEstoqueIMPORT(req("I"), lanc("Lote"), lanc("Validade"), oldLanctos("id"))
            if Quantidade>0 then
                if isnull(lanc("Validade")) then
                    sqlValidade = ""
                else
                    sqlValidade = " and Validade="& mydatenull(lanc("Validade"))
                end if
                set vcaPosicao = db.execute("select id, Quantidade from estoqueposicao where importado=1 and ProdutoID="&req("I")&" and TipoUnidade='U' and Lote like '"&lanc("Lote")&"'"& sqlValidade)
                if EntSai="E" then
                    QuantidadeFinal = Quantidade + QuantidadeTotal
                else
                    QuantidadeFinal = Quantidade - QuantidadeTotal
                end if
                if vcaPosicao.eof then
                    db_execute("insert into estoqueposicao (ProdutoID, Quantidade, TipoUnidade, LocalizacaoID, Lote, Validade, ValorPosicao, importado) values ("&req("I")&", "&treatvalnull( QuantidadeFinal )&", 'U', 0, '"&lanc("Lote")&"', "&mydatenull(lanc("Validade"))&", 0, 1)")
                    set pultPos = db.execute("select id from estoqueposicao order by id desc limit 1")
                    PosicaoID = pultPos("id")
                else
                    PosicaoID = vcaPosicao("id")
                    db_execute("update estoqueposicao set Quantidade="&treatvalnull( QuantidadeFinal )&" where id="& PosicaoID)
                end if
                posicaoAnte = posicaoAnte & PosicaoID &"="& treatval(Quantidade) &"|0, "
            end if
        lanc.movenext
        wend
        lanc.close
        set lanc = nothing
        if posicaoAnte<>"" then
            posicaoAnte = left(posicaoAnte, len(posicaoAnte)-2)
            db_execute("update estoquelancamentos set posicaoAnte='"&posicaoAnte&"' where id="& oldLanctos("id"))
        end if
    oldLanctos.movenext
    wend
    oldLanctos.close
    set oldLanctos=nothing
    'falta atualizar posicaoE e posicaoS nos lancamentos old
end if

%>

<br />

<form method="post" id="frm" name="frm" action="save.asp">
    <iframe align="middle" class="hidden" id="CodBarras" name="CodBarras" src="about:blank" width="100%" height="110"></iframe>

    <%=header(req("P"), "Estoque", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
    <div id="modal-recibo" class="modal fade" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content" id="modal-content" style="width:860px; margin-left:-130px;">
                <div ><i class="far fa-circle-o-notch fa-spin fa-fw"></i> <span class="sr-only">Carregando...</span> Carregando...</div>
            </div><!-- /.modal-content -->
        </div><!-- /.modal-dialog -->
    </div>
    <div class="tabbable panel no-print">
        <div class="tab-content panel-body">
           <%  if TipoProduto&"" = "5" then %>
            <div id="divCadastroProduto" class="tab-pane in active">
                <div class="row">
                    <%=quickField("text", "NomeProduto", "Nome <code>#"& reg("id") &"</code>", 4, reg("NomeProduto"), "", "", " required")%>
                    <%'=quickField("simpleSelect", "TipoProduto", "Tipo", 2, TipoProduto, "select * from cliniccentral.produtostipos order by id", "TipoProduto", " required no-select2 semVazio "& TipoProdutoReadonly)%>
                    <%if TipoProdutoReadonly&""<>"" then%>
                        <input type="hidden" name="TipoProduto" id="TipoProduto" value="<%=TipoProduto%>">
                    <%end if%>
                    <%=quickField("simpleSelect", "CD", "CD", 3, reg("CD"), "select * from cliniccentral.tisscd where id=7 order by Descricao", "Descricao", "semVazio")%>
                </div>
            </div>
           <% else %>
            <div id="divCadastroProduto" class="tab-pane in active">
                <div class="row">
                    <div class="col-md-2">
                        <div class="row">
                            <div class="col-md-12" id="divAvatar">
                                <div id="divDisplayUploadFoto" style="display: <%=divDisplayUploadFoto%>">
                                    <input type="file" name="Foto" id="Foto" />
                                </div>
                                <div id="divDisplayFoto" style="display: <%= divDisplayFoto %>">
                                    <img id="avatarFoto" src="<%=arqEx(reg("Foto"), "Perfil")%>" class="img-thumbnail" width="100%" />
                                    <button type="button" class="btn btn-xs btn-danger" onclick="removeFoto();" style="position: absolute; left: 18px; bottom: 6px;"><i class="far fa-trash"></i></button>
                                </div>
                            </div>
                        </div>
                        <br />
                        <div class="row">
                            <%=quickField("multiple", "LocaisEntradas", "Locais de possíveis entradas", 12, LocaisEntradas, "SELECT * FROM produtoslocalizacoes WHERE sysActive=1", "NomeLocalizacao", " empty")%>
                            <%=quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, reg("Obs"), "", "", "")%>
                        </div>
                    </div>
                    <div class="col-md-10">
                        <div class="row">
                            <%=quickField("text", "NomeProduto", "Nome <code>#"& reg("id") &"</code>", 4, reg("NomeProduto"), "", "", " required")%>
                            <%=quickField("simpleSelect", "TipoProduto", "Tipo", 2, TipoProduto, "select * from cliniccentral.produtostipos WHERE id <> 5 order by id", "TipoProduto", " required no-select2 semVazio "& TipoProdutoReadonly)%>
                            <%if TipoProdutoReadonly&""<>"" then%>
                                <input type="hidden" name="TipoProduto" id="TipoProduto" value="<%=TipoProduto%>">
                            <%end if%>
                            <%=quickField("text", "Codigo", "C&oacute;digo", 2, reg("Codigo"), "", "", "")%>
                            <div class="col-md-2">
                                <%= selectInsert("Categoria", "CategoriaID", reg("CategoriaID"), "produtoscategorias", "NomeCategoria", "", " empty", "") %>
                            </div>
                            <div class="col-md-2">
                                <%= selectInsert("Fabricante", "FabricanteID", reg("FabricanteID"), "produtosfabricantes", "NomeFabricante", "", " empty", "") %>
                            </div>
                        </div>
                        <br />
                        <div class="row">
                            <%=quickField("text", "ApresentacaoNome", "Apresenta&ccedil;&atilde;o", 2, reg("ApresentacaoNome"), "", "", " placeholder=""Ex.: caixa, garrafa..."" required")%>
                            <%
						ApresentacaoQuantidade = reg("ApresentacaoQuantidade")
						if not isnull(ApresentacaoQuantidade) and not ApresentacaoQuantidade="" and isnumeric(ApresentacaoQuantidade) then
							ApresentacaoQuantidade = formatnumber(ApresentacaoQuantidade,2)
						end if
                            %>
                            <%=quickField("text", "ApresentacaoQuantidade", "Contendo", 2, ApresentacaoQuantidade, " input-mask-brl text-right", "", " placeholder=""1,00"" required")%>
                            <%=quickField("simpleSelect", "ApresentacaoUnidade", "Unidade", 2, reg("ApresentacaoUnidade"), "select * from cliniccentral.tissunidademedida order by Descricao", "Descricao", " required empty")%>
                            <div class="col-md-3">
                            <%
                            if LocaisEntradas&""<>"" then
                                call quickField("simpleSelect", "LocalizacaoID", "Localiza&ccedil;&atilde;o Padrão", 12, reg("LocalizacaoID"), "select * from produtoslocalizacoes where sysActive=1 "&sqlLocalizacoes&" order by NomeLocalizacao", "NomeLocalizacao", "")
                            else
                                call selectInsert("Localiza&ccedil;&atilde;o Padrão", "LocalizacaoID", reg("LocalizacaoID"), "produtoslocalizacoes", "NomeLocalizacao", "", "", "")
                            end if
                            %>
                            </div>
                            <%=quickField("simpleSelect", "CD", "CD", 3, reg("CD"), "select * from cliniccentral.tisscd order by Descricao", "Descricao", "")%>
                        </div>

                        <br />


                        <div class="Modulo-Medicamento row">
                            <div class="col-md-12">
                                <div class="ml15" style="color: #AAA;"><h4> - Dispensação</h4></div>
                                <%=quickField("text", "ApresentacaoNomeDispensacao", "Apresenta&ccedil;&atilde;o", 2, ApresentacaoNomeDispensacao, "", "", " placeholder=""Ex.: caixa, garrafa..."" ")%>
                                    <%
                                'ApresentacaoQuantidadeDispensacao = reg("ApresentacaoQuantidadeDispensacao")
                                if not isnull(ApresentacaoQuantidadeDispensacao) and not ApresentacaoQuantidadeDispensacao="" and isnumeric(ApresentacaoQuantidadeDispensacao) then
                                    ApresentacaoQuantidadeDispensacao = formatnumber(ApresentacaoQuantidadeDispensacao,2)
                                end if
                                %>
                                <%=quickField("text", "ApresentacaoQuantidadeDispensacao", "Contendo", 2, ApresentacaoQuantidadeDispensacao, " input-mask-brl text-right", "", " placeholder=""1,00"" ")%>
                                <%=quickField("simpleSelect", "ApresentacaoUnidadeDispensacao", "Unidade", 2, ApresentacaoUnidadeDispensacao, "select * from cliniccentral.tissunidademedida order by Descricao", "Descricao", "  empty")%>
                            </div>
                            <div class="col-md-12 mt10">
                                <%=quickField("text", "DoseMin", "Dose Min.", 2, fn(DoseMin), " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
                                <%=quickField("text", "DoseMax", "Dose Máx.", 2, fn(DoseMax), " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
                                <%=quickField("simpleSelect", "UnidadePrescricao", "Unidade para Prescrição", 3, UnidadePrescricao, "select * from cliniccentral.unidademedida order by UnidadeMedida", "UnidadeMedida", "  empty")%>
                                <div class="col-md-4">
                                    <%= selectInsert("Princípio Ativo", "PrincipioAtivo", PrincipioAtivo, "cliniccentral.principioativo", "Principio", "", "", "") %>
                                </div>
                            </div>
                        </div>

                        <br />
                        <div class="row">
                            <div class="col-md-6">
                                <div class="ml15" style="color: #AAA;"><h4> - Brasíndice</h4></div>
                                <%=quickField("text", "CodigoTabela", "Código da Tabela", 4, CodigoTabela, "", "", "")%>
                                <%=quickField("currency", "PrecoTabela", "Preço da Tabela", 4, PrecoTabela, "", "", "")%>
                                <%=quickField("currency", "PMC", "PMC", 4, PMC, "", "", "")%>
                            </div>
                            <div class="col-md-6">
                                <div class="ml15" style="color: #AAA;"><h4> - Simpro</h4></div>
                                <%=quickField("text", "CodigoTabelaSimpro", "Código da Tabela", 4, CodigoTabelaSimpro, "", "", "")%>
                                <%=quickField("currency", "PrecoTabelaSimpro", "Preço da Tabela", 4, PrecoTabelaSimpro, "", "", "")%>
                                <%=quickField("currency", "PMCSimpro", "PMC", 4, PMCSimpro, "", "", "")%>
                             </div>
                        </div>
                        <br />


                        <div class="col-md-12">
                        <hr/>
                            <div class="row">
                                <%=quickField("text", "EstoqueMinimo", "Estoque M&iacute;nimo", 2, fn(reg("EstoqueMinimo")), " input-mask-brl text-right", "", "")%>
                                <%=quickfield("simpleSelect", "EstoqueMinimoTipo", "&nbsp;", 2, reg("EstoqueMinimoTipo"), "select 'U' id, 'Unidade' Descricao UNION ALL select 'C', 'Conjunto'", "Descricao", "no-select2 semVazio") %>

                                <%=quickField("text", "EstoqueMaximo", "Estoque Máximo", 2, fn(EstoqueMaximo), " input-mask-brl text-right", "", "")%>
                                <%=quickfield("simpleSelect", "EstoqueMaximoTipo", "&nbsp;", 2, EstoqueMaximoTipo, "select 'U' id, 'Unidade' Descricao UNION ALL select 'C', 'Conjunto'", "Descricao", "no-select2 semVazio") %>

                                <%=quickField("number", "DiasAvisoValidade", "Aviso de Validade", 2, DiasAvisoValidade, "", "", " placeholder=""dias"" ")%>

                            </div>
                            <br/>
                            <div class="row">

                                <%=quickField("currency", "PrecoCompra", "Pre&ccedil;o Médio - Compra", 4, reg("PrecoCompra"), "", "", "")%>
                                <div class="col-md-4">
                                    <br />
                                    <div class="radio-custom radio-system">
                                        <input type="radio" name="TipoCompra" value="C" id="TipoCompraC" <% If reg("TipoCompra")="C" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoNomeC" for="TipoCompraC"> por conjunto</label></div>

                                    <div class="radio-custom radio-system">
                                        <input type="radio" name="TipoCompra" value="U" id="TipoCompraU" <% If reg("TipoCompra")="U" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoUnidadeC" for="TipoCompraU"> por unidade</label></div>
                                </div>
                                <div class="col-md-4">
                                    <%=selectInsert("Plano de Contas - Despesa", "CategoriaDespesaID", reg("CategoriaDespesaID"), "sys_financialexpensetype", "Name", "", "", "")%>
                                </div>
                            </div>
                            <div class="row">
                                <%=quickField("currency", "PrecoVenda", "Pre&ccedil;o Médio - Venda", 4, reg("PrecoVenda"), "", "", "")%>
                                <div class="col-md-4">
                                    <br />
                                    <div class="radio-custom radio-alert">
                                        <input type="radio" name="TipoVenda" id="TipoVendaC" value="C" <% If reg("TipoVenda")="C" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoNomeV" for="TipoVendaC"> por conjunto</label></div>

                                    <div class="radio-custom radio-alert">
                                        <input type="radio" name="TipoVenda" id="TipoVendaU" value="U" <% If reg("TipoVenda")="U" Then %> checked="checked" <% End If %> /><label id="lblApresentacaoUnidadeV" for="TipoVendaU"> por unidade</label></div>
                                </div>
                                <div class="col-md-4">
                                    <%=selectInsert("Plano de Contas - Receita", "CategoriaReceitaID", reg("CategoriaReceitaID"), "sys_financialincometype", "Name", "", "", "")%>
                                </div>
                            </div>
                            <div class="row">

                                <div class="col-md-6">
                                    <%if aut("|produtosI|")=1 OR aut("|produtosA|")=1 then%>
                                        <div class="checkbox-custom checkbox-primary mt25">
                                        <input type="checkbox" name="PermitirSaida" id="PermitirSaida" value="S" class="ace" <% If reg("PermitirSaida")="S" Then %> checked="checked" <% End If %> />
                                        <label for="PermitirSaida">Permitir saída pelo cadastro</label></div>
                                    <%end if%>
                                </div>

                            </div>
                        </div>

                    </div>
                </div>
                <hr class="short alt" />

				<%
				set uii = db.execute("select el.Valor, el.TipoUnidade UC from estoquelancamentos el WHERE el.ProdutoID="& req("I") &" ORDER BY el.sysDate desc LIMIT 1")
				if not uii.eof then

				    if not isnull(uii("Valor")) then
                        if uii("Valor")>0 then
                            if uii("UC")="C" then
                                descUC = "conjunto"
                            else
                                descUC = "unidade"
                            end if
                            %>
                            <div class="alert alert-info">
                                Última compra: R$ <%= fn(uii("Valor")) %>/<%= descUC %>

                                <% if aut("contasapagar")=1 and false then %>
                                    <a target="_blank" href="./?P=Invoice&Pers=1&T=D&I=<%= uii("InvoiceID") %>" class="btn btn-xs btn-default"><i class="far fa-eye"></i></a>
                                <% end if %>
                            </div>
                            <%
                        end if
                    end if
                    uii.close
				end if

				%>

               <div class="row">
                    <div class="col-md-12">
                        <div class="row">
                                    <div class="col-md-12" id="ProdutosPosicao">

                                        <%server.Execute("EstoquePosicao.asp")%>
                                    </div>
                        </div>

                    </div>
                </div>
            </div>
            <% end if %>

            <div id="divLancamentos" class="tab-pane">
                Carregando...
            </div>
            <div id="divFaturamento" class="tab-pane">
                Carregando...
            </div>
            <div id="divInteracoesEstoque" class="tab-pane">
                Carregando...
            </div>
            <div id="divConvenioMedicamentos" class="tab-pane">
                Carregando...
            </div>
            <div id="divConversaoEstoque" class="tab-pane">
                <div class="panel-heading">
                    <span class="panel-title">
                        Conversão de Medida
                    </span>
                </div>
                <br>
                <div class="col-md-offset-2 col-md-8 Modulo-Medicamento mt40">
                <%'call Subform("produtosunidademedida", "1", req("I"), "frm")%>
                </div>
            </div>
            <div id="divVincularMedicamento" class="tab-pane">
                Carregando...
            </div>
        </div>
    </div>
</form>

<script type="text/javascript">

    $(document).ready(function()
    {
        let TipoProduto = $("#TipoProduto").val();
        let IdTipoProduto = $(".idItem").val();

    })

    function printEtiqueta(ProdutoID) {
        $.post("printEtiqueta.asp?ProdutoID="+ ProdutoID, $(".eti").serialize(), function (data) {
            $("#modal-table").modal("show");
            $(".modal-content").html(data);
        });
    }

    function showSalvar(opcao){
        if(opcao){
            $('#rbtns #Salvar').show()
        }else{
            $('#rbtns #Salvar').hide()
        }
    }
    showSalvar(true)

    $(document).ready(function() {
        var TipoProduto = $("#TipoProduto").val();

        if (TipoProduto == 4){
            $(".Modulo-Medicamento").attr("style", "display:");
        }else{
            $(".Modulo-Medicamento").attr("style", "display:none");
        }
        $("#Header-List").attr("href", "./?P=ListaProdutos&Pers=1&TipoProduto="+TipoProduto);

        $("#Header-New").addClass("hidden");



        $(".crumb-link").removeClass("hidden");
        $(".crumb-link").html($("#TipoProduto option:selected").text());

        $("#TipoProduto").on("click", function (){
            var TipoProduto = $("#TipoProduto").val();
            if (TipoProduto == 4){
                $(".Modulo-Medicamento").attr("style", "display:");
            }else{
                $(".Modulo-Medicamento").attr("style", "display:none");
            };
            $("#Header-List").attr("href", "./?P=ListaProdutos&Pers=1&TipoProduto="+TipoProduto);
            $(".crumb-link").html($("#TipoProduto option:selected").text());
        });

        $("#ProdutosPosicao").on("click", ".eti",function() {
            var temPosicaoSelecionada = $(".eti:checked").length > 0,
                $btnAcaoEmLote = $(".btn-acao-em-lote");

            $btnAcaoEmLote.attr("disabled", !temPosicaoSelecionada);
        });
        <%call formSave("frm", "save", "$('.btnLancto').removeAttr('disabled');")%>

        <%
        if req("BaixarPosicao")<>"" then
        %>
            setTimeout(function() {
                    lancar('<%=req("I")%>', 'S', '', '', '<%=req("BaixarPosicao")%>', '', '', );
                }, 700);
        <%
        end if
        %>
        });


    function lancar(P, T, L, V, PosicaoID){
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
        $.ajax({
            type:"POST",
            url:"EstoqueLancamento.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }
    function dividir(P, T, L, V, PosicaoID)
    {
        $("#modal-table").modal("show");
        $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)

        if(PosicaoID === "LOTE"){
            PosicaoID=[];

            $(".eti[name=etiqueta]:checked").each(function() {
                PosicaoID.push($(this).val());
            })

            PosicaoID= PosicaoID.join(",");
        }

        $.ajax({
            type:"POST",
            url:"EstoqueDist.asp?P="+P+"&T="+T+"&L="+L+"&V="+V+"&PosicaoID="+PosicaoID,
            success: function(data){
                setTimeout(function(){
                    $("#modal").html(data);
                }, 500);
            }
        });
    }


    function atualizaLanctos(){
        $.ajax({
            type:"GET",
            url:"EstoquePosicao.asp?I=<%=req("I")%>",
            success: function(data){
                $("#ProdutosPosicao").html(data);
            }
        });
    }



   $("#Codigo").on("keyup", function(){
        $("#CodBarras").removeClass("hidden");
        $("#CodBarras").attr("src", "CodBarras.asp?NumeroCodigo="+ $(this).val() );
    });


</script>

<script type="text/javascript">


function lbl(){
    if($("#ApresentacaoNome").val()==""){
        var ApresentacaoNome = "Conjunto";
    }else{
        var ApresentacaoNome = $("#ApresentacaoNome").val()+" (A)";
    }
    $("#lblApresentacaoNomeC, #lblApresentacaoNomeV").html("por "+ ApresentacaoNome);
    $("#EstoqueMinimoTipo option[value=C]").html(ApresentacaoNome);
    $("#EstoqueMaximoTipo option[value=C]").html(ApresentacaoNome);
    if($("#ApresentacaoUnidade").val()=="" || $("#ApresentacaoUnidade").val()=="0"){
        var ApresentacaoUnidade = "Unidade";
    }else{
        var ApresentacaoUnidade = $("#ApresentacaoUnidade option:selected").text().substring(5, 16)+" (U)";
    }
    $("#lblApresentacaoUnidadeC, #lblApresentacaoUnidadeV").html("por "+ ApresentacaoUnidade);
    $("#EstoqueMinimoTipo option[value=U]").html(ApresentacaoUnidade);
    $("#EstoqueMaximoTipo option[value=U]").html(ApresentacaoUnidade);
}

$("#ApresentacaoNome, #ApresentacaoUnidade").on("keyup change", function(){
    lbl();
});

lbl();

    //js exclusivo avatar
<%
    Parametros = "P="&req("P")&"&I="&req("I")&"&Col=Foto&L="& replace(session("Banco"), "clinic", "")

    %>
    function removeFoto(){
        if(confirm('Tem certeza de que deseja excluir esta imagem?')){
            $.ajax({
                type:"POST",
                url:"FotoUploadSave.asp?<%=Parametros%>&Action=Remove",
                success:function(data){
                    $("#divDisplayUploadFoto").css("display", "block");
                    $("#divDisplayFoto").css("display", "none");
                    $("#avatarFoto").attr("src", "/uploads/");
                    $("#Foto").ace_file_input('reset_input');
                }
            });
        }
    }

    $(function() {
        var $form = $('#frm');
        var file_input = $form.find('input[type=file]');
        var upload_in_progress = false;
		
        file_input.ace_file_input({
            style : 'well',
            btn_choose : 'Sem foto',
            btn_change: null,
            droppable: true,
            thumbnail: 'large',

            before_remove: function() {
                if(upload_in_progress)
                    return false;//if we are in the middle of uploading a file, don't allow resetting file input
                return true;
            },

            before_change: function(files, dropped) {
                var file = files[0];
                if(typeof file == "string") {//files is just a file name here (in browsers that don't support FileReader API)
                    /*if(! (/\.(jpe?g|png|gif)$/i).test(file) ) {
						alert('Please select an image file!');
						return false;
					}*/
                }
                else {
                    var type = $.trim(file.type);
                    /*if( ( type.length > 0 && ! (/^image\/(jpe?g|png|gif)$/i).test(type) )
							|| ( type.length == 0 && ! (/\.(jpe?g|png|gif)$/i).test(file.name) )//for android's default browser!
						) {
							alert('Please select an image file!');
							return false;
						}

					if( file.size > 110000 ) {//~100Kb
						alert('File size should not exceed 100Kb!');
						return false;
					}*/
                }
	
                return true;
            }
        });
		
		
        $("#Foto").change(async function() {

            await uploadProfilePic({
                $elem: $("#Foto"),
                userId: "<%=req("I")%>",
                db: "<%= LicenseID %>",
                table: 'produtos',
                content: file_input.data('ace_input_files')[0] ,
                contentType: "form"
            });

            if(!file_input.data('ace_input_files')) return false;//no files selected
        });
		
        $form.on('reset', function() {
            file_input.ace_file_input('reset_input');
        });


        if(location.protocol == 'file:') alert("For uploading to server, you should access this page using a webserver.");

    });
</script>
<!--#include file="disconnect.asp"-->
