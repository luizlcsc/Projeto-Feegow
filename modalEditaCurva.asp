<!--#include file="connect.asp"-->
<%
FormPID = req("FormPID")
CampoID = req("CampoID")
ModeloID = req("ModeloID")
PacienteID = req("PacienteID")
Action = req("Action")
idAction = req("ID")
set pCampo = db.execute("select * from buicamposforms where id="&CampoID)
if not pCampo.EOF then
	ValorPadrao = pCampo("ValorPadrao")
	if ValorPadrao="Crescimento" then
		Titulo = "Altura (cm)"
	elseif ValorPadrao="Cefalico" then
		Titulo = "Medida (cm)"
	elseif ValorPadrao="Peso" then
		Titulo = "Peso (kg)"
	end if
end if
if FormPID="N" then
	FormPID = newForm(ModeloID, PacienteID)
		%>
    	<script>
		$("#FormID").val(<%=FormPID%>);
		</script>
		<%
end if
set pac = db.execute("select NomePaciente, Nascimento from pacientes where id="&PacienteID)
if not pac.eof then
	NomePaciente = pac("NomePaciente")
	IdadePaciente = idade(pac("Nascimento"))
	Nascimento = pac("Nascimento")
end if
if Action<>"" then
	set vals = db.execute("select * from buicurva where FormPID="&FormPID&" and CampoID="&CampoID)
	while not vals.eof
		db_execute("update buicurva set Meses="&treatvalzero(ref("meses"&vals("id")))&", Valor="&treatvalnull(ref("valor"&vals("id")))&" where id="&vals("id"))
		%>
        <script>
		$("#frm<%=CampoID%>").attr("src", "Curva.asp?CampoID=<%= CampoID %>&FormPID=<%= FormPID %>");
		//document.getElementById('frm<%=CampoID%>').contentWindow.location.reload();
		</script>
		<%
	vals.movenext
	wend
	vals.close
	set vals = nothing
end if
if Action="Add" then
	if not isnull(Nascimento) and isdate(Nascimento) then
		Meses = datediff("m", Nascimento, date())
	end if
	db_execute("insert into `buicurva` (CampoID, FormPID, PacienteID, Meses, sysUser) values ("&CampoID&", "&FormPID&", "&PacienteID&", "&treatvalzero(Meses)&", "&session("User")&")")
    db.execute("update buiformspreenchidos set sysActive=1 where id="& FormPID)
end if
if Action="Remove" then
	db_execute("delete from buicurva where id="&idAction)
end if
if Action="Save" then
	%>
	<script>
	$("#modal-table").modal("hide");
	</script>
	<%
end if
%>
<form id="formCurva">
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><%=NomePaciente%><small class="blue"> &raquo; <%=IdadePaciente%></small></h4>
</div>
<div class="modal-body">
    <div class="row">
        <div class="col-md-12">
            <button type="button" class="btn btn-primary pull-right btn-xs" onClick="reg('Add', 0)"><i class="far fa-plus"></i> Inserir Registro</button>
        </div>
    </div>
    <hr>
	<table class="table table-striped table-bordered table-hover">
    	<thead>
          <tr>
        	<th>Idade (meses)</th>
            <th><%=Titulo%></th>
            <th>Informado por</th>
            <th>Data</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
        <%
		set vals = db.execute("select * from buicurva where FormPID="&FormPID&" and CampoID="&CampoID&" order by Meses")
		while not vals.eof
'			if isnull(vals("Valor")) then
'				Valor = "0,00"
'			else
'				Valor = formatnumber(vals("Valor"), 2)
'			end if
			Valor = vals("Valor")
		  %>
          <tr>
        	<td><input class="form-control text-center" type="number" name="meses<%=vals("id")%>" id="meses<%=vals("id")%>" value="<%= vals("Meses") %>"></td>
        	<td>
            <%
			if ValorPadrao="Crescimento" or ValorPadrao="Cefalico" then
				%>
            	<input class="form-control text-center" type="text" name="valor<%=vals("id")%>" id="valor<%=vals("id")%>" value="<%= Valor %>">
            	<%
			elseif ValorPadrao="Peso" then
				if not isnull(Valor) then
					Valor=formatnumber(Valor, 2)
				end if
				%>
				<input class="form-control text-right input-mask-brl" type="text" name="valor<%=vals("id")%>" id="valor<%=vals("id")%>" value="<%= Valor %>">
				<%
			end if
			%>
            </td>
            <td><%= nameInTable(vals("sysUser")) %></td>
            <td><%= vals("sysDate") %></td>
            <td width="1%"><button onClick="reg('Remove', <%=vals("id")%>)" type="button" class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></td>
          </tr>
          <%
		vals.movenext
		wend
		vals.close
		set vals = nothing
		%>
        </tbody>
    </table>
</div>
<div class="modal-footer no-margin-top">
    <button type="button" onClick="reg('Save', 0)" class="btn btn-sm btn-success pull-right">
        <i class="far fa-save"></i>
        Salvar
    </button>
    
</div>
</form>
<script>
function reg(Action, ID){
	$.post("modalEditaCurva.asp?FormPID=<%=FormPID%>&ModeloID=<%= ModeloID %>&CampoID=<%= CampoID %>&PacienteID=<%= PacienteID %>&Action="+Action+"&ID="+ID, $("#formCurva").serialize(), function(data, status){ $("#modal").html(data) });
}
<!--#include file="jQueryFunctions.asp"-->
</script>
<!--#include file="disconnect.asp"-->