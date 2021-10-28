<!--#include file="connect.asp"-->
<%
txt = replace(req("txt"), " ", "%")

IF ModoFranquia THEN
    sqlAM = "select RegistroANS, id, NomeConvenio, RazaoSocial, Unidades, CamposObrigatorios, TipoAtendimentoID, registroans from convenios where sysActive=1 and Ativo='on' and (NomeConvenio like '%"& txt &"%' or id like '%"& txt &"%')"
    sqlAM = "SELECT * FROM ("&sqlAM&") as T "&franquia(" WHERE COALESCE(cliniccentral.overlap(Unidades,COALESCE(NULLIF('[Unidades]',''),'-999')),TRUE)")
    set conv = db.execute(sqlAM)
ELSE
    set conv = db.execute("select RegistroANS, id, NomeConvenio, RazaoSocial, Unidades, CamposObrigatorios, TipoAtendimentoID from convenios where sysActive=1 and Ativo='on' and (NomeConvenio like '%"& txt &"%' or id like '%"& txt &"%')")
END IF
if not conv.eof then

'---> Rotina pra mostrar ou não o link de extrato
set aass = db.execute("select * from cliniccentral.sys_financialaccountsassociation where `table` like 'convenios'")
if not aass.eof then
        associacao = aass("id")
end if
'<--- Rotina pra mostrar ou não o link de extrato
%>

<h4>Convênios Encontrados</h4>
<table class="table table-striped table-bordered table-condensed">
    <thead>
        <tr class="primary">
            <th>Nome</th>
            <th>Razão Social</th>
            <th>Unidades</th>
            <th>Campos Obrigatorios</th>
            <th>Tipo de Atendimento</th>
            <th width="1%"></th>
        </tr>
    </thead>
    <tbody>
        <%
        while not conv.eof
            if conv("registroans") = "simplificado" then
                tipodeconvenio =  "&nbsp;&nbsp;&nbsp;<span class='badge badge-info'>Simplificado</span>"
            else
                tipodeconvenio = ""
            end if
            %>
            <tr>
                <td><a href="./?P=Convenios&I=<%=conv("id") %>&Pers=1"> <%= conv("NomeConvenio") %></a> <%= tipodeconvenio %></td>
                <td><%= conv("RazaoSocial") %></td>
                <td><%= conv("Unidades") %></td>
                <td><%= conv("CamposObrigatorios") %></td>
                <td><%= conv("TipoAtendimentoID") %></td>
                <td nowrap>
                    <% if aut("|conveniosA|")=1 then %>
                        <% if conv("registroans") = "simplificado" then %>
                            <a href="./?P=ConveniosSimplificado&I=<%=conv("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-edit"></i></a>
                        <%else%>
                            <a href="./?P=Convenios&I=<%=conv("id") %>&Pers=1" class="btn btn-xs btn-primary"><i class="fa fa-edit"></i></a>
                        <%end if%>
                    <%end if %>

                    <%if associacao<>"" then%>
                        <a class="btn btn-xs btn-success tooltip-success" title="Extrato" data-rel="tooltip" href="?P=Extrato&Pers=1&T=<%=associacao%>_<%=conv("id")%>"><i class="fa fa-money bigger-130"></i></a>
                    <%end if %>
                    
                    <% if aut("|conveniosX|")=1 then %>
                        <a class="btn btn-xs btn-danger tooltip-danger" title="" data-rel="tooltip" href="javascript:if(confirm('Tem certeza de que deseja excluir este registro?'))location.href='?P=Convenios&X=<%= conv("id") %>&Pers=Follow';"><i class="far fa-remove bigger-130"></i></a>
                    <% end if %>

                </td>
            </tr>
            <%
        conv.movenext
        wend
        conv.close
        set conv = nothing
        %>
    </tbody>
</table>
<%
else
    %>
    Nenhum convênio ativo com o termo '<%= txt %>'.
    <%
end if

%>