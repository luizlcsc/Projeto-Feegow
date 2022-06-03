<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="modulos/audit/AuditoriaUtils.asp"-->
<!--#include file="Classes/ServerPath.asp"-->

<%

PessoaID = req("I")
T = lcase(req("T"))
if T="profissionais" then
	NomeColuna = "NomeProfissional"
elseif T="funcionarios" then
	NomeColuna = "NomeFuncionario"
end if
set pnome = db.execute("select "&NomeColuna&" from "&T&" where id="&PessoaID)
if not pnome.eof then
	Nome = pnome(""&NomeColuna&"")
end if



if req("ExcluiRegra")<>"" then
	db_execute("delete from RegrasPermissoes where id = '"&req("ExcluiRegra")&"'")
	db_execute("delete from RegrasDescontos where RegraID = '"&req("ExcluiRegra")&"'")
end if

if req("DuplicarRegra")<>"" then
    set pr=db.execute("select * from regraspermissoes where id = '"&req("DuplicarRegra")&"'")
    NomeRegra = pr("Regra")&" (Cópia)"

    db.execute("INSERT INTO regraspermissoes (Regra, Permissoes, limitarecpag, LimitarContasPagar) VALUES ('"&NomeRegra&"', '"&pr("Permissoes")&"', '"&pr("limitarecpag")&"', '"&pr("LimitarContasPagar")&"')")

    %>
    <script type="text/javascript">
    new PNotify({
        title: 'Sucesso!',
        text: 'Regra duplicada com sucesso.',
        type: 'success',
        delay: 1500
    });
    </script>
    <%
end if

if req("AplicaRegra")<>"" then
	set pr=db.execute("select * from regraspermissoes where id = '"&req("AplicaRegra")&"'")
	if not pr.eof then

	    sqlAplicaRegra="update sys_users set RegraID="&pr("id")&", Permissoes='"&pr("Permissoes")&" ["&pr("id")&"]', limitarecpag='"& pr("limitarecpag") &"' where id = '"& req("UsId") &"'"

	    call registraEventoAuditoria("altera_permissionamento", req("UsId"), "Regra "&pr("Regra")&" aplicada")
        call gravaLogs(sqlAplicaRegra, "AUTO", "Regra "&pr("Regra")&" aplicada", "")
		db_execute(sqlAplicaRegra)
		%>
        <script type="text/javascript">
        new PNotify({
            title: 'Sucesso!',
            text: 'Regra aplicada.',
            type: 'success', 
            delay: 1500
        });
		</script>
		<%
	end if
end if

if ref("e")<>"" then
	if ref("Regra")<>"" then
		set veseha=db.execute("select * from RegrasPermissoes where Regra like '"&trim(replace(ref("Regra")&" ","'","''"))&"'")
		if veseha.eof then
		    sqlRegra = "insert into RegrasPermissoes (Regra,Permissoes) values ('"&trim(replace(ref("Regra")&" ","'","''"))&"','"&ref("Permissoes")&"')"
		    call gravaLogs(sqlRegra, "AUTO", "Regra criada", "")
			db_execute(sqlRegra)
			set veseha = db.execute("select * from RegrasPermissoes order by id desc limit 1")
			db_execute("update sys_users set OcultarLanctoParticular='"& ref("OcultarLanctoParticular") &"',limitarcontaspagar='"& ref("limitarcontaspagar") &"',Permissoes='"& ref("Permissoes")&" ["&veseha("id")&"]', limitarecpag='"& ref("limitarecpag") &"' where id="&ref("e"))
		else
		    updateRegra = "update RegrasPermissoes set Permissoes='"& ref("Permissoes")&"', limitarecpag='"& ref("limitarecpag") &"' where id = '"&veseha("id")&"'"
            call gravaLogs(updateRegra, "AUTO", "Regra alterada", "")
			db_execute(updateRegra)

			updateUsers = "update sys_users set Permissoes='"&ref("Permissoes")&" ["&veseha("id")&"]',limitarcontaspagar='"& ref("limitarcontaspagar") &"',OcultarLanctoParticular='"& ref("OcultarLanctoParticular") &"' limitarecpag='"& ref("limitarecpag") &"' where Permissoes like '%["&veseha("id")&"]%'"
            call gravaLogs(updateUsers, "AUTO", "Permissões alterada pela regra", "")
			db_execute(updateUsers)
		end if
	else
	    sqlUpdatePermissoes = "update sys_users set Permissoes='"&ref("Permissoes")&"', limitarcontaspagar='"& ref("limitarcontaspagar") &"',OcultarLanctoParticular='"& ref("OcultarLanctoParticular") &"' where id="&ref("e")

	    call registraEventoAuditoria("altera_permissionamento", ref("e"), "Permissões alteradas")
	    call gravaLogs(sqlUpdatePermissoes, "AUTO", "Permissões alteradas", "")

		db_execute(sqlUpdatePermissoes)
	end if
	%>

    <script type="text/javascript">
        new PNotify({
            title: 'Sucesso!',
            text: 'Permiss&otilde;es salvas.',
            type: 'success',
            delay: 2000
        });
	</script>
    <%
