<!--#include file="connect.asp"-->
<!--#include file="Classes/Logs.asp"-->
<!--#include file="Classes/Permissoes.asp"-->
<%

call validatePrivatePage(1,"","")

'on error resume next

Acao = ref("Acao")
cold = ref("old")
CadastrarSinonimo = ref("CadastrarSinonimo")="S"
cnew = ref("new")

if Acao="" then
    Acao="VERIFICAR"
end if

%>
<script type="text/javascript">
        $(".crumb-active a").html("Mesclagem de recurso");
        $(".crumb-link").removeClass("hidden");
        $(".crumb-icon").html("<i class='fa fa-search'></i>");
        $("#sidebar-search").val("<%=q%>");
</script>
<br>
<form method="post" action="" id="form-mesclar">
	<div class="panel">
		<div class="panel-body">
			<div class="col-md-5">
				<%= selectInsert("Procedimento anterior (a ser apagado)", "old", cold, "procedimentos", "NomeProcedimento", "", "", "") %>
                <input type="checkbox" <% if CadastrarSinonimo then %>checked<%end if %> name="CadastrarSinonimo" value="S" id="CadastrarSinonimo"> <label for="CadastrarSinonimo">Cadastrar como sinônimo</label>
			</div>
			<div class="col-md-5">
				<%= selectInsert("Mesclar com (a ser mantido)", "new", cnew, "procedimentos", "NomeProcedimento", "", "", "") %>
			</div>
			<input type="hidden" name="Acao" id="Acao" value="<%=Acao%>">
			<div class="col-md-2"><button type="submit" class="btn btn-primary mt25"><i class="fa fa-search"></i> Encontrar registros </button>
		    </div>
	    </div>
	</div>
