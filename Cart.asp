<!--#include file="connect.asp"-->
<%
Acao = req("A")
id = req("I")
sessaoAgenda = req("sessaoAgenda")

if Acao <> "prop" then
    if Acao="I" then
        Response.write("")
        if  ref("bEspecialidadeID")&"" = "0" and ref("bProfissionalID") = "" and ref("bPacienteID") = "" and ref("bProcedimentoID") = "" then
            Response.write("<div class='alert alert-warning'>Selecione os campos para adicionar ao carrinho</div>")
        else
            bEspecialidadeID = ref("bEspecialidadeID")
            if ref("bEspecialidadeID")&"" = "0" then
                bEspecialidadeID = ""
            end if
            db.execute("insert into agendacarrinho (PacienteID, TabelaID, ProcedimentoID, ComplementoID, Zona, EspecialidadeID, EspecializacaoID, ProfissionalID, sysUser, sessaoAgenda) values ("& treatvalnull(ref("bPacienteID")) &", "& treatvalnull(ref("bageTabela")) &", "& treatvalnull(ref("bProcedimentoID")) &", "& treatvalnull(ref("bComplementoID")) &", '"& ref("bRegiao") &"', "& treatvalnull(bEspecialidadeID) &", "& treatvalnull(ref("bSubespecialidadeID")) &", "& treatvalnull(ref("bProfissionalID")) &", "& session("User") &",'"&sessaoAgenda&"')")
        end if
    end if

    if Acao="X" then
        db.execute("update agendacarrinho SET Arquivado=NOW() WHERE id="& id)
        db.execute("DELETE FROM agenda_horarios WHERE CarrinhoID="& id)
    end if

    if Acao="ALL" then
        db.execute("update agendacarrinho SET Arquivado=NOW() WHERE sysUser="& session("User")&" AND SessaoAgenda='"&SessaoAgenda&"'")
        db.execute("DELETE FROM agenda_horarios WHERE sysUser="& session("User")&" AND SessaoAgenda='"&SessaoAgenda&"'")
    end if

    if Acao="FIND" then
    set cartTotal = db.execute("select count(*) total FROM agendacarrinho ac LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID LEFT JOIN complementos comp ON comp.id=ac.ComplementoID LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID WHERE ac.id="& id)
    else
    set cartTotal = db.execute("select count(*) total FROM agendacarrinho ac LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID LEFT JOIN complementos comp ON comp.id=ac.ComplementoID LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID WHERE ac.sysUser="& session("User") &" AND sessaoAgenda = '"&sessaoAgenda&"' and isnull(ac.Arquivado)")
    end if
    %>
    <%
    valorMinimoParcela = getConfig("ValorMinimoParcelamento")
    %>
    <table class="table table-striped table-bordered table-hover">
        <thead>
            <tr class="system">
                <th colspan="12"><i class="fa fa-calendar"></i> <%=cartTotal("total")%> procedimentos selecionados</th>
            </tr>
            <%
            if Acao="FIND" then
                sql = "select ac.AgendamentoID,ac.id, proc.NomeProcedimento, comp.NomeComplemento, prof.NomeProfissional, prof.NomeSocial, ac.Zona, ac.EspecialidadeID, a.Data, a.Hora, ep.especialidade, ac.ProcedimentoID, ac.ProfissionalID, ac.TabelaID, sep.Subespecialidade " &_ 
                " FROM agendacarrinho ac LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID LEFT JOIN complementos comp ON comp.id=ac.ComplementoID LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID " &_ 
                " LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID LEFT JOIN subespecialidades sep ON sep.id = ac.EspecializacaoID WHERE (ac.id="& id & " or ( ac.sysUser="& session("User") &" AND sessaoAgenda = '"&sessaoAgenda&"' and isnull(ac.Arquivado) ))"
                set cart = db.execute(sql)
            else
                sql = "select ac.AgendamentoID,ac.id, proc.NomeProcedimento, comp.NomeComplemento, prof.NomeProfissional, prof.NomeSocial, ac.Zona, ac.EspecialidadeID, a.Data, a.Hora, ep.especialidade, ac.ProcedimentoID, ac.ProfissionalID, ac.TabelaID, sep.Subespecialidade " &_ 
                " FROM agendacarrinho ac LEFT JOIN procedimentos proc ON proc.id=ac.ProcedimentoID LEFT JOIN complementos comp ON comp.id=ac.ComplementoID LEFT JOIN profissionais prof ON prof.id=ac.ProfissionalID " &_ 
                " LEFT JOIN agendamentos a ON a.id=ac.AgendamentoID LEFT JOIN especialidades ep ON ep.id = ac.EspecialidadeID LEFT JOIN subespecialidades sep ON sep.id = ac.EspecializacaoID WHERE ac.sysUser="& session("User") &" AND sessaoAgenda = '"&sessaoAgenda&"' and isnull(ac.Arquivado)"
                set cart = db.execute(sql)
            end if

            if not cart.eof then
            %>
            <tr>
                <th>Procedimento</th>
                <th>Complemento</th>
                <th>Executor</th>
                <th>Especialidade</th>
                <th>Sub Especialidade</th>
                <th>Data</th>
                <th>Hora</th>
                <th>Local</th>
                <th>A Vista</th>
                <th>3x</th>
                <th class="seisvezes">6x</th>
                <th width="1%"></th>
            </tr>
            <%
                totalAVista = 0
                totalParcelaTres = 0
                totalParcelaSeis = 0

                while not cart.eof
            %>
            <input type="hidden" name="agendamentoIDCarrinho2" class="allCarrinho agendamentoIDCarrinho2<%=cart("id")%>" id="agendamentoIDCarrinho2" value=""> 
            <%
                valorProcedimento = 0
                parcelaTres = 0
                parcelaSeis = 0
                ProfissionalID = cart("ProfissionalID")

                if ProfissionalID&""="0" then
                    ProfissionalID = ""
                end if

                if cart("ProcedimentoID") <> "" and  not isnull(cart("ProcedimentoID")) then
                    valorProcedimento = calcValorProcedimento(cart("ProcedimentoID"), cart("TabelaID"), "ANY", ProfissionalID, cart("EspecialidadeID"), "", "")
                    sqlDesconto = "SELECT ParcelasDe, ParcelasAte, Acrescimo FROM sys_formasrecto WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & cart("ProcedimentoID") & "|%') " &_
                                                " AND MetodoID IN (8,9,10) limit 1"

                    set descontos = db.execute(sqlDesconto)
                                    
                    parcelaTres = valorProcedimento / 3
                    parcelaSeis = valorProcedimento / 6

                    if not descontos.eof then
                        if descontos("ParcelasDe") <= 3 then
                            parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                        end if

                        if descontos("ParcelasAte") >= 6 then
                            parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100 )
                        end if
                    end if

                end if

                    Data = ""
                    Hora = ""
                    Endereco = ""
                    NomeLocal = ""

                    if not isnull(cart("AgendamentoID")) then
                        set AgendamentoSQL = db.execute("SELECT loc.NomeLocal, a.ValorPlano, a.rdValorPlano, a.Data, DATE_FORMAT(a.Hora,'%H:%i') Hora, loc.UnidadeID as uID, " &_ 
                            " IF(loc.UnidadeID = 0, (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from empresa where id = loc.UnidadeID), " &_ 
                            " (select CONCAT(Endereco, ' ', Numero, ' ', Complemento, ' ', Bairro, ' ', Cep, ' ', Cidade, ' ', Estado) Enderecos from sys_financialcompanyunits where id = loc.UnidadeID) ) Enderecos " &_
                            " FROM agendamentos a LEFT JOIN locais loc ON loc.id=a.LocalID WHERE a.id="&cart("AgendamentoID"))

                        if not AgendamentoSQL.eof then

                            AVista = "Convenio"
                            valorProcedimento = 0
                            parcelaTres = 0
                            parcelaSeis = 0

                            if AgendamentoSQL("rdValorPlano") = "V" then 
                                valorProcedimento = AgendamentoSQL("ValorPlano")    

                                if not descontos.eof then
                                    if descontos("ParcelasDe") <= 3 then
                                        parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                                    end if

                                    if descontos("ParcelasAte") >= 6 then
                                        parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100)
                                    end if
                                end if
                            end if

                            NomeLocal = AgendamentoSQL("NomeLocal")
                            Data = AgendamentoSQL("Data")
                            Hora = AgendamentoSQL("Hora")
                            Endereco = AgendamentoSQL("Enderecos")
    %>
                            <script>
                                $(".agendamentoIDCarrinho2<%=cart("id")%>").val("<%=cart("AgendamentoID")%>");
                            </script>
    <%
                        end if
                    end if

                    totalAVista = totalAVista + valorProcedimento
                    totalParcelaTres = totalParcelaTres + parcelaTres
                    totalParcelaSeis = totalParcelaSeis + parcelaSeis
    %>
                    <tr>
                        <input type="hidden" class="ProcedimentoSelecionadoID" value="<%=cart("ProcedimentoID")%>">
                        <input type="hidden" id="BuscaSelecionada" name="BuscaSelecionada" value="<%=cart("id")%>">
                        <td>
                        <input type="checkbox" name="BuscaSelecionada2" id="BuscaSelecionada2" value="<%= cart("id") %>" checked style="display: none" />
                        <%= cart("NomeProcedimento") %></td>
                        <td><%= cart("NomeComplemento") %></td>
                        <td><%= cart("NomeSocial") %></td>
                        <td><%= cart("especialidade") %></td>
                        <td><%= cart("Subespecialidade") %></td>
                        <td><%= Data %></td>
                        <td><%= Hora %></td>
                        <td><span data-toggle="tooltip" title="<%= Endereco %>" href="#" class=""><%= NomeLocal %></span></td>
                        <td>R$ <%= fn(valorProcedimento) %></td>
                        <td>R$ <%= fn(parcelaTres) %></td>
                        <td class="seisvezes">
                        <% if ccur(valorProcedimento) >= ccur(valorMinimoParcela) then %> 
                            R$ <%=fn(parcelaSeis)%>
                        <% else 
                            response.write(" - ")
                        end if %></td>
                        <td><button class="btn btn-xs btn-danger" onclick="cart('X', <%= cart("id") %>)" type="button"><i class="fa fa-remove"></i></button></td>
                    </tr>
                    <%
                cart.movenext
                wend
                cart.close
                set cart = nothing
            %>
                <tr>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td>R$ <%=fn(totalAVista)%></td>
                    <td>R$ <%=fn(totalParcelaTres)%></td>
                    <td class="seisvezes">
                    <% if ccur(totalAVista) >= ccur(valorMinimoParcela) then %> 
                        R$ <%=fn(totalParcelaSeis)%>
                    <% else 
                        response.write(" - ")
                    end if %></td>
                </tr>
            <%
            end if
            %>
        </thead>
    </table>

    <input type="hidden" id="totalValor" value="<%= totalAVista %>">
    <input type="hidden" id="valorMinimoParcela" value="<%= valorMinimoParcela %>">
