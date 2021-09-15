    <%
	if aut("estoque")=1 then
    %>
	<li<% If req("P")="Financeiro" Then %> class="active"<% End If %>>
        <a href="?P=Estoque&Pers=1" class="dropdown-toggle">
            <span class="far fa-pie-chart"></span>
            <span class="sidebar-title"> Posição Atual </span>
        </a>
    </li>
	<li<% If req("P")="Financeiro" Then %> class="active"<% End If %>>
        <a href="?P=EstoqueLancamentos&Pers=1" class="dropdown-toggle">
            <span class="far fa-exchange"></span>
            <span class="sidebar-title"> Lançamentos </span>
        </a>
    </li>
	<li<% If req("P")="Financeiro" Then %> class="active"<% End If %>>
        <a href="?P=EstoqueTransferencia&Pers=1" class="dropdown-toggle">
            <span class="far fa-share-square-o"></span>
            <span class="sidebar-title"> Transferência </span>
        </a>
    </li>
    <%
    end if
	%>
    <li <% If req("P")="Produtos" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-list"></span>
            <span class="sidebar-title"> Produtos</span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav" <% If req("P")="Propostas" Then %> style="display:block"<% End If %>>
        	<li>
                <a href="./?P=Produtos&I=N&Pers=1">
                    <i class="far fa-plus"></i>
                    Inserir
                </a>
            </li>
            <li <% If req("P")="Propostas" and req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=Produtos&Pers=Follow">
                    <i class="far fa-list"></i>
                    Listar
                </a>
            </li>

        </ul>
    </li>
	<li<% If req("P")="produto" Then %> class="active"<% End If %>>
        <a href="?P=ProdutosKits&Pers=Follow" class="dropdown-toggle">
            <span class="far fa-medkit"></span>
            <span class="sidebar-title"> Kits de Produtos </span>
        </a>
    </li>
