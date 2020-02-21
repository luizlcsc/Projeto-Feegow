CKEDITOR.editorConfig = function( config ) {
	config.toolbarGroups = [
		{ name: 'undo', groups: [ 'undo' ] },
		{ name: 'styles', groups: [ 'styles', 'align', 'format' ] },
		{ name: 'basicstyles', groups: ['basicstyles', 'cleanup'] },
		{ name: 'paragraph', groups: ['list'] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'colors', groups: [ 'colors' ] }
	];

	config.extraPlugins = 'autotag';

};