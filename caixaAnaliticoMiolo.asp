<style>
@media print {



    .table {
    display: table;
    border-spacing: 2px;
}

    body{font-size:10px;}

    *{font-size: 9px !important;}
    .printf{ width:330px !important;  display: block;}
    .col-xs-5{width:35% !important}
    .dataTables_paginate, .dataTables_info, .dataTables_length{display:none;}
}
</style>
<div class="row">
    <div class="col-md-12">
        <table class="table table-bordered table-condensed table-hover relatorio-tabela">
            <thead>
                <tr>
                    <th width="5%">Data</th>
                    <th width="7%">Prontuário</th>
                    <th width="15%">Paciente</th>
                    <th class="printf">
                        <div class="row">
                            <div class="col-xs-5">Procedimento</div>
                            <div class="col-xs-5">Profissional</div>
                            <div class="col-xs-2">Descrição</div>
                        </div>
                    </th>
                    <th width="10%">Pagamento</th>
                    <th width="10%">Conta</th>
                    <th width="10%">Valor</th>
                </tr>
            </thead>
            <tbody>
            <%
            response.Buffer

            if instr(req("Procedimentos"), "|ONLY|")>0 then
                onlyProcs = replace(replace(req("Procedimentos"), "|ONLY|", "-1"), "|", "")
                sqlProcsII = " AND ii.ItemID IN ("& onlyProcs &") "
                sqlProcsAP = " AND ap.ProcedimentoID IN ("& onlyProcs &") "
            end if


            if instr(req("Procedimentos"), "|EXCEPT|")>0 then
                exceptProcs = replace(replace(req("Procedimentos"), "|EXCEPT|", "-1"), "|", "")
                sqlExceptProcsII = " AND NOT ii.ItemID IN ("& exceptProcs &") "
                sqlExceptProcsAP = " AND NOT ap.ProcedimentoID IN ("& exceptProcs &") "
            end if
            if req("DEBUG")="1" then
                response.write(session("Banco") &": "& sql)
            end if
            set inv = db.execute( sql )
            while not inv.eof
                response.flush()
                valDesc = 0
                Forma = "0"
                NomeForma = ""
                PMID = inv("PaymentMethodID")
                Valor = inv("Value")
                parcs = ""
                if PMID=8 then
                    set trans = db.execute("select parcelas from sys_financialcreditcardtransaction where MovementID="& inv("id") )
                    if not trans.eof then
                        parcs = trans("Parcelas")&"x &nbsp;"
                    end if
                    parcs = trans("Parcelas")&"x &nbsp;"
                end if

                OcultaProf = 1
                OcultaProc = 1
                %>
                <tr id="m<%=inv("id") %>">
                    <td class="text-right"><%=left(inv("Date"),5) %></td>
                    <td class="text-right"><%=zeroEsq(inv("Prontuario"), 8) %></td>
                    <td nowrap><a style="color:#000" target="_blank" href="./?P=Pacientes&Pers=1&I=<%=inv("PacienteID") %>&Ct=1"><%=left(inv("NomePaciente"),30) %></a></td>
                    <td>
                        <%
                        GrupoID = ""
                        if req("GrupoProcedimentos")<>"" then
                            GrupoID = req("GrupoProcedimentos")
                        end if
                        set idesc = db.execute("select idesc.Valor, ii.Quantidade, proc.id ProcedimentoID, proc.GrupoID, IFNULL(proc.NomeProcedimento, '<em>Procedimento excluído</em>') NomeProcedimento, ii.ProfissionalID, prof.NomeProfissional NomeProfissional5, profx.NomeProfissional NomeProfissional8, ii.Associacao, ii.Executado, ii.Descricao from itensdescontados idesc LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID LEFT JOIN profissionais prof ON prof.id=ii.ProfissionalID LEFT JOIN profissionalexterno profx ON profx.id=ii.ProfissionalID WHERE ii.Tipo='S' AND  idesc.PagamentoID="& inv("id"))
                        while not idesc.eof

                            Quantidade = idesc("Quantidade")
                            if Quantidade>1 then
                                strQtd = Quantidade & "x "
                            else
                                strQtd = ""
                            end if
                            Associacao = idesc("Associacao")
                            ProfissionalIDii = idesc("ProfissionalID")
                            ProcedimentoID = idesc("ProcedimentoID")
                            if idesc("Executado")="S" then
                                if (Associacao=5 or Associacao=8) then
                                    NomeProfissional = idesc("NomeProfissional" & Associacao)
                                else
                                    NomeProfissional = ""
                                end if
                            else
                                NomeProfissional = "<em>Não executado</em>"
                            end if
                            %>
                            <div class="row">
                                <div class="col-xs-5"><%= strQtd & idesc("NomeProcedimento") %> <%'= fn(idesc("Valor")) %></div>
                                <div class="col-xs-5"><%= NomeProfissional %></div>
                                <div class="col-xs-2"><%= idesc("Descricao") %></div>
                            </div>
                            <%
                            if (instr(req("ProfissionalID"), "|"&ProfissionalIDii&"|")>0 AND Associacao=5) OR (instr(req("ProfissionalExtID"), "|"&ProfissionalIDii&"|")>0 AND Associacao=8) OR ( idesc("Executado")="" and  instr(req("ProfissionalID"), "|-1|")) then
                                OcultaProf = 0
                            end if
                            if (instr(req("Procedimentos"), "|ALL|")>0) OR (instr(req("Procedimentos"), "|"&ProcedimentoID&"|")>0 AND instr(req("Procedimentos"), "|ONLY|")>0) OR (instr(req("Procedimentos"), "|"&ProcedimentoID&"|")=0 AND instr(req("Procedimentos"), "|EXCEPT|")>0) then
                                OcultaProc = 0
                            end if
                            if GrupoID<>"" then
                                if not isnull(idesc("GrupoID")) and idesc("GrupoID")<>"" then
                                    if cstr(idesc("GrupoID"))<>GrupoID then
                                        OcultaProc = 1
                                    end if
                                else
                                    OcultaProc = 1
                                end if
                            end if
                        idesc.movenext
                        wend
                        idesc.close
                        set idesc=nothing
                        %>
                    </td>
                    <td nowrap style="padding:0"><%= parcs & inv("PaymentMethod") %></td>
                    <td><%= left(accountName(inv("AccountAssociationIDDebit"), inv("AccountIDDebit"))&"", 20) %></td>
                    <td class="text-right"><%=fn( Valor ) %></td>
                </tr>
                <%
                if OcultaProf=1 or OcultaProc=1 then
                    %>
                    <script>
                        $("#m<%= inv("id") %>").css("display", "none");
                    </script>
                    <%
                else
                    if PMID=1 then
                        Dinheiro = Dinheiro + Valor
                    elseif PMID=2 then
                        Cheque = Cheque + Valor
                    elseif PMID=3 or PMID=5 or PMID=6 or PMID=7 then
                        Transferencia = Transferencia + Valor
                    elseif PMID=8 then
                        set trans = db.execute("select parcelas from sys_financialcreditcardtransaction where MovementID="& inv("id") )
                        if not trans.eof then
                            parcs = trans("Parcelas")&"x &nbsp;"
                        end if
                        parcs = trans("Parcelas")&"x &nbsp;"
                        Credito = Credito + Valor
                    elseif PMID=9 then
                        Debito = Debito + Valor
                    elseif PMID=15 then
                        Pix = Pix + Valor
                    end if

                end if
            inv.movenext
            wend
            inv.close
            set inv=nothing
            %>
            </tbody>
        </table>
    </div>
</div>