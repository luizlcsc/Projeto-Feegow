<%
if req("act")<>"" then'ou seja, quando a chamada vem pelo javascript (no caso dos itens, ou do subform sendo chamado pelo ajax)
	abreDivMaster = ""
	fechaDivMaster = ""
	NomeTabela = req("tbn")
	Coluna = req("cln")
	idNaColuna = req("idc")
	Acao = req("act")
	Registro = req("reg")
	NomeForm = req("frm")
else
	abreDivMaster = "<div id=""div"&NomeTabela&""">"
	fechaDivMaster = "</div>"
	idNaColuna = regPrin
	NomeForm = FormID
end if


set getResource = db.execute("select * from cliniccentral.sys_resources where TableName='"&NomeTabela&"'")

if Acao="Del" then
	db_execute("delete from "&NomeTabela&" where id="&Registro)
end if
if Acao="Add" then
	db_execute("insert into "&NomeTabela&" (sysActive, sysUser, "&Coluna&") values (1, "&session("User")&", "&idNaColuna&")")
end if

MostarBotaoApagar=1

if aut(lcase(NomeTabela)&"V")=1 and aut(lcase(NomeTabela)&"X")=0 then
    MostarBotaoApagar=0
end if

MostarBotaoInserir=1

if aut(lcase(NomeTabela)&"V")=1 and aut(lcase(NomeTabela)&"I")=0 then
    MostarBotaoInserir=0
end if

response.Write(abreDivMaster)
%>
<div class="panel" id="p<%=NomeTabela %>">
    <div class="panel-heading">
        <span class="panel-title"><%= getResource("name") %> </span>
        <span class="panel-controls">
            <a class="panel-control-collapse hidden" href="#"></a>
            <%
            if MostarBotaoInserir=1 then
            %>
            <a class="panel-control" onclick="itemSubform('<%=NomeTabela%>', 'Add', 0, '<%=Coluna%>', <%=idNaColuna%>, '<%=NomeForm%>')" href="javascript:void(0)"><i class="far fa-plus"></i></a>
            <%
            end if
            %>
        </span>
    </div>
    <div class="panel-body pn" <% if device()<>"" then %> style="overflow-x:scroll!important" <% end if %> >
            <table width="100%" class="table table-condensed">
                <thead>
                    <tr>
                    <%
					set countfields = db.execute("select count(*) as total from cliniccentral.sys_resourcesFields where resourceID="&getResource("id")&" and not ColumnName='"&Coluna&"'")
					percentual = cint( 100/ccur(countfields("total")) )
					set getFields = db.execute("select rf.*, rft.typeName from cliniccentral.sys_resourcesFields rf LEFT JOIN cliniccentral.sys_resourcesFieldTypes rft on rf.fieldTypeID=rft.id where resourceID="&getResource("id")&" and not ColumnName='"&Coluna&"' order by id")

					qtdCol = 0
					while not getFields.EOF

						strCampos = strCampos&getFields("columnName")&"|"
						strTipos = strTipos&getFields("typeName")&"|"
						strSelectSQL = strSelectSQL&getFields("selectSQL")&"|"
						strSelectColumnToShow = strSelectColumnToShow&getFields("selectColumnToShow")&"|"
						strRCH = strRCH&getFields("responsibleColumnHidden")&"|"
						%>
                        <th width="<%=percentual%>%"><%=getFields("label")%></th>
						<%
						qtdCol = qtdCol + 1
                    getFields.movenext
                    wend
                    getFields.close
                    set getFields=nothing

                    if session("Unidades")<>"|0|" and NomeTabela="contratosconvenio" then
                        %>
                        <th nowrap>Permitir somente nas unidades abaixo</th>
                        <%
                    end if
                    %>
                    	<th width="1%"></th>




                    <%
                    '----> ADICIONANDO LINK DO PACIENTE CASO SEJA RELACIONADO
                    if getResource("id")=19 then
                    %>
                    <th width="1%"></th>
                    <%
                    end if
                    '<----
                    %>




                    </tr>
                </thead>
                <tbody>
				<%

                splCampos = split(strCampos, "|")
                splTipos = split(strTipos, "|")
                splSelectSQL = split(strSelectSQL, "|")
                splSelectColumnToShow = split(strSelectColumnToShow, "|")
                splRCH = split(strRCH, "|")

				regsSql = "select * from "&NomeTabela&" where sysActive=1 and "&Coluna&"="&idNaColuna
				'response.Write(regsSql)
                set regs = db.execute(regsSql)
				if regs.EOF then
				    'desabilita auto insert
				    if False then
					    db_execute("insert into "&NomeTabela&" (sysActive, sysUser, "&Coluna&") values (1, "&session("User")&", "&idNaColuna&")")
					    set regs = db.execute(regsSql)
                    end if
					%>
					<tr>
					    <td colspan="<%=qtdCol%>" class="text-center">Clique no <i>"+"</i> para adicionar. </td>
                    </tr>
					<%
				end if
                while not regs.eof
                    counter = counter + 1
                    %>
                    <tr>
                        <%
                        Active = regs("sysActive")
                        for i=0 to ubound(splCampos)
							if splCampos(i)<>"" then
								if Acao="" then
									Valor = regs(""&splCampos(i)&"")
								else
									Valor = ref(splCampos(i)&"-"& getResource("tableName") &"-"&regs("id"))
								end if
								%>
								<td>
									<%
                                    if splTipos(i)="selectInsert" then
                                        response.Write (selectInsert("", splCampos(i) &"-"& getResource("tableName") &"-"&regs("id"), Valor, splSelectSQL(i), splSelectColumnToShow(i), splRCH(i), " onclick='alert(1)' ", ""))
                                    elseif splTipos(i)="selectList" then

                                        response.Write (selectList("", splCampos(i) &"-"& getResource("tableName") &"-"&regs("id"), Valor, splSelectSQL(i), splSelectColumnToShow(i), "", "", ""))
                                        %>
                                        <input type="hidden" name="<%=splCampos(i) &"-"& getResource("tableName") &"-"& regs("id") & "-ID"%>" id="<%=splCampos(i) &"-"& getResource("tableName") &"-"& regs("id") & "-ID"%>" value="<%=regs( splCampos(i) &"ID")%>" />
                                        <%
                                    else
                                         'pacotes bugados

                                        if (NomeTabela="pacotesitens" or NomeTabela="estoque_requisicao_produtos") and Active=1 and splTipos(i)="simpleSelect" and Valor<>"" and not isnull(Valor) and Valor<>"0" then

                                            queryId = replace(splSelectSQL(i),"order", "AND id='"&Valor&"' order")
                                            set NomeProcedimentoSQL = db.execute(queryId)
                                            if not NomeProcedimentoSQL.eof then
                                                response.write(NomeProcedimentoSQL(splSelectColumnToShow(i)))
                                            end if
                                            response.write("<input name='"&splCampos(i)&"-"& getResource("tableName") &"-"&regs("id")&"' type='hidden' value='"&Valor&"'/>")
                                        else
                                            call quickField(splTipos(i), splCampos(i)&"-"& getResource("tableName") &"-"&regs("id"), "", 12, Valor, splSelectSQL(i)&"", splSelectColumnToShow(i), "")
                                        end if
                                    end if
                                    %>
								</td>
								<%
							else
                                if session("Unidades")<>"|0|" and NomeTabela="contratosconvenio" then
                                    %>
                                    <td width="30%"><div class="row"> <%=quickfield("empresaMultiIgnore", "SomenteUnidades-"&regs("id"), " ", 12, regs("SomenteUnidades"), "", "", "") %></div></td>
                                    <%
                                end if
								%>
								<td>
								    <%
								    if MostarBotaoApagar=1 then
                                        %>
                                        <button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="itemSubform('<%=NomeTabela%>', 'Del', <%=regs("id")%>, '<%=Coluna%>', <%=idNaColuna%>, '<%=NomeForm%>')"><i class="far fa-trash"></i></button>
                                        <%
								    end if
								    %>
                                </td>
								<%
								'----> ADICIONANDO LINK DO PACIENTE CASO SEJA RELACIONADO
                                if getResource("id")=19 then
                                    %>
                                    <td>
                                    <%
                                    if regs("NomeID")&""<>"" then
                                    %>
                                        <a  href="javascript:modalPaciente(<%=regs("NomeID")%>)">
                                            <button type="button" class="btn btn-sm btn-info"><i class="far fa-expand" title="<%=regs("Nome")%>"></i>  Paciente</button>
                                        </a>
                                    <%
                                    else
                                    %>
                                        <a  href="javascript:modalPacienteRelativo(<%=regs("id")%>, '<%=regs("Nome")%>')">
                                            <button type="button" class="btn btn-sm btn-default"><i class="far fa-expand" title="<%=regs("Nome")%>"></i></button>
                                        </a>
                                    <%
                                    end if
                                    %>
                                    </td>
                                    <%
                                end if
                                '<----
							end if
                        next
                        %>
                    </tr>
                    <%
                if counter mod 10 = 0 then
                    Response.Flush
                End If
                regs.movenext
                wend
                regs.close
                set regs=nothing
                %>
                </tbody>
            </table>
    </div>
</div>
<%
response.Write(fechaDivMaster)
%>