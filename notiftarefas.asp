<!--#include file="connect.asp"-->
<%
set us = db.execute("select notiftarefas from sys_users where id="&session("User"))
nt = us("notiftarefas")&""
spl = split(nt, "|")
for i=0 to ubound(spl)
    item = spl(i)
    if instr(item, ",")>0 then
        spl2 = split(item, ",")
        id = spl2(0)
        if id<>"" and isnumeric(id) then
            strIds = strIds & id & ", "
        end if
    end if
next

if strIds<>"" then


    'set tar = db.execute("select t.id, t.Titulo, t.De, t.DtAbertura, lu.Nome from tarefas t LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=t.De where (t.De="&session("User")&" and t.staDe='Pendente') or (t.Para like '|"&session("User")&"|' and t.staPara='Pendente')")
    set tar = db.execute("select t.id, t.Titulo, t.De, t.DtAbertura, lu.Nome from tarefas t LEFT JOIN cliniccentral.licencasusuarios lu on lu.id=t.De where t.id IN("& strIds &" 0) AND (staDe != 'Finalizada' OR staPara != 'Finalizada' ) ORDER BY 1 DESC ")
    while not tar.eof
        link = "?P=tarefas&Pers=1&I="&tar("id")
        Foto = FotoInTable(tar("De"))&""
        %>
        <div class="media">
            <a class="media-left" href="#">
                <% if len(Foto)>3 then %>
                <img class="media-object mw40" alt="64x64" src="<%=Foto %>">
                <%else %>
                <span class="glyphicon glyphicon-user text-info"></span> 
                <%end if %>
            </a>
            <div class="media-body">
            <h5 class="media-heading"><a href="<%=link %>"><%=tar("Titulo")%></a>
                <small class="text-muted"></small>
            </h5>por <%=tar("Nome") %> - <%=tar("DtAbertura") %>
                            
            </div>
            <div class="media-right">
            <div class="media-response"> Ação</div>
            <div class="btn-group">
                <button type="button" onclick="staTar(<%=tar("id") %>)" class="btn btn-default btn-xs light" data-rel="tooltip" data-placement="right" title="" data-original-title="Marcar como finalizada.">
                <i class="fa fa-check text-success"></i>
                </button>
                <button type="button" onclick="location.href='<%=link %>';" class="btn btn-default btn-xs light" data-rel="tooltip" data-placement="right" title="" data-original-title="Abrir tarefa.">
                <i class="fa fa-edit"></i>
                </button>
            </div>
            </div>
        </div>
        <%
    tar.movenext
    wend
    tar.close
    set tar=nothing
end if
%>
<script type="text/javascript">
function staTar(I){
    $.get("tarefaSave.asp?I="+I+"&onlySta=auto&Val=Finalizada", function(data){eval(data);notifTarefas();});
}

<!--#include file="jQueryFunctions.asp"-->
</script>