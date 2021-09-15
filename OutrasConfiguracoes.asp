<!--#include file="connect.asp"-->
<!--#include file="connectCentral.asp"-->
<!--#include file="./Classes/ServerPath.asp"-->

<script type="text/javascript">
    $(".crumb-active a").html("Outras Configurações");
    $(".crumb-icon a span").attr("class", "far fa-cogs");

</script>


<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.44.0/codemirror.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.44.0/mode/xml/xml.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.44.0/mode/css/css.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/tinycolor/1.4.1/tinycolor.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/pick-a-color@1.2.3/build/1.2.2/js/pick-a-color-1.2.2.min.js"></script>


<%
LicencaID = replace(session("Banco"), "clinic", "")

if ref("E")="E" then
	dbc.execute("update licencas set LocaisAcesso='"&ref("LocaisAcesso")&"', IPsAcesso='"&ref("IPsAcesso")&"' where id="&LicencaID)
end if


set dados = dbc.execute("select * from licencas where id="&LicencaID)
if session("Admin")=1 then
%>

<br />
<div class="tabbable panel">
    <div class="tab-content panel-body">
        <div id="divGeral" class="tab-pane">
            <form method="post" action="">
                <input type="hidden" name="E" value="E">
                <div class="clearfix form-actions">
                    <button class="btn btn-primary pull-right"><i class="far fa-save"></i> SALVAR</button>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>
                                        <label><input type="checkbox" class="ace" name="ConveniosContrato" value="S" /><span class="lbl"> Exibir no agendamento somente convênios com os quais o profissional tenha contrato.</span></label>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </form>
        </div>
        <div id="divIP" class="tab-pane active">

            <form method="post" action="">
            <input type="hidden" name="E" value="E">
            <div class="clearfix form-actions">
                <button class="btn btn-primary pull-right"><i class="far fa-save"></i> Salvar</button>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <label><input class="ace" type="radio" name="LocaisAcesso" value="Todos"<%if dados("LocaisAcesso")="Todos" then%> checked<%end if%>><span class="lbl"> Permitir que os usu&aacute;rios acessem o sistema a partir de todos os lugares.</span></label>
                </div>
                <div class="col-md-6">
                    <label><input class="ace" type="radio" name="LocaisAcesso" value="Limitado"<%if dados("LocaisAcesso")="Limitado" then%> checked<%end if%>><span class="lbl"> Permitir que os usu&aacute;rios acessem o sistema somente a partir dos IPs abaixo.</span></label><br>
                    &raquo; <small>Escreva um IP embaixo do outro.</small>
                    <textarea class="form-control" rows="10" name="IPsAcesso"><%=dados("IPsAcesso")%></textarea>
                </div>
            </div>
                <div class="row">
                    <div class="col-md-12">
                        <%
                        Banco = replace(session("banco"), "clinic", "")
                        Banco = 5533356-ccur(Banco)
                        %>
                        <a class="btn btn-default" href="https://components-legacy.feegow.com/index.php/agendamento-online/client/<%=Banco%>-AAAW" target="_blank"><i class="far fa-external-link"></i> Iframe para agendamento online</a>
                    </div>
                </div>
            </form>
        </div>
        <div class="tab-pane" id="divPesquisaSatisfacao">
        	Carregando...
        </div>
        <div class="tab-pane" id="divTriagem">
        	Carregando...
        </div>
        <div class="tab-pane" id="divOmissao">
        	Carregando...
        </div>
        <div class="tab-pane" id="divIntegracoes">
        	Carregando...
        </div>
        <div class="tab-pane" id="divCamposObrigatorios">
        	Carregando...
        </div>
        <div class="tab-pane" id="divRegrasDeFormulario">
        	Carregando...
        </div>
        <div class="tab-pane" id="divApiPublica">
            Carregando...
        </div>
        <div class="tab-pane" id="divTotem">
            Carregando...
        </div>
        <div class="tab-pane" id="divChamadaTVConfiguracoes">
            Carregando...
        </div>
        <div class="tab-pane" id="divLaudosOnline">
            Carregando...
        </div>
         <div class="tab-pane" id="divProcedimentoLaboratorio">
            Carregando...
        </div>
         <div class="tab-pane" id="divWhatsapp">
            Carregando...
        </div>
    </div>
</div>
<%
end if

%>
<!--#include file="disconnect.asp"-->