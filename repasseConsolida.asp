<!--#include file="connect.asp"-->
<!--#include file="RecibosSplitNFSe.asp"-->

<%
set ConfigSQL = db.execute("SELECT SplitNF FROM sys_config WHERE id=1")
SplitNF = ConfigSQL("SplitNF")

if req("A")="Recibo" then
    if req("InvoiceID")<>"" then
        novoGeraReciboSplit(req("InvoiceID"))
    end if

elseif ref("linhaRepasse")="" and ref("linhaRepasseG")="" then
    %>
    //alert('Este novo repasse encontra-se em publicação. Por favor utilize a versão antiga para gerar repasses.');
    alert('Selecione os itens que deseja consolidar.');
    <%
else
    spl = split(ref("linhaRepasse"), ", ")
    profissionaisParaGerarRecibo = ""

    for i=0 to ubound(spl)

       splL = split( ref("linhaRepasse"& spl(i) ), ", ")
        GrupoConsolidacao = ""

        for j=0 to ubound(splL)
            splLR = split(splL(j), "|")
            '1.ItemInvoiceID|2.ItemDescontadoID|3.ItemGuiaID|4.GuiaConsultaID|5.ItemHonorarioID|6.Funcao|7.Valor|8.ContaCredito|9.Parcela|10.FormaID|11.Sobre|12.FM|13.ProdutoID|14.ValorUnitario|15.Quantidade|16.FuncaoID|17. Percentual|18.ParcelaID|19. modoCalculo
            ItemInvoiceID = splLR(0)
            ItemDescontadoID = splLR(1)
            ItemGuiaID = splLR(2)
            GuiaConsultaID = splLR(3)
            ItemHonorarioID = splLR(4)
            Funcao = splLR(5)
            Valor = splLR(6)
            ContaCredito = splLR(7)
            Parcela = splLR(8)
            FormaID = splLR(9)
            Sobre = splLR(10)
            FM = splLR(11)
            ProdutoID = splLR(12)
            ValorUnitario = splLR(13)
            Quantidade = splLR(14)
            FuncaoID = splLR(15)
            Percentual = splLR(16)
            ParcelaID = splLR(17)
            modoCalculo = splLR(18)
            Bloqueia = ""
            if modoCalculo<>"I" then
                modoCalculo = "N"
            end if
            if ItemInvoiceID<>"" then
                if GrupoConsolidacao="" then
                    set gc = db.execute("select GrupoConsolidacao from rateiorateios where ItemInvoiceID="& ItemInvoiceID &" order by GrupoConsolidacao desc limit 1")
                    if gc.eof then
                        GrupoConsolidacao = 1
                    else
                        GrupoConsolidacao = gc("GrupoConsolidacao")+1
                    end if
                end if
            end if

            'if session("AutoConsolidar")="S" then
                set vca = db.execute("select id from rateiorateios where ItemInvoiceID="& treatvalnull(ItemInvoiceID) &" and ItemDescontadoID="& treatvalnull(ItemDescontadoID) &" and ContaCredito='"& ContaCredito &"' and FuncaoID="& treatvalnull(FuncaoID) &" and ParcelaID="& treatvalzero(ParcelaID) &"")
                if not vca.eof then
                    Bloqueia = "S"
                end if
            'end if

            if Bloqueia="" then
                db.execute("insert into rateiorateios (ItemInvoiceID, ItemDescontadoID, ItemGuiaID, GuiaConsultaID, ItemHonorarioID, Funcao, TipoValor, Valor, ContaCredito, sysDate, Parcela, FormaID, Sobre, FM, ProdutoID, ValorUnitario, Quantidade, sysUser, FuncaoID, Percentual, GrupoConsolidacao, ParcelaID, modoCalculo) values ("& treatvalnull(ItemInvoiceID) &", "& treatvalnull(ItemDescontadoID) &", "& treatvalnull(ItemGuiaID) &", "& treatvalnull(GuiaConsultaID) &", "& treatvalnull(ItemHonorarioID) &", '"& Funcao &"', 'V', "& treatvalzero(Valor) &", '"& ContaCredito &"', curdate(), "& treatvalnull(Parcela) &", "& treatvalnull(FormaID) &", "& treatvalzero(Sobre) &", '"& FM &"', "& treatvalnull(ProdutoID) &", "& treatvalzero(ValorUnitario) &", "& treatvalzero(Quantidade) &", "& session("User") &", "& treatvalnull(FuncaoID) &", "& treatvalnull(Percentual) &", "& treatvalzero(GrupoConsolidacao) &", "& treatvalzero(ParcelaID) &", '"& modoCalculo &"')")
            end if

            if ItemDescontadoID<>"" then
                ' db.execute("update itensdescontados set Repassado=1 WHERE id="& treatvalzero(ItemDescontadoID))
            end if

            if ItemInvoiceID <> "" then
                if SplitNF=1 then
                    'set RepasseIDSQL = db.execute("SELECT id FROM rateiorateios ORDER BY id DESC LIMIT 1")
                    'profissionaisParaGerarRecibo = geraRecibosSplit(RepasseIDSQL("id"))
                end if 
            end if
        next
    next
    ReloadOK=False

    'usaremos agora a geracao manual de recibo no SPLIT
    if false then
        if SplitNF=1 then
            set RepasseIDSQL = db.execute("select ii.InvoiceID from itensinvoice as ii where id="& treatvalnull(ItemInvoiceID))
            InvoiceID = RepasseIDSQL("InvoiceID")
            novoGeraReciboSplit(InvoiceID)
        end if

        'não usado
        if SplitNF=1 then
            profissionaisParaGerarReciboSplt = split(profissionaisParaGerarRecibo,",, ")

            ValorRepassado=0
            for i=0 to ubound(profissionaisParaGerarReciboSplt)
                if profissionaisParaGerarReciboSplt(i) <> "" then
                    ProfissionalInvoice = replace(profissionaisParaGerarReciboSplt(i), "/", "")

                    ProfissionalInvoiceSplt = split(ProfissionalInvoice,"^|")
                    ProfissionalID = ProfissionalInvoiceSplt(0)
                    AssociacaoID = ProfissionalInvoiceSplt(1)
                    InvoiceID = ProfissionalInvoiceSplt(2)
                    Valor = ProfissionalInvoiceSplt(3)
                    ValorSomado = 0
                    RepasseNome = ProfissionalInvoiceSplt(4)
                    PessoaJuridica = ProfissionalInvoiceSplt(5)
                    Cnpj = ProfissionalInvoiceSplt(6)
                    RepasseIds = ProfissionalInvoiceSplt(7)
                    NumeroRps = ProfissionalInvoiceSplt(8)
                    RPS="N"

                    modeloColuna = "ReciboHonorarioMedico"

                    if PessoaJuridica="1" then
                        modeloColuna = "RPSModelo"
                        RepasseNome = "RPS - "&RepasseNome
                        RPS="S"
                    end if

                    ValoresSomatorioSplt = split(Valor, "+")

                    for j=0 to ubound(ValoresSomatorioSplt)
                        if isnumeric(ValoresSomatorioSplt(j)) then
                            ValorSomado = ValorSomado + ValoresSomatorioSplt(j)
                        end if
                    next

                    if not isnumeric(Valor) then
                        Valor=0
                    end if

                    if ValorSomado=0 then
                        ValorSomado=Valor
                    end if

                    ValorRepassado= ValorRepassado + ValorSomado

                    if ValorRepassado>0 then
                        ValorRepassado=ccur(ValorRepassado)
                    end if

                'call gravaRecibo(NumeroRps, repasseIds, RPS, Cnpj, RepasseNome, ValorSomado, InvoiceID, ProfissionalID, AssociacaoID)

                end if
            next

        end if
    end if

        ReloadOK = True
        %>
        location.reload();
        <%
end if



if req("AC")<>"0" and req("AC")<>"" and not ReloadOK then
    db.execute("delete from reconsolidar where id in("& req("AC") &")")
    %>
    location.reload();
    <%
end if
%>