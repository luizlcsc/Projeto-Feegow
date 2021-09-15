    <!--#include file="connect.asp"-->
<%

totalRepasses = 0
totalRecebido = 0
totalMateriais = 0
totalProcedimentos = 0


private function tituloTabelaRepasseConvenio(Classe, Titulo, ItemGuiaID, GuiaConsultaID, ItemHonorarioID, Tabela, PagtoID, ValorRecebido, Extras)
    %>
    <td width="50%">
        <%if Classe<>"dark" then %>
            <div class="checkbox-custom checkbox-<%= Classe %> ptn mtn">
                <input type="checkbox" name="linhaRepasse" value="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>" id="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>"><label for="<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>"> <%= Titulo %>: <%= FormaPagto %></label>
            </div>
        <% end if %>
        <div><%= Titulo %>: <%= FormaPagto %></div>
        <div>Recebido: <%= fn(ValorRecebido) %></div>
        <div><%= Extras %></div>
    </td>
    <%
    totalRecebido = totalRecebido + fn(ValorRecebido)
end function

private function calcCreditado(ContaCredito, ProfissionalExecutante)
    if ContaCredito="PRO" then
        calcCreditado = ProfissionalExecutante
    elseif ContaCredito="LAU" then
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




private function repasse( rDataExecucao, rGuiaID, rNomeProcedimento, rNomePaciente, rItemGuiaID, rValorProcedimento, rValorRecebido, rPercentual, Tabela, rQuantidade )

   '' response.write(rValorRecebido)
    coefPerc = rPercentual / 100
    'conferir -> FormaID pode ser |P| para todos particulares, |C| para todos convênios, |00_0| para forma predefinida de recto e > |0| para qualquer id de convênio
    set fd = db.execute("select * from rateiofuncoes where DominioID="&DominioID&" order by Sobre")
    nLinha = 0

    valorPagoPeloConvenio = getConfig("ValorPagoPeloConvenio")


    if isnumeric(rValorRecebido) then
        if valorPagoPeloConvenio = 1 and rValorRecebido>0 then
           ValorBase = rValorRecebido
        end if
    end if
    fQuantidade = rQuantidade

    while not fd.eof
        '-> Começa a coletar os dados pra temprepasses (antiga rateiorateios)
        Funcao = replace(fd("Funcao")&"","|","_")
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
        modoCalculo = fd("modoCalculo")
        gravaTemp = 0
        valorDescontadoDoItemAnterior = 0

        Quantidade = 1

        if fQuantidade<>"" then
            if isnumeric(fQuantidade) then
                Quantidade =fQuantidade
            end if
        end if


        if TipoValor="V" then
            Valor  = Valor * Quantidade
        end if


        if ultimoSobre<>Sobre then
            ValorBase = ValorBase - somaDesteSobre
            valorDescontadoDoItemAnterior=somaDesteSobre
            somaDesteSobre = 0
        end if
        '<-
        'Funcao da arvore para conta crédito (F ou M)
        if fd("FM")="F" or fd("FM")="M" then
            if ContaPadrao="PRO" then
                ContaCredito = ii("ProfissionalID")
            elseif ContaPadrao="LAU" then
                if Tabela="tissguiasadt" then
                    set LauProf = db.execute("SELECT ProfissionalID FROM laudos WHERE Tabela='tissprocedimentossadt' AND IDTabela="&ItemGuiaID&" LIMIT 1")
                    if not LauProf.eof then
                        ContaCredito = LauProf("ProfissionalID")
                    else
                        ContaCredito = ""
                    end if
                else
                    ContaCredito = ii("ProfissionalID")
                end if
            elseif ContaPadrao="SOL" then
               ContaCredito = ii("ProfissionalSolicitanteID")
            else
                ContaCredito = fd("ContaPadrao")
            end if

            if fd("FM")="M" and TypeName(iio)<>"Empty" then
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
    '    response.write(ValorItem)
            Associacao = 5
            if Tabela = "tissguiasadt" then
                set ProfAssoc = db.execute("select Associacao from tissprocedimentossadt where id="&ItemGuiaID)
                if not ProfAssoc.eof then
                    Associacao = ProfAssoc("Associacao")
                end if
            else
                if Tabela = "tissguiahonorarios" then
                    set ProfAssoc2 = db.execute("select Associacao from tissprocedimentoshonorarios where id="&ItemGuiaID)
                    if not ProfAssoc2.eof then
                        Associacao = ProfAssoc2("Associacao")
                    end if
                end if
            end if
            if Creditado<>"" then
                somaDesteSobre = somaDesteSobre+ValorItem
                if Creditado<>"0" then
                    Despesas = Despesas + ValorItem
                    if instr( Creditado, "_")=0 then
                        Creditado = Associacao&"_"& Creditado
                    end if
                end if
                'response.write "profissional "&ProfissionalExecutante&" id "&Tabela

                'linhaRepasseG = ItemInvoiceID &"|"& ItemDescontadoID &"|"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID
                linhaRepasse = "||"& ItemGuiaID &"|"& GuiaConsultaID &"|"& ItemHonorarioID &"|"& Funcao &"|"& ValorItem*coefPerc &"|"& Creditado &"|"& Parcela &"|"& FormaID &"|"& Sobre &"|"& FM &"|"& ProdutoID &"|"& ValorUnitario &"|"& Quantidade &"|"& FuncaoID &"|"& Percentual &"|"& ParcelaID &"|"& modoCalculo

                %>
                <input type="hidden" name="linhaRepasse<%= ItemGuiaID & GuiaConsultaID & ItemHonorarioID &"_"& Tabela %>" value="<%= linhaRepasse %>" />
                <%
                nLinha = nLinha+1

                'lrResult( lrDataExecucao, lrNomeFuncao, lrInvoiceID, lrNomeProcedimento, lrNomePaciente, lrFormaPagto, lrCreditado, lrValorProcedimento, lrValorRecebido, lrValorRepasse )
                if reqf("AccountID")&""<> "" then
                    if Creditado = reqf("AccountID") then
                        call lrResult( "Calculo", rDataExecucao, DominioID & ": "& Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, (ValorItem * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
                    end if
                else
                    call lrResult( "Calculo", rDataExecucao, DominioID & ": "& Funcao, rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, Creditado, rValorProcedimento, rValorRecebido, (ValorItem * coefPerc), nLinha, fd("FM"), fd("Sobre"), fd("modoCalculo") )
                end if
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
                Response.Flush()
            kit.movenext
            wend
            kit.close
            set kit = nothing
        end if
    


        ultimoSobre = Sobre
        Response.Flush()
    fd.movenext
    wend
    fd.close
    set fd=nothing

end function

De = reqf("De")
Ate = reqf("Ate")
StatusBusca = reqf("Status")
if reqf("Unidades")="" then
    Unidades = session("Unidades")&""
else
    Unidades = reqf("Unidades")
end if
%>


<form method="post" id="frmRepasses" name="frmRepasses">
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title">Repasses de Convênio</span>
        </div>
        <div class="panel-body">
                <table class="table table-condensed table-bordered table-hover">
                    <thead>
                        <th width="2%"></th>
                        <th>Execução</th>
                        <th>Paciente</th>
                        <th>Unidade</th>
                        <th>Data da Conta</th>
                        <th>Solicitante</th>
                        <th>Especialidade</th>
                        <th>Procedimento</th>
                        <th>Valor</th>
                    </thead>
                    <tbody>

            <%
            'db_execute("delete from temprepasse where sysUser="&session("User"))
            ContaProfissional = ""
            if instr(reqf("AccountID"), "_") then

                ContaProfissionalSplt =split(reqf("AccountID"),"_")
                gsContaProfissional = " AND ps.ProfissionalID="& ContaProfissionalSplt(1)&" AND ps.Associacao="&ContaProfissionalSplt(0)&" "
                gcContaProfissional = " AND ifnull(gc.ProfissionalEfetivoID, gc.ProfissionalID)="& ContaProfissionalSplt(1)
            end if

            
            if reqf("ProcedimentoID")<>"0" then
                if instr(reqf("ProcedimentoID"), "G")>0 then
                    set procsGP = db.execute("select group_concat(id) procs from procedimentos where GrupoID="& replace(reqf("ProcedimentoID"), "G", ""))
                    procs=procsGP("procs")
                    if isnull(procs) then
                        sqlProcedimento = " AND t.ProcedimentoID IN (-1) "
                    else
                        sqlProcedimento = " AND t.ProcedimentoID IN ("& procs &") "
                    end if
                else
                    sqlProcedimento = " AND t.ProcedimentoID="& reqf("ProcedimentoID") &" "

                end if
            end if

            if Unidades<>"" then
                sqlUnidadesGC = " AND gc.UnidadeID IN ("& replace(Unidades, "|", "") &") "
                sqlUnidadesGS = " AND gs.UnidadeID IN ("& replace(Unidades, "|", "") &") "
                sqlUnidadesGH = " AND gh.UnidadeID IN ("& replace(Unidades, "|", "") &") "
            end if

            if reqf("TipoData")="Exec" then

                sqlII = "select  u.CompanyUnit, t.sysDate,s.Nome ProfissionalSolicitante, t.ProfissionalSolicitanteID, esp.Especialidade, link, Tipo, ConvenioID, t.id, t.PacienteID, ProfissionalID, GuiaID, t.ProcedimentoID, `Data`, ValorTotal, t.UnidadeID, ValorPago, proc.NomeProcedimento, pac.NomePaciente, c.NomeConvenio, pac.Tabela, ValorPagoOriginal, Quantidade FROM "&_
                                "(select concat(gs.tipoProfissionalSolicitante,'_', gs.ProfissionalSolicitanteID) ProfissionalSolicitante, concat(IF(gs.tipoProfissionalSolicitante='E', '8_', '5_'), gs.ProfissionalSolicitanteID) ProfissionalSolicitanteID, concat(ps.Associacao,'_',ps.ProfissionalID) Especialidade,gs.PacienteID, gs.ConvenioID, 'tissguiasadt' link, 'SP/SADT' Tipo, ps.id, ps.ProfissionalID, ps.GuiaID, ps.ProcedimentoID, ps.`Data`, ps.ValorTotal, gs.UnidadeID, ifnull(gs.ValorPago, 0) ValorPago, ps.ValorPago as ValorPagoOriginal, ps.Quantidade, gs.sysDate from tissguiasadt gs "&_
                                 "INNER JOIN tissprocedimentossadt ps on ps.GuiaID=gs.id WHERE gs.sysActive=1 AND gs.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND ps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gsContaProfissional & sqlUnidadesGS &" "&_
                                 "UNION ALL select concat( '5_',gh.Contratado), concat('5_', gh.Contratado) ProfissionalSolicitanteID, concat(ps.Associacao,'_',ps.ProfissionalID) Especialidade, gh.PacienteID, gh.ConvenioID, 'tissguiahonorarios' link, 'Honorários' Tipo, ps.id, ps.ProfissionalID, ps.GuiaID, ps.ProcedimentoID, ps.`Data`, ps.ValorTotal, gh.UnidadeID, ifnull(gh.ValorPago, 0) ValorPago,ps.ValorPago  as ValorPagoOriginal, ps.Quantidade, gh.sysDate from tissguiahonorarios gh "&_
                                 "INNER JOIN tissprocedimentoshonorarios ps on ps.GuiaID=gh.id WHERE gh.sysActive=1 AND gh.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND ps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gsContaProfissional & sqlUnidadesGH

                                 sqlII=sqlII&"UNION ALL select '' ProfissionalSolicitante, '' ProfissionalSolicitanteID, concat('5_',gc.ProfissionalID) Especialidade, gc.PacienteID, gc.ConvenioID, 'tissguiaconsulta' link, 'Consulta' Tipo, gc.id, ifnull(gc.ProfissionalEfetivoID, gc.ProfissionalID), gc.id GuiaID, gc.ProcedimentoID, gc.DataAtendimento `Data`, gc.ValorProcedimento ValorTotal, gc.UnidadeID, ifnull(gc.ValorPago, 0) ValorPago, gc.ValorPago as ValorPagoOriginal, 1 Quantidade, gc.sysDate from tissguiaconsulta gc "&_
                                 "WHERE gc.sysActive=1 AND gc.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND gc.DataAtendimento BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gcContaProfissional & sqlUnidadesGC
                                                        
                    sqlII=sqlII&") t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID "&_
                                 "left join ((select 0 as 'id',  NomeFantasia CompanyUnit FROM empresa WHERE id=1) UNION ALL (select id,  NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia)) u on u.id = t.UnidadeID"&_
                                " left join (select * from (select concat('I_',z.id) id, z.Nome, z.EspecialidadeID from ( "&_
                                " SELECT '0' id, e.NomeFantasia Nome, '' EspecialidadeID FROM empresa e WHERE NOT ISNULL(e.NomeFantasia) "&_
                                " UNION ALL SELECT u.id*(-1), u.NomeFantasia, '' EspecialidadeID FROM sys_financialcompanyunits u WHERE NOT ISNULL(u.UnitName)"&_
                                " UNION ALL SELECT p.id, p.NomeProfissional, p.EspecialidadeID FROM profissionais p)z "&_
                                " UNION ALL SELECT CONCAT('E_', id) id, NomeProfissional, EspecialidadeID FROM profissionalexterno)s)s on s.id = t.ProfissionalSolicitante"&_
                                " left join (SELECT w.id, e.especialidade FROM ("&_
                                " SELECT CONCAT('5_', id) id, EspecialidadeID FROM profissionais"&_
                                " UNION ALL"&_
                                " SELECT CONCAT('8_', id) id, EspecialidadeID FROM profissionalexterno ) w"&_
                                " left join especialidades e on e.id = EspecialidadeID) esp on esp.id = t.Especialidade WHERE TRUE "& sqlProcedimento &_
                                 " ORDER BY t.Data"

            else
                sqlII = "select u.CompanyUnit, t.sysDate, s.Nome ProfissionalSolicitante, t.ProfissionalSolicitanteID, esp.Especialidade, link, Tipo, ConvenioID, t.id, t.PacienteID, t.ProfissionalID, GuiaID, ProcedimentoID, `Data`, ValorTotal, t.UnidadeID, ValorPago , ValorPago ValorPagoOriginal, proc.NomeProcedimento, pac.NomePaciente, c.NomeConvenio, pac.Tabela, Quantidade FROM ("&_
"select '' ProfissionalSolicitante, '' ProfissionalSolicitanteID, concat('5_',gc.ProfissionalID) Especialidade, gc.PacienteID, gc.ConvenioID, 'tissguiaconsulta' link, 'Consulta' Tipo, gc.id, ifnull(gc.ProfissionalEfetivoID, gc.ProfissionalID) ProfissionalID, gc.id GuiaID, gc.ProcedimentoID, gc.DataAtendimento `Data`, gc.ValorProcedimento ValorTotal, gc.UnidadeID, ifnull(gc.ValorPago, 0) ValorPago, 1 Quantidade, gc.sysDate from sys_financialmovement m "&_
"LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"LEFT JOIN tissguiasinvoice tgi ON tgi.ItemInvoiceID=ii.id "&_
"LEFT JOIN tissguiaconsulta gc ON gc.id=tgi.GuiaID "&_
"WHERE gc.sysActive=1 AND gc.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND m.Type<>'Bill' AND tgi.TipoGuia='guiaconsulta' AND "&_
"m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gcContaProfissional & sqlUnidadesGC &_
"GROUP BY gc.id "&_
                "UNION ALL "&_
"select concat(gs.tipoProfissionalSolicitante,'_', gs.ProfissionalSolicitanteID), concat(IF(gs.tipoProfissionalSolicitante='E', '8_', '5_'), gs.ProfissionalSolicitanteID) ProfissionalSolicitanteID , concat(ps.Associacao,'_',ps.ProfissionalID) Especialidade,gs.PacienteID, gs.ConvenioID, 'tissguiasadt' link, 'SADT' Tipo, ps.id, ps.ProfissionalID, gs.id GuiaID, ps.ProcedimentoID, ps.Data, ps.ValorTotal, gs.UnidadeID, ifnull(ps.ValorPago, gs.ValorPago) ValorPago, ps.Quantidade, gs.sysDate FROM sys_financialmovement m "&_
"LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"LEFT JOIN tissguiasinvoice tgi ON tgi.ItemInvoiceID=ii.id "&_
"LEFT JOIN tissguiasadt gs ON gs.id=tgi.GuiaID "&_
"LEFT JOIN tissprocedimentossadt ps ON ps.GuiaID=gs.id "&_
"WHERE gs.sysActive=1 AND gs.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND m.Type<>'Bill' AND tgi.TipoGuia='guiasadt' AND "&_
"m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gsContaProfissional & sqlUnidadesGS &_
" GROUP BY ps.id " &_
                "UNION ALL "&_
"select concat( '5_',gh.Contratado), concat('5_', gh.Contratado) ProfissionalSolicitanteID,  concat(ps.Associacao,'_',ps.ProfissionalID) Especialidade, gh.PacienteID, gh.ConvenioID, 'tissguiahonorarios' link, 'Honorários' Tipo, ps.id, ps.ProfissionalID, gh.id GuiaID, ps.ProcedimentoID, ps.Data, ps.ValorTotal, gh.UnidadeID, ifnull(ps.ValorPago, gh.ValorPago) ValorPago, ps.Quantidade, gh.sysDate FROM sys_financialmovement m "&_
"LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id "&_
"LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID "&_
"LEFT JOIN tissguiasinvoice tgi ON tgi.ItemInvoiceID=ii.id "&_

"LEFT JOIN tissguiahonorarios gh ON gh.id=tgi.GuiaID "&_
"LEFT JOIN tissprocedimentoshonorarios ps ON ps.GuiaID=gh.id "&_
"WHERE gh.sysActive=1 AND gh.ConvenioID IN ("& replace(reqf("Forma"), "|", "") &") AND m.Type<>'Bill' AND tgi.TipoGuia='guiahonorarios' AND "&_
"m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) & gsContaProfissional & sqlUnidadesGH &_
" GROUP BY gh.id " &_
                ") t LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN convenios c ON c.id=t.ConvenioID"&_
                " left join ((select 0 as 'id',  NomeFantasia CompanyUnit FROM empresa WHERE id=1) UNION ALL (select id,  NomeFantasia FROM sys_financialcompanyunits WHERE sysActive=1 order by NomeFantasia)) u on u.id = t.UnidadeID"&_
                " left join (select * from (select concat('I_',z.id) id, z.Nome, z.EspecialidadeID from ( "&_
                " SELECT '0' id, e.NomeFantasia Nome, '' EspecialidadeID FROM empresa e WHERE NOT ISNULL(e.NomeFantasia) "&_
                " UNION ALL SELECT u.id*(-1), u.NomeFantasia, '' EspecialidadeID FROM sys_financialcompanyunits u WHERE NOT ISNULL(u.UnitName)"&_
                " UNION ALL SELECT p.id, p.NomeProfissional, p.EspecialidadeID FROM profissionais p)z "&_
                " UNION ALL SELECT CONCAT('E_', id) id, NomeProfissional, EspecialidadeID FROM profissionalexterno)s)s on s.id = t.ProfissionalSolicitante"&_
                " left join (SELECT w.id, e.especialidade FROM ("&_
                " SELECT CONCAT('5_', id) id, EspecialidadeID FROM profissionais"&_
                " UNION ALL"&_
                " SELECT CONCAT('8_', id) id, EspecialidadeID FROM profissionalexterno ) w"&_
                " left join especialidades e on e.id = EspecialidadeID) esp on esp.id = t.Especialidade "
            end if
            
            if reqf("DEBUG")="1" then
                response.write( sqlII )
            end if
            set ii = db.execute( sqlII )
            
                'se ii("Repassado")=0 joga pra temprepasse, else exibe o q ja foi pra rateiorateios
                if session("Banco")="clinic3882" then
                    'response.write( sqlII )
                end if

            while not ii.eof

                ProfissionalExecutante = ii("ProfissionalID")
                Link = ii("Link")
                ItemGuiaID = ii("id")
                ItemHonorarioID = ii("id")
                GuiaID = ii("GuiaID")
                ProcedimentoID = ii("ProcedimentoID")
                DataExecucao = ii("Data")
                NomeProcedimento = ii("NomeProcedimento")
                Quantidade = ii("Quantidade")

              '  valorPagoPeloConvenio = getConfig("ValorPagoPeloConvenio")
        
                ValorProcedimento = ii("ValorTotal")

                NomePaciente = ii("NomePaciente")
                NomeConvenio = ii("NomeConvenio")
               
                ValorPago = ii("ValorPagoOriginal")


                ConvenioID = ii("ConvenioID")
                btnExtra = ""
                desfazBtnCons = ""

                PercentualPago = 0
                TotalPago = 0
                TotalRepassado = 0
                PercentualRepassado = 0

                contaLR = 0

                'modificação 29102019
                UnidadeName = ii("CompanyUnit")
                Solicitante = ii("ProfissionalSolicitante")

                if ii("sysDate")&"" <> "" then
                    DataDaConta = FormatDateTime(ii("sysDate"),2)
                else
                    DataDaConta = ""
                end if
                Especialidade = ii("especialidade")


                sqlrr = ""

                if Link="tissguiaconsulta" then
                    GuiaConsultaID = GuiaID
                    ItemGuiaID = ""
                    ItemHonorarioID = ""
                    sqlrr = " rr.GuiaConsultaID="& GuiaConsultaID &" "
                    ColunaRR = "GuiaConsultaID"
                elseif Link="tissguiasadt" then
                    ItemHonorarioID = ""
                    GuiaConsultaID = ""
                    sqlrr = " rr.ItemGuiaID="& ItemGuiaID &" "
                    ColunaRR = "ItemGuiaID"
                elseif Link="tissguiahonorarios" then
                    'ItemGuiaID = ""
                    GuiaConsultaID = ""
                    ColunaRR = "ItemHonorarioID"
                    sqlrr = " rr.ItemHonorarioID="& ItemHonorarioID &" "
                end if

                idPanel = GuiaConsultaID &"_"& ItemGuiaID &"_"& ItemHonorarioID
                %>
            <tr class="panel<%= idPanel %>">
                <td rowspan="2" valign="top" style="vertical-align:top">
                    <a target="_blank" class="btn btn-xs text-dark mn" href="./?P=<%= Link %>&Pers=1&I=<%= GuiaID %>&ItemGuiaID=<%=ItemGuiaID%>">
                        <i class="far fa-chevron-right"></i>
                    </a>
                </td>
                <td> <%= DataExecucao %></td>
                <td><%= NomePaciente %></td>
                <td><%= UnidadeName %></td>
                <td><%= DataDaConta %></td>
                <td><%= Solicitante %></td> 
                <td><%= Especialidade %></td>
                <td><%= NomeProcedimento %></td>
                <td><%= fn(ValorProcedimento) %></td>
            </tr>
            <tr class="panel<%= idPanel %>">
                <td colspan="8">
                    <table class="table table-hover table-condensed">
                <%

                        ultimoSobre = ""
                        somaDesteSobre = 0
                        ValorBase = ValorProcedimento
                        DominioID = dominioRepasse("|"& ConvenioID &"|", ii("ProfissionalID"), ProcedimentoID, ii("UnidadeID"), ii("Tabela"), "", DataExecucao, HoraExecucao)

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

                        set rr = db.execute("select rr.id, GuiaConsultaID, Funcao, ItemGuiaID, ItemHonorarioID, GrupoConsolidacao, ItemContaAPagar, ItemContaAReceber, Valor, CreditoID, ContaCredito, FM, Sobre, modoCalculo from rateiorateios rr where "& sqlrr )

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
                            IDColunaRR = rr(""& ColunaRR &"")
                            GrupoConsolidacao = rr("GrupoConsolidacao")
                            ItemContaAPagar = rr("ItemContaAPagar")
                            ItemContaAReceber = rr("ItemContaAReceber")
                            CreditoID = rr("CreditoID")
                        end if
                        
                        if Exibir=1 or StatusBusca="" then
                            if Classe="dark" then
                                valBtnDesc = "C|"& ColunaRR &"|"& IDColunaRR &"|"& GrupoConsolidacao
                                idBtnDesc = replace(valBtnDesc, "|", "_")
                        btnExtra = "<div class='checkbox-custom pull-right ptn mtn'><input type='checkbox' name='desconsAll' value='"& valBtnDesc &"' id='"& idBtnDesc &"'><label for='"& idBtnDesc &"'></label></div>"&_ 
                    
                    
                    "<button type='button' onclick=""desconsolida('C', '"& ColunaRR &"', "& IDColunaRR &", "& GrupoConsolidacao &")"" id='desconsolidar"& ColunaRR &"_"& IDColunaRR &"_"& GrupoConsolidacao &"' class='btn btn-xs btn-danger pull-right hidden-print mt10'>Desconsolidar</button>"
                            end if
                            %>
                            <tr class="<%= Classe %>">
                                <%= tituloTabelaRepasseConvenio(Classe, NomeConvenio, ItemGuiaID, GuiaConsultaID, ItemHonorarioID, Link, ValorProcedimento, ValorPago, btnExtra) %>
                                <td width="50%" class="<%= Classe %>">
                                    <table class="table table-condensed">



                                        <%
                                        if rr.eof then
                                            call repasse( DataExecucao, InvoiceID, NomeProcedimento, NomePaciente, "Pendente", ValorProcedimento, ValorPago, 100, Link, Quantidade )
                                        else
                                            while not rr.eof
                                                call lrResult( "RateioRateios", rDataExecucao, replace(rr("Funcao")&"","|","_"), rInvoiceID, rNomeProcedimento, rNomePaciente, rFormaPagto, rr("ContaCredito"), ValorProcedimento, ValorPago, rr("Valor"), nLinha, rr("FM"), rr("Sobre"), rr("modoCalculo") )
                                                Response.Flush()
                                            rr.movenext
                                            wend
                                            rr.close
                                            set rr = nothing
                                        end if
                                        %>



                                    </table>
                                </td>
                            </tr>
                            <%
                            if (not isnull(ItemContaAPagar) or not isnull(ItemContaAReceber) or not isnull(CreditoID)) and idBtnDesc&""<>"" then
                                desfazBtnCons = desfazBtnCons & "$('#desconsolidar"& ColunaRR &"_"& IDColunaRR &"_"& GrupoConsolidacao &", #"& idBtnDesc &"').prop('disabled', true);"
                                %>
                                <script><%=desfazBtnCons %></script>
                                <%
                            end if

                        end if
                    %>
                        </table>
                    </div>
                </div>
                    <%
                    if contaLR=0 then
                        %>
                        <script type="text/javascript">$(".panel<%=idPanel %>").css("display", "none");</script>
                        <%
                    else
                        totalProcedimentos = totalProcedimentos + ValorProcedimento
                    end if
                    Response.Flush()
            ii.movenext
            wend
            ii.close
            set ii = nothing

            %>
                </tbody>
            </table>
            <hr class="short alt" />
            <table class="table table-condensed table-bordered">
                <thead>
                    <tr>
                        <th width="20%" class="text-center">Total Serviços</th>
                        <th width="20%" class="text-center">Total Recebido</th>
                        <th width="20%" class="text-center">Total Repasses</th>
                        <th width="20%" class="text-center">Total Materiais</th>
                        <th width="20%" class="text-center">Total Resultado</th>
                    </tr>
                </thead>
                <tbody>
                        <th width="20%" class="text-right"><%= fn(totalProcedimentos) %></th>
                        <th width="20%" class="text-right"><%= fn(totalRecebido) %></th>
                        <th width="20%" class="text-right"><%= fn(totalRepasses) %></th>
                        <th width="20%" class="text-right"><%= fn(totalMateriais) %></th>
                        <th width="20%" class="text-right"><%= fn( totalRecebido - totalRepasses - totalMateriais ) %></th>
                </tbody>
            </table>
        </div>
    </div>
</form>
