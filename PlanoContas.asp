<!--#include file="connect.asp"-->
<%

if req("CD")="D" then
    table = "sys_financialexpensetype"
else
    table = "sys_financialincometype"
end if

%>
		<link type="text/css" rel="stylesheet" href="assets/js/qtip/jquery.qtip.css" />
		<link rel="shortcut icon" href="icon_clinic.png" type="image/x-icon" />
		<link href="https://cdn.feegow.com/feegowclinic-v7/vendor/plugins/select2/select2-bootstrap.css" rel="stylesheet" type="text/css">
		<link href="assets/css/bootstrap.min.css" rel="stylesheet" />
		<link rel="stylesheet" href="assets/css/font-awesome.min.css" />
		<link rel="stylesheet" href="assets/css/jquery-ui-1.10.3.custom.min.css" />
		<link rel="stylesheet" href="assets/css/chosen.css" />
		<link rel="stylesheet" href="assets/css/datepicker.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-timepicker.css" />
		<link rel="stylesheet" href="assets/css/daterangepicker.css" />
		<link rel="stylesheet" href="assets/css/colorpicker.css" />
		<link rel="stylesheet" href="assets/css/jquery.gritter.css" />
		<link rel="stylesheet" href="assets/css/select2.css" />
		<link rel="stylesheet" href="assets/css/bootstrap-editable.css" />
	<link rel="stylesheet" href="assets/css/ace-fonts.css" />
	<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css" integrity="sha384-HSMxcRTRxnN+Bdg0JdbxYKrThecOKuH5zCYotlSAcp1+c8xmyTe9GYg1l9a69psu" crossorigin="anonymous">

		<!-- ace styles -->

		<link rel="stylesheet" href="assets/css/ace.css" />
		<link rel="stylesheet" href="assets/css/ace-rtl.min.css" />
		<link rel="stylesheet" href="assets/css/ace-skins.min.css" />

<style>
	.fa-edit{
		pointer-events: none;
	}
	ol {
		list-style: none;
	}
</style>
<div class="clearfix form-actions">
	<div class="col-xs-6">
		<label>Adicionar Categoria</label><br />
		<input type="text" name="Adicionar" id="Adicionar" class="form-control input-sm" />
    </div>
	<div class="col-xs-6">
		<label>Categoria superior</label><br />
		<select name="CategoriaSuperior" id="CategoriaSuperior" class="form-control">
                <option value="0"></option>
		    <%
		        set CategoriasSQL = db.execute("SELECT * FROM "&table&" WHERE (sysActive!=0 and sysActive!=-1) and Category=0")

		        while not CategoriasSQL.eof
		            %>
		            <option value="<%=CategoriasSQL("id")%>"><%=CategoriasSQL("Name")%></option>
		            <%
		        CategoriasSQL.movenext
		        wend
		        CategoriasSQL.close
		        set CategoriasSQL=nothing
		    %>
        </select>
    </div>
    <div class="col-xs-4"><label>&nbsp;</label><br />
    	<button type="button" class="btn btn-sm btn-success btn-block" onclick="arvore('<%=req("CD")%>', '', $('#Adicionar').val(), $('#CategoriaSuperior').val());location.reload()"><i class="far fa-plus"></i> Inserir</button>
    </div>
    <div class="col-xs-4"><label>&nbsp;</label><br />
    	<!-- <button class="btn btn-primary btn-block btn-sm" onclick="savePlanoContas()" name="serialize" id="serialize"><i class="far fa-save"></i> Salvar Ordem</button> -->
    	<button class="btn btn-primary btn-block btn-sm" type="submit" name="serialize" id="serialize"><i class="far fa-save"></i> Salvar</button>
	</div>
</div>
<%
function li(id, Name, Rateio, Ordem, Posicao)
	%>
	<li id="list_<%=id%>" data-id="<%=id%>" data-tipo="<%=req("CD")%>" data-ordem="<%=Ordem%>" data-nome="<%=Name%>" data-rateio="<%=Rateio%>" class="dd-item">
		<div class="dd-handle">
			<span class="disclose">
				<span>
				</span>
			</span>
			<span class='ordem'> <% if Posicao <> "" then response.write(Posicao) else response.write(Ordem) end if%> </span> -
			<span class='nome'> <%=Name%> </span>
        <div class="pull-right action-buttons">
        	<i class="far fa-move" style="cursor:move"></i>

            <%
            if req("CD")="D" then
                if Rateio=1 then
                    chkRateio = " checked "
                else
                    chkRateio = ""
                end if
                %>
                <label><input type="checkbox" title="Rateio" <%=chkRateio %> class="ace rateio" name="<%=id %>" value="S" /><span class="lbl"></span></label>
                <%
            end if
            %>
			<a class="btn btn-xs btn-danger" href="javascript:if(confirm('Tem certeza de que deseja excluir este registro?'))arvore('<%=req("CD")%>', <%=id%>, '')"><i class="far fa-trash"></i></a>
            <a class="btn btn-xs btn-success" onclick="editaPlanoDeContas('<%=id %>', '<%= req("CD") %>', '<%=Name%>')" href="#"><i class="far fa-edit"></i></a>
		</div></div>
    <%
