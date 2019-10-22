<!--#include file="connect.asp"-->
<%

totalRepasses = 0
totalMateriais = 0
totalProcedimentos = 0


private function tituloTabelaRepasse(Classe, Titulo, ItemGuiaID, GuiaConsultaID, ItemHonorarioID, Tabela, PagtoID, ValorRecebido)
    %>
    <tr class="<%= Classe %>">
        <td colspan="6">
            <div class="row">
                <div class="col-md-3">
                    <% if Classe<>"dark" then %>
                        <span class="checkbox-custom checkbox-<%= Classe %> ptn mtn" style="position:relative; bottom:10px">
                            <input type="checkbox" name="linhaRepasse" value="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>" id="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>"><label for="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>"></label>
                        </span>
                    <% end if %>


                    <%= Titulo %>: <%= FormaPagto %> </div>
                <div class="col-md-3">Recebido: <%= fn(ValorRecebido) %></div>
            </div>
        </td>
    </tr>
    <%

end function

private function calcCreditado(ContaCredito, ProfissionalExecutante)
    if ContaCredito="PRO" then
        calcCreditado = ProfissionalExecutante
    else
        calcCreditado = ContaCredito
    end if
end function

private function calcValor(Valor, TipoValor, ValorBase, modo)
    if modo="calc" then
        if TipoValor="P" then
            calcValor = Valor/100 * ValorBase
        else
            calcValor = Valor
        end if
    else
        if TipoValor="P" then
            calcValor = fn(Valor) &"%"
        else
            calcValor = "R$ "& fn(Valor)
        end if
    end if
end function




