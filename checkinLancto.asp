<!--#include file="connect.asp"-->

<%
posModalPagar = "fixed"
%>

<!--#include file="invoiceEstilo.asp"-->
<script type="text/javascript">
/*
$("#pagar").fadeIn();

$(function() {
$( "#pagar" ).draggable();
});
*/
/*
$("#pagar").html("Carregando...");
    $.post("Pagar.asp?T=C", {
        Parcela: '|3586|'
    }, function (data) {
    $("#pagar").html(data);
});
*/
</script>
<%

splLC = split(ref("LanctoCheckin"), ", ")
ContaRectoID = ref("ContaRectoID")


if ContaRectoID = "" then
    ContaRectoID = 0
end if

FormaID = ref("FormaID")
ValorTotal = 0

tabelaId = ""
for i= 0 to ubound(splLC)
    spl2 = split(splLC(i), "_")
    AgendamentoID = spl2(0)
    AgendamentoProcedimentoID = spl2(1)
    if AgendamentoID<>"" then
        
        set ag = db.execute("select a.id, a.ProfissionalID, a.Data, a.rdValorPlano, a.ValorPlano, a.PacienteID, TipoCompromissoID, a.EspecialidadeID, a.LocalID, a.TabelaParticularID FROM agendamentos a where a.id="& AgendamentoID)
        if not ag.eof then
            
            PacienteID = ag("PacienteID")
            Valor = ag("ValorPlano")
            ProfissionalID = ag("ProfissionalID")
            ProcedimentoID = ag("TipoCompromissoID")
            rdValorPlano = ag("rdValorPlano")
            EspecialidadeID=ag("EspecialidadeID")

            tabelaId = ag("TabelaParticularID")
            
            if AgendamentoProcedimentoID<>"" then
                set agProcedimento = db.execute("select a.rdValorPlano, a.ValorPlano, a.TipoCompromissoID FROM agendamentosprocedimentos a where a.id="& AgendamentoProcedimentoID)
                Valor = agProcedimento("ValorPlano")
                rdValorPlano = agProcedimento("rdValorPlano")
                ProcedimentoID = agProcedimento("TipoCompromissoID")
            end if
            
            if rdValorPlano="V" then
                ValorTotal = ValorTotal + Valor
            end if
 
        end if
    end if
next

ObrigarTabelaParticular= getConfig("ObrigarTabelaParticular")

if (tabelaId = "" or tabelaId="0") and ObrigarTabelaParticular=1 then
    response.write("<script>showMessageDialog('Erro: Preencha a tabela do paciente!');</script>")
    response.end
end if
%>

<script type="text/javascript">
    $("#pagar").fadeIn();

    $(function() {
    $( "#pagar" ).draggable();
    });
</script>

<%
valorTotalOriginal=ValorTotal
if ref("valorTotalSomadoModificado") <> "" then
    valorModificado = ref("valorTotalSomadoModificado")
    valorTotal = valorModificado
end if

 checkinPagar = false


InvoiceID = 0
saveInsys_financialmovement = 0
splLC = split(ref("LanctoCheckin"), ", ")
ProcedimentosAdicionados = ""