end function
%>
<div class="dd" id="nestable">
	<ol class="sortable dd-list">
    <%
	if req("I")<>"" then

		categoriaSuperior = treatvalzero(request.QueryString("CategoriaSuperior"))
		set rsCategoriaMae = db.execute("SELECT Posicao FROM " & table & " WHERE id = " & categoriaSuperior)
		posicaoMae = ""
		if not rsCategoriaMae.eof then
			posicaoMae = rsCategoriaMae("Posicao")
		end if

		set rsMaxOrdem = db.execute("SELECT MAX(Ordem) as Ordem FROM " & table & " sf WHERE sf.Category = " & categoriaSuperior)
		ordem = 0
		if not rsMaxOrdem.eof then
			if rsMaxOrdem("Ordem")&"" <> "" then
				ordem = rsMaxOrdem("Ordem") + 1
			end if
		end if

		if posicaoMae <> "" then
			posicao = posicaoMae & "." & ordem
		else
			posicao = ordem
		end if

		sql = "insert into "&table&" (Name, Category, Ordem, Posicao, sysActive, sysUser) values ('"&replace(request.QueryString("I"), "'", "''")&"', "&categoriaSuperior&","&ordem&",'"&posicao&"', 1, "&session("User")&")"
		db_execute(sql)
		
	    %>
        <script type="text/javascript">
        $(document).ready(function(e) {
            new PNotify({
                title: 'Salvo com sucesso!',
                text: '',
                type: 'success',
                delay: 3000
            });
        });

        </script>
        <%
	end if

	if req("E")<>"" then
		db_execute("UPDATE "&table&" SET Name='"&req("Name")&"' WHERE id="&treatvalnull(req("E")))
	    %>
        <script type="text/javascript">
        $(document).ready(function(e) {
            new PNotify({
                title: 'Salvo com sucesso!',
                text: '',
                type: 'success',
                delay: 3000
            });
        });

        </script>
        <%
	end if

	if req("X")<>"" and isnumeric(req("X")) then
		db_execute("delete from "&table&" where id="&req("X"))
	end if

	contidos = ""
	set reg1 = db.execute("select * from "&table&" where (Category=0 or isnull(Category)) and sysActive=1 order by Ordem")
	reg1cont = 1
	reg2cont = 1
	reg3cont = 1
	reg4cont = 1
	reg5cont = 1
	reg6cont = 1
	while not reg1.eof
		contidos = contidos&"|"&reg1("id")&"|"
		%>
		<%=li(reg1("id"), reg1("Name"), reg1("Rateio"), reg1cont, reg1("Posicao"))%>
		<%
 		set reg2 = db.execute("select * from "&table&" where Category="&reg1("id")&" and sysActive=1 order by Ordem")
		if not reg2.eof then
 		%>
        	<ol>
			<%
			while not reg2.eof
				contidos = contidos&"|"&reg2("id")&"|"
				%>
                <%=li(reg2("id"), reg2("Name"), reg2("Rateio"), reg1cont&"."&reg2cont, reg2("Posicao"))%>
                <%
				set reg3 = db.execute("select * from "&table&" where Category="&reg2("id")&" and sysActive=1 order by Ordem")
				if not reg3.eof then
					%><ol>
                    	<%
						while not reg3.eof
							contidos = contidos&"|"&reg3("id")&"|"
							%>
							<%=li(reg3("id"), reg3("Name"), reg3("Rateio"), reg1cont&"."&reg2cont&"."&reg3cont, reg3("Posicao"))%>
							<%

							set reg4 = db.execute("select * from "&table&" where Category="&reg3("id")&" and sysActive=1 order by Ordem")
							if not reg4.eof then
								%><ol>
									<%
									while not reg4.eof
										contidos = contidos&"|"&reg4("id")&"|"
										%>
										<%=li(reg4("id"), reg4("Name"), reg4("Rateio"), reg1cont&"."&reg2cont&"."&reg3cont&"."&reg4cont, reg4("Posicao"))%>
										<%


										set reg5 = db.execute("select * from "&table&" where Category="&reg4("id")&" and sysActive=1 order by Ordem")
										if not reg5.eof then
											%><ol>
												<%
												while not reg5.eof
													contidos = contidos&"|"&reg5("id")&"|"
													%>
													<%=li(reg5("id"), reg5("Name"), reg5("Rateio"), reg1cont&"."&reg2cont&"."&reg3cont&"."&reg4cont&"."&reg5cont, reg5("Posicao"))%>
													<%

													set reg6 = db.execute("select * from "&table&" where Category="&reg5("id")&" and sysActive=1 order by Ordem")
                                                    if not reg6.eof then
                                                        %><ol>
                                                            <%
                                                            while not reg6.eof
                                                                contidos = contidos&"|"&reg6("id")&"|"
                                                                %>
                                                                <%=li(reg6("id"), reg6("Name"), reg6("Rateio"), reg1cont&"."&reg2cont&"."&reg3cont&"."&reg4cont&"."&reg5cont&"."&reg6cont, reg6("Posicao"))%>
                                                                <%
															reg6cont = reg6cont+1
                                                            reg6.movenext
                                                            wend
                                                            reg6.close
                                                            set reg6 = nothing
                                                            %>
                                                        </ol>
                                                        <%
                                                    end if
												reg5cont = reg5cont+1
												reg6cont = 1
												reg5.movenext
												wend
												reg5.close
												set reg5 = nothing
												%>
											</ol>
											<%
										end if

									reg4cont = reg4cont+1
									reg5cont = 1
									reg4.movenext
									wend
									reg4.close
									set reg4 = nothing
									%>
								</ol>
								<%
							end if


						reg3cont = reg3cont+1
						reg4cont = 1
						reg3.movenext
						wend
						reg3.close
						set reg3 = nothing
						%>
                    </ol>
                    <%
				end if
			reg2cont = reg2cont+1
			reg3cont = 1
			reg4cont = 1
			reg5cont = 1
			reg6cont = 1
			reg2.movenext
			wend
			reg2.close
			set reg2 = nothing
			%>
            </ol>
		<%
		end if
	reg1cont = reg1cont+1
	reg2cont = 1
	reg3cont = 1
	reg4cont = 1
	reg5cont = 1
	reg6cont = 1
	reg1.movenext
	wend
	reg1.close
	set reg1 = nothing

	set descategorizados = db.execute("select * from "&table&" where not Category=0 and not isnull(Category) and sysActive=1 order by Ordem")
	while not descategorizados.eof
		if instr(contidos, "|"&descategorizados("id")&"|")=0 then
            db_execute("update "&table&" set Category=0 where id="&descategorizados("id"))
			%>
			<%=li(descategorizados("id"), descategorizados("Name"), descategorizados("Rateio"),descategorizados("Ordem"))%>
			<%
		end if
	descategorizados.movenext
    wend
    descategorizados.close
    set descategorizados = nothing
    %>
	</ol>
