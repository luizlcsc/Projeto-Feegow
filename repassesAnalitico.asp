<style type="text/css">
body, tr, td, th {
	font-size:10px!important;
	padding:2px!important;
}

.btnPac {
    visibility:hidden;
}

.linhaPac:hover .btnPac {
    visibility:visible;
}


.btnsHV {
    display:none;
}

#resumo tr td {
    height:22px!important;
}

</style>
<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%
response.Charset="utf-8"

'on error resume next
if ref("De")="" then
	De=dateAdd("m",-1,date())
else
	De=ref("De")
end if

if ref("Ate")="" then
	A=date()
else
	A=ref("Ate")
end if

valorTotal=0

function marcar(midBruto, mLink, mClass)
    marcar = "<span class='btnsHV pl30'><span class='btn btn-xs checkbox-custom checkbox-"& mClass &"'> <input type='checkbox' id='chk"& midBruto &"' onclick=""hoverIDBruto('"& midBruto &"', $(this).prop('checked'), '"& mClass &"')"" /> <label for='chk"& midBruto &"'>Marcar</label> </span> " & mLink &"</span>"
end function

%>
<%
if ref("De")="" then
%>
<h4>Repasses - Analítico</h4>
<form method="post" target="_blank" action="PrintStatement.asp?R=repassesAnalitico">
    <input type="hidden" name="R" value="repassesAnalitico">
    <div class="clearfix form-actions">
        <div class="row">
            <%=quickfield("datepicker", "De", "Atendimento de", 2, De, "", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, A, "", "", "")%>
            <%=quickField("empresaMulti", "UnidadeID", "Unidade", 4, session("Unidades"), " input-sm", "", "")%>
            <%= quickfield("multiple", "Profissional", "Profissionais", 3, "", "select distinct replace(rr.contacredito, '5_', '') id, p.NomeProfissional from rateiorateios rr left join profissionais p on p.id=replace(rr.ContaCredito, '5_', '') where left(rr.ContaCredito, 2)='5_' and p.Ativo='on' order by p.NomeProfissional", "NomeProfissional", " required ") %>
            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button type="submit" class="btn btn-primary" name="Gerar" value="Gerar"><i class="far fa-search"></i>Gerar</button>
            </div>
        </div>
        <div class="row mt20">
            <div class="col-md-3 checkbox-custom">
                <input type="checkbox" value="1" name="OutrasDespesas" id="OutrasDespesas" /><label for="OutrasDespesas">Exibir outras despesas</label>
            </div>
            <div class="col-md-3 checkbox-custom">
                <input type="checkbox" value="1" name="Resultado" id="Resultado" /><label for="Resultado">Exibir resultado</label>
            </div>
        </div>
    </div>
    <input type="hidden" name="E" value="E" />
</form>
<%
else
%>
<h2 class="text-center">REPASSES - ANALÍTICO</h2>
<%
end if