for i= 0 to ubound(splLC)
    spl2 = split(splLC(i), "_")
    AgendamentoID = spl2(0)
    AgendamentoProcedimentoID = spl2(1)
    JaAdicionou = false

    if AgendamentoID<>"" then
        set ag = db.execute("select a.IndicadoPor, l.UnidadeID, a.id, a.ProfissionalID, a.Data, a.rdValorPlano, a.ValorPlano, a.PacienteID, TipoCompromissoID, a.EspecialidadeID, a.LocalID, a.TabelaParticularID FROM agendamentos a left join locais l ON l.id=a.LocalID where a.id="& AgendamentoID)
        if not ag.eof then
            
            id = ag("id")
            PacienteID = ag("PacienteID")
            Valor = ag("ValorPlano")
            ProfissionalID = ag("ProfissionalID")
            ProcedimentoID = ag("TipoCompromissoID")
            rdValorPlano = ag("rdValorPlano")
            UnidadeID = ag("UnidadeID")
            IndicacaoID = ag("IndicadoPor")
            TabelaID = ag("TabelaParticularID")

            if (tabelaId&"" = "" or tabelaId&""="0") and ObrigarTabelaParticular=1 then
                response.write("<script>showMessageDialog('Erro: Preencha a tabela do paciente!');$('#pagar').fadeOut();</script>")
                response.end
            end if

            EspecialidadeID=ag("EspecialidadeID")

            if isnull(UnidadeID) then
                UnidadeID=session("UnidadeID")
            end if

            if AgendamentoProcedimentoID<>"" then

                set agProcedimento = db.execute("select a.rdValorPlano, a.ValorPlano, a.TipoCompromissoID FROM agendamentosprocedimentos a where a.id="& AgendamentoProcedimentoID)
                Valor = agProcedimento("ValorPlano")
                rdValorPlano = agProcedimento("rdValorPlano")
                ProcedimentoID = agProcedimento("TipoCompromissoID")
            end if

            Quantidade=1
            'quantidade de um mesmo procedimento na conta
            set QuantidadeProcedimentoSQL = db.execute("SELECT count(ProcedimentoID)Qtd FROM (SELECT TipoCompromissoID ProcedimentoID FROM agendamentos WHERE id="&AgendamentoID&" UNION ALL SELECT TipoCompromissoID ProcedimentoID FROM agendamentosprocedimentos WHERE AgendamentoID="&AgendamentoID&")t WHERE t.ProcedimentoID="&ProcedimentoID&" group by procedimentoID")
            if not QuantidadeProcedimentoSQL.eof then
                Quantidade = ccur(QuantidadeProcedimentoSQL("Qtd"))

                if Quantidade > 1 then
                    if instr(ProcedimentosAdicionados, "|"&ProcedimentoID&"|")>0 then
                        JaAdicionou=true
                    end if
                end if
            end if

            if not JaAdicionou then
                ProcedimentosAdicionados = ProcedimentosAdicionados & "|"&ProcedimentoID&"|"

                if rdValorPlano="V" then

                    'requisitos pra usar o movement que j� existe: executado vazio ou o proprio, data exec vazia ou a propria, descontado zero do ii, soma das parcelas da invoice=1, valor igual, proc igual, else cria nova e chapa como executado
                    set vcaII = db.execute("select ii.InvoiceID, i.FormaID, ii.id, (select id from sys_financialmovement where Type='Bill' and CD='C' and InvoiceID=i.id limit 1) MovementID FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE i.AccountID="& PacienteID &" AND i.Value="& treatvalnull(ValorTotal) &" AND i.AssociationAccountID=3 AND ii.ItemID="& ProcedimentoID &" AND ii.Tipo='S' AND (ii.ProfissionalID="& treatvalnull(ProfissionalID) &" OR ISNULL(ii.ProfissionalID)) AND IFNULL((select sum(Valor) from itensdescontados where ItemID=ii.id), 0)=0 AND (select count(id) from sys_financialmovement where Type='Bill' and CD='C' and InvoiceID=i.id)=1")
                    if not vcaII.eof then

                        'Incrementa o ParcelasAPagar
                        'response.write("Achado "& vcaII("id") &"<br>")
                        MovementID = vcaII("MovementID")
                        InvoiceID = vcaII("InvoiceID")

                        if FormaID&"" <> "0" then
                            db.execute("UPDATE sys_financialinvoices SET FormaID="&treatvalzero(FormaID)&", ContaRectoID="&treatvalzero(ContaRectoID)&" WHERE id="&InvoiceID)
                        end if


                    else
                        'Incrementa a variavel ItensDaInvoiceACriar
                        'response.write("Criando novo<br>")c
                        if InvoiceID=0 then
                            if FormaID = "" then
                                FormaID = 0
                            end if


                            'exclui as contas geradas nao quitadas para este agendamento
                            'aqui pode ser o caso que um desconto foi dado e ai nao eh encontrado mais a conta naqueles parametros

                            set InvoicesNaoQuitadasSQL = db.execute("SELECT ii.InvoiceID, ii.id FROM itensinvoice ii INNER JOIN sys_financialinvoices i ON i.id=ii.InvoiceID INNER JOIN sys_financialmovement m ON m.InvoiceID=i.id WHERE ii.AgendamentoID="&AgendamentoID&" AND i.sysDate=curdate() AND (m.ValorPago is null or m.ValorPago=0) LIMIT 2")
                            while not InvoicesNaoQuitadasSQL.eof
                                InvoiceIDToDelete = InvoicesNaoQuitadasSQL("InvoiceID")
                                db.execute("DELETE FROM itensinvoice WHERE InvoiceID="&InvoiceIDToDelete)
                                db.execute("DELETE FROM sys_financialinvoices WHERE id="&InvoiceIDToDelete)
                                db.execute("DELETE FROM sys_financialmovement WHERE InvoiceID="&InvoiceIDToDelete)
                            InvoicesNaoQuitadasSQL.movenext
                            wend
                            InvoicesNaoQuitadasSQL.close
                            set InvoicesNaoQuitadasSQL=nothing

                            db.execute("insert into sys_financialinvoices (Name, AccountID, AssociationAccountID, Value, Tax, Currency, CompanyUnitID, Recurrence, RecurrenceType, CD, sysActive, sysUser, FormaID, ContaRectoID, sysDate, CaixaID, TabelaID) VALUES ('Gerado pelo check-in', "& PacienteID &", 3, "& treatvalzero(ValorTotal) &", 1, 'BRL', "& UnidadeID &", 1, 'm', 'C', 1, "& session("User") &", "&FormaID&", "&ContaRectoID&", curdate(), "& treatvalnull(session("CaixaID")) &","&treatvalnull(TabelaID)&")")
                            set pult = db.execute("select id from sys_financialinvoices where sysUser="& session("User") &" order by id desc limit 1")
                            InvoiceID = pult("id")

                        end if

                        Acrescimo=0
                        Desconto=0


                        DiferencaPorcentagem = 0

                        if valorModificado<>"" and valorTotalOriginal&""<>"0" then
                            DiferencaPorcentagem = (valorTotalOriginal - ValorTotal) / valorTotalOriginal
                            DiferencaValores = valorTotalOriginal - ValorTotal

                            if DiferencaValores < 0 then
                                Acrescimo = Round((DiferencaPorcentagem * Valor) * -1,2)
                            elseif DiferencaValores > 0 then
                                Desconto = Round(DiferencaPorcentagem * Valor)
                            end if
                        end if

                        db.execute("insert into itensinvoice (InvoiceID, Tipo, Quantidade, CategoriaID, ItemID, ValorUnitario, Desconto, Acrescimo, Executado, DataExecucao, GrupoID, AgendamentoID, sysUser, ProfissionalID, EspecialidadeID, Associacao) values ("& InvoiceID &", 'S', "&Quantidade&", 0, "& ProcedimentoID &", "& treatvalzero(Valor) &", "&treatvalzero(Desconto)&", "&treatvalzero(Acrescimo)&", 'S', curdate(), 0, "& ag("id") &", "& session("User") &", "& ag("ProfissionalID") &", "& treatvalnull(EspecialidadeID) &", 5)")
                        set pult = db.execute("select id from itensinvoice where sysUser="& session("User") &" order by id desc limit 1")
                        ItemInvoiceID = pult("id")

    've se tem repasse com indicacao
                        if IndicacaoID&""<>"" and IndicacaoID<>"0" then

                            if EspecialidadeID&"" <> "" then
                                EspecialidadeID=ccur(EspecialidadeID)
                            end if
                            if ProfissionalID&"" <> "" then
                                ProfissionalID=ccur(ProfissionalID)
                            end if
                            if TabelaID&"" <> "" then
                                TabelaID=ccur(TabelaID)
                            end if
                            if EspecialidadeID&"" <> "" then
                                EspecialidadeID=ccur(EspecialidadeID)
                            end if

                            FormaPagtoRepasse = "|P|"

                            if FormaID&"" <> "0" and ContaRectoID&"" <> "0" then
                                FormaPagtoRepasse="|P"&FormaID&"_"&ContaRectoID&"|"
                            end if

                            DominioID = dominioRepasse(FormaPagtoRepasse, ProfissionalID, ProcedimentoID, UnidadeID, TabelaID, EspecialidadeID, "", "")

                            set FuncaoIndicacaoSQL = db.execute("SELECT id, Funcao FROM rateiofuncoes WHERE DominioID="&DominioID&" AND ContaPadrao=''")
                            if not FuncaoIndicacaoSQL.eof then
                                'adiciona uma indicacao

                                FuncaoID = FuncaoIndicacaoSQL("id")
                                Funcao = FuncaoIndicacaoSQL("Funcao")

                                db_execute("INSERT INTO `itensinvoiceoutros` (`InvoiceID`, `ItemInvoiceID`, `Tipo`, `FuncaoID`, `ProdutoID`, `Quantidade`, `ValorUnitario`, `ProdutoKitID`, `FuncaoEquipeID`, `TipoValor`, `Conta`, `Funcao`, `Variavel`, `ValorVariavel`, `ContaVariavel`, `ProdutoVariavel`, `TabelasPermitidas`, `sysActive`, `Usado`) VALUES " &_
                                                                           " ("&treatvalzero(InvoiceID)&", "&treatvalzero(ItemInvoiceID)&", 'F', "&FuncaoID&", 0, 0, 0, 0, 0, 'S', '"&IndicacaoID&"', '"&Funcao&"', '', '', 'S', '', NULL, 1, 0)")
                            end if
                        end if

                        if saveInsys_financialmovement=0 then
                            db.execute("insert into sys_financialmovement (AccountAssociationIDCredit, AccountIDCredit, AccountAssociationIDDebit, AccountIDDebit, Value, Date, CD, Type, Currency, Rate, InvoiceID, InstallmentNumber, sysUser, CaixaID, UnidadeID) values (0, 0, 3, "& PacienteID &", "& treatvalzero(ValorTotal) &", curdate(), 'C', 'Bill', 'BRL', 1, "& InvoiceID &", 1, "& session("User") &", "& treatvalnull(session("CaixaID")) &", "& UnidadeID &")")
                            set pm = db.execute("select id from sys_financialmovement where sysUser="& session("User") &" order by id desc limit 1")
                            MovementID = pm("id")
                            saveInsys_financialmovement = 1
                        end if

                    end if
                    %>
                    <input id="AccountID" type="hidden" name="AccountID" value="<%= "3_"& PacienteID %>" />
                    <input class="parcela" type="hidden" name="Parcela" value="|<%= MovementID %>|" />
                    <script type="text/javascript">
                        var invoiceId= '<%=InvoiceID%>';


                    </script>
                    <%
                    checkinPagar = true
                end if
            end if
        end if
    else
        'ver o que faz com agprocs.
    end if
next
%>

<% if checkinPagar = true then %>

<script type="text/javascript">
    <!--#include file="financialCommomScripts.asp"-->

    $("#pagar").html("Carregando...");
    $.post("Pagar.asp?T=C", {
        Parcela: '|<%= MovementID %>|'
        }, function (data) {
            $("#pagar").html(data);
        });
</script>  

<% end if %>