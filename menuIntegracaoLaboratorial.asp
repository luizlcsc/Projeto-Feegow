<%
case "labsconfigintegracao", "labscadastrocredenciais", "labslistagemexames", "labsimportardepara", "labslistagemprocedimentos", "deparalabs"
arrayintegracao = split(verificaSevicoIntegracaoLaboratorial(""),"|")
if arrayintegracao(0) = 1 and Aut("labsconfigintegracao") = 1 then
%>
<li>
    <a href="?P=labscadastrocredenciais&Pers=1&v=<%=arrayintegracao(1)%>"><span class="far fa-users"></span> <span class="sidebar-title">Cadastro de Credenciais</span></a>
</li>
<li>
    <a href="?P=labsconfigintegracao&Pers=1&v=<%=arrayintegracao(1)%>"><span class="far fa-list "></span> <span class="sidebar-title">Implantação de Laboratórios</span></a>
</li>
<li>
    <a href="?P=labslistagemexames&Pers=1&v=<%=arrayintegracao(1)%>"><span class="far fa-list "></span> <span class="sidebar-title">Listagem de exames</span></a>
</li>
<li>
    <a href="?P=labslistagemprocedimentos&Pers=1&v=<%=arrayintegracao(1)%>"><span class="fa fa-list "></span> <span class="sidebar-title">Listagem de procedimentos</span></a>
</li>    
<li>
    <a href="?P=procedimentolaboratorio&Pers=1&v=<%=arrayintegracao(1)%>"><span class="fa fa-list "></span> <span class="sidebar-title">Procedimentos x Laboratórios</span></a>
</li>
<li>
    <a href="?P=labsimportardepara&Pers=1&v=<%=arrayintegracao(1)%>"><span class="far fa-download"></span> <span class="sidebar-title">De x Para</span></a>
</li>
<%
end if
%>