<% end if %>

<%
if Acao = "prop" then
    
    PropostaID = ref("bPropostaID")
    
    query = "SELECT * FROM agendacarrinho WHERE PropostaID = "&treatvalnull(PropostaID)&""
    set queryProp = db.execute(query)

    if not queryProp.eof then
        db.execute("UPDATE agendacarrinho SET sessaoAgenda = '"&sessaoAgenda&"' WHERE PropostaID = "&treatvalnull(PropostaID)&"")
    else
        queryProposta = "SELECT I.id AS ItensPropostaID, ItemID, PacienteID, PropostaID FROM itensproposta I INNER JOIN propostas P ON I.PropostaID = P.id WHERE PropostaID = "&treatvalnull(PropostaID)&""
        set proposta = db.execute(queryProposta)
        if not proposta.eof then
            while not proposta.EOF

                ProcedimentoID = proposta("ItemID")
                PacienteID = proposta("PacienteID")
                ItensPropostaID = proposta("ItensPropostaID")

               db.execute("INSERT INTO agendacarrinho (PacienteID, ProcedimentoID, PropostaID, ItensPropostaID, sysUser, sessaoAgenda)"&_
               " values ("& treatvalnull(PacienteID) &", "& treatvalnull(ProcedimentoID) &", "& treatvalnull(PropostaID) &", "&treatvalnull(ItensPropostaID)&", "& session("User") &",'"&sessaoAgenda&"')")
            
            proposta.movenext
            wend
            proposta.close
            set proposta = nothing
        end if
    end if

    query = "SELECT PR.id AS ProcedimentoID, PR.NomeProcedimento, AC.id AS CarrinhoID, AC.AgendamentoID,"&_
            " AG.Data, DATE_FORMAT(AG.Hora,'%H:%i') AS Hora,"&_
            " PF.NomeProfissional, PF.NomeSocial, LC.NomeLocal"&_
            " FROM "&_
            " agendacarrinho AC"&_
            " LEFT JOIN procedimentos PR ON PR.id = AC.ProcedimentoID"&_
            " LEFT JOIN complementos CP ON CP.id = AC.ComplementoID"&_
            " LEFT JOIN profissionais PF ON PF.id = AC.ProfissionalID"&_
            " LEFT JOIN agendamentos AG ON AG.id = AC.AgendamentoID"&_
            " LEFT JOIN especialidades ES ON ES.id = AC.EspecialidadeID"&_
            " LEFT JOIN subespecialidades SE ON SE.id = AC.EspecializacaoID"&_
            " LEFT JOIN propostas PP ON PP.id = AC.PropostaID "&_
            " LEFT JOIN locais LC ON LC.id = AG.LocalID "&_
            " WHERE AC.PropostaID = "&treatvalnull(PropostaID)&""
    set queryProp = db.execute(query)