if ref("E")="E" and ref("Profissional")<>"" then

    granTotal = 0
    granTotalRepasseN = 0
    granTotalOutrasDespesas = 0
    granTotalResultado = 0


    db.execute("delete from cliniccentral.temp_repasses where sysUser="& session("User"))

    response.buffer
    Profissionais = replace(ref("Profissional"), "|", "")
	set pP=db.execute("select prof.NomeProfissional, t.ProfissionalID from ( "&_
    "select distinct ii.ProfissionalID from itensinvoice ii where ii.ProfissionalID IN("& Profissionais &") AND ii.Associacao=5 AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
    "UNION ALL "&_
    "SELECT DISTINCT gc.ProfissionalID FROM tissguiaconsulta gc WHERE gc.ProfissionalID IN("& Profissionais &") AND gc.DataAtendimento BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
    "UNION ALL "&_
    "SELECT DISTINCT gps.ProfissionalID FROM tissprocedimentossadt gps WHERE gps.ProfissionalID IN("& Profissionais &") AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
    ") t LEFT JOIN profissionais prof ON prof.id=t.ProfissionalID WHERE NOT ISNULL(prof.NomeProfissional) GROUP BY t.ProfissionalID ORDER BY prof.NomeProfissional")
	while not pP.EOF
	    c = 0
        Total = 0
        SaldoRepasse = 0
        TotalRepasseN = 0
        TotalRepasseI = 0
        TotalOutrasDespesas = 0
        TotalResultado = 0
        ProfissionalID = pP("ProfissionalID")

        LiqEnvolvidasN = ""
        LiqEnvolvidasI = ""
        %>
        <h4><%=uCase(pP("NomeProfissional"))%></h4>
        <table width="100%" class="table table-condensed table-striped table-hover">
            <thead>
                <tr>
                    <th >ATENDIMENTO</th>
                    <th >PACIENTE</th>
                    <th >PROCEDIMENTO</th>
                    <th>FORMA</th>
                    <th>SITUAÇÃO</th>
                    <th >VALOR TOTAL</th>
                    <th >VALOR PROFISSIONAL</th>
                    <% if ref("OutrasDespesas")="1" then %>
                        <th>OUTRAS DESPESAS</th>
                    <% end if %>
                    <% if ref("Resultado")="1" then %>
                        <th>RESULTADO</th>
                    <% end if %>
                </tr>
            </thead>
            <tbody>
                <%
	            set rp=db.execute("select t.id, t.Coluna, pac.NomePaciente, t.DataExecucao, proc.NomeProcedimento, IF(t.ConvenioID=0, 'Particular', conv.NomeConvenio) NomeConvenio, t.ValorTotal from ( "&_
                "select ii.id, 'ItemInvoiceID' Coluna, i.AccountID PacienteID, ii.DataExecucao, ii.ItemID ProcedimentoID, 0 ConvenioID, (ii.Quantidade * (ii.ValorUnitario-ii.Desconto+ii.Acrescimo)) ValorTotal FROM itensinvoice ii LEFT JOIN sys_financialinvoices i ON i.id=ii.InvoiceID WHERE ii.ProfissionalID="& ProfissionalID &" AND ii.Associacao=5 AND ii.Tipo='S' AND ii.DataExecucao BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
                "UNION ALL "&_
                "SELECT gc.id, 'GuiaConsultaID', gc.PacienteID, gc.DataAtendimento, gc.ProcedimentoID, gc.ConvenioID, gc.ValorProcedimento FROM tissguiaconsulta gc WHERE gc.ProfissionalID="& ProfissionalID &" AND gc.DataAtendimento BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
                "UNION ALL "&_
                "SELECT gps.id, 'ItemGuiaID', gs.PacienteID, gps.Data, gps.ProcedimentoID, gs.ConvenioID, gps.ValorTotal FROM tissprocedimentossadt gps LEFT JOIN tissguiasadt gs ON gs.id=gps.GuiaID WHERE gps.ProfissionalID="& ProfissionalID &" AND gps.Data BETWEEN "& mydatenull(De) &" AND "& mydatenull(A) &_
                ") t LEFT JOIN pacientes pac ON pac.id=t.PacienteID LEFT JOIN procedimentos proc ON proc.id=t.ProcedimentoID LEFT JOIN convenios conv ON conv.id=t.ConvenioID ORDER BY t.DataExecucao")
                while not rp.eof
                    id = rp("id")
                    Coluna = rp("Coluna")
                    set valRep = db.execute("select ifnull(sum(Valor), 0) RepasseProfissional, ContaCredito, ItemContaAPagar, ItemContaAReceber, CreditoID, modoCalculo from rateiorateios where "& Coluna &"="& id &" and ContaCredito='5_"& ProfissionalID &"'")
                    if not valRep.eof then
                        response.flush()

                        ValorRepasse = valRep("RepasseProfissional")
                        if valRep("modoCalculo")="I" then
                            TotalRepasseI = TotalRepasseI + ValorRepasse
                            ValorRepasseShow = ValorRepasse * (-1)
                        else
                            TotalRepasseN = TotalRepasseN + ValorRepasse
                            ValorRepasseShow = ValorRepasse
                        end if
                        c = c+1
                        Total = Total + rp("ValorTotal")
                        SaldoRepasse = SaldoRepasse + ValorRepasse


                        idBruto = "ooo"
                        if not isnull(valRep("CreditoID")) then
                            Situacao = "Liquidado com crédito: "& valRep("CreditoID")
                            idBruto = "C"& valRep("CreditoID")
                            if instr(LiqEnvolvidasI, "|C"& valRep("CreditoID") &"|")=0 then
                                LiqEnvolvidasI = LiqEnvolvidasI & "|"& idBruto &"|"
                            end if
                        elseif not isnull(valRep("ItemContaAPagar")) then
                            Situacao = "Liquidado com pagamento: "& valRep("ItemContaAPagar")
                            idBruto = "P"& valRep("ItemContaAPagar")
                            if instr(LiqEnvolvidasN, "|P"& valRep("ItemContaAPagar") &"|")=0 then
                                LiqEnvolvidasN = LiqEnvolvidasN & "|"& idBruto &"|"
                            end if
                        elseif not isnull(valRep("ItemContaAReceber")) then
                            Situacao = "Liquidado com conta a receber: "& valRep("ItemContaAReceber")
                            idBruto = "R"& valRep("ItemContaAReceber")
                            if instr(LiqEnvolvidasI, "|R"& valRep("ItemContaAReceber") &"|")=0 then
                                LiqEnvolvidasI = LiqEnvolvidasI & "|"& idBruto &"|"
                            end if
                        else
                            if valRep("modoCalculo")="I" then
                                idBruto = "IIII"
                            else
                                idBruto = "NNNN"
                            end if
                            Situacao = "Pendente"
                        end if

                    db.execute("insert into cliniccentral.temp_repasses (idBruto, ValorTotal, ValorDespesas, ValorRepasse, sysUser) values ('"& idBruto &"', "& treatvalzero(rp("ValorTotal")) &", "& treatvalzero(0) &", "& treatvalzero(ValorRepasse) &", "& session("User") &")")

                    %>
                    <tr class="<%= idBruto %> idbru">
                        <td><%= rp("DataExecucao") %></td>
                        <td><%= rp("NomePaciente") %></td>
                        <td><%= rp("NomeProcedimento") %></td>
                        <td><%= rp("NomeConvenio") %></td>
                        <td><%= Situacao %></td>
                        <td class="text-right"><%= fn(rp("ValorTotal")) %></td>
                        <td class="text-right"><%= fn( ValorRepasseShow ) %></td>
                        <% if ref("OutrasDespesas")="1" or ref("Resultado")="1" then
                            set od = db.execute("select ifnull(sum(Valor), 0) od from rateiorateios where "& Coluna &"="& id &" and ContaCredito not in('0', '', '5_"& ProfissionalID &"') and modoCalculo='N'")
                            OutrasDespesas = ccur(od("od"))

                            if ref("Resultado")="1" then
                                set orc = db.execute("select ifnull(sum(Valor), 0) orc from rateiorateios where "& Coluna &"="& id &" and ContaCredito not in('0', '') and modoCalculo='I'")
                                OutrasReceitas = ccur(orc("orc"))
                                if valRep("modoCalculo")="I" then
                                    Resultado = OutrasReceitas
                                else
                                    Resultado = rp("ValorTotal") - OutrasDespesas - ValorRepasse
                                    OutrasReceitas = 0'ver se depois coloca real as outras receitas
                                end if
                                TotalOutrasDespesas = TotalOutrasDespesas + OutrasDespesas
                                TotalResultado = TotalResultado + Resultado
                            end if
                            %>
                            <td class="text-right"><%= fn(OutrasDespesas) %></td>
                        <% end if %>
                        <% if ref("Resultado")="1" then %>
                            <td class="text-right"><%= fn(Resultado) %></td>
                        <% end if %>
                    </tr>
                    <%
                    end if
                rp.movenext
                wend
                rp.close
                set rp = nothing

                granTotal = granTotal+Total
                granTotalRepasseN = granTotalRepasseN+TotalRepasseN
                granTotalOutrasDespesas = granTotalOutrasDespesas+TotalOutrasDespesas
                granTotalResultado = granTotalResultado+TotalResultado
                %>
            </tbody>
            <tfoot>
                <tr>
                    <th colspan="5"><%= c %> itens </th>
                    <th class="text-right"><%= fn(Total) %></th>
                    <th class="text-right"><%= fn(TotalRepasseN) %>
                        <% if TotalRepasseI>0 then %>
                             - <%= fn(TotalRepasseI) %>
                        <% end if %></th>
                    <% if ref("OutrasDespesas")="1" then %>
                        <th class="text-right"><%= fn(TotalOutrasDespesas) %></th>
                    <% end if %>
                    <% if ref("Resultado")="1" then %>
                        <th class="text-right"><%= fn(TotalResultado) %></th>
                    <% end if %>
                </tr>
            </tfoot>
        </table>


        <table class="table table-condensed table-bordered table-hover mt25" id="resumo">
            <% if TotalRepasseI>0 then
                %>
                <tr id="resumoinvertidos">
                    <th>Repasses do profissional para a clínica</th>
                    <th class="text-right"><%= fn(TotalRepasseI) %></th>
                </tr>
                <%
                Pendente = TotalRepasseI
                splLiq = split(LiqEnvolvidasI, "||")
                SaldoFinal = 0
                cl = 0
                for i=0 to ubound(splLiq)
                    Liquidacao = replace(splLiq(i), "|", "")
                    TLiq = ""
                    DescriLiq = ""
                    if instr(Liquidacao, "R")>0 then
                        TLiq = "R"
                        idLiq = replace(Liquidacao, "R", "")

                        set soma = db.execute("select ifnull(sum(ValorRepasse), 0) TotalRepasse from cliniccentral.temp_repasses where idBruto='"& TLiq & idLiq &"' and sysUser="& session("User"))
                        TotalRepasse = ccur(soma("TotalRepasse"))
                        Pendente = Pendente - TotalRepasse
                        set ii = db.execute("select * from itensinvoice ii where id="& idLiq)
                        if not ii.eof then
                            TotalPagtos = 0
                            ValorReceita = ccur(ii("Quantidade")*(ii("ValorUnitario")+ii("Acrescimo")-ii("Desconto")))
                            Link = "<a class='btn btn-xs' href='./?P=Invoice&I="& ii("InvoiceID") &"&Pers=1' target='_blank'><i class='far fa-external-link m5'></i> Detalhes</a>"
                            Descricao = " Receita de R$ "& fn(ValorReceita) &", sendo "
                            set idesc = db.execute("select idesc.*, ii.InvoiceID, m.AccountAssociationIDDebit, m.AccountIDDebit, m.Date DataPagto from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID where idesc.ItemID="& idLiq)
                            while not idesc.eof
                                TotalPagtos = TotalPagtos + idesc("Valor")
                                Descricao = Descricao & " &raquo; R$ "& fn(idesc("Valor")) &" em "& idesc("DataPagto")
                            idesc.movenext
                            wend
                            idesc.close
                            set idesc=nothing

                            if (TotalPagtos+0.03)<ValorReceita then
                                Descricao = Descricao & " &raquo;<code> R$ "& fn(ValorReceita - TotalPagtos) &" em aberto</code>"
                            end if
                            %>
                            <tr>
                                <td class="pl30"><%= Descricao %> <%= marcar(TLiq&idLiq, Link, "alert") %>
                                    
                                </td>
                                <td class="text-right"><%= fn(TotalRepasse) %></td>
                            </tr>
                            <%
                        end if

                    elseif instr(Liquidacao, "C")>0 then
                        TLiq = "C"
                        idLiq = replace(Liquidacao, "C", "")
                        set m = db.execute("select m.* from sys_financialmovement m WHERE m.id="& idLiq)
                        if not m.eof then
                            Link = "<a class='btn btn-xs' href='javascript:repassesCredito("& idLiq &")'><i class='far fa-search m5'></i> Detalhes</a>"
                            cl = cl+1
                            Valor = m("Value")
                            Conta = accountName(m("AccountAssociationIDDebit"), m("AccountIDDebit"))
                            DataPagto = m("Date")
                            SaldoFinal = SaldoFinal + Valor

                                'response.write("select ifnull(sum(ValorRepasse), 0) TotalRepasse from cliniccentral.temp_repasses where idBruto='"& TLiq & idLiq &"' and sysUser="& session("User"))
                            set soma = db.execute("select ifnull(sum(ValorRepasse), 0) TotalRepasse from cliniccentral.temp_repasses where idBruto='"& TLiq & idLiq &"' and sysUser="& session("User"))
                            TotalRepasse = ccur(soma("TotalRepasse"))
                            Pendente = Pendente - TotalRepasse
                            %>
                            <tr>
                                <td class="pl30"><%= " Crédito de R$ "& fn(Valor) &" gerado para abatimento" %> <%= marcar(TLiq&idLiq, Link, "warning") %>
                                    
                                </td>
                                <td class="text-right"><%= fn(TotalRepasse) %></td>
                            </tr>
                            <%
                        end if
                    end if
                next

                Link = ""
                %>
                <tr>
                    <td class="pl30">Pendente do profissional para a clínica <%= marcar("IIII", Link, "danger") %></td>
                    <td class="text-right"><%= fn(Pendente) %></td>
                </tr>
            <% end if %>


                <tr id="resumonormal">
                    <th>Repasses da clínica para o profissional </th>
                    <th class="text-right"><%= fn(TotalRepasseN) %></th>
                </tr>
                <%
                Pendente = TotalRepasseN
                splLiq = split(LiqEnvolvidasN, "||")
                SaldoFinal = 0
                cl = 0
                for i=0 to ubound(splLiq)
                    Liquidacao = replace(splLiq(i), "|", "")
                    TLiq = "P"
                    idLiq = replace(Liquidacao, "P", "")


                    set soma = db.execute("select ifnull(sum(ValorRepasse), 0) TotalRepasse from cliniccentral.temp_repasses where idBruto='"& TLiq & idLiq &"' and sysUser="& session("User"))
                    TotalRepasse = ccur(soma("TotalRepasse"))
                    Pendente = Pendente - TotalRepasse
                    set ii = db.execute("select * from itensinvoice ii where id="& idLiq)
                    if not ii.eof then
                        TotalPagtos = 0
                        ValorDespesa = ccur(ii("Quantidade")*(ii("ValorUnitario")+ii("Acrescimo")-ii("Desconto")))
                        Link = "<a class='btn btn-xs' href='./?P=Invoice&I="& ii("InvoiceID") &"&Pers=1' target='_blank'><i class='far fa-external-link m5'></i> Detalhes</a>"
                        Descricao = " Fatura de R$ "& fn(ValorDespesa) &", sendo "
                        set idesc = db.execute("select idesc.*, ii.InvoiceID, m.AccountAssociationIDDebit, m.AccountIDDebit, m.Date DataPagto from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN sys_financialmovement m ON m.id=idesc.PagamentoID where idesc.ItemID="& idLiq)
                        while not idesc.eof
                            TotalPagtos = TotalPagtos + idesc("Valor")
                            Descricao = Descricao & " &raquo; R$ "& fn(idesc("Valor")) &" em "& idesc("DataPagto")
                        idesc.movenext
                        wend
                        idesc.close
                        set idesc=nothing

                        if (TotalPagtos+0.03)<ValorDespesa then
                            Descricao = Descricao & " &raquo;<code> R$ "& fn(ValorDespesa - TotalPagtos) &" em aberto</code>"
                        end if
                        %>
                        <tr>
                            <td class="pl30">
                                <%= Descricao %> <%= marcar(TLiq&idLiq, Link, "system") %>
                            </td>
                            <td class="text-right"><%= fn(TotalRepasse) %></td>
                        </tr>
                        <%
                    end if
                next

                Link = ""
                %>
                <tr>
                    <td class="pl30">Pendente da clínica para o profissional <%= marcar("NNNN", Link, "dark") %></td>
                    <td class="text-right"><%= fn(Pendente) %> </td>
                </tr>
        </table>






        <%
        if LiqEnvolvidas<>"" then
            %>
            <h4>Liquidações Relacionadas</h4>
            <table class="table table-condensed table-bordered table-hover">
                <thead>
                    <tr>
                        <th>Data</th>
                        <th>Descrição</th>
                        <th>Forma</th>
                        <th>Conta</th>
                        <th>Valor</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
                <tfoot class="hidden">
                    <tr>
                        <td colspan="3"><%= cl %> lançamento(s)</td>
                        <td class="text-right"><%= fn(SaldoFinal) %></td>
                    </tr>
                </tfoot>
            </table>
            <%
        end if
	pP.moveNext
	wend
	pP.close
	set pP=nothing


end if%>
<hr class="short alt" />

Total: R$ <%= fn(granTotal) %> <br />
Repasses: R$ <%= fn(granTotalRepasseN) %> <br />


<!--#include file="disconnect.asp"-->
<script type="text/javascript">
function repassesCredito(I){
    /*$("#modal-table").modal("show");
    $.get("repassesCredito.asp?I="+I, function(data){
        $("#modal").html(data);
    });*/
    window.open("PrintStatement.asp?R=repassesCredito&I="+I,'targetWindow', 'toolbar=no, location=no, status=no, menubar=no, scrollbars=yes, resizable=yes, width=900, height=700');
}

function hoverIDBruto(ib, io, mc){
    if(io==true){
        $("."+ib).addClass( mc );
        //alert( $("."+ib).html() );
    }
    if(io==false){
        $("."+ib).removeClass( mc );
    }
    }

    $("#resumo tr").on('mouseenter', function () {
        $(this).find(".btnsHV").fadeIn();
    });
    $("#resumo tr").on('mouseleave', function () {
        $(this).find(".btnsHV").fadeOut();
    });

<!--#include file="JQueryFunctions.asp"-->
</script>
