<!--#include file="connect.asp"-->
<%
Fcn = req("fcn")
InvoiceID = req("InvoiceID")
tipoTela = req("tipoTela")



select case Fcn
    case "DescontoGeral"
        DescontoGeral = req("DescontoGeral")
        if DescontoGeral<>"" and isnumeric(DescontoGeral) then
            DescontoGeral = ccur(DescontoGeral)
        else
            DescontoGeral = 0
        end if
        TipoDescontoGeral = req("TipoDescontoGeral")
        set pValTot = db.execute("select IFNULL(sum(ValorUnitario),0) Total FROM cliniccentral.itensinvoice_temp WHERE sysUser="& session("User") &" AND tipoTela='"& tipoTela &"' AND InvoiceID="& InvoiceID)
        Total = pValTot("Total")

        set iit = db.execute("select * from cliniccentral.itensinvoice_temp WHERE sysUser="& session("User") &" AND tipoTela='"& tipoTela &"' AND InvoiceID="& InvoiceID)
        while not iit.eof
            ValorUnitario = iit("ValorUnitario")
            ItemInvoiceID = iit("ItemInvoiceID")
            if TipoDescontoGeral="P" then
                Percentual = DescontoGeral/100
            else
                Percentual = DescontoGeral / Total
            end if
            ValorDesconto = ValorUnitario * Percentual
            response.write("$('#ifatDesconto"& ItemInvoiceID &"').val('"& fn(ValorDesconto) &"');")
        iit.movenext
        wend
        iit.close
        set iit = nothing

        response.write("validaDescontos();")

    case "listaItens"
        %>
        <table class="table table-condensed table-hover">
            <thead>
                <tr>
                    <th>Procedimento</th>
                    <th>Valor</th>
                    <th>Desconto</th>
                    <th>Acréscimo</th>
                    <th class="hidden">Total</th>
                </tr>
            </thead>
            <tbody>
                <%
                set t = db.execute("select dct.id DescontoSolicitadoID, dct.Status StatusDescontoSolicitado,dct.Desconto DescontoSolicitado, iit.*, proc.NomeProcedimento, IFNULL(iitv.Desconto,0) Desconto, IFNULL(iitv.Acrescimo, 0) Acrescimo, i.CompanyUnitID UnidadeID "&_ 
                " from cliniccentral.itensinvoice_temp iit "&_
                "INNER JOIN procedimentos proc ON (proc.id=iit.ItemID and iit.Tipo='S') "&_
                "LEFT JOIN cliniccentral.itensinvoicevar_temp iitv ON iitv.iiTempID=iit.id "&_
                "LEFT JOIN descontos_pendentes dct ON dct.ItensInvoiceID=iit.ItemInvoiceID "&_
                "LEFT JOIN sys_financialinvoices i ON i.id=iit.InvoiceID "&_
                "WHERE iit.sysUser="& session("User") &" AND iit.tipoTela='"& tipoTela &"' AND iit.InvoiceID="& InvoiceID)

                HasDescontoPendente= False
                while not t.eof
                    NomeProcedimento = t("NomeProcedimento")
                    ValorUnitario = t("ValorUnitario")
                    Desconto = t("Desconto")
                    Acrescimo = t("Acrescimo")
                    UnidadeID = t("UnidadeID")
                    ItemInvoiceID = t("ItemInvoiceID")
                    ProcedimentoID = t("ItemID")
                    DescontoSolicitadoID = t("DescontoSolicitadoID")

                    if t("StatusDescontoSolicitado")=1 then 
                        Desconto = t("DescontoSolicitado")
                    end if
                    %>
                    <tr>
                        <input type="hidden" name="itemFaturaCheckin" value='<%=ItemInvoiceID%>'/>
                        <td width="50%"><%= NomeProcedimento %> </td>
                        <td class="text-center" class="text-right" style="vertical-align: top;"><%= quickfield("currency", "ifatValorUnitario"& ItemInvoiceID, "", 12, ValorUnitario, "", "", " disabled ") %></td>
                        <td class="text-center" style="vertical-align: top;"><%= quickfield("currency", "ifatDesconto"& ItemInvoiceID, "", 12, Desconto, "", "", " data-ItemInvoiceID='"& ItemInvoiceID &"' ") %>
                            <div id="divDesconto<%= ItemInvoiceID %>">
                                <%
                                if t("StatusDescontoSolicitado")=0 then
                                    HasDescontoPendente=True
                                    %>
                                    <span class="label label-warning badge-waiting-approval"><i class='far fa-circle-o-notch fa-spin'></i> Aguardando aprovação (R$ <%=fn(t("DescontoSolicitado"))%>)</span>
                                    <%
                                end if
                                
                                if t("StatusDescontoSolicitado")=1 then
                                    %>
                                    <span class="label label-success badge-waiting-approval"><i class='far fa-check'></i> Desconto aprovado</span>
                                    <%
                                end if
                                %>
                            </div>
                        </td>
                        <td class="text-center" style="vertical-align: top;"><%= quickfield("currency", "ifatAcrescimo"& ItemInvoiceID, "", 12, Acrescimo, "", "", " disabled ") %></td>
                        <th class="text-right hidden"><%= fn(Subtotal) %></th>
                    </tr>
                    <%
                t.movenext
                wend
                t.close
                set t=nothing
                %>
            </tbody>
        </table>
        <script type="text/javascript">
        <%
        if HasDescontoPendente THEN
            %>
            startCheckAprovacaoDesconto('<%=DescontoSolicitadoID%>');
            <%
        end if
        %>

        var intervaloDesconto;
        
        $("input[name^=ifatDesconto]").keyup(function(){
            clearInterval(intervalDesconto);

            intervalDesconto = setTimeout(() => {
                validaDescontos();                
            }, 300);
        });

        <!--#include file="JQueryFunctions.asp"-->
        </script>    
        <%

    case "avaliaDesconto"
        sql = "select iit.*, proc.NomeProcedimento, IFNULL(iitv.Desconto,0) Desconto, IFNULL(iitv.Acrescimo, 0) Acrescimo, i.CompanyUnitID UnidadeID "&_ 
        " from cliniccentral.itensinvoice_temp iit INNER JOIN procedimentos proc ON (proc.id=iit.ItemID and iit.Tipo='S') LEFT JOIN cliniccentral.itensinvoicevar_temp iitv ON iitv.iiTempID=iit.id LEFT JOIN sys_financialinvoices i ON i.id=iit.InvoiceID WHERE iit.sysUser="& session("User") &" AND iit.tipoTela='"& tipoTela &"' AND iit.InvoiceID="& InvoiceID

        'response.write( sql )
 
        set t = db.execute( sql )
        temNaoAprovavel = 0
        todosAutorizados = 1
        while not t.eof
            NomeProcedimento = t("NomeProcedimento")
            ValorUnitario = t("ValorUnitario")
            Acrescimo = t("Acrescimo")
            UnidadeID = t("UnidadeID")
            ItemInvoiceID = t("ItemInvoiceID")
            ProcedimentoID = t("ItemID")
            DescontoSolicitado = ref("ifatDesconto"& ItemInvoiceID)
            if DescontoSolicitado<>"" and isnumeric(DescontoSolicitado) then
                DescontoSolicitado=ccur(DescontoSolicitado)
            else
                DescontoSolicitado=0
            end if
                %>
                <script>
                    $("#divDesconto<%= ItemInvoiceID %>").html("");
                </script>
                <%

            if DescontoSolicitado>0 then


                if tipoTela="invoice" or tipoTela="checkin" then
                    Recurso = "ContasAReceber"

                end if
                'Retorna até quanto esse user pode dar, o máximo que pode ser dado por outros e quais outros podem dar o máximo

                sqlAlcadas = "select *, if(TipoDesconto='P', "& treatvalzero(ValorUnitario) &"/100*DescontoMaximo, DescontoMaximo) ValorMaximo from regrasdescontos where (Procedimentos='' or Procedimentos LIKE '%|"& ProcedimentoID &"|%') AND Recursos LIKE '%|"& Recurso &"|%' AND (Unidades LIKE '%|"& UnidadeID &"|%' or Unidades='') AND "&_ 
                " if(TipoDesconto='P', "& treatvalzero(ValorUnitario) &"/100*DescontoMaximo, DescontoMaximo)>="& treatvalzero(DescontoSolicitado)
                'response.write( sqlAlcadas )
                set alcadas = db.execute( sqlAlcadas )
                Autorizado = 0
                Aprovavel = 0
                RegrasAprovaveis = "0"
                if alcadas.eof then
                    Autorizado = 0
                    todosAutorizados = 0
                else
                    while not alcadas.eof
                        ValorMaximo = alcadas("ValorMaximo")
                        RegraID = alcadas("RegraID")
                        PodeEsteUser = 0
                        Aprovavel = 1

                        if session("ModoFranquia") then
                            set vcaRegraUser = db.execute("select id from usuarios_regras where usuario="& session("User") &" and regra="& RegraID &" and unidade="& UnidadeID)
                            if not vcaRegraUser.eof then
                                Autorizado = 1
                            else
                                RegrasAprovaveis = RegrasAprovaveis &", "& RegraID
                            end if
                        else
                            if instr(session("Permissoes"), "["& RegraID &"]")>0 then
                                Autorizado = 1
                            else
                                RegrasAprovaveis = RegrasAprovaveis &", "& RegraID
                                todosAutorizados = 0
                            end if
                        end if
                    alcadas.movenext
                    wend
                    alcadas.close
                    set alcadas = nothing
                end if
                if DescontoSolicitado>ValorUnitario then
                    Autorizado = 0
                    Aprovavel = 0
                    todosAutorizados = 0
                end if
                if Autorizado=0 and Aprovavel=0 then
                    temNaoAprovavel = 1
                    todosAutorizados = 0
                end if

                if RegrasAprovaveis<>"0" then
                    sqlRegrasAprovaveis = sqlRegrasAprovaveis & " AND id IN("& RegrasAprovaveis &") "
                end if
    
                if Autorizado=1 then
                    %>
                    <script>
                    $("#divDesconto<%= ItemInvoiceID %>").html("<span class='label label-success'>Autorizado</span>");
                    </script>
                    <%
                else
                    todosAutorizados = 0
                    if Aprovavel=1 then
                        %>
                        <script>
                        $("#divDesconto<%= ItemInvoiceID %>").html("<span class='label label-warning badge-waiting-approval'>A aprovar</span>");
                        </script>
                        <%
                    else
                        temNaoAprovavel=1
                        %>
                        <script>
                        $("#divDesconto<%= ItemInvoiceID %>").html("<span class='label label-danger'>Não autorizado</span>");
                        </script>
                        <%
                    end if
                end if

            end if
        t.movenext
        wend
        t.close
        set t = nothing

        'response.write( sqlRegrasAprovaveis )

        if temNaoAprovavel=0 and todosAutorizados=0 then
            if true then
                set perfs = db.execute("select * from regraspermissoes where 1 "& sqlRegrasAprovaveis)
                if not perfs.eof then
                        'response.write(" temNaoAprovavel: "& temNaoAprovavel &" - todosAutorizados: "& todosAutorizados )
                        %>
                        <div class="col-md-12" id="content-solicitar-aprovacao-desconto">
                            <div class="panel">
                                <div class="panel-heading">
                                    <span class="panel-title">Perfis com Alçada</span>
                                </div>
                                <div class="panel-body">
                                    <div class="col-md-6">
                                        <%
                                        HaUsuarioComPermissaoDeAprovar=0
                                        while not perfs.eof
                                            
                                            if session("ModoFranquia") then
                                                set usr = db.execute("select su.id, f.NomeFuncionario Nome FROM usuarios_regras ur LEFT JOIN sys_users su ON su.id=ur.usuario LEFT JOIN funcionarios f ON (f.id=su.idInTable AND su.Table='funcionarios') where f.Ativo='on' AND f.sysActive=1 AND NOT ISNULL(f.NomeFuncionario) AND f.Unidades LIKE '%|"& UnidadeID &"|%' AND su.UnidadeID="&session("UnidadeID")&" AND ur.regra="& perfs("id") &" AND ur.unidade="& UnidadeID &" AND NOT su.id="& session("User"))
                                            else
                                                set usr = db.execute("select su.id, f.NomeFuncionario Nome from sys_users su LEFT JOIN funcionarios f ON (f.id=su.idInTable AND su.Table='funcionarios') where f.Ativo='on' AND f.sysActive=1 AND NOT ISNULL(f.NomeFuncionario) AND f.Unidades LIKE '%|"& UnidadeID &"|%' AND su.Permissoes LIKE '%["& perfs("id") &"]%' AND su.UnidadeID="&session("UnidadeID")&" AND NOT su.id="& session("User"))
                                            end if
                                            if not usr.eof then
                                                HaUsuarioComPermissaoDeAprovar=1
                                            %>
                                            <b><%= ucase(perfs("Regra")&"") %></b> <br>
                                            <%
                                                while not usr.eof
                                                %>
                                                <label><input type="radio" name="UsuarioAprovacao" value="<%= usr("id") %>"> <%= usr("Nome") %></label> <br>
                                                <%
                                                usr.movenext
                                                wend
                                                usr.close
                                                set usr = nothing
                                            end if
                                        perfs.movenext
                                        wend
                                        perfs.close
                                        set perfs = nothing
                                        %>
                                    </div>
                                    <%
                                    if HaUsuarioComPermissaoDeAprovar then
                                    %>
                                    <%= quickfield("memo", "ObsDesconto", "Observações do desconto", 6, "", "", "", "") %>
                                    <%
                                    end if
                                    %>
                                </div>
                                <div class="panel-footer">
                                    <%
                                    if HaUsuarioComPermissaoDeAprovar then
                                    %>
                                    <div class="row">
                                        <div class="col-md-8">
                                        </div>
                                        <div class="col-md-4">
                                            <button class="btn btn-sm btn-block btn-success hidden" type="button" onclick="confAut(0)">Autorizar</button>
                                            <button id="btn-solicitar-aprovacao" class="btn btn-sm btn-block btn-warning" type="button" onclick="solicitarAutorizacao()">Solicitar</button>
                                        </div>
                                    </div>
                                    <%
                                    else
                                        %>
                                        <p>Não há nenhum usuário com permissão para aprovar o desconto em sua unidade.</p>
                                        <%
                                    end if
                                    %>
                                </div>
                            </div>
                        </div>
                        <script>
                            $(".desc-forma").css("display", "none");
                        </script>
                        <%
                end if
            end if
        elseif todosAutorizados=1 then
            %>
            <script>
                $(".desc-forma").css("display", "none");
            </script>
            <div class="panel-footer desc-manual">
                <div class="row">
                    <div class="col-md-2 col-md-offset-10">
                        <button type="button" class="btn btn-sm btn-block btn-success" onclick="confAut(1)">Confirmar</button>
                    </div>
                </div>
            </div>
            <%
        end if
        
        response.end
    case "Receber"
        'Verifica se neste tipoTela, sysUser

    case "confAut"
        %>
        <!--#include file="Classes/Environment.asp"-->
        <%
        UsuarioAprovacao = ref("UsuarioAprovacao")
        senhaAprovacao = ref("senhaAprovacao")
        ObsDesconto = ref("ObsDesconto")
        dir = ref("dir")

        if dir="0" then
            Password = senhaAprovacao
            PasswordSalt = getEnv("FC_PWD_SALT", "SALT_")
            if senhaAprovacao="" then
                erro = "Preencha a senha do usuário aprovador."
            end if
            if UsuarioAprovacao="" then
                erro = "Selecione o usuário aprovador."
            end if
            if erro="" then
                sqlSenha = " ((Senha='"&Password&"' AND VersaoSenha=1) "&_
                "or (SenhaCript=SHA1('"&PasswordSalt& uCase(Password) &"') AND VersaoSenha=2)"&_
                "or (SenhaCript=SHA1('"&PasswordSalt& Password &"') AND VersaoSenha=3)"&_
                ") "
                sql = "select id from cliniccentral.licencasusuarios WHERE LicencaID="& replace(session("Banco"), "clinic", "") &" AND id="& UsuarioAprovacao &" AND "& sqlSenha
                'response.write( sql )
                set validaSenha = db.execute( sql )
                if validaSenha.eof then
                    erro = "Senha incorreta."
                end if
            end if
            if erro<>"" then
                %>
                alert('<%= erro %>');
                <%
            else
                %>
                aDesc();
                <%
            end if
        else
            'aDesc = AUTORIZA DESCONTO
            %>
            aDesc();
            <%
        end if
    case "aDesc"
        'loop nos itens aplicando o desconto do ref
        set iit = db.execute("select * from cliniccentral.itensinvoice_temp WHERE sysUser="& session("User") &" AND tipoTela='"& tipoTela &"' AND InvoiceID="& InvoiceID)
        while not iit.eof
            'aplica na itensinvoice
            db.execute("update itensinvoice set Desconto="& treatvalzero(ref("ifatDesconto"& iit("ItemInvoiceID") )) &" WHERE id="& iit("ItemInvoiceID"))
         iit.movenext
        wend
        iit.close
        set iit = nothing


        'pega o novo valor total
        set pVal = db.execute("select sum( quantidade * ( valorunitario+acrescimo-desconto ) ) NovoTotal from itensinvoice where InvoiceID="& InvoiceID)
        NovoTotal = pVal("NovoTotal")
        'response.write("alert('"& NovoTotal &"')")

        'atualiza o value da invoice
        db.execute("update sys_financialinvoices set Value="& treatvalzero(NovoTotal) &" where id="& InvoiceID)

        'loop na movement atualizando a primeira pro total e apagando da segunda em diante
        c = 0
        set mov = db.execute("select id from sys_financialmovement where Type='Bill' AND InvoiceID="& InvoiceID)
        while not mov.eof
            c = c+1
            if c=1 then
                MovementID = mov("id")
                db.execute("update sys_financialmovement set Value="& treatvalzero(NovoTotal) &" where id="& mov("id"))
            else
                db.execute("delete from sys_financialmovement where id="& mov("id"))
            end if
        mov.movenext
        wend
        mov.close
        set mov = nothing

        'arredonda se tiver arredondamento

        'AÇÕES FINAIS SE FOR INVOICE
        if tipoTela="invoice" then
            'chama recalc e parcelas...
            %>
            itens();
            recalc();
            <%

            'fecha modal
            %>
            $("#modal-table").modal("hide");
            <%
        elseif tipoTela="checkin" then
            set vFormaRecto = db.execute("select id from sys_formasrecto where MetodoID='"& ref("MetodoID") &"'")
            if not vFormaRecto.eof then
                db.execute("update sys_financialinvoices set FormaID="& vFormaRecto("id") &" where id="& InvoiceID)
            end if
            %>
            abrirPagar(<%= MovementID %>);

            <%
        end if

        call arredonda(InvoiceID)

end select

%>

