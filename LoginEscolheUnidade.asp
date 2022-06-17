<!--#include file="connect.asp"-->
<%
set UltimaUnidadeSQL  = db.execute("SELECT UnidadeID FROM sys_users WHERE id="&session("User"))

if not UltimaUnidadeSQL.eof then
    UnidadeID=UltimaUnidadeSQL("UnidadeID")

    if isnumeric(UnidadeID) then
        UnidadeID=ccur(UnidadeID)
    end if
end if

IF session("UnidadeID") >= "0" THEN
    UnidadeID = session("UnidadeID")
END IF



%>
<div class="modal-header">
    <h4 class="modal-title">Selecione a Unidade</h4>
</div>
<div class="modal-body">

    <div class="row">
    <%
        unidadeDisabled=False

        if session("CaixaID")<>"" then
            unidadeDisabled=True
            msgUnidadeDisabled="Existe um caixa aberto na unidade que está logado. Para alterar, feche seu caixa."
        end if
        if unidadeDisabled then
            %>
<div class="col-md-12">
<div class="alert alert-danger">
    <strong>Atenção!</strong> <%=msgUnidadeDisabled%>
</div>
</div>
            <%
        else
%>

<%
        end if
    %>
        <div class="col-md-12">
            <p>Selecione a <strong>unidade</strong> que está atualmente:</p>
        </div>
        <%


        set UnidadesSQL = db.execute("SELECT id, NomeFantasia FROM (select id, NomeFantasia, 0 Matriz from sys_financialcompanyunits where sysActive=1 UNION ALL select '0', NomeFantasia, 1 Matriz from empresa order by id) t WHERE '"&session("Unidades")&"' LIKE CONCAT('%|',id,'|%') ORDER BY Matriz desc, NomeFantasia")
        set getUnidades = db.execute("select Unidades from "&session("Table")&" where id="&session("idInTable"))
		selectUnidades = getUnidades("Unidades")

        while not UnidadesSQL.eof
            if instr(selectUnidades,"|"&UnidadesSQL("id")&"|")>0 then 
            %>
            <div <% if unidadeDisabled then %> style="opacity: .4" <% end if %> class="col-md-6 pt10">
                <a style="font-size: 11px" <% if not unidadeDisabled then %> href="?P=MudaLocal&Pers=1&MudaLocal=<%=UnidadesSQL("id")%>" <% else %> disabled onclick="alert('Você precisa fechar o caixa para alterar a unidade.')" <% end if%> class="btn
                 <%
                 if UnidadesSQL("id")&""=UnidadeID&"" then
                 %>btn-dark<%
                 else
                 %>btn-default<%
                 end if
                 %>
                 btn-block" ><i class="far fa-building"></i> <%=UnidadesSQL("NomeFantasia")%></a>
            </div>
            <%
            end if 
        UnidadesSQL.movenext
        wend
        UnidadesSQL.close
        set UnidadesSQL=nothing
        %>
    </div>
</div>
<!--#include file="disconnect.asp"-->