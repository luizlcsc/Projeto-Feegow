<!--#include file="connect.asp"-->

<% server.execute("preXML.asp") %>

<%
function updateTabelaProcedimentos(tabelaGuia, tabelaId, codigo, valor, GuiaId, motivoGlosa, codigoGlosa)
    if codigo&"" <> "" then
        sqlUpdateTabela = "UPDATE `"&tabelaGuia&"` SET ValorPago= COALESCE(ValorPago,IFNULL('"&valor&"' * IFNULL(CAST(Quantidade AS UNSIGNED),1),0)), "&_
                            "motivoGlosa='"&motivoGlosa&"', CodigoGlosa="&treatvalnull(codigoGlosa)&" "&_
                            "WHERE  CodigoProcedimento = '"&codigo&"' and Quantidade=1 AND GuiaID = "&GuiaID

        db.execute(sqlUpdateTabela)
    end if
end function

function updateGuiaSemGlosa(GuiaId, tabelaGuia)
    if GuiaID&"" <> "" and tabelaGuia&"" <> "" then
        'atualiza procedimento
        set procedimentos = db.execute("SELECT id, ValorTotal FROM "&pguias("TabelaProcedimentos")&" WHERE GuiaID = "&pguias("id")&"")
        while not procedimentos.eof
            valorTotalProc = treatvalzero(procedimentos("ValorTotal"))

            sqlProcSemGlosa = "UPDATE "&pguias("TabelaProcedimentos")&" SET ValorPago = NULLIF("&valorTotalProc&",'') WHERE id = "&procedimentos("id")

            set UpdateProcSemGlosa = db.execute(sqlProcSemGlosa)
        procedimentos.movenext
        wend
        procedimentos.close
        set procedimentos = nothing

        'atualiza despesas anexas
        set despesas = db.execute("SELECT * FROM tissguiaanexa WHERE GuiaID = "&pguias("id")&"")
        while not despesas.eof
            valorTotal = treatvalzero(despesas("ValorTotal"))

            SqlSemGlosa = "UPDATE tissguiaanexa SET ValorPago=NULLIF("&valorTotal&",'') WHERE id = "&despesas("id")

            set UpdateSemGlosa = db.execute(SqlSemGlosa)
        despesas.movenext
        wend
        despesas.close
        set despesas = nothing
    end if
end function

function UpdateGuiaComGlosa(codigoItem, tipoTabela, valorProcessado, valorLiberado, tipoGlosa, GuiaID)
    if codigoItem&"" <> "" then
        'pega o id e o motivo da glosa
        idGlosa = ""
        motivoGlosa = ""
        if tipoGlosa <> "" then
            set infoGlosa = db.execute("SELECT * FROM cliniccentral.tabelaglosas WHERE Codigo = "&tipoGlosa)
            if not infoGlosa.eof then
                idGlosa = infoGlosa("id")
                motivoGlosa = infoGlosa("Descricao")
            end if
        end if
        'verifica o tipo da tabela e realiza o update de acordo
        if tipoTabela = 22 then
            sqlUpdateTabela = "UPDATE `tissprocedimentossadt` SET ValorPago= COALESCE(ValorPago,IFNULL("&treatvalzero(valorLiberado)&" * IFNULL(CAST(Quantidade AS UNSIGNED),1),0)), "&_
                            "motivoGlosa='"&tipoGlosa&"', CodigoGlosa='|"&idGlosa&"|' "&_
                            "WHERE  CodigoProcedimento = '"&codigoItem&"' AND GuiaID = "&GuiaID
            db.execute(sqlUpdateTabela)
        else
            sqlUpdateTabela = "UPDATE tissguiaanexa SET ValorPago=NULLIF("&treatvalzero(valorLiberado)&",''), motivoGlosa="&idGlosa&" WHERE GuiaID = "&GuiaID&" AND CodigoProduto = "&codigoItem
            db.execute(sqlUpdateTabela)
        end if
    end if
end function

function updateGuiaSemGlosa(GuiaId, tabelaGuia)
    if GuiaID&"" <> "" and tabelaGuia&"" <> "" then
        'atualiza procedimento
        set procedimentos = db.execute("SELECT id, ValorTotal FROM "&pguias("TabelaProcedimentos")&" WHERE GuiaID = "&pguias("id")&"")
        while not procedimentos.eof
            valorTotalProc = replace(procedimentos("ValorTotal"),",",".")

            sqlProcSemGlosa = "UPDATE "&pguias("TabelaProcedimentos")&" SET ValorPago = NULLIF('"&valorTotalProc&"','') WHERE id = "&procedimentos("id")

            set UpdateProcSemGlosa = db.execute(sqlProcSemGlosa)
        procedimentos.movenext
        wend
        procedimentos.close
        set procedimentos = nothing

        'atualiza despesas anexas
        set despesas = db.execute("SELECT * FROM tissguiaanexa WHERE GuiaID = "&pguias("id")&"")
        while not despesas.eof
            valorTotal = replace(despesas("ValorTotal"),",",".")

            SqlSemGlosa = "UPDATE tissguiaanexa SET ValorPago=NULLIF('"&valorTotal&"','') WHERE id = "&despesas("id")

            set UpdateSemGlosa = db.execute(SqlSemGlosa)
        despesas.movenext
        wend
        despesas.close
        set despesas = nothing
    end if
