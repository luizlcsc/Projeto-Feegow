<!--#include file="connect.asp"-->
<%
PacienteID = req("PacienteID")
Acao = req("A")
ID = req("I")

if Acao="A" or Acao="I" then
    set reg = db.execute("select id from pacientescurva where PacienteID="& PacienteID &" ORDER BY Data, id")
    while not reg.eof
        ID = reg("id")
        db.execute("update pacientescurva set Peso="& treatvalnull(ref("Peso"& ID)) &", Altura="& treatvalnull(ref("Altura"& ID)) &", PerimetroCefalico="& treatvalnull(ref("PerimetroCefalico"& ID)) &", Data="& mydatenull(ref("Data"& ID)) &" where id="& ID)
    reg.movenext
    wend
    reg.close
    set reg = nothing
    if Acao="I" then
        db.execute("insert into pacientescurva set PacienteID="& PacienteID &", Data=curdate(), sysUser="& session("User"))
    else
    %>
    <script>
    curva(<%= PacienteID %>);
    </script>
    <%
    end if
elseif Acao="X" then
    db.execute("delete from pacientescurva where id="& ID)
end if
%>
<div class="panel-heading">
    <span class="panel-title">Valores para Curva de Evolução</span>
    <span class="panel-controls">
        <button type="button" class="btn btn-sm btn-default" onclick="$('#divCurvaValores').slideUp()">Fechar</button>
    </span>
</div>
<div class="panel-body">
    <form id="frmCurvaValores">
        <div class="row">
            <div class="col-xs-12">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Data</th>
                            <th>Peso (kg)</th>
                            <th>Altura (cm)</th>
                            <th>Per. Cefálico (cm)</th>
                            <th width="1%"></th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                    set reg = db.execute("select * from pacientescurva where PacienteID="& PacienteID &" ORDER BY Data, id")
                    while not reg.eof
                        %>
                        <tr>
                            <td><%= quickfield("datepicker", "Data"&reg("id"), "", 12, reg("Data"), "", "", "") %></td>
                            <td><%= quickfield("text", "Peso"&reg("id"), "", 12, fn(reg("Peso")), " input-mask-brl text-right ", "", "") %></td>
                            <td><%= quickfield("number", "Altura"&reg("id"), "", 12, reg("Altura"), " text-right ", "", "") %></td>
                            <td><%= quickfield("number", "PerimetroCefalico"&reg("id"), "", 12, reg("PerimetroCefalico"), " text-right ", "", "") %></td>
                            <td>
                                <button class="btn btn-danger btn-xs" type="button" onclick="curvaValores('X', <%= reg("id") %>)"><i class="far fa-remove"></i></button>
                            </td>
                        </tr>
                        <%
                    reg.movenext
                    wend
                    reg.close
                    set reg = nothing
                    %>
                    </tbody>
                </table>
            </div>
        </div>
    </form>
    <div class="row">
        <div class="col-xs-12 text-center">
            <button type="button" class="btn btn-xs btn-success" onclick="curvaValores('I', 0)"><i class="far fa-plus"></i> INSERIR</button>
            <button type="button" class="btn btn-xs btn-primary" onclick="curvaValores('A', 0)"><i class="far fa-save"></i> SALVAR</button>
        </div>
    </div>
</div>
<script type="text/javascript">
<!--#include file="JQueryFunctions.asp"-->
</script>