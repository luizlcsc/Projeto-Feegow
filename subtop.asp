<%
set resource = db.execute("select * from cliniccentral.sys_resources where tableName='"&request("P")&"'")
if not resource.EOF then
	resourceName = resource("name")
	resourceDescription = "<small><i class=""far fa-double-angle-right""></i> "&resource("description")&"</small>"
	if request("I")<>"" then
		inicioA = "<a href=""?P="&resource("tableName")&""">"
		fimA = "</a>"
	end if
	'exception to Invoices
	if resource("tablename")="sys_financialinvoices" then
		if req("T")="C" then
			resourceName = "Receita"
			resourceDescription = "<small><i class=""far fa-double-angle-right""></i> edi&ccedil;&atilde;o de conta a receber</small>"
		else
			resourceName = "Despesa"
			resourceDescription = "<small><i class=""far fa-double-angle-right""></i> edi&ccedil;&atilde;o de conta a pagar</small>"
		end if
	end if
else
	resourceName = request("P")
end if
%>
<div class="breadcrumbs hidden-print" id="breadcrumbs">
    <div class="">&nbsp;&nbsp;
        <%
		if Aut("agenda")=1 or session("Table")="profissionais" then
			if versaoAgenda=1 or 1=1 then
			%>






    <div class="btn-group">
        <button class="btn btn-light btn-sm dropdown-toggle" onClick="location='./?P=Agenda-1&Pers=1';"><i class="far fa-calendar-o align-top bigger-125"></i> Agenda</button>
        <button class="btn dropdown-toggle" data-toggle="dropdown">
            <span class="far fa-caret-down icon-only"></span>
        </button>
        <ul class="dropdown-menu">
            <li>
                <a href="javascript:location='./?P=Agenda-1&Pers=1';">Diária</a>
            </li>
            <li>
                <a href="javascript:location='./?P=Agenda-S&Pers=1';">Semanal</a>
            </li>
        </ul>
    </div>





            <%
				if Aut("|agenda")=1 then
					%>
					<div class="btn-group">
						<button type="button" onClick="location.href='./?P=QuadroDisponibilidade&Pers=1';" class="btn btn-sm btn-light"><i class="far fa-calendar align-top bigger-125"></i> Agenda M&uacute;ltipla</button>
					</div>
					<%
				end if
            else
            %>
            <div class="btn-group">
                <button type="button" class="btn btn-sm btn-light" id="btnAgenda"><i class="far fa-calendar-o align-top bigger-125"></i> Agenda</button>
            </div>
            <%
				if Aut("agenda")=1 then
					%>
                    <div class="btn-group">
                        <button type="button" class="btn btn-sm btn-light" id="btnAgendaMultipla"><i class="far fa-calendar align-top bigger-125"></i> Agenda M&uacute;ltipla</button>
                    </div>
                    <%
				end if
            end if
            %>
        <div class="btn-group">
            <button type="button" class="btn btn-sm btn-light" id="btnListaEspera"><i class="far fa-clock-o align-top bigger-125"></i> Lista de Espera</button>
		</div>
		<%
		end if
		if aut("pacientesV")=1 or aut("pacientesI")=1 or aut("pacientesA")=1 then
		%>                
        <div class="btn-group">
            <button class="btn btn-light btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="far fa-user align-top bigger-125"></i> Pacientes <span class="far fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            	<%
				if aut("pacientesI")=1 then
				%>
                <li>
                    <a href="?P=Pacientes&I=N&Pers=1"><i class="far fa-plus"></i> Inserir</a>
                </li>
                <%
				end if
				if aut("pacientesV")=1 or aut("pacientesA")=1 then
				%>
                <li>
                    <a href="?P=Pacientes&Pers=Follow"><i class="far fa-list"></i> Listar</a>
                </li>
                <%
				end if
				%>
            </ul>
        </div>
		<%
		end if
		if aut("contatosV")=1 or aut("contatosI")=1 or aut("contatosA")=1 then
		%>
        <div class="btn-group">
            <button class="btn btn-light btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="far fa-mobile-phone align-top bigger-125"></i> Contatos <span class="far fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            	<%
				if aut("contatosI")=1 then
				%>
                <li>
                    <a href="?P=Contatos&I=N&Pers=1"><i class="far fa-plus"></i> Inserir</a>
                </li>
                <%
				end if
				if aut("contatosV")=1 or aut("contatosA")=1 then
				%>
                <li>
                    <a href="?P=Contatos&Pers=Follow"><i class="far fa-list"></i> Listar</a>
                </li>
                <%
				end if
				%>
            </ul>
        </div>
		<%
		end if
		if aut("lctestoque")=1 or aut("produtos")=1 then
		%>
        <div class="btn-group">
            <button class="btn btn-light btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="far fa-medkit align-top bigger-125"></i> Estoque <span class="far fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            	<%
				if aut("produtosI")=1 then
				%>
                <li>
                    <a href="?P=Produtos&I=N&Pers=1"><i class="far fa-plus"></i> Cadastrar Produto</a>
                </li>
                <%
				end if
				if aut("produtosA")=1 or aut("produtosV")=1 then
				%>
                <li>
                    <a href="?P=Produtos&Pers=Follow"><i class="far fa-list"></i> Listar Produtos</a>
                </li>
                <%
				end if
				%>
                <li class="divider"></li>
                <%
				if aut("lctestoqueI")=1 and 1=2 then
				%>
                <li>
                    <a href="?P=unavailable&Pers=1"><i class=""></i> Lan&ccedil;ar Movimento</a>
                </li>
                <%
				end if
				if aut("lctestoqueV")=1 or aut("lctestoqueA")=1 then
				%>
                <li class="hidden">
                    <a href="?P=unavailable&Pers=1"><i class=""></i> Posi&ccedil;&atilde;o do Estoque</a>
                </li>
                <%
				end if
				%>
            </ul>
        </div>
        <%
		end if
		if aut("orcamentos")=1 then
		%>
        <div class="btn-group hidden">
            <button class="btn btn-light btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="far fa-puzzle-piece align-top bigger-125"></i> Or&ccedil;amentos <span class="far fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            	<%
				if aut("orcamentosI")=1 then
				%>
                <li>
                    <a href="?P=unavailable&Pers=1"><i class="far fa-plus"></i> Inserir</a>
                </li>
                <%
				end if
				if aut("orcamentosV")=1 or aut("orcamentosA")=1 then
				%>
                <li>
                    <a href="?P=unavailable&Pers=1"><i class="far fa-list"></i> Listar</a>
                </li>
                <%
				end if
				%>
            </ul>
        </div>
        <%
		end if
		if aut("contasa")=1 or aut("movement")=1 then
		%>
            <button class="btn btn-light btn-sm" onClick="location.href='./?P=Financeiro&Pers=1';">
                <i class="far fa-money align-top bigger-125"></i> Financeiro
            </button>
		<%
		end if
		if aut("guias")=1 or aut("faturas")=1 then
		%>
        <div class="btn-group">
            <button class="btn btn-light btn-sm dropdown-toggle" data-toggle="dropdown">
                <i class="far fa-exchange align-top bigger-125"></i> TISS <span class="far fa-caret-down icon-on-right"></span>
            </button>
            <ul class="dropdown-menu dropdown-info">
            	<%
				if aut("guiasI")=1 then
				%>
                <li>
                    <a href="?P=tissguiaconsulta&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de Consulta</a>
                </li>
                <li>
                    <a href="?P=tissguiasadt&I=N&Pers=1"><i class="far fa-plus"></i> Inserir Guia de SP/SADT</a>
                </li>
                <%
				end if
				%>
				<li class="divider"></li>
				<%
				if aut("guiasV")=1 or aut("guiasA")=1 then
				%>
                <li>
                    <a href="?P=tissbuscaguias&Pers=1"><i class="far fa-list"></i> Buscar Guias</a>
                </li>
                <li><a href="?P=tissfechalote&Pers=1"><i class="far fa-archive"></i> Fechar Lote</a></li>
                <li><a href="?P=tisslotes&Pers=1"><i class="far fa-folder-open"></i> Administrar Lotes</a></li>
                <%
				end if
				%>
            </ul>
        </div>
		<%
		end if
		if aut("relatorios")=1 then
		%>
        <div class="btn-group" id="btnRelatorios">
			<button type="button" class="btn btn-light btn-sm"><i class="far fa-bar-chart align-top bigger-125"></i> Relat&oacute;rios</button>
		</div>
        <%
		end if
		%>
	</div>


						<div class="nav-search" id="nav-search">
							<form class="form-search" method="get" action="">
								<span class="input-icon">
									<input type="text" placeholder="Busca r&aacute;pida..." name="q" value="<%=req("q")%>" class="nav-search-input" id="nav-search-input" autocomplete="off" />
                                    <input type="hidden" name="P" value="Busca" />
                                    <input type="hidden" name="Pers" value="1" />
									<i class="far fa-search nav-search-icon"></i>
								</span>
							</form>
						</div><!-- #nav-search -->
					</div>
					<div class="page-content">
                    <!--
						<div class="page-header">
							<h1>
								<%=resourceName%>
								<%=resourceDescription%>
                                <%if req("I")="" and not req("P")="Home" then%>
									<a href="?P=<%=req("P")%>&I=N"><button class="btn btn-primary"><i class="far fa-edit"></i> Inserir</button></a>
								<%end if%>
							</h1>
						</div><!-- /.page-header -->
<script language="javascript">
$("#btnAgenda").click(function(){
	location.href='?P=Agenda&Pers=1';
});
$("#btnAgendaMultipla").click(function(){
	location.href='?P=AgendaMultipla&Pers=1';
});
$("#btnListaEspera").click(function(){
	location.href='?P=ListaEspera&Pers=1';
});
$("#btnRelatorios").click(function(){
	location.href='?P=Relatorios&Pers=1';
});
</script>