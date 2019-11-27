<!--#include file="connect.asp"-->

<%

Operacao = ref("O")
I = req("I")
ProcedimentoID = ref("ProcedimentoID")
ValorReembolso = ref("ValorReembolso")
ConvenioID = ref("ConvenioID")
PlanoID = ref("PlanoID")
PacienteID = ref("PacienteID")
ProcedimentoID = ref("ProcedimentoID")

function consultaValorReembolso(Procedimento)
    sqlConvenio = "SELECT proc.NomeProcedimento, "&_
   " COALESCE(tvp.QuantidadeCH, tv.QuantidadeCH, proc.CH) QtdCH FROM convenios c "&_
   " INNER JOIN procedimentos proc ON proc.id="& treatvalzero(ProcedimentoID)&_
   " LEFT JOIN tissprocedimentosvalores tv ON tv.ProcedimentoID=proc.id AND tv.ConvenioID =c.id "&_
   " LEFT JOIN tissprocedimentosvaloresplanos tvp ON tvp.AssociacaoID=tv.id AND tvp.PlanoID="&treatvalzero(PlanoID)&_
   " WHERE c.id="&treatvalzero(ConvenioID)&" "

    set ProcedimentoSQL = db.execute(sqlConvenio)
    if not ProcedimentoSQL.eof then
        QuantidadeCH = ProcedimentoSQL("QtdCH")
    end if

    if QuantidadeCH&""<> "" then
        sqlReembolso= "SELECT * FROM convenio_reembolso WHERE ConvenioID="&treatvalnull(ConvenioID)&" AND (PlanoID="&treatvalnull(PlanoID)&" or PlanoID is null) AND PacienteID="&treatvalnull(PacienteID)&" ORDER BY id DESC"


        ValorCH = ref("ValorCH")
        set ConvenioReembolsoSQL = db.execute(sqlReembolso)
        if not ConvenioReembolsoSQL.eof then
            ValorCH = ConvenioReembolsoSQL("ValorCH")
        end if

        if ValorCH<>"" then
            ValorReembolso = QuantidadeCH * ValorCH
            consultaValorReembolso=ValorReembolso
        else
            consultaValorReembolso=0
        end if
    else
        consultaValorReembolso=0
    end if

end function

select case Operacao
    case "RecalcularItens"
        InvoiceID= ref("InvoiceID")
        set ItensSQL = db.execute("SELECT id, ItemID, ValorUnitario, Quantidade FROM itensinvoice WHERE InvoiceID="&InvoiceID)

        ValorTotal = 0

        while not ItensSQL.eof
            ItemID=ItensSQL("id")
            ProcedimentoID=ItensSQL("ItemID")
            valorRecalculado = consultaValorReembolso(ProcedimentoID)

            Valor = ItensSQL("ValorUnitario")

            if valorRecalculado > 0 then
                valorNoDesconto = Valor - valorRecalculado

                if not isnull(valorNoDesconto) then
                    ValorNoDesconto = ccur(valorNoDesconto)

                    if ValorNoDesconto > 0 then

                        if ValorNoDesconto<0 or ValorNoDesconto > Valor then
                            ValorNoDesconto=0
                        end if

                        set ProcedimentoSQL = db.execute("SELECT Valor FROM procedimentos WHERE id="&treatvalzero(ProcedimentoID))

                        if not ProcedimentoSQL.eof then
                            db.execute("UPDATE itensinvoice SET Desconto="&treatvalzero(ValorNoDesconto)&", Acrescimo=0 WHERE id="&ItemID&" AND InvoiceID="&InvoiceID)


                            ValorTotal = ValorTotal + valorRecalculado
                        end if
                    else
                        db.execute("UPDATE itensinvoice SET Desconto=0 WHERE id="&ItemID&" AND InvoiceID="&InvoiceID)
                    end if
                end if
            end if



        ItensSQL.movenext
        wend
        ItensSQL.close
        set ItensSQL=nothing

        db.execute("UPDATE sys_financialmovement SET Value="&treatvalzero(ValorTotal)&" WHERE InvoiceID="&InvoiceID&" AND CD='C' AND Type='Bill'")
        db.execute("UPDATE sys_financialinvoices SET Value="&treatvalzero(ValorTotal)&" WHERE id="&InvoiceID&" AND CD='C'")

    case "ConsultarValorParticular"
        set ProcedimentoSQL = db.execute("SELECT Valor FROM procedimentos WHERE id="&ProcedimentoID)
        if not ProcedimentoSQL.eof then
            Valor = ProcedimentoSQL("Valor")
            %>
            $(".valor-reembolso").html("Valor do particular: R$ <%=fn(Valor)%>");
            <%
        end if
    case "SalvaValorReembolso"
        ValorCH = 0
        sqlConvenio = "SELECT proc.NomeProcedimento, c.Telefone, c.Contato, COALESCE(tvp.ValorCH, tv.ValorCH,  c.ValorCH) ValorCH, "&_
                       " COALESCE(tvp.QuantidadeCH, tv.QuantidadeCH, proc.CH) QtdCH FROM convenios c "&_
                       " INNER JOIN tissprocedimentosvalores tv ON tv.ConvenioID =c.id "&_
                       " INNER JOIN procedimentos proc ON proc.id=tv.ProcedimentoID "&_
                       " LEFT JOIN tissprocedimentosvaloresplanos tvp ON tvp.AssociacaoID=tv.id AND tvp.PlanoID="&treatvalzero(PlanoID)&_
                       " WHERE c.id="&treatvalzero(ConvenioID)&" AND tv.ProcedimentoID="&treatvalzero(ProcedimentoID)


        set ProcedimentoSQL = db.execute(sqlConvenio)
        if not ProcedimentoSQL.eof then
            QuantidadeCH = ProcedimentoSQL("QtdCH")
        end if

        if not isnumeric(QuantidadeCH) then
            %>
            showMessageDialog("Preencha a quantidade de CH para o cálculo de reembolso", "warning", "Procedimento (<%=ProcedimentoSQL("NomeProcedimento")%>) sem CH configurado");
            <%
        end if

        if isnumeric(QuantidadeCH) and isnumeric(ValorReembolso) and ConvenioID<>"" then
            ValorCH = replace(replace((ValorReembolso) / (QuantidadeCH), ".", ""),",",".")

            sql = "SELECT * FROM convenio_reembolso WHERE ConvenioID="&treatvalnull(ConvenioID)&" AND PlanoID="&treatvalnull(PlanoID)&" AND PacienteID="&PacienteID&" AND ValorCH='"&ValorCH&"' ORDER BY id DESC"
            set ValorJaExisteSQL = db.execute(sql)

            if ValorJaExisteSQL.eof then


                sqlInsert = "INSERT INTO convenio_reembolso (ConvenioID, PlanoID, PacienteID, ValorCH, DataConsulta, ProcedimentoID, ValorReembolso, sysUser) VALUES "&_
                                    "("&treatvalnull(ConvenioID)&","&treatvalnull(PlanoID)&","&treatvalnull(PacienteID)&","&ValorCH&",CURDATE(),"&treatvalnull(ProcedimentoID)&","&treatvalnull(ValorReembolso)&", "&session("User")&") "

                db.execute(sqlInsert)

                %>
                $("#ValorCH").val("<%=fn(ValorCH)&"00"%>");
                showMessageDialog("Valor do CH (<%=ValorCH  %>) salvo.", "success");
                <%
            end if
        end if

