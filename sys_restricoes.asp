<!--#include file="connect.asp"-->
<%
call insertRedir(request.QueryString("P"), request.QueryString("I"))
set reg = db.execute("select * from sys_restricoes where id="& req("I"))
%>
<div class="panel">
    <div class="panel-body">
        <form method="post" id="frm" name="frm" action="saveRestricao.asp">
            <%=header(req("P"), "Restrições", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
            <input type="hidden" name="I" value="<%=request.QueryString("I")%>" />
            <input type="hidden" name="P" value="<%=request.QueryString("P")%>" />
            <input type="hidden" name="Acao" value="salvarFormRestricao">
            <div class="container">
                <div class="row">
                    <%=quickField("text", "Descricao", "Descrição", 8, reg("Descricao"), "", "", "")%>
                    <%=quickField("simpleSelect", "Tipo", "Tipo", 4, reg("Tipo"), "SELECT id, Tipo FROM cliniccentral.restricoestipo ORDER BY Tipo;", "Tipo", "")%>
                    <%=quickField("simpleCheckbox", "ExibirCheckin", "Exibir no checkin", 12, reg("ExibirCheckin"), "", "", "")%>
                    <div id="divRestricaoSemExcecao">    
                        <%=quickField("simpleCheckbox", "RestricaoSemExcecao", "Restrição sem exceção", 12, reg("RestricaoSemExcecao"), "", "", "")%>
                    </div>
                </div>
                <div class="row" id="divTipoRestricaoSimNao">
                    <%=quickField("simpleCheckbox", "CaixaSIM", "Mostrar caixa de texto para SIM", 3, reg("CaixaSIM"), "", "", "")%>
                    <%=quickField("text", "TextoSIM", "Texto para SIM", 9, reg("TextoSIM"), "", "", "")%>
                    <%=quickField("simpleCheckbox", "CaixaNAO", "Mostrar caixa de texto para NÃO", 3, reg("CaixaNAO"), "", "", "")%>
                    <%=quickField("text", "TextoNAO", "Texto para NÃO", 9, reg("TextoNAO"), "", "", "")%>
                </div>
                <div class="row" id="divDadosPaciente">
                    <div class="col-md-4">
                        <label for="DadoFicha">Dados do paciente</label>
                        <select name="DadoFicha" class="select-dados-paciente">
                            <option value="0">Selecione
                            <option value="85" <% if reg("DadoFicha") = "85" then response.write("selected") end if%>>Altura
                            <option value="59" <% if reg("DadoFicha") = "59" then response.write("selected") end if%>>Nascimento
                            <option value="84" <% if reg("DadoFicha") = "84" then response.write("selected") end if%>>Peso
                        </select>
                    </div>
                    <br>
                    <%=quickField("simpleCheckbox", "ExibeDadoFicha", "Trazer dados do cadastro", 12, reg("ExibeDadoFicha"), "", "", "")%>
                    <%=quickField("simpleCheckbox", "AlteraDadoFicha", "Atualizar dados do cadastro", 12, reg("AlteraDadoFicha"), "", "", "")%>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <button type="button" class="btn btn-primary pull-right m5" onclick="SalvaRestricao()">Salvar</button>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>
<script>

    function SalvaRestricao() {

        $.post("saveRestricao.asp",$("#frm").serialize(),function(data){
            eval(data);
        })
    }

    $("#divRestricaoSemExcecao").hide();
    $("#divTipoRestricaoSimNao").hide();
    $("#divDadosPaciente").hide();

    $("#Tipo").change(function(){
        var tipoSelecionado = $("#Tipo").val();

        if (tipoSelecionado == 3) {
            $("#divDadosPaciente").hide();
            $("#divDadosPaciente").find("input:text, input:checkbox, select").each(function(){$(this).prop("disabled",true)});
            $("#divTipoRestricaoSimNao").find("input:text, input:checkbox").each(function(){$(this).prop("disabled",false)});
            $("#divTipoRestricaoSimNao").show();
            $("#divRestricaoSemExcecao").show();
        } else if (tipoSelecionado == 2) {
            $("#divTipoRestricaoSimNao").hide();
            $("#divTipoRestricaoSimNao").find("input:text, input:checkbox").each(function(){$(this).prop("disabled",true)});
            $("#divDadosPaciente").find("input:text, input:checkbox, select").each(function(){$(this).prop("disabled",false)});
            $("#divDadosPaciente").show();
            $("#divRestricaoSemExcecao").show();
        } else {
            $("#RestricaoSemExcecao").find("input:text, input:checkbox").each(function(){$(this).prop("disabled",true)});
            $("#divDadosPaciente").find("input:text, input:checkbox, select").each(function(){$(this).prop("disabled",true)});
            $("#divTipoRestricaoSimNao").find("input:text, input:checkbox").each(function(){$(this).prop("disabled",true)});
            $("#divRestricaoSemExcecao").hide();
            $("#divTipoRestricaoSimNao").hide();
            $("#divDadosPaciente").hide();
        }
    })

    $(document).ready(function(){
        
        $("#Salvar").hide();

        $("#frm").submit(function(e){
            e.preventDefault();
        });

        var tipoSelecionado = $("#Tipo").val();

        if (tipoSelecionado == 3) {
            $("#divTipoRestricaoSimNao").show();
            $("#divRestricaoSemExcecao").show();
        } else if (tipoSelecionado == 2) {
            $("#divDadosPaciente").show();
            $("#divRestricaoSemExcecao").show();
        } else if (tipoSelecionado == 1) {
            $("#divRestricaoSemExcecao").hide();
            $("#divTipoRestricaoSimNao").hide();
            $("#divDadosPaciente").hide();
        }

        <%call formSave("frm", "save", "")%>
     });
    $('.select-dados-paciente').select2();
</script>
<!--#include file="disconnect.asp"-->