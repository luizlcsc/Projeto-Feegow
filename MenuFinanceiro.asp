    <%
	if aut("|contasa")=1 or aut("movement")=1 then
    %>
	<li<% If req("P")="Financeiro" Then %> class="active"<% End If %>>
        <a href="?P=Financeiro&Pers=1" class="dropdown-toggle">
            <span class="far fa-pie-chart"></span>
            <span class="sidebar-title"> Resumo </span>
        </a>
    </li>
    <%
    end if
    if aut("|contasapagar") or aut("|repassesV|") then%>
    <li<% If (req("P")="invoice" OR req("P")="ContasCD") AND req("T")="D" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-arrow-circle-up"></span>
            <span class="sidebar-title"> Contas a Pagar </span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav" <% If (req("P")="ContasCD" OR req("P")="Recorrentes") AND req("T")="D" Then %> style="display:block"<% End If %>>
            <%
			if aut("|contasapagarI") then
			%>
            <li>
                <a href="./?P=invoice&I=N&T=D&Pers=1">
                    <i class="far fa-plus"></i>
                    Inserir
                </a>
            </li>
			<%
			end if
			if aut("|contasapagarV") or aut("|repassesV|") then
			%>
            <li<% If req("P")="ContasCD" AND req("T")="D" Then %> class="active"<% End If %>>
                <a href="./?P=ContasCD&T=D&Pers=1">
                    <i class="far fa-list"></i>
                    Listar
                </a>
            </li>
            <%
            end if
            if aut("|contasapagarV") and aut("despesafixaV")=1 then
            %>
            <li<% If req("P")="Recorrentes" AND req("T")="D" AND req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=Recorrentes&T=D&Pers=1&List=1">
                    <i class="far fa-refresh"></i>
                    Despesas Fixas
                </a>
            </li>
			<%
			end if

            if aut("solicitacao_compraV") = 1 then
            %>
                <li class="">
                    <a href="./?P=SolicitacaoDeCompraLista&I=N&Pers=1">
                        <i class="far fa-shopping-cart"></i>
                        Solicitação de compra <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
            <% end if %>

            <% if aut("aprovacompraV") = 1 then %>
                <li class="">
                    <a href="./?P=SolicitacaoDeCompraAprovacao&I=N&Pers=1">
                        <i class="far fa-check"></i>
                        Aprovação de compra <span class="label label-system label-xs fleft">Novo</span>
                    </a>
                </li>
            <% end if %>
        </ul>
    </li>
    <%
	end if
	if aut("|contasareceber") then
	%>
    <li <% If (req("P")="invoice" OR req("P")="ContasCD" OR req("P")="Recorrentes") AND req("T")="C" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-arrow-circle-down"></span>
            <span class="sidebar-title"> Contas a Receber </span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav" <% If (req("P")="ContasCD" OR req("P")="Recorrentes") AND req("T")="C" Then %> style="display:block"<% End If %>>
        	<%
			if aut("|contasareceberI")  then
			%>
            <li>
                <a href="./?P=invoice&I=N&T=C&Pers=1">
                    <i class="far fa-plus"></i>
                    Inserir
                </a>
            </li>
			<%
			end if
			if aut("|contasareceberV") then
			%>
            <li<% If req("P")="ContasCD" AND req("T")="C" Then %> class="active"<% End If %>>
                <a href="./?P=ContasCD&T=C&Pers=1">
                    <i class="far fa-list"></i>
                    Listar
                </a>
            </li>

            <%
            if aut("receitafixaV")=1  then
            %>
            <li<% If req("P")="Recorrentes" AND req("T")="C" AND req("List")="1" Then %> class="active"<% End If %>>
                <a href="./?P=Recorrentes&T=C&Pers=1&List=1">
                    <i class="far fa-refresh"></i>
                    Receitas Fixas
                </a>
            </li>
			<%
			end if

			end if
			%>
        </ul>
    </li>
    <%
	end if
    if recursoAdicional(40) and (aut("solicitacoescompras") = 1 or aut("configcompras") = 1)  then
    %>
    <li>
        <a href="#" class="accordion-toggle">
            <span class="far fa-shopping-cart"></span>
            <span class="sidebar-title"> Compras </span>
            <span class="caret"></span>
        </a>
        <ul class="nav sub-nav">
            <% if aut("solicitacoescompras") = 1 then %>
            <li><a href="./?P=solicitacoescompras&Pers=1#/solicitacoes"><i class="far fa-list"></i> Solicitações</a></li>
            <li><a href="./?P=solicitacoescompras&Pers=1#/aprovacoes"><i class="far fa-check-square-o"></i> Aprovação</a></li>
            <li><a href="./?P=solicitacoescompras&Pers=1#/ordens"><i class="far fa-paper-plane"></i> Ordem de Compra</a></li>
            <% end if %>
            <% if aut("configcompras") = 1 then %>
            <li><a href="./?P=configcompras&Pers=1"><i class="far fa-cog"></i> Configurações</a></li>
            <% end if %>
        </ul>
    </li>
    <%
    end if
	if aut("|contasareceber") or aut("caixasusu") then
	    %>
	<li <% If req("P")="Caixas" Then %> class="active"<% End If %>>
        <a href="./?P=Caixas&Pers=1">
            <span class="far fa-inbox"></span>
            <span class="sidebar-title"> Caixas </span>
        </a>
    </li>
	    <%
	end if
	if aut("|contasareceber") and aut("|contasapagar") then
	%>
	<li <% If req("P")="Extrato" Then %> class="active"<% End If %>>
        <a href="./?P=Extrato&Pers=1">
            <span class="far fa-reorder"></span>
            <span class="sidebar-title"> Extratos </span>
        </a>
    </li>
	<%
	end if
	if aut("repasses")  then
	%>
    <li <% If (req("P")="RepassesAConferir" OR req("P")="RepassesConferidos") Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle" id="RepassesCollapse">
            <span class="far fa-puzzle-piece"></span>
            <span class="sidebar-title"> Repasses </span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav" <% If req("P")="RepassesConferidos" or req("P")="RepassesAConferir" Then %> style="display:block"<% End If %>>
        <%
        if newrep()=0 and 1=0 then
        %>
          <li>
            <a href="?P=Repasses&Pers=1">
              <i class="far fa-list"></i>
              Repasses
            </a>
          </li>
        <%
        else
        %>
          <li <% If req("P")="RepassesAConferir" Then %> class="active"<% End If %>>
            <a href="./?P=RepassesAConferir&Pers=1" id="RepassesConsolidacao">
              <i class="far fa-list"></i>
              Consolidação <span class="label label-system label-xs fleft">Novo</span>
            </a>
          </li>
          
            <li <% If req("P")="RepassesConferidos" Then %> class="active"<% End If %>>
                <a href="./?P=RepassesConferidos&Pers=1">
                    <i class="far fa-list"></i>
                  Repasses Consolidados
                </a>
            </li>
            <%
        
        end if
        %>
        </ul>
    </li>
	<%
	end if

	if aut("configrateio")=1 and false then
    %>
	<li <% If req("P")="GerarRateio" Then %> class="active"<% End If %>>
        <a href="?P=GerarRateio&Pers=1">
            <span class="far fa-th"></span>
            <span class="sidebar-title"> Gerar Rateio </span>
        </a>
    </li>

    <%
    end if

    if aut("capptaV") then
    %>
    <li <% If req("P")="Microteflogs" Then %> class="active"<% End If %>>
        <a href="?P=Microteflogs&Pers=1">
            <span class="far fa-credit-card"></span>
            <span class="sidebar-title"> Transações TEF </span>
        </a>
    </li>

    <%
    end if

    if aut("splitpagamentoV") then
    	ConciliacaoBancariaStatus = recursoAdicional(15)

        if ConciliacaoBancariaStatus=4 then
    %>
    <li<% If req("P")="Splits" OR req("P")="SplitsCancelamento" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-code-fork"></span>
            <span class="sidebar-title"> Splits </span>

            <span class="caret"></span>
        </a>
        <ul class="nav sub-nav" <% If req("P")="Splits" or req("P")="SplitsCancelamento" Then %> style="display:block"<% End If %>>
            <li <% If req("P")="Splits" Then %> class="active"<% End If %>>
                <a href="?P=Splits&Pers=1">
                    <span class="far fa-code-fork"></span>
                    <span class="sidebar-title"> Realizar/Realizados </span>
                </a>
            </li>
                <li <% If req("P")="SplitsCancelamento" Then %> class="active"<% End If %>>
                    <a href="?P=SplitsCancelamento&Pers=1">
                        <span class="far fa-history"></span>
                        <span class="sidebar-title"> Cancelados </span>
                    </a>
                </li>
        </ul>
    </li>

    <%
        end if
    end if

    StatusEmissaoBoleto = recursoAdicional(8)
    if StatusEmissaoBoleto = 4 and aut("emissaoboletosV") = 1 then
    %>

       <li<% If req("P")="Marketplace" OR req("P")="BoletosEmitidos" Then %> class="open"<% End If %>>
           <a href="#" class="accordion-toggle">
               <span class="far fa-barcode"></span>
               <span class="sidebar-title"> Emissão de boletos </span>

               <span class="caret"></span>
           </a>
           <ul class="nav sub-nav" <% If req("P")="Marketplace" or req("P")="BoletosEmitidos" Then %> style="display:block"<% End If %>>
               <li <% If req("P")="BoletosEmitidos" Then %> class="active"<% End If %>>
                   <a href="?P=BoletosEmitidos&Pers=1">
                       <span class="far fa-list"></span>
                       <span class="sidebar-title"> Gerenciar boletos </span>
                   </a>
               </li>
                   <li <% If req("P")="Marketplace" Then %> class="active"<% End If %>>
                       <a href="?P=Marketplace&Pers=1">
                           <span class="far fa-cogs"></span>
                           <span class="sidebar-title"> Gerenciar conta </span>
                       </a>
                   </li>
           </ul>
       </li>

    <%
    end if

	%>

	<% if aut("|notafiscalV|") and recursoAdicional(34)=4 then %>
       <li<% If req("P")="ListarEmpresasNFse" OR req("P")="BoletosEmitidos" OR req("P")="CriarEmpresaNFse" Then %> class="open"<% End If %>>
           <a href="#" class="accordion-toggle">
               <span class="far fa-file-text"></span>
               <span class="sidebar-title"> Nota Fiscal</span>
               <span class="caret"></span>
           </a>
           <ul class="nav sub-nav">
               <li>
                   <a href="?P=ListarNotasFiscais&Pers=1">
                       <span class="far fa-list"></span>
                       <span class="sidebar-title"> Listar notas </span>
                   </a>
               </li>
               <li <% If req("P")="ListarEmpresasNFse" Then %> class="active"<% End If %>>
                   <a href="?P=ListarEmpresasNFse&Pers=1">
                       <span class="far fa-building"></span>
                       <span class="sidebar-title"> Listar empresas </span>
                   </a>
               </li>
               <li <% If req("P")="CriarEmpresaNFse" Then %> class="active"<% End If %>>
                      <a href="?P=CriarEmpresaNFse&Pers=1">
                          <span class="far fa-plus"></span>
                          <span class="sidebar-title"> Criar empresa </span>
                      </a>
                  </li>
           </ul>
       </li>
       <% end if 
       
       if aut("chequesV") = 1 then %>
	<li <% If req("P")="ChequesRecebidos" Then %> class="active"<% End If %>>
        <a href="?P=ChequesRecebidos&Pers=1">
            <span class="far fa-list-alt"></span>
            <span class="sidebar-title"> Cheques </span>
        </a>
    </li>
    <%
    end if

    if aut("controlecartoes")=1 then
    %>
    <li <% If req("P")="CartaoCredito" or req("P")="FaturaCartao" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-credit-card"></span>
            <span class="sidebar-title"> Cartões</span>

            <span class="caret"></span>
        </a>
        <ul class="nav sub-nav" <% If req("P")="CartaoCredito" or req("P")="FaturaCartao" Then %> style="display:block"<% End If %>>
            <li <% If req("P")="CartaoCredito" Then %> class="active"<% End If %>>
                <a href="?P=CartaoCredito&Pers=1">
                    <span class="far fa-download"></span>
                    <span class="sidebar-title"> Baixar Pagamentos </span>
                </a>
            </li>
            <%
            if 0 then
            %>
            <li style="display: none" <% If req("P")="FaturaCartao" Then %> class="active"<% End If %>>
                <a href="./?P=FaturaCartao&Pers=1">
                    <i class="far fa-list"></i>
                    Fatura do Cartão <span class="label label-system label-xs fleft">Novo</span>
                </a>
            </li>
            <%
            end if
            if recursoAdicional(25)=4 then
            %>
            <li <% If req("P")="CartaoConcilia" Then %> class="active"<% End If %>>
                <a href="?P=CartaoConcilia&Pers=1">
                    <span class="far fa-upload"></span>
                    <span class="sidebar-title"> Importação CSV </span>
                </a>
            </li>

           <%end if%>

        </ul>


    </li>
    <%
    end if
    if session("Admin")=1 and (session("Banco")="clinic5760" or session("Banco")="clinic100000") then
    %>

	<li <% If req("P")="FechamentoData" Then %> class="active"<% End If %>>
        <a href="./?P=FechamentoData&Pers=1">
            <span class="far fa-lock"></span>
            <span class="sidebar-title"> Fechamento de Data </span>
        </a>
    </li>

    <%
    end if
    %>

	<%
	ConciliacaoBancariaStatus = recursoAdicional(16)

    if ConciliacaoBancariaStatus=4 and aut("automacaoV") = 1 then
        %>

        <li>
            <a href="#" class="accordion-toggle">
                <span class="far fa-cogs"></span>
                <span class="sidebar-title"> Automação</span>

                <span class="caret"></span>
            </a>

            <ul class="nav sub-nav" >
           
                <li>
                    <a href="./?P=ArquivoRetorno&Pers=1">
                        <i class="far fa-download"></i>
                        <span class="sidebar-title"> Retorno bancário</span>
                    </a>
                </li>
               
                <li <% If req("P")="Concilia" Then %> class="active"<% End If %>>
                    <a href="?P=BancoConcilia&Pers=1">
                        <span class="far fa-check"></span>
                        <span class="sidebar-title"> Conciliação bancária </span>
                    </a>
                </li>
               
                <li <% If req("P")="ImportRet" Then %> class="active"<% End If %>>
                    <a href="?P=ImportRet&Pers=1">
                        <span class="far fa-download"></span>
                        <span class="sidebar-title"> Retorno CNAB</span>
                    </a>
                </li>
                <% if session("Banco")="clinic5760" then %>
                <li <% If req("P")="StoneConcilia" Then %> class="active"<% End If %>>
                    <a href="?P=StoneConcilia&Pers=1">
                        <span class="far fa-check"></span>
                        <span class="sidebar-title"> Conciliação Stone</span>
                    </a>
                </li>
                <%
                end if
	            StatusEmissaoBoleto = recursoAdicional(8)

                if StatusEmissaoBoleto=4 then %>
                <li>
                    <a href="./?P=ConciliacaoProvedor&Pers=1">
                        <span class="far fa-check"></span>
                        <span class="sidebar-title"> Conciliação provedor</span>
                    </a>
                </li>
                <% end if %>
            </ul>
        </li>
        <%
    end if
    if aut("proposta")=1 then
	%>
    <li <% If req("P")="buscaPropostas" or req("P")="PacientesPropostas" Then %> class="open"<% End If %>>
        <a href="#" class="accordion-toggle">
            <span class="far fa-files-o"></span>
            <span class="sidebar-title"> Propostas</span>

            <span class="caret"></span>
        </a>

        <ul class="nav sub-nav"  <% If req("P")="PacientesPropostas" or req("P")="buscaPropostas" Then %> style="display:block"<% End If %>>
        	<li <% If req("P")="PacientesPropostas" Then %> class="active"<% End If %>>
                <a href="./?P=PacientesPropostas&PropostaID=N&Pers=1">
                    <i class="far fa-plus"></i>
                    Inserir
                </a>
            </li>
            <li <% If req("P")="buscaPropostas" Then %> class="active"<% End If %>>
                <a href="./?P=buscaPropostas&Pers=1">
                    <i class="far fa-list"></i>
                    Listar
                </a>
            </li>

        </ul>
    </li>
    <%
        if aut("descontospendentes")=1 then
    %>
    <li <% If req("P")="DescontoPendente" Then %> class="active"<% End If %>>
        <a href="./?P=DescontoPendente&Pers=1">
            <span class="far fa-money"></span>
            <span class="sidebar-title"> Descontos Pendentes </span>
        </a>
    </li>
    <%
        end if
        if aut("|honorarios|")=1 then
    %>
    <li <% If req("P")="Honorarios" Then %> class="active"<% End If %>>
        <a href="./?P=Honorarios&Pers=1">
            <span class="far fa-calendar"></span>
            <span class="sidebar-title"> Honorários </span>
        </a>
    </li>
    <%
        end if
    end if


    %>
