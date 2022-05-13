<!--#include file="connect.asp"-->
<!--#include file="extenso.asp"-->
<!--#include file="Classes/TagsConverte.asp"-->
<% if session("Banco")="clinic5760" then %>
<style type="text/css">
    body {
        font-size:11px;
    }
</style>
<% end if %>
<style type="text/css">
    @media print {
        .pagebreak { display: block; page-break-after: always; }
    }
</style>
<%

function ConstroiConteudoTabela(usuario, tipoderecibo,quantidade,senha,subtotal,acrescimo,desconto,unitario,valorpago,valorpendente,descricao,valorunitario)
    ConstroiConteudoTabela =""
    sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='"&tipoderecibo&"' order by rc.ordem"
    set exec = db.execute(sqlvar)
    if not exec.eof then
        teste = "<tr> "
        while not exec.eof
            if exec("exibir") = "S" then
                Select Case exec("campoId")
                    Case 1
                        teste = teste &"<td class='text-right'> "&quantidade&"</td>"
                    Case 2
                        teste = teste &"<td> "&senha&"</td>"
                    Case 3
                        teste = teste &"<td class='text-right'> "&fn( subtotal) &"</td>"
                    Case 4
                        teste = teste &"<td class='text-right'> "&fn(acrescimo)&"</td>"
                    Case 5
                        teste = teste &"<td class='text-right'> "&fn(desconto)&"</td>"
                    Case 6
                        teste = teste &"<td class='text-right'> "&fn( unitario) &"</td>"
                    Case 7
                        teste = teste &"<td class='text-right'> "&fn( valorpago) &"</td>"
                    Case 8
                        teste = teste &"<td class='text-right'> "&fn( valorpendente) &"</td>"
                    Case 9
                        teste = teste &"<td> "&descricao&"</td>"
                    Case 10
                        teste = teste &"<td class='text-right'> "&fn( valorunitario)&"</td>"
                    Case else
                        teste = teste &""
                End Select
            end if
        exec.movenext
        wend
        exec.close
    ConstroiConteudoTabela = teste&"</tr>"
    end if
end function

function ConstroiCabecalhoTabela(usuario, tipoderecibo)
    ConstroiCabecalhoTabela = ""
    sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='"&tipoderecibo&"' order by rc.ordem"
    set exec = db.execute(sqlvar)
    if not exec.eof then
        teste = "<table class='table table-striped table-condensed table-bordered table-hover'>"&_
                        "<thead><tr>"
        while not exec.eof
            if exec("exibir") = "S" then
                Select Case exec("campoId")
                    Case 1
                        teste = teste &"<th width='1%'>Quantidade</th>"
                    Case 2
                        teste = teste &"<th>Senha</th>"
                    Case 3
                        teste = teste &"<th class='text-right'>Subtotal</th>"
                    Case 4
                        teste = teste &"<th  class='text-right'>Acréscimo</th>"
                    Case 5
                        teste = teste &"<th  class='text-right'>Desconto</th>"
                    Case 6
                        teste = teste &"<th class='text-right'>Valor</th>"
                    Case 7
                        teste = teste &"<th class='text-right'>Valor Pago</th>"
                    Case 8
                        teste = teste &"<th  class='text-right'>Valor Pendente</th>"
                    Case 9
                        teste = teste &"<th>Item</th>"
                    Case 10
                        teste = teste &"<th  class='text-right'>Valor Unitário</th>"
                    Case else
                        teste = teste &""
                End Select
            end if
        exec.movenext
        wend
        exec.close
    ConstroiCabecalhoTabela = teste&"</tr></thead><tbody>"
    end if
end function

function ConstroiRodapeTabela(usuario, tipoderecibo)
    ConstroiRodapeTabela=""
    if tipoderecibo="RPSModelo" then
        tipoderecibo="RecibosIntegrados"
    end if

    sqlvar = "select rcm.Nome, rc.* from recibo_campos rc join cliniccentral.recibo_campos_modelo rcm on rc.campoId = rcm.id where rc.tipo='"&tipoderecibo&"' order by rc.ordem"
    set exec = db.execute(sqlvar)
    if not exec.eof then
        teste = "</tbody><tfoot><tr>"
			    tabelinha = tabelinha &""

        while not exec.eof
            if exec("exibir") = "S" then
                Select Case exec("campoId")
                    Case 1
                        teste = teste &"<th class='text-right'>"&TotalQuantidade&"</th>"
                    Case 2
                        teste = teste &"<th></th>"
                    Case 3
                        teste = teste &"<th class='text-right'>"&fn(TotalTotal)&"</th>"
                    Case 4
                        teste = teste &"<th class='text-right'>"&fn(TotalAcrescimo)&"</th>"
                    Case 5
                        teste = teste &"<th class='text-right'>"&fn(TotalDesconto)&"</th>"
                    Case 6
                        teste = teste &"<th class='text-right'></th>"
                    Case 7
                        teste = teste &"<th class='text-right'>"&fn(TotalPago)&"</th>"
                    Case 8
                        teste = teste &"<th></th>"
                    Case 9
                        teste = teste &"<th></th>"
                    Case 10
                        teste = teste &"<th></th>"
                    Case else
                        teste = teste &""
                End Select
            end if
        exec.movenext
        wend
        exec.close
    ConstroiRodapeTabela = teste&"</tr></tfoot></table>"
    end if
end function

Imprimiu=req("Imprimiu")
InvoiceID=req("I")
GravaRecibo=req("GravaRecibo")
ReciboModelo=req("ModeloColuna")
ProfissionalExecutanteID=req("ProfissionalID")
tipoProfissionalSelecionado=req("tipoProfissionalSelecionado")
AssociacaoID=req("AssociacaoID")
NomeRecibo=req("NomeRecibo")
RPS=req("RPS")
NumeroRPS=req("NumeroRps")
Cnpj=req("Cnpj")
RepasseIds=req("RepasseIds")
profissionalSelecionado=req("profissionalSelecionado")
executouProcedimento=req("executouProcedimento")
procedimentos=req("procedimentos")
profissionalParaNaoProcessado=req("profissionalParaNaoProcessado")
reciboID = req("ReciboID")
ValorRecibo = req("ValorRecibo")
PacienteID = req("PacienteID")

if NomeRecibo="" then
    NomeRecibo="Recibo Padrão"
end if

if RPS="" then
    RPS="N"
end if

