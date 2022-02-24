<!--#include file="connect.asp"-->
<style>
    .TipoValor{
        border-bottom-left-radius: 0;
        border-top-left-radius: 0;
    }
    .Valor{
        border-top-right-radius:0;
        border-bottom-right-radius:0;
    }
    .divValor{
        padding-right:0px;
    }
    .divTipoValor{
        padding-left:0px;
    }
</style>
<%
ProcedimentoID = req("I")
Acao = req("A")
TipoAcao = req("TA")

if TipoAcao="P" then
    if Acao="I" then
        db_execute("insert into procedimentosequipeparticular (ProcedimentoID, Funcao, Valor, TipoValor, ContaPadrao, TabelasPermitidas) values ("&ProcedimentoID&", '', 0, 'P', '', '|5|, |8|')")
    end if
    if Acao="X" then
        db_execute("delete from procedimentosequipeparticular where id="&req("Ieq"))
    end if
end if

if TipoAcao="C" then
    if Acao="I" then
        db_execute("insert into procedimentosequipeconvenio (ProcedimentoID, Funcao, Valor, TipoValor, ContaPadrao) values ("&ProcedimentoID&", 0, 0, 'P', '')")
    end if
    if Acao="X" then
        db_execute("delete from procedimentosequipeconvenio where id="&req("Ieq"))
    end if
end if


%>

<div class="panel-heading">
    <span class="panel-title">Equipe para Repasse <small>&raquo; particular</small></span>
    <span class="panel-controls">
        <button type="button" class="btn btn-sm btn-info" onclick="pep('I', 0, 0)"><i class="far fa-plus"></i> Adicionar</button>
    </span>
</div>

<div class="row">
    <div class="col-md-12">
        <%
        set eq = db.execute("select * from procedimentosequipeparticular ep where ProcedimentoID="&ProcedimentoID)
        if eq.eof then
            response.Write("<div class='col-md-12 text-center'>Nenhuma fun&ccedil;&atilde;o padr&atilde;o para repasse particular neste procedimento.</div>")
        else
        %>
        <table class="table table-condensed table-bordered table-striped">
            <thead>
              <tr class="info">
                <th class="p10">Fun&ccedil;&atilde;o</th>
                <th class="p10">Valor</th>
                <th class="p10">Conta Padr&atilde;o</th>
                <th class="p10">Tabelas Permitidas</th>
                <th class="p10" width="1%"></th>
              </tr>
            </thead>
            <tbody>
                <%
            while not eq.eof
                %>
                <tr class="linhaP" id="<%=eq("id")%>">
                    <td><%=quickField("text", "FuncaoP"&eq("id"), "", 12, eq("Funcao"), "", "", "") %></td>
                    <td>
                        <div class="input-group">
					        <%=quickField("text", "ValorP"&eq("id"), "", 12, fn(eq("Valor")), " input-mask-brl text-right", "", "")%>
                            <span class="input-group-addon">
                                <select class="select-group" name="TipoValorP<%=eq("id")%>" id="TipoValorP<%=eq("id")%>">
                                    <option value="P"<% If eq("TipoValor")="P" Then %> selected<% End If %>>%</option>
                                    <option value="V"<% If eq("TipoValor")="V" Then %> selected<% End If %>>R$</option>
                                </select>
                            </span>
                        </div>
                    </td>
                    <td><%call selectCurrentAccounts("ContaPadraoP"&eq("id"), "0, 5, 4, 2, 8", eq("ContaPadrao"), "")%></td>
                    <td><%=quickField("multiple", "TabelasPermitidasP"&eq("id"), "", 12, eq("TabelasPermitidas"), "select id, `table` Tabela from cliniccentral.sys_financialaccountsassociation where id in (2,3,4,5,8)", "Tabela", "")%></td>
                    <td><button type="button" class="btn btn-sm btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este item?'))pep('X', 0, <%=eq("id") %>)"><i class="far fa-remove"></i></button></td>
                </tr>
                <%
            eq.movenext
            wend
            eq.close
            set eq=nothing
                %>
            </tbody>
        </table>
        <%
        end if
        %>
    </div>
