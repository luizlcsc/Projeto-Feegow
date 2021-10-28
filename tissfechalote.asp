<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<!--#include file="Classes\JSON.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Fechar Lote");
    $(".crumb-icon a span").attr("class", "far fa-archive");
</script>
<%
Unidades = req("CompanyUnitID")
Planos = req("Planos")
Contratados = replace(req("Contratados"),"''","'")
Procedimentos =  req("Procedimentos")
Executantes =  req("Executantes")
Pais =  req("PaisID")
Estado =  req("EstadoID")
Cidade =  req("CidadeID")

if Unidades="" then
	Unidades = session("Unidades")
end if
%>
<form action="" id="fechalote" method="get">
	<input type="hidden" name="P" value="tissfechalote" />
    <input type="hidden" name="Pers" value="1" />
    <br>
    <div class="panel">

    <div class="clearfix form-actions panel-body">
    	<div class="row">
            <div class="col-md-2">
                <label>Tipo de Guia</label><br />
                <select name="T" id="T" class="form-control" required onchange="return onChangeGuiaTipo();">
                    <option value="">Selecione</option>
                    <option value="GuiaConsulta"<%if req("T")="GuiaConsulta" then%> selected="selected"<%end if%>>Guia de Consulta</option>
                    <option value="GuiaSADT"<%if req("T")="GuiaSADT" then%> selected="selected"<%end if%>>Guia de SP/SADT</option>
                    <option value="GuiaHonorarios"<%if req("T")="GuiaHonorarios" then%> selected="selected"<%end if%>>Guia de Honorários</option>
                </select>
            </div>
            <%= quickField("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 3, req("ConvenioID"), "select * from Convenios where Ativo='on' and sysActive=1 order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
            <%= quickField("datepicker", "DataDe", "Data do Preenchimento", 2, req("DataDe"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAte", "&nbsp;", 2, req("DataAte"), "", "", " placeholder='At&eacute;'") %>
            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button class="btn btn-md btn-primary"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
        <br>
        <div class="row">
            <div class="col-md-2">
                <label>Ordenar por</label><br />
                <select name="OrdenarPor" id="OrdenarPor" class="form-control" required>
                    <option value="0">Data do preenchimento</option>
                    <option value="1" <%if req("OrdenarPor")="1" then%> selected="selected"<%end if%>>Nome do paciente</option>
                    <option value="2" <%if req("OrdenarPor")="2" then%> selected="selected"<%end if%>>Código na operadora</option>
                    <option value="3" <%if req("OrdenarPor")="3" then%> selected="selected"<%end if%>>Data da solicitação</option>
                </select>
            </div>
            <div class="col-md-3">
                <label>Exibir nome do profissional</label><br />
                <select name="ExibirProfissional" id="ExibirProfissional" class="form-control" required>
                    <option value="0">Não exibir</option>
                    <option value="1" <%if req("ExibirProfissional")="1" then%> selected="selected"<%end if%>>Profissional executante</option>
                </select>
            </div>
            <%= quickField("datepicker", "DataDeAtendimento", "Data do Atendimento", 2, req("DataDeAtendimento"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAteAtendimento", "&nbsp;", 2, req("DataAteAtendimento"), "", "", " placeholder='At&eacute;'") %>
            <%=quickField("empresaMultiIgnore", "CompanyUnitID", "Unidades", 3, Unidades, "", "", "")%>

        </div>
        <br>
        <div class="row">
            <%= quickField("simpleSelect", "GuiaStatus", "Status", 2, req("GuiaStatus"), "SELECT * FROM cliniccentral.tissguiastatus ORDER BY Status", "Status", " empty") %>
            <%=quickfield("simpleSelect", "Procedimentos", "Procedimentos", 3, Procedimentos, "select id, NomeProcedimento from procedimentos where sysActive=1 and Ativo='on' order by NomeProcedimento", "NomeProcedimento", " empty")%>

            <div class="col-md-2" id="tag-planos" >
                <label>Planos</label><br />
                <select id="Planos" name="Planos" class="form-control">
                    <option value="">Selecione o Convênio</option>
                </select>
            </div>
            <div class="col-md-2" id="tag-contratados" >
                <label>Contratados</label><br />
                <select id="Contratados" name="Contratados" class="form-control">
                    <option value="">Selecione o Convênio</option>
                </select>
            </div>
            <%=quickfield("simpleSelect", "Executantes", "Executantes", 3, Executantes, "select id, NomeProfissional from profissionais where sysActive=1 and Ativo='on' order by NomeProfissional", "NomeProfissional", " empty")%>
        </div>
        <br>
        <div class="row" style="display: flex; align-items: flex-end;">
            <div class="col-md-2">
                <label>País</label><br />
                <select id="PaisID" name="PaisID" onchange="$('#EstadoID').val(0).change();" style="
                        background-color: #fff;
                        border: 1px solid rgba(0, 0, 0, 0.1);
                        border-radius: 4px;
                        height: 38px;
                        width: -webkit-fill-available;">
                    <option selected value="">Todos</option>
                    <option value="1">Brasil</option>
                    <option value="0">Outros</option>
                </select>
                <script>
                    $(document).ready(() => {
                        const paisId = '<%=Pais%>';
                        $('#PaisID').val(paisId).change();
                    })
                </script>
            </div>
            <div class="col-md-2">
                <label>Estado</label><br/>
                <select id="EstadoID" name="EstadoID" onchange="$('#CidadeID').val(0).change(); setCitiesSelect();" style="
                        background-color: #fff;
                        border: 1px solid rgba(0, 0, 0, 0.1);
                        border-radius: 4px;
                        height: 38px;
                        width: -webkit-fill-available;">
                    <option selected value="">Todos</option>
                    <option value="1" >AC</option>
                    <option value="2" >AL</option>
                    <option value="3" >AM</option>
                    <option value="4" >AP</option>
                    <option value="5" >BA</option>
                    <option value="6" >CE</option>
                    <option value="7" >DF</option>
                    <option value="8" >ES</option>
                    <option value="9" >GO</option>
                    <option value="10" >MA</option>
                    <option value="11" >MG</option>
                    <option value="12" >MS</option>
                    <option value="13" >MT</option>
                    <option value="14" >PA</option>
                    <option value="15" >PB</option>
                    <option value="16" >PE</option>
                    <option value="17" >PI</option>
                    <option value="18" >PR</option>
                    <option value="19" >RJ</option>
                    <option value="20" >RN</option>
                    <option value="21" >RO</option>
                    <option value="22" >RR</option>
                    <option value="23" >RS</option>
                    <option value="24" >SC</option>
                    <option value="25" >SE</option>
                    <option value="26" >SP</option>
                    <option value="27" >TO</option>
                </select>
                <script>
                    $(document).ready(() => {
                        const estadoId = '<%=Estado%>';
                        $('#EstadoID').val(estadoId).change();
                    })
                </script>
            </div>
            <div class="col-md-2">
                <label>Cidade</label><br/>
                <select id="CidadeID" name="CidadeID" style="
                        background-color: #fff;
                        border: 1px solid rgba(0, 0, 0, 0.1);
                        border-radius: 4px;
                        height: 38px;
                        width: -webkit-fill-available;">
                    <option selected value="">Todas</option>
                </select>
                <script>
                    $(document).ready(() => {
                        const cidadeId = '<%=Cidade%>';
                        setTimeout(() => $('#CidadeID').val(cidadeId).change(), 1000);
                    })
                </script>
            </div>
            <div class="col-md-3">
                <!-- empty for spacing -->
            </div>
            <div class="col-md-3" style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <strong>Guias encontradas:</strong> <span id="encontradas">0</span><br>
                    <strong>Guias selecionadas:</strong> <span id="selecionadas">0</span>
                </div>
                <button type="button" class="btn btn-md btn-success" onClick="fechalote()"><i class="fa fa-archive"></i> Fechar Lote</button>
            </div>
        </div>

    </div>
    </div>
</form>

<div class="panel">
<div class="panel-heading">
    <span class="panel-title">
        Guias encontradas
    </span>
    <span class="panel-controls">
        <button type="button" class="btn btn-md btn-success" onClick="fechalote()"><i class="far fa-archive"></i> Fechar Lote</button>
    </span>
</div>
<div class="panel-body">
<form action="" method="post" id="guias" name="guias">
<%
response.buffer
c=0
ordenarPor = req("OrdenarPor")
orderBy = ""

if ordenarPor = "1" then
    orderBy = " ORDER BY p.NomePaciente"
end if

if ordenarPor = "2" then
    orderBy = " ORDER BY g.CodigoNaOperadora"
end if

if ordenarPor = "3" then
    if req("T")="GuiaSADT" then
        orderBy  = " ORDER BY g.DataSolicitacao"
    elseif req("T")="GuiaHonorarios" then
        orderBy = " ORDER BY g.DataEmissao"
    elseif req("T")="GuiaConsulta" then
        orderBy = " ORDER BY g.DataAtendimento"
    end if
end if

if req("ConvenioID")<>"" and req("T")="GuiaConsulta" then
	%>
    <table width="100%" class="table table-striped table-bordered">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if req("ExibirProfissional") = "1" then
                %>
                <th nowrap>Profissional</th>
                <%
            end if
            %>
            <th nowrap>Nº da Guia<br/> Operadora</th>
            <th nowrap>Nº da Guia<br/> Prestador</th>
            <th nowrap>Cód. na Operadora</th>
            <th nowrap>Procedimento</th>
            <th nowrap>Paciente</th>
            <th nowrap>N&deg; da Carteira</th>
            <th nowrap>Valor da Guia</th>
            <th nowrap>Usuário</th>
            <th nowrap>Observações</th>
        </tr>
    </thead>
    <tbody>
	<%
	sqlLote = " and LoteID=0"


	if req("DataDe")<>"" and isdate(req("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(req("DataDe"))&"'"
	end if
	if req("DataAte")<>"" and isdate(req("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(req("DataAte"))&"'"
	end if

	if req("DataDeAtendimento")<>"" and isdate(req("DataDeAtendimento")) then
        sqlDataDeAtendimento = " and date(g.DataAtendimento)>='"&mydate(req("DataDeAtendimento"))&"'"
    end if
    if req("DataAteAtendimento")<>"" and isdate(req("DataAteAtendimento")) then
        sqlDataAteAtendimento = " and date(g.DataAtendimento)<='"&mydate(req("DataAteAtendimento"))&"'"
    end if

    if req("GuiaStatus")<>"" and req("GuiaStatus")<>"0" then
        sqlStatusGuia = " and g.GuiaStatus="&req("GuiaStatus")
    end if

	if Unidades<>"" then
        sqlUnidades = " and g.UnidadeID IN ("& replace(Unidades, "|", "") &") "
    end if

    if Planos<>"" then
        sqlPlanos = " and g.PlanoID IN ("&Planos&") "
    end if

    if Procedimentos<>"" then
        sqlProcedimentos = " and g.ProcedimentoID IN ("&Procedimentos&") "
    end if

    if Contratados<>"" then
        sqlContratados = " and g.CodigoNaOperadora IN ("&Contratados&") "
    end if
    if Executantes<>"" then
        sqlExecutantes = " and g.ProfissionalID IN ("&Executantes&") "
    end if

    if Pais<>"" then
        if Pais = 1 then
            sqlPais = " and p.PaisID = 1"
        else
            sqlPais = " and p.PaisID <> 1"
        end if
    end if

    if Estado<>"" then
        sqlEstado = " and p.EstadoID = "&Estado
    end if

    if Cidade<>"" then
        sqlCidade = " and p.CidadeID = "&Cidade
    end if

    sqlGuia = "select g.*, proc.NomeProcedimento from tissguiaconsulta g LEFT JOIN pacientes p ON p.id = g.PacienteID LEFT JOIN procedimentos proc ON proc.id = g.ProcedimentoID where g.sysActive=1"&sqlLote&sqlContratados&sqlPlanos&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlProcedimentos&sqlExecutantes&sqlPais&sqlEstado&sqlCidade&" and g.ConvenioID="&req("ConvenioID")&sqlUnidades &sqlStatusGuia &orderBy

	set guias = db.execute(sqlGuia)
	while not guias.EOF
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if
		set prof = db.execute("select NomeProfissional from profissionais where id="&guias("ProfissionalID"))
		if prof.eof then
			NomeProfissional = ""
		else
			NomeProfissional = prof("NomeProfissional")
		end if
		c=c+1

        if c<=100 then
            marcavel = " marcavel "
        else
            marcavel = ""
        end if
		%>
		<tr>
        	<td><label><input type="checkbox" class="ace guia <%=marcavel %>" name="guia" value="<%=guias("id")%>"><span class="lbl"></span></label></td>
        	<td><%=left(guias("sysDate"),10)%></td>
        	<%
                if req("ExibirProfissional") = "1" then
                    %>
                        <td><%=NomeProfissional%></td>
                    <%
                end if
            %>
            <td><a href="./?P=tissguiaconsulta&I=<%=guias("id")%>&Pers=1" target="_blank"><%= guias("NGuiaPrestador") %></a></td>
            <td><%= guias("NGuiaOperadora") %></td>
            <td><%= guias("CodigoNaOperadora") %></td>
            <td><%= guias("NomeProcedimento") %></td>
	        <td><%=NomePaciente%></td>
            <td><%=guias("NumeroCarteira")%></td>
            <td class="text-right">R$ <%=formatnumber(guias("ValorProcedimento"),2)%></td>
            <td><%=nameInTable(guias("SysUser"))%></td>
            <td><%=guias("Observacoes")%></td>
        </tr>
		<%
		response.Flush()
	guias.movenext
	wend
	guias.close
	set guias=nothing
	%>
    </tbody>
    </table><%
elseif req("ConvenioID")<>"" and req("T")="GuiaHonorarios" then
	%>
    <table width="100%" class="table table-striped">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if req("ExibirProfissional") = "1" then
                %>
                <th nowrap>Profissional</th>
                <%
            end if
            %>
            <th nowrap>Nº da Guia<br/> Operadora</th>
            <th nowrap>Nº da Guia<br/> Prestador</th>
            <th nowrap>Cód. na Operadora</th>
            <th nowrap>Procedimentos</th>
            <th nowrap>Paciente</th>
            <th nowrap>N&deg; da Carteira</th>
            <th nowrap>Valor da Guia</th>
            <th nowrap>Senha</th>
            <th nowrap>Usuário</th>
            <th nowrap>Observações</th>
        </tr>
    </thead>
    <tbody>
	<%
	sqlLote = " and LoteID=0"
	if req("DataDe")<>"" and isdate(req("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(req("DataDe"))&"'"
	end if
	if req("DataAte")<>"" and isdate(req("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(req("DataAte"))&"'"
	end if

    if req("GuiaStatus")<>"" and req("GuiaStatus")<>"0" then
        sqlStatusGuia = " and g.GuiaStatus="&req("GuiaStatus")
    end if

	if req("DataDeAtendimento")<>"" and isdate(req("DataDeAtendimento")) then
		sqlDataDeAtendimento = " and date(g.DataEmissao)>='"&mydate(req("DataDeAtendimento"))&"'"
	end if
	if req("DataAteAtendimento")<>"" and isdate(req("DataAteAtendimento")) then
		sqlDataAteAtendimento = " and date(g.DataEmissao)<='"&mydate(req("DataAteAtendimento"))&"'"
	end if


	if Unidades<>"" then
        sqlUnidades = " and g.UnidadeID IN ("& replace(Unidades, "|", "") &") "
    end if

    if Planos<>"" then
        sqlPlanos = " and g.PlanoID IN ("&Planos&") "
    end if

    if Procedimentos<>"" then
        sqlProcedimentos = " and tph.ProcedimentoID IN ("&Procedimentos&") "
    end if

    if Contratados<>"" then
        sqlContratados = " and g.CodigoNaOperadora IN ("&Contratados&") "
    end if

    if Executantes<>"" then
        sqlExecutantes = " and tph.ProfissionalID IN ("&Executantes&") "
    end if

    sqlGuias = "select g.*, GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') NomeProcedimentos  from tissguiahonorarios g LEFT JOIN tissprocedimentoshonorarios tph ON tph.GuiaID=g.id LEFT JOIN procedimentos proc ON proc.id=tph.ProcedimentoID where g.sysActive=1"&sqlContratados&sqlPlanos&sqlLote&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlProcedimentos&" and g.ConvenioID="&req("ConvenioID")&sqlUnidades &sqlStatusGuia &sqlExecutantes& "GROUP BY g.id "&orderBy

	set guias = db.execute(sqlGuias)
	while not guias.EOF
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if


		'--> INICIO - Pegar o profissional executor da guia
        		if req("ExibirProfissional") = "1" then
                    set proguia = db.execute("SELECT group_concat(profissionalid) profissionais FROM tissprofissionaissadt WHERE guiaID="&guias("id"))
                    if proguia.EOF then
                        NomeProfissional = ""
                    elseif not isnull(proguia("profissionais")) or proguia("profissionais")<>"" then
                        profissionais = proguia("profissionais")
                        set prof = db.execute("SELECT group_concat(NomeProfissional) NomeProfissional FROM profissionais WHERE id IN ("&profissionais&")  ")
                        if prof.eof then
                        	NomeProfissional = ""
                        elseif not isnull(prof("NomeProfissional")) or prof("NomeProfissional")<>"" then
                        	NomeProfissional = prof("NomeProfissional")
                        else
                            NomeProfissional = ""
                        end if
                    else
                        NomeProfissional = ""
                    end if
        		end if
                '--> FIM - Pegar o profissional executor da guia



		c=c+1

        if c<=100 then
            marcavel = " marcavel "
        else
            marcavel = ""
        end if
		%>
		<tr>
        	<td><label><input type="checkbox" class="ace guia <%=marcavel %>" name="guia" value="<%=guias("id")%>"><span class="lbl"></span></label></td>
        	<td><%=left(guias("sysDate"),10)%></td>
        	<%
            if req("ExibirProfissional") = "1" then
                %>
                    <td><%=NomeProfissional%></td>
                <%
            end if
            %>
            <td><a href="./?P=tissguiahonorarios&I=<%=guias("id")%>&Pers=1" target="_blank"><%= guias("NGuiaOperadora") %></a></td>
            <td><a href="./?P=tissguiahonorarios&I=<%=guias("id")%>&Pers=1" target="_blank"><%= guias("NGuiaPrestador") %></a></td>
            <td><%= guias("CodigoNaOperadora") %></td>
            <td><%=guias("NomeProcedimentos") %></td>
	        <td><%=NomePaciente%></td>
            <td><%=guias("NumeroCarteira")%></td>
            <td class="text-right">R$ <%=formatnumber(guias("Procedimentos"),2)%></td>
            <td><%=guias("Senha")%></td>
            <td><%=nameInTable(guias("SysUser"))%></td>
            <td><%=guias("Observacoes")%></td>
        </tr>
		<%
		response.Flush()
	guias.movenext
	wend
	guias.close
	set guias=nothing
	%>
    </tbody>
    </table><%
elseif req("ConvenioID")<>"" and req("T")="GuiaSADT" then
	%>
    <table width="100%" class="table table-striped table-bordered">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if req("ExibirProfissional") = "1" then
                %>
                <th nowrap>Profissional</th>
                <%
            end if
            %>
            <th nowrap>Nº da Guia<br/> Operadora</th>
            <th nowrap>Nº da Guia<br/> Prestador</th>
            <th nowrap>Cód. na Operadora</th>
            <th nowrap>Procedimentos</th>
            <th nowrap>Paciente</th>
            <th nowrap>N&deg; da Carteira</th>
            <th nowrap>Valor da Guia</th>
            <th nowrap>Senha</th>
            <th nowrap>Usuário</th>
            <th nowrap>Observação</th>
        </tr>
    </thead>
    <tbody>
	<%
	sqlLote = " and LoteID=0"
	if req("DataDe")<>"" and isdate(req("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(req("DataDe"))&"'"
	end if
	if req("DataAte")<>"" and isdate(req("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(req("DataAte"))&"'"
	end if

	if req("GuiaStatus")<>"" and req("GuiaStatus")<>"0" then
        sqlStatusGuia = " and g.GuiaStatus="&req("GuiaStatus")
    end if

	if req("DataDeAtendimento")<>"" and isdate(req("DataDeAtendimento")) then
		sqlDataDeAtendimento = " and date(g.DataSolicitacao)>='"&mydate(req("DataDeAtendimento"))&"'"
	end if
	if req("DataAteAtendimento")<>"" and isdate(req("DataAteAtendimento")) then
		sqlDataAteAtendimento = " and date(g.DataSolicitacao)<='"&mydate(req("DataAteAtendimento"))&"'"
	end if

    if Procedimentos<>"" then
        sqlProcedimentos = " and tps.ProcedimentoID IN ("&Procedimentos&") "
    end if


	if Unidades<>"" then
        sqlUnidades = " and g.UnidadeID IN ("& replace(Unidades, "|", "") &") "
    end if

    if Planos<>"" then
        sqlPlanos = " and g.PlanoID IN ("&Planos&") "
    end if

    if Contratados<>"" then
        sqlContratados = " and g.CodigoNaOperadora IN ("&Contratados&") "
    end if

    if Executantes<>"" then
        sqlExecutantes = " and tps.ProfissionalID IN ("&Executantes&") "
    end if

    if Pais<>"" then
        if Pais = 1 then
            sqlPais = " and p.PaisID = 1"
        else
            sqlPais = " and p.PaisID <> 1"
        end if
    end if

    if Estado<>"" then
        sqlEstado = " and p.EstadoID = "&Estado
    end if

    if Cidade<>"" then
        sqlCidade = " and p.CidadeID = "&Cidade
    end if

    sqlGuias = "select g.*, GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') Procedimentos from tissguiasadt g LEFT JOIN pacientes p ON p.id = g.PacienteID LEFT JOIN tissprocedimentossadt tps ON tps.GuiaID=g.id LEFT JOIN procedimentos proc ON proc.id=tps.ProcedimentoID where g.sysActive=1"&sqlContratados&sqlLote&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlPlanos&sqlProcedimentos&" and g.ConvenioID="&req("ConvenioID")&sqlUnidades &sqlStatusGuia &sqlExecutantes&sqlPais&sqlEstado&sqlCidade&" GROUP BY g.id "& orderBy

    %><script>console.log('<%=sqlGuias%>')</script><%

	set guias = db.execute(sqlGuias)

	while not guias.EOF
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if

        '--> INICIO - Pegar o profissional executor da guia
		if req("ExibirProfissional") = "1" then
            set proguia = db.execute("SELECT group_concat(profissionalid) profissionais FROM tissprofissionaissadt WHERE guiaID="&guias("id")&" limit 1")
            profissionais = proguia("profissionais")
            if not isnull(profissionais) or profissionais<>"" then
                set prof = db.execute("SELECT group_concat(NomeProfissional) NomeProfissional FROM profissionais WHERE id IN ("&profissionais&")")
                NomeProfissional = prof("NomeProfissional")
            end if
		end if
        '--> FIM - Pegar o profissional executor da guia


		c=c+1
        if c<=100 then
            marcavel = " marcavel "
        else
            marcavel = ""
        end if
		%>
		<tr>
        	<td><label><input type="checkbox" class="ace guia <%=marcavel %>" name="guia" value="<%=guias("id")%>"><span class="lbl"></span></label></td>
        	<td><%=left(guias("sysDate"),10)%></td>
        	<%
        	if req("ExibirProfissional") = "1" then
                %>
                    <td><%=NomeProfissional%></td>
                <%
            end if
            %>
            <td><a href="./?P=tissguiasadt&I=<%=guias("id")%>&Pers=1" target="_blank"><%= guias("NGuiaPrestador") %></a></td>
            <td><a href="./?P=tissguiasadt&I=<%=guias("id")%>&Pers=1" target="_blank"><%= guias("NGuiaOperadora") %></a></td>
            <td><%=guias("CodigoNaOperadora") %></td>
            <td><%=guias("Procedimentos") %></td>
	        <td><%=NomePaciente%></td>
            <td><%=guias("NumeroCarteira")%></td>
            <td class="text-right">R$ <%=fn(guias("TotalGeral"))%></td>
            <td><%=guias("senha")%></td>
            <td><%=nameInTable(guias("SysUser"))%></td>
            <td><%=guias("Observacoes")%></td>
        </tr>
		<%
		response.Flush()
	guias.movenext
	wend
	guias.close
	set guias=nothing
	%>
    </tbody>
    </table><%
end if
%>
</form>
</div>
</div>

<script type="text/javascript">
$("#encontradas").html('<%=c%>');

$("#T, #ConvenioID").change(function(){
	$.ajax({
		type:"GET",
		url:"tissselectlote.asp?T="+$("#T").val()+"&ConvenioID="+$("#ConvenioID").val(),
		success:function(data){
			$("#selectLote").html(data);
		}
	});
});

$("#marca").click(function(){
	var marcado = $(this).prop("checked");
	$(".marcavel").prop("checked", marcado);
});

function fechalote(){
    var G = $("#frmModal, #guias").serialize()
	var checados = $("input.guia:checked").length;
	if(checados==0){
		$.gritter.add({
			title: '<i class="far fa-thumbs-down"></i> ERRO:',
			text: 'Selecione as guias para fechar o lote.',
			class_name: 'gritter-error gritter-light'
		});
	}else{
		$.ajax({
			type:"POST",
			url:"modalFechaLote.asp?T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&"+G,
			success: function(data){
				$("#modal-table").modal("show");
				$("#modal").html(data);
			}
		});
	}
}

$(".guia, #marca").click(function(){
	$("#selecionadas").html( $("input.guia:checked").length );
});

$(".guia").click(function(){
    if($(this).prop("checked")==true){
        var qtd = $(".guia:checked").size();
        if(qtd>100){
            alert('Você não pode selecionar mais de 100 guias para fechar um lote.\n Por favor, desmarque outras guias para poder selecionar esta.')
            $(this).prop("checked", false);
        }
    }
});
$(document).ready(function() {
  // setTimeout(function() {
  //   $("#toggle_sidemenu_l").click()
  // }, 500);

    changeConvenio("<%=req("ConvenioID")%>")
    changeContratos("<%=req("ConvenioID")%>")

    $("#ConvenioID").on('change',function (){
        changeConvenio(this.value);
        changeContratos(this.value);

    })
});

var planos = <%=recordToJSON(db.execute("SELECT * FROM conveniosplanos WHERE sysActive = 1 and NomePlano!=''"))%>;

<% sqlContratado = " SELECT CONCAT(contratosconvenio.id,'') AS idContatado,CONCAT(CodigoNaOperadora,' - ',NomeContratado) as NomeContratado,contratosconvenio.* FROM (                "&chr(13)&_
                   " select 0 as id,NomeFantasia as NomeContratado from empresa                                      "&chr(13)&_
                   " UNION ALL                                                                                      "&chr(13)&_
                   " select id*-1,NomeFantasia from sys_financialcompanyunits where not isnull(UnitName) and sysActive=1"&chr(13)&_
                   " UNION ALL                                                                                      "&chr(13)&_
                   " select id, NomeProfissional from profissionais where sysActive=1) t                            "&chr(13)&_
                   " JOIN contratosconvenio ON contratosconvenio.Contratado = t.id                                  "&chr(13)&_
                   " "%>

<% sqlContratado = " SELECT DISTINCT CodigoNaOperadora FROM (                                                                  "&chr(13)&_
                   " select distinct g.CodigoNaOperadora from tissguiahonorarios g WHERE g.CodigoNaOperadora <> ''             "&chr(13)&_
                   " UNION ALL                                                                                                 "&chr(13)&_
                   " select distinct g.CodigoNaOperadora from tissguiaconsulta g   WHERE g.CodigoNaOperadora <> ''             "&chr(13)&_
                   " UNION ALL                                                                                                 "&chr(13)&_
                   " select distinct g.CodigoNaOperadora from tissguiasadt g   WHERE g.CodigoNaOperadora <> '') AS T order by 1" %>

var Contratados = <%=recordToJSON(db.execute(sqlContratado))%>;

function changeContratos(convenio){


    let options = "";

        Contratados.forEach((contrato) => {
        options+=`<option value="'${contrato.CodigoNaOperadora}'">${contrato.CodigoNaOperadora}</option>`
    });

    $("#tag-contratados").html(`<label>Contratados</label><br /><select id="Contratados" name="Contratados" multiple="multiple">${options}</select>`);

    $('#Contratados').val([<%=req("Contratados")%>]).multiselect({});
}


function changeConvenio(convenio){
    changeContratos(convenio)
    if(!convenio){
        return ;
    }

    let options = "";

    planos.filter(p => p.ConvenioID === convenio).forEach((plano) => {
        options+=`<option value="${plano.id}">${plano.NomePlano}</option>`
    })

    $("#tag-planos").html(`<label>Planos</label><br /><select id="Planos" name="Planos" multiple="multiple">${options}</select>`);

    $('#Planos').val([<%=req("Planos")%>]).multiselect({});
}

function geraInvoice(T, V, Incrementar){
// Fecha o lote
    $.ajax({
		   type:"POST",
		   url:"saveLote.asp?Acao=Inserir&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>",
		   data:$("#frmModal, #guias").serialize(),
		   success:function(data){
			   eval(data);
		   }
		   });

// Adiciona a invoice
    var Lote = $("#Lote").val();
    $("#lanctoGuias").find("button").attr("disabled", true);
    var strIncrementar = "";
    if(Incrementar){
        strIncrementar="&Incrementar="+Incrementar;
    }

    $.post("LoteAReceber.asp?T="+T+"&V="+V+"&ConvenioID=<%=req("ConvenioID")%>&Lotes="+Lote+strIncrementar, $(".guia").serialize(), function(data){
        eval(data);

        setTimeout(function(){
            $("#lanctoGuias").find("button").attr("disabled", false);
        }, 1000);
    });

	return false;
}

jQuery(function() {
  $("table").dataTable({
      ordering: true,
      bPaginate: false,
      bLengthChange: false,
      bFilter: true,
      bInfo: false,
      bAutoWidth: false,
      searching: false
  });
});
</script>

<!-- CAL-514 Adição de filtro de país, estado e cidade no fechamento de lote de guias TISS -->
<script>

    $(document).ready(() => {
        onChangeGuiaTipo();
    });

    function onChangeGuiaTipo() {
        if ($('#T').val() == 'GuiaHonorarios') {
            $('#PaisID').prop('disabled', true);
            $('#EstadoID').prop('disabled', true);
            $('#CidadeID').prop('disabled', true);
        } else {
            $('#PaisID').prop('disabled', false);
            $('#EstadoID').prop('disabled', false);
            $('#CidadeID').prop('disabled', false);
        }
    }

    function getCitiesFromEstado(estadoSigla) {
        return new Promise((resolve, _reject) => {
            getUrl(`ibge/get-cities-from-estado-by-sigla/${estadoSigla}`, {}, (cidades) => resolve(cidades));
        });
    }

    function setCitiesSelect(estadoSigla) {
        if (!estadoSigla)
            estadoSigla = $('#EstadoID option:selected').html();
        if (!estadoSigla || estadoSigla == '')
            return;
        estadoSigla = estadoSigla.toUpperCase();
        
        $('#Estado').val(estadoSigla);
        getCitiesFromEstado(estadoSigla).then((cidades) => {
            const cidadesSelect = $(
                `<select id="CidadeID" name="CidadeID" style="
                        background-color: #fff;
                        border: 1px solid rgba(0, 0, 0, 0.1);
                        border-radius: 4px;
                        height: 38px;
                        width: -webkit-fill-available;">
                    <option selected value="">Todas</option>
                </select>`);
            for (const cidade of cidades) {
                const nome = cidade['Cidade'];
                const feegowId = cidade['id'];
                cidadesSelect.append(`<option value="${feegowId}">${nome}</option>`);
            }
            $('#CidadeID').replaceWith(cidadesSelect[0].outerHTML)
        });
    }
</script>