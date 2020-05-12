<!--#include file="connect.asp"-->
<%
call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "& req("P") &" where id="&req("I"))


%>
<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Tabelas Particulares", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
    <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
    <div class="panel mt10">
        <div class="panel-body">
            <%= quickfield("text", "NomeTabela", "Nome da Tabela", 4, reg("NomeTabela"), "", "", "") %>
            <%= quickfield("empresaMultiIgnore", "Unidades", "Limitar Unidades", 4, reg("Unidades"), "", "", "") %>
            <div class="col-md-1">
                <label>
                    Ativo
                    <br />
                    <div class="switch round">
                        <input type="checkbox" <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                        <label for="Ativo">Label</label>
                    </div>
                </label>  
            </div>
            <div class="col-md-3">
                 <div class="checkbox-custom checkbox-primary">
                    <input type="checkbox" class="ace 1" name="ExibirAgendamentoOnline" id="ExibirAgendamentoOnline" value="1" <% if reg("ExibirAgendamentoOnline")="1" then %>checked<%end if%>>
                    <label class="checkbox" for="ExibirAgendamentoOnline"> Exibir no agendamento online</label>
                </div>  
            </div>
        </div>
    </div>
</form>

<script type="text/javascript">
$(document).ready(function(e) {
    <% if (reg("sysActive")=1 AND session("Franqueador") <> "") then %>
              $('#rbtns').prepend(`&nbsp;<button class="btn btn-dark btn-sm" type="button" onclick="replicarRegistro(<%=reg("id")%>,'<%=request.QueryString("P")%>')"><i class="fa fa-copy"></i> Replicar</button>`)
        <% end if %>
	<%call formSave("frm", "save", "")%>
});
</script>