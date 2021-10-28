<!--#include file="connect.asp"-->
<div class="widget-box transparent">
    <div class="widget-header widget-header-flat">
        <h4 class=""><i class="far fa-<%=dIcone("settings")%> blue"></i>
			EMPRESA E FILIAIS
        </h4>
    </div>
</div>


        <div class="tab-content">
            <div id="divEmpresa" class="tab-pane in active">
                <p><!--#include file="Empresa.asp"--></p>
            </div>

            <div id="divImpressos" class="tab-pane">
                Carregando...
                <%=server.Execute("ConfigImpressos.asp")%>
            </div>

            <div id="divContent" class="tab-pane">
                Carregando...
            </div>

            <div id="divUnavailable" align="center" class="tab-pane">
                <br /><br /><br /><br /><img src="assets/img/naodisponivel.png" width="550" height="243" /><br /><br /><br /><br /><br /><br />
            </div>
        </div>

