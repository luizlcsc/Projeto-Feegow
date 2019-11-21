<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<!--#include file="modalTiss.asp"-->
<!--#include file="Classes\JSON.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Fechar Lote");
    $(".crumb-icon a span").attr("class", "fa fa-archive");
</script>
<%
Unidades = req("CompanyUnitID")
Planos = req("Planos")
Contratados = request.QueryString("Contratados")
Procedimentos =  req("Procedimentos")

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
                <select name="T" id="T" class="form-control" required>
                    <option value="">Selecione</option>
                    <option value="GuiaConsulta"<%if request.QueryString("T")="GuiaConsulta" then%> selected="selected"<%end if%>>Guia de Consulta</option>
                    <option value="GuiaSADT"<%if request.QueryString("T")="GuiaSADT" then%> selected="selected"<%end if%>>Guia de SP/SADT</option>
                    <option value="GuiaHonorarios"<%if request.QueryString("T")="GuiaHonorarios" then%> selected="selected"<%end if%>>Guia de Honorários</option>
                </select>
            </div>
            <%= quickField("simpleSelect", "ConvenioID", "Conv&ecirc;nio", 3, request.QueryString("ConvenioID"), "select * from Convenios where Ativo='on' and sysActive=1 order by NomeConvenio", "NomeConvenio", " empty="""" required=""required""") %>
            <%= quickField("datepicker", "DataDe", "Data do Preenchimento", 2, request.QueryString("DataDe"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAte", "&nbsp;", 2, request.QueryString("DataAte"), "", "", " placeholder='At&eacute;'") %>
            <div class="col-md-1">
                <label>&nbsp;</label><br />
                <button class="btn btn-md btn-primary"><i class="fa fa-search"></i> Buscar</button>
            </div>
            <div class="col-md-2">
                <label>&nbsp;</label><br />
                <button type="button" class="btn btn-md btn-success" onClick="fechalote()"><i class="fa fa-archive"></i> Fechar Lote</button>
            </div>
        </div>
        <br>
        <div class="row">
            <div class="col-md-2">
                <label>Ordenar por</label><br />
                <select name="OrdenarPor" id="OrdenarPor" class="form-control" required>
                    <option value="0">Data do preenchimento</option>
                    <option value="1" <%if request.QueryString("OrdenarPor")="1" then%> selected="selected"<%end if%>>Nome do paciente</option>
                    <option value="2" <%if request.QueryString("OrdenarPor")="2" then%> selected="selected"<%end if%>>Código na operadora</option>
                    <option value="3" <%if request.QueryString("OrdenarPor")="3" then%> selected="selected"<%end if%>>Data da solicitação</option>
                </select>
            </div>
            <div class="col-md-3">
                <label>Exibir nome do profissional</label><br />
                <select name="ExibirProfissional" id="ExibirProfissional" class="form-control" required>
                    <option value="0">Não exibir</option>
                    <option value="1" <%if request.QueryString("ExibirProfissional")="1" then%> selected="selected"<%end if%>>Profissional executante</option>
                </select>
            </div>
            <%= quickField("datepicker", "DataDeAtendimento", "Data do Atendimento", 2, request.QueryString("DataDeAtendimento"), "", "", " placeholder='De'") %>
            <%= quickField("datepicker", "DataAteAtendimento", "&nbsp;", 2, request.QueryString("DataAteAtendimento"), "", "", " placeholder='At&eacute;'") %>
            <%=quickField("empresaMultiIgnore", "CompanyUnitID", "Unidades", 3, Unidades, "", "", "")%>

        </div>
        <br>
        <div class="row">
            <%= quickField("simpleSelect", "GuiaStatus", "Status", 3, req("GuiaStatus"), "SELECT * FROM cliniccentral.tissguiastatus ORDER BY Status", "Status", " empty") %>
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

            <div class="col-md-2"><br>
                Guias encontradas: <span id="encontradas">0</span>.<br>
                Guias selecionadas: <span id="selecionadas">0</span>.
            </div>
        </div>

    </div>
    </div>
</form>

<div class="panel">
<div class="panel-body">
<form action="" method="post" id="guias" name="guias">
<%
response.buffer
c=0
ordenarPor = request.QueryString("OrdenarPor")
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

if request.QueryString("ConvenioID")<>"" and request.QueryString("T")="GuiaConsulta" then
	%>
    <table width="100%" class="table table-striped table-bordered">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if request.QueryString("ExibirProfissional") = "1" then
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


	if request.QueryString("DataDe")<>"" and isdate(request.QueryString("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(request.QueryString("DataDe"))&"'"
	end if
	if request.QueryString("DataAte")<>"" and isdate(request.QueryString("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(request.QueryString("DataAte"))&"'"
	end if

	if request.QueryString("DataDeAtendimento")<>"" and isdate(request.QueryString("DataDeAtendimento")) then
        sqlDataDeAtendimento = " and date(g.DataAtendimento)>='"&mydate(request.QueryString("DataDeAtendimento"))&"'"
    end if
    if request.QueryString("DataAteAtendimento")<>"" and isdate(request.QueryString("DataAteAtendimento")) then
        sqlDataAteAtendimento = " and date(g.DataAtendimento)<='"&mydate(request.QueryString("DataAteAtendimento"))&"'"
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

    sqlGuia = "select g.*, proc.NomeProcedimento from tissguiaconsulta g LEFT JOIN pacientes p ON p.id = g.PacienteID LEFT JOIN procedimentos proc ON proc.id = g.ProcedimentoID where g.sysActive=1"&sqlLote&sqlContratados&sqlPlanos&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlProcedimentos&" and g.ConvenioID="&request.QueryString("ConvenioID")&sqlUnidades &sqlStatusGuia &orderBy

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
                if request.QueryString("ExibirProfissional") = "1" then
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
elseif request.QueryString("ConvenioID")<>"" and request.QueryString("T")="GuiaHonorarios" then
	%>
    <table width="100%" class="table table-striped">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if request.QueryString("ExibirProfissional") = "1" then
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
	if request.QueryString("DataDe")<>"" and isdate(request.QueryString("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(request.QueryString("DataDe"))&"'"
	end if
	if request.QueryString("DataAte")<>"" and isdate(request.QueryString("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(request.QueryString("DataAte"))&"'"
	end if

    if req("GuiaStatus")<>"" and req("GuiaStatus")<>"0" then
        sqlStatusGuia = " and g.GuiaStatus="&req("GuiaStatus")
    end if

	if request.QueryString("DataDeAtendimento")<>"" and isdate(request.QueryString("DataDeAtendimento")) then
		sqlDataDeAtendimento = " and date(g.DataEmissao)>='"&mydate(request.QueryString("DataDeAtendimento"))&"'"
	end if
	if request.QueryString("DataAteAtendimento")<>"" and isdate(request.QueryString("DataAteAtendimento")) then
		sqlDataAteAtendimento = " and date(g.DataEmissao)<='"&mydate(request.QueryString("DataAteAtendimento"))&"'"
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

    sqlGuias = "select g.*, GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') NomeProcedimentos  from tissguiahonorarios g LEFT JOIN tissprocedimentoshonorarios tph ON tph.GuiaID=g.id LEFT JOIN procedimentos proc ON proc.id=tph.ProcedimentoID where g.sysActive=1"&sqlContratados&sqlPlanos&sqlLote&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlProcedimentos&" and g.ConvenioID="&request.QueryString("ConvenioID")&sqlUnidades &sqlStatusGuia & "GROUP BY g.id "&orderBy

	set guias = db.execute(sqlGuias)
	while not guias.EOF
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if


		'--> INICIO - Pegar o profissional executor da guia
        		if request.QueryString("ExibirProfissional") = "1" then
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
            if request.QueryString("ExibirProfissional") = "1" then
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
elseif request.QueryString("ConvenioID")<>"" and request.QueryString("T")="GuiaSADT" then
	%>
    <table width="100%" class="table table-striped table-bordered">
	<thead>
    	<tr>
        	<th><label><input type="checkbox" class="ace" id="marca"><span class="lbl"></span></label></th>
            <th nowrap>Data de Preenchimento</th>
            <%
            if request.QueryString("ExibirProfissional") = "1" then
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
	if request.QueryString("DataDe")<>"" and isdate(request.QueryString("DataDe")) then
		sqlDataDe = " and date(g.sysDate)>='"&mydate(request.QueryString("DataDe"))&"'"
	end if
	if request.QueryString("DataAte")<>"" and isdate(request.QueryString("DataAte")) then
		sqlDataAte = " and date(g.sysDate)<='"&mydate(request.QueryString("DataAte"))&"'"
	end if

	if req("GuiaStatus")<>"" and req("GuiaStatus")<>"0" then
        sqlStatusGuia = " and g.GuiaStatus="&req("GuiaStatus")
    end if

	if request.QueryString("DataDeAtendimento")<>"" and isdate(request.QueryString("DataDeAtendimento")) then
		sqlDataDeAtendimento = " and date(g.DataSolicitacao)>='"&mydate(request.QueryString("DataDeAtendimento"))&"'"
	end if
	if request.QueryString("DataAteAtendimento")<>"" and isdate(request.QueryString("DataAteAtendimento")) then
		sqlDataAteAtendimento = " and date(g.DataSolicitacao)<='"&mydate(request.QueryString("DataAteAtendimento"))&"'"
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

    sqlGuias = "select g.*, GROUP_CONCAT(NomeProcedimento SEPARATOR ', ') Procedimentos from tissguiasadt g LEFT JOIN pacientes p ON p.id = g.PacienteID LEFT JOIN tissprocedimentossadt tps ON tps.GuiaID=g.id LEFT JOIN procedimentos proc ON proc.id=tps.ProcedimentoID where g.sysActive=1"&sqlContratados&sqlLote&sqlDataDe&sqlDataAte&sqlDataDeAtendimento&sqlDataAteAtendimento&sqlPlanos&sqlProcedimentos&" and g.ConvenioID="&request.QueryString("ConvenioID")&sqlUnidades &sqlStatusGuia & " GROUP BY g.id "& orderBy
	set guias = db.execute(sqlGuias)

	while not guias.EOF
		set pac = db.execute("select NomePaciente from pacientes where id="&guias("PacienteID"))
		if pac.eof then
			NomePaciente = "<em>Paciente exclu&iacute;do</em>"
		else
			NomePaciente = pac("NomePaciente")
		end if

        '--> INICIO - Pegar o profissional executor da guia
		if request.QueryString("ExibirProfissional") = "1" then
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
        	if request.QueryString("ExibirProfissional") = "1" then
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
	var checados = $("input.guia:checked").length;
	if(checados==0){
		$.gritter.add({
			title: '<i class="fa fa-thumbs-down"></i> ERRO:',
			text: 'Selecione as guias para fechar o lote.',
			class_name: 'gritter-error gritter-light'
		});
	}else{
		$.ajax({
			type:"POST",
			url:"modalFechaLote.asp?T=<%=request.QueryString("T")%>&ConvenioID=<%=request.QueryString("ConvenioID")%>",
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

    changeConvenio("<%=request.QueryString("ConvenioID")%>")
    changeContratos("<%=request.QueryString("ConvenioID")%>")

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

    $('#Contratados').val([<%=request.QueryString("Contratados")%>]).multiselect({});
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

    $('#Planos').val([<%=request.QueryString("Planos")%>]).multiselect({});
}

jQuery(function() {
  $("table").dataTable({
      ordering: true,
      bPaginate: false,
      bLengthChange: false,
      bFilter: true,
      bInfo: false,
      bAutoWidth: false
  });
});
</script>