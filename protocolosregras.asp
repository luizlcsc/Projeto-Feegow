<!--#include file="connect.asp"-->
<%
'id = req("I")

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
                <button class="btn btn-sm btn-primary pull-right" ><i class="fa fa-plus"></i> Adicionar nova regra</button>
            </div>

            <!-- Regra 1-->
            <div class="col-md-12">
                <table width="100%" class="table table-striped table-hover mt20">
                    <thead>
                        <tr class="success">
                            <th colspan="3"><b>REGRA 1</b></th>
                            <th width="1%"><button class="btn btn-sm btn-alert"><i class="fa fa-files-o"></i></button></th>
                            <th width="1%"><button class="btn btn-sm btn-success pull-right" ><i class="fa fa-plus"></i></button></th>
                            <th width="1%"><button class="btn btn-sm btn-dark pull-right" ><i class="fa fa-close"></i></button></th>
                        </tr>
                    </thead>
                    <tbody>
                            <tr>
                                <td width="40%">
                                    <select id="Campo" name="Campo" class="select2-single form-control">
                                        <optgroup label="Dados Cadastrais">
                                            <option value="1" selected>Sexo</option>
                                            <option value="1">Idade</option>
                                            <option value="2">Convênio</option>
                                        </optgroup>
                                        <optgroup label="Dados Estruturados">
                                            <option value="3">Altura</option>
                                            <option value="4">Peso</option>
                                            <option value="4">CID</option>
                                        </optgroup>
                                        <optgroup label="Campos dos Formulários">
                                            <option value="3">Queixa Principal (Primeira Consulta)</option>
                                            <option value="4">Estadiamento (Evolução)</option>
                                        </optgroup>
                                    </select>
                                </td>
                                <td>
                                    <%=quickfield("simpleSelect", "SexoValor", "", 12, SexoValor, "select id, NomeSexo from sexo where sysActive=1 order by NomeSexo", "NomeSexo", "")%>
                                </td>
                                <td>
                                </td>
                                <td></td>
                                <td> <code><b>e</b></code> </td>
                                <td><button class="btn btn-sm btn-danger pull-right" ><i class="fa fa-minus"></i></button></td>
                            </tr>
                            <tr>
                                <td width="40%">
                                    <select id="Campo" name="Campo" class="select2-single form-control">
                                        <optgroup label="Dados Cadastrais">
                                            <option value="1">Sexo</option>
                                            <option value="1">Idade</option>
                                            <option value="2">Convênio</option>
                                        </optgroup>
                                        <optgroup label="Dados Estruturados">
                                            <option value="3" selected>Altura</option>
                                            <option value="4">Peso</option>
                                            <option value="4">CID</option>
                                        </optgroup>
                                        <optgroup label="Campos dos Formulários">
                                            <option value="3">Queixa Principal (Primeira Consulta)</option>
                                            <option value="4">Estadiamento (Evolução)</option>
                                        </optgroup>
                                    </select>
                                </td>
                                <td>
                                    <%=quickField("simpleSelect", "PesoRegra", "", 12, PesoRegra, "select '|IGUAL|' id, 'Igual a' PesoRegra union all select '|DIFERENTE|' id, 'Diferente de' PesoRegra union all select '|MAIOR|' id, 'Maior que' PesoRegra union all select '|MENOR|' id, 'Menor que' PesoRegra", "PesoRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <div class="input-group">
                                        <input class="form-control input-mask-brl text-right" placeholder="0,00" type="text" style="text-align:right">
                                        <span class="input-group-addon">
                                            <strong>m</strong>
                                        </span>
                                    </div>
                                </td>
                                <td></td>
                                <td> <code><b>e</b></code> </td>
                                <td><button class="btn btn-sm btn-danger pull-right" ><i class="fa fa-minus"></i></button></td>
                            </tr>

                    </tbody>
                </table>
            </div>


            <br>
            <div class="col-md-12 text-center">
            <code><b>ou</b></code>
            </div>
            <br>


            <div class="col-md-12">
                <table width="100%" class="table table-striped table-hover mt20">
                    <thead>
                        <tr class="success">
                            <th colspan="3"><b>REGRA 2</b></th>
                            <th width="1%"><button class="btn btn-sm btn-alert"><i class="fa fa-files-o"></i></button></th>
                            <th width="1%"><button class="btn btn-sm btn-success pull-right" ><i class="fa fa-plus"></i></button></th>
                            <th width="1%"><button class="btn btn-sm btn-dark pull-right" ><i class="fa fa-close"></i></button></th>
                        </tr>
                    </thead>
                    <tbody>
                            <tr>
                                <td width="40%">
                                    <select id="Campo" name="Campo" class="select2-single form-control">
                                        <optgroup label="Dados Cadastrais">
                                            <option value="1">Sexo</option>
                                            <option value="1">Idade</option>
                                            <option value="2" selected>Convênio</option>
                                        </optgroup>
                                        <optgroup label="Dados Estruturados">
                                            <option value="3">Altura</option>
                                            <option value="4">Peso</option>
                                            <option value="4">CID</option>
                                        </optgroup>
                                        <optgroup label="Campos dos Formulários">
                                            <option value="3">Queixa Principal (Primeira Consulta)</option>
                                            <option value="4">Estadiamento (Evolução)</option>
                                        </optgroup>
                                    </select>
                                </td>
                                <td>
                                    <%=quickField("simpleSelect", "ConvenioRegra", "", 12, ConvenioRegra, "select '|ALL|' id, 'Todos' ConvenioRegra union all select '|ONLY|' id, 'Somente' ConvenioRegra union all select '|EXCEPT|' id, 'Exceto' ConvenioRegra", "ConvenioRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <%=quickfield("simpleSelect", "ConvenioValor", "", 12, ConvenioValor, "select id, NomeConvenio from convenios where sysActive=1 and Ativo='on' order by NomeConvenio", "NomeConvenio", "")%>
                                </td>
                                <td></td>
                                <td> <code><b>e</b></code> </td>
                                <td><button class="btn btn-sm btn-danger pull-right" ><i class="fa fa-minus"></i></button></td>
                            </tr>
                            <tr>
                                <td width="40%">
                                    <select id="Campo" name="Campo" class="select2-single form-control">
                                        <optgroup label="Dados Cadastrais">
                                            <option value="1">Sexo</option>
                                            <option value="1">Idade</option>
                                            <option value="2">Convênio</option>
                                        </optgroup>
                                        <optgroup label="Dados Estruturados">
                                            <option value="3">Altura</option>
                                            <option value="4" selected>Peso</option>
                                            <option value="4">CID</option>
                                        </optgroup>
                                        <optgroup label="Campos dos Formulários">
                                            <option value="3">Queixa Principal (Primeira Consulta)</option>
                                            <option value="4">Estadiamento (Evolução)</option>
                                        </optgroup>
                                    </select>
                                </td>
                                <td>
                                    <%=quickField("simpleSelect", "PesoRegra", "", 12, PesoRegra, "select '|IGUAL|' id, 'Igual a' PesoRegra union all select '|DIFERENTE|' id, 'Diferente de' PesoRegra union all select '|MAIOR|' id, 'Maior que' PesoRegra union all select '|MENOR|' id, 'Menor que' PesoRegra", "PesoRegra", " semVazio ")%>
                                </td>
                                <td>
                                    <div class="input-group">
                                        <input class="form-control input-mask-brl text-right" placeholder="0,00" type="text" style="text-align:right">
                                        <span class="input-group-addon">
                                            <strong>Kg</strong>
                                        </span>
                                    </div>
                                </td>
                                <td></td>
                                <td> <code><b>e</b></code> </td>
                                <td><button class="btn btn-sm btn-danger pull-right" ><i class="fa fa-minus"></i></button></td>
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
