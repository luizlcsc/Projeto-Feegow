<!--#include file="connect.asp"-->
<%
if PacienteID="" then
    PacienteID = req("PacienteID")
end if
if req("CID")<>"" then

    'inclusão do atendimentoID se houver atendimento em curso
    'verifica se tem atendimento aberto
    set atendimentoReg = db.execute("select * from atendimentos where PacienteID="&PacienteID&" and sysUser = "&session("User")&" and HoraFim is null and Data = date(now())")
    if(atendimentoReg.EOF) then
	    db_execute("insert into pacientesdiagnosticos (PacienteID, CidID, sysUser) values ('"&PacienteID&"', '"&req("CID")&"', '"&session("User")&"')")
    else
        'salva com id do atendimento
        db_execute("insert into pacientesdiagnosticos (PacienteID, CidID, sysUser, AtendimentoID) values ('"&PacienteID&"', '"&req("CID")&"', '"&session("User")&"', "&atendimentoReg("id")&")")
    end if

end if
if req("X")<>"" and req("X")<>"0" then
	db_execute("delete from pacientesdiagnosticos where id="&req("X"))
end if

set pdiag = db.execute("select * from pacientesdiagnosticos where PacienteID="&PacienteID)

if pDiag.eof then
	%>
    Nenhum diagn&oacute;stico adicionado neste paciente.
    <%
else%>
    <table width="100%" class="table table-striped table-hover">
      <tbody>
        <%
        while not pdiag.eof
            set pcid = db.execute("select * from cliniccentral.cid10 where id="&pdiag("CidID"))
            if not pcid.EOF then
                cid = pcid("Codigo")&": "&pcid("Descricao")
            end if
            %>
            <tr>
                <td><span class="label label-lg label-warning arrowed-in arrowed-right">Em <%=formatdatetime(pdiag("DataHora"),1)%>, &agrave;s <%=formatdatetime(pdiag("DataHora"),3)%></span><br><%=cid%><br>
				<%=quickField("memo", "memo"&pdiag("id"), "", 12, pdiag("Descricao"), " memodiagnostico", "", " placeholder='Observa&ccedil;&otilde;es...'")%></td>
                <td width="1%">
                <% if recursoAdicional(37) = 4 then %>
                <button style="margin-bottom: 10px" type="button" class="btn btn-xs btn-success" onclick="openCalculator(<%=pdiag("CidID")%>, <%=PacienteID%>)"><i class="fa fa-calculator"></i></button>
                <% end if %>
                <button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este registro?'))cid10(<%=pdiag("id")%>);"><i class="fa fa-trash"></i></button>
            </tr>
            <%
        pdiag.movenext
        wend
        pdiag.close
        set pdiag = nothing
        %>
      </tbody>
    </table>
<%end if%>
<script type="text/javascript">
$(".memodiagnostico").change(function(){
	$.post("saveDiagnostico.asp?PacienteID=<%=PacienteID%>",{
		   Descricao: $(this).val(),
		   DiagnosticoID: $(this).attr("id")
		   },function(data,status){
	  //$("#ListaCID").html(data);
	});
});

 function openCalculator(cid, patientId) {
    const authToken = localStorage.getItem("tk");

    var iframe = `<iframe width="100%" height="100%" frameborder="0" scrolling="no" src="https://tnm.feegow.com/?patientId=${patientId}&cid=${cid}&tk=${authToken}"></iframe>`;
    $("#modal-calculator-content").html(iframe);
    $("#modal-calculator").modal("show");
}
</script>


