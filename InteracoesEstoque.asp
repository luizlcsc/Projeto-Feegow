<!--#include file="connect.asp"-->
<%
I = req("I")
Acao = req("Acao")

if Acao="I" then
    MedicamentosRestricaoTotal = ref("MedicamentosRestricaoTotal")
    MedicamentosTipoInteracao = ref("MedicamentosTipoInteracao")
    MedicamentosTipoInteracao = ref("MedicamentosTipoInteracao")
    MedicamentosRestricaoParcial = ref("MedicamentosRestricaoParcial")
    AgentesRestricaoTotal = ref("AgentesRestricaoTotal")
    AgentesTipoInteracao = ref("AgentesTipoInteracao")
    AgentesRestricaoParcial = ref("AgentesRestricaoParcial")
    AlimentosRestricaoTotal = ref("AlimentosRestricaoTotal")
    AlimentosTipoInteracao = ref("AlimentosTipoInteracao")
    AlimentosRestricaoParcial = ref("AlimentosRestricaoParcial")

    set produtosInteracoes = db.execute("SELECT * FROM produtosinteracoes WHERE ProdutoID="&I)
    if produtosInteracoes.eof then
	    db_execute("INSERT INTO produtosinteracoes (ProdutoID, MedicamentosRestricaoTotal, MedicamentosTipoInteracao, MedicamentosRestricaoParcial, AgentesRestricaoTotal, AgentesTipoInteracao, AgentesRestricaoParcial, AlimentosRestricaoTotal, AlimentosTipoInteracao, AlimentosRestricaoParcial, sysUser) values ("&I&", '"&MedicamentosRestricaoTotal&"', '"&MedicamentosTipoInteracao&"', '"&MedicamentosRestricaoParcial&"', '"&AgentesRestricaoTotal&"', '"&AgentesTipoInteracao&"', '"&AgentesRestricaoParcial&"', '"&AlimentosRestricaoTotal&"', '"&AlimentosTipoInteracao&"', '"&AlimentosRestricaoParcial&"', "&session("User")&") ")
    else
        db_execute("UPDATE produtosinteracoes SET MedicamentosRestricaoTotal = '"&MedicamentosRestricaoTotal&"', MedicamentosTipoInteracao = '"&MedicamentosTipoInteracao&"', MedicamentosRestricaoParcial = '"&MedicamentosRestricaoParcial&"', AgentesRestricaoTotal = '"&AgentesRestricaoTotal&"', AgentesTipoInteracao = '"&AgentesTipoInteracao&"', AgentesRestricaoParcial = '"&AgentesRestricaoParcial&"', AlimentosRestricaoTotal = '"&AlimentosRestricaoTotal&"', AlimentosTipoInteracao = '"&AlimentosTipoInteracao&"', AlimentosRestricaoParcial = '"&AlimentosRestricaoParcial&"' WHERE ProdutoID="&I)
    end if
    %>
        new PNotify({
            title: 'Salvo com sucesso',
            text: 'Interação salva com sucesso.',
            type: 'success',
            delay: 1000
        });
    <%
end if


set getInteracoes = db.execute("SELECT * FROM produtosinteracoes WHERE ProdutoID="&treatvalzero(I))
if not getInteracoes.eof then
    MedicamentosRestricaoTotal = getInteracoes("MedicamentosRestricaoTotal")
    MedicamentosTipoInteracao = getInteracoes("MedicamentosTipoInteracao")
    MedicamentosRestricaoParcial = getInteracoes("MedicamentosRestricaoParcial")
    AgentesRestricaoTotal = getInteracoes("AgentesRestricaoTotal")
    AgentesTipoInteracao = getInteracoes("AgentesTipoInteracao")
    AgentesRestricaoParcial = getInteracoes("AgentesRestricaoParcial")
    AlimentosRestricaoTotal = getInteracoes("AlimentosRestricaoTotal")
    AlimentosTipoInteracao = getInteracoes("AlimentosTipoInteracao")
    AlimentosRestricaoParcial = getInteracoes("AlimentosRestricaoParcial")
end if
%>
<style>
    #formInteracoes .panel-heading{
        display: flex;
        justify-content: space-between;
    }
</style>
<form action="" method="post" id="formInteracoes">
    <div class='panel-heading'>
        <span>Interações do Medicamento</span>
        <div class='actionArea'>
            <button class="btn btn-success"><i class="far fa-save"></i> Salvar</button>
        </div>
    </div>