private function repasse( rDataExecucao, rGuiaID, rNomeProcedimento, rNomePaciente, rItemGuiaID, rValorProcedimento, rValorRecebido, rPercentual, Tabela )

    coefPerc = rPercentual / 100
    'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
    set fd = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" order by Sobre")
    nLinha = 0
    while not fd.eof
        '-> Começa a coletar os dados pra temprepasses (antiga rateiorateios)
        Funcao = fd("Funcao")
        TipoValor = fd("TipoValor")
        Valor = fd("Valor")
        ContaPadrao = fd("ContaPadrao")
        ContaCredito = fd("ContaPadrao")
        Sobre = fd("Sobre")
        FormaID = 0 'Resolver
        FM = fd("FM")
        ProdutoID = fd("ProdutoID")
        ValorUnitario = fd("ValorUnitario")
        Quantidade = fd("Quantidade")
        sysUser = session("User")
        FuncaoID = fd("id")
        gravaTemp = 0
        if ultimoSobre<>Sobre then
            ValorBase = ValorBase - somaDesteSobre
            somaDesteSobre = 0
        end if
        '<-
        'Funcao da arvore para conta crédito (F ou M)
        if fd("FM")="F" or fd("FM")="M" then
            if ContaPadrao="PRO" then
                ContaCredito = ii("ProfissionalID")
            else
                ContaCredito = fd("ContaPadrao")
            end if

            if fd("FM")="M" then
                'Produto variável
                if fd("ProdutoID")=0 then
                    if not iio.eof then
                        ProdutoID = iio("ProdutoID")
                    end if
                end if
                'Valor variável
                if fd("ValorVariavel")="S" then
                    if not iio.eof then
                        ValorUnitario = iio("ValorUnitario")
                    end if
                end if
            end if
            gravaTemp = 1
        end if

        'Funções estampadas
        if fd("FM")="F" then
            Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
            ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
                                
            if Creditado<>"" then
                somaDesteSobre = somaDesteSobre+ValorItem
                if Creditado<>"0" then
                    Despesas = Despesas + ValorItem
                    Creditado = "5_"& Creditado
                end if


                'linhaRepasseG = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID
                linhaRepasse = "||"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID

                %>
                <input type="hidden" name="linhaRepasse<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>" value="<%= linhaRepasse %>" />
                <%
                nLinha = nLinha+1

                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                call lrResult( "Calculo", rDataExecucao, fd("Funcao"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, (ValorItem * coefPerc), nLinha, fd("FM"), fd("Sobre") )
            end if
        end if

        'Materiais da árvore (M)
        if fd("FM")="M" then
            Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
            ShowValor = calcValor(Valor, TipoValor, ValorBase, "show")
            ValorItem = calcValor(Valor, TipoValor, ValorBase, "calc")
        end if


        'Materiais de Kit do Procedimento (K)
        if fd("FM")="K" then
            'primeiro puxa só os produtos que não possuem variação (ver se quando nao muda ele grava)
            'depois sai listando as variações
            set kit = db.execute("select pdk.id ProdutoDoKitID, pdk.Valor, pdk.ContaPadrao, pdk.Quantidade, pdk.ProdutoID, pdk.Variavel from procedimentoskits pk LEFT JOIN produtosdokit pdk ON pk.KitID=pdk.KitID WHERE pk.Casos LIKE '%|P|%' AND pk.ProcedimentoID="& ProcedimentoID)
            while not kit.eof
                NomeProduto = ""
                Quantidade = kit("Quantidade")
                ValorUnitario = kit("Valor")
                ContaPadrao = kit("ContaPadrao")
                ContaCredito = ContaPadrao
                ProdutoID = kit("ProdutoID")
                TipoValor = "V"
                if not isnull(ProdutoID) then
                    set prod = db.execute("select NomeProduto from produtos where id="& ProdutoID)
                    if not prod.eof then
                        NomeProduto = prod("NomeProduto")
                    end if
                end if
                Creditado = calcCreditado(ContaCredito, ProfissionalExecutante)
                if ProdutoID<>0 and not isnull(ProdutoID) and Creditado<>"" then
                    somaDesteSobre = somaDesteSobre + (Quantidade * ValorUnitario)
                    'if Creditado<>"0" then
                        Despesas = Despesas + (Quantidade*ValorUnitario)
                    'end if
                    ValorItem = ValorUnitario

                end if
            kit.movenext
            wend
            kit.close
            set kit = nothing
        end if
    


        ultimoSobre = Sobre
    fd.movenext
    wend
    fd.close
    set fd=nothing

end function

De = req("De")
Ate = req("Ate")
StatusBusca = req("Status")
%>


<form method="post" id="frmRepasses" name="frmRepasses">

            <%
            'db_execute("delete from temprepasse where sysUser="&session("User"))
            ContaProfissional = ""
            if instr(req("AccountID"), "_") then
                ContaProfissionalSplt =split(req("AccountID"),"_")
                gsContaProfissional = " AND ps.ProfissionalID="& ContaProfissionalSplt(1)
                gcContaProfissional = " AND gc.ProfissionalID="& ContaProfissionalSplt(1)
            end if

            set ii = db.execute("select link, Tipo, ConvenioID, t.id, t.PacienteID, ProfissionalID, GuiaID, ProcedimentoID, `Data`, ValorTotal, UnidadeID, ValorPago, proc.NomeProcedimento, pac.NomePaciente, c.NomeConvenio FROM (select gs.PacienteID, gs.ConvenioID, 'tissguiasadt' link, 'SP/SADT' Tipo, ps.id, ps.ProfissionalID, ps.GuiaID, ps.ProcedimentoID, ps.`Data`, ps.ValorTotal, gs.UnidadeID, ifnull(gs.ValorPago, 0) ValorPago from tissguiasadt gs LEFT JOIN tissprocedimentossadt ps on ps.GuiaID=gs.id WHERE gs.ConvenioID IN ("& replace(req("Forma"), "|", "") &") AND ps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gsContaProfissional &" UNION ALL select gc.PacienteID, gc.ConvenioID, 'tissguiaconsulta' link, 'Consulta' Tipo, gc.id, gc.ProfissionalID, gc.id GuiaID, gc.ProcedimentoID, gc.DataAtendimento `Data`, gc.ValorProcedimento ValorTotal, gc.UnidadeID, ifnull(gc.ValorPago, 0) ValorPago from tissguiaconsulta gc WHERE gc.ConvenioID IN ("& replace(req("Forma"), "|", "") &") AND gc.DataAtendimento BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gcContaProfissional &" ) t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID ORDER BY t.Data")
                'se ii("Repassado")=0 joga pra temprepasse, else exibe o q ja foi pra rateiorateios
            while not ii.eof

                ProfissionalExecutante = ii("ProfissionalID")
                Link = ii("Link")
                ItemGuiaID = ii("id")
                GuiaID = ii("GuiaID")
                ProcedimentoID = ii("ProcedimentoID")
                DataExecucao = ii("Data")
                NomeProcedimento = ii("NomeProcedimento")
                ValorProcedimento = ii("ValorTotal")
                NomePaciente = ii("NomePaciente")
                NomeConvenio = ii("NomeConvenio")
                ValorPago = ii("ValorPago")
                ConvenioID = ii("ConvenioID")

                PercentualPago = 0
                TotalPago = 0
                TotalRepassado = 0
                PercentualRepassado = 0

                contaLR = 0



                sqlrr = ""

                if Link="tissguiaconsulta" then
                    GuiaConsultaID = GuiaID
                    ItemGuiaID = ""
                    ItemHonorarioID = ""
                    sqlrr = " rr.GuiaConsultaID="& GuiaConsultaID &" "
                elseif Link="tissguiasadt" then
                    ItemHonorarioID = ""
                    GuiaConsultaID = ""
                    sqlrr = " rr.ItemGuiaID="& ItemGuiaID &" "
                elseif Link="tissguiahonorarios" then
                    ItemGuiaID = ""
                    GuiaConsultaID = ""
                    sqlrr = " rr.ItemHonorarioID="& ItemHonorarioID &" "
                end if

                idPanel = GuiaConsultaID &"_"& ItemGuiaID &"_"& ItemHonorarioID
                %>
                <div class="panel mn mt10" id="panel<%= idPanel %>">
                    <div class="panel-heading mn pn">
                        <div class="row panel-title pn mn">
                            <small class="col-xs-2">
                                Execução: <%= DataExecucao %>
                            </small>
                            <small class="col-xs-3">
                                 Proc.: <a target="_blank" href="./?P=<%= Link %>&Pers=1&I=<%= GuiaID %>"><%= left(NomeProcedimento&"", 20) %></a>
                            </small>
                            <small class="col-xs-3">
                                Paciente: <%= left(NomePaciente&"", 20) %>
                            </small>
                            <small class="col-xs-2">
                                Valor: <%= fn(ValorProcedimento) %>
                            </small>
                        </div>
                    </div>
                    <div class="panel-body">
                        <table class="table table-hover table-condensed">
                            <tbody>
                                <tr class="dark">
                                    <th width="1%"></th>
                                    <th width="35%">Função / Item</th>
                                    <th width="35%">Creditado</th>
                                    <th>$ Repasse</th>
                                </tr>
                <%

                        ultimoSobre = ""
                        somaDesteSobre = 0
                        ValorBase = ValorProcedimento
                        DominioID = dominioRepasse("|"& ConvenioID &"|", ii("ProfissionalID"), ProcedimentoID, ii("UnidadeID"))

                        Despesas = 0
                        ItemDescontadoID = 0

                        Percentual = PercentualNaoPago
                        Exibir = 1
                        if ValorPago>0 then
                            if StatusBusca="C" then
                                Exibir=0
                            end if
                            if StatusBusca="S" then
                                Exibir=1
                            end if
                            if StatusBusca="N" then
                                Exibir=0
                            end if

                            Classe = "success"
                        else
                            if StatusBusca="C" then
                                Exibir=0
                            end if
                            if StatusBusca="S" then
                                Exibir=0
                            end if
                            if StatusBusca="N" then
                                Exibir=1
                            end if
                            Classe = "danger"
                        end if

                        set rr = db.execute("select rr.id from rateiorateios rr where "& sqlrr )
                        if not rr.eof then
                            if StatusBusca="C" then
                                Exibir=1
                            end if
                            if StatusBusca="S" then
                                Exibir=0
                            end if
                            if StatusBusca="N" then
                                Exibir=0
                            end if
                            Classe = "dark"
                        end if
                        
                        if Exibir=1 or StatusBusca="" then
                            call tituloTabelaRepasse(Classe, NomeConvenio, ItemGuiaID, GuiaConsultaID, ItemHonorarioID, Link, ValorProcedimento, ValorPago)
                            call repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, "Pendente", ValorProcedimento, ValorPago, 100, Link )                
                        end if
                    %>
                        </table>
                    </div>
                </div>
                    <%
                    if contaLR=0 then
                        %>
                        <script type="text/javascript">$("#panel<%=idPanel %>").css("display", "none");</script>
                        <%
                    else
                        totalProcedimentos = totalProcedimentos + ValorProcedimento
                    end if
            ii.movenext
            wend
            ii.close
            set ii = nothing

            %>
</form>
<hr class="short alt" />
<div class="panel"><div class="panel-body">
    <table class="table table-condensed table-bordered">
        <thead>
            <tr>
                <th width="25%" class="text-center">Total Serviços</th>
                <th width="25%" class="text-center">Total Repasses</th>
                <th width="25%" class="text-center">Total Materiais</th>
                <th width="25%" class="text-center">Total Resultado</th>
            </tr>
        </thead>
        <tbody>
                <th width="25%" class="text-right"><%= fn(totalProcedimentos) %></th>
                <th width="25%" class="text-right"><%= fn(totalRepasses) %></th>
                <th width="25%" class="text-right"><%= fn(totalMateriais) %></th>
                <th width="25%" class="text-right"><%= fn( totalProcedimentos - totalRepasses - totalMateriais ) %></th>
        </tbody>
    </table>
</div></div>