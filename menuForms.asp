<!--#include file="connect.asp"-->
<%
if GrupoID="" then
	GrupoID = req("GrupoID")
end if
FormularioNaTimeline = getConfig("FormularioNaTimeline")
%>
<div class="col-xs-12 widget-container-span">
    <div class="widget-box">
        <div class="widget-header widget-header-small header-color-orange">
            <h6>
                <i class="far fa-plus"></i> ADICIONAR CAMPO
            </h6>

        </div>

        <div class="widget-body">
            <div class="widget-main">
              <table class="table table-condensed">
                <tr>
                    <td width="50%"><button type="button" onClick="addCampo(1, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-text-width bigger-200"></i><br>Texto</button></td>
                    <td width="50%"><button type="button" onClick="addCampo(8, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-align-justify bigger-200"></i><br>Memo</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(4, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-check-square-o bigger-200"></i><br>Check</button></td>
                    <td><button type="button" onClick="addCampo(5, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-check-circle-o bigger-200"></i><br>Radio</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(6, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-toggle-down bigger-200"></i><br>Sele&ccedil;&atilde;o</button></td>
                    <td><button type="button" onClick="addCampo(2, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-calendar bigger-200"></i><br>Data</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(10, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-header bigger-200"></i><br>T&iacute;tulo</button></td>
                    <td><button type="button" onClick="addCampo(3, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-image bigger-200"></i><br>Imagem</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(9, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-table bigger-200"></i><br>Tabela</button></td>
                    <td><button type="button" onClick="addCampo(11, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-line-chart bigger-200"></i><br>Gr&aacute;fico</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(15, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-barcode bigger-200"></i><br>Barras</button></td>
                    <td><button type="button" onClick="addCampo(16, <%=GrupoID%>)" class="btn btn-app btn-block btn-info btn-sm"><i class="far fa-stethoscope bigger-200"></i><br>CID-10</button></td>
                </tr>
                <tr>
                	<td colspan="2">
                        <div class="btn-group btn-block">
                        <button class="btn btn-block btn-app btn-info btn-sm dropdown-toggle" data-toggle="dropdown">
                        <i class="far fa-headphones bigger-200"></i><br>Espec.
                        <span class="far fa-caret-down icon-on-right"></span>
                        </button>
                        <ul class="dropdown-menu dropdown-info pull-right">
                            <li><a href="javascript:addCampo(14, <%=GrupoID%>)"><i class="far fa-child"></i> Curva de Crescimento</a></li>
                            <li><a href="javascript:addCampo(12, <%= GrupoID %>)"><i class="far fa-headphones"></i> Audiometria</a></li>

                            <%
                            IF FormularioNaTimeline THEN
                            %>
                            <li><a href="javascript:addCampo(24, <%= GrupoID %>)"><i class="far fa-table"></i> Carteira de Vacinação</a></li>
                            <%
                            END IF
                            %>
                        </ul>
                        </div>
                    </td>
                </tr>
                <%
                IF FormularioNaTimeline THEN
                %>
                <tr>
                    <td><button type="button" onClick="addCampo(19, <%=GrupoID%>)" class="btn btn-app btn-block btn-primary btn-sm"><i class="far fa-flask bigger-200"></i><br>Prescri&ccedil;&otilde;es</button></td>
                    <td><button type="button" onClick="addCampo(20, <%=GrupoID%>)" class="btn btn-app btn-block btn-primary btn-sm"><i class="far fa-hospital-o bigger-200"></i><br>Pedidos</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(21, <%=GrupoID%>)" class="btn btn-app btn-block btn-primary btn-sm"><i class="far fa-file-text bigger-200"></i><br>Atestados</button></td>
                    <td><button type="button" onClick="addCampo(16, <%=GrupoID%>)" class="btn btn-app btn-block btn-primary btn-sm"><i class="far fa-stethoscope bigger-200"></i><br>CID-10</button></td>
                </tr>
                <tr>
                    <td><button type="button" onClick="addCampo(23, <%=GrupoID%>)" class="btn btn-app btn-block btn-primary btn-sm"><i class="far fa-external-link bigger-200"></i><br>Encaminhamento</button></td>
                </tr>
                <%
                end if
                %>
                <%if GrupoID=0 then
                    set pform = db.execute("select * from buiforms where id="& req("I"))
                    Prior = pform("Prior")
                    %>
                <tr>
                    <td colspan="2"><button type="button" onClick="estilo()" class="btn btn-app btn-block btn-default btn-xs"><i class="far fa-style bigger-200"></i> Estilo do Formul&aacute;rio</button></td>
                </tr>
                <tr>
                    <td colspan="2" class="checkbox-custom checkbox-warning">
                        <input type="checkbox" <%if Prior=1 then response.write(" checked ") end if %> name="Prior" id="Prior" value="1" /> <label for="Prior"> <i class="far fa-star"></i> Priorizar na linha do tempo</label>
                    </td>
                </tr>
                <%
				else
				%>
                <tr>
                	<td colspan="3"><button type="button" onClick="$('#modal-narrow').modal('hide');" class="btn btn-app btn-block btn-default btn-xs"><i class="far fa-remove bigger-200"></i> Fechar</button></td>
                </tr>
                <% end if %>

              </table>
              <br>
               <%if getConfig("UtilizarFormatoImpressao")=1 then
                      set getForm = db.execute("SELECT ModoImpressao FROM buiforms WHERE id="&req("I") )
                      if not getForm.eof then
                          ModoImpressao  = getForm("ModoImpressao")
                      end if

                 call quickField("simpleSelect", "ModoImpressao", "Modo de Impressão", 10, ModoImpressao, "SELECT 'bootstrap' id, 'Padrão' ModoImpressao UNION ALL SELECT 'personalizado' id, 'Personalizado' ModoImpressao ", "ModoImpressao", " semVazio no-select2")
                 %>
                 <!--<button type="button" class="btn mt25 btn-app btn-info btn-xs"  title="Informações"> <i class="far fa-info bigger-200"></i> </button>-->
                 <button type="button" class="btn mt25 btn-app btn-success btn-xs hidden" id="EditarImpressao" onClick="EditarImpressao('<%=req("I")%>')" title="Informações"> <i class="far fa-edit bigger-200"></i> </button>
                 <%
                 end if
                 %>
            </div>
        </div>
    </div>
</div>    

<script language="javascript">
$(document).ready(function(){


    if ($("#ModoImpressao").val() === "personalizado"){
        $("#EditarImpressao").removeClass("hidden");
    }

    $("#ModoImpressao").change(function(){
        $("#Salvar").click();
        $.post("saveModoImpressaoForm.asp?I=<%=req("I")%>&ModoImpressao="+$("#ModoImpressao").val(), "", function(data){
            eval(data);
        });
        if ($("#ModoImpressao").val() === "personalizado"){
            $("#EditarImpressao").removeClass("hidden");
        }else{
             $("#EditarImpressao").addClass("hidden");
         }

    });




});

function EditarImpressao(I){
    $("#modal").css("width", "1200px");
    $("#modal").css("margin-left", "-300px");

    $("#modal-table").modal("show");
    $("#modal").html("Carregando...");
    $.post("ConfigFormPersonalizado.asp?I="+I, "", function (data) {
        $("#modal").html(data);

    });
    $("#modal").addClass("modal-lg");
}

function infoImpressao(){
    $("#modal-table").modal("show");
    $("#modal").html("Carregando...");
    $.post("infoImpressao.asp", "", function (data) {
        $("#modal").html(data);
    });
    $("#modal-content").addClass("modal-lg");

}
<!--#include file="JQueryFunctions.asp"-->
</script>