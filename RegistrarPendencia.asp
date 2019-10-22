<!--#include file="connect.asp"-->
<%
UnidadeID = req("UnidadeID")
BuscaID = req("BuscaID")
Regiao = req("Regiao")

Contato = ref("Contato")
Acao = ref("A")

if Acao="I" then
    db.execute("INSERT INTO pendencias (UnidadeID,StatusID,BuscaID,PacienteID,Zonas,Requisicao,Contato,Turno,Datas,Horarios,ObsRequisicao,ObsContato,ObsTurno, sysUser) VALUES "&_
    " ("&treatvalzero(ref("UnidadeID"))&","& treatvalzero(ref("StatusID")) &","& treatvalzero(ref("BuscaID")) &","& treatvalzero(ref("PacienteID")) &",'"&ref("Zonas") &_
    "', '"& ref("Requisicao") &"', '"& ref("Contato") &"','"& ref("Turno") &"','"& ref("Datas") &"','"&ref("Horarios")&"','"&ref("ObsRequisicao")&"','"&ref("ObsContato")&"','"&ref("ObsTurno")&"', "&session("User")&")")

    Response.End
end if
%>

<div class="row">
    <div class="col-md-7">
        <input type="hidden" value="I" name="A">
        <input type="hidden" value="1" name="StatusID">
        <input type="hidden" value="<%=BuscaID%>" name="BuscaID">

        <%=quickField("empresa", "UnidadeID", "Unidade da pendência", "6", UnidadeID, "", "", "")%>
        <%= quickfield("multiple", "bRegiao", "Zona", 6, Regiao, "select '' id, 'Todas' Regiao UNION ALL select distinct Regiao id , Regiao  from sys_financialcompanyunits WHERE sysActive=1 AND Regiao is not null and Regiao!=''", "Regiao", " semVazio required") %>
        <%= quickfield("simpleSelect", "Requisicao", "Requisição", 6, Regiao, "select 'C' id, 'Clínica' Tipo UNION ALL SELECT 'P' id, 'Particular' Tipo UNION ALL select id , NomeConvenio Tipo from convenios WHERE sysActive=1", "Tipo", " semVazio required") %>

        <div class="col-md-6 mt5">
            <label for="">Contato</label>

            <br>
            <input type="radio" id="contato-paciente" name="Contato" value="S">
            <label for="contato-paciente">Paciente</label>

            <input type="radio" id="contato-outros" name="Contato" value="S">
            <label for="contato-outros">Outros</label>
        </div>

        <div class="col-md-12">
            <div class="row">
                <div class="col-md-6">
                    <label for="ObsRequisicao">Observações requisição</label>
                    <textarea name="ObsRequisicao" id="ObsRequisicao" class="form-control"></textarea>
                </div>

                <div class="col-md-6">
                    <label for="ObsContato">Observações contato</label>
                    <textarea name="ObsContato" id="ObsContato" class="form-control"></textarea>
                </div>
            </div>
        </div>

    </div>
    <div class="col-md-5">
        <div class="col-md-12">
        <%
        Server.Execute("CalendarioPendencia.asp")
        %>
        </div>

        <div class="col-md-12 mt5">
            <label for="">Turno</label>

            <br>
            <input type="checkbox" id="turno-manha" name="Turno">
            <label for="turno-manha">Manhã</label>

            <input type="checkbox" id="turno-noite" name="Turno">
            <label for="turno-noite">Tarde</label>
        </div>

        <div class="col-md-12">
            <label for="">Horários</label>
            <br>
            <%
            HoraInicio = cdate("07:00:00")
            HoraFim = cdate("21:00:00")

            while HoraInicio<HoraFim
                %>
                <div class="col-md-3">
                    <input name="Horarios" type="checkbox" id="Horario<%=left(HoraInicio, 5)%>" value="<%=left(HoraInicio, 5)%>"><label for="Horario<%=left(HoraInicio, 5)%>">&nbsp;<%=left(HoraInicio, 5)%></label>
                </div>
                <%
                HoraInicio = dateadd("n", 30, HoraInicio)
            wend
            %>
        </div>
    </div>


</div>

<script >
get$ComponentsForm().submit(function() {
    $.post("RegistrarPendencia.asp", $(this).serialize(), function() {
      
    });

    return false;
});
<!--#include file="jQueryFunctions.asp"-->
</script>