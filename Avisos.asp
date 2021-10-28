<!--#include file="connect.asp"-->
<%

'ALTER TABLE `fornecedores`	ADD COLUMN `limitarPlanoContas` TEXT NULL AFTER `PlanoContasID`,	ADD COLUMN `autoPlanoContas` TEXT NULL AFTER `limitarPlanoContas`


call insertRedir(req("P"), req("I"))
set reg = db.execute("select * from "&req("P")&" where id="&req("I"))
%>


<form method="post" id="frm" name="frm" action="save.asp">
    <%=header(req("P"), "Gestão de Avisos", reg("sysActive"), req("I"), req("Pers"), "Follow")%>
    <input type="hidden" name="I" value="<%=req("I")%>" />
    <input type="hidden" name="P" value="<%=req("P")%>" />

    <div class="panel mt25">
        <div class="panel-body">
            <div class="row">
                <%= quickfield("text", "Titulo", "Título", 6, reg("Titulo"), "", "", " required ") %>
                <%= quickfield("datepicker", "Inicio", "Data Início", 3, reg("Inicio"), "", "", " required ") %>
                <%= quickfield("datepicker", "Fim", "Data Fim", 3, reg("Fim"), "", "", " required ") %>
            </div>
            <div class="row">
                <%
                UnidadesLicencas = reg("UnidadesLicencas")
                Perfis = reg("Perfis")
                Texto = reg("Texto")
                Especialidades = reg("Especialidades")
                TipoExibicao = reg("TipoExibicao")
                if session("Banco")="clinic105" or session("Banco")="clinic5459" then
                    call quickfield("multiple", "UnidadesLicencas", "Licenças", 3, UnidadesLicencas, "select id, concat(id, ' - ', ifnull(NomeEmpresa, NomeContato)) NomeEmpresa from cliniccentral.licencas where Status IN ('B', 'C') ORDER BY ifnull(NomeEmpresa, NomeContato)", "NomeEmpresa", " required ")
                else
                    call quickfield("multiple", "UnidadesLicencas", "Unidades", 3, UnidadesLicencas, "select id, NomeFantasia from vw_unidades where sysActive=1 order by NomeFantasia", "NomeFantasia", " required ")
                end if
                call quickfield("multiple", "Perfis", "Perfis", 3, Perfis, "SELECT * FROM (SELECT Perfil id, CONCAT('Tipo: ', Perfil) Perfil from cliniccentral.avisosperfis) t UNION ALL ( SELECT id, CONCAT('Permissão: ', Regra) FROM regraspermissoes ORDER BY Regra )", "Perfil", " required ")
                call quickfield("multiple", "Especialidades", "Especialidades", 3, Especialidades,  "select * from especialidades where sysActive=1 order by especialidade", "especialidade", "")
                call quickfield("simpleSelect", "TipoExibicao", "Tipo de Exibição", 3, TipoExibicao, "select * from cliniccentral.avisostipoexibicao WHERE ID IN (2)", "TipoExibicao", " semVazio ")
                %>
                <%= quickfield("editor", "Texto", "Texto", 12, Texto, "500", "", " required ") %>
            </div>
        </div>
    </div>
</form>

<%
set vcaLido = db.execute("select al.*, lu.Nome, u.NomeFantasia Unidade from avisosleitura al LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=al.sysUser LEFT JOIN vw_unidades u ON u.id=al.UnidadeID WHERE al.AvisoID="& req("I"))
if not vcaLido.eof then
    %>
    <div class="panel">
        <div class="panel-heading"><i class='fa fa-check text-success'></i> Marcado como lido por</div>
        <div class="panel-body">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Nome</th>
                        <th>Data</th>
                        <th>Unidade</th>
                    </tr>
                </thead>
                <tbody>

                <%
                while not vcaLido.eof
                    %>
                    <tr>
                        <td><i class="fa fa-check text-success"></i> <%= vcaLido("Nome") %></td>
                        <td><%= vcaLido("sysDate") %></td>
                        <td><%= vcaLido("Unidade") %></td>
                    </tr>
                    <%
                vcaLido.movenext
                wend
                vcaLido.close
                set vcaLido = nothing
                %>
                </tbody>
            </table>
        </div>
    </div>
    <%
end if
%>

<script type="text/javascript">
$(document).ready(function(e) {
	<%call formSave("frm", "save", "")%>
});

</script>
<!--#include file="disconnect.asp"-->