</div>

	<pre class="hidden" id="serializeOutput"></pre>

<script type="text/javascript" src="js/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.16.custom.min.js"></script>
<script type="text/javascript" src="js/jquery.ui.touch-punch.js"></script>
<script type="text/javascript" src="js/jquery.mjs.nestedSortable.js"></script>

<script type="text/javascript">
	<%
	set rsCategoriaMae = db.execute("select Posicao from " & table & " where id = 0")
	codCategoriaMae = ""
	if not rsCategoriaMae.eof then
		codCategoriaMae = rsCategoriaMae("Posicao")
	end if
	%>

	const CD = '<%=request.QueryString("CD")%>';
	const inputCodigo = window.parent.document.getElementById('codigo-mae-' + CD);
	const inputAnotherCodigo = window.parent.document.getElementById('codigo-mae-' + (CD == 'C' ? 'D' : 'C'));
	let codCategoriaMae = '';
	if (inputCodigo) {
		codCategoriaMae = inputCodigo.value;
	} else {
		codCategoriaMae = '<%=codCategoriaMae%>';
	}

	$(document).ready(function(){
		$('ol.sortable').nestedSortable({
			forcePlaceholderSize: true,
			handle: 'div',
			helper:	'clone',
			items: 'li',
			opacity: .6,
			placeholder: 'placeholder',
			revert: 250,
			tabSize: 25,
			tolerance: 'pointer',
			toleranceElement: '> div',
			maxLevels: 6,

			isTree: false,
			expandOnHover: 700,
			startCollapsed: false,
			relocate: function() {
				reordenaLista($('ol.sortable'));
			}
		});

		function reordenaLista(list, prevOrdem) {
			$(list).find('> li.dd-item').each(function(index) {
				const item     = $(this);
				const curOrdem = (index + 1);

				const ordem  = prevOrdem ? (prevOrdem + '.' + curOrdem) : curOrdem;

				const ordemText = codCategoriaMae != '' ? codCategoriaMae + '.' + ordem : ordem
				item.find('.ordem').html(ordemText);
				item.attr('data-ordem', ordem);

				item.find('> ol').each(function() {
					reordenaLista($(this), ordem);
				});
			});
		}

		if (inputCodigo) {
			$(inputCodigo).on('blur', function() {
				if ($(this).val() != '' && $(this).val() != codCategoriaMae) {
					codCategoriaMae = $(this).val();
					reordenaLista($('ol.sortable'));
				}
			});
		}

		$('.disclose').on('click', function() {
			$(this).closest('li').toggleClass('mjs-nestedSortable-collapsed').toggleClass('mjs-nestedSortable-expanded');
		});


		$('#serialize').click(function(){
			serialized = $('ol.sortable').nestedSortable('serialize');
			linhas = serialized.split('&')
			let array = []
			array[0]= 'null'
			linhas.filter((linha)=>{
				let index = linha.split('=')[0].replace('list[','').replace(']','')
				let valor = linha.split('=')[1]

				array[index] = valor
			});

			let itens = $('li[data-tipo="<%=req("CD")%>"]')
			let data = ''

			if (inputCodigo) {
				if (inputCodigo.value === '') {
					alert('Informe o código da categoria de ' + (CD === 'C' ? 'Receitas' : 'Despesas'));
					inputCodigo.focus();
					return;
				}

				if (inputAnotherCodigo.value == inputCodigo.value) {
					alert('O código não pode ser igual ao código da categoria de ' + (CD === 'C' ? 'Despesas' : 'Receitas'));
					inputCodigo.focus();
					return;
				}

				codCategoriaMae = inputCodigo.value;
				

				data += '[id:0, Posicao:' + codCategoriaMae +']&'
				console.log(data);
			}

			let ordem = 0;
			itens.filter((key,ele)=>{
				let id = $(ele).attr('data-id')
				let nome = $(ele).attr('data-nome')
				let posicao = (codCategoriaMae != '' ? (codCategoriaMae + '.') : '') + $(ele).attr('data-ordem')
				let category = array[id]
				let rateio = $(ele).attr('data-rateio')
				if(category == 'null'){
					category = 0
				}
				data += '[id:'+id+',Category:'+category+',Name:'+nome+',Rateio:'+rateio+',Posicao:'+posicao+']&'
			});

			$.ajax({
				type:"POST",
				url:"savePlanoContas.asp?R=<%=table%>",
				data:data,
				success:function(data){
 					chamagritter();
                    $("#content").find(".col-xs-12").html(data);
				}
			});
		});

		$(".rateio").click(function () {
		    $.post("saveDataCat.asp", {I:$(this).attr('name'), Checked:$(this).prop('checked')}, function (data) { eval(data) });
		})

		$('#toHierarchy').click(function(e){
			hiered = $('ol.sortable').nestedSortable('toHierarchy', {startDepthCount: 0});
			hiered = dump(hiered);
			(typeof($('#toHierarchyOutput')[0].textContent) != 'undefined') ?
			$('#toHierarchyOutput')[0].textContent = hiered : $('#toHierarchyOutput')[0].innerText = hiered;
		})

		$('#toArray').click(function(e){
			arraied = $('ol.sortable').nestedSortable('toArray', {startDepthCount: 0});
			arraied = dump(arraied);
			(typeof($('#toArrayOutput')[0].textContent) != 'undefined') ?
			$('#toArrayOutput')[0].textContent = arraied : $('#toArrayOutput')[0].innerText = arraied;
		})

	});

	function dump(arr,level) {
		var dumped_text = "";
		if(!level) level = 0;

		//The padding given at the beginning of the line.
		var level_padding = "";
		for(var j=0;j<level+1;j++) level_padding += "    ";

		if(typeof(arr) == 'object') { //Array/Hashes/Objects
			for(var item in arr) {
				var value = arr[item];

				if(typeof(value) == 'object') { //If it is an array,
					dumped_text += level_padding + "'" + item + "' ...\n";
					dumped_text += dump(value,level+1);
				} else {
					dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
				}
			}
		} else { //Strings/Chars/Numbers etc.
			dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
		}
		return dumped_text;
	}
	function editaPlanoDeContas(id, cd, value) {
		var newValue = prompt("Digite o nome do plano de contas", value);
		if(newValue){
			$('#list_'+id).attr('data-nome',newValue)
			$('#list_'+id+' > div.dd-handle > span.nome').html(newValue)


			$.post("EdiCat.asp", {id: id, CD: cd, value: newValue}, function() {
				location.reload();
			});
		}
	}

</script>

		<script src="assets/js/jquery.gritter.min.js"></script>
