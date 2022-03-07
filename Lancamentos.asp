<!--#include file="connect.asp"-->
<%
ProdutoID = req("I")'apenas se forna movimentacao geral do produto
ItemInvoiceID = req("ItemInvoiceID")
ProdutoInvoiceID = req("ProdutoInvoiceID")
AtendimentoID = req("AtendimentoID")

if req("X")<>"" then
    set lancto = db.execute("select posicaoAnte from estoquelancamentos where id="& req("X"))
    if not lancto.eof then
        posicaoAnte = lancto("posicaoAnte")&""
        spl = split(posicaoAnte, ", ")
        db.execute("update estoqueposicao set Quantidade=0, ValorPosicao=0 where ProdutoID="& ProdutoID)
        for ip=0 to ubound(spl)
            spl2 = split(spl(ip), "=")
            spl3 = split(spl2(1), "|")
            posQuantidade = spl3(0)
            posValorComprado = spl3(1)
            db.execute("update estoqueposicao set Quantidade="& posQuantidade &", ValorPosicao="& posValorComprado &" where id="& spl2(0))
        next
    end if
    'voltar a posição anterior
	db_execute("delete from estoquelancamentos where id="&req("X"))
end if

if ItemInvoiceID<>"" and ItemInvoiceID<>"undefined" then
    hiddenII = "hidden"
    sqlIIID = " AND ItemInvoiceID="& ItemInvoiceID &" "
end if
if ProdutoInvoiceID<>"" and ProdutoInvoiceID<>"undefined" then
    hiddenII = "hidden"
    sqlIIID = " AND ProdutoInvoiceID="& ProdutoInvoiceID &" "
end if
if ProdutoID<>"" and (ItemInvoiceID="" or ItemInvoiceID="undefined") and (ProdutoInvoiceID="" or ProdutoInvoiceID="undefined") then
    sqlProduto = " AND ProdutoID="& ProdutoID &" "
    hiddenProd = " hidden "
end if
if AtendimentoID<>"" then
    hiddenII = "hidden"
    sqlAtendimento = " AND el.AtendimentoID="& AtendimentoID &" "
end if

sqlLanc = "select el.Responsavel,el.FornecedorID,el.PacienteID, el.id, QuantidadeTotal, el.Data, el.EntSai, el.Quantidade, el.TipoUnidade, el.Lote, el.Validade, el.Valor, el.UnidadePagto, el.Responsavel, el.Lancar, el.sysUser, el.sysDate, el.QuantidadeConjunto, el.LocalizacaoID, el.CBID, el.AtendimentoID, el.ProdutoInvoiceID, i.AccountID, i.AssociationAccountID, prod.NomeProduto, prod.ApresentacaoNome, un.Descricao, coalesce(i.nroNFe, el.NF)nroNFe, el.ItemInvoiceID from estoquelancamentos as el LEFT JOIN produtos as prod on prod.id=el.ProdutoID LEFT JOIN cliniccentral.tissunidademedida as un on un.id=prod.ApresentacaoUnidade LEFT JOIN itensinvoice ii ON ii.id=el.ItemInvoiceID LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE EntSai in('E', 'S', 'M') "& sqlAtendimento & sqlProduto & sqlIIID &" order by id desc"

set lanc = db.execute( sqlLanc )
if not lanc.eof or (ItemInvoiceID="" and AtendimentoID="" and ProdutoInvoiceID="") then
    %>
