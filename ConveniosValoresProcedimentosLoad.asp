<!--#include file="connect.asp"-->
<!--#include file="Classes\ValorProcedimento.asp"-->
<%
loadMore = 0
MaximoLimit = 50
if req("ConvenioID") <>"" then
    ConvenioID = req("ConvenioID")
end if

if req("loadMore") <> "" then
    loadMore = req("loadMore")
end if 
limit = "limit "&loadMore&","&MaximoLimit

if req("txt")<>"" then
    limit = ""
end if

IF limit = "" THEN
    limit = "limit 150"
END IF

txt = replace(req("txt"), " ", "%")

sqlProcedimentos = "select p.id as ProcID, p.NomeProcedimento, v.*, v.id as PvId, pt.*, tc.CodigoTabela, (SELECT group_concat(DISTINCT CodigoNaOperadora) FROM contratosconvenio cc WHERE v.Contratados like CONCAT('%|',cc.id,'|%') AND CodigoNaOperadora <> '' ) as CodigoNaOperadora  from procedimentos as p "&_
                    "left join tissprocedimentosvalores as v on (v.ProcedimentoID=p.id and v.ConvenioID="&ConvenioID&") "&_
                    "left join tissprocedimentostabela as pt on (v.ProcedimentoTabelaID=pt.id)"&_
                    "left join tabelasconvenios as tc on (IF(pt.TabelaID < 0, (pt.TabelaID)*-1 = tc.id, pt.TabelaID = tc.id))"&_
                    "where (p.NomeProcedimento like '%"&txt&"%' or p.Codigo = '"&txt&"' ) and p.sysActive=1 and Ativo='on' and (v.ConvenioID="&ConvenioID&" or v.ConvenioID is null) and (isnull(SomenteConvenios) or SomenteConvenios like '%|"&ConvenioID&"|%' or SomenteConvenios like '') and (SomenteConvenios not like '%|NONE|%' or isnull(SomenteConvenios)) order by (IF(v.id IS NOT NULL, 0,1)) , NomeProcedimento "&limit

    set proc = db.execute(sqlProcedimentos)
if not proc.eof then
%>

 <table class="table table-striped table-hover table-bordered table-condensed">
        <thead><tr>
            <th></th>
            <th>Procedimento</th>
            <th>Tabela</th>
            <th>C&oacute;digo</th>
            <th>Código na Operadora</th>
            <th>Descri&ccedil;&atilde;o</th>
            <th>T&eacute;cnica</th>
            <th>Valor</th>
            <%
            if false then
                splNomePlano = split(strNomePlano, "|")
                for i=0 to ubound(splNomePlano)
                    if splNomePlano(i)<>"" then
                        %>
                        <th><%=splNomePlano(i)%></th>
                        <%
                    end if
                next
            end if
            %>
            <th width="1%"></th>
        </tr></thead>
        <tbody>
<%


IF getConfig("calculostabelas") THEN
    On Error Resume Next
        ProcessarTodasAssociacoes(ConvenioID)
    On Error Goto 0
END IF

while not proc.eof
    if isnull(proc("Valor")) then
        Valor=""
    else
        Valor=formatnumber(proc("Valor"),2)
    end if

    IF proc("PvId") > 0 AND getConfig("calculostabelas") THEN
        IF NOT isnull(proc("ValorConsolidado")) THEN
            Valor=formatnumber(proc("ValorConsolidado"),2)
        ELSE
            set reg = CalculaValorProcedimentoConvenio(proc("PvId"),ConvenioID,proc("ProcID"),null,null,null,null,null)
            On Error Resume Next
                ProcID = reg("AssociacaoID")
                Valor = "R$"&fn(reg("TotalGeral")+CalculaValorProcedimentoConvenioAnexo(ConvenioID,proc("ProcID"),reg("AssociacaoID"),null))
            On Error Goto 0
        END IF
    END IF

    codigoTabela = proc("TabelaID")
    IF proc("TabelaID") < 0 then
        codigoTabela = proc("CodigoTabela")
    END IF

    response.flush()

    %><tr id="<%=proc("ProcID")%>">
        <td><% if aut("|conveniosA|")= 1 then %><button type="button" onclick="editaValores(<%=proc("ProcID")%>, <%=ConvenioID%>,<%=proc("PvId")%>);" class="btn btn-xs btn-success"><i class="far fa-edit"></i></button><% end if %></td>
        <td><%=proc("NomeProcedimento")%></td>
        <td class="text-right"><%=codigoTabela%></td>
        <td class="text-right"><%=proc("Codigo")%></td>
        <td class="text-right"><%=proc("CodigoNaOperadora")%></td>
        <td><%=proc("Descricao")%></td>
        <td class="text-right"><%=proc("TecnicaID")%></td>
        <td class="text-right"><%=Valor%></td>
        <%
        if false then
            splPlanoID = split(strPlanoID, "|")
            for j=0 to ubound(splNomePlano)
                if splPlanoID(j)<>"" then
                    ValorPlano = ""
                    set valPlan = db.execute("select * from tissprocedimentosvaloresplanos where PlanoID="&splPlanoID(j)&" and AssociacaoID like '"&proc("PvId")&"'")
                    if not valPlan.EOF then
                        if valPlan("NaoCobre")="S" then
                            ValorPlano = "<i class=""far fa-ban-circle""></i>"
                        else
                            ValorPlano = formatnumber(valPlan("Valor"),2)
                        end if
                    end if
                    %>
                    <td class="text-right"><%=ValorPlano%></td>
                    <%
                end if
            next
        end if
        %>
        <td nowrap>
            <%
            if proc("id") > 0 then
                %>
                <a  class="btn btn-primary btn-xs" onclick="clonarAssociacao(<%=proc("PvId")%>);"><i class="far fa-copy bigger-130"></i></a>
                <a  class="btn btn-danger btn-xs" onclick="removeAssociacao(<%=proc("PvId")%>);" ><i class="far fa-remove bigger-130"></i></a>
                <%
            end if
            %>
        </td>
    </tr><%
proc.movenext
wend
proc.close
set proc = nothing
%>
        </tbody>
    </table>
</div>
<%
end if
%>