end function

function UpdateGuiaComGlosa(codigoItem, tipoTabela, valorProcessado, valorLiberado, tipoGlosa, GuiaID)
    if codigoItem&"" <> "" then
        'pega o id e o motivo da glosa
        idGlosa = ""
        motivoGlosa = ""
        if tipoGlosa <> "" then
            set infoGlosa = db.execute("SELECT * FROM cliniccentral.tabelaglosas WHERE Codigo = "&tipoGlosa)
            if not infoGlosa.eof then
                idGlosa = infoGlosa("id")
                motivoGlosa = infoGlosa("Descricao")
            end if
        end if
        'verifica o tipo da tabela e realiza o update de acordo
        if tipoTabela = 22 then
            sqlUpdateTabela = "UPDATE `tissprocedimentossadt` SET ValorPago= COALESCE(ValorPago,IFNULL('"&valorLiberado&"' * IFNULL(CAST(Quantidade AS UNSIGNED),1),0)), "&_
                            "motivoGlosa='"&tipoGlosa&"', CodigoGlosa='|"&idGlosa&"|' "&_
                            "WHERE  CodigoProcedimento = '"&codigoItem&"' AND GuiaID = "&GuiaID
            db.execute(sqlUpdateTabela)
        else
            sqlUpdateTabela = "UPDATE tissguiaanexa SET ValorPago=NULLIF('"&valorLiberado&"',''), CodigoGlosa='|"&idGlosa&"|', motivoGlosa="&tipoGlosa&" WHERE GuiaID = "&GuiaID&" AND CodigoProduto = "&codigoItem
            db.execute(sqlUpdateTabela)
        end if
    end if
end function
%>

<div class="panel">
    <div class="panel-body">
        <div class="row">
            <div class="col-md-6">
