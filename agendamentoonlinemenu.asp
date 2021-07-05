<!--#include file="connect.asp"-->

<%
if req("MarcaAba")<>"" then
	db.execute("update aoabas set active=0")
	db.execute("update aoabas set active=1 where id="& req("MarcaAba"))
	response.end
end if
%>

<!--#include file="modal.asp"-->
<div class="row mb20 p10">
	<%= quickfield("simpleSelect", "adicionarAba", "+ Adicionar aba", 2, "", "select 'abaPersonalizada' id, '+ ABA PERSONALIZADA' Nome UNION ALL select concat('Tipo-', id), concat('+ TIPO > ', TipoProcedimento) from tiposprocedimentos UNION ALL select concat('Grupo-', id), concat('+ GRUPO > ', NomeGrupo) from procedimentosgrupos where sysActive=1", "Nome", " no-select2 onchange='aoAba(`I`, $(this).val() )' ") %>
</div>

<%

if req("AtuAbas")="1" then
	set abas = db.execute("select * from aoabas order by id")
	while not abas.eof
		db.execute("update aoabas set Icone='"& ref("Icone"&abas("id")) &"', Rotulo='"& ref("Rotulo"&abas("id")) &"', Agrupamento='"& ref("Agrupamento"&abas("id")) &"' where id="& abas("id"))
	abas.movenext
	wend
	abas.close
	set abas = nothing

	set aoi = db.execute("select id from aoabasitens")
	while not aoi.eof
		db.execute("update aoabasitens set Rotulo='"& ref("RotuloItem"& aoi("id")) &"' where id="& aoi("id"))
	aoi.movenext
	wend
	aoi.close
	set aoi=nothing
end if


Acao = ref("Acao")
Val = ref("Val")

if Acao="I" then
	if instr(Val, "Grupo-")>0 then
		Tabela = "Grupo"
		id = replace(Val, "Grupo-", "")
	elseif instr(Val, "Tipo-")>0 then
		Tabela = "Tipo"
		id = replace(Val, "Tipo-", "")
	elseif instr(Val, "Especialidades-")>0 then
		Tabela = "Especialidades"
		id = replace(Val, "Tipo-", "")
	elseif Val = "abaPersonalizada" then
		Tabela = "Personalizada"
		id = "NULL"
	end if
	db.execute("update aoabas set active=0")

	sql = "insert into aoabas set Rotulo='Nova aba', Tabela='"& Tabela &"', ItemID="& id &", active=1, sysUser="& session("User")
	'response.write( sql )
	db.execute(sql)

elseif Acao="II" then
	AbaID = ref("I")
	db.execute("insert into aoabasitens SET AbaID="& AbaID &", Ordem=0, Rotulo='Descrição do item'")

elseif Acao="P" then

	spl = split(ref("Val"), "-")
	Tipo = spl(0)
	ItemID = spl(1)
	AbaID = spl(2)
	db.execute("insert into aoabasitens set ItemID="& ItemID &", AbaID="& AbaID &", Tipo='"& Tipo &"', sysUser="& session("User"))

elseif Acao="X" then
	db.execute("delete from aoabas where id="& Val)
	db.execute("delete from aoabasitens where AbaID="& Val)

elseif Acao="PX" then
	db.execute("delete from aoabasitens where id="& Val)
end if

set abas = db.execute("select * from aoabas order by id")
if abas.eof then
	%>
	<div class="alert alert-warning">Nenhum menu configurado para a tela inicial do seu agendamento online</div>
	<%
