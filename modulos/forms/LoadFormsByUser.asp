<!--#include file="./../../connect.asp"-->
<%
PacienteID=req("PacienteID")
Tipo=req("Tipo")
EspecialidadeID=req("EspecialidadeID")
ForceLoadForms = req("force")&"" = "1"
EmAtendimento = req("EmAtendimento")

CookieId = "FormIds"&Tipo

FormIds = request.Cookies(CookieId)

if Tipo="|AE|" OR Tipo=InserirDinamico then
    subTitulo = "Anamneses e Evoluções"
    rotuloBotao = "Inserir Anamnese / Evolução"
    sqlForm = " bf.Tipo IN(1,2) "
else
    subTitulo = "Laudos e Formulários"
    rotuloBotao = "Inserir Laudo / Formulário"
    sqlForm = " ( bf.Tipo IN (3,4,0) OR ISNULL(bf.Tipo) ) "
end if

if False then
    set UltimosFormsSQL = db.execute("SELECT GROUP_CONCAT(DISTINCT ModeloID) modelos FROM ( "&_
    "SELECT bp.ModeloID, COUNT(bp.id) qtd from buiformspreenchidos bp join buiforms b on b.id=ModeloID WHERE bp.DataHora >= DATE_SUB(NOW(), INTERVAL 30 DAY) and bp.sysUser="&session("User")&" and   "&sqlForm&"  "&_
    "GROUP BY bp.ModeloID "&_
    "ORDER BY qtd desc "&_
    "LIMIT 5 "&_
    ")t ")

    if not UltimosFormsSQL.eof then
        favoritos = UltimosFormsSQL("modelos")
        if favoritos<> "" then
            sqlOrderFavoritos = " IF(bf.id in ("&favoritos&"),0,1),"
        end if
    end if
end if

if FormIds="" or ForceLoadForms = True then
    FormIds=""
    
    sqlBuiforms = "select bf.Nome,bf.id, count(bp.id)qtdPermissoes from buiforms bf LEFT JOIN buipermissoes bp ON bp.FormID=bf.id where bf.sysActive=1 and "& sqlForm &" GROUP BY bf.id order by "&sqlOrderFavoritos&" bf.Nome"

    set forms = db.execute(sqlBuiforms)

    while not forms.eof
        hasPermissao = False
        
        hasPermissao = forms("qtdPermissoes")&""="0"

        if not hasPermissao then
            hasPermissao = autForm(forms("id"), "IN", "", EspecialidadeID)
        end if

        if hasPermissao then

            if FormIds="" then
                FormIds=forms("id")&""
            else
                FormIds=FormIds&","&forms("id")
            end if

        end if
    forms.movenext
    wend
    forms.close
    set forms = nothing
    
    if FormIds<>"" then
        response.Cookies(CookieId)=FormIds
        Response.Cookies(CookieId).Expires = Date() + 1
    end if

end if

if FormIds<>"" then
    set FormSQL = db.execute("SELECT id,Nome from buiforms WHERE id IN ("&FormIds&") order by Nome")

    while not FormSQL.eof
        formId = FormSQL("id")

        badgeFavorito = ""

        if instr(favoritos, formId) then
            badgeFavorito = " <i class='fas fa-star text-warning'></i>"
        end if
        %>
        <li  <% if EmAtendimento=0 then%>disabled data-toggle="tooltip" title="Inicie um atendimento." data-placement="right"<% end if%>><a  <% if EmAtendimento=1 then%>
        href="#" onclick="iPront('<%=replace(Tipo, "|", "") %>', '<%=PacienteID%>', '<%=formId%>', 'N', '');" <% end if %>><i class="far fa-plus"></i> <%=FormSQL("Nome")%> <%=badgeFavorito%></a> </li>
        <%
    FormSQL.movenext
    wend
    FormSQL.close
    set FormSQL=nothing
end if

if aut("buiformsI") and session("Banco")<>"clinic522" then
    %>
    <li class="divider"></li>
    <li><a href="./?P=buiforms&Pers=Follow"><i class="far fa-cog"></i> Gerenciar modelos de <%=lcase(subTitulo) %></a></li>
    <%
end if

if false then
%>
<li class="text-right" title="Recarregar listagem"><a href="#" onclick="loadFormOptions('<%=Tipo%>', '<%=PacienteID%>', true)"><i class="far fa-refresh"></i> </a></li>
<%
end if
%>
