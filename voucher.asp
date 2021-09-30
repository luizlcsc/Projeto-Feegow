<!--#include file="connect.asp"-->
<%
'permissao
'campo dentro do financeiro
'na conta do paciente ou no site
'aparecer no caixinha que houve voucher
'relatório voucher utilizado
'por grupo, pacote e procedimento
'motivo de emissão estruturado
call insertRedir(request.QueryString("P"), request.QueryString("I"))
TableName = request.QueryString("P")
sqlReg = "select * from "&request.QueryString("P")&" where id="&request.QueryString("I")
set reg = db.execute(sqlReg)
if not reg.eof then
    Codigo = reg("Codigo")
	Tabelas = reg("Tabelas")
	Limitar = reg("Limitar")
	Unidades = reg("Unidades")
	De = reg("De")
	Ate = reg("Ate")
	Valor = reg("Valor")
	TipoValor = reg("TipoValor")
	GruposProcedimentos = reg("GruposProcedimentos")
    Procedimentos = reg("Procedimentos")
	Pacotes = reg("Pacotes")
	MotivoID = reg("MotivoID")
	Descricao = reg("Descricao")
end if
%>
<form method="post" id="frm" name="frm" action="save.asp">
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />
    <button style="display: none" id="submitFrm"></button>

    <div class="panel mt25">
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "Codigo", "Código do Voucher", 2, Codigo, "", "", " required ") %>
                <%= quickfield("multiple", "Tabelas", "Tabelas", 2, Tabelas, "select * from tabelaparticular where Ativo='on' order By NomeTabela", "NomeTabela", "") %>
                <%= quickfield("number", "Limitar", "Limitar", 1, Limitar, "", "", "") %>
                <%= quickfield("empresaMultiIgnore", "Unidades", "Unidades", 3, Unidades, "", "", " rows=3 ") %>
                <%= quickfield("datepicker", "De", "De", 2, De, "", "", "") %>
                <%= quickfield("datepicker", "Ate", "Até", 2, Ate, "", "", "") %>
            </div>
            <div class="row mt20">
                <div class="col-md-3">
                    <label>Valor do Voucher</label><br />
                    <div class="input-group">
                        <%=quickField("text", "Valor", "", 12, fn(Valor), " input-mask-brl text-right", "", " required ")%>
                        <span class="input-group-addon">
                            <select class="select-group" name="TipoValor">
                                <option value="P"<% If TipoValor="P" Then %> selected<% End If %>>%</option>
                                <option value="V"<% If TipoValor="V" Then %> selected<% End If %>>R$</option>
                            </select>
                        </span>
                    </div>
                </div>
                <%= quickfield("multiple", "GruposProcedimentos", "Grupos de Procedimento", 3, GruposProcedimentos, "select * from procedimentosgrupos where sysActive=1 ORDER BY NomeGrupo", "NomeGrupo", "") %>
                <%= quickfield("multiple", "Pacotes", "Pacotes", 3, Pacotes, "select * from pacotes where sysActive=1 ORDER BY NomePacote", "NomePacote", "") %>
                <div class="col-md-3">
                    <label>Procedimentos <br></label>
                    <%= quickField("multipleModal", "Procedimentos", "Procedimentos", "width", Procedimentos, "select * from procedimentos where ativo='on' Order By NomeProcedimento", "NomeProcedimento", "") %>
                </div>
            </div>
            <hr class="short alt">
            <div class="row">
                <div class="col-md-6">
                <label>Tipo de Campanha </label><br>
                <%
                set mot = db.execute("select * from cliniccentral.campanha_tipo WHERE sysActive=1")
                while not mot.eof
                    %>
                    <div class="radio-custom radio-primary">
                        <input type="radio" id="MotivoID<%= mot("id") %>" name="MotivoID" value="<%= mot("id") %>" <%if MotivoID=mot("id") then response.write(" checked ") end if %> ><label for="MotivoID<%= mot("id") %>" class="radio"> <%= mot("TipoCampanha") %></label>
                    </div>
                    <%
                mot.movenext
                wend
                mot.close
                set mot = nothing
                %>
                </div>
                <%= quickfield("memo", "Descricao", "Descrição", 6, Descricao, "", "", " rows=8 ") %>
            </div>
        </div>
    </div>
</form>


<script type="text/javascript">
    $(".crumb-active a").html("Cadastro de Voucher");
    $(".crumb-link").removeClass("hidden");
    $(".crumb-link").html("para aplicação de descontos");
    $(".crumb-icon a span").attr("class", "fa fa-money");
	<%call formSave("frm", "save", "")%>

    $("#rbtns").html(`<button class="btn btn-primary btn-sm" onclick="$('#submitFrm').click()"> <i class="fa fa-save"></i> Salvar </button>`);

</script>