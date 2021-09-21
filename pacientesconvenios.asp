<%
if req("act")<>"" then'ou seja, quando a chamada vem pelo javascript (no caso dos itens, ou do subform sendo chamado pelo ajax)
	abreDivMaster = ""
	fechaDivMaster = ""
	Acao = req("act")
	idNaColuna = req("idc")
	Registro = req("reg")
else
	abreDivMaster = "<div id=""divpacientesconvenios"">"
	fechaDivMaster = "</div>"
	idNaColuna = regprin
end if

if Acao="Del" then
	db_execute("delete from pacientesconvenios where id="&Registro)
end if
if Acao="Add" then
	db_execute("insert into pacientesconvenios (sysActive, sysUser, PacienteID) values (1, "&session("User")&", "&idNaColuna&")")
end if

response.Write(abreDivMaster)
%>
<div class="widget-box transparent">
    <div class="widget-header">
        <h4 class="lighter">Conv&ecirc;nios do Paciente</h4>

        <div class="widget-toolbar no-border">
            <a href="#" onclick="itemPacientesConvenios('pacientesconvenios', 'Add', 0, 'PacienteID', <%=idNaColuna%>, 'frm')" data-action="settings">
                <i class="far fa-plus"></i>
            </a>

            <a href="#" data-action="collapse">
                <i class="far fa-chevron-up"></i>
            </a>
        </div>
    </div>
    <div class="widget-body">
        <div class="widget-main padding-6 no-padding-left no-padding-right">
            <table width="100%" class="table table-striped table-bordered">
                <thead>
                    <tr>
                        <th width="17%">Conv&ecirc;nio</th>
                        <th width="17%">Plano</th>
                        <th width="26%">Matr&iacute;cula / Carteirinha</th>
                        <th width="18%">Validade</th>
                        <th width="21%">Titular</th>
                    	<th width="1%"></th>
                    </tr>
                </thead>
                <tbody>
				<%
				regsSql = "select * from pacientesconvenios where sysActive=1 and PacienteID="&idNaColuna
				'response.Write(regsSql)
                set regs = db.execute(regsSql)
				if regs.EOF then
					db_execute("insert into pacientesconvenios (sysActive, sysUser, PacienteID) values (1, "&session("User")&", "&idNaColuna&")")
					set regs = db.execute(regsSql)
				end if
                while not regs.eof
					if isnull(regs("ConvenioID")) then ConvenioID = 0 else ConvenioID = regs("ConvenioID") end if
					if isnull(regs("PlanoID")) then PlanoID = 0 else PlanoID = regs("PlanoID") end if
                    %>
                    <tr>
                        <td>
                            <%=selectInsert("", "ConvenioID-PacientesConvenios-"&regs("id"), ConvenioID, "convenios", "NomeConvenio", "", "", "")%>
                        </td>
                        <td>
                        	<%=selectInsert("", "PlanoID-PacientesConvenios-"&regs("id"), PlanoID, "conveniosplanos", "NomePlano", "", "", "ConvenioID-PacientesConvenios-"&regs("id"))%>
                        </td>
                        <td><%=quickField("text", "Matricula-PacientesConvenios-"&regs("id"), "", 12, regs("Matricula"), "", "", "")%></td>
                        <td><%=quickField("datepicker", "Validade-PacientesConvenios-"&regs("id"), "", 12, regs("Validade"), "", "", "")%></td>
                        <td><%=quickField("text", "Titular-PacientesConvenios-"&regs("id"), "", 12, regs("Titular"), "", "", "")%></td>
                        <td><button type="button" class="btn btn-sm btn-danger remove-item-subform" onclick="itemPacientesConvenios('pacientesconvenios', 'Del', <%=regs("id")%>, '', <%=idNaColuna%>, '<%=NomeForm%>')"><i class="far fa-trash"></i></button></td>
                    </tr>
                    <%
                regs.movenext
                wend
                regs.close
                set regs=nothing
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<%
response.Write(fechaDivMaster)
%>