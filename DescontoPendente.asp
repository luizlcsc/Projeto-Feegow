<!--#include file="connect.asp"-->

<script type="text/javascript">
    $(".crumb-active").html("<a href='#'>Financeiro</a>");
    $(".crumb-icon a span").attr("class", "far fa-percentage");
    $(".crumb-trail").removeClass("hidden");
    $(".crumb-trail").html("descontos pendentes");
</script>
<!--#include file="DescontoPendenteSave.asp"-->
<%
StatusDesconto = ref("StatusDesconto")
De = ref("De")
Ate = ref("Ate")

if De&"" = "" then
    De = dateadd("d", -7, date())
    Ate = date()
end if
%>
<br />
	<div class="panel">
	    <div class="panel-heading">
            <span class="panel-title">
                Descontos pendentes
            </span>
        </div>
        <div class="panel-body">
            <div class="col-md-12">
                <form id="form1" action="?P=DescontoPendente&Pers=1" method="post">
                    <%=quickfield("simpleSelect", "StatusDesconto", "Status do Desconto", 3, StatusDesconto, "select '0' id, 'PENDENTE' Tipo UNION ALL select '1' id, 'APROVADO' Tipo UNION ALL select '-1' id, 'RECUSADO' Tipo  ", "Tipo", "") %>
                    <%= quickField("datepicker", "De", "De", 2, De, "", "", "") %>
                    <%= quickField("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>

                    <div class="col-xs-2">
                    <label>&nbsp;</label><br />
                        <button type="submit" class="btn btn-sm btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
                    </div>
                </form>
            </div>
        </div>

    </div>

    <div class="panel">

        <div class="panel-body">
            <div class="col-md-12">
                <div class="row">
                    <table class="table table-striped table-hover">
                        <tr>
                            <th>Receber de</th>
                            <th>Título</th>
                            <th>Data</th>
                            <th>Desconto Pendente</th>
                            <th>Desconto Total</th>
                            <th>Quantidade</th>
                            <th>Valor</th>
                            <th>Valor Total</th>
                            <th>Percentual</th>
                            <th>Solicitante</th>
                            <th>Unidade</th>
                            <th width="1%"></th>
                        </tr>
                    <%
                        descontoPendenteSql = "select dp.DataHora, dp.id as iddesconto, dp.ItensInvoiceID, CASE " &_
                                                    "WHEN ii.Tipo='O' THEN Descricao " &_
                                                    "WHEN ii.Tipo='S' THEN (select NomeProcedimento from procedimentos p where p.id = ii.ItemID ) " &_
                                                    "WHEN ii.Tipo='M' THEN (SELECT NomeProduto from produtos p where p.id = ii.ItemID ) " &_
                                                " END AS titulo, dp.Desconto DescontoPendente, Quantidade, ValorUnitario, STATUS, " &_ 
                                                " CASE WHEN i.CompanyUnitID = 0 THEN (SELECT NomeEmpresa from empresa limit 1) " &_ 
                                                " WHEN i.CompanyUnitID > 0 THEN (select UnitName from sys_financialcompanyunits fs where fs.id = i.CompanyUnitID) " &_
                                                " END AS NomeUnidade, " &_ 
                                                " Nome, AssociationAccountID, AccountID, InvoiceID " &_ 
                                                " from descontos_pendentes dp inner join itensinvoice ii ON ii.id = dp.ItensInvoiceID " &_
                                                " inner join sys_financialinvoices i ON i.id = ii.InvoiceID " &_
                                                " inner join cliniccentral.licencasusuarios lu ON lu.id = dp.SysUser  " &_ 
                                                " where 1 =  1  "
                        if StatusDesconto <> "" then
                            descontoPendenteSql = descontoPendenteSql + " AND dp.STATUS = " & StatusDesconto
                        else 
                            descontoPendenteSql = descontoPendenteSql + " AND  dp.SysUserAutorizado is null AND dp.STATUS = 0 "
                        end if

                        if De <> "" then
                            descontoPendenteSql = descontoPendenteSql + " AND DATE(dp.DataHora) BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)
                        end if


                        descontoPendenteSql = descontoPendenteSql + " UNION ALL "

                        descontoPendenteSql  = descontoPendenteSql + " select dp.DataHora,  dp.id as iddesconto, dp.ItensInvoiceID, CASE " &_
                                                    "WHEN ii.Tipo='O' THEN Descricao " &_
                                                    "WHEN ii.Tipo='S' THEN (select NomeProcedimento from procedimentos p where p.id = ii.ItemID ) " &_
                                                    "WHEN ii.Tipo='M' THEN (SELECT NomeProduto from produtos p where p.id = ii.ItemID ) " &_
                                                " END AS titulo, dp.Desconto DescontoPendente, Quantidade, ValorUnitario, STATUS, " &_ 
                                                " CASE WHEN i.UnidadeID = 0 THEN (SELECT NomeEmpresa from empresa limit 1) " &_ 
                                                " WHEN i.UnidadeID > 0 THEN (select UnitName from sys_financialcompanyunits fs where fs.id = i.UnidadeID) " &_
                                                " END AS NomeUnidade,  " &_ 
                                                " Nome, 3 as AssociationAccountID, PacienteID as AccountID, InvoiceID  " &_ 
                                                " from descontos_pendentes dp inner join itensproposta ii ON ii.id = dp.ItensInvoiceID*-1 " &_
                                                " inner join propostas i ON i.id = ii.PropostaID " &_
                                                " inner join cliniccentral.licencasusuarios lu ON lu.id = dp.SysUser  " &_ 
                                                " where 1 =  1  "

                        if StatusDesconto <> "" then
                            descontoPendenteSql = descontoPendenteSql + " AND dp.STATUS = " & StatusDesconto
                        else 
                            descontoPendenteSql = descontoPendenteSql + " AND  dp.SysUserAutorizado is null AND dp.STATUS = 0 "
                        end if
                        if De <> "" then
                            descontoPendenteSql = descontoPendenteSql + " AND DATE(dp.DataHora) BETWEEN "&mydatenull(De)&" AND "&mydatenull(Ate)
                        end if

                        set rsDescontoPendente = db.execute(" SELECT t.* FROM ("&descontoPendenteSql&")t ORDER BY t.DataHora DESC")

                        set rsDescontosUsuario = db.execute("select suser.id, rd.id, Recursos, Unidades, rd.RegraID, Procedimentos, DescontoMaximo, TipoDesconto "&_
											" from regrasdescontos rd inner join sys_users suser on suser.Permissoes LIKE CONCAT('%[',rd.RegraID,']%') "&_
											" WHERE suser.id = "&session("User")&" AND rd.Recursos LIKE '%"&querydesconto&"%' AND (rd.Unidades LIKE '%|"& session("UnidadeID") &"|%' OR rd.Unidades = '"& session("UnidadeID") &"' OR rd.Unidades  = '' OR rd.Unidades IS NULL )")

                        if not rsDescontosUsuario.eof then 
                        while not rsDescontoPendente.eof
                            podePermitirDesconto = 0
                            while not rsDescontosUsuario.eof and podePermitirDesconto = 0
                                valorLimiteRegra = rsDescontosUsuario("DescontoMaximo")
                                if rsDescontosUsuario("TipoDesconto") = "P" then 
                                    valorLimiteRegra = rsDescontoPendente("ValorUnitario") * rsDescontosUsuario("DescontoMaximo") / 100
                                end if
                                
                                if valorLimiteRegra >= rsDescontoPendente("DescontoPendente") then
                                    podePermitirDesconto = 1

                                end if

                                rsDescontosUsuario.movenext
                            wend    
                            rsDescontosUsuario.movefirst

                            if podePermitirDesconto = 1 then

                            'Buscar o valor de receber de
                            set ass = db.execute("select `table`, `column` from sys_financialaccountsassociation WHERE id="& rsDescontoPendente("AssociationAccountID"))
	                        set reg = db.execute("select "&ass("column")&" as ReceberDe FROM "&ass("table")&" where id="&rsDescontoPendente("AccountID") )

                            jaPago = 0
                            if rsDescontoPendente("InvoiceID")&"" <> "" and StatusDesconto = "0" then
                                set pago = db.execute("select IFNULL(count(*),0) as total FROM sys_financialmovement where InvoiceID="&rsDescontoPendente("InvoiceID")&" AND ValorPago > 0"  )    
                                if not pago.eof then
                                    if ccur(pago("total")) > 0 then
                                        jaPago = 1
                                    end if
                                end if
                            end if

                            if jaPago = 1 then
                                set idsItens = db.execute("SELECT GROUP_CONCAT(ii.id) ids FROM sys_financialinvoices i INNER JOIN itensinvoice ii ON ii.InvoiceID = i.id WHERE i.id = "&rsDescontoPendente("InvoiceID")  )    
                                db.execute("UPDATE descontos_pendentes set Status = -1 where ItensInvoiceID in ( " &idsItens("ids")&") " )
                            else

                            Percentual = (rsDescontoPendente("DescontoPendente")/rsDescontoPendente("ValorUnitario")) * 100
                            ClassePercentual = ""
                            if Percentual > 80 then
                                ClassePercentual = "label label-danger"
                            end if
                            if Percentual > 50 then
                                ClassePercentual = "label label-warning"
                            end if
                        %>
                            <tr>
                                <td><% if not reg.eof then 
                                    response.write(reg("ReceberDe"))
                                else 
                                    response.write("N/D")
                                end if %></td>
                                <td><%=rsDescontoPendente("titulo")%></td>
                                <td><%=rsDescontoPendente("DataHora")%></td>
                                <th  align="center">R$ <%=formatnumber(rsDescontoPendente("DescontoPendente"), 2)%></th>
                                <th  align="center">R$ <%=formatnumber(rsDescontoPendente("DescontoPendente"), 2) * rsDescontoPendente("Quantidade")%></th>
                                <td align="center"><%=rsDescontoPendente("Quantidade")%></td>
                                <td  align="center">R$ <%=formatnumber(rsDescontoPendente("ValorUnitario"), 2)%></td>
                                <td  align="center">R$ <%=formatnumber(rsDescontoPendente("ValorUnitario"), 2) * rsDescontoPendente("Quantidade")%></td>
                                <td  align="center"><span class="<%=ClassePercentual%>"><%= fn(Percentual)%>%</span></td>
                                <td><%=rsDescontoPendente("Nome")%></td>
                                <td><%=rsDescontoPendente("NomeUnidade") %></td>
                                <% if rsDescontoPendente("STATUS") = "0" then %>
                                <td nowrap="nowrap">
                                    <div class="action-buttons">
                                        <%
                                            link = "./?P=DescontoPendente&I="&rsDescontoPendente("iddesconto")&"&Pers=1"
                                        %>
                                        <a title="Aprovar" class="btn btn-xs btn-success" href="<%=link%>&OP=1" onclick="aprovarDesconto(this)"><i class="far fa-check-square bigger-130"></i></a>
                                        <a title="Não Aprovar" class="btn btn-xs btn-danger" href="<%=link%>&OP=-1" onclick="rejeitarDesconto(this)"><i class="far fa-times bigger-130"></i></a>
                                    </div>
                                </td>
                                <% end if %>

                            </tr>
                        <% 
                            end if
                            end if
                            rsDescontoPendente.movenext
                        wend
                        end if
                    %>
                    </table>
                </div>
            </div>
            
        </div>

    </div>

<script>
    function aprovarDesconto($el){
        if(confirm("Deseja aprovar o desconto?")){
            $($el).attr("disabled", true);

            return true;
        }
    }


    function rejeitarDesconto($el){
        if(confirm("Deseja reprovar o desconto?")){
            $($el).attr("disabled", true);

            return true;
        }
    }
</script>