</div>

<div class="widget-header">
    <h4>Equipe para Faturamento e Repasse <small>&raquo; conv&ecirc;nio</small></h4>
    <div class="widget-toolbar">
        <button type="button" class="pull-right btn btn-xs btn-info" onclick="pec('I', 0, 0)"><i class="far fa-plus"></i> Adicionar</button>
    </div>
</div>

<div class="row">
    <div class="col-md-12">
        <%
        set eq = db.execute("select * from procedimentosequipeconvenio ec where ProcedimentoID="&ProcedimentoID)
        if eq.eof then
            response.Write("<div class='col-md-12 text-center'>Nenhuma fun&ccedil;&atilde;o padr&atilde;o para faturamento e repasse de conv&ecirc;nio neste procedimento.</div>")
        else
        %>
        <table class="table table-condensed table-bordered table-striped">
            <thead>
                <th>Fun&ccedil;&atilde;o</th>
                <th>Valor</th>
                <th>Conta Padr&atilde;o</th>
                <th width="1%"></th>
            </thead>
            <tbody>
                <%
            while not eq.eof
                %>
                <tr class="linhaC" id="<%=eq("id")%>">
                    <td><%=quickField("simpleSelect", "FuncaoC"&eq("id"), "", 12, eq("Funcao"), "select id, descricao from cliniccentral.tissgrauparticipacao order by codigo", "Descricao", " empty='' required = ""required"" ") %></td>
                    <td>
                        <div class="col-md-8 divValor">
					        <%=quickField("text", "ValorC"&eq("id"), "", 7, fn(eq("Valor")), " input-mask-brl text-right Valor", "", "")%>
                        </div>
                        <div class="col-md-2 divTipoValor">
                            <select class="form-control TipoValor" name="TipoValorC<%=eq("id")%>" id="TipoValorC<%=eq("id")%>">
                                <option value="P"<% If eq("TipoValor")="P" Then %> selected<% End If %>>%</option>
                                <option value="V"<% If eq("TipoValor")="V" Then %> selected<% End If %>>R$</option>
                            </select>
                        </div>
                    </td>
                    <td><%call selectCurrentAccounts("ContaPadraoC"&eq("id"), "0, 5, 4, 2, 8", eq("ContaPadrao"), "")%></td>
                    <td><button type="button" class="btn btn-xs btn-danger" onclick="if(confirm('Tem certeza de que deseja excluir este item?'))pec('X', 0, <%=eq("id") %>)"><i class="far fa-remove"></i></button></td>
                </tr>
                <%
            eq.movenext
            wend
            eq.close
            set eq=nothing
                %>
            </tbody>
        </table>
        <%
        end if
        %>
    </div>
</div>


<script>
    $(".linhaP input, .linhaP select").change(function(){
        var LI = $(this).closest("tr").attr("id");
        $.post("procedimentosequipesalvar.asp?TA=P&I=<%=req("I") %>", {
            Funcao: $("#FuncaoP"+LI).val(),
            Valor: $("#ValorP"+LI).val(),
            TipoValor: $("#TipoValorP"+LI).val(),
            ContaPadrao: $("#ContaPadraoP"+LI).val(),
            TabelasPermitidas: $("#TabelasPermitidasP"+LI).val(),
            eI:LI
        }, function(data){
            //eval(data);
        });
    });
    $(".linhaC input, .linhaC select").change(function(){
        var LI = $(this).closest("tr").attr("id");
        $.post("procedimentosequipesalvar.asp?TA=C&I=<%=req("I") %>", {
            Funcao: $("#FuncaoC"+LI).val(),
            Valor: $("#ValorC"+LI).val(),
            TipoValor: $("#TipoValorC"+LI).val(),
            ContaPadrao: $("#ContaPadraoC"+LI).val(),
            eI:LI
        }, function(data){
            //eval(data);
        });
    });

    <!--#include file="JQueryFunctions.asp"-->
</script>