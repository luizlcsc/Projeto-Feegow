<!--#include file="connect.asp"-->
<!--#include file="extenso.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<%
'##############
'*** PREPARA DADOS PARA CONVERTER TAGS DE PROFISSIONAL EXECUTANTE QNDO EXTERNO OU INTERNO
'21/10/2020 NÃO EXISTE TAG QUE TRATE LISTA DE PROFISSIONAIS EXECUTANTES EX.: [ProfissionalExecutante.Lista] Caso seja criado basta ajustar o código abaixo.
'##############
ProfissionaisExecutante = req("ProfissionalExecutante")
if ProfissionaisExecutante&""<>"" then
    ProfExec__array = split(ProfissionaisExecutante, ",")
    For ProfExecLista = 0 To ubound(ProfExec__array)
        ProfExec = split(ProfissionaisExecutante, ",")
        ProfissionalLinha = ProfExec(ProfExecLista)

        if ProfissionalLinha<> "" then
            ProfExecItem = split(ProfissionalLinha, "_")

            If UBound(ProfExecItem) >= 1 Then
                val__ProfissionalExecutanteTipo = ProfExecItem(0)
                val__ProfissionalExecutanteID = ProfExecItem(1)
            else
                val__ProfissionalExecutanteTipo=0
                val__ProfissionalExecutanteID=0
            end if

            if val__ProfissionalExecutanteTipo=5 then
                ProfissionalExecutanteID = "|ProfissionalID_"&val__ProfissionalExecutanteID
            end if
            if val__ProfissionalExecutanteTipo=8 then
                ProfissionalExecutanteExternoID = "|ProfissionalExecutanteExternoID_"&val__ProfissionalExecutanteID
            end if
            'response.write("Valor: "& ProfExec(ProfExecLista) &" :: "&ProfissionalExecutanteTipo&"<br>")
        end if
    next
end if
%>


<div class="modal-header">
    <h3 class="blue">Contrato</h3>
</div>
<div class="modal-body">
    <div class="row" id="divContrato">



<%
if request.ServerVariables("REMOTE_ADDR")<>"::1" then
'    on error resume next
end if


ModeloID = req("ModeloID")
if req("InvoiceID")<>"" then
    InvoiceID = ccur(req("InvoiceID"))
end if
if req("Tipo")="SADT" then
    'InvoiceID = InvoiceID*(-1)
end if
ContaID = req("ContaID")
ContratoID = req("I")

splConta = split(ContaID, "_")

if ModeloID="0" or ModeloID="X" then
    if ModeloID="X" then
        db_execute("delete from contratos where id="&InvoiceID)
    end if
    %>
    <table class="table table-striped table-hover">
    <thead>
        <tr>
            <th>Data de Criação</th>
            <th>Usuário</th>
            <th>Modelo</th>
            <th width="1%"></th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
    <%
    set conts = db.execute("select c.id, c.DataHora, c.sysUser, m.NomeModelo from contratos c LEFT JOIN contratosmodelos m on m.id=c.ModeloID where Associacao="&splConta(0)&" AND ContaID="&splConta(1)&"")
    while not conts.eof
        %>
        <tr>
            <td><%=conts("DataHora") %></td>
            <td><%=nameInTable(conts("sysUser")) %></td>
            <td><%=conts("NomeModelo") %></td>
            <td><button class="btn btn-xs btn-success" onclick="openContrato(<%=conts("id") %>)"><i class="far fa-edit"></i></button></td>
            <td><button class="btn btn-xs btn-danger" onclick="javascript:if(confirm('Tem certeza de que deseja apagar este contrato?'))addContrato('X', <%=conts("id") %>, '<%=ContaID %>')"><i class="far fa-remove"></i></button></td>
        </tr>
        <%
    conts.movenext
    wend
    conts.close
    set conts=nothing
    %>
    </tbody>
    </table>
    <%
