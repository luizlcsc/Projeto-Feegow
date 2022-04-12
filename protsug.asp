<!--#include file="connect.asp"-->
<%
CampoID = req("CampoID")
Origem = req("Origem")
Txt = replace(trim(lcase(ref("T"))), " ", "%")
FormID = req("FormID")
conta = 0
Tipo = req("Tipo")
Subgrupo = req("Subgrupo")

select case Tipo
    case "CidCiap"
        set pcampo = db.execute("select c.Estruturacao FROM buicamposforms c WHERE id="& CampoID)
        Estruturacao = pcampo("Estruturacao")&""
        if instr(Estruturacao, "|CID|")>0 and instr(Estruturacao, "|Tags|")>0 then
            sqlUNION = " UNION ALL "
        end if
        if instr(Estruturacao, "|Tags|")>0 then
            sqlTags = " SELECT 'Tag' numero, (id*(-1)) id, '' CID10_Cd1, Tag Termo FROM Tags WHERE Tag LIKE '%"& right(Txt, 5) &"%' "
            if Origem="Cid" then
                sqlTags = sqlTags & " UNION ALL SELECT 'ADICIONAR >>>', '0', '', '"& ref("T") &"' "
            end if
        end if

        if instr(Estruturacao, "|CID|")>0 then
            palavrasDesconsiderar = "paciente, de , da , do , das , dos , uma , um , o , a , e , no , na , nas , nos , em , um ,relata,refere,trata,cliente"
            spl = split(palavrasDesconsiderar, ",")
            for i=0 to ubound(spl)
                Txt = replace(Txt, spl(i), " ")
            next
            Termo = replace(Txt, " ", "%")
            sqlCidCiap = " select '1' numero, t.id, t.CID10_Cd1, c.Descricao from cliniccentral.tesauro t LEFT JOIN cliniccentral.cid10 c ON c.codigo = REPLACE(t.CID10_Cd1,'.','') where t.CID10_Cd1<>'' AND (t.Termo LIKE '%"& right(Termo, 10) &"%' or t.CID10_Cd1 LIKE '%"& right(Termo, 10) &"%')"&_
                " UNION ALL "&_
                " select '2' numero, t.id, t.CID10_Cd1, c.Descricao from cliniccentral.tesauro t LEFT JOIN cliniccentral.cid10 c ON c.codigo = REPLACE(t.CID10_Cd1,'.','') where t.CID10_Cd1<>'' AND t.Termo LIKE '%"& right(Termo, 7) &"%'"
        end if

        if sqlCidCiap<>"" or sqlTags<>"" then
            sql = "select id, numero, CID10_Cd1, Descricao as Termo from ("& sqlCidCiap & sqlUNION & sqlTags &") tab GROUP BY CID10_Cd1 ORDER BY numero, CID10_Cd1 LIMIT 50"
            ' response.write( sql )
            set ciap = db.execute( sql )
            if not ciap.eof then
                %>
                <table class="table table-condensed table-hover">
                <%
                while not ciap.eof
                    conta = conta+1
                    %>
                    <tr onclick="protAdd('ciapAdd', <%= ciap("id") &", "& FormID &", "& CampoID %>)">
                        <td><code><%= ciap("numero") %></code> <%= ciap("CID10_Cd1") %></td>
                        <td><%= ciap("Termo") %></td>
                    </tr>
                    <%
                ciap.movenext
                wend
                ciap.close
                set ciap = nothing
                %>
                </table>
                <%
            end if
        end if
    case "Medicamento"
        sql = "select * from cliniccentral.medicamentos2 where NomeMedicamento LIKE '%"& Txt &"%' GROUP BY NomeMedicamento ORDER BY NomeMedicamento LIMIT 30"
        'response.write( sql )
        set ciap = db.execute( sql )
        if not ciap.eof then
            %>
            <table class="table table-condensed table-hover">
            <%
            while not ciap.eof
                conta = conta+1
                %>
                <tr onclick="protAdd('prescAdd', <%= ciap("id") &", "& FormID &", "& CampoID %>); $('#Campo<%= CampoID %>').val('');">
                    <td><%= ciap("NomeMedicamento") %></td>
                    <td><%= ciap("FabricanteMedicamento") %></td>
                    <td><%= ciap("TitularidadeMedicamento") %></td>
                </tr>
                <%
            ciap.movenext
            wend
            ciap.close
            set ciap = nothing
            %>
            </table>
            <%
        end if
    case "Pedido"
        if len(Subgrupo)>1 then
        '    sqlSubgrupo = " AND Subgrupo LIKE '%"& Subgrupo &"%' "
        end if
        sql = "select id, codigo, descricao from cliniccentral.tusscorrelacao where (codigo LIKE '%"& Txt &"%' OR descricao LIKE '%"& Txt &"%') AND Descricao IS NOT NULL "& sqlSubgrupo &" "&_
                " UNION ALL "&_
                " SELECT -1, '000000', '"& ref("T") &" - ADICIONAR' "&_
                " ORDER BY descricao LIMIT 50"
        'response.write( sql )
        set ciap = db.execute( sql )
        if not ciap.eof then
            %>
            <table class="table table-condensed table-hover">
            <%
            while not ciap.eof
                conta = conta+1
                %>
                <tr onclick="protAdd('pedAdd', <%= ciap("id") &", "& FormID &", "& CampoID %>); $('#Campo<%= CampoID %>').val('');">
                    <td><%= ciap("codigo") %></td>
                    <td><%= ciap("descricao") %></td>
                </tr>
                <%
            ciap.movenext
            wend
            ciap.close
            set ciap = nothing
            %>
            </table>
            <%
        end if
end select
%>

<script type="text/javascript">
<%
    if conta> 0 then
        %>$("#sugCid<%= CampoID%>").fadeIn();<%
    else
        %>$("#sugCid<%= CampoID%>").fadeOut();<%
    end if
%>
</script>