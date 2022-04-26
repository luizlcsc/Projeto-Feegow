<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->

<style type="text/css">
    .btnGlosa{
        position:absolute;
        z-index:10000;
        margin-left:90px;
        display:none;
    }
    .divGlosa:hover .btnGlosa{
        display:block;
    }
</style>

<script type="text/javascript">
    $(".crumb-active a").html("Buscar Guias");
    $(".crumb-icon a span").attr("class", "far fa-credit-card");
</script>
<%
Unidades = req("CompanyUnitID")
if Unidades="" then
	Unidades = session("Unidades")
end if


if req("T")="GuiaSADT" or req("T")="guiasadt" then
	tabela = "tissguiasadt"
elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
	tabela = "tissguiahonorarios"
elseif req("T")="GuiaInternacao" then
	tabela = "tissguiainternacao"
elseif req("T")="GuiaQuimioterapia" then
	tabela = "tissguiaquimioterapia"
else
	tabela = "tissguiaconsulta"
end if

Retira = req("Retira")
if Retira="1" then
    sqlExecute = "update "&tabela&" set LoteID=0 where id IN("&req("Guia")&")"
    db_execute(sqlExecute)
    set lotesEnv = db.execute("select group_concat(LoteID) lotes from "&tabela&" where id in("& req("Guia") &")")
	set lotesvazios = db.execute("select l.*, (select count(id) from "&tabela&" where LoteID=l.id) quantidade from tisslotes l where l.id IN ("&lotesEnv("lotes")&")")
	while not lotesvazios.eof
		if lotesvazios("quantidade")="0" then
			sqlExecute = "delete from tisslotes where id="&lotesvazios("id")
            db_execute(sqlExecute)
		end if
	lotesvazios.movenext
	wend
	lotesvazios.close
	set lotesvazios=nothing
end if

if req("X")<>"" then
	if req("T")="GuiaSADT" or req("T")="guiasadt" then
		tabela = "tissguiasadt"
		sqlExecute = "delete from tissprocedimentossadt where GuiaID="&req("X")
        db_execute(sqlExecute)

		sqlExecute = "delete from tissprofissionaissadt where GuiaID="&req("X")
        db_execute(sqlExecute)
	elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
		tabela = "tissguiahonorarios"
		sqlExecute = "delete from tissprocedimentoshonorarios where GuiaID="&req("X")
        db_execute(sqlExecute)

		sqlExecute = "delete from tissprofissionaishonorarios where GuiaID="&req("X")
        db_execute(sqlExecute)
    elseif req("T")="GuiaInternacao" then
        tabela = "tissguiainternacao"
        sqlExecute = "delete from tissprocedimentosinternacao where GuiaID="&req("X")
        db_execute(sqlExecute)
    elseif req("T")="GuiaQuimioterapia" then
        tabela = "tissguiaquimioterapia"
        sqlExecute = "delete from tissmedicamentosquimioterapia where GuiaID="&req("X")
        db_execute(sqlExecute)
	elseif req("T")="GuiaConsulta" or req("T")="guiaconsulta" then
		tabela = "tissguiaconsulta"
	end if
	if tabela<>"" then
		sqlExecute = "delete from "&tabela&" where id="&req("X")
        db_execute(sqlExecute)
	end if
