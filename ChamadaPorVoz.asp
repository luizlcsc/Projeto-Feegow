<!--#include file="connect.asp"-->
<%
sql = "select * from sys_chamadaporvoz"
set reg = db.execute(sql)
if reg.eof then
	db_execute("insert into sys_chamadaporvoz (Texto, Sexo, Usuarios) values ('[TratamentoProfissional] [NomeProfissional] chama paciente [NomePaciente] para atendimento', '2', 'ALL')")
	set reg = db.execute(sql)
end if

if ref("E")="E" then
	db_execute("update sys_chamadaporvoz set Texto='"&ref("Texto")&"', Sexo='"&ref("Sexo")&"', Usuarios='"&ref("Usuarios")&"'")
else
%>
<script type="text/javascript">
    $(".crumb-active a").html("Configuração de Chamada de Pacientes por Voz");
    $(".crumb-icon a span").attr("class", "far fa-<%=dIcone("chamadaporvoz")%>");
    <%
    'if aut("lancamentosI")=1 then
    %>
    $("#rbtns").html('<button type="button" onClick="salvarChamada();" class="btn btn-sm btn-primary">&nbsp;&nbsp;<i class="far fa-save"></i> <strong>SALVAR</strong>&nbsp;&nbsp;</button>');
    <%
    'end if
    %>
</script>
<br>
<div class="panel">
<div class="panel-body">
            <form method="post" id="frm" name="frm" action="ChamadaPorVoz.asp">
            <input type="hidden" name="E" value="E">

 
                <div class="row">
                    <div class="col-md-6">
                        <div class="row">
                            <p style="padding-left: 10px"><strong>Texto a ser falado</strong></p>
                            <%=quickField("memo", "Texto", "", 12, reg("Texto"), "", "", " rows=6 required")%>
                            <br>
                            <div class="clearfix form-actions alert alert-primary">
                            <small><em>Obs.: O sistema ler&aacute; o texto acima toda vez que o paciente for chamado atrav&eacute;s da <strong>Lista de Espera</strong> para atendimento. As tags ser&atilde;o substitu&iacute;das pelos dados do cadastro no momento da leitura do texto pelo sistema. <br><br>
<strong>Veja o que as tags significam:</strong><br>
<strong>[TratamentoProfissional]</strong> &raquo; Ex.: Dr., Dra., Sr., Sra.<br>
<strong>[NomeProfissional]</strong> &raquo; Nome do profissional que est&aacute; chamando<br>
<strong>[NomePaciente]</strong> &raquo; Nome do paciente que est&aacute; sendo chamado<br />
<strong>[NomeLocal]</strong> &raquo; Nome do local do agendamento<br>
</em></small></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <input type="hidden" name="Sexo" value="2">
                        <p style="padding-left: 10px"><strong>Quais usu&aacute;rios ouvir&atilde;o as chamadas?</strong></p>

                        <div class="col-md-10" style="margin-top: 8px">
                            <select multiple="" class=" multisel tag-input-style" id="Usuarios" name="Usuarios">
                                <option value="|ALL|" <%if instr(reg("Usuarios"), "ALL")>0 then response.write("selected") end if %>>Todos</option>
                                <%
                                set pus = db.execute("select u.*, p.NomeProfissional, f.NomeFuncionario from sys_users as u left join profissionais as p on (p.id=u.idInTable and u.Table='Profissionais' AND p.Ativo='on') left join funcionarios as f on (f.id=u.idInTable and u.Table='Funcionarios' AND f.Ativo='on') order by u.NameColumn, f.NomeFuncionario, p.NomeProfissional")
                                while not pus.eof
                                    NomeColuna = pus("NameColumn")
                                    if not isnull(pus(""&NomeColuna&"")) then
                                        %>
                                        <option value="|<%=pus("id")%>|"<%if instr(reg("Usuarios"), "|"&pus("id")&"|")>0 then%> selected="selected"<%end if%>><%=pus(""&NomeColuna&"")%> &raquo; <%=pus("Table")%></option>
                                        <%
                                    end if
                                pus.movenext
                                wend
                                pus.close
                                set pus=nothing
                                %>
                                </select>
                            </div>
                        </div>
                    </div>
            </form>

</div>
</div>

<script language="javascript">
function salvarChamada(){
	$.ajax({
		   type:"POST",
		   url:"ChamadaPorVoz.asp",
		   data:$("#frm").serialize(),
		   success:function(data){
                new PNotify({
                    type:'success',
                    title:'Salvo!',
                    text:'Atualizado com sucesso...',
                    delay:1000
                });
		   }
	});
}
</script>
<%end if%>
<!--#include file="disconnect.asp"-->