<%
            function vbrl(val)
                vbrl = replace(val&"", ".", ",")
                if isnumeric(vbrl) and vbrl<>"" then
                    vbrl = ccur(vbrl)
                else
                    vbrl = 0
                end if
            end function

            if req("Last")="1" then
                set plast = db.execute("select * from retornoxml where sysUser="& session("User") &" order by id desc")
                Arquivo = plast("Arquivo")
            else
                Arquivo = req("F") &".xml"
            end if

            Set objXML = Server.CreateObject("Microsoft.XMLDOM")
            objXML.load("C:\inetpub\wwwroot\v7\xml-retorno\"& Arquivo)

            if objXML.getElementsByTagName("ansTISS:registroANS").length>0 then
                tipoTransacao = objXML.getElementsByTagName("ansTISS:tipoTransacao")(0).text
                registroANS = objXML.getElementsByTagName("ansTISS:registroANS")(0).text
                versaoPadrao = objXML.getElementsByTagName("ansTISS:versaoPadrao")(0).text
                Set contas = objXML.getElementsByTagName("ansTISS:demonstrativoAnaliseConta")
                Tamanho = contas.length
            end if
            if objXML.getElementsByTagName("ans:registroANS").length>0 and objXML.getElementsByTagName("ans:versaoPadrao").length>0 then
                tipoTransacao = objXML.getElementsByTagName("ans:tipoTransacao")(0).text
                registroANS = objXML.getElementsByTagName("ans:registroANS")(0).text
                versaoPadrao = objXML.getElementsByTagName("ans:versaoPadrao")(0).text
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                Tamanho = contas.length
            end if
            if objXML.getElementsByTagName("ans:registroANS").length>0 and objXML.getElementsByTagName("ans:Padrao").length>0 then
                tipoTransacao = objXML.getElementsByTagName("ans:tipoTransacao")(0).text
                registroANS = objXML.getElementsByTagName("ans:registroANS")(0).text
                versaoPadrao = objXML.getElementsByTagName("ans:Padrao")(0).text
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                Tamanho = contas.length
            end if

            response.write("Tipo transação: "& tipoTransacao &"<br> Registro ANS: "& registroANS &"<br> Versão: "& versaoPadrao &"<br> Contas: "& Tamanho)
            set regs = objXML.getElementsByTagName("ans:cabecalhoDemonstrativo")


            for each reg in regs
                if reg.getElementsByTagName("ans:registroANS").length>0 then
                    Dim registro: registro = reg.getElementsByTagName("ans:registroANS")(0).text
                    if len(registro)=6 then
                        registrosANS = registrosANS & ", '"& registro &"'"
                    end if
                end if
            next

            if registrosANS<>"" then
                registrosANS = "'"& registroANS &"'"& registrosANS
            else
                registrosANS = "'"& registroANS &"'"
            end if
            
            sqlConv = "select id from convenios where registroANS IN ("& registrosANS &")"
            'response.write( sqlConv )
            set conv = db.execute( sqlConv )
            while not conv.eof
                ConvenioID = ConvenioID & ", "& conv("id")
            conv.movenext
            wend
            conv.close
            set conv = nothing

            if ConvenioID <>"" then
                ConvenioID = right(ConvenioID, len(ConvenioID)-2)
            end if

            function strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, NumeroGuiaPrestador)

                resultado = ""
                acaoFinanceiro = ""
                checkFinanceiro = ""
                valorLiberadoGuia = vbrl(valorLiberadoGuia)

                sql = "select * from (select id, 'tissguiaconsulta' Tabela, null TabelaProcedimentos, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                " UNION ALL select id, 'tissguiasadt', 'tissprocedimentossadt' TabelaProcedimentos, ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                " UNION ALL select id, 'tissguiahonorarios', 'tissprocedimentoshonorarios' TabelaProcedimentos, ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                " ) t"
              '  response.write( sql )
                set pguia = db.execute( sql )
                if pguia.eof then
                    strGuia = "<a class='btn btn-xs btn-danger'>GUIA NÃO ENCONTRADA</a>"
                else
                    tipoguia = replace(pguia("Tabela")&"", "tiss", "")
                    strGuia = "<a href='./?P="& pguia("Tabela") &"&I="&pguia("id")&"&Pers=1' target='_blank' class='btn btn-xs btn-success'>GUIA ENCONTRADA</a>"
                    set vcaFin = db.execute("select * from tissguiasinvoice where GuiaID="& pguia("id") &" and TipoGuia='"& tipoguia &"'")
                    if vcaFin.eof then
                        acaoFinanceiro = "Lançar"
                        checkFinanceiro = "<input type='checkbox' name='lancar' value='"& tipoguia &"|"& pguia("id") &"|"& fn(valorLiberadoGuia) &"' onclick='lFin();'>"
                    else
                        acaoFinanceiro = "Lançado"
                        set nf = db.execute("select nroNFe from sys_financialinvoices where id="& vcaFin("InvoiceID") &"")
                        if not nf.eof then
                            acaoFinanceiro = "<a href='./?P=Invoice&Pers=1&CD=C&I="& vcaFin("InvoiceID") &"' class='btn btn-xs' target='_blank'>Lançado - NF: "& nf("nroNFe") &"</a>"
                        end if
                    end if
                end if


                valorInformadoGuia = vbrl(valorInformadoGuia)
                valorGlosaGuia = vbrl(valorGlosaGuia)
                update = 0
                Glosado = 0


                if not pguia.eof then
                    valorPagoBD = ccur(pguia("ValorPago"))

                    if valorPagoBD=0 then
                        if valorGlosaGuia=0 and valorInformadoGuia=valorLiberadoGuia then
                            resultado = "<small class='label label-sm label-success'>INTEGRALMENTE PAGA</small>"
                            'colocar glosado 0 e pago o valor total com status de paga (10)
                            update = 1
                            statusGuia = 10
                        elseif valorGlosaGuia>0 and valorLiberadoGuia>0 then
                            resultado = "<small class='label label-sm label-warning'>PARCIALMENTE PAGA</small>"
                            '(11)
                            update = 1
                            statusGuia = 11
                        elseif valorInformadoGuia=valorGlosaGuia then
                            resultado = "<small class='label label-sm label-danger'>GUIA GLOSADA</small>"
                            acaoFinanceiro = "Glosada"
                            checkFinanceiro = ""
                            '(8)
                            statusGuia = 8
                            update = 1
                            Glosado = 1
                        end if
                    else
                        resultado = "<small class='label label-sm label-default'>PRÉ-BAIXADO - Nada alterado</small>"
                    end if
                end if

                if update then
                    db.execute("update "& pguia("Tabela") &" set ValorPago="& treatvalzero(valorLiberadoGuia) &", GuiaStatus="& statusGuia &", Glosado ="&treatvalzero(valorGlosaGuia)&" where id="& pguia("id"))
                    if not isnull(pguia("TabelaProcedimentos")) then
                        'atualiza o procedimento sadt
                        'db_execute("update "& pguia("TabelaProcedimentos") &" set ValorPago="& treatvalzero(valorLiberadoGuia) &" where GuiaID="& pguia("id"))

                    end if
                end if




                strGuia = "<tr>"&_ 
                            "<td>"& checkFinanceiro &"</td>"&_ 
                            "<td>"& acaoFinanceiro &"</td>"&_ 
                            "<td>"& NumeroGuiaPrestador &"</td>"&_ 
                            "<td>"& numeroCarteira &"</td>"&_
                            "<td class='text-right'>"& fn(valorInformadoGuia) &"</td>"&_
                            "<td class='text-right'>"& fn(valorPagoBD) &"</td>"&_
                            "<td class='text-right'>"& fn(valorLiberadoGuia) &"<input type='hidden' name='liberado' class='liberado'></td>"&_
                            "<td class='text-right'>"& fn(valorGlosaGuia) &"</td>"&_
                            "<td class='text-center'>"& resultado &"</td>"&_
                            "<td>"& strGuia &"</td>"&_
                          "</tr>"
            end function

            if ConvenioID<>"" then
                set pnc = db.execute("select group_concat(NomeConvenio SEPARATOR ', ') Convenios from convenios where id IN ("& ConvenioID &")")
                if not pnc.eof then
                    response.write("<br>Convênio: " &pnc("Convenios"))
                end if
            end if
             

            %>
            </div>
            <div id="divLancar" class="col-md-6">
                
            </div>
        </div>

        <hr class="short alt" />
        <table class="table table-condensed table-hover table-bordered">
            <thead>
                <tr class="info">
                    <th width="1%">
                        <input type="checkbox" onclick="$('input[name=lancar]').prop('checked', $(this).prop('checked')); lFin();" />
                    </th>
                    <th>Financeiro</th>
                    <th>Número da Guia</th>
                    <th>Número da Carteira</th>
                    <th>Valor Informado</th>
                    <th>Valor Lib. - Anterior</th>
                    <th>Valor Lib. - XML</th>
                    <th>Valor Glosa</th>
                    <th>Resultado</th>
                    <th width="1%"></th>
                </tr>
            </thead>
            <tbody>

            <%   
            'response.write("<br> ConvenioID: "& ConvenioID &"<br>")

            'DIFERENÇAS: 
            '   1. ans / ansTISS
            '   2. Não possui numeroGuiaOperadora

            versaoPadraoEncontrada = false
            ' versaoPadraoEncontrada se não encontrar nenhuma versão sera usada a versão 3.03.03

            c = 0
            if versaoPadrao="2.01.03" then 'mediservice.xml
                versaoPadraoEncontrada= true
                for each conta in contas
                    c = c+1
                    'Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set faturas = conta.getElementsByTagName("ans:numeroFatura")
                    For Each fatura in faturas
                        'response.write("numeroFatura: "& fatura.text &"<br>")
                    Next
                    Set lotes = conta.getElementsByTagName("ans:numeroLote")
                    For Each lote in lotes
                        'response.write("numeroLote: "& lote.text &"<br>")
                    Next
                    Set guias = conta.getElementsByTagName("ans:guia")
                    For Each guia in guias
                        Dim numeroGuiaPrestador : numeroGuiaPrestador = guia.getElementsByTagName("ans:numeroGuiaPrestador")(0).text
                        Dim numeroGuiaOperadora : numeroGuiaOperadora = guia.getElementsByTagName("ans:numeroGuiaOperadora")(0).text
                        Dim numeroCarteira : numeroCarteira = guia.getElementsByTagName("ans:numeroCarteira")(0).text
                        Dim valorInformadoGuia : valorInformadoGuia = guia.getElementsByTagName("ans:valorProcessadoGuia")(0).text
                        Dim valorLiberadoGuia : valorLiberadoGuia = guia.getElementsByTagName("ans:valorLiberadoGuia")(0).text
                        Dim valorGlosaGuia : valorGlosaGuia = guia.getElementsByTagName("ans:valorGlosaGuia")(0).text
                        response.Write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                        'response.Write("numeroGuiaOperadora: "& numeroGuiaOperadora &"<br>")
                        'response.Write("numeroCarteira: "& numeroCarteira &"<br>")
                        'response.Write("valorProcessadoGuia: "& valorInformadoGuia &"<br>")
                        'response.Write("valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                        'response.Write("valorGlosaGuia: "& valorGlosaGuia &"<br>")

                        sql = "select * from (select id, 'tissguiaconsulta' Tabela, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                      " UNION ALL select id, 'tissguiasadt', ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                      " UNION ALL select id, 'tissguiahonorarios', ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                      " ) t"
                        set pguias = db.execute( sql )
        
                        set procs = guia.getElementsByTagName("ans:dadosProcedimento")
                        for each proc in procs
                            codigo = proc.getElementsByTagName("ans:codigo")(0).text
                            tipoTabela = proc.getElementsByTagName("ans:tipoTabela")(0).text
                            valorInformado = proc.getElementsByTagName("ans:valorProcessado")(0).text
                            valorLiberado = proc.getElementsByTagName("ans:valorLiberado")(0).text
                            grauParticipacao = proc.getElementsByTagName("ans:grauParticipacao")(0).text

                             IF NOT pguias.eof THEN
                                IF pguias("Tabela") = "tissguiasadt" THEN
                                    call updateTabelaProcedimentos("tissprocedimentossadt", tipoTabela, codigo, valorLiberado, pguias("id"), null, null)

                                    'sqlProcedimento = "UPDATE tissprocedimentossadt SET ValorPago=COALESCE(ValorPago,NULLIF(CAST('"&valorLiberado&"' AS UNSIGNED) * IFNULL(CAST(Quantidade AS UNSIGNED),1),'')) WHERE TabelaID = "&tipoTabela&" AND CodigoProcedimento = "&codigo&" AND GuiaID = "&pguias("id")
                                    'db.execute(sqlProcedimento)
                                END IF
                            END IF
                        next
                    Next
                next
            end if

            c = 0
            if versaoPadrao="2.02.03" then 'master1518432620286.xml
                versaoPadraoEncontrada= true

                for each conta in contas
                    c = c+1
                    'Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set faturas = conta.getElementsByTagName("ansTISS:numeroFatura")
                    'For Each fatura in faturas
                    '    response.write("numeroFatura: "& fatura.text &"<br>")
                    'Next
                    Set lotes = conta.getElementsByTagName("ansTISS:dadosLote")
                    For Each lote in lotes
                        numeroLote = lote.getElementsByTagName("ansTISS:numeroLote")(0).text

                        'set plote = db.execute("select * from tisslotes where ConvenioID="& ConvenioID &" and Lote="& numeroLote)
                        if 0 then
                            %>
                            {{{ LOTE ENCONTRADO }}}
                            <%
                        end if

                        'response.write("numeroLote: "& numeroLote &" - ConvenioID: "& ConvenioID &"<br>")
                        Set guias = lote.getElementsByTagName("ansTISS:dadosGuia")
                        For Each guia in guias
                            numeroGuiaPrestador = guia.getElementsByTagName("ansTISS:numeroGuiaPrestador")(0).text
                            numeroCarteira = guia.getElementsByTagName("ansTISS:numeroCarteira")(0).text
                            valorInformadoGuia = guia.getElementsByTagName("ansTISS:valorProcessadoGuia")(0).text
                            valorLiberadoGuia = guia.getElementsByTagName("ansTISS:valorLiberadoGuia")(0).text
                            valorGlosaGuia = guia.getElementsByTagName("ansTISS:valorGlosaGuia")(0).text

                            response.write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                            'response.Write("---> numeroGuiaPrestador: "& numeroGuiaPrestador & strGuia(ConvenioID, NumeroGuiaPrestador) &"<br>")
                            'response.Write("---> numeroCarteira: "& numeroCarteira &"<br>")
                            'response.Write("---> valorProcessadoGuia: "& valorInformadoGuia &"<br>")
                            'response.Write("---> valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                            'response.Write("---> valorGlosaGuia: "& valorGlosaGuia &"<br>")

                            sql = "select * from (select id, 'tissguiaconsulta' Tabela, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                          " UNION ALL select id, 'tissguiasadt', ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                          " UNION ALL select id, 'tissguiahonorarios', ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                                                                          " ) t"
                            set pguias = db.execute( sql )
                            set procs = guia.getElementsByTagName("ansTISS:dadosProcedimento")
                            if 1 then
                                for each proc in procs
                                    codigo = proc.getElementsByTagName("ansTISS:codigo")(0).text
                                    tipoTabela = proc.getElementsByTagName("ansTISS:tipoTabela")(0).text
                                    valorInformado = proc.getElementsByTagName("ansTISS:valorProcessado")(0).text
                                    valorLiberado = proc.getElementsByTagName("ansTISS:valorLiberado")(0).text
                                    descricao = proc.getElementsByTagName("ansTISS:descricao")(0).text
                                    grauParticipacao = proc.getElementsByTagName("ansTISS:grauParticipacao")(0).text
                                    DataRealizacao = guia.getElementsByTagName("ansTISS:dataRealizacao")(0).text


                                    IF NOT pguias.eof THEN
                                        'atualizar tabela tissguiaanexas
                                        'caso nao possua codigo = nao houve glosa
                                        IF codigo = "" then
                                            set despesas = db.execute("SELECT * FROM tissguiaanexa WHERE GuiaID = "&pguias("id")&"")
                                            while not despesas.eof
                                                valorTotal = replace(despesas("ValorTotal"),",",".")

                                                SqlSemGlosa = "UPDATE tissguiaanexa SET ValorPago=NULLIF('"&valorTotal&"','') WHERE id ="&despesas("id")

                                                set UpdateSemGlosa = db.execute(SqlSemGlosa)
                                            despesas.movenext
                                            wend
                                            despesas.close
                                            set despesas = nothing
                                        Else
                                            'PRESUME-SE QUE SE HÁ CÓDIGO HOUVE GLOSA
                                            sqlAnexa = "SELECT * FROM tissguiaanexa ta WHERE ta.GuiaID= "&pguias("id")&" AND ta.`Data`= '"&DataRealizacao&"' AND ta.CodigoProduto="&codigo

                                            set updateAnexa = db.execute(sqlAnexa)

                                            if not updateAnexa.eof then
                                                SqlComGlosa = "UPDATE tissguiaanexa SET ValorPago=NULLIF('"&valorLiberado&"',''), motivoGlosa="&GlosaID&" WHERE id="&updateAnexa("id")

                                                set UpdateComGLosa = db.execute(SqlComGlosa)
                                            end if
                                        end if
                                        'atualiza tabela tissguiasadt
                                        IF pguias("Tabela") = "tissguiasadt" THEN
                                            ' busca o motivo da glosa
                                             set codigoGlosaTag = proc.selectSingleNode("ansTISS:codigoGlosa")

                                             codigoGlosa = ""
                                             GlosaID=0

                                             'nao implementado corretamente - nao ira atualizar o glosaId
                                             If Not codigoGlosaTag Is Nothing Then

                                                 set codigoGlosa = proc.getElementsByTagName("ansTISS:codigoGlosa")(0).text
                                                 GlosaID=0

                                                 set MotivoGlosaSQL = db.execute("SELECT id, Descricao FROM cliniccentral.tissmotivoglosa WHERE Codigo="&treatvalnull(codigoGlosa)&"")
                                                 if not MotivoGlosaSQL.eof then
                                                    GlosaID=MotivoGlosaSQL("id")
                                                 end if

                                             end if

                                            ' a tabela vem 00 sempre, portanto nao podemos usar como parametro do where. TabelaID = '"&tipoTabela&"' AND

                                            call updateTabelaProcedimentos("tissprocedimentossadt", tipoTabela, codigo, valorLiberado, pguias("id"), GlosaID, codigoGlosa)
                                            'sqlProcedimento = "UPDATE tissprocedimentossadt SET ValorPago=COALESCE(ValorPago,NULLIF('"&valorLiberado&"','')), motivoGlosa="&GlosaID&", CodigoGlosa="&treatvalnull(codigoGlosa)&" WHERE  CodigoProcedimento = '"&codigo&"' AND GuiaID = "&pguias("id")

                                            'db.execute(sqlProcedimento)
                                        END IF

                                    END IF

                                next
                            end if
                        Next
                    Next
                next
            end if
  
            c = 0
            if versaoPadrao="3.02.00" then '31552269.xml - guias de consulta, 31552272 - guias de sadt
                versaoPadraoEncontrada= true
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                for each conta in contas
                    c = c+1
                    'Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set lotes = conta.getElementsByTagName("ans:dadosProtocolo")
                    For Each lote in lotes
                        numeroLote = lote.getElementsByTagName("ans:numeroLotePrestador")(0).text

                        response.write("numeroLote: "& numeroLote &"<br>")
                        Set guias = lote.getElementsByTagName("ans:relacaoGuias")
                        For Each guia in guias
                            numeroGuiaPrestador = guia.getElementsByTagName("ans:numeroGuiaPrestador")(0).text
                            numeroCarteira = guia.getElementsByTagName("ans:numeroCarteira")(0).text
                            valorInformadoGuia = guia.getElementsByTagName("ans:valorInformadoGuia")(0).text
                            valorLiberadoGuia = guia.getElementsByTagName("ans:valorLiberadoGuia")(0).text
                            valorGlosaGuia = guia.getElementsByTagName("ans:valorGlosaGuia")(0).text

                            response.Write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                            'response.Write("---> numeroCarteira: "& numeroCarteira &"<br>")
                            'response.Write("---> valorProcessadoGuia: "& valorProcessadoGuia &"<br>")
                            'response.Write("---> valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                            'response.Write("---> valorGlosaGuia: "& valorGlosaGuia &"<br>")
        
                            sql = "select * from (select id, 'tissguiaconsulta' Tabela, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiasadt', ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiahonorarios', ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " ) t"
                            set pguias = db.execute( sql )
                            set procs = guia.getElementsByTagName("ans:detalhesGuia")
                            for each proc in procs
                                codigo = proc.getElementsByTagName("ans:codigoProcedimento")(0).text
                                tipoTabela = proc.getElementsByTagName("ans:codigoTabela")(0).text
                                valorProcessado = proc.getElementsByTagName("ans:valorProcessado")(0).text
                                valorLiberado = proc.getElementsByTagName("ans:valorLiberado")(0).text
                                set tipoGlosas = proc.getElementsByTagName("ans:tipoGlosa")
                                tipoGlosa = ""

                                For Each tipoGlosaObj in tipoGlosas
                                    tipoGlosa = tipoGlosaObj.text
                                next

                                IF NOT pguias.eof THEN
                                    IF pguias("Tabela") = "tissguiasadt" THEN

                                        call updateTabelaProcedimentos("tissprocedimentossadt", tipoTabela, codigo, valorLiberado, pguias("id"), tipoGlosa, codigoGlosa)
                                        'sqlProcedimento = "UPDATE tissprocedimentossadt SET ValorPago=COALESCE(ValorPago,NULLIF('"&valorLiberado&"','')),motivoGlosa=NULLIF('"&tipoGlosa&"','')  WHERE TabelaID = "&tipoTabela&" AND CodigoProcedimento = "&codigo&" AND GuiaID = "&pguias("id")
                                        'db.execute(sqlProcedimento)
                                    END IF

                                END IF
                            next
                        Next
                    Next
                next
            end if

            c = 0
            if versaoPadrao="3.02.01" then '31552269.xml - guias de consulta, 31552272 - guias de sadt
                versaoPadraoEncontrada= true
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                for each conta in contas
                    c = c+1
                    'Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set lotes = conta.getElementsByTagName("ans:dadosProtocolo")
                    For Each lote in lotes
                        numeroLote = lote.getElementsByTagName("ans:numeroLotePrestador")(0).text


                        'response.write("numeroLote: "& numeroLote &"<br>")
                        Set guias = lote.getElementsByTagName("ans:relacaoGuias")
                        For Each guia in guias
                            numeroGuiaPrestador = guia.getElementsByTagName("ans:numeroGuiaPrestador")(0).text
                            numeroCarteira = guia.getElementsByTagName("ans:numeroCarteira")(0).text
                            valorInformadoGuia = guia.getElementsByTagName("ans:valorInformadoGuia")(0).text
                            valorLiberadoGuia = guia.getElementsByTagName("ans:valorLiberadoGuia")(0).text
                            valorGlosaGuia = guia.getElementsByTagName("ans:valorGlosaGuia")(0).text

                            response.Write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                            'response.Write("---> numeroCarteira: "& numeroCarteira &"<br>")
                            'response.Write("---> valorProcessadoGuia: "& valorProcessadoGuia &"<br>")
                            'response.Write("---> valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                            'response.Write("---> valorGlosaGuia: "& valorGlosaGuia &"<br>")

                            sql = "select * from (select id, 'tissguiaconsulta' Tabela, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiasadt', ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiahonorarios', ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " ) t"
                            set pguias = db.execute( sql )
                            set procs = guia.getElementsByTagName("ans:detalhesGuia")
                            for each proc in procs
                                codigo = proc.getElementsByTagName("ans:codigoProcedimento")(0).text
                                tipoTabela = proc.getElementsByTagName("ans:codigoTabela")(0).text
                                valorProcessado = proc.getElementsByTagName("ans:valorProcessado")(0).text
                                valorLiberado = proc.getElementsByTagName("ans:valorLiberado")(0).text
                                tipoGlosa = proc.getElementsByTagName("ans:tipoGlosa")(0).text
                                IF NOT pguias.eof THEN
                                    IF pguias("Tabela") = "tissguiasadt" THEN
                                    
                                        call updateTabelaProcedimentos("tissprocedimentossadt", tipoTabela, codigo, valorLiberado, pguias("id"), tipoGlosa, codigoGlosa)


                                        'sqlProcedimento = "UPDATE tissprocedimentossadt SET ValorPago=COALESCE(ValorPago,NULLIF('"&valorLiberado&"','')),motivoGlosa=NULLIF('"&tipoGlosa&"','')  WHERE TabelaID = "&tipoTabela&" AND CodigoProcedimento = "&codigo&" AND GuiaID = "&pguias("id")
                                        'db.execute(sqlProcedimento)
                                    END IF

                                END IF
                            next
                        Next
                    Next
                next
            end if

            c = 0
            if versaoPadrao="3.03.01" then '36048832 - guia do novo pasta
                versaoPadraoEncontrada= true
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                for each conta in contas
                    c = c+1
                    Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set lotes = conta.getElementsByTagName("ans:dadosProtocolo")
                    For Each lote in lotes
                        numeroLote = lote.getElementsByTagName("ans:numeroLotePrestador")(0).text


                        'response.write("numeroLote: "& numeroLote &"<br>")
                        Set guias = lote.getElementsByTagName("ans:relacaoGuias")
                        For Each guia in guias
                            numeroGuiaPrestador = guia.getElementsByTagName("ans:numeroGuiaPrestador")(0).text
                            numeroCarteira = guia.getElementsByTagName("ans:numeroCarteira")(0).text
                            valorInformadoGuia = guia.getElementsByTagName("ans:valorInformadoGuia")(0).text
                            valorLiberadoGuia = guia.getElementsByTagName("ans:valorLiberadoGuia")(0).text
                            'valorGlosaGuia = guia.getElementsByTagName("ans:valorGlosaGuia")(0).text

                            response.Write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                            'response.Write("---> numeroCarteira: "& numeroCarteira &"<br>")
                            'response.Write("---> valorProcessadoGuia: "& valorProcessadoGuia &"<br>")
                            'response.Write("---> valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                            'response.Write("---> valorGlosaGuia: "& valorGlosaGuia &"<br>")

                            sql = "select * from (select id, 'tissguiaconsulta' Tabela, ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiasadt', ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiahonorarios', ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " ) t"

                            set pguias = db.execute( sql )

                            set procs = guia.getElementsByTagName("ans:detalhesGuia")
                            for each proc in procs
                                codigo = proc.getElementsByTagName("ans:codigoProcedimento")(0).text
                                tipoTabela = proc.getElementsByTagName("ans:codigoTabela")(0).text
                                valorProcessado = proc.getElementsByTagName("ans:valorProcessado")(0).text
                                valorLiberado = proc.getElementsByTagName("ans:valorLiberado")(0).text
                                'grauParticipacao = proc.getElementsByTagName("ans:grauParticipacao")(0).text
                                'response.write("------> Código: "& codigo &" - Tabela: "& tipoTabela & " - Val. Proc.: " & valorProcessado & " - Val. Lib.: " & valorLiberado & " - Grau Part.:" & grauParticipacao &"<br>")
                            next
                        Next
                    Next
                next
            end if
            c = 0

            if versaoPadrao="3.03.02" or versaoPadrao="3.03.03"  or versaoPadraoEncontrada= false then '36048832 - guia do novo pasta 
                versaoPadraoEncontrada= true
                Set contas = objXML.getElementsByTagName("ans:demonstrativoAnaliseConta")
                for each conta in contas
                    c = c+1
                    'Response.Write conta.xml & "<br />" & vbCrLf
                    '***Add the following:
                    Set lotes = conta.getElementsByTagName("ans:dadosProtocolo")
                    For Each lote in lotes
                        numeroLote = lote.getElementsByTagName("ans:numeroLotePrestador")(0).text


                        'response.write("numeroLote: "& numeroLote &"<br>")
                        Set guias = lote.getElementsByTagName("ans:relacaoGuias")
                        For Each guia in guias
                            numeroGuiaPrestador = guia.getElementsByTagName("ans:numeroGuiaPrestador")(0).text
                            numeroCarteira = guia.getElementsByTagName("ans:numeroCarteira")(0).text
                            valorInformadoGuia = guia.getElementsByTagName("ans:valorInformadoGuia")(0).text
                            valorLiberadoGuia = guia.getElementsByTagName("ans:valorLiberadoGuia")(0).text
                            valorGlosaGuia = guia.getElementsByTagName("ans:valorGlosaGuia")(0).text

                            response.Write( strGuia(ConvenioID, numeroCarteira, valorInformadoGuia, valorLiberadoGuia, valorGlosaGuia, numeroGuiaPrestador) )
                            'response.Write("---> numeroCarteira: "& numeroCarteira &"<br>")
                            'response.Write("---> valorProcessadoGuia: "& valorProcessadoGuia &"<br>")
                            'response.Write("---> valorLiberadoGuia: "& valorLiberadoGuia &"<br>")
                            'response.Write("---> valorGlosaGuia: "& valorGlosaGuia &"<br>")

                            sql = "select * from (select id, 'tissguiaconsulta' Tabela, NULL TabelaProcedimentos,ifnull(ValorPago, 0) ValorPago from tissguiaconsulta where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiasadt', 'tissprocedimentossadt' TabelaProcedimentos, ifnull(ValorPago, 0) from tissguiasadt where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " UNION ALL select id, 'tissguiahonorarios', 'tissprocedimentoshonorarios' TabelaProcedimentos, ifnull(ValorPago, 0) from tissguiahonorarios where ConvenioID IN ("& ConvenioID &") and NGuiaPrestador='"& NumeroGuiaPrestador &"' "&_
                                  " ) t"
                            set pguias = db.execute( sql )
                            'atualiza os valores cheios caso não haja glosa
                            set procs = guia.getElementsByTagName("ans:detalhesGuia")
                            IF NOT pguias.eof THEN
                                'atualiza procedimentos e anexos de guias que não tiveram glosa
                                IF procs.length = 0 AND valorGlosaGuia = 0 THEN
                                    call updateGuiaSemGlosa(pguias("id"), pguias("TabelaProcedimentos"))
                                ELSE
                                    'atualiza valores que tiveram glosa
                                    for each proc in procs
                                        codigoItem = proc.getElementsByTagName("ans:codigoProcedimento")(0).text
                                        tipoTabela = proc.getElementsByTagName("ans:codigoTabela")(0).text
                                        valorProcessado = proc.getElementsByTagName("ans:valorProcessado")(0).text
                                        valorLiberado = proc.getElementsByTagName("ans:valorLiberado")(0).text
                                        tipoGlosa = proc.getElementsByTagName("ans:tipoGlosa")(0).text
                                        'Verificar tipo da tabela
                                        IF pguias("Tabela") = "tissguiasadt" THEN
                                            call UpdateGuiaComGlosa(codigoItem, tipoTabela, valorProcessado, valorLiberado, tipoGlosa, pguias("id"))
                                        END IF
                                    next
                                    'atualiza os procedimentos que não tiveram alteração com o valor total
                                    db.execute("UPDATE tissprocedimentossadt SET ValorPago = ValorTotal WHERE GuiaID="&pguias("id")&" AND ISNULL(ValorPago)")
                                    'atualiza os anexos que não tiveram alteração com o valor total
                                    db.execute("UPDATE tissguiaanexa SET ValorPago = ValorTotal WHERE GuiaID="&pguias("id")&" AND ISNULL(ValorPago)")
                                END IF
                            END IF
                        Next
                    Next
                next
            end if

                                %>
            </tbody>
        </table>
    </div>
</div>

<script type="text/javascript">
    function lFin() {
        var checkeds = $("input[name=lancar]:checked").size();

        if (checkeds == 0) {
            $("#divLancar").html("");
        } else {
            $.post("xmlLFin.asp", $("input[name=lancar]").serialize(), function (data) {
                $("#divLancar").html(data);
            });

}
    }
</script>