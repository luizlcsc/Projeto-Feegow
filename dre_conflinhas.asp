<!--#include file="connect.asp"-->
<%
ModeloID = req("I")
LinhaID = req("II")
Acao = req("A")
LC = req("LC")

if LC="L" then
	if Acao="X" then
		db.execute("delete from dre_modeloslinhas where id="& LinhaID)
	elseif Acao="I" then
		db.execute("insert into dre_modeloslinhas set ModeloID="& ModeloID &", Tipo='LINHA', Descricao='Dê uma descrição à linha'")
	elseif Acao="U" then
		set l = db.execute("select id from dre_modeloslinhas where ModeloID="& ModeloID)
		while not l.eof
			sqlUP = "update dre_modeloslinhas set Descricao='"& ref("Descricao"& l("id")) &"', TipoValor='"& ref("TipoValor"& l("id")) &"', CorFundo='"& ref("CorFundo"& l("id")) &"', Ordem="& treatvalzero(ref("Ordem"& l("id"))) &" where id="& l("id")
			'response.write(sqlUP &"<br>")
			db.execute( sqlUP )
		l.movenext
		wend
		l.close
		set l = nothing
	end if
elseif LC="C" then
	if Acao="X" then
		db.execute("delete from dre_modeloscondicoes where id="& LinhaID)
	elseif isnumeric(Acao) then
		set pcon = db.execute("select * from cliniccentral.dre_condicoes where id="& Acao)
		db.execute("insert into dre_modeloscondicoes set LinhaID="& LinhaID &", CondicaoID="& Acao &", Valor="& treatvalnull(pcon("Valor")) &", Desconto="& treatvalnull(pcon("Desconto")) &", Acrescimo="& treatvalnull(pcon("Acrescimo")) &", Pessoas='"& pcon("Pessoas") &"', Categorias=''")
	elseif Acao="U" then
		set con = db.execute("select id from dre_modeloscondicoes where LinhaID="& LinhaID)
		while not con.eof
			ConID = con("id")
			db.execute("update dre_modeloscondicoes set Valor="& ref("Valor"& conID) &", Desconto="& ref("Desconto"& conID) &", Acrescimo="& ref("Acrescimo"& conID) &", Pessoas='"& ref("Pessoas"& conID) &"', Categorias='"& ref("Categorias"& conID) &"', Grupos='"& ref("Grupos"& conID) &"' where id="& con("id"))
		con.movenext
		wend
		con.close
		set con = nothing
	end if
elseif LC="T" then
	if Acao="X" then
		db.execute("delete from dre_modeloslinhas where id="& LinhaID)
	elseif Acao="XLT" then
		db.execute("delete from dre_totalizadores where id="& LinhaID)
	elseif isnumeric(Acao) then
		db.execute("insert into dre_totalizadores set LinhaTotID="& LinhaID &", LinhaID="& ref("AddTot"& LinhaID) &", SomarSubtrair="& ref("SoSuTot"& LinhaID) &", sysUser="& session("User"))
	elseif Acao="I" then
		db.execute("insert into dre_modeloslinhas set ModeloID="& ModeloID &", Tipo='TOTALIZADOR', Descricao='DÊ UMA DESCRIÇÃO AO TOTALIZADOR'")
	end if
