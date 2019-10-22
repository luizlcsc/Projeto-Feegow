    <%
	if aut("contasa")=1 or aut("movement")=1 then
    %>
	<li<% If req("P")="Financeiro" Then %> class="active"<% End If %>>
        <a href="?P=Financeiro&Pers=1" class="dropdown-toggle">
            <span class="fa fa-pie-chart"></span>
            <span class="sidebar-title"> Resumo </span>
        </a>
    </li>
    <%
    end if
    if aut("contasapagar") then%>
    <li<% If (req("P")="invoice" OR req("P")="ContasCD") AND req("T")="D" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="fa fa-arrow-circle-up"></span>
            <span class="sidebar-title"> Contas a Pagar </span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav">
            <%
			if aut("contasapagarI") then
			%>
            <li>
                <a href="./?P=invoice&I=N&T=D&Pers=1">
                    <i class="fa fa-plus"></i>
                    Inserir
                </a>
            </li>
			<%
			end if
			if aut("contasapagarV") then
			%>
            <li<% If req("P")="ContasCD" AND req("T")="D" Then %> class="active"<% End If %>>
                <a href="./?P=ContasCD&T=D&Pers=1">
                    <i class="fa fa-list"></i>
                    Listar
                </a>
            </li>
            <li<% If req("P")="Recorrentes" AND req("T")="D" AND req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=Recorrentes&T=D&Pers=1&List=1">
                    <i class="fa fa-refresh"></i>
                    Despesas Fixas
                </a>
            </li>
			<%
			end if
			%>
        </ul>
    </li>
    <%
	end if
	if aut("contasareceber") then
	%>
    <li <% If (req("P")="invoice" OR req("P")="ContasCD") AND req("T")="C" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="fa fa-arrow-circle-down"></span>
            <span class="sidebar-title"> Contas a Receber </span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav">
        	<%
			if aut("contasareceberI") then
			%>
            <li>
                <a href="./?P=invoice&I=N&T=C&Pers=1">
                    <i class="fa fa-plus"></i>
                    Inserir
                </a>
            </li>
			<%
			end if
			if aut("contasareceberV") then
			%>
            <li<% If req("P")="ContasCD" AND req("T")="C" Then %> class="active"<% End If %>>
                <a href="./?P=ContasCD&T=C&Pers=1">
                    <i class="fa fa-list"></i>
                    Listar
                </a>
            </li>
            <li<% If req("P")="Recorrentes" AND req("T")="C" AND req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=Recorrentes&T=C&Pers=1&List=1">
                    <i class="fa fa-refresh"></i>
                    Receitas Fixas
                </a>
            </li>
			<%
			end if
			%>
        </ul>
    </li>
    <%
	end if
	if aut("contasareceber") and aut("contasapagar") then
	%>
	<li <% If req("P")="Caixas" Then %> class="active"<% End If %>>
        <a href="./?P=Caixas&Pers=1">
            <span class="fa fa-inbox"></span>
            <span class="sidebar-title"> Caixas </span>
        </a>
    </li>
	<li <% If req("P")="Extrato" Then %> class="active"<% End If %>>
        <a href="./?P=Extrato&Pers=1">
            <span class="fa fa-reorder"></span>
            <span class="sidebar-title"> Extratos </span>
        </a>
    </li>
	<%
	end if
	if aut("repasses") then
	%>
	<li <% If req("P")="Repasses" Then %> class="active"<% End If %>>
        <a href="?P=Repasses&Pers=1">
            <span class="fa fa-puzzle-piece"></span>
            <span class="sidebar-title"> Repasses </span>
        </a>
    </li>
	<%
	end if
    %>
	<li <% If req("P")="GerarRateio" Then %> class="active"<% End If %>>
        <a href="?P=GerarRateio&Pers=1">
            <span class="fa fa-th"></span>
            <span class="sidebar-title"> Gerar Rateio </span>
        </a>
    </li>

    <%
	if aut("contasareceber") then
	%>
	<li <% If req("P")="ChequesRecebidos" Then %> class="active"<% End If %>>
        <a href="?P=ChequesRecebidos&Pers=1">
            <span class="fa fa-list-alt"></span>
            <span class="sidebar-title"> Cheques </span>
        </a>
    </li>

	<li <% If req("P")="CartaoCredito" Then %> class="active"<% End If %>>
        <a href="?P=CartaoCredito&Pers=1">
            <span class="fa fa-credit-card"></span>
            <span class="sidebar-title"> Cartões </span>
        </a>
    </li>
	<%
	end if
	%>
    <li <% If req("P")="Propostas" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="fa fa-files-o"></span>
            <span class="sidebar-title"> Propostas</span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav" <% If req("P")="Propostas" Then %> style="display:block"<% End If %>>
        	<li>
                <a href="./?P=PacientesPropostas&PropostaID=N&Pers=1">
                    <i class="fa fa-plus"></i>
                    Inserir
                </a>
            </li>
            <li <% If req("P")="Propostas" and req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=buscaPropostas&Pers=1">
                    <i class="fa fa-list"></i>
                    Listar
                </a>
            </li>

        </ul>
    </li>
