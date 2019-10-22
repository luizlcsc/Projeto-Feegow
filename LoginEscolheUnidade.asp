<!--#include file="connect.asp"-->
<%
set UltimaUnidadeSQL  = db.execute("SELECT UnidadeID FROM sys_users WHERE id="&session("User"))

if not UltimaUnidadeSQL.eof then
    UnidadeID=UltimaUnidadeSQL("UnidadeID")

    if isnumeric(UnidadeID) then
        UnidadeID=ccur(UnidadeID)
    end if
end if

%>
<div class="modal-header">
    <h4 class="modal-title">Selecione a Unidade</h4>
</div>
<div class="modal-body">

    <div class="row">
        <div class="col-md-12">
            <p>Selecione a <strong>unidade</strong> que está atualmente:</p>
        </div>
        <%
        set UnidadesSQL = db.execute("SELECT id, NomeFantasia FROM (select id, NomeFantasia from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia from empresa order by id) t WHERE '"&session("Unidades")&"' LIKE CONCAT('%|',id,'|%')")

        while not UnidadesSQL.eof
            %>
            <div class="col-md-6 pt10">
                <a style="font-size: 11px" href="?P=Home&Pers=1&MudaLocal=<%=UnidadesSQL("id")%>" class="btn
                 <%
                 if UnidadesSQL("id")&""=UnidadeID&"" then
                 %>btn-dark<%
                 else
                 %>btn-default<%
                 end if
                 %>
                 btn-block"><i class="fa fa-building"></i> <%=UnidadesSQL("NomeFantasia")%></a>
            </div>
            <%
        UnidadesSQL.movenext
        wend
        UnidadesSQL.close
        set UnidadesSQL=nothing
        %>
    </div>
</div>