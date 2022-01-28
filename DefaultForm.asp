<!--#include file="modal.asp"-->
<%
function desfazBloqueioFeriado(feriadoid)
	sqlBuscaBloqueios = " select * "&_ 
						" from compromissos where FeriadoID = "&feriadoid&" "&_ 
						" and DataA >= '"&mydate(Date)&"'" 
	set bloqueiosFeriados = db.execute(sqlBuscaBloqueios)

	if not bloqueiosFeriados.eof then
		db_execute(" delete "&_ 
					" from compromissos where FeriadoID = "&feriadoid&" "&_ 
					" and DataA >= '"&mydate(Date)&"' " )
	end if
end function

function DefaultForm(tableName, id)
	if lcase(tableName)="pacientes" then
		omitir = ""
		if session("Admin")=0 then
			set omit = db.execute("select * from omissaocampos")
			while not omit.eof
				tipo = omit("Tipo")
				grupo = omit("Grupo")
				if Tipo="P" and lcase(session("Table"))="profissionais" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
					omitir = omitir&lcase(omit("Omitir"))
				elseif Tipo="F" and lcase(session("Table"))="funcionarios" and (instr(grupo, "|0|")>0 or instr(grupo, "|"&session("idInTable")&"|")>0) then
					omitir = omitir&lcase(omit("Omitir"))
				elseif Tipo="E" and lcase(session("Table"))="profissionais" then
					set prof = db.execute("select EspecialidadeID from profissionais where id="&session("idInTable"))
					if not prof.eof then
						if instr(grupo, "|"&prof("EspecialidadeID")&"|")>0 then
							omitir = omitir&lcase(omit("Omitir"))
						end if
					end if
				end if
			omit.movenext
			wend
			omit.close
			set omit = nothing
		end if
	end if
	if id="" then
		'show the form list
		set res = db.execute("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
		if not res.eof then
			initialOrder = res("initialOrder")
			if req("Pers")="Follow" then
				Pers = 1
				if res("Pers")="0" then
				    Pers=0
				end if
			else
				Pers = 0
			end if
			if aut(lcase(tableName)&"I")=1 then
			
%>





                <%
				if (lcase(tableName)="funcionarios" or lcase(tableName)="profissionais") and session("Status")<>"T" then
					if lcase(tableName)="funcionarios" then
						nomeColuna = "funcion&aacute;rio"
					else
						nomeColuna = "profissional"
					end if
                    btnInserir = "<button type=""button"" class=""btn btn-sm btn-success btn-inserir-funcionario"" onclick=""conf()""><i class=""far fa-plus""></i> INSERIR</button>"
                %>
                
                <script type="text/javascript">
					<%
					if session("Admin")=1 or (aut("profissionaisI")=1 and lcase(tableName)="profissionais") or (aut("funcionariosI")=1 and lcase(tableName)="funcionarios") then
						set contaUsu = db.execute("select ifnull(((select count(*) from profissionais where sysActive=1 and Ativo='on')+(select count(*) from funcionarios where sysActive=1 and Ativo='on')), 0) as total")
						set valorUsu = db.execute("select ifnull(valorusuario, 0) valorusuario from cliniccentral.licencas where id="&replace(session("banco"), "clinic", ""))

                        ValorAtual = 0'ccur(contaUsu("total")) * ccur(valorUsu("valorUsuario"))
						NovoValor = 0'ValorAtual+ccur(valorUsu("valorUsuario"))
						
'						message = "<strong class='red'><i class='far fa-warning'></i> ATEN&Ccedil;&Atilde;O!</strong><br><br><br>Ao cadastrar um novo "&nomeColuna&", sua fatura aumentar&aacute; de <strong>R$ "&formatnumber(ValorAtual, 2)&"</strong> para <strong>R$ "&formatnumber(NovoValor, 2)&"</strong>.<br>Tem certeza de que deseja cadastrar mais um usu&aacute;rio?<br><br><small class='grey'>Obs.: Caso tenha d&uacute;vidas quanto a esta cobran&ccedil;a, entre em contato conosco.</small>"
						message = "<strong class='red'><i class='far fa-warning'></i> ATEN&Ccedil;&Atilde;O!</strong><br><br><br>Ao cadastrar um novo "&nomeColuna&", sua fatura pr&oacute;xima ser&aacute; acrescida deste usu&aacute;rio</strong>.<br>Tem certeza de que deseja cadastrar mais um usu&aacute;rio?<br><br><small class='grey'>Obs.: Caso tenha d&uacute;vidas quanto a esta cobran&ccedil;a, entre em contato conosco.</small>"
						%>
					function conf(){
						bootbox.dialog({
							message: "<%=message%>",
							buttons: 			
							{
								"success" :
								 {
									"label" : "<i class='icon-ok'></i> ACEITAR",
									"className" : "btn-sm btn-success",
									"callback": function() {
										location.href='?P=<%=req("P")%>&I=N&Pers=<%=Pers%>';
									}
								},
								"danger" :
								{
									"label" : "CANCELAR",
									"className" : "btn-sm btn-danger",
									"callback": function() {
										//Example.show("uh oh, look out!");
									}
								}
							}
						});
					    }
                        <%
				    else
					    %>
					    function conf(){
						    bootbox.dialog({
							message: "<strong class='red'><i class='far fa-warning'></i> ATEN&Ccedil;&Atilde;O!</strong><br><br><br>O cadastro de novos funcion&aacute;rios e profissionais &eacute; permitido somente ao usu&aacute;rio administrador do sistema.<br><br><small>Usu&aacute;rio(s) com permiss&atilde;o para isso:<br><%
							set master = db.execute("select id from cliniccentral.licencasusuarios where LicencaID="&replace(session("banco"), "clinic", "")&" and admin=1")
							while not master.eof
								%>&raquo; <%=nameInTable(master("id"))%><br><%
							master.movenext
							wend
							master.close
							set master=nothing
							%>",
							buttons: 			
							{
								"danger" :
								{
									"label" : "FECHAR",
									"className" : "btn-sm btn-info",
									"callback": function() {
										//Example.show("uh oh, look out!");
									}
								}
							}
						});
					}
					<%
					end if
					%>
                </script>
                <%
                elseif (lcase(tableName)="buiforms") and (ModoFranquiaUnidade or getConfig("ReplicarFormulario")) then
                    btnInserir = ("<a class=""btn btn-sm btn-dark"" href=""?P=buiforms-duplicar&I=N&Pers="&Pers&"""><i class=""far fa-copy""></i> Duplicar da Central</a>")&"&nbsp;<a class=""btn btn-sm btn-success"" href=""?P="& req("P")&"&I=N&Pers="&Pers&"""><i class=""far fa-plus""></i> INSERIR</a>"
				else
                    %>
                    <br />
                    <%
                    btnInserir = "<a class=""btn btn-sm btn-success"" href=""?P="& req("P")&"&I=N&Pers="&Pers&"""><i class=""far fa-plus""></i> INSERIR</a>"
				end if
							end if

                %>
<script type="text/javascript">
    $(document).ready(function(){
        $(".crumb-active a").html("<%=res("Name")%>");
        $(".crumb-icon a span").attr("class", "far fa-<%=dIcone(lcase(tableName))%>");
        $(".topbar-right").html('<%=btnInserir%>');
    });
	function viewProp(P){
		$("#modal-table").modal("show");
		$.get("ListaPropostas.asp?PacienteID="+P+"&CallID=-999", function(data){ $("#modal").html(data) });
	}
</script>

    <%
        if lcase(tableName)="procedimentos" then
            server.execute("procedimentoRapido.asp")
        end if

        if lcase(tableName)="sys_preparos" or lcase(tableName)="sys_restricoes" then
            server.execute("preparoRestricaoRapido.asp")
        end if

        if lcase(tableName)="produtos" then
            server.execute("filtraProdutos.asp")
        end if

		if lcase(tableName)="convenios" then
            server.execute("ConvenioRapido.asp")
        end if

		if lcase(tableName)="protocolos" then
            server.execute("protocoloBuscaRapida.asp")
        end if


        if lcase(tableName)="pacientes" and session("OtherCurrencies")="phone" then
    %>
    <form method="post">
        <div class="clearfix form-actions hidden">
            <div class="col-md-12">
                <%
                set sta = db.execute("select * from chamadasconstatus")
                while not sta.eof
                %>
                <label>
                    <input type="radio" class="ace" name="ConstatusID" value="<%=sta("id") %>" <%if ref("ConstatusID")=cstr(sta("id")) then response.write(" checked ") end if %> /><span class="lbl"> <%=sta("NomeStatus") %></span></label>
                <%
                sta.movenext
                wend
                sta.close
                set sta=nothing
                %>
                <button class="btn btnxs btn-primary"><i class="far fa-filter"></i>Filtrar</button>
            </div>
        </div>
    </form>
    <%
        end if
    %>
<%
			if aut(lcase(tableName)&"A")=1 or aut(lcase(tableName)&"V")=1 then
				if req("X")<>"" then
					AutX = "S"
					if lcase(tableName)="funcionarios" or lcase(tableName)="profissionais" then
						AutX ="N"
						set vcAdmiOuProprio = db.execute("select pf.id UserID, lu.Admin from "&tableName&" pf left join sys_users u on (u.idInTable=pf.id and u.`Table` like '"&tableName&"') left join cliniccentral.licencasusuarios lu on lu.id=u.id where pf.id="&req("X"))
						if not vcAdmiOuProprio.eof then
							if vcAdmiOuProprio("UserID")=session("User") then
								ErroX = "Erro: voce não pode excluir o seu próprio cadastro."
							elseif vcAdmiOuProprio("Admin")=1 then
								ErroX = "Erro: você não pode excluir usuário MASTER do sistema."
							else
								AutX = "S"
							end if
						end if
					end if
					if AutX="N" then
%>
<script>alert('<%=ErroX%>');</script>
<%
					else
						if lcase(tableName)="funcionarios" or lcase(tableName)="profissionais" then
							'-> grava o log pra fatura
							if lcase(tableName)="profissionais" then Nome = "NomeProfissional" end if
							if lcase(tableName)="funcionarios" then Nome = "NomeFuncionario" end if
							set pNome = db.execute("select "&Nome&" from "&tableName&" where id="&req("X"))
							if not pNome.EOF then
								NomeExcluir = pNome(""&Nome&"")
							end if
							db_execute("insert into cliniccentral.licencaslogs (LicencaID, tipo, Nome, idTabela, acao, sysUser) values ("&replace(session("banco"), "clinic", "")&", '"&tableName&"', '"&NomeExcluir&"', '"&req("X")&"', 'X', "&session("User")&")")
							'<- grava o log pra fatura
						end if
                      'db_execute("delete from "&tableName&" where id="&req("X"))
                      db_execute("UPDATE "&tableName&" SET sysActive = -1 WHERE id="&req("X"))
						 db_execute("insert into log (I, Operacao, recurso, colunas, valorAnterior, valorAtual, sysUser) values ("&req("X")&", 'X', '"& tableName &"', '', '', '', "&session("User")&")")

						if lcase(tableName)="funcionarios" or lcase(tableName)="profissionais" then
							if lcase(tableName)="funcionarios" or lcase(tableName)="profissionais" then
								set userX = db.execute("select * from sys_users where idInTable="&req("X")&" and `Table`like '"&tableName&"'")
								if not userX.eof then
									'db_execute("delete from sys_Users where id="&userX("id"))
									'db_execute("delete from cliniccentral.licencasusuarios where id="&userX("id")&" and LicencaID="&replace(session("Banco"), "clinic", ""))
								end if
							end if
						end if
						if lcase(tableName)="feriados" then
							call desfazBloqueioFeriado(req("X"))
						end if
						response.Redirect("?P="&req("P")&"&Pers="&req("Pers"))
					end if
				end if
				q = trim(replace(replace(TirarAcento(req("q")), "'", "")," ", "%"))
				if q="" then
                    if ref("ConstatusID")<>"" then
                        sqlConstatus = " AND ConstatusID="&ref("ConstatusID")&" "
                    end if
					limite = 50
                    if req("sysActive")="" then
    					set conta = db.execute("select count(*) as total from "&tableName&" where sysActive=1"& sqlConstatus)
                    elseif req("sysActive")="-3" then
    					set conta = db.execute("select count(*) as total from "&tableName&" where sysActive=-3"& sqlConstatus)
                    else
    					set conta = db.execute("select count(*) as total from "&tableName&" where sysActive="&req("sysActive")& sqlConstatus)
                    end if
					'response.Write("("&conta("total")&")")
					total = ccur(conta("total"))
					if total>=limite then
						paginar=1
%>
<div class="row text-center hidden-xs">
    <ul class="pagination pagination-sm">
        <li<%if req("Initial")="" then%> class="active" <%end if%>>
                                    <a href="./?P=<%=req("P")%>&Pers=<%=req("Pers")%>">
                                        TODOS
                                    </a>
                                </li>
                                <%
                                if req("sysActive")&""<>""  then
                                   sysActive= "&sysActive=-1"
                                else
                                    sysActive = ""
                                end if

                                nchr=64
                                while nchr<90
                                    nchr=nchr+1
                                    vchr=chr(nchr)
                                    %>
                                    <li<%if req("Initial")=vchr then%> class="active"<%end if%>>
                                        <a href="./?P=<%=req("P")%>&Pers=<%=req("Pers")%><%=sysActive%>&Initial=<%=vchr%>"><%=vchr%></a>
                                    </li>
                                    <%
                                wend

                                if req("P")="Procedimentos" or req("P")="Pacotes" then
                                %>
                                <li>
                                    <a href="./?P=<%=req("P")%>&Pers=<%=req("Pers")%>&Print=1"><i class="far fa-print"></i></a>
                                </li>
                                <%
                                end if
                                %>
    </ul>
</div>
<%
						Initial = req("Initial")
						if Initial<>"" then
							sqlInitial = "and "&initialOrder&" like '"&Initial&"%'"
						end if
						Pag = req("Pag")
						if isnumeric(Pag) and Pag<>"" then
							partirde = limite*(Pag-1)&", "
						end if
					end if
                    palLimit = " limit "
                    if req("Print")="1" then
                        partirde = ""
                        limite = ""
                        palLimit = ""
                    end if
                    if req("sysActive")="" then
                        if lcase(tableName)="profissionais" or lcase(tableName)="funcionarios" or lcase(tableName)="fornecedores" or lcase(tableName)="equipamentos" or lcase(tableName)="convenios" or lcase(tableName)="tabelaparticular" or lcase(tableName)="pacotes" then
    					    sqlReg = "select * from "&tableName&" where sysActive=1 "&sqlInitial & sqlConstatus &"  "&franquia(" AND Unidades like '%|[UnidadeID]|%' ")&" order by ativo desc, "&initialOrder& palLimit &partirde&limite
                        elseif lcase(tableName)="procedimentos" then
    					    sqlReg = "select * from "&tableName&" where sysActive=1 "&sqlInitial & sqlConstatus &" order by ativo desc, "&initialOrder& palLimit&partirde&limite
                        elseif lcase(tableName)="pacientes" and session("SepararPacientes") and aut("vistodospacsV")=0 and lcase(session("Table"))="profissionais" then
                            sqlReg = "select * from pacientes where Profissionais like '%|ALL|%' or Profissionais like '%|"& session("idInTable") &"|%' and sysActive=1 "&sqlInitial & sqlConstatus &" order by "&initialOrder& palLimit &partirde&limite
                        else
    					    sqlReg = "select * from "&tableName&" where sysActive=1 "&sqlInitial & sqlConstatus &" order by "&initialOrder& palLimit &partirde&limite
                        end if
                    else
    					sqlReg = "select * from "&tableName&" where sysActive="&req("sysActive")&" "&sqlInitial& sqlConstatus & " order by "&initialOrder& palLimit &partirde&limite
                    end if
					'sqlReg = "select * from "&tableName&" where sysActive=1 "&sqlInitial&" order by "&initialOrder&" limit 110"
				else
                    if isdate(q) then
                        sqlNasc = " OR Nascimento="& mydatenull(q) &" "
                    end if
					if lcase(tableName)="pacientes" then
					if isnumeric(q) then
					        sqlBuscaNumerica = " or replace(replace(CPF,'.',''),'-','') like replace(replace('"&q&"%','.',''),'-','') or Tel1 like '%"&q&"%' or Tel2 like '%"&q&"%' or Cel1 like '%"&q&"%' or Cel2 like '%"&q&"%' or id = '"&q&"' or (idImportado = '"&q&"' and idImportado <>0) "
					    end if
					    sqlBuscaNome = " OR NomePaciente like '%"&q&"%' or NomeSocial like '"&q&"%' "

					    if PorteClinica > 3 then

                           q = replace(UCASE(q),UCASE("José%"),"José ")
                           q = replace(UCASE(q),UCASE("Jose%"),"Jose ")
                           q = replace(UCASE(q),UCASE("Maria%"),"Maria ")
                           q = replace(UCASE(q),UCASE("Mari%"),"Mari ")
                           q = replace(UCASE(q),UCASE("Ana%"),"Ana ")
                           q = replace(UCASE(q),UCASE("%Das%"),"%Das ")
                           q = replace(UCASE(q),UCASE("%De%"),"%De ")
                           q = replace(UCASE(q),UCASE("Antonio%"),"Antonio ")
                           q = replace(UCASE(q),UCASE("Antônio%"),"Antônio ")
                           q = replace(UCASE(q),UCASE("Francisco%"),"Francisco ")
                           q = replace(UCASE(q),UCASE("Silva%"),"Silva ")

					        sqlBuscaNome = " OR NomePaciente like '%"&q&"%' "
                            if isnumeric(q) then
                                sqlBuscaNumerica = " OR CPF = '"&q&"' OR id = '"&q&"' OR Cel1 = '"&q&"' OR Tel1 = '"&q&"' "
                                sqlBuscaNome = ""
                            end if
							if isdate(q) then
								sqlBuscaNome = ""
							end if
					    end if


                        if session("SepararPacientes") and aut("vistodospacsV")=0 and lcase(session("Table"))="profissionais" then
                            sqlReg = "select * from pacientes where (trim(NomePaciente) like '%"&q&"%' or TRIM(NomeSocial) like '%"&q&"%' or replace(replace(CPF,'.',''),'-','') like replace(replace('"&q&"%','.',''),'-','') or Tel1 like '%"&q&"%' or Tel2 like '%"&q&"%' or Cel1 like '%"&q&"%' or Cel2 like '%"&q&"%' or id = '"&q&"' or (idImportado = '"&q&"' and idImportado <>0) "& sqlNasc &") and (Profissionais like '%|ALL|%' or Profissionais like '%|"& session("idInTable") &"|%') and sysActive=1 ORDER BY sysActive DESC LIMIT 100"
                        else
    						sqlReg = "select * from pacientes where (False "&sqlBuscaNome&" "&sqlBuscaNumerica& sqlNasc &") LIMIT 100"
                        end if

                        sqlReg = "SELECT * FROM ("&sqlReg&") as T ORDER BY IF(sysActive=1,0,1), 2"

                    elseif lcase(tableName)="profissionais" or lcase(tablename)="funcionarios" then
    					sqlReg = "select * from "&tableName&" where sysActive=1 and ("&initialOrder&" like '%"&q&"%' "& sqlNasc &") "&franquia(" AND Unidades like '%|[UnidadeID]|%' ")&" order by IF(ativo='on' and sysActive=1,0,1), "&initialOrder
						' response.write(sqlReg)

					elseif lcase(tableName)="procedimentos" then
						sqlReg = "select * from "&tableName&" where sysActive=1 and "&initialOrder&" like '%"&q&"%' OR Sigla LIKE '%"&q&"%' OR Codigo LIKE '%"&q&"%' order by IF(ativo='on' and sysActive=1,0,1), "&initialOrder
					elseif lcase(tableName)="fornecedores" then
                        sqlReg = "select * from "&tableName&" where sysActive=1 and "&initialOrder&" like '%"&q&"%' OR replace(replace(replace(CPF,'.',''),'-',''),'/','') like replace(replace(replace('"&q&"%','.',''),'-',''),'/','') order by IF(ativo='on' and sysActive=1,0,1),"&initialOrder
					elseif lcase(tableName)="produtos" then
                        sqlReg = "select * from "&tableName&" where sysActive=1 and "&initialOrder&" like '%"&q&"%' OR id = '"&q&"' order by IF(sysActive=1,0,1), "&initialOrder
					else
						sqlReg = "select * from "&tableName&" where sysActive=1 and "&initialOrder&" like '%"&q&"%' order by IF(sysActive=1,0,1), "&initialOrder
					end if
				end if
				
				'---> Rotina pra mostrar ou não o link de extrato
				set aass = db.execute("select * from cliniccentral.sys_financialaccountsassociation where `table` like '"&tableName&"'")
				if not aass.eof then
					if (lcase(tableName)="pacientes" and aut("contapacV")=1) or ( lcase(tableName)="profissionais" and aut("contaprofV")=1 ) or ( (lcase(tableName)="sys_financialcurrentaccounts" or lcase(tableName)="fornecedores" or lcase(tableName)="convenios" or lcase(tableName)="tabelaparticular" or lcase(tableName)="pacotes" or lcase(tableName)="funcionarios") and aut("movementV")=1 ) then
						associacao = aass("id")
					end if
				end if
				'<--- Rotina pra mostrar ou não o link de extrato
%>
<br />
<div class="panel">
<div class="panel-body <%if paginar="" and 1=2 then%> table-responsive <%end if%>">
    <div id="divProcedimentoRapido">

    </div>

				<table id="table-<%=tableNameXXXX%>" class="table table-striped table-bordered table-hover">
					<thead>
						<tr class="info">
							<th class="center hidden-xs" width="1%">
								<label>
									<input type="checkbox" class="ace" />
									<span class="lbl"></span>
								</label>
							</th>
                            <%if lcase(tableName)="pacientes" then%>
							<th class="hidden-xs">Prontu&aacute;rio</th>
							<%
							end if
	                        set fieldsInList = db.execute("select * from cliniccentral.sys_resourcesfields where resourceID="&res("id")&" and showInList=1")
							while not fieldsInList.eof
								if instr(Omitir, "|"&lcase(fieldsInList("columnName"))&"|")=0 then
									lineToExecute = lineToExecute&fieldsInList("columnName")&"|"
									ordersNull = ordersNull&"null,"
                                end if
								lineToExecuteFieldType = lineToExecuteFieldType&fieldsInList("fieldTypeID")&"|"
								lineToExecuteSelectSQL = lineToExecuteSelectSQL&fieldsInList("selectSQL")&"|"
								lineToExecuteSelectColumnToShow = lineToExecuteSelectColumnToShow&fieldsInList("selectColumnToShow")&"|"
								responsibleColumnHidden = fieldsInList("responsibleColumnHidden")
								if initialOrder = fieldsInList("columnName") then
									arrInitialOrder = arrInitialOrder&"1"&"|"
                                    hiddenXS = ""
								else
									arrInitialOrder = arrInitialOrder&"0"&"|"
                                    hiddenXS = " hidden-xs "
								end if
								arrResponsibleColumnHidden = arrResponsibleColumnHidden&responsibleColumnHidden&"|"
                            'response.Write("{"&omitir&"}")
							if instr(Omitir, "|"&lcase(fieldsInList("columnName"))&"|")=0 then

                                if req("Print")="1" then
                                    hiddenXS = ""
                                end if

								%>
								<th class="<%=responsibleColumnHidden & hiddenXS %>"><%=fieldsInList("label")%></th>
								<%
							end if
							fieldsInList.movenext
							wend
							fieldsInList.close
							set fieldsInList=nothing
							if lcase(tableName)="pacientes" or lcase(tableName)="buiforms" then
								arrInitialOrder = arrInitialOrder&"0|"
								ordersNull = ordersNull&"null,"
							end if
							if session("Admin")=1 and lcase(tableName)="profissionais" or lcase(tableName)="funcionarios" then
								ordersNull = ordersNull&"null,"
								%>
    	                        <th><i class="far fa-lock"></i> Perfil</th>
                                <%
							end if
							if lcase(tableName)="pacientes" and aut("agendaV")=1 then
								ordersNull = ordersNull&"{ ""bSortable"": false },{ ""bSortable"": false },"
								%>
								<th width="100">Propostas</th>
								<th width="100" class="hidden-xs" nowrap>&Uacute;lt. Agend.</th>
								<th width="100" class="hidden-xs" nowrap>Pr&oacute;x. Agend.</th>
								<%
							end if
							if req("P")="buiforms" then
								%>
								<th>Registros</th>
								<%
							end if
                            if lcase(tableName)="pacotes" then
                                %>
                                <th>Valor Total</th>
                                <%
                            end if
							%>
							<th width="1%" class="hidden-print"></th>
						</tr>
					</thead>
		
					<tbody>
                    	<%
						set reg = db.execute(sqlReg)
						while not reg.eof
						%>
						<% 
						
						if lcase(tablename)="basedeconhecimento" then 
							dtAtualizacao = reg("sysDate")
							sqlConfig = "select * from sys_config limit 1"
							set config = db.execute(sqlConfig)
							NMeses = 1
							if not config.eof then
								NMeses = config("NMesesPergunta")
							end if
							hoje = date()
							datalimite=dateadd("m",NMeses,hoje)
							
							classLinha = ""

							if datalimite < reg("sysDate")then
								classLinha = "class='danger'" 
							end if
						end if %>
						<tr <%=classLinha%> >
							<td class="center hidden-xs">
								<label>
									<input type="checkbox" class="ace" />
									<span class="lbl"></span>
								</label>
							</td>
							<%if lcase(tableName)="pacientes" then%>
                            <td class="hidden-xs"><%
                            if getConfig("AlterarNumeroProntuario") = 1 then
                            'if session("banco")="clinic1612" or session("banco")="clinic3610" or session("banco")="clinic105" or session("banco")="clinic3859" or session("banco")="clinic5491" then
                            %>
                            <%=reg("idImportado")%>
                            <%else%>
                            <%=reg("id")%>
                            <%end if%></td>
							<%
							end if
							splfieldsInList = split(lineToExecute,"|")
							splfieldFieldType = split(lineToExecuteFieldType,"|")
							splfieldSelectSQL = split(lineToExecuteSelectSQL,"|")
							splfieldSelectColumnToShow = split(lineToExecuteSelectColumnToShow,"|")
							splArrInitialOrder = split(arrInitialOrder,"|")
							splArrResponsibleColumnHidden = split(arrResponsibleColumnHidden, "|")
							for i = 0 to uBound(splfieldsInList)
								if splfieldsInList(i)<>"" then
									valor = ""
									if splArrInitialOrder(i)=1 then
										Aopen = "<a href=""?P="&tableName&"&I="&reg("id")&"&Pers="&Pers&""">"
										Aclose = "</a>"
                                        hiddenXS = ""
									else
										Aopen = ""
										Aclose = ""
                                        hiddenXS = " hidden-xs "
									end if
									if splfieldFieldType(i)="3" then
										quebraSQL = split(splfieldSelectSQL(i), "where")
										sql = quebraSQL(0)&" where id="& treatvalzero(reg(splfieldsInList(i))) &""
'										response.Write(sql)
										set pval = db.execute(sql)
										if not pval.EOF then
											valor = pval(""&splfieldSelectColumnToShow(i)&"")
										end if
									else
										valor = ""
										if splfieldsInList(i) <> "" then
										valor = reg(splfieldsInList(i))
										end if
									end if
									if splfieldFieldType(i)=5 then
										if valor <>"" then
											valor = "Sim"
										end if
									end if
									if splfieldFieldType(i)=6 then
										classeRight = " text-right"
										if isnumeric(valor) and valor<>"" and not isnull(valor) then
											valor = formatnumber(valor,2)
										end if
									elseif splfieldFieldType(i)=24 then
										if valor=0 then
											set emp = db.execute("select NomeFantasia from empresa")
											if not emp.eof then
												valor = emp("NomeFantasia")
											else
												valor = "-"
											end if
										else
											set fil = db.execute("select NomeFantasia from sys_financialcompanyunits where id="&valor)
											if not fil.eof then
												valor = fil("NomeFantasia")
											else
												valor = "-"
											end if
										end if
										classeRight = ""
									elseif splfieldFieldType(i)=27 then
                                        classeRight = ""
                                        Valor = ""
                                        optSelecteds = reg(splfieldsInList(i))&""
                                        set preg = db.execute(splfieldSelectSQL(i))
                                        while not preg.eof
                                            if instr(optSelecteds, "|"& preg("id") &"|")>0 then
                                                Valor = Valor & preg(splfieldSelectColumnToShow(i)) &", "
                                            end if
                                        preg.movenext
                                        wend
                                        preg.close
                                        set preg = nothing
                                        if len(Valor)>2 then
                                            Valor = left(Valor&"", len(Valor&"")-2)
                                        end if
                                    elseif splfieldFieldType(i)=11 and isdate(Valor&"") and not isnull(Valor) then
                                        Valor = formatdatetime( Valor, 3 )
									else
										classeRight = ""
									end if

                                    if (lcase(tableName)="profissionais" or lcase(tableName)="funcionarios" or lcase(tableName)="procedimentos" or lcase(tableName)="equipamentos" or lcase(tableName)="fornecedores" or lcase(tableName)="convenios" or lcase(tableName)="tabelaparticular" or lcase(tableName)="pacotes") and splArrInitialOrder(i)=1 then
                                        if reg("Ativo")="" then
                                            valor = "<code>Inativo</code>" & valor
                                        end if
                                    end if
                                    if reg("sysActive")= -1 and (i=0) then
                                        valor = "<code>Excluído</code>" & valor
                                    end if

                                    if req("Print")="1" then
                                        hiddenXS = ""
                                    end if
									%>
									<td class="<%=splArrResponsibleColumnHidden(i) & classeRight & hiddenXS%>">
									<%=Aopen%>
                                        <%
                                        if lcase(tablename)="pacientes" and session("OtherCurrencies")="phone" and (splfieldsInList(i)="Tel1" or splfieldsInList(i)="Cel1") then
                                            response.write( prebtb(reg("id"), valor, splfieldsInList(i)) )
										else
											response.write( valor )
                                        end if
                                        %>
                                    <%=Aclose%>
									</td>
									<%
								end if
							next
                            Key = ""
							if session("Admin")=1 and lcase(tableName)="profissionais" or lcase(tableName)="funcionarios" then
								set perf = db.execute("select * from sys_users where `Table`='"&tableName&"' and idInTable="&reg("id"))
								Permissoes = ""
								Perfil = "<i class=""far fa-exclamation-triangle red""></i> Nenhum"
								if not perf.eof then
                                    set lu = db.execute("select * from cliniccentral.licencasusuarios where id="&perf("id")&" and Email<>'' and (Senha<>'' or SenhaCript<>'')")
                                    if lu.eof then
                                        Key = ""
                                    else
                                        Key = "<i class='far fa-key text-warning' title='"&lu("Email")&"'></i>&nbsp;"
                                    end if
									Permissoes = perf("Permissoes")
									if instr(Permissoes, "[") then
										splPerm = split(Permissoes, "[")
										splPerm2 = split(splPerm(1), "]")
										Perfil = splPerm2(0)
										'response.Write(Perfil&"<br><br>")
										
										set regra = db.execute("select regra from regraspermissoes where id="&Perfil)
										if not regra.eof then
											Perfil = regra("regra")
										else
											Perfil = "<i class=""far fa-exclamation-triangle red""></i> Nenhum"
										end if
									end if
								end if
								%>
    	                        <td><%=Key %> <%=Perfil%></td>
                                <%
							end if
							if lcase(tableName)="pacientes" and aut("agendaV")=1 then
								calendars = calendars & reg("id") & ", "
								%>
								<td class="pn hidden-xs" id="proposta<%= reg("id") %>"></td>
								<td class="pn hidden-xs" id="calendarH<%=reg("id")%>"></td>
								<td class="pn hidden-xs" id="calendar<%=reg("id")%>"></td>
								<%
							end if
							if req("P")="buiforms" then
							set conta = db.execute("select count(*) total from buiformspreenchidos where sysActive=1 AND ModeloID="&reg("id"))
								Preenchidos = conta("total")
								if isnull(Preenchidos) or Preenchidos="0" then
									NaoExcluir = ""
								else
									NaoExcluir = "S"
								end if
							%>
                            <td nowrap width="1%" class="text-right">
                            <%=Preenchidos%>
                            </td>
                            <%
							end if
                            if lcase(tableName)="pacotes" then
                                set cvt = db.execute("select ifnull(sum(ValorUnitario), 0) Total from pacotesitens where PacoteID="& reg("id"))
                                %>
                                <td class="text-right">R$ <%= fn(cvt("Total")) %></td>
                                <%
                            end if
							%>
							<td width="1%" nowrap="nowrap" class="hidden-print">
								<div class="action-buttons">
                                    <%
                                    ExibirEditar="S"
                                    if req("P")="buiforms" then
                                        set buif = db.execute("select sysUser from buiforms where sysActive=1 and id="&reg("id"))
                                        if not buif.eof then
                                            if aut("buiformsA")=1 then
                                                ExibirEditar="S"
                                            elseif (buif("sysUser")<>session("User") and aut("buiformsA")=0) then
                                                ExibirEditar=""
                                            end if
                                        end if
                                    end if
                                    if ExibirEditar<>"" then
                                    %>

									<a class="btn btn-xs btn-info tooltip-info" data-rel="tooltip" title="Editar" href="?P=<%=tableName%>&I=<%=reg("id")%>&Pers=<%=Pers%>">
										<i class="far fa-edit bigger-130"></i>
									</a>
                                    <%
                                    end if
                                    If session("Admin")=1 and (lcase(tableName)="profissionais" or lcase(tableName)="funcionarios") Then %>
									<a class="btn btn-xs btn-warning tooltip-warning" title="Permiss&otilde;es" data-rel="tooltip" href="?P=<%=tableName%>&I=<%=reg("id")%>&Pers=<%=Pers%>&GT=Permissoes">
										<i class="far fa-lock bigger-130"></i>
									</a>
									<%
									end if
									if associacao<>"" then
										if lcase(tableName)="pacientes" then
											%>
											<a class="btn btn-xs btn-success tooltip-success" title="Conta e Extrato" data-rel="tooltip" href="?P=Pacientes&Pers=1&I=<%=reg("id")%>&Ct=1">
												<i class="far fa-money bigger-130"></i>
											</a>
											<%
										else
											%>
											<a class="btn btn-xs btn-success tooltip-success" title="Extrato" data-rel="tooltip" href="?P=Extrato&Pers=1&T=<%=associacao%>_<%=reg("id")%>">
												<i class="far fa-money bigger-130"></i>
											</a>
											<%
										end if
									end if
									if aut(lcase(tableName)&"X")=1 and NaoExcluir="" and lcase(tableName)<>"profissionais" and lcase(tableName)<>"funcionarios" then
									%>
									<a class="btn btn-xs btn-danger tooltip-danger" title="Excluir" data-rel="tooltip" href="javascript:if(confirm('Tem certeza de que deseja excluir este registro?'))location.href='?P=<%=req("P")%>&X=<%=reg("id")%>&Pers=<%=req("Pers")%>';">
										<i class="far fa-remove bigger-130"></i>
									</a>
                                    <%
									end if
									%>
								</div>
		
							</td>
						</tr>
                        <%
						reg.movenext
						wend
						reg.close
						set reg=nothing
						%>
					</tbody>
				</table>
			</div>
    </div>
            <%
				if calendars<>"" and len(calendars)<300 then
					calendars = left(calendars, len(calendars)-2 )
					'response.Write(calendars)
					response.Write("<script>")

					set prop = db.execute("select PacienteID from propostas where PacienteID IN("& calendars &") and sysActive=1 and DataProposta>=CURDATE()-30")
					while not prop.eof
						btnProp = "<button class='btn btn-xs btn-alert' type='button' onclick='viewProp("& prop("PacienteID") &")'>Ver Propostas</button>"
						%>
						$("#proposta<%= prop("PacienteID") %>").html("<%=btnProp%>");
						<%
					prop.movenext
					wend
					prop.close
					set prop = nothing

					set age = db.execute("select a.PacienteID, a.id, a.Data, a.Hora, p.NomeProfissional from agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID where a.PacienteID in ("&calendars&") and a.Data>=date(now()) and not isnull(Hora) and a.sysActive = 1 group by a.PacienteID order by a.Data, a.Hora")
					while not age.eof
						Hora = age("Hora")
						if not isnull(Hora) then
							Hora = formatdatetime(age("Hora"),4)
						end if
						%>
						$("#calendar<%=age("PacienteID")%>").html( $("#calendar<%=age("PacienteID")%>").html() + '<button data-rel="tooltip" type="button" onClick="location.href=\'./?P=Agenda-1&Pers=1&AgendamentoID=<%=age("id")%>\';" class="btn btn-xs btn-success btn-alt btn-gradient item-active mn tooltip-success" data-original-title="Profissional &raquo; <%=age("NomeProfissional")%>"><i class="far fa-calendar"></i> <%=left(age("Data"),5)%> - <%=Hora%></button>');
						<%
					age.movenext
					wend
					age.close
					set age=nothing

					set age = db.execute("select a.PacienteID, a.id, a.Data, a.Hora, p.NomeProfissional from agendamentos a LEFT JOIN profissionais p on p.id=a.ProfissionalID where a.PacienteID in ("&calendars&") and a.Data<date(now()) and not isnull(a.Hora) order by a.PacienteID, a.Data desc, a.Hora desc limit 1")

					while not age.eof
						%>
						$("#calendarH<%=age("PacienteID")%>").html( $("#calendarH<%=age("PacienteID")%>").html() + '<button data-rel="tooltip" type="button" onClick="location.href=\'./?P=Agenda-1&Pers=1&AgendamentoID=<%=age("id")%>\';" class="btn btn-xs btn-alert btn-alt btn-gradient item-active mn tooltip-info" data-original-title="Profissional &raquo; <%=age("NomeProfissional")%>"><i class="far fa-calendar"></i> <%=age("Data")%> - <%=formatdatetime(age("Hora"),4)%></button>');
						<%
					age.movenext
					wend
					age.close
					set age=nothing
					response.Write("</script>")
				end if
			
				if paginar=1 then
					%>
                    <div class="row text-center">
                    <ul class="pagination pagination-sm">
					<%
					if req("sysActive")&""<>""  then
                       sysActive= "&sysActive=-1"
                       active = "-1"
                    else
                        sysActive = ""
                        active = "1"

                    end if

					contaLetra = db.execute("select count(*) as totalletra from "&tableName&" where sysActive="&active&" "&sqlInitial)
					regLetra = ccur(contaLetra("totalletra"))
                    if req("Print")="" then
					    if regLetra>0 then
						    paginas = cint(regLetra/limite)
						    if regLetra>(paginas*limite) then
							    paginas = paginas+1
						    end if
					    end if
                    else
                        %>
                        <script>
                            print();
                        </script>
                        <%
                    end if
					
					numeroPagina = 0

					if req("Pag")="" or not isnumeric(req("Pag")) then
						PaginaAtual = 1
					else
						PaginaAtual = ccur(req("Pag"))
					end if
					LimiteAnt = PaginaAtual - 12
					LimitePos = PaginaAtual + 12

					while nPagina<paginas
						nPagina = nPagina+1
						
						'response.Write(nPagina &">="& LimiteAnt &" and "& nPagina &"<="& LimitePos &"<br>")
						if nPagina >= LimiteAnt and nPagina <= LimitePos then
						%>
                        <li<%if (req("Pag")="" and nPagina=1) or req("Pag")=cstr(nPagina) then%> class="active"<%end if%>>
                            <a href="./?P=<%=req("P")%>&Pers=<%=req("Pers")%><%=sysActive%>&Initial=<%=req("Initial")%>&Pag=<%=nPagina%>"><%=nPagina%></a>
                        </li>
						<%
						end if
					wend
					%>
                    </ul>
                    </div>
                    <%
				end if
			end if
			if total<500 then
			%>
			<script type="text/javascript">
			    jQuery(function($) {
			        var oTable1 = $('#table-<%=tableName%>').dataTable( {
			            "aoColumns": [
                          { "bSortable": false },
                          <%=ordersNull%>
                          { "bSortable": false }
			            ] } );

                    <% IF session("Franqueador") <> "" THEN %>
                        oTable1 = $('#table-').dataTable( {
                        "aoColumns": [
                          { "bSortable": false },
                          <%=ordersNull%>
                          { "bSortable": false }
                        ] } );
                    <% END IF %>


					
			        $('table th input:checkbox').on('click' , function(){
			            var that = this;
			            $(this).closest('table').find('tr > td:first-child input:checkbox')
						.each(function(){
						    this.checked = that.checked;
						    $(this).closest('tr').toggleClass('selected');
						});
							
			        });
				
				
			        $('[data-rel="tooltip"]').tooltip({placement: tooltip_placement});
			        function tooltip_placement(context, source) {
			            var $source = $(source);
			            var $parent = $source.closest('table')
			            var off1 = $parent.offset();
			            var w1 = $parent.width();
				
			            var off2 = $source.offset();
			            var w2 = $source.width();
				
			            if( parseInt(off2.left) < parseInt(off1.left) + parseInt(w1 / 2) ) return 'right';
			            return 'left';
			        }
			    })
			</script>
			<%
			end if
		end if
	else
		'show the form in insert and update mode
		if id="N" then
			sqlVie = "select id, sysUser, sysActive from "&tableName&" where sysUser="&session("User")&" and sysActive=0"
			set vie = db.execute(sqlVie)
			if vie.eof then
				db_execute("insert into "&tableName&" (sysUser, sysActive) values ("&session("User")&", 0)")
				set vie = db.execute(sqlVie)
			end if
			response.Redirect("?P="&tableName&"&I="&vie("id")&"&Pers="&Pers)
		else
			set data = db.execute("select * from "&tableName&" where id="&id)
			if data.eof then
				response.Redirect("?P="&tableName&"&I=N&Pers="&Pers)
			end if
		end if
	
	
		set res = db.execute("select * from cliniccentral.sys_resources where tableName='"&tableName&"'")
		if not res.eof then
	
			if ref("E")="E" then
	
				set fieldsToUpdate = db.execute("select * from cliniccentral.sys_resourcesFields where resourceID="&res("id"))
				while not fieldsToUpdate.eof
					val = ref(fieldsToUpdate("ColumnName"))
					if fieldsToUpdate("fieldTypeID")=10 or fieldsToUpdate("fieldTypeID")=13 then
						if isDate(val) then
							val = "'"&year(val)&"-"&month(val)&"-"&day(val)&"'"
						else
							val = "NULL"
						end if
					elseif fieldsToUpdate("fieldTypeID")=11 then
						if not isDate(val) or val="" then
							val = "NULL"
						else
							val = "'"&val&"'"
						end if
					elseif fieldsToUpdate("fieldTypeID")=12 then
						if isDate(val) then
							val = "'"&year(val)&"-"&month(val)&"-"&day(val)&" "&hour(val)&":"&minute(val)&":"&second(val)&"'"
						else
							val = "NULL"
						end if
					elseif fieldsToUpdate("fieldTypeID")=4 or fieldsToUpdate("fieldTypeID")=7 then
						if not isNumeric(val) or val="" then
							val = "0"
						end if
					elseif fieldsToUpdate("fieldTypeID")=6 then
						val = replace(val, ".", "")
						val = replace(val, ",", ".")
						if not isNumeric(val) or val="" then
							val = "NULL"
						end if
					else
					val = "'"&val&"'"
					end if
					sqlUpdate = sqlUpdate &fieldsToUpdate("columnName")&"="&val&", "
				fieldsToUpdate.moveNext
				wend
				fieldsToUpdate.close
				set fieldsToUpdate = nothing
	
				sqlUpdate = "update "&tableName&" set "&sqlUpdate&" sysActive=1 where id="&id
'				response.Write(sqlUpdate)
                'call logMessage(tableName,id, "Cadastro alterado.")
				db_execute(sqlUpdate)

				'verifica se é feriado e se precisa bloquear na agenda
				if lcase(tableName)="feriados" then
					nomeferiado = ref("NomeFeriado")
					data = ref("Data")
					recorrente = ref("Recorrente")
					bloquear = ref("BloquearAgenda")

					call desfazBloqueioFeriado(id)

					if bloquear <> "" then
						ocorrencias = 1
						inicio = 0

						data = DateValue(DAY(data) & "/" & MONTH(data) & "/" & YEAR(Date))

						if data <= Date then
							inicio = 1
						end if 

						data = DateAdd("yyyy",inicio,data)
						sqlBloqueio = "insert into compromissos (FeriadoID, DataDe, DataA, HoraDe, HoraA, ProfissionalID, Titulo, Descricao, Usuario, Data, DiasSemana, Profissionais, Unidades, BloqueioMulti) values ("&id&",'"&mydate(data)&"', '"&mydate(data)&"', '00:00', '23:59', '0', '"&nomeferiado&" (feriado)', '', '"&session("User")&"', '"&now()&"', '1 2 3 4 5 6 7','','','S')"
						db_execute(sqlBloqueio)

						if recorrente <> "" then
							inicio = inicio+1
							For i = 1 To 5 
								data = DateAdd("yyyy",inicio,data)
								sqlBloqueio = "insert into compromissos (FeriadoID, DataDe, DataA, HoraDe, HoraA, ProfissionalID, Titulo, Descricao, Usuario, Data, DiasSemana, Profissionais, Unidades, BloqueioMulti) values ("&id&",'"&mydate(data)&"', '"&mydate(data)&"', '00:00', '23:59', '0', '"&nomeferiado&" (feriado)', '', '"&session("User")&"', '"&now()&"', '1 2 3 4 5 6 7','','','S')"
								db_execute(sqlBloqueio)
							Next
						end if
					end if
				end if

				response.Redirect("?P="&tableName)
	
			end if

			set pfields = db.execute("select * from cliniccentral.sys_resourcesFields where resourceID="&res("id")&" and showInForm=1 order by rowNumber")
			%>
			<br>
            				<div class="panel">
            				<div class="panel-body">

            				<%
			while not pfields.eof
				endRow = "</div>"
				if currentRow<>pFields("rowNumber") then
					if currentRow<>"" then
						response.Write("</div>")
					end if
					startRow = "<div class=""row"" id=""row"&pFields("rowNumber")&""">"
				else
					startRow = ""
				end if
				currentRow = pFields("rowNumber")

				response.Write(startRow)

				fieldTypeID = pFields("fieldTypeID")
				fieldValue = data(""&pFields("columnName")&"")
				colSize = pFields("size")
				fRequired = pfields("required")
				if fRequired=1 then
				    required = " required "
                else
                    required = 0
				end if
				select case fieldTypeID
					case 1'Texto
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<input type="text" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" placeholder="<%=pfields("Placeholder")%>" class="form-control search-query" <%=required%>/>
						</div>
						<%
					case 2'Memorando
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<textarea class="form-control" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" placeholder="<%=pfields("Placeholder")%>"><%=fieldValue%></textarea>
						</div>
						<%
					case 3'Select com filtro
                        call quickField("simpleSelect", pFields("ColumnName"), pfields("Label"), pFields("size"), fieldValue, pFields("selectSQL"), pFields("selectColumnToShow"), "")
					case 4'Radio
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<%
						set listItems = db.execute(pfields("selectSQL"))
						while not listItems.EOF
						%>
						<div class="radio">
							<label>
								<input name="<%=pFields("ColumnName")%>" id="<%=pFields("ColumnName")%>_<%=listItems("id")%>" value="<%=listItems("id")%>" type="radio" class="ace"<%if fieldValue=listItems("id") then%> checked="checked"<%end if%> />
								<span class="lbl"><%=listItems(""&pFields("selectColumnToShow")&"")%></span>
							</label>
							
						</div>
						<%
						listItems.movenext
						wend
						listItems.close
						set listItems=nothing
						%>
						</div>
						<%
					case 5'Checkboxes

						if pFields("ColumnName")="Ativo" then
						%>
						    <div class="col-md-<%=colSize%>">
                                <label>
                                    <%=pFields("ColumnName")%>
                                    <br />
                                    <%
                                    set listItems = db.execute("select * from "&lcase(tableName)&" where id="&req("I"))
                                    while not listItems.EOF
                                    %>
                                    <div class="switch round">
                                        <input type="checkbox" <% If listItems("Ativo")="on" or isnull(listItems("Ativo")) Then %> checked="checked"<%end if%> name="<%=pFields("ColumnName")%>" id="<%=pFields("ColumnName")%>">
                                        <label for="<%=pFields("ColumnName")%>">Label</label>
                                    </div>
                                    <%
                                    listItems.movenext
                                    wend
                                    listItems.close
                                    set listItems=nothing
                                    %>
                                </label>
                              </div>
						<%else%>
                            <div class="col-md-<%=colSize%>">
                            <label for="<%=pFields("ColumnName")%>">
                            <%=pfields("Label")%>
                            </label>
                            <%
                            set listItems = db.execute(pfields("selectSQL"))
                            while not listItems.EOF
                            %>
                            <div class="checkbox">
                                <label>
                                    <input name="<%=pFields("ColumnName")%>" value="|<%=listItems("id")%>|" type="checkbox" class="ace"<%if inStr(fieldValue, "|"&listItems("id")&"|")>0 then%> checked="checked"<%end if%> />
                                    <span class="lbl"><%=listItems(""&pFields("selectColumnToShow")&"")%></span>
                                </label>
                            </div>
                            <%
                            listItems.movenext
                            wend
                            listItems.close
                            set listItems=nothing
                            %>
                            </div>
                        <%
                        end if
					case 6'Moeda
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<div class="input-group">
						<span class="input-group-addon">
						<strong>R$</strong>
						</span>
						<input class="form-control input-mask-brl" placeholder="<%=pfields("Placeholder")%>" type="text" value="<%=fieldValue%>" name="<%=pFields("ColumnName")%>" id="<%=pFields("ColumnName")%>" style="text-align:right" />
						</div>
						</div>
						<%
					case 7'Número com spinner
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label><br />
	
						<input type="text" class="input-mini" placeholder="<%=pfields("Placeholder")%>" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" />
						<div class="space-6"></div>
	
						</div>
<script type="text/javascript">
    document.getElementById('spinners').value=document.getElementById('spinners').value+"$('#<%=pFields("ColumnName")%>').ace_spinner({value:<%=fieldValue%>,min:0,max:20000,step:1, btn_up_class:'btn-info' , btn_down_class:'btn-info'}).on('change', function(){});";
						</script>
						<%
					case 8'CPF
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<input type="text" placeholder="<%=pfields("Placeholder")%>" class="form-control input-mask-cpf" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" />
	
						</div>
						<%
					case 9'CNPJ
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<input type="text" placeholder="<%=pfields("Placeholder")%>" class="form-control input-mask-cnpj" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" />
	
						</div>
						<%
					case 10'Datepicker
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<div class="input-group">
						<input class="form-control date-picker" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" placeholder="<%=pfields("Placeholder")%>" type="text" data-date-format="dd/mm/yyyy" />
						<span class="input-group-addon">
						<i class="far fa-calendar bigger-110"></i>
						</span>
						</div>
						</div>
						<%
					case 11'Hora
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<div class="input-group bootstrap-timepicker">
						<input value="<%=fieldValue%>" id="timepicker1" name="<%=pFields("ColumnName")%>" type="text" class="form-control" />
						<span class="input-group-addon">
						<i class="far fa-time bigger-110"></i>
						</span>
						</div>
						</div>
						<%
					case 12'Data e Hora
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pfields("Label")%>
						</label>
						<div id="D<%=pFields("ColumnName")%>" class="input-group">
							<input class="form-control" value="<%=fieldValue%>" name="<%=pFields("ColumnName")%>" placeholder="<%=pfields("Placeholder")%>" id="<%=pFields("ColumnName")%>" data-format="dd/MM/yyyy hh:mm:ss" type="text"></input>
							<span class="add-on input-group-addon">
							<i data-time-icon="far fa-time" data-date-icon="far fa-calendar bigger-110">
							</i>
							</span>
						  </div>
	
						  <script type="text/javascript">
						      $(function() {
						          $('#D<%=pFields("ColumnName")%>').datetimepicker({
						              language: 'pt-BR'
						          });
						      });
							</script>
						</div>
						<%
					case 13'Data Mascarada
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pFields("Label")%>
						</label>
						<div class="input-group">
						<input id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" value="<%=fieldValue%>" placeholder="<%=pfields("Placeholder")%>" class="form-control input-mask-date" type="text">
						<span class="input-group-addon">
						<i class="far fa-calendar bigger-110"></i>
						</span>
						</div>
						</div>
					<%
					case 14'Telefone fixo
					%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pFields("Label")%>
						</label>
						
						<div class="input-group">
						<span class="input-group-addon">
						<i class="far fa-phone"></i>
						</span>
						<input class="form-control input-mask-phone" placeholder="<%=pfields("Placeholder")%>" type="text" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" />
						</div>
						</div>
					 <%
					case 15'Telefone celular
					%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pFields("Label")%>
						</label>
						
						<div class="input-group">
						<span class="input-group-addon">
						<i class="far fa-phone"></i>
						</span>
						
						<input class="form-control input-mask-celphone" type="text" placeholder="<%=pfields("Placeholder")%>" value="<%=fieldValue%>" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" />
						</div>
						</div>
					 <%
					case 16'Cep
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pFields("Label")%>
						</label>
						<div class="input-group">
						<input id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" value="<%=fieldValue%>" placeholder="<%=pfields("Placeholder")%>" class="form-control input-mask-cep" type="text">
						</div>
						</div>
					<%
					case 17'Imagem única
						%>
						<div class="col-md-<%=colSize%>">
						<label for="<%=pFields("ColumnName")%>">
						<%=pFields("Label")%>
						</label>
	
							<input multiple type="file" id="id-input-file-3" />
							<label>
								<input type="checkbox" name="file-format" id="id-file-format" class="ace" checked="checked" />
							</label>
					</div>
	
<%
					case 7777777'18'Múltiplo com termos - antigo
						%>
                        <div class="col-md-<%=colSize%>">
                            <label>
                                <span class="bigger-110"><%=pfields("Label")%></span>
                            </label>
                        <select multiple="" class="width-80 chosen-select tag-input-style" id="<%=pFields("ColumnName")%>" name="<%=pFields("ColumnName")%>" data-placeholder="<%=pfields("Placeholder")%>">
						<%
						set listItems = db.execute(pfields("selectSQL"))
						while not listItems.EOF
						%>
						<option value="|<%=listItems("id")%>|"<%if inStr(fieldValue, "|"&listItems("id")&"|")>0 then%> selected="selected"<%end if%>><%=listItems(""&pFields("selectColumnToShow")&"")%></option>
						<%
						listItems.movenext
						wend
						listItems.close
						set listItems=nothing
						%>
                        </select>
						</div>
<%
					case 21
						valor = fieldValue
						tamanho = colSize
						call quickField("editor", pFields("ColumnName"), pfields("Label"), tamanho, valor, pFields("selectSQL"), "", "")
					case 24
						valor = fieldValue
						tamanho = colSize
						call quickField("empresa", pFields("ColumnName"), pfields("Label"), tamanho, valor, pFields("selectSQL"), "", "")
                    case 27, 18
                        call quickField("multiple", pFields("ColumnName"), pfields("Label"), pFields("size"), fieldValue, pFields("selectSQL"), pFields("selectColumnToShow"), "")
                    case 29
                        call quickField("simpleCheckbox", pFields("ColumnName"), pfields("Label"), colSize, fieldValue, "", "", "")
				end select
			pfields.movenext
			wend
			pfields.close
			set pfields=nothing
			response.Write(endRow)
			%>
			<% if lcase(tableName)="feriados" then %>
				<div class="alert alert-info" role="alert">
					Ao marcar "Recorrente" em um feriado marcado com "Bloqueia na agenda" ele irá bloquear o dia do feriado pelos próximos 5 anos.
				</div>
			<% end if %>
            <script type="text/javascript">
                $(".crumb-active a").html("<%=res("name")%>");
                $(".crumb-icon a span").attr("class", "far fa-<%=dIcone(res("tableName"))%>");
            </script>

            <div class="clearfix form-actions">
            <%
			if aut(lcase(tableName)&"A")=1 then
                %>
                <%=header(req("P"), res("Name"), 0, req("I"), req("Pers"), "Follow")%>
                <%
			end if
			%>
            </div>
            </div>
            </div>
			<%
		end if
	end if
end function
%>