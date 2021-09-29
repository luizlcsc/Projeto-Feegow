<!--#include file="connect.asp"-->
<!--#include file="modal.asp"--> 
<%
'on error resume next

Data = req("Data")
if Data = "" then
	Data = date()
end if

Mes = month(Data)
Ano = year(Data)

if req("De")="" then
    De = DiaMes("P", Data)
else
    De = req("De")
end if
if req("Ate")="" then
    Ate = DiaMes("U", Data)
else
    Ate = req("Ate")
end if

response.Buffer
%>
<% if req("R")="" then %>
<form method="get" action="PrintStatement.asp" id="frmfiltros" target="_blank">
    <input type="hidden" name="R" value="AnaliseReceitas" />
    <!-- <input type="hidden" name="Pars" value="<%=tipo%>"> -->
    <div class="row">
        <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
        <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
        <div class="col-md-2">
            <!-- <button type="button" class="mt25 btn btn-primary" onclick="javascript:callReport('AnaliseReceitas', 'RECEITAS&U=|0|, |1|&De='+ $('#De').val() +'&Ate='+ $('#Ate').val() );">GERAR</button>-->
            <button type="submit" class="mt25 btn btn-primary" > GERAR</button>
        </div>
    </div> 
</form>
<% else %>

<h1 class="text-center">Análise de Receitas</h1>
<h4 class="text-center">De <%= De %> a <%= Ate %></h4>