</form>
<%
if cold<>"" and cnew<>"" then
%>
<div class="panel">
    <div class="panel-body">
        <div class="col-md-12">

              <table class="table table-hover">
                <thead>
                    <tr class="primary">
                        <th></th>
                        <th>ID anterior</th>
                        <th>ID atualizado</th>
                        <th>Recurso</th>
                        <th>Coluna</th>
                        <th>Número de linhas</th>
                    </tr>
                </thead>
              <%
              EncontrouRegistros=False
              recurso = "procedimentos"

              	set cols = db.execute("SELECT i.COLUMN_NAME, i.TABLE_NAME, i.`COLUMN_DEFAULT`, i.`COLUMN_TYPE` FROM information_schema.`COLUMNS` i "&_
              	                      "WHERE i.TABLE_SCHEMA='"& session("Banco") &"' "&_
              	                      "AND (i.COLUMN_NAME IN ('id_procedimento','ProcedimentoID', 'ItemID', 'Procedimento', 'Procedimentos', 'TipoCompromissoID', 'ProcedimentosAgenda') OR i.COLUMN_NAME LIKE '%procedimento%')"&_
              	                      "AND i.TABLE_NAME NOT LIKE 'temp%' "&_
              	                      "AND i.TABLE_NAME NOT LIKE 'view%' "&_
              	                      "AND i.TABLE_NAME NOT LIKE 'vw%' "&_
              	                      "AND i.TABLE_NAME NOT LIKE 'procedimentos_unidades' "&_
              	                      "AND i.TABLE_NAME NOT LIKE 'somente_fornecedor_procedimento' "&_
              	                      "AND i.TABLE_NAME NOT LIKE 'somente_profissionais_procedimento' "&_
              	                      "LIMIT 200")

                if recurso = "procedimentos" and Acao="MESCLAR"  then
                    sqlatualizacao = "INSERT INTO registros_mesclados(tabela,de,para,sysUser) VALUES('procedimentos',"&cold&","&cnew&","&session("User")&")"
                    db.execute(sqlatualizacao)

                    db.execute("UPDATE registros_importados_franquia SET idOrigem="&cnew&" WHERE tabela = 'procedimentos' AND idOrigem = '"&cold&"'")

                    db.execute("UPDATE procedimentostabelasvalores SET TabelaID = TabelaID*-1  WHERE procedimentoId = "&cold)

                    db.execute("DROP TABLE IF EXISTS temp_procedimentostabelasvalores;")

                    db.execute("CREATE TEMPORARY TABLE temp_procedimentostabelasvalores "&_
                              "SELECT tabelaid,procedimentoid,COUNT(*) FROM procedimentostabelasvalores WHERE procedimentoId = "&cnew&"  AND tabelaid < 0 GROUP BY 1,2;")
                    db.execute("UPDATE procedimentostabelasvalores SET tabelaid = tabelaid*-1 WHERE (tabelaid,procedimentoid,1) in (SELECT * FROM temp_procedimentostabelasvalores )")

                    if CadastrarSinonimo then

                        set NomeProcedimentoAnteriorSQL = db.execute("SELECT NomeProcedimento FROM procedimentos WHERE id="&cold)

                        if not NomeProcedimentoAnteriorSQL.eof then
                            NomeProcedimentoAnterior = NomeProcedimentoAnteriorSQL("NomeProcedimento")
                        end if
                        sqlUpSinonimo="UPDATE procedimentos SET Sinonimo = CONCAT(IFNULL(Sinonimo,''),',"&NomeProcedimentoAnterior&"') "&_
                                      " WHERE id= "&cnew
                        db.execute(sqlUpSinonimo)
                    end if



                    db.execute("update procedimentos set sysActive=-1 where id="& cold)
                    'db.execute("insert into mesclar set Recurso='Procedimentos', idNew="& cnew &", idOld="& cold &", sysUser="& session("User"))
                    set somentes = db.execute("select * from procedimentos where id="& cold)
                    SomenteProfissionais = somentes("SomenteProfissionais")&""
                    SomenteFornecedor = somentes("SomenteFornecedor")&""
                    SomenteProfissionaisExterno = somentes("SomenteProfissionaisExterno")&""
                    SomenteEquipamentos = somentes("SomenteEquipamentos")&""
                    SomenteEspecialidades = somentes("SomenteEspecialidades")&""
                    SomenteLocais = somentes("SomenteLocais")&""
                    SomenteConvenios = somentes("SomenteConvenios")&""
                    db.execute("update procedimentos set SomenteProfissionais=concat(ifnull(SomenteProfissionais, ''), '"&SomenteProfissionais&"'), SomenteFornecedor=concat(ifnull(SomenteFornecedor, ''), '"&SomenteFornecedor&"'), SomenteProfissionaisExterno=concat(ifnull(SomenteProfissionaisExterno, ''), '"&SomenteProfissionaisExterno&"'), SomenteEquipamentos=concat(ifnull(SomenteEquipamentos, ''), '"&SomenteEquipamentos&"'), SomenteEspecialidades=concat(ifnull(SomenteEspecialidades, ''), '"&SomenteEspecialidades&"'), SomenteLocais=concat(ifnull(SomenteLocais, ''), '"&SomenteLocais&"'), SomenteConvenios=concat(ifnull(SomenteConvenios, ''), '"&SomenteConvenios&"') where id="& cnew)
                end if

              	while not cols.eof
              		'if cols("")
              		columnType = cols("COLUMN_TYPE")
              		columnName = cols("COLUMN_NAME")
              		tableName = cols("TABLE_NAME")
                      newValor = ""
                      oldValor = ""

              		if left(columnType, 3)="int" or columnType="float" then
              		    newValor = treatvalzero(cnew)
              		    oldValor = treatvalzero(cold)
                        queryUp = " `"& columnName &"`="& newValor &" "
              		    where = "`"&columnName&"`="&oldValor
              		end if

              		if left(columnType, 7)="varchar" or columnType="text" then
              		    newValor = cnew
              		    oldValor = cold
                        queryUp = "`"& columnName &"`=REPLACE(IFNULL("& columnName &",'') , '|"& oldValor &"|', '|"& newValor &"|') "
              		    where = "`"&columnName&"` LIKE '%|"&oldValor&"|%'"
              		end if

                    sqlSelect = "SELECT COUNT(1)Qtd FROM `"& tableName &"` WHERE "&where
                    'response.write( sqlSelect &"<br>")
                    set QtdSQL = db.execute(sqlSelect)
                      QtdLinhas = 0

                    if not QtdSQL.eof then

                        QtdLinhas = ccur(QtdSQL("Qtd"))

                        if QtdLinhas > 0 then
                            EncontrouRegistros=True
                        %>
                        <tr>
                            <td>
                                <%
                                if Acao="VERIFICAR" then
                                    %>
                                    <i class="fa fa-exclamation-circle" style="color: orange;"></i>
                                    <%
                                else
                                    %>
                                    <i class="fa fa-check-circle" style="color: green;"></i>
                                    <%
                                end if
                                %>
                            </td>
                            <td><code><%=cold%></code></td>
                            <td><code><%=cnew%></code></td>
                            <td><%=tableName%></td>
                            <td><%=columnName%></td>
                            <td><%=QtdLinhas%></td>
                        </tr>
                        <%
                        end if
                    end if

                    if Acao="MESCLAR" and newValor<>"" then
                        sqlUp = "UPDATE `"& tableName &"` set "& queryUp &" WHERE "&where
                        'response.write( sqlUp &"<br>")
                        db.execute(sqlUp)
                    end if

              	cols.movenext
              	wend
              	cols.close
              	set cols = nothing



              if not EncontrouRegistros then
                %>
                <tfoot>
                    <tr>
                        <th class="text-center" colspan="5">Nenhum registro encontrado.</th>
                    </tr>
                </tfoot>
                <%
              else
                if Acao="MESCLAR" then
                    call createLog("E", cold, recurso, "|ID|", "|^"&cold&"|^", "|^"&cnew&"|^", "Mesclagem de recurso ("&recurso&")")
                end if
              end if
              %>
              </table>
            <div class="pull-right">
                <button onclick="AtualizarRecursos()" type="button" class="btn btn-warning mb15">
                    <i class="fa fa-exclamation-circle"></i>
                    Atualizar registros
                </button>
            </div>
        </div>
    </div>
</div>
<%
end if
%>
<script >
<%
if Acao="MESCLAR" then
%>
$(document).ready(function() {

    $("#Acao").val("VERIFICAR");
    showMessageDialog("Registros atualizados com sucesso.", "success");
});
<%
end if
%>
function AtualizarRecursos() {
  if(confirm("Tem certeza que deseja atualizar estes registros?")){
    $("#Acao").val("MESCLAR");
    $("#form-mesclar").submit();
  }
}
</script>