%>  
    <table class="table table-condensed table-bordered table-hover">
        <thead>
            <tr class="system">
                <th colspan="12"><i class="fa fa-calendar"></i>procedimentos selecionados</th>
            </tr>
            <tr>
                <th>Procedimento</th>
                <th>Complemento</th>
                <th>Executor</th>
                <th>Especialidade</th>
                <th>Sub Especialidade</th>
                <th>Data</th>
                <th>Hora</th>
                <th>Local</th>
                <th>A Vista</th>
                <th>3x</th>
                <th class="seisvezes">6x</th>
                <th width="1%"></th>
            </tr>
            <%
            while not queryProp.eof
                valorProcedimento = 0
                parcelaTres = 0
                parcelaSeis = 0

                if queryProp("ProcedimentoID") <> "" and  not isnull(queryProp("ProcedimentoID")) then
                    valorProcedimento = calcValorProcedimento(queryProp("ProcedimentoID"), "", "ANY", "", "", "")
                    sqlDesconto = "SELECT"&_
                                    " ParcelasDe, ParcelasAte, Acrescimo"&_
                                    " FROM sys_formasrecto"&_
                                    " WHERE tipoDesconto = 'P' AND (procedimentos LIKE '%|ALL|%' OR procedimentos LIKE '%|" & queryProp("ProcedimentoID") & "|%') " &_
                                    " AND MetodoID IN (8,9,10) limit 1"

                    set descontos = db.execute(sqlDesconto)
                                    
                    parcelaTres = valorProcedimento / 3
                    parcelaSeis = valorProcedimento / 6

                    if not descontos.eof then
                        if descontos("ParcelasDe") <= 3 then
                            parcelaTres = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (3 * 100 )
                        end if

                        if descontos("ParcelasAte") >= 6 then
                            parcelaSeis = (valorProcedimento * (ccur(descontos("Acrescimo") + 100))) / (6 * 100 )
                        end if
                    end if

                end if

                totalAVista = totalAVista + valorProcedimento
                totalParcelaTres = totalParcelaTres + parcelaTres
                totalParcelaSeis = totalParcelaSeis + parcelaSeis
            %>
            <tr>
                <input type="hidden" name="agendamentoIDCarrinho2" class="allCarrinho agendamentoIDCarrinho2<%= queryProp("CarrinhoID") %>" id="agendamentoIDCarrinho2" value=""> 
                <script>
                    $(".agendamentoIDCarrinho2<%= queryProp("CarrinhoID") %>").val("<%= queryProp("AgendamentoID") %>");
                </script>
                <input type="hidden" class="ProcedimentoSelecionadoID" value="<%= queryProp("ProcedimentoID") %>">
                <input type="hidden" id="BuscaSelecionada" name="BuscaSelecionada" value="<%= queryProp("CarrinhoID") %>">
                <td>
                    <input type="checkbox" name="BuscaSelecionada2" id="BuscaSelecionada2" value="<%= queryProp("CarrinhoID") %>" checked style="display: none" />
                    <%= queryProp("NomeProcedimento") %>
                </td>
                <td></td>
                <td><%= queryProp("NomeSocial") %></td>
                <td></td>
                <td></td>
                <td><%= queryProp("Data") %></td>
                <td><%= queryProp("Hora") %></td>
                <td><span href="#" class=""><%= queryProp("NomeLocal") %></span></td>
                <td>R$ <%= fn(valorProcedimento) %></td>
                <td>R$ <%= fn(parcelaTres) %></td>
                <td class="seisvezes">R$ <%= fn(parcelaSeis) %></td>
                <td><button class="btn btn-xs btn-danger" onclick="" type="button"><i class="fa fa-remove"></i></button></td>
            </tr>
            <%
            queryProp.movenext
            wend
            queryProp.close
            set queryProp = nothing
            %>
            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>R$ <%= fn(totalAVista) %></td>
                <td>R$ <%= fn(totalParcelaTres) %></td>
                <td class="seisvezes">R$ <%= fn(totalParcelaSeis) %></td>
            </tr>
        </thead>
    </table>
<%
end if
%>