<table class="table table-condensed table-hover">
    <tbody>
    <%
    db_execute("delete from cliniccentral.rel_plano WHERE sysUser="& session("User"))

    db_execute("insert INTO cliniccentral.rel_plano (sysUser, `Date`, `Type`, Value, AccountIDDebit, AccountAssociationIDDebit, PaymentMethodID, ItemIDDescontado, PagamentoID, ValorDescontado, Tipo, ItemID, CategoriaID, GrupoID, Descricao) SELECT "& session("User") &" sysUser, m.Date, m.`Type`, m.Value, m.AccountIDDebit, m.AccountAssociationIDDebit, m.PaymentMethodID, idesc.ItemID ItemIDDescontado, idesc.PagamentoID, idesc.Valor ValorDescontado, ii.Tipo, ii.ItemID, IFNULL(ii.CategoriaID, 0) CategoriaID, ifnull(proc.GrupoID, 0) GrupoID, ii.Descricao FROM sys_financialmovement m LEFT JOIN itensdescontados idesc ON idesc.PagamentoID=m.id LEFT JOIN itensinvoice ii ON ii.id=idesc.ItemID LEFT JOIN procedimentos proc ON proc.id=ii.ItemID WHERE m.Date BETWEEN "& mydatenull(De) &" AND "& mydatenull(Ate) &" AND m.`Type`!='Bill' AND m.CD='D' AND m.PaymentMethodID IN (1, 2, 3, 4, 5, 6, 7) AND m.Value>0")


    set cat1 = db.execute("SELECT DISTINCT rp.Tipo, (select sum(ValorDescontado) FROM cliniccentral.rel_plano WHERE sysUser="& session("User") &" AND Tipo=rp.Tipo) Total FROM cliniccentral.rel_plano rp WHERE rp.sysUser="& session("User") &" ORDER BY Tipo DESC")
    c1 = 0

    while not cat1.eof
        c1 = c1+1
        sqlCat2 = ""
        %>
        <tr>
            <td><%= c1 &". "& ucase(descTI(cat1("Tipo"))) %></td>
            <td class="text-right"><em><%= fn(cat1("Total")) %></em></td>
        </tr>
        <%
        sqlCat2=""

        if cat1("Tipo")="S" then
            sqlCat2 = "SELECT DISTINCT c.GrupoID Cat2ID, IF(c.GrupoID=0, 'Outros grupos de serviços', g.NomeGrupo) Descricao, "&_
            " (select sum(ValorDescontado) from cliniccentral.rel_plano where sysUser="& session("User") &" and Tipo='S' and GrupoID=c.GrupoID) Total "&_
            " FROM cliniccentral.rel_plano c LEFT JOIN procedimentosgrupos g ON g.id=c.GrupoID WHERE c.sysUser="& session("User") &""
        elseif cat1("Tipo")="O" then
            sqlCat2 = "SELECT DISTINCT c.CategoriaID Cat2ID, IF(c.CategoriaID=0, 'Outras categorias', g.Name) Descricao, "&_
            " (select sum(ValorDescontado) from cliniccentral.rel_plano where sysUser="& session("User") &" and Tipo='O' and CategoriaID=c.CategoriaID) Total "&_
            " FROM cliniccentral.rel_plano c LEFT JOIN sys_financialincometype g ON g.id=c.CategoriaID WHERE c.sysUser="& session("User") &""
        end if

        'response.write( sqlCat2 )

        if sqlCat2<>"" then
            set cat2 = db.execute("SELECT * FROM ("& sqlCat2 &") t ORDER BY t.Descricao")
            'set cat2 = db.execute( sqlCat2 )

            c2 = 0
            while not cat2.eof
                c2 = c2+1
                %>
                <tr>
                    <td> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%= c1 &"."& c2 &". "& ucase(cat2("Descricao")&"") %></td>
                    <td class="text-right"><em><%= fn(cat2("Total")) %></em></td>
                </tr>
                <%
                if cat1("Tipo")="S" then
                    sqlCat3 = "SELECT DISTINCT c.ItemID Cat3ID, proc.NomeProcedimento Descricao, "&_
                    " ifnull((select sum(ValorDescontado) from cliniccentral.rel_plano where sysUser="& session("User") &" and Tipo='S' and ItemID=c.ItemID), 0) Total "&_
                    " FROM cliniccentral.rel_plano c LEFT JOIN procedimentos proc ON proc.id=c.ItemID WHERE c.sysUser="&session("User")&" AND c.GrupoID="& cat2("Cat2ID") &" ORDER BY proc.NomeProcedimento"
                elseif cat1("Tipo")="O" then
                    sqlCat3 = "SELECT DISTINCT IFNULL(c.Descricao, '') Cat3ID, IF(c.Descricao='', 'Não especificado', c.Descricao) Descricao, ValorDescontado Total FROM cliniccentral.rel_plano c WHERE c.sysUser="&session("User")&" AND c.CategoriaID="& cat2("Cat2ID") &" and c.Tipo='O' ORDER BY c.Descricao"
                end if

                c3 = 0
                'response.write( sqlCat3 )
                set cat3 = db.execute( sqlCat3 )
                while not cat3.eof
                    if ccur(cat3("Total"))>0 then
                        c3 = c3+1
                        %>
                        <tr>
                            <td> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%= c1 &"."& c2 &"."& c3 &". "& ucase(cat3("Descricao")&"") %></td>
                            <td class="text-right"><%= fn(cat3("Total")) %></td>
                        </tr>
                        <%
                    end if
                    response.Flush()
                cat3.movenext
                wend
                cat3.close
                set cat3 = nothing

                response.Flush()
            cat2.movenext
            wend
            cat2.close
            set cat2 = nothing
        end if
        response.Flush()
    cat1.movenext
    wend
    cat1.close
    set cat1 = nothing

'    db_execute("delete from cliniccentral.rel_plano WHERE sysUser="& session("User"))
    %>
    </tbody>
</table>

<% end if %>

<script>
function cd(CategoriaID) {
	var empresas = ('<%=req("U")%>')
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $("#modal-table").modal("show");
    $.get("PlanoDespModal.asp?C=" + CategoriaID + "&Empresas=" + empresas, function (data) {
        $("#modal").html(data);
    });
}


<!--#include file="JQueryFunctions.asp"-->
</script>