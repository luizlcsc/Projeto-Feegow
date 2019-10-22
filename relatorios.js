var DataSourceTree = function(options) {
	this._data 	= options.data;
	this._delay = options.delay;
}

DataSourceTree.prototype.data = function(options, callback) {
	var self = this;
	var $data = null;

	if(!("name" in options) && !("type" in options)){
		$data = this._data;//the root tree
		callback({ data: $data });
		return;
	}
	else if("type" in options && options.type == "folder") {
		if("additionalParameters" in options && "children" in options.additionalParameters)
			$data = options.additionalParameters.children;
		else $data = {}//no data
	}
	
	if($data != null)//this setTimeout is only for mimicking some random delay
		setTimeout(function(){callback({ data: $data });} , parseInt(Math.random() * 50) + 50);

	//we have used static data here
	//but you can retrieve your data dynamically from a server using ajax call
	//checkout examples/treeview.html and examples/treeview.js for more info
};

var tree_data = {
}

var treeDataSource = new DataSourceTree({data: tree_data});


var tree_data_2 = {
	'pacientes' : {name: 'Pacientes', type: 'folder', 'icon-class':'orange'}	,
	'prontuarios' : {name: 'Prontu&aacute;rios', type: 'folder', 'icon-class':'blue'}	,
	'faturamento' : {name: 'Faturamento', type: 'folder', 'icon-class':'pink'}	,
	'financeiro' : {name: 'Financeiro', type: 'folder', 'icon-class':'green'}
}
tree_data_2['pacientes']['additionalParameters'] = {
	'children' : [
		{name: '<a href="#" onclick="report(\'CadastrosEfetuadosPorPeriodo\');"><i class="fa fa-file-text blue"></i> <small>Cadastros por Per&iacute;odo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorTempoSemConsulta\');"><i class="fa fa-file-text"></i> <small>Por Tempo de Aus&ecirc;ncia</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorEndereco\');"><i class="fa fa-file-text"></i> <small>Por Endere&ccedil;o</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorFaixaEtaria\');"><i class="fa fa-file-text"></i> <small>Por Faixa Et&aacute;ria</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorConvenio\');"><i class="fa fa-file-text"></i> <small>Por Conv&ecirc;nio</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorGrauDeInstrucao\');"><i class="fa fa-file-text"></i> <small>Por Escolaridade</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorSexo\');"><i class="fa fa-file-text"></i> <small>Por Sexo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorPrevisaoDeRetorno\');"><i class="fa fa-file-text"></i> <small>Por Previs&atilde;o de Retorno</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorCutis\');"><i class="fa fa-file-text"></i> <small>Por C&uacute;tis</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorEstadoCivil\');"><i class="fa fa-file-text"></i> <small>Por Estado Civil</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorIndicacao\');"><i class="fa fa-file-text"></i> <small>Por Indica&ccedil;&atilde;o</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesComDebitoFinanceiro\');"><i class="fa fa-file-text"></i> <small>Por D&eacute;bito Financeiro</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesAniversariantes\');"><i class="fa fa-file-text"></i> <small>Aniversariantes por Per&iacute;odo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorOrigem\');"><i class="fa fa-file-text"></i> <small>Por Origem</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesPorProfissao\');"><i class="fa fa-file-text"></i> <small>Por Profiss&atilde;o</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'ListaMailing\');"><i class="fa fa-file-text"></i> <small>Lista para Mailing</small></a>', type: 'item'}
	]
}
tree_data_2['prontuarios']['additionalParameters'] = {
	'children' : [
		{name: '<a href="#" onclick="report(\'CIDsPorPeriodo\');"><i class="fa fa-file-text blue"></i> <small>CIDs por Per&iacute;odo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'ConsultasERetornosDePacientes\');"><i class="fa fa-file-text"></i> <small>Consultas e Retornos</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'ExamesEProcedimentosSolicitados\');"><i class="fa fa-file-text"></i> <small>Exames Solicitados</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'MedicamentosPrescritosPorPeriodo\');"><i class="fa fa-file-text"></i> <small>Prescri&ccedil;&otilde;es</small></a>', type: 'item'}
	]
}
tree_data_2['faturamento']['additionalParameters'] = {
	'children' : [
		{name: '<a href="#" onclick="report(\'FaturamentoSintetico\');"><i class="fa fa-file-text blue"></i> <small>Faturamento Sint&eacute;tico</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'ProducaoMedica\');"><i class="fa fa-file-text blue"></i> <small>Produ&ccedil;&atilde;o M&eacute;dica</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'AgrupadoPorConvenio\');"><i class="fa fa-file-text blue"></i> <small>Agrupado por Conv&ecirc;nio</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'AgrupadoPorProfissional\');"><i class="fa fa-file-text"></i> <small>Produ&ccedil;&atilde;o Conv&ecirc;nio por Profissional</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'AgrupadoPorProfissionalParticular\');"><i class="fa fa-file-text"></i> <small>Produ&ccedil;&atilde;o Particular por Profissional</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'AgrupadoPorUsuarioParticular\');"><i class="fa fa-file-text"></i> <small>Agrupado por Usu&aacute;rio</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'DetalhesAtendimentos\');"><i class="fa fa-file-text blue"></i> <small>Agendamentos e Atendimentos</small></a>', type: 'item'}
	]
}
tree_data_2['financeiro']['additionalParameters'] = {
	'children' : [
		{name: '<a href="#" onclick="report(\'FinanceiroSintetico\');"><i class="fa fa-file-text blue"></i> <small>Sint&eacute;tico por Per&iacute;odo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'FluxoDeCaixa\');"><i class="fa fa-file-text"></i> <small>Fluxo de Caixa</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'DebitosComFuncionariosEFornecedores\');"><i class="fa fa-file-text"></i> <small>D&eacute;bitos Financeiros</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'PacientesComDebitoFinanceiro\');"><i class="fa fa-file-text"></i> <small>Pacientes em D&eacute;bito</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'LucroPorPeriodo\');"><i class="fa fa-file-text"></i> <small>Resultado por Per&iacute;odo</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'ResultadoPorOrigem\');"><i class="fa fa-file-text"></i> <small>Resultado por Origem</small></a>', type: 'item'},
		{name: '<a href="#" onclick="report(\'Dmed\');"><i class="fa fa-file-text"></i> <small>D-Med</small></a>', type: 'item'}
	]
}

var treeDataSource2 = new DataSourceTree({data: tree_data_2});

