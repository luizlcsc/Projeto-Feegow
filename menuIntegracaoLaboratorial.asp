<%

case "labsconfigintegracao", "labscadastrocredenciais", "labslistagemexames", "labsimportardepara", "labslistagemprocedimentos", "deparalabs", "procedimentolaboratorio", "modelocomprovantecoleta"

arrayintegracao = split(verificaSevicoIntegracaoLaboratorial(""),"|")
if arrayintegracao(0) = 1 and Aut("labsconfigintegracao") = 1 then
    %>
    <li class="sidebar-label pt20">Implantação</li>
    <li>
        <a href="?P=labsconfigintegracao&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-list "></span> <span class="sidebar-title">Implantação de Laboratórios</span></a>
    </li>
    <li>
        <a href="?P=labscadastrocredenciais&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-users"></span> <span class="sidebar-title">Cadastro de Credenciais</span></a>
    </li>
    <li>
        <a href="?P=labsimportardepara&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-download"></span> <span class="sidebar-title">Importação De x Para</span></a>
    </li>
    <li>
        <a href="?P=modelocomprovantecoleta&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-download"></span> <span class="sidebar-title">Comprovante de Coleta</span></a>
    </li>
    <li class="sidebar-label pt20">Gerenciamento</li>
    <li>
        <a href="?P=labslistagemexames&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-list "></span> <span class="sidebar-title">Listagem de exames</span></a>
    </li>
    <li>
        <a href="?P=labslistagemprocedimentos&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="fa fa-list "></span> <span class="sidebar-title">Listagem de procedimentos</span></a>
    </li>    
    <li>
        <a href="?P=procedimentolaboratorio&Pers=1&v=<%=arrayintegracao(1)%>" title="V.<%=arrayintegracao(1)%>"><span class="fa fa-list "></span> <span class="sidebar-title">Procedimentos x Laboratórios</span></a>
    </li>
    <li class="sidebar-label pt20">Config. Procedimentos x Exames</li>
    <% 
    if arrayintegracao(1) = 1 then 
        sql = "SELECT lab.id, lab.NomeLaboratorio FROM labs_autenticacao la INNER JOIN cliniccentral.labs lab ON lab.id = la.LabID WHERE sysactive ='1' AND UnidadeID="&treatvalzero(SESSION("UnidadeID"))
    else 
        sql = "SELECT lab.id, lab.NomeLaboratorio FROM slabs_autenticacao la INNER JOIN cliniccentral.labs lab ON lab.id = la.LabID WHERE sysactive ='1' AND UnidadeID="&treatvalzero(SESSION("UnidadeID"))
    end if
    set listaLabs = db.execute(sql)
    while not listaLabs.eof 
        %>
        <li>
            <a href="?P=DeParaLabs&Pers=1&v=<%=arrayintegracao(1)%>&labid=<%= listaLabs("id") %>" title="V.<%=arrayintegracao(1)%>"><span class="far fa-download"></span> <span class="sidebar-title"><%= listaLabs("NomeLaboratorio") %> </span></a>
        </li>
        <%
        listaLabs.movenext
    wend
end if
%>