<div class="row mt30">
    <div class="col-md-12" id="InteracoesEstoqueTabela">
        <table id="InteracoesMedicamento"  class="table table-striped table-bordered table-condensed table-hover">
            <thead>
                <tr>
                    <th width="20%" class="text-center"><h4>Medicamentos</h4></th>
                    <th width="80%"></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Restritos (Impede a prescrição)</td>
                    <td>
                        <%=quickField("multiple", "MedicamentosRestricaoTotal", "Selecione os Medicamentos que possuem Restrição Total", 12, MedicamentosRestricaoTotal, "SELECT * FROM produtos WHERE sysActive=1 AND TipoProduto=4 AND id<>"&I, "NomeProduto", " empty")%>

                    </td>
                </tr>
                <tr>
                    <td>Restrição parcial (Avisos e alertas)</td>
                    <td>
                        <%=quickField("multiple", "MedicamentosTipoInteracao", "Selecione o Tipo de Restrição Parcial", 12, MedicamentosTipoInteracao, "SELECT * FROM cliniccentral.produtostiposinteracoes", "TipoInteracao", " empty")%>
                        <%=quickField("multiple", "MedicamentosRestricaoParcial", "Selecione os Medicamentos que possuem Restrição Parcial", 12, MedicamentosRestricaoParcial, "SELECT * FROM produtos WHERE sysActive=1 AND TipoProduto=4 AND id<>"&I, "NomeProduto", " empty")%>
                    </td>
                </tr>
            </tbody>
        </table>

        <table id="InteracoesAgentes"  class="table table-striped table-bordered table-condensed table-hover mt30">
            <thead>
                <tr>
                    <th width="20%" class="text-center"><h4>Agentes</h4></th>
                    <th width="80%"></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Restritos (Impede a prescrição)</td>
                    <td>
                        <%=quickField("multiple", "AgentesRestricaoTotal", "Selecione os Agentes que possuem Restrição Total", 12, AgentesRestricaoTotal, "SELECT * FROM cliniccentral.alergias WHERE Tipo like 'Agentes'", "Descricao", " empty")%>
                    </td>
                </tr>
                <tr>
                    <td>Restrição parcial (Avisos e alertas)</td>
                    <td>
                        <%=quickField("multiple", "AgentesTipoInteracao", "Selecione o Tipo de Restrição Parcial", 12, AgentesTipoInteracao, "SELECT * FROM cliniccentral.produtostiposinteracoes", "TipoInteracao", " empty")%>
                        <%=quickField("multiple", "AgentesRestricaoParcial", "Selecione os Agentes que possuem Restrição Parcial", 12, AgentesRestricaoParcial, "SELECT * FROM cliniccentral.alergias WHERE Tipo like 'Agentes'", "Descricao", " empty")%>
                    </td>
                </tr>
            </tbody>
        </table>


        <table id="InteracoesAlimentos" class="table table-striped table-bordered table-condensed table-hover mt30">
            <thead>
                <tr>
                    <th width="20%" class="text-center"><h3>Alimentos</h3></th>
                    <th width="80%"></th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Restritos (Impede a prescrição)</td>
                    <td>
                        <%=quickField("multiple", "AlimentosRestricaoTotal", "Selecione os Alimentos que possuem Restrição Total", 12, AlimentosRestricaoTotal, "SELECT * FROM cliniccentral.alergias WHERE Tipo like 'Alimentar'", "Descricao", " empty")%>
                    </td>
                </tr>
                <tr>
                    <td>Restrição parcial (Avisos e alertas)</td>
                    <td>
                        <%=quickField("multiple", "AlimentosTipoInteracao", "Selecione o Tipo de Restrição Parcial", 12, AlimentosTipoInteracao, "SELECT * FROM cliniccentral.produtostiposinteracoes", "TipoInteracao", " empty")%>
                        <%=quickField("multiple", "AlimentosRestricaoParcial", "Selecione os Alimentos que possuem Restrição Parcial", 12, AlimentosRestricaoParcial, "SELECT * FROM cliniccentral.alergias WHERE Tipo like 'Alimentar'", "Descricao", " empty")%>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

</form>

<script>

$("#formInteracoes").submit(function(){
	$.post("InteracoesEstoque.asp?Acao=I&I=<%=I%>", $("#formInteracoes").serialize(), function(data, status){ eval(data) } );
	return false;
})
showSalvar(false)
<!--#include file="jQueryFunctions.asp"-->

</script>