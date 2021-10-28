<!--#include file="connect.asp"-->
<%
Valor1 = 79
Valor2 = 78
Valor3 = 77


if ref("X")<>"" then
	if ref("T")="P" then
		tableName="profissionais"
	else
		tableName="funcionarios"
	end if
	db_execute("delete from "&tableName&" where id="&ref("X"))
	if lcase(tableName)="funcionarios" or lcase(tableName)="profissionais" then
		set userX = db.execute("select * from sys_users where idInTable="&ref("X")&" and `Table`like '"&tableName&"'")
		if not userX.eof then
			db_execute("delete from sys_Users where id="&userX("id"))
			db_execute("delete from cliniccentral.licencasusuarios where id="&userX("id")&" and LicencaID="&replace(session("Banco"), "clinic", ""))
		end if
	end if
end if

if ref("Acao")="Inserir" then
	if ref("T")="P" then
		tableName = "profissionais"
		columnName = "NomeProfissional"
	else
		tableName = "funcionarios"
		columnName = "NomeFuncionario"
	end if
	db_execute("insert into "&tableName&" ("&columnName&", sysActive, sysUser, Ativo) values ('"&ref("Nome")&"', 1, "&session("User")&", 'on')")
end if

set c = db.execute("select (select count(*) from profissionais where sysActive=1) p, 0 f")
f=ccur(c("f"))
p = ccur(c("p"))

Qtd = p+f
if Qtd<10 then
	Valor = Valor1
elseif Qtd>=10 and Qtd<20 then
	Valor = Valor2
else
	Valor = Valor3
end if

SubtotalF = Valor * f
SubtotalP = Valor * p
%>
	<div class="row">
        <div class="col-md-6">
            <table class="table">
                <thead>
                    <tr>
                        <th width="73%"> &nbsp;&nbsp; <i class="far fa-user-md blue"></i> Profissionais de saúde<br>
<small class="grey lighter">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &raquo; Ex.: médicos, dentistas, psicólogos, etc.</small></th>
                        <th colspan="2" width="27%" class="text-center" nowrap>
                        	<button type="button" class="btn btn-sm btn-primary btn-block" onClick="inserir('P')"><i class="far fa-plus"></i> Inserir</button>
                        </th>
                    </tr>
                </thead>
                <tbody>
                <%
				set u = db.execute("select p.*, lu.Admin from profissionais p left join sys_users u on u.idInTable=p.id and `Table`='profissionais' left join cliniccentral.licencasusuarios lu on lu.id=u.id and lu.LicencaID="&replace(session("banco"), "clinic", "")&" where sysActive=1 order by NomeProfissional")
				while not u.eof
					%>
                    <tr>
                        <td><%= u("NomeProfissional")&u("Admin") %></td>
                        <td nowrap class="text-right">R$ <%=formatnumber(Valor ,2)%></td>
                        <td><button title="Excluir" onClick="conf(<%=u("id")%>, 'P')" type="button"<% If u("Admin")=1 Then %> disabled<% End If %> class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <%
				u.movenext
				wend
				u.close
				set u=nothing
				%>
				</tbody>
                <tfoot>
                	<tr>
                    	<td><strong>Subtotal</strong></td>
                        <td nowrap class="text-right"><strong>R$ <%= formatnumber(SubtotalP, 2) %></strong></td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="col-md-6">
            <table class="table">
                <thead>
                    <tr>
                        <th width="73%"> &nbsp;&nbsp; <i class="far fa-user blue"></i> Funcionários<br>
<small class="grey lighter">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &raquo; Ex.: secretárias, recepcionistas, faturistas, etc.</small></th>
                        <th colspan="2" width="27%" class="text-center" nowrap>
                        	<button type="button" class="btn btn-sm btn-primary btn-block" onClick="inserir('F')"><i class="far fa-plus"></i> Inserir</button>
                        </th>
                    </tr>
                </thead>
                <tbody>
                <%
				set u = db.execute("select f.*, lu.Admin from funcionarios f left join sys_users u on u.idInTable=f.id and `Table`='funcionarios' left join cliniccentral.licencasusuarios lu on lu.id=u.id and lu.LicencaID="&replace(session("banco"), "clinic", "")&" where sysActive=1 order by NomeFuncionario")
				while not u.eof
					%>
                    <tr>
                        <td><%= u("NomeFuncionario")&u("Admin") %></td>
                        <td><button title="Excluir" onClick="conf(<%=u("id")%>, 'F')" type="button"<% If u("Admin")=1 Then %> disabled<% End If %> class="btn btn-xs btn-danger"><i class="far fa-remove"></i></button></td>
                    </tr>
                    <%
				u.movenext
				wend
				u.close
				set u=nothing
				%>
				</tbody>
                <tfoot>
                	<tr>
                    	<td></td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>
    <div class="alert alert-block alert-success">
        <h4 class="text-right" style="margin:10px"><input type="hidden" name="Funcionarios" value="<%= f %>"><input type="hidden" name="Profissionais" value="<%= p %>"><input type="hidden" name="Valor" value="<%= formatnumber(SubtotalP+SubtotalF, 2) %>">Investimento mensal: R$ <%= formatnumber(SubtotalP+SubtotalF, 2) %></h4>
    </div>

<script>
function conf(X, T){
	bootbox.dialog({
		message: "<strong class='red'><i class='far fa-warning'></i> Tem certeza de que deseja excluir este usu&aacute;rio?</strong>",
		buttons: 			
		{
			"success" :
			 {
				"label" : "<i class='icon-ok'></i> CONFIRMAR",
				"className" : "btn-sm btn-primary",
				"callback": function() {
					$.post("ContratarUsuarios.asp", {X:X, T:T}, function(data, status){ $("#divUsuarios").html(data) });
				}
			},
			"danger" :
			{
				"label" : "CANCELAR",
				"className" : "btn-sm",
				"callback": function() {
					//Example.show("uh oh, look out!");
				}
			}
		}
	});
}
function inserir(T) {
	if(T=='P'){
		nome = 'profissional';
	}else{
		nome = 'funcion&aacute;rio';
	}
	bootbox.prompt("Qual o nome do "+nome+"?", function(result) {
		if (result === null) {
			//Example.show("Prompt dismissed");
		} else {
			$.post("ContratarUsuarios.asp", {Nome:result, T:T, Acao:'Inserir'}, function(data, status){ $("#divUsuarios").html(data) });
		}
	});
}

<!--#include file="jQueryFunctions.asp"-->
</script>