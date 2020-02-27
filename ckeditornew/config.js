CKEDITOR.editorConfig = function( config ) {
	config.toolbarGroups = [
		{ name: 'undo', groups: [ 'undo' ] },
		{ name: 'styles', groups: [ 'styles', 'align', 'format' ] },
		{ name: 'basicstyles', groups: ['basicstyles', 'cleanup'] },
		{ name: 'paragraph', groups: ['list'] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'colors', groups: [ 'colors' ] },
        { name: 'links' }
	];

	// config.extraPlugins = 'autotag';

	// config.removeButtons = 'Source,Save,NewPage,Preview,Print,Templates,Find,Replace,SelectAll,Scayt,Form,Checkbox,Radio,Indent,CreateDiv,Language,BidiRtl,BidiLtr,Link,Unlink,Anchor,Flash,Smiley,Iframe,PageBreak,Maximize,ShowBlocks,About,Styles,SpecialChar,Subscript,Superscript,Formata��o,HorizontalRule,Format';
};