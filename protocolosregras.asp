<!--#include file="connect.asp"-->
<%
id = req("I")
set getRegra = db.execute("select * from protocolos WHERE id="&id)
if not getRegra.eof then
    SexoRegra = getRegra("SexoRegra")
    SexoValor = getRegra("SexoValor")
    PesoRegra = getRegra("PesoRegra")
    PesoValor = getRegra("PesoValor")
    AlturaRegra = getRegra("AlturaRegra")
    AlturaValor = getRegra("AlturaValor")
    IdadeRegra = getRegra("IdadeRegra")
    IdadeValor = getRegra("IdadeValor")
    ConvenioRegra = getRegra("ConvenioRegra")
    ConvenioValor = getRegra("ConvenioValor")
    CidRegra = getRegra("CidRegra")
    CidValor = getRegra("CidValor")
end if
%>

<div class="modal-header ">
    <div class="row">
        <div class="col-md-8">
            <h4 class="lighter blue"> <i class="fa fa-lock"></i>  Regra de Sugestão do Protocolo</h4>
        </div>
        <div class="col-md-4" style="margin-top: 5px;">
            <button class="btn btn-sm btn-primary pull-right" onclick="saveRegra('<%=id%>')"><i class="fa fa-save"></i> Salvar</button>
        </div>
    </div>

</div>
<div class="col-md-12 mt30 ml5">
    <p><i><b>Atenção:</b> Na seção dados demográficos a sugestão aparecerá apenas se na ficha do paciente a informação coincidir com a aqui marcada. <br />Já em dados clínicos estão listados todos os campos distintos dos formulários criados em seu sistema, e só será validade os campos presentes na ficha do paciente.</i></p>
</div>
<form method="post" id="frmRegraProtocolo" name="frmRegraProtocolo">
    <div class="modal-body">
        <div class="row">
            <input type="hidden" name="I" id="I" value="<%=id%>" />
            <div class="col-md-12">
                <table width="100%" class="table table-striped table-hover mt20">
                    <thead>
                        <tr class="success">
                            <th width="30%">Dados Demográficos</th>
                            <th width="35%">Regras</th>
                            <th width="35%">Valor</th>
                        </tr>
                    </thead>
                    <tbody>
                            <tr>
                                <td>Sexo</td>
                                <td>
                                    <%=quickField("simpleSelect", "SexoRegra", "", 12, SexoRegra, "select '|ALL|' id, 'Todos' SexoRegra union all select '|ONLY|' id, 'Somente' SexoRegra union all select '|EXCEPT|' id, 'Exceto' SexoRegra", "SexoRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickfield("multiple", "SexoValor", "", 12, SexoValor, "select id, NomeSexo from sexo where sysActive=1 order by NomeSexo", "NomeSexo", "")%>
                                </td>
                            </tr>
                            <tr>
                                <td>Peso</td>
                                <td>
                                    <%=quickField("simpleSelect", "PesoRegra", "", 12, PesoRegra, "select '|IGUAL|' id, 'Igual a' PesoRegra union all select '|DIFERENTE|' id, 'Diferente de' PesoRegra union all select '|MAIOR|' id, 'Maior que' PesoRegra union all select '|MENOR|' id, 'Menor que' PesoRegra", "PesoRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickField("text", "PesoValor", "", 1, PesoValor, " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
                                </td>
                            </tr>
                            <tr>
                                <td>Altura</td>
                                <td>
                                    <%=quickField("simpleSelect", "AlturaRegra", "", 12, AlturaRegra, "select '|IGUAL|' id, 'Igual a' AlturaRegra union all select '|DIFERENTE|' id, 'Diferente de' AlturaRegra union all select '|MAIOR|' id, 'Maior que' AlturaRegra union all select '|MENOR|' id, 'Menor que' AlturaRegra", "AlturaRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickField("text", "AlturaValor", "", 1, AlturaValor, " input-mask-brl text-right", "", " placeholder=""0,00"" ")%>
                                </td>
                            </tr>
                            <tr>
                                <td>Idade</td>
                                <td>
                                    <%=quickField("simpleSelect", "IdadeRegra", "", 12, IdadeRegra, "select '|IGUAL|' id, 'Igual a' IdadeRegra union all select '|DIFERENTE|' id, 'Diferente de' IdadeRegra union all select '|MAIOR|' id, 'Maior que' IdadeRegra union all select '|MENOR|' id, 'Menor que' IdadeRegra", "IdadeRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickField("number", "IdadeValor", "", 1, IdadeValor, " text-right", "", " placeholder=""0"" ")%>
                                </td>
                            </tr>
                            <tr>
                                <td>Convênio</td>
                                <td>
                                    <%=quickField("simpleSelect", "ConvenioRegra", "", 12, ConvenioRegra, "select '|ALL|' id, 'Todos' ConvenioRegra union all select '|ONLY|' id, 'Somente' ConvenioRegra union all select '|EXCEPT|' id, 'Exceto' ConvenioRegra", "ConvenioRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickfield("multiple", "ConvenioValor", "", 12, ConvenioValor, "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", "")%>
                                </td>
                            </tr>
                            <tr>
                                <td>CID</td>
                                <td>
                                    <%=quickField("simpleSelect", "CidRegra", "", 12, CidRegra, "select '|ALL|' id, 'Todos' CidRegra union all select '|ONLY|' id, 'Somente' CidRegra union all select '|EXCEPT|' id, 'Exceto' CidRegra", "CidRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickfield("multiple", "CidValor", "", 12, CidValor, "select id, concat(codigo, ' ' , descricao) NomeCid from cliniccentral.cid10 order by Codigo limit 100", "NomeCid", "")%>
                                </td>
                            </tr>

                    </tbody>
                </table>
            </div>

        </div>
        <br>
    </div>
    <div class="modal-footer no-margin-top">
        <button class="btn btn-sm btn-primary pull-right" onclick="saveRegra('<%=id%>')"><i class="fa fa-save"></i> Salvar</button>
    </div>
</form>


<script>

function saveRegra(ID){
	$.post("saveProtocolo.asp?Tipo=Regra&I="+ID, $("#frmRegraProtocolo").serialize(), function(data, status){ window.location.reload(); });
	return false;
};
</script>


<script type="text/javascript">

<!--#include file="JQueryFunctions.asp"-->
</script>