end if


set dadosUser = db.execute("select * from sys_users where `Table` like '"&req("T")&"' and idInTable="&req("I"))
if dadosUser.EOF then
	comAcesso = "N"
	nuncaAcessou = "S"
else
	PermissoesUsuario = dadosUser("Permissoes")
	set dadosAcesso = dbc.execute("select * from licencasusuarios where id="&dadosUser("id")&" and LicencaID="&replace(session("Banco"), "clinic", ""))
	if dadosAcesso.eof then
		comAcesso = "N"
	else
		if dadosAcesso("Email")="" then
			comAcesso="N"
		else
			comAcesso = "S"
			EmailAcesso = dadosAcesso("Email")
		end if
		UserID = dadosAcesso("id")
	end if
	if comAcesso="N" then
	%>
	<div class="panel">
        <div class="panel-body">
            Este usu&aacute;rio est&aacute; com seu acesso ao sistema desabilitado. Defina seu acesso na aba "Dados de Acesso". 
        </div>
	</div>
	<%
	end if
end if
%>
<style>
.pn{
padding-left: 0 !important;
}

.success th{
padding-left: 0!important;
}
.success th:first-child{
padding-left: 9px !important;
}

</style>

<%

if nuncaAcessou="S" or UserID="" then
	%><div class="clearfix form-actions">O acesso deste usu&aacute;rio ao sistema nunca foi habilitado, por isso suas permiss&otilde;es n&atilde;o podem ser alteradas. <br />
	Habilite o acesso na aba "Dados de Acesso", e em seguida defina suas permiss&otilde;es.</div><%
