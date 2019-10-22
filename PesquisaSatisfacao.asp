<!--#include file="connect.asp"-->
<%

if ref("e")="e" then
    if ref("AtivoEmail")="on" then
        db_execute("update sys_config SET RecursosAdicionais= CONCAT(IFNULL(RecursosAdicionais,'|'),'PesquisaSatisfacao|') WHERE id=1")
    else
        db_execute("update sys_config SET RecursosAdicionais= replace(RecursosAdicionais, '|PesquisaSatisfacao|','|') WHERE id=1")
    end if
end if

set PesquisaSatisfacaoSQL = db.execute("SELECT RecursosAdicionais FROM sys_config WHERE id=1")
if instr(PesquisaSatisfacaoSQL("RecursosAdicionais"),"|PesquisaSatisfacao|") then
    Ativo = "checked"
end if

%>

<div class="row">
<form id="formPesquisa">
<div class="col-md-12">
  <div class="alert alert-default">
    Valor por e-mail enviado: <strong>R$ 0,25</strong>
</div>
</div>
  <div class="col-md-10">

  <input type="hidden" name="e" value="e">
    <label for="">Pesquisa de satisfação via e-mail</label>
    <div title="Ativar / Desativar" class="mn">
        <div class="switch switch-info switch-inline">
            <input <%=Ativo%> name="AtivoEmail" id="AtivoEmail" type="checkbox">
            <label class="mn" for="AtivoEmail"></label>
        </div>
    </div>
</div>
<div class="col-md-2">
    <button class="btn btn-primary">Salvar</button>
</div>

</form>
</div>
<script >

$("#formPesquisa").submit(function(){
    $.post("PesquisaSatisfacao.asp", $(this).serialize(), function(data){
       $("#divPesquisaSatisfacao").html(data);
    });
    return false;
});
</script>