elseif ModeloID<>"" and ModeloID<>"0" then
    
    if req("Tipo")<>"SADT" then
        set pinv = db.execute("select i.*, coalesce(mov.ValorPago) ValorPago from sys_financialinvoices i join sys_financialmovement mov on mov.InvoiceID=i.id where i.id="&InvoiceID)
        if not pinv.eof then
            ValorPago = pinv("ValorPago")
            ValorTotal = pinv("Value")
            TotalPendente = ValorTotal - ValorPago
            PacienteContrato = pinv("AccountID")
            UnidadeInvoiceID = pinv("CompanyUnitID")
        end if

        set pmod = db.execute("select * from contratosmodelos where id="&ModeloID)
        if not pmod.eof then
            ModeloContrato = pmod("Conteudo")
            AgruparExecutante = pmod("AgruparExecutante")
            AgruparParcela = pmod("AgruparParcela")
        end if

        ModeloContrato=replace(ModeloContrato,"AReceber","Receita")


        ModeloContrato = replace(ModeloContrato, "[Receita.ValorTotal]", fn(ValorTotal))
        ModeloContrato = replace(ModeloContrato, "[Receita.TotalPago]", fn(ValorPago))
        ModeloContrato = replace(ModeloContrato, "[Receita.ValorPendente]", fn(TotalPendente))

        if instr(ModeloContrato, "[Receita.PrimeiroVencimento]")>0 and InvoiceID>0 then
            set PrimeiroVencimentoSQL = db.execute("SELECT date FROM sys_financialmovement WHERE InvoiceID="&InvoiceID&" AND Type='Bill' order by Date ASC")
            if not PrimeiroVencimentoSQL.eof then
                ModeloContrato = replace(ModeloContrato, "[Receita.PrimeiroVencimento]", PrimeiroVencimentoSQL("date"))
            end if

        end if
        ModeloContrato = replace(ModeloContrato, "[Procedimento.Nome]", "[Receita.ProcedimentosAgrupados]")

        if instr(ModeloContrato, "[Receita.ProcedimentosAgrupados]")>0 and InvoiceID>0 then
            set distProcs = db.execute("select proc.NomeProcedimento, ii.Quantidade, ii.ValorUnitario, ii.Desconto, ii.Acrescimo from itensinvoice ii left join procedimentos proc on proc.id=ii.ItemID where ii.InvoiceID="& InvoiceID &" group by ItemID")
            while not distProcs.eof
                if session("Banco")="clinic6118" or session("Banco")="clinic100000" then
                    Valor = (distProcs("ValorUnitario") - distProcs("Desconto")) + distProcs("Acrescimo")
                    if Valor<=0 then
                        Valor = 0
                    end if
                    ProcsDist = ProcsDist & "<p>" & distProcs("Quantidade") & "x " & distProcs("NomeProcedimento") &" - Valor: R$" & Valor & "</p>"
                else
                    ProcsDist = ProcsDist & ", " & distProcs("NomeProcedimento")
                end if
            distprocs.movenext
            wend
            distProcs.close
            set distProcs=nothing
            if session("Banco")="clinic6118" or session("Banco")="clinic100000" then
                ProcsDist = right(ProcsDist, len(ProcsDist)-3)
            else
                ProcsDist = right(ProcsDist, len(ProcsDist)-2)
            end if
            ModeloContrato = replace(ModeloContrato, "[Receita.ProcedimentosAgrupados]", ProcsDist)
        end if
        if InvoiceID<0 then
            PacienteContrato = replace(req("ContaID"), "3_", "")
            ModeloContrato = replace(ModeloContrato, "[Receita.ProcedimentosAgrupados]", "")
        end if

        if instr(ModeloContrato, "[ProximoAgendamento.Profissional]") then
            set pag = db.execute("select prof.NomeProfissional from agendamentos a left join profissionais prof on prof.id=a.ProfissionalID where (a.Data>curdate() or (a.Data=curdate() and a.Hora>curtime())) and PacienteID="& PacienteContrato)
            if not pag.eof then
                NomeProfissional = pag("NomeProfissional") &""
            end if
            ModeloContrato = replace(ModeloContrato, "[ProximoAgendamento.Profissional]", NomeProfissional)
        end if
        'TAG ANTIGA DESATIVADA | RAFAEL MAIA 28/07/2020
        'ModeloContrato = replace(ModeloContrato, "[Contrato.Protocolo]", InvoiceID)
        ModeloContrato = TagsConverte(ModeloContrato,"ContratoID_"&req("InvoiceID")&ProfissionalExecutanteExternoID&ProfissionalExecutanteID,"") 

        if instr(ModeloContrato, "[UltimoFormulario.")>0 then
            splUF = split( ModeloContrato, "[UltimoFormulario." )
            for i=0 to ubound(splUF)
                splUFnomeform = split(splUF(i), ".")
                nomeUltimoForm = splUFnomeform(0)
                splUFnomecampo = split(splUFnomeform(1), "]")
                nomeCampoUF = splUFnomecampo(0)

                set pidform = db.execute("select id from buiforms where Nome like '"& rep(nomeUltimoForm) &"'")
                if not pidForm.eof then
                    idform = pidform("id")
                    set pidcampo = db.execute("select id from buicamposforms where FormID="& idform &" and NomeCampo like '"& rep(nomeCampoUF) &"'")
                    if not pidcampo.eof then
                        idcampo = pidcampo("id")
                        set bfp = db.execute("select * from `_"&idform&"` where PacienteID="&PacienteContrato&" order by DataHora desc limit 1")
                        if not bfp.eof then
                            Valor = bfp(""& idCampo &"")
                            ModeloContrato = replace(ModeloContrato, "[UltimoFormulario."& nomeUltimoForm &"."& nomeCampoUF &"]", Valor )
                        
                            'ModeloContrato = replace( ModeloContrato, "[UltimoFormulario.Primeira Consulta.Conduta]", "{[UltimoFormulario."& nomeUltimoForm &"."& nomeCampoUF &"]}")
                        end if
                    end if
                end if
            next
        end if


        if AgruparExecutante="S" then
            set exec = db.execute("select ProfissionalID, Associacao, LEFT(MD5(id), 7) AS senha from itensinvoice WHERE InvoiceID="&InvoiceID&" GROUP BY ProfissionalID")
            ValorTotal = 0
            while not exec.eof
                PreContrato = ModeloContrato
                if instr(PreContrato, "[Itens.Iniciar]")>0 and instr(PreContrato, "[Itens.Finalizar]")>0 then
                'response.write("oi")
                    splItens = split(PreContrato, "[Itens.Iniciar]")
                    splItens2 = split(splItens(1), "[Itens.Finalizar]")
                    modeloItens = splItens2(0)
                    EsteItem = ""
                    ContItens = ""

                    set ii = db.execute("select ii.*, p.NomeProcedimento, (ii.Quantidade * (ii.ValorUnitario + ii.Acrescimo - ii.Desconto)) ValorTotal from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID where ii.InvoiceID="&InvoiceID&" AND ii.ProfissionalID="& treatvalzero(exec("ProfissionalID")) )
                    while not ii.eof
                        EsteItem = replace(modeloItens, "[Itens.Descricao]", ii("NomeProcedimento")&"")
                        EsteItem = replace(EsteItem, "[Itens.Quantidade]", ii("Quantidade")&"")
                        EsteItem = replace(EsteItem, "[Itens.Obs]", ii("Descricao")&"")

                        if instr(EsteItem, "[Itens.Preco]") then
                            ValorEsteItem = ii("ValorTotal")
                            ValorTotal = ValorTotal+ValorEsteItem

                            EsteItem = replace(EsteItem, "[Itens.Preco]", "R$ "&fn(ValorEsteItem)&"")
                        end if
                        ContItens = ContItens & EsteItem
                    ii.movenext
                    wend
                    ii.close
                    set ii=nothing

                    PreContrato = splItens(0) & ContItens & splItens2(1)


                    if ValorTotal > 0 then
                        if instr(PreContrato, "[Itens.ValorTotal]") then
                            PreContrato = replace(PreContrato, "[Itens.ValorTotal]", "R$ "&fn(ValorTotal)&"")
                        end if
                    end if
                end if

                set pinv = db.execute("select i.*, (select count(id) from sys_financialmovement where InvoiceID=i.id) NumeroParcelas from sys_financialinvoices i where i.id="&InvoiceID)
                if not pinv.eof then
                    PreContrato = replace(PreContrato, "[Receita.Total]", "Total")
                    PreContrato = replace(PreContrato, "[Receita.NumeroParcelas]", pinv("NumeroParcelas"))
                    PreContrato = replace(PreContrato, "[Receita.TotalExtenso]", lcase(Extenso( pinv("Value"))) )
                    PreContrato = replace(PreContrato, "[Receita.CodigoBarras]", "[CodigoBarras."&zeroEsq(pinv("id"), 6)&"]")
                    PreContrato = replace(PreContrato, "[Receita.Numero]", zeroEsq(pinv("id"), 6))
                end if
                if exec("ProfissionalID")<>0 and not isnull(exec("ProfissionalID")) then

                    PreContrato = replace(PreContrato&"", "[Executante.Nome]", accountName(exec("Associacao"), exec("ProfissionalID")) )
                end if
                PreContrato = replacetags(PreContrato, replace(ContaID, "3_", ""), session("User"), pinv("CompanyUnitID"))
                PreContrato = replacePagto(PreContrato, pinv("Value"))
               
                'CONVERSÃO DA SENHA ADD PARA POSSIBILITAR A CUSTOMIZAÇÃO DO CONTRATO 2022-01-04
                'NÃO EXISTE CONSULTA DE ITENS NA FUNÇÃO TAGSCONVERTE.ASP
                if instr(PreContrato, "[Itens.Senha]") then
                    PreContrato = replace(PreContrato, "[Itens.Senha]", exec("senha"))
                end if
                if Contrato="" then
                    hr = ""
                else
                    hr = "<hr/>"
                end if
                Contrato = Contrato & hr & PreContrato
            ' response.Write("{"& exec("ProfissionalID") &"} <br>")
            exec.movenext
            wend
            exec.close
            set exec=nothing

            if len(Contrato)>3 then
            ' Contrato = replace(Contrato, "<hr/>", "", 1)
            end if
        elseif AgruparParcela="S" then
            set mov = db.execute("select * from sys_financialmovement WHERE InvoiceID="&InvoiceID&" order by Date")
            NumeroParcela = 0
            contaHR = -1
            while not mov.eof
                contaHR = contaHR+1
                NumeroParcela = NumeroParcela + 1
                PreContrato = ModeloContrato&""
                PreContrato = replace(PreContrato, "[Parcela.Vencimento]", mov("Date"))
                PreContrato = replace(PreContrato, "[Parcela.Documento]", zeroEsq(mov("InvoiceID"), 6))
                PreContrato = replace(PreContrato, "[Parcela.Numero]", NumeroParcela)
                PreContrato = replace(PreContrato, "[Parcela.Valor]", fn(mov("Value")))

                set pinv = db.execute("select i.*, (select count(id) from sys_financialmovement where InvoiceID=i.id) NumeroParcelas from sys_financialinvoices i where i.id="&InvoiceID)
                if not pinv.eof then
                    PreContrato = replace(PreContrato, "[Receita.Total]", "Total")
                    PreContrato = replace(PreContrato, "[Receita.NumeroParcelas]", pinv("NumeroParcelas"))
                    PreContrato = replace(PreContrato, "[Receita.TotalExtenso]", lcase(Extenso( pinv("Value"))) )
                    PreContrato = replace(PreContrato, "[Receita.CodigoBarras]", "[CodigoBarras."&zeroEsq(pinv("id"), 6)&"]")
                    PreContrato = replace(PreContrato, "[Receita.Numero]", zeroEsq(pinv("id"), 6))
                end if
                PreContrato = replacetags(PreContrato, replace(ContaID, "3_", ""), session("User"), pinv("CompanyUnitID"))
                PreContrato = replacePagto(PreContrato, pinv("Value"))
                if contaHR=3 then
                    hr = "<hr/>"
                    contaHR = 0
                else
                    hr = ""
                end if
                Contrato = Contrato & hr & PreContrato
            ' response.Write("{"& exec("ProfissionalID") &"} <br>")
            mov.movenext
            wend
            mov.close
            set mov=nothing
            if len(Contrato)>3 then
            ' Contrato = replace(Contrato, "<hr/>", "", 1)
            end if
            
        else
            Contrato = ModeloContrato

            if instr(ModeloContrato, "[Profissional.Nome]")>0 then
                set exec = db.execute("SELECT COUNT(DISTINCT ProfissionalID) as total from  itensinvoice WHERE InvoiceID="&InvoiceID)
                if not exec.eof then
                    total =  CInt(exec("total"))
                    if total =1 then
                        exec.close
                        set exec = db.execute("select * from itensinvoice WHERE InvoiceID="&InvoiceID&" GROUP BY ProfissionalID")
                        Contrato = replace(Contrato, "[Profissional.Nome]", accountName(exec("Associacao"), exec("ProfissionalID")) )
                    end if
                end if
                exec.close
                set exec=nothing
            end if

            if req("Tipo")<>"SADT" then
                set forma = db.execute("SELECT IF(bm.id IS NOT NULL, 1, cartao_credito.Parcelas) Parcelas, IF(bm.id IS NOT NULL, 'Boleto', forma_pagamento.PaymentMethod) PaymentMethod, pagamento.MovementID, IF(bm.id IS NOT NULL, debito.Value ,credito.`value`) Value, IF(bm.id IS NOT NULL, debito.sysUser, credito.sysUser) sysUser, debito.Date DataVencimento, credito.Date DataPagamento "&_
                                    "FROM sys_financialmovement debito "&_
                                    "LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID = debito.id  "&_
                                    "LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "&_
                                    "LEFT JOIN sys_financialpaymentmethod forma_pagamento ON forma_pagamento.id = credito.PaymentMethodID "&_
                                    "LEFT JOIN sys_financialcreditcardtransaction cartao_credito ON cartao_credito.MovementID=credito.id "&_
                                    "LEFT JOIN boletos_emitidos bm ON bm.MovementID=debito.id AND bm.StatusID NOT IN (3, 4) "&_
                                    "LEFT JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "&_
                                    "WHERE debito.InvoiceID="&pinv("id"))

                Parcelas = ""
                FormaPagto = ""
                DataVencimento = ""
                DataPagamento = ""
                while not forma.EOF
                    PaymentMethod = forma("PaymentMethod")
                    Parcela = forma("Parcelas")
                    value = forma("value")
                    Vencimento = forma("DataVencimento")
                    Pagamento = forma("DataPagamento")
                    DataVencimento = DataVencimento&"<br>"&Vencimento
                    DataPagamento = DataPagamento&"<br>"&Pagamento

                    if not isnull(PaymentMethod) then

                        if not isnull(Parcela) then
                            Parcelas =  ccur(Parcela)
                        else
                            Parcelas = "1"
                        end if
                        if not isnull(value) then
                            valorForma = "R$ "&formatnumber(value, 2)
                        else
                            valorForma = "R$ 0,00"
                        end if
                        FormaPagtoOri = "<br>"&"("& Parcelas &"x) "&PaymentMethod &" = "&valorForma
                        FormaPagto = FormaPagto &""& FormaPagtoOri

                    end if
                    UsuarioRecebimento=nameInTable(forma("sysUser"))
                forma.movenext
                wend
                forma.close
                set forma=nothing
            end if


            'Tags do agendamento
            set itensConta= db.execute("SELECT * FROM itensinvoice WHERE (AgendamentoID<>0 OR AgendamentoID IS NOT NULL) AND InvoiceID="&InvoiceID&" LIMIT 1")
            if not itensConta.eof then
                AgendamentoID = itensConta("AgendamentoID")
                set dadosAgendamento = db.execute("SELECT a.Data, a.Hora, unit.NomeFantasia, unit.Cep, unit.Endereco, unit.Numero, unit.Complemento, unit.Bairro, unit.Cidade, unit.Estado, IFNULL(p.CPF, pacrel.CPFParente) ResponsavelCPF, IFNULL(p.NomePaciente, pacrel.Nome) ResponsavelNome "&_
                                                "FROM agendamentos a "&_
                                                "LEFT JOIN pacientesrelativos pacrel ON pacrel.PacienteID=a.PacienteID AND pacrel.Dependente='S' "&_
                                                "LEFT JOIN pacientes p ON p.id=pacrel.NomeID "&_
                                                "LEFT JOIN locais l ON l.id=a.LocalID "&_
                                                "LEFT JOIN (SELECT 0 id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM empresa UNION ALL SELECT id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM sys_financialcompanyunits WHERE sysActive=1) unit ON unit.id=l.UnidadeID "&_
                                                "WHERE a.id="&AgendamentoID)
                if not dadosAgendamento.eof then
                    Contrato = replace(Contrato, "[Agendamento.Data]", dadosAgendamento("Data"))
                    Contrato = replace(Contrato, "[Agendamento.Hora]", formatdatetime(dadosAgendamento("Hora"),4))
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Nome]", dadosAgendamento("NomeFantasia")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Cep]", dadosAgendamento("Cep")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Endereco]", dadosAgendamento("Endereco")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Numero]", dadosAgendamento("Numero")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Complemento]", dadosAgendamento("Complemento")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Bairro]", dadosAgendamento("Bairro")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Cidade]", dadosAgendamento("Cidade")&"")
                    Contrato = replace(Contrato, "[AgendamentoUnidade.Estado]", dadosAgendamento("Estado")&"")
                    Contrato = replace(Contrato, "[Responsavel.Nome]", dadosAgendamento("ResponsavelNome")&"")
                    Contrato = replace(Contrato, "[Responsavel.CPF]", dadosAgendamento("ResponsavelCPF")&"")
                end if

            end if

            if formaPagto="" then
                FormaPagto = "Não pago"

                if req("Tipo")<>"SADT" then
                    FormaID=pinv("FormaID")
                    if not isnull(FormaID) then
                        if FormaID&"" <> "0" then
                            set MetodoPagamentoSQL = db.execute("SELECT pm.PaymentMethod FROM sys_formasrecto r INNER JOIN sys_financialpaymentmethod pm ON pm.id=r.MetodoID WHERE r.id="&FormaID)
                            if not MetodoPagamentoSQL.eof then
                                FormaPagto=MetodoPagamentoSQL("PaymentMethod")
                            end if
                        end if
                    end if
                end if

                UsuarioRecebimento=nameInTable(session("User"))
            end if


            Contrato = replace(Contrato, "[Contrato.DataPagamento]", DataPagamento)
            Contrato = replace(Contrato, "[-Usuario.Nome-]", UsuarioRecebimento)
            Contrato = replace(Contrato, "[Contrato.FormaPagamento]", FormaPagto)


            if instr(Contrato, "[Itens.Iniciar]")>0 and instr(Contrato, "[Itens.Finalizar]")>0 then
            'response.write("oi")
                splItens = split(Contrato, "[Itens.Iniciar]")
                splItens2 = split(splItens(1), "[Itens.Finalizar]")
                modeloItens = splItens2(0)
                set ii = db.execute("select ii.*, p.NomeProcedimento from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID where ii.InvoiceID="&InvoiceID)
                
                
                while not ii.eof
                    EsteItem = replace(modeloItens, "[Itens.Descricao]", ii("NomeProcedimento"))
                    EsteItem = replace(EsteItem, "[Itens.Quantidade]", ii("Quantidade"))
                    EsteItem = replace(EsteItem, "[Itens.Obs]", ii("Descricao")&"")
                    ContItens = ContItens & EsteItem
                ii.movenext
                wend
                ii.close
                set ii=nothing

                Contrato = splItens(0) & ContItens & splItens2(1)
            end if
                if req("Tipo")="SADT" then
                    Contrato = replace(Contrato, "[Receita.CodigoBarras]", "[CodigoBarras."&zeroEsq(req("InvoiceID"), 8)&"]")
                    Contrato = replace(Contrato, "[Receita.Numero]", zeroEsq(req("InvoiceID"), 8))
                else
                    set pinv = db.execute("select i.*, (select count(id) from sys_financialmovement where InvoiceID=i.id) NumeroParcelas from sys_financialinvoices i where i.id="&InvoiceID)
                    if not pinv.eof then
                        Contrato = replace(Contrato, "[Receita.Total]", "Total")
                        Contrato = replace(Contrato, "[Receita.NumeroParcelas]", pinv("NumeroParcelas"))
                        Contrato = replace(Contrato, "[Receita.TotalExtenso]", lcase(Extenso( pinv("Value"))) )
                        Contrato = replace(Contrato, "[Receita.CodigoBarras]", "[CodigoBarras."&zeroEsq(pinv("id"), 6)&"]")
                        Contrato = replace(Contrato, "[Receita.Numero]", zeroEsq(pinv("id"), 6))
                        PacienteContrato = pinv("AccountID")
                    end if
                end if

            'aqui onde o replace é dado deve trazer o id de quem terá o nome impresso
            Contrato = replacetags(Contrato, replace(ContaID, "3_", ""), session("User"), UnidadeInvoiceID)
            Contrato = replacePagto(Contrato, pinv("Value"))
            if instr(Contrato, "[ItensNaoExecutados.Inicio]")>0 and instr(Contrato, "[ItensNaoExecutados.Fim]")>0 then

                splModeloItensNE = split(Contrato, "[ItensNaoExecutados.Inicio]")
                spl2ModeloItensNE = split(splModeloItensNE(1), "[ItensNaoExecutados.Fim]")
                ModeloItensNE = spl2ModeloItensNE(0)
                strAntesRepeticaoNE = splModeloItensNE(0)
                strDepoisRepeticaoNE = spl2ModeloItensNE(1)

                set iiNE = db.execute("select ii.*, p.NomeProcedimento from itensinvoice ii LEFT JOIN procedimentos p on p.id=ii.ItemID where ii.Executado = '' and ii.InvoiceID="&InvoiceID )
                ageIN = "0"
                strItensNE = ""
                while not iiNE.eof
                    set ageFut = db.execute("select a.*, prof.NomeProfissional from agendamentos a LEFT JOIN profissionais prof on prof.id=a.ProfissionalID where a.PacienteID="&PacienteContrato&" and a.Data>=curdate() and a.StaID<>3 and a.TipoCompromissoID="&iiNE("ItemID")&" and a.id NOT IN ("& ageIN &")")
                    if not ageFut.EOF then
                        ItemNE = replace(ModeloItensNE, "[Item.Data]", ageFut("Data")&"")
                        ItemNE = replace(ItemNE, "[Item.Hora]", ft(ageFut("Hora")))
                        ItemNE = replace(ItemNE, "[Item.NomeProfissional]", ageFut("NomeProfissional")&"")
                        ItemNE = replace(ItemNE, "[Item.NomeProcedimento]", iiNE("NomeProcedimento"))
                        ageIN = ageIN & ", "& ageFut("id")
                        strItensNE = strItensNE & ItemNE
                    end if
                    
                iiNE.movenext
                wend
                iiNE.close
                set iiNE=nothing

                Contrato = strAntesRepeticaoNE & strItensNE & strDepoisRepeticaoNE
            end if
        end if
        exibeCont = 1
    else
        set pmod = db.execute("select * from contratosmodelos where id="&ModeloID)
        if not pmod.eof then
            ModeloContrato = pmod("Conteudo")
            AgruparExecutante = pmod("AgruparExecutante")
            AgruparParcela = pmod("AgruparParcela")
        end if
        
        'procedimentos
        Contrato = ModeloContrato
        Contrato=replace(Contrato,"AReceber","Receita")

         if instr(Contrato, "[Procedimentos.Iniciar]")>0 and instr(Contrato, "[Procedimentos.Finalizar]")>0 then
            'response.write("oi")
                splItens = split(Contrato, "[Procedimentos.Iniciar]")
                splItens2 = split(splItens(1), "[Procedimentos.Finalizar]")
                modeloItens = splItens2(0)
                set guiaprocedimentos = db.execute("select gp.*, p.NomeProcedimento from tissprocedimentossadt gp LEFT JOIN procedimentos p on p.id = gp.ProcedimentoID where gp.GuiaID="&InvoiceID)
                
                while not guiaprocedimentos.eof
                    EsteItem = replace(modeloItens, "[Procedimentos.Descricao]", guiaprocedimentos("NomeProcedimento"))
                    EsteItem = replace(EsteItem, "[Procedimentos.Codigo]", guiaprocedimentos("CodigoProcedimento"))
                    EsteItem = replace(EsteItem, "[Procedimentos.Quantidade]", guiaprocedimentos("Quantidade"))
                    EsteItem = replace(EsteItem, "[Procedimentos.Obs]", guiaprocedimentos("Descricao")&"")
                    EsteItem = replace(EsteItem, "[Procedimentos.ValorUN]", guiaprocedimentos("ValorUnitario")&"")
                    EsteItem = replace(EsteItem, "[Procedimentos.ValorTotal]", guiaprocedimentos("ValorTotal")&"")

                    if instr(EsteItem, "[Procedimentos.Executante]")>0 then

                        if guiaprocedimentos("Associacao")=8 then
                            profsql = "select * from profissionalexterno where id="&guiaprocedimentos("ProfissionalID")
                        else
                            profsql = "select * from profissionais where id="&guiaprocedimentos("ProfissionalID")
                        end if
                        set prof = db.execute(profsql)
                        if not prof.eof then
                            EsteItem = replace(EsteItem, "[Procedimentos.Executante]", prof("NomeProfissional")&"")
                        end if
                    end if
                    ContItens = ContItens & EsteItem
                guiaprocedimentos.movenext
                wend
                guiaprocedimentos.close
                set guiaprocedimentos=nothing

                Contrato = splItens(0) & ContItens & splItens2(1)
            end if
            guiasql = "select * from tissguiasadt where id="&InvoiceID
            set guia=db.execute(guiasql)
            
            Contrato = replateTagsPaciente(Contrato, guia("PacienteID"))
            Contrato = replacetags(Contrato, guia("PacienteID"),"" ,guia("UnidadeID") )

        
        exibeCont = 1

    end if
else
    set cont = db.execute("select * from contratos where id="&ContratoID)
    if not cont.eof then
        Contrato = cont("Contrato")
    end if
    exibeCont = 1
end if

if exibeCont=1 then
    response.write( quickfield("editor", "Contrato", "Contrato", 12, Contrato, "400", "", "") )
end if




%>

    </div>
</div>
<div class="modal-footer">
    <%if exibeCont=1 then %>
    <button class="btn btn-primary" onclick="saveContrato()"><i class="far fa-save"></i> Salvar e Imprimir</button>
    <%end if %>
</div>

<script type="text/javascript">
    function saveContrato() {
        $.post("saveContrato.asp?I=<%=req("I")%>&InvoiceID=<%=InvoiceID%>&ModeloID=<%=req("ModeloID")%>&ContaID=<%=req("ContaID")%>", {Contrato: $("#Contrato").val()}, function(data){
            eval(data);
        });
    }
    function openContrato(I){
        $.post("addContrato.asp?I="+I, {}, function(data){
            $("#modal").html(data);
        });
    }
</script>