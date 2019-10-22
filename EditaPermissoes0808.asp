<!--#include file="connect.asp"-->
<%
RegraID = req("I")
T = req("T")
PessoaID = req("PessoaID")

if RegraID<>"" and isnumeric(RegraID) then
	set pregra = db.execute("select * from regraspermissoes where id="&RegraID)
	if not pregra.eof then
		Regra = pregra("Regra")
		strP = pregra("Permissoes")
	end if
end if
%>

<form id="FormEditaPermissoes">
<div class="modal-header">
    <button class="bootbox-close-button close" type="button" data-dismiss="modal">×</button>
    <h4 class="modal-title"><i class="fa fa-lock"></i> Edição de Permissionamento</h4>
</div>
<div class="modal-body">
    <div class="row">
        <%=quickField("text", "Regra", "Nome da Regra", 6, Regra, "", "", " required")%>
        <div class="col-md-6">
        	<label>&nbsp;</label><br>
        	<button class="btn btn-primary pull-right btn-sm"><i class="fa fa-save"></i> Salvar</button>
        </div>
    </div>
    <hr>
    <div class="row">
    	<div class="col-md-12">
            <table width="100%" class="table table-striped table-hover">
              <%
              set lista=db.execute("select * from cliniccentral.sys_permissoes where not Categoria like '' order by Categoria,Acao")
              while not lista.eof
                  if Categoria<>lista("Categoria") then
                    %><tr class="success">
                        <th><%=lista("Categoria")%></th>
                        <th>Visualizar</th>
                        <th>Inserir</th>
                        <th>Alterar</th>
                        <th>Excluir</th>
                      </tr>
                    <%
                  end if
              Categoria=lista("Categoria")
              %>
	          <tr>
		        <td width="68%"><%=lista("Acao")%></td>
		        <td style="vertical-align:top" width="8%" class="text-center pn">
		          <%if lista("Visualizar")="s" then%>
                    <span class="checkbox-custom checkbox-primary mn">
                        <input type="checkbox" name="Permissoes" id="<%=lista("Nome")%>V2" value="|<%=lista("Nome")%>V|"<%
		          if inStr(strP,"|"&lista("Nome")&"V|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>V2"></label>
		          </span>
		        </td>

		        <td width="8%" class="text-center pn" style="vertical-align:top">
		          <%if lista("Inserir")="s" then%>
                    <span class="checkbox-custom checkbox-success mn">
                        <input class="ace" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>I2" value="|<%=lista("Nome")%>I|" <%
		          if inStr(strP,"|"&lista("Nome")&"I|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>I2"></label>
                    </span>
		        </td>

		        <td width="8%" class="text-center pn" style="vertical-align:top">
		          <%if lista("Alterar")="s" then%>
                    <span class="checkbox-custom checkbox-warning mn">
                        <input class="ace" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>A2" value="|<%=lista("Nome")%>A|" <%
		          if inStr(strP,"|"&lista("Nome")&"A|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>A2"></label>
                    </span>
		        </td>

		        <td width="8%" class="text-center pn" style="vertical-align:top">
		          <%if lista("Excluir")="s" then%>
                    <span class="checkbox-custom checkbox-danger mn">
                        <input class="ace" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>X2" value="|<%=lista("Nome")%>X|" <%
		          if inStr(strP,"|"&lista("Nome")&"X|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>X2"></label>
                    </span>
		        </td>
	          </tr>
              <%
              lista.movenext
              wend
              lista.close
              set lista=nothing
              %>
            </table>
        </div>
    </div>
</div>
<div class="modal-footer no-margin-top">
	<button class="btn btn-primary pull-right btn-sm"><i class="fa fa-save"></i> Salvar</button>
</div>
</form>

<script>
$("#FormEditaPermissoes").submit(function(){
	$.post("saveEditaPermissoes.asp?I=<%=RegraID%>&T=<%=T%>&PessoaID=<%=PessoaID%>", $(this).serialize(), function(data, status){ eval(data) });
	return false;
});
</script>