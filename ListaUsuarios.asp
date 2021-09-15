<!--#include file="connect.asp"-->
<script type="text/javascript">
    $(".crumb-active a").html("Lista de Usuarios");
    $(".crumb-icon a span").attr("class", "far fa-user");
</script>

<%
licencaid = replace(session("banco"), "clinic", "")
set licenca = db.execute("select Cupom from cliniccentral.licencas where id="&licencaid)
if not licenca.EOF then
    Cupom = licenca("Cupom")
end if
%>

<form id="frmListaUsuarios">
    <div class="panel">
        <div class="panel-body mt20">
            <div class="row">
                <%= quickField("text", "Cupom", "Cupom", 2, cupom, "", "", " readonly='readonly'") %>
                <%= quickField("text", "Nome", "Usuário", 2, "", "", "", "") %>
                <%= quickField("simpleSelect", "Tipo", "Tipo do Usuário", 2, "", "select 'Profissionais' id UNION ALL select 'Funcionarios' id", "id", " empty") %>
                <%= quickfield("multiple", "Empresa", "Empresa", 3, "", "select id, NomeEmpresa from cliniccentral.licencas where NomeEmpresa<>'' and Cupom like '"&Cupom&"' ", "NomeEmpresa", "") %>

                <div class="col-md-offset-1 col-md-2">
                    <button class="btn btn-primary btn-block mt20" id="buscaListaUsuarios"><i class="far fa-search bigger-110"></i> Buscar</button>
                </div>
            </div>

        </div>
    </div>
</form>

<div class="panel">
    <div class="panel-body" id="divListaUsuariosConteudo">
    </div>
</div>


<script type="text/javascript">
    $("#frmListaUsuarios").submit(function () {
        $(".buscaListaUsuarios").on('subimit',$("#divListaUsuariosConteudo").html("<p style='text-align: center'><i class='fa-9x far fa-spin fa-spinner'></i> Aguarde, estamos carregando a lista de usuários ...</p>"))

        $.post("ListaUsuariosConteudo.asp", $(this).serialize(), function (data) {
            $("#divListaUsuariosConteudo").html(data);
        });
        return false;
    });
    
    $("#frmListaUsuarios").submit();
</script>

<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>