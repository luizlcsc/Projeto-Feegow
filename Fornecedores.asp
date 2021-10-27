<!--#include file="connect.asp"-->
<!--#include file="modal.asp"-->
<%

'ALTER TABLE `fornecedores`	ADD COLUMN `limitarPlanoContas` TEXT NULL AFTER `PlanoContasID`,	ADD COLUMN `autoPlanoContas` TEXT NULL AFTER `limitarPlanoContas`


call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))

limitarPlanoContas = reg("limitarPlanoContas")
autoPlanoContas = reg("autoPlanoContas")

obrigar = ""

set config = db.execute("select ValidarCPFCNPJ from sys_config where id=1")
if not config.eof then
    if config("ValidarCPFCNPJ")="S" then
        obrigar = " required"
    end if
end if
%>


<%=header(req("P"), "Cadastro de Fornecedor", reg("sysActive"), req("I"), req("Pers"), "Follow")%>

<br>
<div class="tabbable">
    <div class="tab-content">
        <div id="divCadastroPrincipal" class="tab-pane  in active panel">

            <form method="post" id="frm" name="frm" action="save.asp">
                <input type="hidden" name="I" value="<%=req("I")%>" />
                <input type="hidden" name="P" value="<%=req("P")%>" />


                <div class="panel-heading">
                    <span class="panel-title">
                        Dados Principais
                    </span>
                    <span class="panel-controls">
                    <%
                    if (reg("sysActive")=1 and aut(lcase(req("P"))&"A")=1) or (reg("sysActive")=0 and aut(lcase(req("P"))&"I")=1) then
                        %>
                        <button class="btn btn-primary btn-sm" id="save"> <i class="far fa-save"></i> Salvar </button>
                        <%
                    end if
                    %>
                    </span>
                </div>

                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-12">
                            <div class="row">
                                <%=quickField("text", "NomeFornecedor", "Nome", 5, reg("NomeFornecedor"), "", "", " required")%>
                                <%= quickField("text", "CPF", "CPF/CNPJ", 3, reg("CPF"), "", "", obrigar) %>
                                <%= quickField("text", "RG", "Inscri&ccedil;&atilde;o Mun./Est.", 3, reg("RG"), "", "", "") %>

                                <script src="//unpkg.com/vanilla-masker@1.1.1/lib/vanilla-masker.js"></script>
                                <script>
                                    function inputHandler(masks, max, event) {
                                      var c = event.target;
                                      var v = c.value.replace(/\D/g, '');
                                      var m = c.value.length > max ? 1 : 0;
                                      VMasker(c).unMask();
                                      VMasker(c).maskPattern(masks[m]);
                                      c.value = VMasker.toPattern(v, masks[m]);
                                    }

                                   var docMask = ['999.999.999-99', '99.999.999/9999-99'];
                                   var doc = document.querySelector('#CPF');

                                   doc.addEventListener('input', inputHandler.bind(undefined, docMask, 14), false);
                                   doc.addEventListener('change', function(arg){
                                       if(!((arg.target.value+"").length == 14 || (arg.target.value+"").length == 18)){
                                           arg.target.value = ""
                                       }
                                   });
                                </script>

                                <div class="col-md-1">
                                    <label>
                                        Ativo
                                        <br />
                                        <div class="switch round">
                                            <input type="checkbox" <% If reg("Ativo")="on" or isnull(reg("Ativo")) Then %> checked="checked"<%end if%> name="Ativo" id="Ativo">
                                            <label for="Ativo">Label</label>
                                        </div>

                                    </label>
                                  </div>
                            </div>
                            <div class="row">
                                <div class="col-md-3">
                                    <%=selectInsert("Grupo", "GrupoID", reg("GrupoID"), "profissionaisgrupos", "NomeGrupo", "", "", "") %>
                                </div>
                                <%= quickField("simpleSelect", "TipoPrestadorID", "Tipo de Prestador de Serviço", 2, reg("TipoPrestadorID"), "select * from cliniccentral.tipoprestadorservico order by 1", "descricao", "") %>

                            </div>
                            <hr />
                            <div class="row">
                                <%= quickField("text", "Cep", "Cep", 3, reg("cep"), "input-mask-cep", "", "") %>
                                <%= quickField("text", "Endereco", "Endere&ccedil;o", 5, reg("endereco"), "", "", "") %>
                                <%= quickField("text", "Numero", "N&uacute;mero", 2, reg("numero"), "", "", "") %>
                                <%= quickField("text", "Complemento", "Compl.", 2, reg("complemento"), "", "", "") %>
                            </div>
                            <div class="row">
                                <%= quickField("text", "Bairro", "Bairro", 4, reg("bairro"), "", "", "") %>
                                <%= quickField("text", "Cidade", "Cidade", 4, reg("cidade"), "", "", "") %>
                                <%= quickField("text", "Estado", "Estado", 2, reg("estado"), "", "", "") %>
                                <%= quickField("simpleSelect", "Pais", "Pa&iacute;s", 2, reg("Pais"), "select * from Paises where sysActive=1 order by NomePais", "NomePais", "") %>
                            </div>
                            <div class="row">
                                <%= quickField("phone", "Tel1", "Telefone", 4, reg("tel1"), "", "", "") %>
                                <%= quickField("mobile", "Cel1", "Celular", 4, reg("cel1"), "", "", "") %>
                                <%= quickField("email", "Email1", "E-mail", 4, reg("email1"), "", "", "") %>
                                <%= quickField("phone", "Tel2", "&nbsp;", 4, reg("tel2"), "", "", "") %>
                                <%= quickField("mobile", "Cel2", "&nbsp;", 4, reg("cel2"), "", "", "") %>
                                <%= quickField("email", "Email2", "&nbsp;", 4, reg("email2"), "", "", "") %>
                            </div>
                            <div class="row mt10">
                                <%= quickField("memo", "Obs", "Observa&ccedil;&otilde;es", 12, reg("Obs"), "", "", "") %>
                            </div>
                            <hr class="short alt" />
                            <div class="row">
                                <%'= quickField("simpleSelect", "PlanoContaID", "Plano de Contas", 4, reg("PlanoContaID"), "select id,Name from sys_financialexpensetype where sysActive=1 order by Name", "Name", "") %>
                                <%= quickField("multiple", "limitarPlanoContas", "Limitar Planos de Contas", 3, limitarPlanoContas, "select id, Name from sys_financialexpensetype where sysActive=1 order by Name", "Name", "") %>
                                <%= quickField("multiple", "autoPlanoContas", "Adicionar Itens Automaticamente", 3, autoPlanoContas, "select id, Name from sys_financialexpensetype where sysActive=1 order by Name", "Name", "") %>
                                
                                <div class="col-md-6">
                                    <%call Subform("fornecedorcentrocusto", "FornecedorID", req("I"), "frm")%>
                                </div>

                            </div>
                            <div class="row">
                                <%'=quickField("multiple", "SomenteFornecedor", "Procedimentos", 6, SomenteFornecedor, "SELECT id,NomeProcedimento FROM procedimentos WHERE Ativo='on' and sysActive=1 order by NomeProcedimento", "NomeProcedimento", "")%>
                            </div>
                            </div>
                        </div>
                     </div>
            </form>
        </div>
        <div id="divContratos" class="tab-pane">
            Carregando...
        </div>
        <div id="divAcesso" class="tab-pane">
            Carregando...
        </div>
        <div id="divPermissoes" class="tab-pane">
			Carregando...
        </div>
    </div>
</div>
<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});


$("#Cep").keyup(function(){
	getEndereco();
});
var resultadoCEP
function getEndereco() {
//alert()
//	alert(($("#Cep").val() *= '_'));
	var temUnder = /_/i.test($("#Cep").val())
	if(temUnder == false){
		$.getScript("webservice-cep/cep.php?cep="+$("#Cep").val(), function(){
			if(resultadoCEP["logradouro"]!=""){
				$("#Endereco").val(unescape(resultadoCEP["logradouro"]));
				$("#Bairro").val(unescape(resultadoCEP["bairro"]));
				$("#Cidade").val(unescape(resultadoCEP["cidade"]));
				$("#Estado").val(unescape(resultadoCEP["uf"]));
				$("#Numero").focus();
			}else{
				$("#Endereco").focus();
			}
		});				
	}			
}

</script>
<!--#include file="disconnect.asp"-->