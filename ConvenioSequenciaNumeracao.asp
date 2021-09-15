<!--#include file="connect.asp"-->
<%
ConvenioID=req("ConvenioID")

if ref("AlterarNumeracao")="1" then
    db.execute("DELETE FROM tissguiaconsulta WHERE ConvenioID="&ConvenioID&" AND sysActive in (-1,2)")

    db.execute("INSERT INTO tissguiaconsulta (ConvenioID, NGuiaPrestador, sysActive) VALUES ("&ConvenioID&", '"&ref("Numeracao")&"', 2)")
end if

sqlMaiorGuia = "SELECT numero, tipo FROM ((SELECT cast(gc.NGuiaPrestador as signed integer)  numero, 'tissguiaconsulta' as tipo, sysDate FROM tissguiaconsulta gc WHERE gc.ConvenioID LIKE '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gs.NGuiaPrestador as signed integer)  numero, 'tissguiasadt' as tipo,sysDate FROM tissguiasadt gs WHERE gs.ConvenioID LIKE '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1) UNION ALL (SELECT cast(gh.NGuiaPrestador as signed integer)  numero, 'tissguiahonorarios' as tipo,sysDate FROM tissguiahonorarios gh WHERE gh.ConvenioID LIKE '"&ConvenioID&"' order by sysDate DESC, numero desc limit 1)) as numero ORDER BY sysDate DESC LIMIT 1"


set UltimaGuiaSQL = db.execute(sqlMaiorGuia)

UltimaGuia = 0

if not UltimaGuiaSQL.eof then
    UltimaGuia=UltimaGuiaSQL("numero")
end if

%>
<h3>Numeração atual:  <strong><%=UltimaGuia%></strong></h3>

<div class="row">
    <div class="col-md-3">
        <label for="AlterarSequenciaPara">Alterar sequência das guias</label>
        <input type="text" class="form-control" value="<%=UltimaGuia%>" id="AlterarSequenciaPara">
    </div>
    <div class="col-md-4">
        <br>
        <button class="btn btn-warning" onclick="AlterarNumeracaoDasGuias()">
            <i class="far fa-exclamation-triangle"></i> Alterar sequência
        </button>
    </div>
</div>

<br>

<h3>Últimas guias geradas</h3>
<table class="table">
    <thead>
        <tr>
            <th>Númeração</th>
            <th>Tipo</th>
            <th>Data e hora</th>
            <th>Usuário</th>
            <th>Paciente</th>
        </tr>
    </thead>
    <%

    sqlUltimasGuias="SELECT guia.id, guia.sysDate, guia.NGuiaPrestador, guia.sysUser, guia.Tipo, pac.NomePaciente, lu.Nome FROM "&_

                        " ( (SELECT id, sysDate, sysUser, 'Consulta' Tipo, PacienteID, NGuiaPrestador FROM tissguiaconsulta WHERE ConvenioID="&ConvenioID&" AND sysActive=1 ORDER BY sysDate DESC LIMIT 30) "&_
                        " UNION ALL (SELECT id, sysDate, sysUser, 'SADT' Tipo, PacienteID, NGuiaPrestador FROM tissguiasadt WHERE ConvenioID="&ConvenioID&" AND sysActive=1 ORDER BY sysDate DESC LIMIT 30) "&_
                        " UNION ALL (SELECT id, sysDate, sysUser, 'Honorarios' Tipo, PacienteID, NGuiaPrestador FROM tissguiahonorarios WHERE ConvenioID="&ConvenioID&" AND sysActive=1 ORDER BY sysDate DESC LIMIT 30) "&_

                        ")guia "&_
                        " LEFT   JOIN pacientes pac ON pac.id= guia.PacienteID"&_
                         " LEFT JOIN cliniccentral.licencasusuarios lu ON lu.id=guia.sysUser ORDER BY guia.sysDate DESC LIMIT 60"

    set UltimasGuiasSQL = db.execute(sqlUltimasGuias)

    if not UltimasGuiasSQL.eof then
        %>
        <tbody>
            <%
            while not UltimasGuiasSQL.eof

                ID = UltimasGuiasSQL("id")
                Numero = UltimasGuiasSQL("NGuiaPrestador")
                TipoGuia = "tissguia"&UltimasGuiasSQL("Tipo")

                LinkGuia = "<a target='_blank' href='?P="&TipoGuia&"&I="&ID&"&Pers=1'>"&Numero&"</a>"
            %>
            <tr>
                <td><%=LinkGuia%></td>
                <td><%=UltimasGuiasSQL("Tipo")%></td>
                <td><%=UltimasGuiasSQL("sysDate")%></td>
                <td><%=UltimasGuiasSQL("Nome")%></td>
                <td><%=UltimasGuiasSQL("NomePaciente")%></td>
            </tr>
            <%
            UltimasGuiasSQL.movenext
            wend
            UltimasGuiasSQL.close
            set UltimasGuiasSQL=nothing
            %>
        </tbody>
        <%
    end if
    %>
</table>
<script >
    function AlterarNumeracaoDasGuias() {
        var ConvenioID="<%=ConvenioID%>";
        var Numeracao = $("#AlterarSequenciaPara").val();

        if(confirm("Tem certeza que deseja mudar a sequência das guias?")){
            $.post("ConvenioSequenciaNumeracao.asp?ConvenioID="+ConvenioID, {
                Numeracao: Numeracao,
                AlterarNumeracao: 1
            }, function(data) {
                $("#divNumeracao").html(data);
            });
        }
    }
</script>