else
	%>
	<div class="col-md-12">




		<div class="panel">
			<div class="panel-heading">
				<ul id="myTab" class="nav panel-tabs-border panel-tabs panel-tabs-left">
				<%
				while not abas.eof
					Descricao = ""
					Tabela = abas("Tabela")
					ItemID = abas("ItemID")
					abaID = abas("id")
					Icone = abas("Icone")
					Rotulo = abas("Rotulo")
					agrupamento = abas("Agrupamento")
					Placeholder = ""
					active = abas("active")
					if active=1 then
						active=" active "
					end if
					if Tabela = "Personalizada" then
						Descricao = Tabela
						ItensAba = ""
					else
						if Tabela="Tipo" then
							tbl = "tiposprocedimentos"
							cln = "TipoProcedimento"
						elseif Tabela="Grupo" then
							tbl = "procedimentosgrupos"
							cln = "NomeGrupo"
						end if
						set pdesc = db.execute("select id, "& cln &" from "& tbl &" where id="& ItemID)
						if not pdesc.eof then
							Descricao = Tabela &": "& pdesc( cln )
							Placeholder = pdesc( cln )
						end if
					end if
					
					%>
					<li class="<%= active %>" onclick="ajxContent('agendamentoonlinemenu', '&MarcaAba=<%= abas("id") %>', 1, '');">
						<a href="#a<%= abas("id") %>" data-toggle="tab">
							<% if Placeholder="" then response.write(Rotulo) else response.write(Placeholder) end if %>
						</a>
					</li>
					<%
				abas.movenext
				wend
				%>
				</ul>
			</div>
			<div class="panel-body">
				<div class="tab-content pn br-n">
				<%
				abas.moveFirst()
				while not abas.eof
					Descricao = ""
					Tabela = abas("Tabela")
					ItemID = abas("ItemID")
					abaID = abas("id")
					Icone = abas("Icone")
					Rotulo = abas("Rotulo")
					agrupamento = abas("Agrupamento")
					active = abas("active")
					if active=1 then
						active=" active "
					end if
					Placeholder = ""
					if Tabela = "Personalizada" then
						Descricao = Tabela
						ItensAba = ""
					else
						if Tabela="Tipo" then
							tbl = "tiposprocedimentos"
							cln = "TipoProcedimento"
						elseif Tabela="Grupo" then
							tbl = "procedimentosgrupos"
							cln = "NomeGrupo"
						end if
						set pdesc = db.execute("select id, "& cln &" from "& tbl &" where id="& ItemID)
						if not pdesc.eof then
							Descricao = Tabela &": "& pdesc( cln )
							Placeholder = pdesc( cln )
						end if
					end if
					%>
					<div id="a<%= abas("id") %>" class="tab-pane in <%= active %>">

						<div class="row">
							<div class="col-md-12">
								<%= Descricao %>
							</div>
						</div>
						<hr class="short alt">
						<div class="row">
							<%= quickfield("text", "Rotulo"& abaID, "Rótulo", 8, Rotulo, " frm ", "", " placeholder='"& Placeholder &"' ") %>
							<%= quickfield("text", "Icone"& abaID, "Ícone", 3, Icone, " frm ", "", "  ") %>
							<div class="col-md-1 pt25">
								<i type="button" class="btn btn-md btn-danger fa fa-remove" onclick="if(confirm('Tem certeza de que deseja apagar esta aba?')) aoAba('X', <%= abaID %>)"></i>
							</div>
						</div>
						<hr class="short alt">
						<div class="row">
							<div class="col-md-12">


							<%
							if Tabela="Tipo" or Tabela="Grupo" then
								'call quickfield("simpleSelect", "Agrupamento"& abaID, "", 12, Agrupamento, "select 'Especialidades' id, 'Especialidades' Nome UNION ALL select 'Procedimentos', 'Procedimentos'", "Nome", " no-select2 semVazio")
								response.write("<em>Todos os procedimentos do "& lcase(Tabela) &" <b>"& ucase(pdesc(cln)) &"</b> habilitados para agendamento online.</em>")
							else
								'aba personalizada
								set pers = db.execute("SELECT * FROM aoabasitens where AbaID="& abas("id") &" ORDER BY Ordem, id")
								if pers.eof then
									%>
									<em>Nenhum item nesta aba.</em>
									<%
								else
									%>
									<table class="table">
										<thead>
											<tr>
												<th width="30%">
													Texto do botão
												</th>
												<th>Botões de procedimentos</th>
												<th width="1%"></th>
											</tr>
										</thead>
										<tbody>
										<%
										while not pers.eof
											%>
											<tr>
												<td>
													<%= quickfield("text", "RotuloItem"& pers("id"), "", 4, pers("Rotulo"), " frm ", "", "") %>
												</td>
												<td>
													<%
													set b = db.execute("select b.*, p.ProcedimentoTelemedicina tele from aoabasitensbotoes b left join procedimentos p on p.id=b.ProcedimentoID where b.ItemID="& pers("id"))
													while not b.eof
														if b("tele")="S" then
															iconeTele = "<i class='fa fa-video-camera'></i> "
														else
															iconeTele = ""
														end if
														%>
														<button type="button" class="btn btn-default text-left" onclick="btnPers('E', <%= pers("id") %>, <%= b("id") %>)">
															<%= iconeTele & b("Texto")%>
															<i class="btn btn-xs btn-primary fa fa-edit"></i>
														</button>
														<%
													b.movenext
													wend
													b.close
													set b=nothing
													%>
												</td>
												<td nowrap>
													<i class="btn btn-primary fa fa-plus" onclick="btnPers('I', <%= pers("id") %>, '')"></i>
													<i class="fa fa-remove btn btn-md btn-danger" onclick="if(confirm('Deseja excluir este item da aba personalizada?')) aoAba('PX', <%= pers("id") %>)"></i>
												</td>
											</tr>
											<%
										pers.movenext
										wend
										pers.close
										set pers = nothing
										%>
										</tbody>
									</table>
									<%
								end if
								%>
								<button type="button" class="btn btn-xs btn-success btn-block" onclick="aoItemPers('II', <%= abas("id") %>, '')">+ Adicionar</button>
								<%
							end if
							%>
							</div>
						</div>





					</div>
				<%
				abas.movenext
				wend
				abas.close
				set abas = nothing
				%>
				</div>
			</div>
		</div>




	</div>
	<%
end if
%>




<script type="text/javascript">
function aoAba(Acao, Val){
	$.post("agendamentoonlinemenu.asp", { Acao: Acao, Val: Val }, function(data){
		$("#menuAO").html(data);
	});
}

function aoItemPers(Acao, I, Val){
	$.post("agendamentoonlinemenu.asp", { Acao: Acao, I:I, Val: Val }, function(data){
		$("#menuAO").html(data);
	});
}

$("#tblMenu input, #tblMenu select, .frm").change(function(){
	$.post("agendamentoonlinemenu.asp?AtuAbas=1", $("#tblMenu input, #tblMenu select, .frm").serialize(), function(data) { 
		eval(data);
	})
});

function abaPers(I){
	$("#modal-table").modal("show");
	$.get("agendamentoonlineaddpers.asp?AbaID="+I, function(data){ $("#modal").html(data) });
}

function btnPers(A, I, B){
	$("#modal-table").modal("show");
	$.get("agendamentoonlineprocPers.asp?ItemID="+I+"&A="+A+"&B="+B, function(data){ $("#modal").html(data) });
}

</script>