end if
%>
<table class="table table-bordered table-hover table-striped table-condensed">
	<thead>
		<tr class="info">
			<th width="200">Parâmetros da linha</th>
			<th width="1%"></th>
		</tr>
	</thead>
	<tbody>
		<%
		set plinhas = db.execute("select * from dre_modeloslinhas where ModeloID="& ModeloID &" ORDER BY Ordem")
		while not plinhas.eof
			Tipo = plinhas("Tipo")
			id = plinhas("id")
			Descricao = plinhas("Descricao")
			Ordem = plinhas("Ordem")
			CorFundo = plinhas("CorFundo")
			TipoValor = plinhas("TipoValor")
			%>
			<tr>
				<td>
					<div class="row">
						<%=quickfield("text", "Descricao"& id, "DESCRIÇÃO - "& ucase(Tipo), 6, Descricao, "", "", " onchange='lin(`L`, `U`, "& id &")' ") %>
						<%=quickfield("text", "Ordem"& id, "Ordem", 2, Ordem, "", "", " onchange='lin(`L`, `U`, "& id &")' ") %>
						<%
						if Tipo="TOTALIZADOR" then
							call quickfield("simpleSelect", "CorFundo"& id, "Cor", 2, CorFundo, "select 'success' id, 'Verde' Cor UNION ALL select 'danger', 'Vermelha'", "Cor", " no-select2  onchange='lin(`L`, `U`, "& id &")' ")
						end if

						if Tipo="LINHA" then
							call quickfield("simpleSelect", "AddCon", "Condições", 2, "", "select '' id, '+ Adicionar' Descricao UNION ALL select id, Descricao from cliniccentral.dre_condicoes", "Descricao", " semVazio  no-select2 onchange='lin(`C`, $(this).val(), "& plinhas("id") &" )' ")

							call quickfield("simpleSelect", "TipoValor"& id, "Tipo de Valor", 2, TipoValor, "select 'Competencia' id, 'Competência' Descricao UNION ALL select 'Pagamento', 'Pagamento'", "Descricao", " semVazio  no-select2 onchange='lin(`L`, `U`, "& plinhas("id") &" )' ")
						else
							%>
							<div class="col-md-2">
								<input type="radio" name="SoSuTot<%= plinhas("id") %>" value="1" checked> + Somar
								<input type="radio" name="SoSuTot<%= plinhas("id") %>" value="-1"> - Subtrair
							</div>
							<%
							call quickfield("simpleSelect", "AddTot"& plinhas("id"), " ", 2, "", "select '' id, '+ Adicionar' Descricao UNION ALL (select id, Descricao from dre_modeloslinhas where Tipo='LINHA' order by Ordem)", "Descricao", " semVazio  no-select2 onchange='lin(`T`, $(this).val(), "& plinhas("id") &" )' ")
						end if
						%>
					</div>
					<div class="row">
						<div class="col-md-12">
						<%
						if Tipo="LINHA" then
							set pcon = db.execute("select m.*, c.Descricao, coalesce(m.Valor, c.Valor) Valor, coalesce(m.Desconto, c.Desconto) Desconto, coalesce(m.Acrescimo, c.Acrescimo) Acrescimo, coalesce(m.Pessoas, c.Pessoas) Pessoas, c.Categorias tabcolCategorias, c.Grupos tabcolGrupos, m.Categorias, m.Grupos from dre_modeloscondicoes m LEFT JOIN cliniccentral.dre_condicoes c ON c.id=m.CondicaoID where m.LinhaID="& id)
							if not pcon.eof then
								%>
								<table class="table table-condensed table-bordered mt10">
									<thead>
										<tr>
											<th>Recurso</th>
											<th>Valor</th>
											<th>Desconto</th>
											<th>Acréscimo</th>
											<th>Tipo forn/tomador</th>
											<th>Categorias</th>
											<th>Grupos</th>
											<th width="1%"></th>
										</tr>
									</thead>
									<tbody>
									<%
									while not pcon.eof
										Valor = pcon("Valor")
										Desconto = pcon("Desconto")
										Acrescimo = pcon("Acrescimo")
										ConID = pcon("id")
										Pessoas = pcon("Pessoas")
										Categorias = pcon("Categorias")
										Grupos = pcon("Grupos")
									
										tabcolCategorias = pcon("tabcolCategorias")&""
										if tabcolCategorias<>"" then
											spl = split(tabcolCategorias, ";")
											tabCategorias = spl(0)
											colCategorias = spl(1)
										end if

										tabcolGrupos = pcon("tabcolGrupos")&""
										if tabcolGrupos<>"" then
											spl = split(tabcolGrupos, ";")
											tabGrupos = spl(0)
											colGrupos = spl(1)
										end if
										%>
										<tr>
											<td><%= pcon("Descricao") %></td>
											<td>
												<%= quickfield("simpleSelect", "Valor"& ConID, "", 12, Valor, "select '1' id, 'Somar' Descricao UNION ALL select '0', 'Não contabilizar' UNION ALL select '-1', 'Subtrair' Descricao", "Descricao", " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ")  %>
											</td>
											<td>
												<%= quickfield("simpleSelect", "Desconto"& ConID, "", 12, Desconto, "select '1' id, 'Somar' Descricao UNION ALL select '0', 'Não contabilizar' UNION ALL select '-1', 'Subtrair' Descricao", "Descricao", " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ") %>
											</td>
											<td>
												<%= quickfield("simpleSelect", "Acrescimo"& ConID, "", 12, Acrescimo, "select '1' id, 'Somar' Descricao UNION ALL select '0', 'Não contabilizar' UNION ALL select '-1', 'Subtrair' Descricao", "Descricao", " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ") %>
											</td>
											<td>
												<%= quickfield("multiple", "Pessoas"& ConID, "", 12, Pessoas, "select * from cliniccentral.sys_financialaccountsassociation", "AssociationName", " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ") %>
											</td>
											<td>
												<%
												if tabcolCategorias<>"" then
													call quickfield("multiple", "Categorias"& ConID, "", 12, Categorias, "select '0' id, '        SEM CATEGORIA' "& colCategorias &", '       ' Posicao UNION select id, concat(ifnull(Posicao, ''), ' - ', "& colCategorias &") "& colCategorias &", Posicao from "& tabCategorias &" WHERE sysActive=1 ORDER BY Posicao, "& colCategorias, colCategorias, " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ")
												end if
												%>
											</td>
											<td>
												<%
												if tabcolGrupos<>"" then
													call quickfield("multiple", "Grupos"& ConID, "", 12, Grupos, "select '0' id, '           SEM GRUPO' "& colGrupos &" UNION select id, "& colGrupos &" from "& tabGrupos &" WHERE sysActive=1 ORDER BY "& colGrupos, colGrupos, " no-select2 semVazio onchange='lin(`C`, `U`, "& plinhas("id") &" )' ")
												end if
												%>
											</td>
											<td>
											    <%
											    if aut("dre_conflinhasX") then
											    %>
											    <button class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir esta condição da linha?'))lin('C', 'X', <%= pcon("id") %>)">
											        <i class="far fa-remove"></i>
                                                </button>
											    <%
											    end if
											    %>
                                            </td>
										</tr>
									<%
									pcon.movenext
									wend
									pcon.close
									set pcon = nothing
									%>
									</tbody>
								</table>
								<%
							end if
						else
							'TOTALIZADOR
							set ptot = db.execute("select t.*, lt.Descricao from dre_totalizadores t LEFT JOIN dre_modeloslinhas lt ON lt.id=t.LinhaID where LinhaTotID="& id)
							if not ptot.eof then
							%>
							<table class="table table-condensed table-bordered mt10">
								<thead>
									<tr>
										<th nowrap width="1%">Somar / Subtrair</th>
										<th>Linha</th>
										<th width="1%"></th>
									</tr>
								</thead>
								<tbody>
									<%
									while not ptot.eof
										if ptot("SomarSubtrair")=1 then
											SoSu = "(+)"
										else
											SoSu = "(-)"
										end if
										%>
										<tr>
											<td class="text-center"><%= SoSu %></td>
											<td><%= ptot("Descricao") %></td>
											<td>
											 <%
                                            if aut("dre_conflinhasX") then
                                            %>
											    <button class=" btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir esta condição do totalizador?'))lin('T', 'XLT', <%= ptot("id") %>)">
											        <i class="far fa-remove"></i>
                                                </button>
                                            <%
                                            end if
                                            %>
                                            </td>
										</tr>
										<%
									ptot.movenext
									wend
									ptot.close
									set ptot = nothing
									%>
								</tbody>
							</table>
							<%
							end if
						end if
						%>
						</div>
					</div>
					<hr class="short alt">
				</td>
				<td>
				 <%
                if aut("dre_conflinhasX") then
                %>
					<button class=" btn btn-sm btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir esta linha deste modelo de DRE?'))lin('L', 'X', <%= id %>)">
					    <i class="far fa-remove"></i>
                    </button>
					<%
					end if
					%>
				</td>
			</tr>
			<%
		plinhas.movenext
		wend
		plinhas.close
		set plinhas = nothing
		%>
	</tbody>
</table>

<script type="text/javascript">
function lin(LC, A, II){
	$.post('dre_conflinhas.asp?I=<%= ModeloID &"&LC='+LC+'&A='+A+'&II='+II" %>, $("#frm").serialize(), function(data){
		$("#linhas").html(data);
	});
}

<!--#include file="JQueryFunctions.asp"-->
</script>