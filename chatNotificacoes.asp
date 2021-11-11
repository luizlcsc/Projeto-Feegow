<!--#include file="connect.asp"-->
<%
Pesq=req("Pesq")
%>

<script>
pesquiArgs = '<%=Pesq %>';
let options = {
  valueNames: [ 'nome' , 'online']
};

let userList = new List('chatUsers', options);
userList.sort('online', { order: "asc" });
userList.search(pesquiArgs);

$("#txtPesquisar").val(pesquiArgs);


</script>
<h5 class="title-divider text-muted mt30 mb10">USUÁRIOS</h5>

<div class="panel mbn panel-chat">
        <div id="chatUsers"  class="tab-content br-n pn">
            <input id="txtPesquisar" class="search form-control" placeholder="Pesquisar" autocomplete="off" />

            
<br>
            <ul class="media-list list" role="menu">
<%
'set u = db.execute("select id from sys_users where id<>"&session("User")&" and Permissoes like '%chatI%'")
'set u = db.execute("select p.NomeProfissional Nome, p.Foto, p.id from profissionais p where p.sysActive=1 UNION ALL select f.NomeFuncionario, f.Foto, f.id from funcionarios f where f.sysActive=1 ORDER BY Nome")
set u = db.execute("select Nome, Foto, t.id, t.Table, UltRef, chat.DataHora FROM ("&_
                   " SELECT p.NomeProfissional Nome, p.Foto, sp.id, sp.`Table`, sp.UltRef from profissionais p LEFT JOIN sys_users sp on sp.idInTable=p.id and sp.`Table` like 'profissionais' where p.sysActive=1 and p.Ativo='on' and not isnull(sp.`id`)  "&_
                   " UNION ALL select f.NomeFuncionario, f.Foto, sf.id, sf.`Table`, sf.UltRef from funcionarios f LEFT JOIN sys_users sf on sf.idInTable=f.id and sf.`Table` like 'funcionarios' where f.sysActive=1 and not isnull(sf.`id`) and f.Ativo='on'"&_
                   " )t"&_
                   " LEFT JOIN chatmensagens chat ON (de="&session("User")&" AND chat.Para=t.id) OR (chat.para="&session("User")&" AND chat.De=t.id)"&_
                   "  GROUP BY t.id"&_
                   "  ORDER BY chat.DataHora DESC, Nome")
'set u = db.execute("select su.id, su.`Table`, f.NomeFuncionario NomeFuncionarios, f.Foto FotoFuncionarios, p.NomeProfissional NomeProfissionais, p.Foto FotoProfissionais from sys_users su LEFT JOIN profissionais p on (p.id=su.idInTable and su.`Table` like 'Profissionais') LEFT JOIN funcionarios f on (f.id=su.idInTable and su.`Table` like 'Funcionarios') where su.id<>"&session("User")&" and su.Permissoes like '%chatI%' and (not isnull(f.NomeFuncionario) or not isnull(p.NomeProfissional)) order by p.NomeProfissional")
while not u.eof
	if u("id")<>session("User") then
    set qtdMsg = db.execute("SELECT count(*) as qtd FROM chatmensagens WHERE  Para="&session("User")&" and De="&u("id")&"  and Visualizado = 0")
    if not qtdMsg.eof then
    msgNaoLidas= ""
        if cint(qtdMsg("qtd")) > 0 then
            msgNaoLidas = qtdMsg("qtd")
        end if
    end if
	%>
                <li class="media" onclick="callWindow(<%=u("id")%>, '<%=replace(u("Nome"), "'", "\'")%>')" style="cursor:pointer">
                    <a class="media-left" href="javascript:void(0)">
        	<%
			if isnull(u("Foto")) or u("Foto")="" then
				img="assets/img/user.png"
			else
			    LicencaID = replace(session("Banco"), "clinic", "")
				img= arqEx(u("Foto"), "Perfil")

			end if
			%>
                        <img src="<%=img %>" class="mw40 " loading=lazy>
                    </a>
                    <div class="media-body">
                        <h5 class="nome media-heading">
                    <%
                    isonline = "1"
					Segundos = datediff("s", u("UltRef"), now() )
					if Segundos < 20 then
                    isonline = "0"

						%>
                        <i class="fas fa-circle text-success"></i>
                        <%
					end if
					%>
                        <%=u("Nome")%>
                        <span class="badge badge-primary"><%=msgNaoLidas%></span>
                        </h5>
                        <p class="online hidden"><%=isonline %></p>
                    </div>
                </li>
	<%
	end if
u.movenext
wend
u.close

set u=nothing
%>
 </li>   
         </ul>
<br>

        </div>
</div>