end if
%>
<form action="" id="buscaGuias" method="get">
	<input type="hidden" name="P" value="tissbuscaguias" />
    <input type="hidden" name="Pers" value="1" />
    <br />
    <div class="panel">
        <div class="panel-body">
    	    <div class="col-md-3">
        	    <label>Tipo de Guia</label><br />
        	    <select name="T" id="T" class=" form-control" required>
            	    <option value="">Selecione</option>
            	    <option value="GuiaConsulta"<%if req("T")="GuiaConsulta" then%> selected="selected"<%end if%>>Guia de Consulta</option>
                    <option value="GuiaSADT"<%if req("T")="GuiaSADT" then%> selected="selected"<%end if%>>Guia de SP/SADT</option>
                    <option value="GuiaHonorarios"<%if req("T")="GuiaHonorarios" then%> selected="selected"<%end if%>>Guia de Honorários Individuais</option>
                    <option value="GuiaInternacao"<%if req("T")="GuiaInternacao" then%> selected="selected"<%end if%>>Guia de Solicitação de Internação</option>
                    <option value="GuiaQuimioterapia"<%if req("T")="GuiaQuimioterapia" then%> selected="selected"<%end if%>>Guia de Solicitação de Quimioterapia</option>
                </select>
            </div>
            <%= quickField("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 3, req("ConvenioID"), "select * from Convenios where Ativo='on' and sysActive=1 order by NomeConvenio", "NomeConvenio", "onchange=""tissplanosguia(this.value)"" empty="""" required=""required""") %>
            <div class="col-md-3" id="selectLote">
               <%server.Execute("tissselectlote.asp")%>
            </div>
            <%= quickField("memo", "NumeroGuia", "N&deg; da Guia (separadas por Enter)", 3, req("NumeroGuia"), "", "", " placeholder='opcional'") %>
            <div class="col-md-3">
            <%
		    if req("PacienteID")="" then
			    PacienteID = 0
		    else
			    PacienteID = req("PacienteID")
		    end if
		    %>
	            <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", " placeholder='opcional'", "") %>
            </div>
            <%= quickField("datepicker", "DataDe", "Data do Atendimento", 2, req("DataDe"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAte", "&nbsp;", 2, req("DataAte"), "", "", " placeholder='At&eacute;'") %>
            
            <%= quickField("datepicker", "DataDePreenchimento", "Data do Preenchimento", 2, req("DataDePreenchimento"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAtePreenchimento", "&nbsp;", 2, req("DataAtePreenchimento"), "", "", " placeholder='At&eacute;'") %>
            <%= quickField("empresaMultiIgnore", "CompanyUnitID", "Unidades", 3, Unidades, "", "", "")%>
            <div class="col-md-2">
                <label>Ordenar por</label><br />
                <select name="OrdenarPor" id="OrdenarPor" class="form-control" required>
                    <option value="0">Data do preenchimento</option>
                    <option value="1" <%if req("OrdenarPor")="1" then%> selected="selected"<%end if%>>Nome do paciente</option>
                    <option value="2" <%if req("OrdenarPor")="2" then%> selected="selected"<%end if%>>Número da guia</option>
                    <option value="3" <%if req("OrdenarPor")="3" then%> selected="selected"<%end if%>>Data da solicitação</option>
                </select>
                
            </div>
            <%= quickField("simpleSelect", "GuiaStatusID", "Status", 2, req("GuiaStatusID"), "SELECT * FROM cliniccentral.tissguiastatus ORDER BY Status", "Status", " empty") %>
            <div id="tissplanosguia">
                 <%= quickField("simpleSelect", "PlanoID", "Plano ", 2, req("PlanoID"), "SELECT id, nomeplano from conveniosplanos WHERE false and sysActive = 1 ORDER BY nomeplano ", "nomeplano", " empty") %>
            </div>
            
            <div class="col-md-2">
        	    <label>&nbsp;</label><br />
                <button class="btn btn-primary btn-block"><i class="far fa-search"></i> Buscar</button>
            </div>
        </div>
    </div>
</form>


<div class="panel">
    <div class="panel-heading">

        <div class="btn-group">
            <button class="btn btn-sm btn-primary dropdown-toggle dropdown-status" data-toggle="dropdown"><i class="far fa-plus"></i> Inserir Guia  <i class="far fa-angle-down icon-on-right"></i></button>
            <ul class="dropdown-menu dropdown-danger">
            <li><a href="./?P=tissguiaconsulta&I=N&Pers=1"><i class="far fa-plus"></i> Consulta</a></li>
            <li><a href="./?P=tissguiasadt&I=N&Pers=1"><i class="far fa-plus"></i> SP/SADT</a></li>
            <li><a href="./?P=tissguiahonorarios&I=N&Pers=1"><i class="far fa-plus"></i> Honorários</a></li>
            <li><a href="./?P=tissguiainternacao&I=N&Pers=1"><i class="far fa-plus"></i> Sol. Internação</a></li>
            <li><a href="./?P=tissguiaquimioterapia&I=N&Pers=1"><i class="far fa-plus"></i> Sol. Quimioterapia</a></li>
            </ul>
        </div>

        <span id="lanctoGuias" class="pl20"></span>
        


        <span>           
            

        </span>
        <span class="panel-controls">
        <%
        if aut("loteX")=1 then
        %>
            <button type="button" disabled class="btn-acao-guias btn btn-sm btn-warning" onclick="retiraGuia( $('.guia:checked').serialize() )"><i class="far fa-arrow-circle-left"></i> Retirar do Lote</button>
        <%
        end if
        %>
            <button onclick="glosa('Pago', 'M');" disabled class=" btn-acao-guias btn btn-sm btn-success"><i class="far fa-thumbs-up"></i> Pago</button>
            <button onclick="glosa('Glosado', 'M');" disabled class=" btn-acao-guias btn btn-sm btn-danger"><i class="far fa-thumbs-down"></i> Glosado</button>
        </span>
    </div>
    <div class="panel-body">
<%
if req("ConvenioID")<>"" then

    set GuiaStatusSQL = db.execute("SELECT * FROM cliniccentral.tissguiastatus order by id")

    if aut("guiasA")=1 then
        desativar = ""
    else
        desativar = "disabled"
    end if
    StatusSelect = "<div class='btn-group mb10'><button class='btn btn-sm btn-COR-- dropdown-status dropdown-toggle "&desativar&"' data-toggle='dropdown' aria-expanded='false'  > <span class='label-status'>LABEL--</span>  <i class='far fa-angle-down icon-on-right'></i></button><ul class='dropdown-menu dropdown-danger'>"
    while not GuiaStatusSQL.eof

        StatusSelect = StatusSelect&"<li ><a data-value='"&GuiaStatusSQL("id")&"' style='cursor:pointer' class='StatusGuia'><div style='border-radius:50%;width:8px;height:8px;float:left;' class='mr5 mt5 btn-"&GuiaStatusSQL("Cor")&"'></div>"&GuiaStatusSQL("Status")&"</a></option>"
    GuiaStatusSQL.movenext
    wend
    GuiaStatusSQL.close
    set GuiaStatusSQL = nothing

    StatusSelect = StatusSelect&"</div><br>"
end if

if req("ConvenioID")<>"" and req("T")="GuiaConsulta" or req("T")="guiaconsulta" then
	%>
    <table width="100%" class="table table-striped" id="table-busca-guias">
	<thead>
    	<tr class="info">
        	<th colspan="5">
                <div class="pl10 checkbox-custom checkbox-primary">
                    <input type="checkbox" id="allConsulta" onclick="$('.guia').prop('checked', $(this).prop('checked') )" />
                    <label for="allConsulta"> Guia</label>
                </div>
            </th>
        </tr>
    </thead>
    <tbody>
	<%
    orderBy = "g.sysDate"

    if req("OrdenarPor") = "2" then
        orderBy = "cast(g.NGuiaPrestador as signed integer) DESC"
    end if

    if req("GuiaStatusID")<>"" then
        if req("GuiaStatusID")=null then
            req("GuiaStatusID")="0"
        end if
        sqlGuiaStatus = " AND tgs.id = "&req("GuiaStatusID")
    end if

	if req("LoteID")<>"" then
	    if req("LoteID")="-1" then
		    sqlLote = " and (tgi.ItemInvoiceID IS NULL OR tgi.ItemInvoiceID='')"
        else
		    sqlLote = " and g.LoteID="&req("LoteID")
        end if
        orderBy = "(CASE l.Ordem WHEN 'Data' THEN g.sysDate WHEN 'Paciente' THEN p.NomePaciente ELSE g.NGuiaPrestador END)"
	end if

    if req("OrdenarPor") = "1" then
        orderBy = "p.NomePaciente"
    end if

	if req("NumeroGuia")<>"" then
	    sqlNumero=""
	    getNumeroGuia = req("NumeroGuia")
	    ' adaptado para receber varios numeros
	    splU = split(getNumeroGuia, chr(13))
        for i=0 to ubound(splU)
            NGuia = trim(splU(i))
            NGuia = replace(NGuia, chr(10),"")
            if Nguia<>"" then
                sqlNumero = sqlNumero &" or (g.NGuiaPrestador='"&NGuia&"' or g.NGuiaOperadora='"&NGuia&"')"
            end if
        next
        sqlNumero = " and (1=0 "&sqlNumero&")"
	end if
	if req("PacienteID")<>"" and req("PacienteID")<>"0" then
		sqlPaciente = " and g.PacienteID="&req("PacienteID")
	end if


	if req("DataDe")<>"" and isdate(req("DataDe")) then
		sqlDataDe = " and date(DataAtendimento)>='"&mydate(req("DataDe"))&"'"
	end if
	if req("DataAte")<>"" and isdate(req("DataAte")) then
		sqlDataAte = " and date(DataAtendimento)<='"&mydate(req("DataAte"))&"'"
	end if

	if req("DataDePreenchimento")<>"" and isdate(req("DataDePreenchimento")) then
		sqlDataDePreenchimento = " and date(g.sysDate)>='"&mydate(req("DataDePreenchimento"))&"'"
	end if
	if req("DataAtePreenchimento")<>"" and isdate(req("DataAtePreenchimento")) then
		sqlDataAtePreenchimento = " and date(g.sysDate)<='"&mydate(req("DataAtePreenchimento"))&"'"
	end if

    if Unidades<>"" then
        sqlUnidades = " and g.UnidadeID IN ("& replace(Unidades, "|", "") &") "
    end if

    if req("PlanoID") <>"" and req("PlanoID")<>"0" then
        sqlPlano = " and g.PlanoID = '"& req("PlanoID") &"' "
    end if

    ' Alterado ANDRE SOUZA EM 04/10/2019 Tarefa:1084
    sql = "select cp.NomePlano, g.*, l.Lote, tgi.ItemInvoiceID, tgi.InvoiceID, tgs.Cor, tgs.Status, tgs.Icone, l.Enviado from tissguiaconsulta g"
    sql = sql & " LEFT JOIN cliniccentral.tissguiastatus tgs ON tgs.id = COALESCE(g.GuiaStatus, 0) left join tisslotes l on l.id=g.LoteID "
    sql = sql & " LEFT JOIN pacientes p ON p.id = g.PacienteID "
    sql = sql & " LEFT JOIN tissguiasinvoice tgi on (tgi.GuiaID=g.id and tgi.TipoGuia='" & lcase(req("T"))&"')" 
    sql = sql & " LEFT JOIN conveniosplanos cp ON cp.ConvenioID = g.ConvenioID AND cp.id = g.PlanoID where g.sysActive=1 "
    sql = sql & sqlLote & sqlNumero & sqlGuiaStatus & sqlPaciente & sqlDataDe & sqlDataAte & sqlDataDePreenchimento & sqlDataAtePreenchimento & sqlPlano
    sql = sql & sqlUnidades &" and g.ConvenioID="&req("ConvenioID")&" ORDER BY "&orderBy&" LIMIT 100"
    ' -------
	set guias = db.execute(sql)
        c=0
        ValorTotal=0
	while not guias.EOF
        ItemInvoiceID = guias("ItemInvoiceID")
        bloquear = ""
        if guias("LoteID")<>0 then
           bloquear = "disabled"
        end if
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
        ValorTotal=ValorTotal+guias("ValorProcedimento")
        if isnull(ItemInvoiceID) then
            disabled = ""
        else
            disabled = " disabled "
        end if

		%>
		<tr id="guia-linha-<%=guias("id")%>" >
            <td >
                <div class="col-md-3">

                    <input type="hidden" class="loteid_val" value="<%=guias("LoteID") %>" />
                    <%if not isnull(ItemInvoiceID) then %>
                    <a title="Ir para conta" href="./?P=Invoice&T=C&I=<%=guias("InvoiceID") %>&Pers=1" class="btn btn-xs btn-success"><i class="far fa-money"></i></a>
                    <strong>N&uacute;mero:</strong> <%= guias("NGuiaPrestador") %>
                    <%else %>

                        <% if isnull(ItemInvoiceID) and guias("LoteID") <> 0 then %>
                            <div class="checkbox-custom checkbox-warning">
                                <input type="checkbox" class="guia" name="Guia" id="ckGuia<%=guias("id") %>" value="<%=guias("id") %>" />
                                <label for="ckGuia<%=guias("id") %>">
                                    <strong>N&uacute;mero:</strong> <%= guias("NGuiaPrestador") %>
                                </label>
                            </div>
                        <% else %>
                            <div>
                                <label>
                                    <input type="hidden" class="guia" value="<%=guias("id") %>" />
                                    <strong>N&uacute;mero:</strong> <%= guias("NGuiaPrestador") %>
                                </label>
                            </div>
                        <% end if %>

                    <%end if %>
                </div>
	            <div class="col-md-6"><strong>Paciente:</strong> <a style="cursor: pointer;" onclick="modalPaciente('<%=guias("PacienteID")%>')"><%=NomePaciente%></a></div>
				<div class="col-md-3">
                    <strong>Preenchimento: </strong><%= left(guias("sysDate"),10) %>
                    - <b>Valor: </b>R$ <%=fn(guias("ValorProcedimento")) %>
				</div>
                <input class="valor-total-guia" value="<%=fn(guias("ValorProcedimento")) %>" type="hidden">
                <div class="col-md-3"><div class="col-md-8">
                 <%
                'if aut("|guiasA|")=1 then

                    Cor = guias("Cor")
                    Status = guias("Status")
                    StatusSelectS = StatusSelect

                    if not isnull(Cor) then
                        StatusSelectS = replace(StatusSelectS,"COR--",Cor)
                    end if

                    if not isnull(Status) and Status<>"" then
                        StatusSelectS = replace(StatusSelectS,"LABEL--",Status)
                    else
                        StatusSelectS = replace(StatusSelectS,"LABEL--","Sem status")
                    end if
                    response.write(StatusSelectS)
                'end if


				if guias("LoteID")=0 then
					response.Write("<button type=""button"" onclick=""insereGuia("&guias("id")&")"" title=""Adicionar a um Lote"" class=""btn-default btn btn-xs""><i class=""far fa-arrow-alt-circle-right""></i></button> FORA DE LOTE")
				else
                    if aut("loteX")=1 and (guias("Enviado")&""<>"1" or aut("guiadentrodeloteA")=1) then
					    response.Write("<button type=""button"" "& disabled &" onclick=""$('.guia').prop('checked', false); $('#ckGuia"& guias("id") &"').prop('checked', true); retiraGuia('Guia="&guias("id")&"')"" title=""Retirar do Lote"" class=""btn-warning btn btn-xs""><i class=""far fa-arrow-circle-left""></i></button>")
					end if
					response.Write("<strong>Lote: </strong> "&guias("Lote"))
				end if
				%></div>
                    <div class="col-md-4">
                     <button type="button" class="btn btn-info btn-sm" onclick="modalTissGuiaStatuslog(<%=guias("id") %>, '<%=req("T")%>')"><i class="far fa-comment"></i></button>
                    </div>
                </div>
        		<div class="col-md-6"><strong>Executante: </strong><%= NomeProfissional %></div>
                <div class="col-md-3"><strong>Cód. na Operadora: </strong><%= guias("CodigoNaOperadora") %></div>
                <% if guias("NomePlano") <> "" then %>
                <div class="col-md-3"><strong>Plano: </strong><%= guias("NomePlano") %></div>
                <% end if %>
             </td>
             <td width="150" class="divGlosa" id="dvp<%=guias("id")%>" nowrap>                            
                 <div class="btnGlosa">
                     <button type="button" class="btn btn-xs btn-success" <%=disabled %> onclick="glosa('Pago', <%=guias("id") %>)" title="Pago"><i class="far fa-thumbs-up"></i></button>
                     <button type="button" class="btn btn-xs btn-danger" <%=disabled %> onclick="glosa('Glosado', <%=guias("id") %>)" title="Glosado"><i class="far fa-thumbs-down"></i></button>
                 </div>
                 

                 <%
                 if guias("Glosado")=1 then
                     response.write("<center><span class='label label-danger'>Glosada</span></center>")
                 else
                    jsAtualizaValor = "onchange='lancamentoValorPago(`"&guias("id")&"`,`"&req("T")&"`)'"
                    'response.write(jsAtualizaValor)
                    response.write quickfield("text", "ValorPago"&guias("id"), "Valor", 12, fn(guias("ValorPago")), " text-right input-mask-brl input-valor-pago", "", " "&jsAtualizaValor& disabled &" ")
                 end if
                 %>

             </td>
             <td><a href="./?P=tissguiaconsulta&Pers=1&I=<%=guias("id")%>" class="btn btn-success"><i class="far fa-edit"></i> Editar</a></td>
             <td><button type="button" class="btn btn-info" onclick="guiaTISS('GuiaConsulta', <%=guias("id")%>,'<%=req("ConvenioID")%>')"><i class="far fa-print"></i></button></td>

             <td>
                <%
                if aut("|guiasX|")=1 then
                %>
                <a href="./?P=tissbuscaguias&Pers=1&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&LoteID=<%=req("LoteID")%>&NumeroGuia=<%=req("NumeroGuia")%>&PacienteID=<%=req("PacienteID")%>&searchPacienteID=<%=req("searchPacienteID")%>&DataDe=<%=req("DataDe")%>&DataAte=<%=req("DataAte")%>&X=<%=guias("id")%>" <%=disabled %> class="btn btn-danger <%=bloquear%>"><i class="far fa-remove"></i></a>
                <%  
                end if
                %>
            </td>
        </tr>
		<%
	guias.movenext
	wend
	guias.close
	set guias=nothing
	%>
    </tbody>
    <tfoot>
        <tr>
            <th><%=c %> registros encontrados.</th>
            <th>Total: R$<%=fn(ValorTotal) %> </th>
        </tr>
    </tfoot>
    </table><%
elseif req("ConvenioID")<>"" and (req("T")="GuiaSADT" or req("T")="guiasadt" or req("T")="GuiaHonorarios" or req("T")="guiahonorarios" or req("T")="GuiaInternacao" or req("T")="GuiaQuimioterapia") then
    if req("T")="GuiaSADT" or req("T")="guiasadt" then
        tabela = "tissguiasadt"
        ColunaTotal = "TotalGeral"
    elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
        tabela = "tissguiahonorarios"
        ColunaTotal = "Procedimentos"
    elseif req("T")="GuiaInternacao" then
        tabela = "tissguiainternacao"
        ColunaTotal = "TotalGeral"
    elseif req("T")="GuiaQuimioterapia" then
        tabela = "tissguiaquimioterapia"
        ColunaTotal = "TotalGeral"
    end if
	%>
    <table width="100%" class="table table-striped" id="table-busca-guias">
	<thead>
    	<tr class="info">
        	<th><div class="pl10 checkbox-custom checkbox-primary">
                    <input type="checkbox" onclick="$('.guia').prop('checked', $(this).prop('checked') )" id="allSADT" /> <label for="allSADT"> Guia</label></div></th>
            <%if req("T")<>"GuiaInternacao" or req("T")="GuiaQuimioterapia" then%>
            <th width="100" nowrap>Val. Pago</th>
            <%else%>
            <th width="100" nowrap></th>
            <%end if%>
            <th width="1%" class="text-center">Editar</th>
            <th width="1%" class="text-center"><i class="far fa-print"></i></th>
            <th width="1%" class="text-center"><i class="far fa-trash"></i></th>
        </tr>
    </thead>
    <tbody>
	<%
	orderBy = "g.sysDate"


    if req("LoteID")<>"" then
        if req("LoteID")="-1" then
            sqlLote = " and (tgi.ItemInvoiceID IS NULL OR tgi.ItemInvoiceID='')"
        else
            sqlLote = " and g.LoteID="&req("LoteID")
        end if
		orderBy = "(CASE l.Ordem WHEN 'Data' THEN g.sysDate WHEN 'Paciente' THEN p.NomePaciente ELSE g.NGuiaPrestador END)"
    end if

	if req("OrdenarPor") = "1" then
	    orderBy = "p.NomePaciente"
	end if

    if req("OrdenarPor") = "2" then
        orderBy = "cast(g.NGuiaPrestador as signed integer) DESC"
    end if

    if req("OrdenarPor") = "3" then
        if req("T")="GuiaSADT" or req("T")="guiasadt" or req("T")="GuiaInternacao" or req("T")="GuiaQimioterapia" then
        	orderBy  = "g.DataSolicitacao"
        elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
        	orderBy = "g.DataEmissao"
        elseif req("T")="GuiaConsulta" or req("T")="guiaconsulta" then
        	orderBy = "g.DataAtendimento"
        end if
    end if

	if req("NumeroGuia")<>"" then
        sqlNumero=""
        getNumeroGuia = req("NumeroGuia")
        ' adaptado para receber varios numeros
        splU = split(getNumeroGuia, chr(13))
        for i=0 to ubound(splU)
            NGuia = trim(splU(i))
            NGuia = replace(NGuia, chr(10),"")
            if Nguia<>"" then
                sqlNumero = sqlNumero &" or (g.NGuiaPrestador='"&NGuia&"' or g.NGuiaOperadora='"&NGuia&"')"
            end if
        next
        sqlNumero = " and (1=0 "&sqlNumero&")"
    end if
    if req("GuiaStatusID")<>"" then
        if req("GuiaStatusID")=null then
            req("GuiaStatusID")="0"
        end if
        sqlGuiaStatus = " AND tgs.id = "&req("GuiaStatusID")
    end if

	if req("PacienteID")<>"" and req("PacienteID")<>"0" then
		sqlPaciente = " and g.PacienteID="&req("PacienteID")
	end if

	if req("T")="GuiaSADT" or req("T")="guiasadt" or req("T")="GuiaInternacao" or req("T")="GuiaQuimioterapia" then
        if req("DataDe")<>"" and isdate(req("DataDe")) then
            sqlDataDe = " and date(g.DataSolicitacao)>='"&mydate(req("DataDe"))&"'"
        end if
        if req("DataAte")<>"" and isdate(req("DataAte")) then
            sqlDataAte = " and date(g.DataSolicitacao)<='"&mydate(req("DataAte"))&"'"
        end if
	elseif req("T")="GuiaHonorarios" or req("T")="guiahonorarios" then
	    if req("DataDe")<>"" and isdate(req("DataDe")) then
            sqlDataDe = " and date(g.DataEmissao)>='"&mydate(req("DataDe"))&"'"
        end if
        if req("DataAte")<>"" and isdate(req("DataAte")) then
            sqlDataAte = " and date(g.DataEmissao)<='"&mydate(req("DataAte"))&"'"
        end if
	end if

	if req("DataDePreenchimento")<>"" and isdate(req("DataDePreenchimento")) then
		sqlDataDePreenchimento = " and date(g.sysDate)>='"&mydate(req("DataDePreenchimento"))&"'"
	end if
	if req("DataAtePreenchimento")<>"" and isdate(req("DataAtePreenchimento")) then
		sqlDataAtePreenchimento = " and date(g.sysDate)<='"&mydate(req("DataAtePreenchimento"))&"'"
	end if

    if req("PlanoID")<>"" and req("PlanoID")<>"0" then
        sqlPlano = " and g.PlanoID = '"& req("PlanoID") &"' "
    end if

    if Unidades<>"" then
        sqlUnidades = " and g.UnidadeID IN ("& replace(Unidades, "|", "") &") "
    end if
        c=0
        ValorTotal=0
    sql = "select cp.NomePlano, g.*, l.Lote, tgi.ItemInvoiceID, tgi.InvoiceID, tgs.Cor,tgs.Status, l.Enviado from "&tabela&" g "
    sql = sql & " LEFT JOIN cliniccentral.tissguiastatus tgs ON tgs.id = COALESCE(g.GuiaStatus, 0) left join tisslotes l on l.id=g.LoteID "
    sql = sql & " LEFT JOIN pacientes p ON p.id = g.PacienteID "
    sql = sql & " LEFT JOIN tissguiasinvoice tgi on (tgi.GuiaID=g.id and tgi.TipoGuia='"&lcase(req("T"))&"') "
    sql = sql & " LEFT JOIN conveniosplanos cp ON cp.ConvenioID = g.ConvenioID AND cp.id = g.PlanoID "
    sql = sql & " WHERE g.sysActive=1" & sqlLote & sqlNumero & sqlPaciente & sqlDataDe&sqlDataAte & sqlDataDePreenchimento & sqlPlano
    sql = sql & sqlDataAtePreenchimento & sqlUnidades & sqlGuiaStatus 
    sql = sql & " and g.ConvenioID="&req("ConvenioID")
    sql = sql & " GROUP BY g.id ORDER BY "&orderBy&" LIMIT 200"
	set guias = db.execute(sql)
    TotalPago = 0
	while not guias.EOF
        if IsNumeric(guias("ValorPago")) then
            guia_valorPago = guias("ValorPago")
        else
           guia_valorPago = 0
        end if
        
        TotalPago = TotalPago+guia_valorPago

        Total = guias(ColunaTotal)


        if not isnumeric(Total) then
            Total=0
        end if

        Total = ccur(Total)

        ItemInvoiceID = guias("ItemInvoiceID")
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if
        c = c+1
        bloquear = ""
        if guias("LoteID")<>0 then
           bloquear = "disabled"
        end if
        if isnull(ItemInvoiceID) then
            disabled = ""
        else
            disabled = " disabled "
            disabled = " disabledEdicaoProcedimento "
        end if

        AVencerAlerta=""
        if req("T")="GuiaSADT" or req("T")="guiasadt" then
            AVencer = datediff("d", guias("DataAutorizacao"), guias("DataValidadeSenha"))
            if AVencer <= 10 and isnull(guias("Lote")) then
                AVencerAlerta = "S"
                DataValidadeGuia = guias("DataValidadeSenha")
            end if
        end if

		%>
		<tr id="guia-linha-<%=guias("id")%>">
        	<td>

                <div class="col-md-3">
                    <input type="hidden" class="loteid_val" value="<%=guias("LoteID") %>" />
                    <%if not isnull(ItemInvoiceID) then %>
                    <a title="Ir para conta" href="./?P=Invoice&T=C&I=<%=guias("InvoiceID") %>&Pers=1" class="btn btn-xs btn-success"><i class="far fa-money"></i></a>
                    <span <% if AVencerAlerta<> "" then%>style="color:red" <% end if%> >
                    <strong>N&uacute;mero:</strong> <%= guias("NGuiaPrestador") %>
                    </span>
                    <%else %>
                    <div class="checkbox-custom checkbox-warning">
                        <input type="checkbox" class="guia" name="Guia" id="ckGuia<%=guias("id") %>" value="<%=guias("id") %>" />
                        <label for="ckGuia<%=guias("id") %>">
                            <strong>N&uacute;mero:</strong> <%= guias("NGuiaPrestador")%>

                            <%
                            if AVencerAlerta<> "" then
                            %>
                            <br>
                            <small style="color: red"><i>* Senha da guia válida até <%=DataValidadeGuia%></i></small>
                            <%
                            end if
                            %>
                        </label>
                        <%

                        Obs = guias("Observacoes")
                        if Obs&"" <> "" then
                        %>
                        <br>
                        <small><strong>Observações:</strong> <%=Obs%></small>
                        <%
                        end if
                        %>
                    </div>
                    <%end if %>
                </div>
                <div class="col-md-6"><strong>Paciente:</strong> <a style="cursor: pointer;" onclick="modalPaciente('<%=guias("PacienteID")%>')"><%=NomePaciente%></a></div>
				<div class="col-md-3"><strong>Preenchimento: </strong><%= left(guias("sysDate"),10) %></div>
                <div class="col-md-3"><div class="col-md-8"><%
                'if aut("|guiasA|")=1 then
                    Cor = guias("Cor")
                    Status = guias("Status")

                    StatusSelectS = StatusSelect

                    if not isnull(Cor) then
                        StatusSelectS = replace(StatusSelectS,"COR--",Cor)
                    end if
                    if not isnull(Status) and Status<>"" then
                        StatusSelectS = replace(StatusSelectS,"LABEL--",Status)
                    else
                        StatusSelectS = replace(StatusSelectS,"LABEL--","Sem status")
                    end if
                    response.write(StatusSelectS)
                'end if
				if guias("LoteID")=0 then
					response.Write("<button type=""button"" onclick=""insereGuia("&guias("id")&")"" title=""Adicionar a um Lote"" class=""btn-default btn btn-xs""><i class=""far fa-arrow-alt-circle-right""></i></button> FORA DE LOTE")
				else
                    if aut("loteX")=1 and (guias("Enviado")&""<>"1" or aut("guiadentrodeloteA")=1) then
                        response.Write("<button type=""button"" "& disabled &" onclick=""$('.guia').prop('checked', false); $('#ckGuia"& guias("id") &"').prop('checked', true); retiraGuia('Guia="&guias("id")&"')"" title=""Retirar do Lote"" class=""btn-warning btn btn-xs""><i class=""far fa-arrow-circle-left""></i></button>")
				    end if
                        response.Write("<strong> Lote: </strong> "&guias("Lote")&"")

				end if
                if req("T")="GuiaSADT" or req("T")="guiasadt" then
                    set ps = db.execute("SELECT ps.*, p.NomeProcedimento FROM tissprocedimentossadt ps LEFT JOIN procedimentos p ON p.id=ps.ProcedimentoID WHERE ps.GuiaID="& guias("id"))
                    while not ps.eof
                        %>
                        <br />
                        <%= ps("NomeProcedimento") %>
                        <%
                    ps.movenext
                    wend
                    ps.close
                    set ps=nothing
                end if
				%></div>
				<div class="col-md-4">
				 <button type="button" class="btn btn-info btn-sm" onclick="modalTissGuiaStatuslog(<%=guias("id") %>, '<%=req("T")%>')"><i class="far fa-comment"></i></button>
                </div>
				</div>
				<%if req("T")<>"GuiaInternacao" or req("T")<>"GuiaQuimioterapia" then%>
                <div class="col-md-3">Valor: R$ <%=fn(Total)%></div>
                <%end if%>
                <input class="valor-total-guia" value="<%=Total %>" type="hidden">
                <div class="col-md-3"><strong>Cód. na Operadora: </strong><%= guias("CodigoNaOperadora") %></div>
                
                <%if req("T")="GuiaSADT" or req("T")="guiasadt" then%>
            		<div class="col-md-3">
                        <div class="row"><strong>Cód. Solicitante: </strong><%= guias("ContratadoSolicitanteCodigoNaOperadora") %></div>
                        <div class="row">
                            <button type="button" class="btn btn-info btn-sm " onclick="guiaTISS('EspelhoConta', <%=guias("id")%>,'<%=req("ConvenioID")%>')"><i class="far fa-print"> Espelho da Conta</i></button>
                        </div>
                    </div>                    
                <%end if %>
                <% if guias("NomePlano") <> "" then %>
                <div class="col-md-3"><strong>Plano: </strong><%= guias("NomePlano") %></div>
                <% end if %>
             </td>
             <td width="150" class="divGlosa" id="dvp<%=guias("id")%>" nowrap>
                 <%if req("T")<>"GuiaInternacao" or req("T")<>"GuiaQuimioterapia" then%>
                 <div class="btnGlosa">
                     <button type="button" class="btn btn-xs btn-success" <%=disabled %> onclick="glosa('Pago', <%=guias("id") %>)" title="Pago"><i class="far fa-thumbs-up"></i></button>
                     <button type="button" class="btn btn-xs btn-danger" <%=disabled %> onclick="glosa('Glosado', <%=guias("id") %>)" title="Glosado"><i class="far fa-thumbs-down"></i></button>
                 </div>
                 <%end if%>

                 <%
                 if(UCase("GuiaHonorarios") = UCase(req("T"))) then
                    valorTotalCheck = guias("Procedimentos")
                 else
                    valorTotalCheck = guias("TotalGeral")
                 end if

                 if req("T")<>"GuiaInternacao" then
                     if guias("Glosado")=1 then
                         response.write("<center><span class='label label-danger'>Glosada</span></center>")
                     else
                         valorPagoCheck = guias("ValorPago")
                         guiaIdCheck = guias("id")
                         qualtabela = req("T")

                         eventModal = "onchange=correcaoValoresProcedimentos(this,'"&guiaIdCheck&"','"&valorTotalCheck&"',"&Chr(34)&qualtabela&Chr(34)&")"
                         response.write quickfield("text", "ValorPago"&guias("id"), "Valor Pago", 12, fn(guias("ValorPago")), " text-right input-mask-brl input-valor-pago", ""," "&eventModal& disabled &" ")
                        
                         if(UCase(req("T")) = UCase("GuiaHonorarios")) or (UCase(req("T")) = UCase("GuiaSADT")) then
                            set ProcedimentoComValorPagoNullSQL = db.execute("SELECT id FROM tissprocedimentossadt WHERE GuiaID="&guias("id")&" AND ValorPago IS NULL")
                            if not ProcedimentoComValorPagoNullSQL.eof then
                                disabledEdicaoProcedimento=""
                            end if

                            if valorPagoCheck&"" = ""  then
                                valorPagoCheck = 0
                            end if

                            if valorTotalCheck&"" = ""  then
                                valorTotalCheck = 0
                            end if

                            if(ccur(valorPagoCheck) <> ccur(valorTotalCheck)) then  %>
                                 <button id="procedimentos_button_<%= guiaIdCheck %>" style="text-align: center;display: flex; margin: 0px auto;" type="button" <%=disabledEdicaoProcedimento%> class="btn btn-success btn-sm " onclick="correcaoValoresProcedimentos(self, '<%= guiaIdCheck %>', '<%= valorTotalCheck %>', '<%= qualtabela %>')"><i class="far fa-edit"> Procedimentos</i></button>
                            <% else %>
                                <button id="procedimentos_button_<%= guiaIdCheck %>" style="text-align: center;display: flex; margin: 0px auto; display:none" type="button" <%=disabledEdicaoProcedimento%> class="btn btn-success btn-sm " onclick="correcaoValoresProcedimentos(self, '<%= guiaIdCheck %>', '<%= valorTotalCheck %>', '<%= qualtabela %>')"><i class="far fa-edit"> Procedimentos</i></button>
                            <% end if
                         end if

                     end if
                 end if
                 ValorTotal = ValorTotal + Total
                 %>
                 
                 </td>
             <td><a href="./?P=<%=tabela %>&Pers=1&I=<%=guias("id")%>" class="btn btn-success btn-sm"><i class="far fa-edit"></i> Editar</a></td>
             <td><button type="button" class="btn btn-info btn-sm" onclick="guiaTISS('<%=req("T")%>', <%=guias("id")%>,'<%=req("ConvenioID")%>')"><i class="far fa-print"></i></button></td>
             <td>
                <%
                if aut("|guiasX|")=1 then
                %>
                <a href="./?P=tissbuscaguias&Pers=1&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&LoteID=<%=req("LoteID")%>&NumeroGuia=<%=req("NumeroGuia")%>&PacienteID=<%=req("PacienteID")%>&searchPacienteID=<%=req("searchPacienteID")%>&DataDe=<%=req("DataDe")%>&DataAte=<%=req("DataAte")%>&X=<%=guias("id")%>" <%=disabled %> class="btn btn-sm btn-danger <%=bloquear%>"><i class="far fa-remove"></i></a>
                <%
                end if
                %>
            </td>
        </tr>
		<%
	guias.movenext
	wend
	guias.close
	set guias=nothing

    saldoTotal = FormatNumber(TotalPago-fn(ValorTotal))
    if saldoTotal<0 then
        saldoTotal__class = "text-danger"
    else
        saldoTotal__class = "text-primary"
    end if
	%>
        </tbody>
        <tfoot>
            <tr>
                <th>
                    <div class="col-md-6"><%=c&" registros encontrados." %></div>
                    <div class="col-md-6"><%="Total Gerado: <br><small>R$"&fn(ValorTotal)&"</small>"%> </div>
                </th>
                <th>
                    <%="Total Pago: <br><small>R$"&TotalPago&"</small>" %>
                </th>
                <th colspan="3">
                    <%="Saldo: <br><small class='"&saldoTotal__class&"'>R$"&saldoTotal&"</small>"%>
                </th>
            </tr>
        </tfoot>
    </table><%
end if

%>
    </div>
</div>


<script type="text/javascript">

function correcaoValoresProcedimentos(self, guiaId, valorTotalCheck, tabela) {
    var valorDigitado = document.getElementById('ValorPago'+guiaId).value;
    var valor = valorDigitado.replace(",00","").replace(".","");
    var valorTotalCheck = valorTotalCheck.replace(",00","").replace(".","");
    
    if(valorTotalCheck != valor){
        document.getElementById('procedimentos_button_'+guiaId).style.display = "flex"

        openComponentsModal("ProcedimentosListagemCorrecao.asp", {guiaId: guiaId, tabela: tabela, valor: valor }, "Procedimentos", true);
    }else{
        lancamentoValorPago(guiaId, tabela, valorDigitado);
    }
}

function modalTissGuiaStatuslog(GuiaID, TipoGuia) {
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.post("modalTissGuiaStatuslog.asp?GuiaID="+GuiaID+"&TipoGuia="+TipoGuia, "", function (data) { $("#modal").html(data) });
    $("#modal").addClass("modal-lg");
 }

function modalPaciente(ID) {
    $("#modal-table").modal("show");
    $("#modal").html(`<div class="p10"><button type="button" class="close" data-dismiss="modal">×</button><center><i class="far fa-2x fa-circle-o-notch fa-spin"></i></center></div>`)
    $.post("modalPacientes.asp?I="+ID, "", function (data) { $("#modal").html(data) });
    $("#modal").addClass("modal-lg");
 }

function lancamentoValorPago(guiaId, tipoGuia, valorNovo, statusId=false, Operacao=""){
    
    if (valorNovo === undefined){
        valorNovo = $("#ValorPago"+guiaId).val();
    }

    $.post("Glosa.asp?TG=<%=req("T")%>&I="+guiaId+"&T="+Operacao, {
        n: "ValorPago"+guiaId,
        vp: valorNovo,
    }, function (data) {
        eval(data);
        
        if(statusId){
            alteraStatusGuia(guiaId, tipoGuia, statusId);
        }

        $("#guia-linha-"+guiaId).find(".input-valor-pago").val(valorNovo);

        showMessageDialog("Salvo com sucesso", "success");
    });

    if(statusId){
        alteraStatusGuia(guiaId, tipoGuia, statusId);
    }
}



 function alteraStatusGuia(guiaId, tipoGuia, statusId){
     var $lb = $("#guia-linha-"+guiaId, "#table-busca-guias").find(".dropdown-status");

    $.get("AlteraStatusGuia.asp", {GuiaID:guiaId, TipoGuia:tipoGuia, Status: statusId, Lista:1}, function(data) {
        data = JSON.parse(data);

        $lb.find(".label-status").html(data.Status);
        $lb.removeClass("btn-primary btn-warning btn-success btn-danger btn-dark");

        $lb.addClass("btn-"+data.Cor);
    })
 }

$(".StatusGuia").click(function() {
    var $lb = $(this).parents("tr").find(".dropdown-toggle");
    var guiaId = $(this).parents("tr").find(".guia").val();
    var tipoGuia = "<%=req("T")%>";
    var statusId = $(this).attr("data-value");

     alteraStatusGuia(guiaId, tipoGuia, statusId);
});

function tissplanosguia(ConvenioID){
	$.ajax({
		type:"POST",
		url:"chamaTissplanosguia.asp?ConvenioID="+ConvenioID,
		data:$("#GuiaConsulta").serialize(),
		success: function(data){
			$("#tissplanosguia").html("<div class=\"col-md-2 qf\" id=\"qfplanoid\">" + data + "<div>");
		}
	})
}

$("#T, #ConvenioID").change(function(){
	$.ajax({
		type:"GET",
		url:"tissselectlote.asp?T="+$("#T").val()+"&ConvenioID="+$("#ConvenioID").val(),
		success:function(data){
			$("#selectLote").html(data);
		}
	});
});

function anexa(){
	$("#btnAnexa").css("visibility", "visible");
}
function retiraGuia(I) {
    n = $(".guia:checked").size();
    if(n==0){
        alert('Selecione as guias que deseja retirar do lote.');
    }else{
        if (confirm('Tem certeza de que deseja retirar esta guia deste lote?')) {
            location.href = "./?P=tissbuscaguias&Pers=1&T=<%=req("T")%>&ConvenioID=<%=req("ConvenioID")%>&LoteID=<%=req("LoteID")%>&NumeroGuia=<%=replace(req("NumeroGuia"),chr(13)&chr(10),"%0D%0A")%>&PacienteID=<%=req("PacienteID")%>&searchPacienteID=<%=req("searchPacienteID")%>&DataDe=<%=req("DataDe")%>&DataAte=<%=req("DataAte")%>&DataDePreenchimento=<%=req("DataDePreenchimento")%>&DataAtePreenchimento=<%=req("DataAtePreenchimento")%>&Retira=1&" + I;
        }
    }
}

function insereGuia(I) {
    $("#modal-table").modal("show");
    $.get("insereGuia.asp?T=<%=req("T")%>&TB=<%=tabela%>&ConvenioID=<%=req("ConvenioID")%>&G="+I, function(data){
        $("#modal").html(data);
    });
    $("#modal-table").modal("show");
}

$('td[id^=dvp]').click(function () {
    //alert('oi');
});

function glosa(T, I){
    $.post("Glosa.asp?T="+T+"&I="+I+"&TG=<%=req("T")%>", $(".guia").serialize(), function(data){
        eval(data);
    })
}


$(".guia, input[id^='all']").click(function(){

    var $btnAcaoGuias = $(".btn-acao-guias");
   
    if($(".guia:checked").length>0){
    $.post("lanctoGuias.asp?T=<%=req("T")%>", $(".guia").serialize(), function(data){
        $("#lanctoGuias").html(data);
    });
        $btnAcaoGuias.attr("disabled", false);
    }else{
        $btnAcaoGuias.attr("disabled", true);
        $("#lanctoGuias").html("");
    }
});

var lotes = [];
function getLotesSelecionados() {
    var $guias = $(".guia:checked");
    $guias.each(function(){
        var LoteID=$(this).parents("tr").find(".loteid_val").val();
        if($.inArray(LoteID, lotes)===-1){
            lotes.push(LoteID);
        }
    });
    return lotes.join(",");
}

function geraInvoice(T, V, Incrementar){
    $("#lanctoGuias").find("button").attr("disabled", true);
    var strIncrementar = "";
    if(Incrementar){
        strIncrementar="&Incrementar="+Incrementar;
    }

    $.post("LoteAReceber.asp?T="+T+"&V="+V+"&CriaInvoice=1&ConvenioID=<%=req("ConvenioID")%>&Lotes="+getLotesSelecionados()+strIncrementar, $(".guia").serialize(), function(data){
        eval(data);

        setTimeout(function(){
            $("#lanctoGuias").find("button").attr("disabled", false);
        }, 1000);
    });
}

$(document).ready(function(){
    let convenioId = '<%=req("ConvenioID")%>';
    if(convenioId != ''){
        tissplanosguia(convenioId)
    }
});

</script>