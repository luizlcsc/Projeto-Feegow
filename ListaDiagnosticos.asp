<!--#include file="connect.asp"-->
<!--#include file="ProntCompartilhamento.asp"-->
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

set pdiag = db.execute("select * from pacientesdiagnosticos where sysactive=1 and PacienteID="&PacienteID)

if pDiag.eof then
	%>
    Nenhum diagn&oacute;stico adicionado neste paciente.
    <%
else%>
    <table width="100%" class="table table-striped table-hover">
      <tbody>
        <%
        while not pdiag.eof
            urlbmj = getConfig("urlbmj")
            IF urlbmj <> "" THEN
                sqlBmj = " (SELECT GROUP_CONCAT(DISTINCT CONCAT('<BR><strong>BMJ:</strong> <a href=""[linkbmj]/',bmj.codbmj,'"" class=""badge badge-primary"">',if(bmj.PortugueseTopicTitle='0',bmj.TopicTitle,bmj.PortugueseTopicTitle),'</a>') SEPARATOR ' ') " &_
                        " FROM cliniccentral.cid10_bmj bmj" &_
                        " WHERE bmj.cid10ID = cliniccentral.cid10.id) as bmj_link "
            ELSE
                sqlBmj = " '' as bmj_link  "
            END IF
            sqlcid = "select *, "&sqlBmj&" from cliniccentral.cid10 where id="&pdiag("CidID")

            podever = True
            permissao = ""

            if session("User") <> pdiag("sysUser") then
                permissao = VerificaProntuarioCompartilhamento(session("User"), "Diagnostico", pdiag("id"))
            end if

            if permissao <> "" then
                permissaoSplit = split(permissao,"|")
                podever = permissaoSplit(0)
            end if

            if podever then
                set pcid = db.execute(sqlcid)
                if not pcid.EOF then
                    cid = pcid("Codigo")&": "&pcid("Descricao")&" "& pcid("bmj_link")
                    'response.write (cid)
                end if
                %>
                <tr>
                    <td><span class="label label-lg label-warning arrowed-in arrowed-right">Em <%=formatdatetime(pdiag("DataHora"),1)%>, &agrave;s <%=formatdatetime(pdiag("DataHora"),3)%></span><br><%=cid%><br>
                    <%=quickField("memo", "memo"&pdiag("id"), "", 12, pdiag("Descricao"), " memodiagnostico", "", " placeholder='Observa&ccedil;&otilde;es...'")%></td>
                    <td width="1%">
                    <% if recursoAdicional(37) = 4 then %>
                    <button style="margin-bottom: 10px" type="button" class="btn btn-xs btn-success" onclick="openCalculator(<%=pdiag("CidID")%>, <%=PacienteID%>)"><i class="far fa-calculator"></i></button>
                    <% end if %>
                    <button type="button" class="hidden btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este registro?'))cid10(<%=pdiag("id")%>);"><i class="far fa-trash"></i></button>
                </tr>
                <%
            end if
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


