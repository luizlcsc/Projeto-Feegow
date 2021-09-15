<!--#include file="connect.asp"-->
<%
Filtro = req("Filtro")

limite = 250
c = 0
set listaFormulas = db.execute("select id, NomeProcedimento, Valor from procedimentos where (NomeProcedimento like '%"&Filtro&"%' or Sigla like '%"&Filtro&"%') and sysActive=1 and Ativo='on' "&_
                                              " order by (NomeProcedimento like '"&Filtro&"%' ) desc, NomeProcedimento limit "&limite)



if not listaFormulas.eof then
    while not listaFormulas.EOF
        c = c+1
        %>
            <tr>
              <td>
                <button style="border:none;color:#3498db;background-color:white" onclick='itens("S", "I", "<%= listaFormulas("id") %>")' id="botao-aplicar-proposta-<%=listaFormulas("id")%>">
                    <i class="far fa-hand-o-left icon-hand-left bigger-125"></i></button>
              </td>
              <td><code>Procedimento</code> <%=listaFormulas("NomeProcedimento")%></td>
            </tr>

    <%
    listaFormulas.movenext
    wend
    listaFormulas.close
    set listaFormulas = nothing
end if
set PacotesSQL = db.execute("select pac.id, pac.NomePacote from pacotes pac where pac.NomePacote like '%"&Filtro&"%' and sysActive=1 and Ativo='on' "&_
" order by pac.NomePacote limit "&limite)
if not PacotesSQL.eof then
    while not PacotesSQL.EOF
        c = c+1
        %>
            <tr>
              <td>
                <a href="javascript:itens('P', 'I', '<%=PacotesSQL("id")%>')" class="blue" id="<%=PacotesSQL("id")%>" title="" data-placement="top" data-rel="tooltip" data-original-title="Aplicar">
                    <i class="far fa-hand-o-left icon-hand-left bigger-125"></i>
                </a>
              </td>
              <td><code>Pacote</code> <%=PacotesSQL("NomePacote")%></td>
            </tr>

    <%
    PacotesSQL.movenext
    wend
    PacotesSQL.close
    set PacotesSQL = nothing
end if

if c=limite then
	%>
	<li><span class="red">Exibindo somente os <%=limite%> primeiros. <br>Para visualizar mais, busque acima.</span></li>
	<%
end if
%>
<script>
$("#ulItens li").hover(function(){
	
	//javascript:itens('S', 'I', 0);
	
  
  let html = `
    <div class="tools action-buttons">
      <span class="tooltip-info" title="" data-placement="top" data-rel="tooltip" data-original-title="Inserir na Proposta">
        <a href="#" data-toggle="modal" class="blue" onClick="itens(\'S\', \'I\', '+ $(this).attr('id') +')">
          <i class="far fa-hand-o-left icon-hand-left bigger-125"></i>
        </a>
      </span>
    </div>`

	$(this).find(".btns").html(html);
	
	
});
$("#ulItens li").mouseleave(function(){
	$(this).find(".btns").html('');
});


/*
function filtra(v){
	var texto = v;
	$("#ulItens li").css("display", "block");
	$("#ulItens li").each(function(){
		if($(this).text().indexOf(texto) < 0)
		   $(this).css("display", "none");
	});
}

	$("#listaformulasmedicamentos li").css('display', 'none');
	$('#listaformulasmedicamentos').find('li').filter(function () {
		return /dul/.test(this.innerHTML);
	}).css('display','block')
*/
</script>