set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
if not ConfigSQL.eof then
    SplitNF = ConfigSQL("SplitNF")

    if SplitNF&""<>"1" then
        RPS="N"
    end if
end if

NomeItens = ""
splitInvoiceID = split(InvoiceID, ",")
ValorTotalReciboRepasse = getConfig("ValorTotalReciboRepasse")

for keySplit=0 to ubound(splitInvoiceID)
    InvoiceID = splitInvoiceID(keySplit)
    TabelaRepasses = ""


set inv = db.execute("select * from sys_financialinvoices where id in("&InvoiceID&")")

if not inv.eof then

    if ReciboModelo="" then
        if inv("CD")="D" then
            ReciboModelo = "RecibosIntegradosAPagar"
        else
            ReciboModelo="RecibosIntegrados"
        end if
    end if

    DataHora = inv("DataHora")

    TipoReciboModelo = ReciboModelo

    if TipoReciboModelo="RPSModelo" then
        TipoReciboModelo="RecibosIntegrados"
    end if

	%>
	<div class="pagebreak">
	<div class="modal-body">
		<%
		ContaID = inv("AssociationAccountID")&"_"&inv("AccountID")
        Solicitante = inv("ProfissionalSolicitante")


		if inv("AssociationAccountID")=3 then
		    PacienteID=inv("AccountID")
		end if
        recSQL = "select "&ReciboModelo&" from impressos WHERE Executante IS NULL or Executante LIKE '%|"&AssociacaoID&"_"&ProfissionalExecutanteID&"|%' ORDER BY Executante DESC"
        'response.write(recSQL)
		set rec = db.execute(recSQL)
		if not rec.eof then
		    User = session("User")

            if inv("AssociationAccountID")="5" then
                vUserSQL = "SELECT su.id FROM sys_users su WHERE su.idInTable="&inv("AccountID")&" AND su.NameColumn = 'NomeProfissional'"
                'response.write(vUserSQL)
                set UserSQL = db.execute(vUserSQL)
                if not UserSQL.eof then
                    User=UserSQL("id")
                end if
            end if

            Recibo = rec(ReciboModelo)&""
            'NOVO CONVERSOR DE TAGS 28/07/2020 || RAFAEL MAIA
            if inv("ProfissionalSolicitante")&"" <>"" then
                ProfissionalSolicitanteArray = Split(inv("ProfissionalSolicitante"),"_")
                if ubound(ProfissionalSolicitanteArray)=1 then
                    ProfissionalSolicitanteID = ProfissionalSolicitanteArray(1)
                else
                    ProfissionalSolicitanteID = 0
                end if
            else
                ProfissionalSolicitanteID=0
            end if
            'response.write("<script>console.log('Valor: '"&ProfissionalSolicitanteID&")</script>")

            if ProfissionalExecutanteID&""="" then
                set ExecutanteSQL = db.execute("SELECT ProfissionalID,Associacao FROM itensinvoice WHERE InvoiceID="&InvoiceID&" LIMIT 1")
                if not ExecutanteSQL.eof then
                    if ExecutanteSQL("Associacao")=8 then
                        Converte_ProfissionalExecutanteExterno = "ProfissionalExecutanteExternoID_"&ExecutanteSQL("ProfissionalID")&"|"
                    else
                        ProfissionalExecutanteID=ExecutanteSQL("ProfissionalID")&""
                    end if
                    
                    if ProfissionalExecutanteID="0" then
                        ProfissionalExecutanteID=""
                    end if
                end if
            end if
            
            if profissionalSelecionado&""<>"" then
                if tipoProfissionalSelecionado&""=8 then
                    Converte_ProfissionalExecutanteExterno = "ProfissionalExecutanteExternoID_"&profissionalSelecionado&"|"
                end if
                if tipoProfissionalSelecionado&""=5 then
                    ProfissionalExecutanteID = profissionalSelecionado
                end if
            end if

		end if

		'Tags do agendamento
        set itensConta= db.execute("SELECT * FROM itensinvoice WHERE (AgendamentoID<>0 OR AgendamentoID IS NOT NULL) AND InvoiceID="&InvoiceID&" LIMIT 1")
        if not itensConta.eof then
            AgendamentoID = itensConta("AgendamentoID")
            sqlAgendamento = "SELECT a.Data, a.Hora, unit.NomeFantasia, unit.Cep, unit.Endereco, unit.Numero, unit.Complemento, unit.Bairro, unit.Cidade, unit.Estado, IFNULL(pacrel.CPFParente, p.CPF) ResponsavelCPF, IFNULL(pacrel.Nome, p.NomePaciente) ResponsavelNome "&_
                                              "FROM agendamentos a "&_
                                              "LEFT JOIN pacientesrelativos pacrel ON pacrel.PacienteID=a.PacienteID AND pacrel.Dependente='S' "&_
                                              "LEFT JOIN pacientes p ON p.id=pacrel.NomeID "&_
                                              "LEFT JOIN locais l ON l.id=a.LocalID "&_
                                              "LEFT JOIN (SELECT 0 id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM empresa UNION ALL SELECT id, NomeFantasia, Cep, Endereco, Numero, Complemento, Bairro, Cidade, Estado FROM sys_financialcompanyunits WHERE sysActive=1) unit ON unit.id=l.UnidadeID "&_
                                              "WHERE a.id="&AgendamentoID

            set dadosAgendamento = db.execute(sqlAgendamento)
            if not dadosAgendamento.eof then
                HoraAgendamento =""
                if dadosAgendamento("Hora")&""<>"" then
                    HoraAgendamento = formatdatetime(dadosAgendamento("Hora"),4)
                end if
                Recibo = replace(Recibo, "[Agendamento.Data]", dadosAgendamento("Data"))
                Recibo = replace(Recibo, "[Agendamento.Hora]", HoraAgendamento)
                Recibo = replace(Recibo, "[AgendamentoUnidade.Nome]", dadosAgendamento("NomeFantasia")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Cep]", dadosAgendamento("Cep")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Endereco]", dadosAgendamento("Endereco")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Numero]", dadosAgendamento("Numero")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Complemento]", dadosAgendamento("Complemento")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Bairro]", dadosAgendamento("Bairro")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Cidade]", dadosAgendamento("Cidade")&"")
                Recibo = replace(Recibo, "[AgendamentoUnidade.Estado]", dadosAgendamento("Estado")&"")
                'Recibo = replace(Recibo, "[Responsavel.Nome]", dadosAgendamento("ResponsavelNome")&"")
                'Recibo = replace(Recibo, "[Responsavel.CPF]", dadosAgendamento("ResponsavelCPF")&"")
            end if

        end if

		if instr(Recibo, "[Receita.")>0 or true then

			'if session("Banco")="clinic105" or session("Banco")="clinic1752" then
				'tabelinha = "<table class='table table-striped table-condensed table-bordered table-hover'>"&_
					'"<thead><tr><th width='1%'>Quantidade</th><th>Senha</th><th>Item</th><th class='text-right'>Valor</th><th class='text-right'>Subtotal</th><th class='text-right'>Valor Pago</th></tr></thead><tbody>"
			'else
			    'if ProfissionalExecutanteID<>"" or RPS="S" then
			        'aqui eh o recibo de honorario de repasse

                    'if RPS="N" then
			        '    tabelinha = "<table class='table table-striped table-condensed table-bordered table-hover'>"&_
                                        '    "<thead><tr><th>Item</th><th class='text-right'>Valor</th></tr></thead><tbody>"
                   ' end if

			    'else
                    'tabelinha = ConstroiCabecalhoTabela(session("User"),TipoReciboModelo)
                    'tabelinha = "<table class='table table-striped table-condensed table-bordered table-hover'>"&_
                     '   "<thead><tr><th width='1%'>Quantidade</th><th>Item</th><th class='text-right'>Valor</th><th class='text-right'>Subtotal</th><th class='text-right'>Valor Pago</th></tr></thead><tbody>"

			    'end if
			'end if

                if RPS<>"S" then
                    tabelinha = ConstroiCabecalhoTabela(session("User"),TipoReciboModelo)
                end if

                AgruparPacote = false
                AgruparItem = false

                SqlAgruparPacote = 0
                SqlAgruparItem = 0

                sqlConfig = "select co.Coluna, cg.valor from cliniccentral.config_opcoes co join config_gerais cg on cg.ConfigID = co.id where co.sysActive = 1 and co.Coluna ='AgruparItem' or co.Coluna ='AgruparPacote'"
                set checkConfig = db.execute(sqlConfig)
                if not checkConfig.eof then
                    while not checkConfig.eof 
                        if (checkConfig("Coluna") = "AgruparPacote") and (checkConfig("valor") = "1") then
                            AgruparPacote = true
                            SqlAgruparPacote = 1
                        end if 

                        if (checkConfig("Coluna") = "AgruparItem") and (checkConfig("valor") = "1") then
                            AgruparItem = true
                            SqlAgruparItem = 1
                        end if
                    checkConfig.movenext
                    wend
                    checkConfig.close
                end if

                'sqlItens = "select ii.*, upper(left(md5(ii.id), 7)) Senha, p.NomeProcedimento, p.TipoProcedimentoID, p.DiasRetorno, (select sum(Valor) from itensdescontados where ItemID=ii.id) ValorPago from itensinvoice ii left join procedimentos p on p.id=ii.ItemID where InvoiceID="&InvoiceID&sqlProfissional          
                
                profissionalSelecionadoQuery = ""
                if profissionalSelecionado <> "" then
                    profissionalSelecionadoQuery = " and ii.ProfissionalID = "&profissionalSelecionado
                end if

                IF profissionalSelecionado = "" and profissionalParaNaoProcessado <> "" THEN
                    profissionalSelecionado = profissionalParaNaoProcessado
                END IF

                sqlwhereprof = sqlItens&profissionalSelecionadoQuery

                profissionalExecutouProcedimentoQuery = ""

                if executouProcedimento = "N" or executouProcedimento = "X" then
                    profissionalExecutouProcedimentoQuery = " AND COALESCE(EXECUTADO <> 'S',TRUE) "
                end if

                sqlwhereprof = sqlwhereprof&profissionalExecutouProcedimentoQuery

                if procedimentos <> "" then
                    sqlwhereprof = sqlwhereprof&" AND ii.id in("&procedimentos&")"
                end if
                
                sqlItens = "select  "&_
                            " SUM(ifnull(t.Quantidade,0)) ItensQuantidade, "&_
                            " SUM(ifnull(t.ValorUnitario,0)) ItensValorUnitario,"&_
                            " SUM(ifnull(t.Desconto,0)) ItensDesconto,"&_
                            " SUM(ifnull(t.acrescimo,0)) ItensAcrescimo,"&_
                            " SUM((ifnull(t.valorunitario,0)-ifnull(t.desconto,0)+ifnull(t.acrescimo,0))) ItensValor, "&_
                            " SUM((select sum(Valor) from itensdescontados where ItemID=t.id) ) ItensValorPago,"&_
                            " count(itemid) itens, "&_
                            " t.* "&_
                            " from(select "&_
                            " SUM(ifnull(ii.Quantidade,0)) PacoteQuantidade, "&_
                            " SUM(ifnull(ii.ValorUnitario,0)) PacoteValorUnitario,"&_
                            " SUM(ifnull(ii.Desconto,0)) PacoteDesconto,"&_
                            " SUM(ifnull(ii.acrescimo,0)) PacoteAcrescimo,"&_
                            " SUM((ifnull(ii.valorunitario,0)-ifnull(ii.desconto,0)+ifnull(ii.acrescimo,0))) PacoteValor, "&_
                            " SUM((select sum(Valor) from itensdescontados where ItemID=ii.id) ) PacoteValorPago,"&_
                            " pac.NomePacote,"&_
                            " pro.NomeProduto,"&_
                            " count(ii.itemid) grupo, "&_
                            " ii.*, "&_
                            " upper(left(md5(ii.id), 7)) Senha, "&_
                            " p.NomeProcedimento, "&_
                            " p.TipoProcedimentoID, "&_
                            " p.DiasRetorno, "&_
                            " (select sum(Valor) from itensdescontados where ItemID=ii.id) ValorPago,"&_
                            " (if(ii.PacoteID is null,CONCAT(ii.ValorUnitario, ii.ItemID, ii.id),ii.PacoteID)) PACUNICO,"&_
                            " (if(ii.PacoteID is not null,CONCAT(ii.ItemID, ii.id),CONCAT(ii.ValorUnitario, IFNULL(ii.acrescimo,0), IFNULL(ii.Desconto,0),ii.ItemID,IFNULL(ii.Descricao,0)))) ITEMUNICO"&_
                            " "&_
                            " from itensinvoice ii "&_
                            " left join procedimentos p on p.id=ii.ItemID "&_
                            " left join pacotes pac on pac.ID = ii.PacoteID "&_
                            " left join produtos pro on pro.id = ii.ItemID "&_
                            " where ii.InvoiceID="&InvoiceID&sqlProfissional&sqlwhereprof&" "&_
                            " group by "&_
                            " 	if("&SqlAgruparPacote&", PACUNICO,ii.id)"&_
                            " ) as t"&_
                            " group by "&_
                            " 	if("&SqlAgruparItem&",ITEMUNICO,id)"

				set itens = db.execute(sqlItens)

				TotalTotal = 0
                TotalPago = 0
                TotalQuantidade = 0
                TotalDesconto = 0
                TotalAcrescimo = 0
                ProfissionalExecutante = ""

				while not itens.eof

                    UnitarioSimples = itens("ValorUnitario")
                    ValorDesconto = itens("Desconto")
                    ValorAcrescimo = itens("Acrescimo")
                    ValorPago = itens("ValorPago")
                    Quantidade = itens("Quantidade")

                    if AgruparPacote and itens("grupo") <> "1" then
                        UnitarioSimples = itens("PacoteValorUnitario")
                        ValorDesconto = itens("PacoteDesconto")
                        ValorAcrescimo = itens("PacoteAcrescimo")
                        ValorPago = itens("PacoteValorPago")
                       ' Quantidade = itens("PacoteQuantidade")
                    end if

                    if AgruparItem and itens("itens") <> "1" then
                        'UnitarioSimples = itens("ItensValorUnitario")
                        'ValorDesconto = itens("ItensDesconto")
                        'ValorAcrescimo = itens("ItensAcrescimo")
                        ValorPago = itens("ItensValorPago")
                        Quantidade = itens("ItensQuantidade")
                    end if

					Unitario = UnitarioSimples-ValorDesconto+ValorAcrescimo
					Subtotal = Unitario*Quantidade
                    ValorPendente = Subtotal - ValorPago

					TotalTotal = TotalTotal + Subtotal
                    TotalQuantidade = TotalQuantidade + Quantidade
                    TotalDesconto = TotalDesconto + ValorDesconto
                    TotalAcrescimo = TotalAcrescimo + ValorAcrescimo

                    if inv("CD")="D" then
                        set vcaRep = db.execute("select rr.* from rateiorateios rr WHERE rr.ItemContaAPagar="&itens("id"))

                        while not vcaRep.eof
                            if not isnull(vcaRep("ItemGuiaID")) then
                                TipoRegra = "Guia SP/SADT"

                                qDadosRepasseSQL =  " SELECT p.NomePaciente,p.CPF,proc.NomeProcedimento, tgc.Data, rr.Valor AS ValorTotal   "&chr(13)&_
                                                    " FROM tissprocedimentossadt tgc                                                        "&chr(13)&_
                                                    " LEFT JOIN tissguiasadt tg ON tg.id = tgc.GuiaID                                       "&chr(13)&_
                                                    " LEFT JOIN pacientes p ON p.id = tg.PacienteID                                         "&chr(13)&_
                                                    " LEFT JOIN procedimentos proc ON proc.id = tgc.ProcedimentoID                          "&chr(13)&_
                                                    " LEFT JOIN rateiorateios rr ON rr.ItemGuiaID = tgc.id                                  "&chr(13)&_
                                                    " WHERE tgc.id="&vcaRep("ItemGuiaID")
                                'response.write("<pre>"&qDadosRepasseSQL&"</pre>")
                                set DadosRepasseSQL = db.execute(qDadosRepasseSQL)

                                if not DadosRepasseSQL.eof then
                                    NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
                                    NomePaciente =DadosRepasseSQL("NomePaciente")
                                    CPF =DadosRepasseSQL("CPF")
                                    DataAtendimento = DadosRepasseSQL("Data")
                                    ValorTotal =DadosRepasseSQL("ValorTotal")
                                end if
                            end if
                            if not isnull(vcaRep("GuiaConsultaID")) then
                                TipoRegra = "Guia de Consulta"
                                set DadosRepasseSQL = db.execute("SELECT p.NomePaciente,p.CPF,proc.NomeProcedimento,tgc.ValorProcedimento, tgc.DataAtendimento FROM tissguiaconsulta tgc LEFT JOIN pacientes p ON p.id = tgc.PacienteID LEFT JOIN procedimentos proc ON proc.id = tgc.ProcedimentoID WHERE tgc.id="&vcaRep("GuiaConsultaID"))

                                if not DadosRepasseSQL.eof then
                                    NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
                                    NomePaciente =DadosRepasseSQL("NomePaciente")
                                    CPF =DadosRepasseSQL("CPF")
                                    ValorTotal =DadosRepasseSQL("ValorProcedimento")
                                    DataAtendimento = DadosRepasseSQL("DataAtendimento")
                                end if
                            end if
                            if not isnull(vcaRep("ItemHonorarioID")) then

                                TipoRegra = "Guia de Honorário"
                                set DadosHonorarioSQL = db.execute("SELECT proc.NomeProcedimento, p.NomePaciente, p.CPF, tph.ValorTotal, tph.Data as DataHonorario FROM tissguiahonorarios tgh INNER JOIN tissprocedimentoshonorarios tph ON tph.Guiaid = tgh.id LEFT JOIN procedimentos proc ON proc.id = tph.ProcedimentoID LEFT JOIN  pacientes p ON p.id=tgh.PacienteID WHERE tph.id=" & vcaRep("ItemHonorarioID"))
                                if not DadosHonorarioSQL.eof then
                                    NomeProcedimento = DadosHonorarioSQL("NomeProcedimento")
                                    NomePaciente =DadosHonorarioSQL("NomePaciente")
                                    CPF =DadosHonorarioSQL("CPF")
                                    ValorTotal =DadosHonorarioSQL("ValorTotal")
                                    DataAtendimento = DadosHonorarioSQL("DataHonorario")
                                end if
                                
                            end if
                            if not isnull(vcaRep("ItemInvoiceID")) then
                                TipoRegra = "Particular"
                                qDadosRepasseSQL =  " SELECT proc.NomeProcedimento,p.NomePaciente,p.CPF,(ii.Quantidade * (ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal,ii.ValorUnitario, ii.DataExecucao"&chr(13)&_
                                                    " FROM itensinvoice ii                                                                                                                                        "&chr(13)&_
                                                    " LEFT JOIN sys_financialinvoices i ON i.id = ii.InvoiceID                                                                                                    "&chr(13)&_
                                                    " LEFT JOIN pacientes p ON p.id=i.AccountID                                                                                                                   "&chr(13)&_
                                                    " LEFT JOIN procedimentos proc ON proc.id = ii.ItemID                                                                                                         "&chr(13)&_
                                                    " WHERE ii.id="&vcaRep("ItemInvoiceID")
                                'response.write("<pre>"&qDadosRepasseSQL&"</pre>")

                                set DadosRepasseSQL = db.execute(qDadosRepasseSQL)
                                if not DadosRepasseSQL.eof then
                                    NomeProcedimento = DadosRepasseSQL("NomeProcedimento")
                                    NomePaciente =DadosRepasseSQL("NomePaciente")
                                    ValorTotal =DadosRepasseSQL("ValorTotal")
                                    CPF =DadosRepasseSQL("CPF")
                                    DataAtendimento = DadosRepasseSQL("DataExecucao")
                                end if
                            end if
                            ValorFinal = calculaRepasse(vcaRep("id"), vcaRep("Sobre"), ValorTotal, vcaRep("Valor"), vcaRep("TipoValor"))
                            tipoValor = vcaRep("TipoValor")
                            if tipoValor="V" then
                                pre = "R$ "
                                suf = ""
                            else
                                pre = ""
                                suf = "%"
                            end if

                            ColunaValorTotal = ""

                            if ValorTotalReciboRepasse then
                                ColunaValorTotal = "<td>"&pre & fn(ValorTotal) & suf&"</td>"
                            end if
                            
                            TabelaRepasses = TabelaRepasses&"<tr><td>"&DataAtendimento&"</td><td>"&NomeProcedimento&"</td><td>"&NomePaciente&"</td><td>"&CPF&"</td>"&ColunaValorTotal&"<td>"&fn(ValorFinal)&"</td></tr>"
                        vcaRep.movenext
                        wend
                        vcaRep.close
                        set vcaRep=nothing
                    end if

                    NomeItem=itens("NomeProcedimento")

                    if isnull(NomeItem) then
                        NomeItem = itens("Descricao")
                    end if
                    if instr("MK", itens("Tipo")) then
                        NomeItem = itens("NomeProduto")
                    end if

                    if AgruparPacote and itens("grupo") <> "1" then
                        NomeItem = itens("NomePacote")
                    end if
                    

                    if session("Banco")="clinic5445" or session("Banco")="clinic100000" then
                        if itens("TipoProcedimentoID")=2 then
                            if itens("DiasRetorno")&"" <>"" then
                                InformacoesAdicionaisProcedimento=" (* O Paciente tem "&itens("DiasRetorno")&" dias para retorno)"
                            end if
                        end if
                    end if

                    if instr(Recibo, "[ProfissionalExecutante.Nome]")>0 then
                        if ProfissionalExecutanteID="" then
                            ProfissionalID=itens("ProfissionalID")
                        else
                            ProfissionalID=ProfissionalExecutanteID
                        end if

                        IF profissionalParaNaoProcessado <> "" THEN
                            ProfissionalID = profissionalParaNaoProcessado
                        END IF

                        if (executouProcedimento = "N" OR executouProcedimento = "X") AND profissionalParaNaoProcessado = "" then
                            Recibo = replace(Recibo, "[ProfissionalExecutante.Conselho]", "" )
                            Recibo = replace(Recibo, "[ProfissionalExecutante.Nome]", "" )
                            Recibo = replace(Recibo, "[ProfissionalExecutante.CPF]", "" )
                        end if

                        if ProfissionalID&"" <> "" then

                            IF NOT IsNumeric(tipoProfissionalSelecionado) THEN
                                set ProfissionalExecutanteSQL = db.execute("SELECT prof.FornecedorID, prof.NomeProfissional, prof.DocumentoConselho, prof.UFConselho ,cons.codigo, prof.CPF  FROM profissionais prof LEFT JOIN conselhosprofissionais cons ON cons.id = prof.Conselho WHERE prof.id="&ProfissionalID)
                            ELSEIF tipoProfissionalSelecionado = 2 THEN
                                set ProfissionalExecutanteSQL = db.execute("SELECT id as FornecedorID, NomeFornecedor as NomeProfissional, ''  DocumentoConselho, Estado as UFConselho, Estado as codigo, CPF FROM fornecedores WHERE id="&ProfissionalID)
                            ELSEIF tipoProfissionalSelecionado = 8  THEN
                                set ProfissionalExecutanteSQL = db.execute("SELECT id as FornecedorID, NomeProfissional as NomeProfissional, CPF DocumentoConselho, estados.sigla as UFConselho, Estado as codigo, CPF FROM profissionalexterno LEFT JOIN estados ON estados.codigo = profissionalexterno.Estado WHERE id="&ProfissionalID)
                            ELSE
                                set ProfissionalExecutanteSQL = db.execute("SELECT prof.FornecedorID, prof.NomeProfissional, prof.DocumentoConselho, prof.UFConselho ,cons.codigo, prof.CPF  FROM profissionais prof LEFT JOIN conselhosprofissionais cons ON cons.id = prof.Conselho WHERE prof.id="&ProfissionalID)
                            END IF

                            if not ProfissionalExecutanteSQL.eof then
                                ProfissionalExecutanteConselho= ProfissionalExecutanteSQL("codigo")& " " & ProfissionalExecutanteSQL("DocumentoConselho")& " - "& ProfissionalExecutanteSQL("UFConselho")
                                NomeProfissional= ProfissionalExecutanteSQL("NomeProfissional")
                                CPFProfissional= ProfissionalExecutanteSQL("CPF")&""

                                MedicoPJ = ProfissionalExecutanteSQL("FornecedorID")
                                if not isnull(MedicoPJ) then
                                    if MedicoPJ>0 then
                                        set MedicoFornecedorSQL = db.execute("SELECT NomeFornecedor, CPF FROM fornecedores WHERE Ativo='on' AND sysActive=1 AND id="&treatvalzero(MedicoPJ))
                                        if not MedicoFornecedorSQL.eof then
                                            NomeProfissional=MedicoFornecedorSQL("NomeFornecedor")
                                            CPFProfissional=MedicoFornecedorSQL("CPF")
                                        end if
                                    end if
                                end if

                                ProfissionalExecutante=NomeProfissional&""
                                ProfissionalExecutanteCPF=CPFProfissional&""

                                Recibo = replace(Recibo, "[ProfissionalExecutante.Conselho]", ProfissionalExecutanteConselho )
                                Recibo = replace(Recibo, "[ProfissionalExecutante.Nome]", ProfissionalExecutante )
                                Recibo = replace(Recibo, "[ProfissionalExecutante.CPF]", ProfissionalExecutanteCPF )
                                
                                'CONVERSOR DE TAG APLICADO EM 22/07/2020
                                'Recibo = tagsConverte(Recibo,"ProfissionalID_"&ProfissionalID,"")

                            end if
                        end if
                        'caso o profissional executante não for encontrado utilizar profissional solicitante 
                        if instr(Recibo, "[ProfissionalExecutante.Nome]")>0 then

                            if Solicitante&"" <> "" and Solicitante&""<>"0" then
                                Recibo = replace(Recibo, "[ProfissionalExecutante.Nome]", Accountname("",Solicitante))
                            end if
                        end if 
                    end if

					'if session("Banco")="clinic105" or session("Banco")="clinic1752" then
						'tabelinha = tabelinha &"<tr> <td class='text-right'>"&itens("Quantidade")&"</td><td>"&itens("Senha")&"</td><td>"&NomeItem&"</td><td class='text-right'>"&fn( Unitario) &"</td><td class='text-right'>"&fn( Subtotal) &"</td> </tr>"
					'else

					    if ProfissionalExecutanteID<>"" or RPS="S" then
					        'pega o valor do repasse
                            AdicionaItem=True
                            ValorRepasse = 0
                            sqlContaCredito = AssociacaoID&"_"&ProfissionalExecutanteID

                            if RPS="S" then
                                sqlContaCredito="0"
                            end if

                            if ProfissionalExecutanteID<>"" AND ProfissionalExecutanteID<>"0" AND AssociacaoID="5" then
                                sqlProfissional = " AND ii.ProfissionalID="&ProfissionalExecutanteID&" AND ii.Associacao="&AssociacaoID
                            end if

                            sqlRateio = "select valor from (SELECT SUM(ifnull(Valor,0)) Valor FROM rateiorateios WHERE ItemInvoiceID="&itens("id")&" AND ContaCredito='"&sqlContaCredito&"')t where valor is not null"

                            set ValorRepasseSQL = db.execute(sqlRateio)

                            if not ValorRepasseSQL.eof then
                                ValorPago = ValorRepasseSQL("Valor")
                            elseif ProfissionalExecutanteID="0" then
                                sqlRepassesProfissionais = "SELECT SUM(Valor)ValorTotalRepassado FROM rateiorateios WHERE ItemInvoiceID="&itens("id")&" AND ContaCredito!='0'"
                                set ValorRepasseEmpresaSQL= db.execute(sqlRepassesProfissionais)
                                if not ValorRepasseEmpresaSQL.eof then
                                    ValorPago = ValorPago - ValorRepasseEmpresaSQL("ValorTotalRepassado")
                                end if
                            else
                                AdicionaItem=False
                            end if

                            if AdicionaItem then
                                if RPS="S" then
                                    tabelinha = tabelinha &"<br>"&NomeItem&" : &nbsp;&nbsp;&nbsp;&nbsp; R$ "&fn( ValorPago) &""
                                else
                                    tabelinha = tabelinha &"<br>"&NomeItem&":  R$ "&fn( ValorPago) &""
                                    if instr(tabelinha,"<table>")>0 then
                                        tabelinha = tabelinha &"<tr><td>"&NomeItem&" </td><td class='text-right'> "&fn( ValorPago) &"</td></tr>"
                                    end if

                                    if ValorPago>0 then
                                        if NomeItens<>"" then
                                            NomeItens = NomeItens & ", "&NomeItem
                                        else
                                            NomeItens = NomeItem
                                        end if
                                    end if

                                end if
                            end if
                        else
                            if ValorPago>0 then
                                if NomeItens<>"" then
                                    NomeItens = NomeItens & ", "&NomeItem
                                else
                                    NomeItens = NomeItem
                                end if
                            end if
                        end if
                        'else

                            'tabelinha = tabelinha &"<tr> <td class='text-right'>"&itens("Quantidade")&"</td><td>"&NomeItem&InformacoesAdicionaisProcedimento&"</td><td class='text-right'>"&fn( Unitario) &"</td><td class='text-right'>"&fn( Subtotal) &"</td> <td class='text-right'>"&fn( ValorPago) &"</td> </tr>"
                            if RPS<>"S" then
                                tabelinha = tabelinha &ConstroiConteudoTabela(session("User"),TipoReciboModelo,Quantidade,itens("Senha"),Subtotal,ValorAcrescimo,ValorDesconto,Unitario,ValorPago,ValorPendente,NomeItem,UnitarioSimples) &"</tr>"
                            end if
                        'end if

					'end if

                    if isnull(ValorPago) then
                        ValorPago=0
                    end if
					TotalPago = TotalPago + ValorPago
				itens.movenext
				wend
				itens.close
				set itens=nothing

            if ProfissionalExecutanteID<>"" or RPS="S" then
                'if RPS="N" then
                   ' tabelinha = tabelinha &"</tbody><tfoot><tr><th colspan='1'></th><th class='text-right'>"&fn(TotalPago)&"</th></tr></tfoot></table>"
                'else
                if NumeroRPS<>"N" and NumeroRPS<>""  then
                    set NFeSQL = db.execute("SELECT emit.*, o.cnpj, o.ServicoLCP116, o.InscricaoMunicipal FROM nfe_notasemitidas emit INNER JOIN nfe_origens o ON replace(replace(replace(o.cnpj,'.',''),'-',''),'/','')=emit.cnpj WHERE emit.cnpj='"&cnpj&"' AND emit.numero="&NumeroRPS)
                    if not NFeSQL.eof then
                        set UnidadeSQL = db.execute("SELECT RazaoSocial, Endereco,Bairro, Numero, Complemento, Estado, Tel1, Email1, Cep FROM (SELECT UnitName RazaoSocial,Endereco,Bairro, Numero, Complemento, Estado, Tel1, Email1, Cep FROM sys_financialcompanyunits WHERE cnpj='"&NFeSQL("cnpj")&"' "&_
                        "UNION ALL SELECT  NomeEmpresa RazaoSocial,Endereco,Bairro, Numero, Complemento, Estado, Tel1, Email1, Cep FROM empresa WHERE cnpj='"&NFeSQL("cnpj")&"')t")

                        Recibo = replace(Recibo, "[Empresa.Endereco]", UnidadeSQL("Endereco"))
                        Recibo = replace(Recibo, "[Empresa.Nome]", UnidadeSQL("RazaoSocial"))
                        Recibo = replace(Recibo, "[Empresa.Numero]", UnidadeSQL("Numero"))
                        Recibo = replace(Recibo, "[Empresa.Complemento]", UnidadeSQL("Complemento"))
                        Recibo = replace(Recibo, "[Empresa.Bairro]", UnidadeSQL("Bairro"))
                        Recibo = replace(Recibo, "[Empresa.Tel1]", UnidadeSQL("Tel1"))
                        Recibo = replace(Recibo, "[Empresa.Email1]", UnidadeSQL("Email1"))
                        Recibo = replace(Recibo, "[Empresa.Cep]", UnidadeSQL("Cep"))

                        Recibo = replace(Recibo, "[Empresa.Estado]", UnidadeSQL("Estado"))

                        Recibo = replace(Recibo, "[NFe.Serie]", NFeSQL("serie"))
                        Recibo = replace(Recibo, "[NFe.RPS]", NFeSQL("numero"))
                        Recibo = replace(Recibo, "[NFe.DataEmissao]", NFeSQL("datageracao"))
                        Recibo = replace(Recibo, "[NFe.InscricaoMunicipal]", NFeSQL("InscricaoMunicipal"))
                        Recibo = replace(Recibo, "[NFe.CodigoServico]", NFeSQL("ServicoLCP116"))
                        Recibo = replace(Recibo, "[NFe.CNPJ]", NFeSQL("cnpj"))
                    end if
                end if
            'else
                'tabelinha = tabelinha &ConstroiRodapeTabela(session("User"),TipoReciboModelo)
			    'tabelinha = tabelinha &"</tbody><tfoot><tr><th colspan='3'></th><th class='text-right'>"&fn(TotalTotal)&"</th><th class='text-right'>"&fn(TotalPago)&"</th></tr></tfoot></table>"
            end if

            if RPS<>"S" then
                tabelinha = tabelinha &ConstroiRodapeTabela(session("User"),TipoReciboModelo)
            end if

			Recibo = replace(Recibo, "[Receita.Itens]", tabelinha)
            Recibo = replace(Recibo&"", "[Receita.ItensExtenso]", NomeItens&"")

            sqlPagtos = "SELECT cartao_credito.Parcelas Parcelas, IF(credito.`Type` = 'Transfer','Crédito', forma_pagamento.PaymentMethod) PaymentMethod, "&_
                        "pagamento.MovementID, credito.`value` Value, credito.sysUser sysUser, debito.Date DataVencimento, credito.Date DataPagamento "&_
                        "FROM sys_financialmovement debito "&_
                        "LEFT JOIN sys_financialdiscountpayments pagamento ON pagamento.InstallmentID = debito.id  "&_
                        "LEFT JOIN sys_financialmovement credito ON credito.id=pagamento.MovementID "&_
                        "LEFT JOIN sys_financialpaymentmethod forma_pagamento ON forma_pagamento.id = credito.PaymentMethodID "&_
                        "LEFT JOIN sys_financialcreditcardtransaction cartao_credito ON cartao_credito.MovementID=credito.id "&_
                        "WHERE debito.InvoiceID="&inv("id") &" "&_
                        "UNION ALL "&_
                        "SELECT 1 Parcelas, 'Boleto' PaymentMethod, NULL, debito.Value VALUE, debito.sysUser  sysUser, debito.Date DataVencimento, null DataPagamento "&_
                        "FROM sys_financialmovement debito "&_
                        "INNER JOIN boletos_emitidos bm ON bm.MovementID=debito.id AND bm.StatusID NOT IN (2, 3, 4) "&_
                        "INNER JOIN cliniccentral.boletos_status bs ON bs.id=bm.StatusID "&_
                        "WHERE debito.InvoiceID="&inv("id")
            'response.write(sqlPagtos)
			set forma = db.execute(sqlPagtos)

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
                    MetodoRecebimento = PaymentMethod
                end if
                UsuarioRecebimento=nameInTable(forma("sysUser"))
            forma.movenext
            wend
            forma.close
            set forma=nothing


            ProfissionalTagID = ""

            if ProfissionalExecutanteID&""<>"" then
                ProfissionalTagID = AssociacaoID&"-"&ProfissionalExecutanteID    
            end if
            
            Recibo = TagsConverte(Recibo,Converte_ProfissionalExecutanteExterno&"ProfissionalSolicitanteID_"&ProfissionalSolicitanteID&"|ProfissionalID_"&ProfissionalTagID&"|UnidadeID_"&inv("CompanyUnitID")&"|FaturaID_"&req("I"),"")
            ' Recibo = TagsConverte(Recibo,"ProfissionalSessao_X","")

            'CONVERSOR ANTIGO DE TAGS DESATIVADO
            'Recibo = replace(Recibo, "[Usuario.Nome]","[-Usuario.Nome-]")
			Recibo = replaceTags(Recibo, ContaID, User, inv("CompanyUnitID"))


            if formaPagto="" then
                if TotalTotal=0 then
                    FormaPagto = "-"
                else
                    FormaPagto = "Não pago"
                end if
                UsuarioRecebimento=nameInTable(session("User"))
                Parcelas = ""
            end if


			'response.write("bb"&ValorPago)

			if TotalPago&"" = "" then
			    TotalPago=0
			end if

            ValorPagoExtenso = ValorRecibo

            if ValorRecibo="" then
                ValorRecibo=TotalPago
                ValorPagoExtenso = TotalPago
            end if
            
            Recibo = replace(Recibo, "[Recibo.Mes]", MonthName(month(date())))
            Recibo = replace(Recibo, "[Recibo.DataVencimento]", DataVencimento)
            Recibo = replace(Recibo, "[Recibo.DataPagamento]", DataPagamento)
            Recibo = replace(Recibo, "[Recibo.Dia]", day(date()))
            Recibo = replace(Recibo, "[Recibo.Ano]", year(date()))
			Recibo = replace(Recibo, "[-Usuario.Nome-]", UsuarioRecebimento)
			Recibo = replace(Recibo, "[Receita.ValorTotal]", fn(TotalTotal) )
			Recibo = replace(Recibo, "[Receita.TotalPago]", fn(ValorRecibo) )
			Recibo = replace(Recibo, "[Receita.TotalPendente]", fn(TotalPendente) )
            Recibo = replace(Recibo, "[Receita.ValorPagoExtenso]", extenso(ValorPagoExtenso))

            'TAGS MIGRADAS PARA A CLASSE tagsConverte 25/11/2020
            'Recibo = replace(Recibo, "[Receita.FormaPagamento]", FormaPagto)
			'Recibo = replace(Recibo, "[Receita.MetodoRecebimento]", MetodoRecebimento)

            Recibo = TagsConverte(Recibo,"ReceitaID_"&inv("id"),"")


            NomeSolicitante = ""

            if instr(inv("ProfissionalSolicitante"),"_")>0 then
                NomeSolicitante = Accountname("",inv("ProfissionalSolicitante"))
            end if
            Recibo = replace(Recibo, "[ProfissionalSolicitante.Nome]", NomeSolicitante)

		end if

		UnidadeInvoice = session("UnidadeID")
        set getUnidadeInvoice = db.execute("SELECT CompanyUnitID FROM sys_financialinvoices WHERE id="&inv("id"))
        if not getUnidadeInvoice.eof then
            UnidadeInvoice = getUnidadeInvoice("CompanyUnitID")
        end if

        set invoiceSequencial = db.execute("SELECT * FROM recibos WHERE InvoiceID="&inv("id")&" AND UnidadeID="&UnidadeInvoice)
        if not invoiceSequencial.eof then
            NumeroSequencial = invoiceSequencial("NumeroSequencial")

            if SplitNF<>1 then
                db_execute("UPDATE recibos SET sysActive=-1 WHERE InvoiceID="&inv("id")&" AND id!="&treatvalzero(reciboID))
            end if

        else
            set reciboSequencial = db.execute("SELECT NumeroSequencial FROM recibos WHERE UnidadeID="&UnidadeInvoice&" ORDER BY NumeroSequencial DESC LIMIT 1")
            if not reciboSequencial.eof then
                NumeroSequencial = reciboSequencial("NumeroSequencial") + 1
            else
                NumeroSequencial = 1
            end if
        end if
        Recibo = replace(Recibo, "[Recibo.Protocolo]", NumeroSequencial&"")
        Recibo = replace(Recibo, "[Fatura.NumeroSequencial]", inv("NumeroFatura")&"")

        nroNFe = 0
        set nfeEmitido = db.execute("select numeronfse from nfe_notasemitidas where numeronfse<>'' and InvoiceID="&inv("id"))
        if not nfeEmitido.eof then
            nroNFe = nfeEmitido("numeronfse")
        else
            if inv("nroNFe")&""<>"" then
                nroNFe = inv("nroNFe")
            end if
        end if
        Recibo = replace(Recibo, "[Recibo.NotaFiscal]", nroNFe)


        if (PacienteID<>"" and TotalPago>0) or (PacienteID<>"" and session("Banco")="clinic5968") or (PacienteID<>"" and session("Banco")="clinic100000") then
                                                           Recibo = replace(Recibo, "'", """")
            NomeItens = left(NomeItens, 200)
            CPFPACIENTE = ""

            set ReciboSQL = db.execute("SELECT id FROM recibos ORDER BY id DESC LIMIT 1")

            if not ReciboSQL.eof then
                Recibo = replace(Recibo, "[Recibo.ID]", ReciboSQL("id") + 1)
            end if

            set PacSQL = db.execute("SELECT cpf FROM pacientes WHERE id = "&PacienteID)

            if not PacSQL.eof then
                CPFPACIENTE = PacSQL("cpf")
            end if

            if reciboID<>"" then
                sqlRecibo = "UPDATE recibos SET Texto = '"&Recibo&"', ImpressoEm = now() WHERE id="&reciboID
            else


                if getConfig("registrarReciboDataHoraConta") then
                    sqlDataHora = mydatetime(DataHora)
                else
                    sqlDataHora = mydatetime(now())
                end if

                if Imprimiu="1" then
                    sqlRecibo = "INSERT INTO recibos (NumeroRps, RepasseIds, RPS, Cnpj, Nome, Data, Valor, Texto, PacienteID, sysUser, Servicos, Emitente, InvoiceID, UnidadeID, NumeroSequencial, CPF, Auto,ImpressoEm, sysDate) VALUES ("&treatvalzero(NumeroRps)&",'"&RepasseIds&"', '"&RPS&"', '"&Cnpj&"','"&NomeRecibo&"', "&mydatenull(date())&", "&treatvalzero(ValorRecibo)&", '"&Recibo&"', '"&PacienteID&"', "&session("User")&", '"&NomeItens&"', 0, "&InvoiceID&", "&UnidadeInvoice&", "&NumeroSequencial&", '"&CPFPACIENTE&"', 0, now(), "&sqlDataHora&")"
                else
                    sqlRecibo = "INSERT INTO recibos (NumeroRps, RepasseIds, RPS, Cnpj, Nome, Data, Valor, Texto, PacienteID, sysUser, Servicos, Emitente, InvoiceID, UnidadeID, NumeroSequencial, CPF, Auto, sysDate) VALUES ("&treatvalzero(NumeroRps)&",'"&RepasseIds&"', '"&RPS&"', '"&Cnpj&"','"&NomeRecibo&"', "&mydatenull(date())&", "&treatvalzero(ValorRecibo)&", '"&Recibo&"', '"&PacienteID&"', "&session("User")&", '"&NomeItens&"', 0, "&InvoiceID&", "&UnidadeInvoice&", "&NumeroSequencial&", '"&CPFPACIENTE&"', 0, "&sqlDataHora&")"
                end if
            end if
            
            if GravaRecibo="" then
		        db_execute(sqlRecibo)
            end if


        end if

		%>
		<%=unscapeOutput(Recibo)%>
	</div>
	<%
	if TabelaRepasses<>"" then
	%>

    <div style="padding: 0px 20px;" >
        <h4>Valores repassados</h4>
    	<table style="float: left;" class="table table-striped table-bordered table-condensed">

    	<thead>
    	<tr>
            <th>Data</th>
            <th>Procedimento</th>
            <th>Paciente</th>
            <th>CPF</th>
            <% if ValorTotalReciboRepasse then %>
                <th>Total</th>
            <% end if %>
            <th>Repasse</th>
        </tr>
        </thead>
    	<tbody ><%=TabelaRepasses%></tbody>
        </table>
    </div>

    <%
    end if
    %>
	<%
end if %>
</div>
<% next %>
<script type="text/javascript">
   $(document).ready(function(){
        print();
   });
</script>