else
	set pstr=db.execute("select * from sys_users where id="&UserID)
	strP=pstr("Permissoes")
	%>
	
	<form method="post" name="frmPermissoes" id="frmPermissoes" action="">
	<input type="hidden" name="e" value="<%=UserID%>" />



    <div class="panel">
        <div class="panel-heading">
            <span class="title">Permissões de <%=Nome%></span>

            <button type="button" onclick="MostraLogsPermissoes()" class="btn btn-sm btn-default fright mt10" style="float: right">
                <i class="far fa-history"></i>
            </button>
        </div>
        <div class="panel-body">
            <div class="col-md-offset-10 col-md-2">
                <span class="checkbox-custom checkbox-alert  mn">
                   <input type="checkbox" class="ace" name="checkAll" id="checkAll" /> <label for="checkAll">Selecionar tudo</label>
                </span>
            </div>
            <br>
            <br>


            <table width="100%" class="table table-striped table-hover">
	          <%
			  currentVersionFolder = getCurrentVersion()

	          set lista=db.execute("select * from cliniccentral.sys_permissoes where Categoria != '' AND JSON_SEARCH(Versoes,'one','"&currentVersionFolder&"') IS NOT null order by Categoria,Acao")
	          while not lista.eof
		          if Categoria<>lista("Categoria") then
			        %><tr class="success">
				        <th><%=lista("Categoria")%></th>
                        <th>
                            <span class="checkbox-custom checkbox-primary mn">
                               <input type="checkbox" data-group="<%=lista("Categoria")%>" data-type="V" class="ace categoria-marcar-todos"  id="<%=lista("Categoria")%>V" /> <label for="<%=lista("Categoria")%>V">Visualizar</label>
                            </span>
                        </th>
                        <th>
                            <span class="checkbox-custom checkbox-success mn">
                               <input type="checkbox" data-group="<%=lista("Categoria")%>" data-type="I" class="ace categoria-marcar-todos"  id="<%=lista("Categoria")%>I" /> <label for="<%=lista("Categoria")%>I">Inserir</label>
                            </span>
                        </th>
                        <th>
                            <span class="checkbox-custom checkbox-warning mn">
                               <input type="checkbox" data-group="<%=lista("Categoria")%>" data-type="A" class="ace categoria-marcar-todos"  id="<%=lista("Categoria")%>A" /> <label for="<%=lista("Categoria")%>A">Alterar</label>
                            </span>
                        </th>
                        <th>
                            <span class="checkbox-custom checkbox-danger mn">
                               <input type="checkbox" data-group="<%=lista("Categoria")%>" data-type="E" class="ace categoria-marcar-todos"  id="<%=lista("Categoria")%>E" /> <label for="<%=lista("Categoria")%>E">Excluir</label>
                            </span>
                        </th>
			          </tr>
		  	        <%
		          end if
	          Categoria=lista("Categoria")
	          %>
	          <tr>
		        <td width="68%"><%=lista("Acao")%></td>
		        <td style="vertical-align:top" width="8%" class="text-left pn">
		          <%if lista("Visualizar")="s" then%>
                    <span class="checkbox-custom checkbox-primary mn">
                        <input class="ace checkbox-permissao" data-type="V" data-group="<%=lista("Categoria")%>" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>V" value="|<%=lista("Nome")%>V|"<%
		          if inStr(strP,"|"&lista("Nome")&"V|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>V"></label>
		          </span>
		        </td>

		        <td width="8%" class="text-left pn" style="vertical-align:top">
		          <%if lista("Inserir")="s" then%>
                    <span class="checkbox-custom checkbox-success mn">
                        <input class="ace checkbox-permissao" data-type="I" data-group="<%=lista("Categoria")%>" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>I" value="|<%=lista("Nome")%>I|" <%
		          if inStr(strP,"|"&lista("Nome")&"I|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>I"></label>
                    </span>
		        </td>

		        <td width="8%" class="text-left pn" style="vertical-align:top">
		          <%if lista("Alterar")="s" then%>
                    <span class="checkbox-custom checkbox-warning mn">
                        <input class="ace checkbox-permissao" data-type="A" data-group="<%=lista("Categoria")%>" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>A" value="|<%=lista("Nome")%>A|" <%
		          if inStr(strP,"|"&lista("Nome")&"A|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>A"></label>
                    </span>
		        </td>

		        <td width="8%" class="text-left pn" style="vertical-align:top">
		          <%if lista("Excluir")="s" then%>
                    <span class="checkbox-custom checkbox-danger mn">
                        <input class="ace checkbox-permissao" data-type="E" data-group="<%=lista("Categoria")%>" type="checkbox" name="Permissoes" id="<%=lista("Nome")%>X" value="|<%=lista("Nome")%>X|" <%
		          if inStr(strP,"|"&lista("Nome")&"X|")>0 then%> checked="checked"<%end if%> /><%end if%><label for="<%=lista("Nome")%>X"></label>
                    </span>
		        </td>
	          </tr>
	          <%
	          lista.movenext
	          wend
	          lista.close
	          set lista=nothing

	          limitarcontaspagar = dadosUser("limitarcontaspagar")
	          'limitarcontasreceber = dadosUser("limitarcontasreceber")
	          OcultarLanctoParticular = dadosUser("OcultarLanctoParticular")
	          %>
	          <tr>
                <td>Ocultar categorias contas a pagar</td>
                <td colspan="4"><%= quickfield("multiple", "limitarcontaspagar", "", 12,limitarcontaspagar, "select id, Name from sys_financialexpensetype", "Name", "") %></td>
              </tr>

              <tr>
                  <td>Ocultar lançamento de particular na conta do paciente</td>
                  <td colspan="4">
                      <%=quickField("simpleCheckbox", "OcultarLanctoParticular", "", "6", OcultarLanctoParticular, "", "", "")%>
                  </td>
              </tr>
	          <tr class="info">
		        <td>Se desejar utilizar estas mesmas permiss&otilde;es em outro usu&aacute;rio, d&ecirc; um nome a esta regra:</td>
		        <td colspan="2"><input type="text" name="Regra" class="form-control" placeholder="Nome da regra (opcional)" /></td>
		        <td colspan="2"><button class="btn btn-primary"><i class="far fa-save"></i> Salvar permiss&otilde;es</button></td>
	          </tr>
	        </table>
        </div>
    </div>
	
	</form>
    
    <div class="panel">
	<div class="panel-heading success">
        <span class="panel-title">Voc&ecirc; tamb&eacute;m pode aplicar uma das regras predefinidas abaixo</span>
        <span class="panel-controls">
            <button type="button" class="btn btn-primary btn-sm" onClick="editaRegra('N')"><i class="far fa-plus"></i>  Inserir Regra</button>
        </span>
	</div>
	<%
	set pr=db.execute("select * from regraspermissoes order by Regra")
	if not pr.eof then%>
    <div class="panel-body pn">
        <table width="100%" class="table table-striped">
        <%
	    while not pr.eof
	    %>
	    <tr>
        <td width="1%"><%if instr(PermissoesUsuario, "["&pr("id")&"]")>0 then%><i class="far fa-check green"></i><%end if%></td>
	    <td width="92%"><%=pr("Regra")%></td>
	    <td width="4%"><button type="button" class="btn btn-sm btn-default" onclick="ajxContent('Permissoes&T=<%=req("T")%>&DuplicarRegra=<%=pr("id")%>&UsId=<%=UserID%>', <%=req("I")%>, 1, 'divPermissoes');"><i class="far fa-copy"></i> Duplicar</button></td>
	    <td width="4%"><button type="button" class="btn btn-sm btn-info" onclick="ajxContent('Permissoes&T=<%=req("T")%>&AplicaRegra=<%=pr("id")%>&UsId=<%=UserID%>', <%=req("I")%>, 1, 'divPermissoes');"><i class="far fa-check"></i> Aplicar</button></td>
	    <td width="4%"><button type="button" class="btn btn-sm btn-success" onclick="editaRegra(<%=pr("id")%>)"><i class="far fa-edit"></i> Editar</button></td>
	    <td width="4%"><button type="button" class="btn btn-sm btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir esta regra de permissionamento?'))ajxContent('Permissoes&T=<%=req("T")%>&ExcluiRegra=<%=pr("id")%>', <%=req("I")%>, 1, 'divPermissoes');"><i class="far fa-remove"></i> Excluir</button></td></tr>
	    <%
	    pr.movenext
	    wend
	    pr.close
	    set pr=nothing
	    %></table>
    </div>
	  <%
	end if
	%>
	</div>
	
	<%
end if
%>
<script language="javascript">
$(document).ready(function(e) {
	$("#frmPermissoes").submit(function(){
		$.ajax({
			type:"POST",
			url:"Permissoes.asp?T=<%=req("T")%>&I=<%=req("I")%>",
			data:$("#frmPermissoes").serialize(),
			success:function(data){
				$("#divPermissoes").html(data);
			}
		});
		return false;
	});
});

$("#checkAll").click(function(){
		$(".checkbox-permissao,.categoria-marcar-todos").prop("checked", $(this).prop("checked"));
});

$(".categoria-marcar-todos").click(function(){
    var group = $(this).data("group");
    var type = $(this).data("type");

    $(".checkbox-permissao[data-group='"+group+"'][data-type='"+type+"']").prop("checked", $(this).prop("checked"))

});
	
function editaRegra(I){
	$("#modal-table").modal("show");
	$.post("EditaPermissoes.asp?I="+I+"&T=<%=req("T")%>&PessoaID=<%=req("I")%>", "", function(data, status){ $("#modal").html(data) });
}

<!--#include file="JQueryFunctions.asp"-->

function MostraLogsPermissoes() {
    openComponentsModal("LogPermissoes.asp", {I: '<%=UserID%>', R: 'sys_users'},"Log das permissões")
}

$('#tabelaParticular12V').click(function(){
	if($(this).is(':checked') == false){
   
	var id = "<%=req("I")%>"
			$.ajax({		
			method: "POST",
			url: "TabelaAutorization.asp",
			data: {autorization: "UpdateAll",id:id},
				function(data){
				SysUser = data;				
					UpdateAll(SysUser);
                }
			})
		
		}
	});

function UpdateAll(SysUser){
 $.ajax({		
			method: "POST",
			url: "TabelaAutorization.asp",
			data: {autorization:"UpdateAll",SysUser:SysUser},
				function(data){
					
			}
        })

}
</script>