end select

if I<>"" then
select case Operacao
case "PacienteID"
    set PacienteSQL = db.execute("SELECT pac.Nascimento, pac.Sexo, pac.sysDate, pac.Tabela, pac.ConvenioID1, pac.PlanoID1  FROM pacientes pac WHERE pac.id="&I)

    if not PacienteSQL.eof then
        TabelaID = PacienteSQL("Tabela")
        ConvenioID = PacienteSQL("ConvenioID1")
        PlanoID = PacienteSQL("PlanoID1")

        sqlReembolso = "SELECT * FROM convenio_reembolso WHERE PacienteID="&PacienteID&" ORDER BY id DESC"
        set ConvenioReembolsoSQL = db.execute(sqlReembolso)

        if not ConvenioReembolsoSQL.eof then
            ConvenioID=ConvenioReembolsoSQL("ConvenioID")
            PlanoID=ConvenioReembolsoSQL("PlanoID")

            %>

                $("#ValorCH").val("<%=fn(ConvenioReembolsoSQL("ValorCH"))%>");
            <%
        end if


        if TabelaID&""<>"" then
            %>
            $("#TabelaID").val("<%=TabelaID%>").change();
            <%
        end if

        if ConvenioID&""<>"" then
            set ConvenioSQL = db.execute("SELECT NomeConvenio FROM convenios WHERE id="&ConvenioID)
            if not ConvenioSQL.eof then
                NomeConvenio = ConvenioSQL("NomeConvenio")
            end if
            %>
            PlanoPacienteID='<%=PlanoID%>';
            $("#ConvenioID").html("<option value='<%=ConvenioID%>'><%=NomeConvenio%></option>").change();
            <%
            if PlanoID&""="" or PlanoID=0 then
                %>
                $("#PlanoID").html("").change();
                <%
            end if
        else
            %>
            $("#ConvenioID").html("").change();
            $("#PlanoID").html("").change();
            $("#ValorCH").val("");
            $(".valor-sugerido-ch").html("");
            <%
        end if
    end if
case "SugereValorCH"
    sqlConvenio = "SELECT c.Telefone, c.Contato, COALESCE(tvp.ValorCH, tv.ValorCH,  c.ValorCH) ValorCH, "&_
                       " COALESCE(tvp.QuantidadeCH, tv.QuantidadeCH, proc.CH) QtdCH FROM convenios c "&_
                       " INNER JOIN procedimentos proc ON proc.id="&treatvalzero(ProcedimentoID)&_
                       " LEFT JOIN tissprocedimentosvalores tv ON tv.ProcedimentoID=proc.id AND tv.ConvenioID =c.id "&_
                       " LEFT JOIN tissprocedimentosvaloresplanos tvp ON tvp.AssociacaoID=tv.id AND tvp.PlanoID="&treatvalzero(PlanoID)&_
                       " WHERE c.id="&treatvalzero(I)

    set ConvenioSQL = db.execute(sqlConvenio)

    if not ConvenioSQL.eof then
        %>
        $(".valor-por-ch").html("R$ <%=fn(ConvenioSQL("ValorCH"))%>");
        $(".telefone-contato-convenio").html("Telefone: <%=ConvenioSQL("Telefone")%>");
        <%
    end if
end select
end if

%>