<div class="no-print">
    <div class="panel-heading">
	    <span class="panel-title">Movimenta&ccedil;&atilde;o</span>
    </div>
    <div class="row ">
	    <div class="col-md-12">
    	    <table class="table table-striped table-bordered table-hover">
        	    <thead>
            	    <tr>
                	    <th width="1%"></th>
                        <th>Quant.</th>
                        <th>Data</th>
                        <th class="<%=hiddenProd %>">Produto</th>
                        <th class="<%= hiddenII %>">Paciente/Fornecedor</th>
                        <th>Responsável</th>
                        <th>Usu&aacute;rio</th>
                        <th>Lote</th>
                        <th>Código</th>
                        <th>Validade</th>
                        <th class="<%= hiddenII %>">NF</th>
                        <th nowrap>Valor Unit.</th>
                        <%if ProdutoInvoiceID="" then %>
                            <th>Conta</th>
                        <% end if %>
                        <th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
                <%
			    QuantidadeAtual = 0
			    c=0
			    while not lanc.eof
                    PacForn=""

                    EntSai = lanc("EntSai")
                    NF = lanc("nroNFe")
					Responsavel = accountName(NULL, lanc("Responsavel"))
				    if c=0 and aut("estoquemovimentacaoX")=1 then
					    btnX = "<button class=""btn btn-danger btn-xs"" type=""button"" onclick=""if(confirm('Tem certeza de que deseja excluir este lançamento?')){ajxContent('Lancamentos&X="&lanc("id")&"', '"&ProdutoID&"', 1, 'divLancamentos'); modalEstoque('"&ItemInvoiceID&"', '"&ProdutoID&"', '"&ProdutoInvoiceID&"');};""><i class=""far fa-remove""></i></button>"
				    else
					    btnX = ""
				    end if
				    if EntSai="E" then
					    Icone = "<i class='far fa-level-down text-system'></i>"
					    Sinal = "+"
					    QuantidadeAtual = QuantidadeAtual+lanc("QuantidadeTotal")
				    elseif EntSai="S" then
					    Icone = "<i class='far fa-level-up text-alert'></i>"
					    Sinal = "-"
					    QuantidadeAtual = QuantidadeAtual-lanc("QuantidadeTotal")
				    elseif EntSai="M" then
					    Icone = "<i class='far fa-exchange text-info'></i>"
					    Sinal = ""
					    QuantidadeAtual = QuantidadeAtual-lanc("QuantidadeTotal")
				    end if
				    if isnull(lanc("PacienteID")) then
                        if not isnull(lanc("AtendimentoID")) then
                            set pac = db.execute("select p.id, p.NomePaciente from atendimentosprocedimentos ap LEFT JOIN atendimentos a ON a.id=ap.AtendimentoID LEFT JOIN pacientes p ON p.id=a.PacienteID WHERE ap.id="& lanc("AtendimentoID"))
                            if not pac.eof then
                                pacforn = pac("NomePaciente")
                            end if
                        else
                            if isnull(lanc("AssociationAccountID")) then
                                if instr(lanc("FornecedorID"),"_")>0 then
                                    FornecedorSplt = split(lanc("FornecedorID"),"_")
                                    AccountAssociationID=FornecedorSplt(0)
                                    AccountID=FornecedorSplt(1)
                                else
                                    AccountAssociationID=2
                                    AccountID=lanc("FornecedorID")
                                end if
                                if AccountID&""<>"" then
                                    pacforn = accountName(AccountAssociationID, AccountID)
                                else
                                    pacforn=""
                                end if
                            else
                                pacforn = accountName(lanc("AssociationAccountID"), lanc("AccountID"))
                            end if
                        end if
                    else
                        set pac = db.execute("select p.id, p.NomePaciente FROM pacientes p WHERE p.id="& lanc("PacienteID"))
                        if not pac.eof then
                            pacforn = pac("NomePaciente")
                        end if
                    end if
				    UnidadePagto = lanc("UnidadePagto")
				    if UnidadePagto="C" then
					    if isnull(lanc("ApresentacaoNome")) or lanc("ApresentacaoNome")="" then
						    DescrPagto = "Conjunto"
					    else
						    DescrPagto = lanc("ApresentacaoNome")
					    end if
				    else
					    if isnull(lanc("Descricao")) or len(lanc("Descricao"))<6 then
						    DescrPagto = "Unidade"
					    else
						    DescrPagto = right(lanc("Descricao"), len(lanc("Descricao"))-6)
					    end if
				    end if

				    InvoiceID=""

                    set inv = db.execute("select InvoiceID from itensinvoice where id="& treatvalnull(lanc("ProdutoInvoiceID")))
                    if not inv.eof then
                        InvoiceID = inv("InvoiceID")
                    else
                        InvoiceID = ""
                    end if

				    if EntSai="E" and InvoiceID<>"" then
				        set ContaAPagarSQL = db.execute("SELECT AccountID, AssociationAccountID FROM sys_financialinvoices WHERE id="&treatvalzero(InvoiceID))
				        if not ContaAPagarSQL.eof then
				            PacForn = accountName(ContaAPagarSQL("AssociationAccountID"), ContaAPagarSQL("AccountID"))
				        end if
				    end if
				    %>
            	    <tr>
                	    <td><%=Icone%></td>
                	    <td class="text-right"><%=Sinal%> <%=descQuant(lanc("Quantidade"), lanc("TipoUnidade"), lanc("ApresentacaoNome"), lanc("descricao"))%></td>
                	    <td class="text-right"><%=lanc("Data")%></td>
                        <td class="<%= hiddenProd %>"><%= lanc("NomeProduto") %></td>
                        <td class="<%=hiddenII %>"><%=PacForn%></td>
                        <td><%=Responsavel%></td>
                	    <td><%=nameInTable(lanc("sysUser"))%></td>
                        <td class="text-right"><%=lanc("Lote")%></td>
                        <td class="text-right"><%=lanc("CBID")%></td>
                        <td class="text-right"><%=lanc("Validade")%></td>
                        <td class="text-right <%= hiddenII %>"><%= NF %></td>
                        <td class="text-right"><%=fn(lanc("Valor"))%> / <%=DescrPagto%></td>
                        <%if ProdutoInvoiceID="" then %>
                            <td>
                                <%
                                if isnull(lanc("ProdutoInvoiceID")) then
                                    if EntSai="E" then
                                        btn = "<button onclick='lancarConta("& lanc("id") &")' type='button' data-rel='tooltip' data-placement='bottom' original-title='Lançar na conta do paciente' title='Lançar no contas a pagar' class='btn btn-xs btn-block btn-default'>Lançar Despesa</button>"
                                    elseif EntSai="S" then
                                        btn = "<button onclick='lancarConta("& lanc("id") &")' type='button' data-rel='tooltip' data-placement='bottom' original-title='Lançar na conta do paciente' title='Lançar na conta do paciente' class='btn btn-xs btn-block btn-default'>Lançar Receita</button>"
                                    else
                                        btn = "<button onclick='printRecibo("& lanc("id") &")' type='button' data-rel='tooltip' data-placement='bottom' original-title='Nota da movimentação' title='Nota da movimentação' class='btn btn-xs btn-block btn-primary'><i class='far fa-print'></i> &nbsp; Nota da movimentação</button>"
                                    end if
                                else
                                    if EntSai="E" and InvoiceID<>"" then
                                        btn = "<button onclick=""location.href='./?P=Invoice&Pers=1&I="& InvoiceID &"&T=D'"" type='button' data-rel='tooltip' data-placement='bottom' original-title='Ver conta a pagar' title='' class='btn btn-xs btn-block btn-alert'>Ver Despesa</button>"
                                    elseif EntSai="S" and InvoiceID<>"" then
                                        btn = "<button onclick=""location.href='./?P=Invoice&Pers=1&I="& InvoiceID &"&T=C'"" type='button' data-rel='tooltip' data-placement='bottom' original-title='Ver conta a receber' title='' class='btn btn-xs btn-block btn-system'>Ver Receita</button>"
                                    else
                                        btn = ""
                                    end if
                                end if
                                response.write( btn )
                                %>
                            </td>
                        <%end if %>
                        <td><%=btnX%></td>
                    </tr>
                    <%
				    c=c+1
				    response.flush()
			    lanc.movenext
			    wend
			    lanc.close
			    set lanc = nothing
			    %>
                </tbody>
            </table>
        </div>
    </div>
</div>
   
    <%
end if
%>
<script type="text/javascript">
function lancarConta(LancamentoID){
    $.post("estoqueLC.asp?LancamentoID="+LancamentoID, "", function(data){
        eval(data);
    });
}
function printRecibo(id){
     $.get("printRecibo.asp?movId="+id, "", function(data){
        $("#modal-content").html(data)
        $("#modal-recibo").modal("show")
    });
}
<!--#include file="JQueryFunctions.asp"-->
</script>