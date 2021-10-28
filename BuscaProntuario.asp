<!--#include file="connect.asp"-->
<%
q = req("q")
PacienteID = req("PacienteID")
De = req("De")
Ate = req("Ate")

q = replace(q,"'","")
q = replace(q,"\","")
%>
<style>
    em{
        color: #47d65c;
    }
</style>
<br>
<div class="panel">
    <div class="panel-body">
    <div class="row">
        <form method="get" id="frmBuscaProntuario" action="">
            <input type="hidden" name="P" value="BuscaProntuario">
            <input type="hidden" name="Pers" value="1">
            <%=quickfield("text", "q", "Termo", 3, q, "", "", "")%>
            <div class="col-md-3">
            <button class="btn btn-default btn-xs ResetaPacienteID" type="button"><i class="far fa-times"></i></button>
            <%= selectInsert("Paciente", "PacienteID", PacienteID, "pacientes", "NomePaciente", "", "", "") %>
            </div>
            <%=quickfield("datepicker", "De", "De", 2, De, " input-mask-date", "", "")%>
            <%=quickfield("datepicker", "Ate", "At&eacute;", 2, Ate, " input-mask-date", "", "")%>
            <div class="col-md-2">
            <br>
            <button class="btn btn-primary m5"><i class="far fa-search bigger-110"></i> Buscar</button>
            <button class="btn btn-success " name="Filtrate" onclick="downloadExcel()" type="button"><i class="far fa-table bigger-110"></i> Excel</button>

            </div>
            <div class="col-md-12 mt15">
            <%
            if aut("pacientesv")=1 then
            %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="FichaCadastral" name="Ficha" value="1"
                <% if req("Ficha")="1" then%>
                checked
                <%end if%>>
                  <label for="FichaCadastral"> Ficha cadastral</label>
              </div>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="Alteracoes" name="Alteracoes" value="1"
                <% if req("Alteracoes")="1" then%>
                checked
                <%end if%>>
                  <label for="Alteracoes"> Alterações de cadastro</label>
              </div>
              <%
              end if
              if aut("formsae")=1 then
            %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirAnamneseEvolucao" name="AE" value="1"
                <% if req("AE")="1" then%>
                checked
                <%end if%>>
                  <label for="ImprimirAnamneseEvolucao"> Anamnese e evolução</label>
              </div>
              <%
              end if

              if aut("formsl")=1 then
              %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirLaudosForms" name="L" value="1"
                    <% if req("L")="1" then%>
                    checked
                    <%end if%>>
                  <label for="ImprimirLaudosForms"> Laudos e Formulários</label>
              </div>
              <%
              end if

              if aut("prescricoes")=1 then
              %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirPrescricoes" name="Prescricao" value="1"
                  <% if req("Prescricao")="1" then%>
                  checked
                  <%end if%>>
                  <label for="ImprimirPrescricoes"> Prescrições</label>
              </div>
              <%
              end if

              if aut("diagnosticos")=1 then
              %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirDiagnosticos" name="Diagnostico" value="1"
                  <% if req("Diagnostico")="1" then%>
                  checked
                  <%end if%>>
                  <label for="ImprimirDiagnosticos"> Diagnósticos</label>
              </div>
              <%
              end if
              if aut("atestados")=1 then
              %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="ImprimirAtestados" name="Atestado" value="1"
                  <% if req("Atestado")="1" then%>
                  checked
                  <%end if%>>
                  <label for="ImprimirAtestados"> Atestados</label>
              </div>
              <%
              end if

              if aut("pedidosexame")=1 then
              %>
              <div class="checkbox-custom checkbox-default">
                  <input data-rel="tooltip" title="" type="checkbox" class="tooltip-danger PacienteImpressaoOpt" id="Pedido" name="Pedido" value="1"
                  <% if req("Pedido")="1" then%>
                  checked
                  <%end if%>>
                  <label for="Pedido"> Pedidos de Exame</label>
              </div>
              <%
              end if
            %>
            </div>
        </form>
<script >
$(".ResetaPacienteID").click(function() {
    $("#PacienteID").val("").trigger("change");
});
</script>
</div>

<%
DadosDemograficos=req("Ficha")
DadosClinicos="S"

function MontaQuery(Coluna)
    WhereClause = WhereClause&" OR `"&Coluna&"` LIKE '%"&q&"%'"
    SelectClause = SelectClause&" ,IF( `"&Coluna&"` LIKE '%"&q&"%',1,0)_"&Coluna
end function

function AplicaFiltros(ID,Dt)
    FiltrosPaciente=""
    if PacienteID<>"" then
        FiltrosPaciente = FiltrosPaciente&" AND "&ID&" ="&PacienteID
    end if
    if De<>"" and Dt<>"" then
        FiltrosPaciente = FiltrosPaciente&" AND "&Dt&" >="&mydatenull(De)
    end if
    if Ate<>"" and Dt<>"" then
        FiltrosPaciente = FiltrosPaciente&" AND "&Dt&" <="&mydatenull(Ate)
    end if
    AplicaFiltros=FiltrosPaciente
end function

if len(q)>1 then
%>
<div id="BuscaProntuarioConteudo">
<table class="table table-striped mt20">
<thead>
<tr>
    <th width="20%">
        Paciente
    </th>
    <th width="10%">
        Campo
    </th>
    <th width="10%">
        Data
    </th>
    <th width="60%">
        Resultado
    </th>
</tr>
</thead>
<%
    if DadosDemograficos="1" then
        set CamposPacienteSQL = db.execute("SELECT columnName FROM cliniccentral.sys_resourcesfields WHERE resourceID=1 AND fieldTypeID NOT IN (3,4,7)")
        if not CamposPacienteSQL.eof then

            WhereClause = "1=0"
            SelectClause = "*"


            Campos = Array()

            while not CamposPacienteSQL.eof
                Coluna = CamposPacienteSQL("columnName")
                MontaQuery(Coluna)
            CamposPacienteSQL.movenext
            wend
            CamposPacienteSQL.close
            set CamposPacienteSQL=nothing

            FiltrosPaciente=AplicaFiltros("id","")

            sql = "SELECT "&SelectClause&" FROM pacientes WHERE sysActive=1 AND ("&WhereClause&")"&FiltrosPaciente
            'response.write(sql)
            set ResultadosDemograficosSQL = db.execute(sql)
            if not ResultadosDemograficosSQL.eof then

                while not ResultadosDemograficosSQL.eof
                    set CamposPacienteSQL = db.execute("SELECT columnName,label FROM cliniccentral.sys_resourcesfields WHERE resourceID=1 AND fieldTypeID NOT IN (3,4,7)")
                    ColunaResultado=""
                    Resultado=""

                    while not CamposPacienteSQL.eof
                        Coluna = CamposPacienteSQL("columnName")
                        'response.write(Coluna)
                        if ResultadosDemograficosSQL("_"&Coluna)="1" then
                            ColunaResultado=CamposPacienteSQL("label")
                            Resultado = ResultadosDemograficosSQL(Coluna)
                            Resultado = replace(Resultado,q,"<em>"&q&"</em>")
                        end if
                    CamposPacienteSQL.movenext
                    wend
                    CamposPacienteSQL.close
                    set CamposPacienteSQL=nothing

                    %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ResultadosDemograficosSQL("id")%>&Pers=1"><%=ResultadosDemograficosSQL("NomePaciente")%></a>
        </td>
        <td>
            <%=ColunaResultado%>
        </td>
        <td>
            <%=ResultadosDemograficosSQL("sysDate")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
                    <%


                ResultadosDemograficosSQL.movenext
                wend
                ResultadosDemograficosSQL.close
                set ResultadosDemograficosSQL=nothing

            end if

        end if
    end if

    if DadosClinicos="S" then

    if req("Prescricao")="1" then
        'prescricoes
        sql = "SELECT presc.*, p.NomePaciente FROM pacientesprescricoes presc LEFT JOIN pacientes p ON p.id = presc.PacienteID WHERE presc.Prescricao LIKE '%"&q&"%'"

        FiltrosPaciente = AplicaFiltros("PacienteID","Data")
        sql = sql&FiltrosPaciente

        set ClinicosSQL = db.execute(sql)

        while not ClinicosSQL.eof

            Resultado = ClinicosSQL("Prescricao")
            Resultado = replace(Resultado,q,"<em>"&q&"</em>")
        %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ClinicosSQL("PacienteID")%>&Pers=1"><%=ClinicosSQL("NomePaciente")%></a>
        </td>
        <td>
            Prescrição
        </td>
        <td>
            <%=ClinicosSQL("Data")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
        <%
        ClinicosSQL.movenext
        wend
        ClinicosSQL.close
        set ClinicosSQL=nothing
    end if


    if req("Atestado")="1" then
     'atestados
        sql = "SELECT atest.*, p.NomePaciente FROM pacientesatestados atest LEFT JOIN pacientes p ON p.id = atest.PacienteID WHERE atest.Atestado LIKE '%"&q&"%'"
        FiltrosPaciente = AplicaFiltros("PacienteID","Data")

        sql = sql&FiltrosPaciente
        set ClinicosSQL = db.execute(sql)

        while not ClinicosSQL.eof

            Resultado = ClinicosSQL("Atestado")
            Resultado = replace(Resultado,q,"<em>"&q&"</em>")
        %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ClinicosSQL("PacienteID")%>&Pers=1"><%=ClinicosSQL("NomePaciente")%></a>
        </td>
        <td>
            Atestado
        </td>
        <td>
            <%=ClinicosSQL("Data")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
        <%
        ClinicosSQL.movenext
        wend
        ClinicosSQL.close
        set ClinicosSQL=nothing
    end if
    if req("Alteracoes")="1" then
     'atestados
        sql = "SELECT l.*, p.NomePaciente FROM log l LEFT JOIN pacientes p ON p.id = l.I WHERE (l.ValorAtual LIKE '%^%"&req("q")&"%' OR l.ValorAnterior LIKE '%^"&req("q")&"%' AND l.recurso='pacientes')"& AplicaFiltros("l.I","l.DataHora")
'response.write(s)
        sql = sql&FiltrosPaciente
        set ClinicosSQL = db.execute(sql)

        while not ClinicosSQL.eof

            Resultado = ""
            'Resultado = replace(Resultado,q,"<em>"&q&"</em>")
        %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ClinicosSQL("I")%>&Pers=1"><%=ClinicosSQL("NomePaciente")%></a>
        </td>
        <td>
            Alteração de cadastro
        </td>
        <td>
            <%=ClinicosSQL("DataHora")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
        <%
        ClinicosSQL.movenext
        wend
        ClinicosSQL.close
        set ClinicosSQL=nothing
    end if

    if req("Diagnostico")="1" then
     'diagnosticos
         if req("PacienteID")<>"" then
            FiltroPaciente = " AND cid.PacienteID="&req("PacienteID")
         end if
        sql = "SELECT cid.*,cidt.Codigo, p.NomePaciente, cidt.Descricao, cid.DataHora FROM pacientesdiagnosticos cid LEFT JOIN pacientes p ON p.id = cid.PacienteID LEFT JOIN cliniccentral.cid10 cidt ON cidt.id = cid.CidID WHERE (cid.Descricao LIKE '%"&q&"%' OR cidt.Descricao LIKE '%"&q&"%' OR cidt.Codigo LIKE '%"&q&"%')"&FiltroPaciente
        'response.write(sql)
        FiltrosPaciente = AplicaFiltros("PacienteID","DataHora")

        sql = sql&FiltrosPaciente
        set ClinicosSQL = db.execute(sql)

        while not ClinicosSQL.eof

            Resultado = ClinicosSQL("Codigo") & " " & ClinicosSQL("Descricao")
            Resultado = replace(Resultado,q,"<em>"&q&"</em>")
        %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ClinicosSQL("PacienteID")%>&Pers=1"><%=ClinicosSQL("NomePaciente")%></a>
        </td>
        <td>
            Diagnóstico
        </td>
        <td>
            <%=ClinicosSQL("DataHora")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
        <%
        ClinicosSQL.movenext
        wend
        ClinicosSQL.close
        set ClinicosSQL=nothing
    end if


    if req("Pedido")="1" then
     'pedidos
        sql = "SELECT atest.*, p.NomePaciente FROM pacientespedidos atest LEFT JOIN pacientes p ON p.id = atest.PacienteID WHERE atest.PedidoExame LIKE '%"&q&"%'"
        FiltrosPaciente = AplicaFiltros("PacienteID","Data")

        sql = sql&FiltrosPaciente
        set ClinicosSQL = db.execute(sql)

        while not ClinicosSQL.eof

            Resultado = ClinicosSQL("PedidoExame")
            Resultado = replace(Resultado,q,"<em>"&q&"</em>")
        %>
    <tr>
        <td>
            <a href="?P=pacientes&I=<%=ClinicosSQL("PacienteID")%>&Pers=1"><%=ClinicosSQL("NomePaciente")%></a>
        </td>
        <td>
            Pedido de exame
        </td>
        <td>
            <%=ClinicosSQL("Data")%>
        </td>
        <td>
            <%=Resultado%>
        </td>
    </tr>
        <%
        ClinicosSQL.movenext
        wend
        ClinicosSQL.close
        set ClinicosSQL=nothing
    end if

    if req("AE")="1" or req("L")="1"  then
        
        formSqlWhere = "(1,2)"
        if req("L")="1" then
            formSqlWhere = "(3, 4, 0) or isnull(Tipo)"
        end if

        set FormsSQL = db.execute("SELECT id, Nome FROM buiforms WHERE Tipo IN "&formSqlWhere)

            if not FormsSQL.eof then
                while not FormsSQL.eof
                set  FormColunasSQL = db.execute("SELECT COLUMN_NAME FROM information_schema.COLUMNS where TABLE_SCHEMA='"&session("Banco")&"' AND TABLE_NAME='_"&FormsSQL("id")&"' AND DATA_TYPE!='int'")

                WhereClause = "1=0"
                SelectClause = "*"

                while not FormColunasSQL.eof
                    Coluna = FormColunasSQL("COLUMN_NAME")
                    MontaQuery(Coluna)
                FormColunasSQL.movenext
                wend
                FormColunasSQL.close
                set FormColunasSQL=nothing

                FiltrosPaciente=AplicaFiltros("PacienteID","DataHora")
                
                set tabelaExiste = db.execute("SHOW TABLES LIKE '_"&FormsSQL("id")&"'")

                if not tabelaExiste.eof then

                    sql = "SELECT "&SelectClause&" FROM `_"&FormsSQL("id")&"` WHERE ("&WhereClause&")"&FiltrosPaciente

                    set FormsResultadoSQL = db.execute(sql)
                    if not FormsResultadoSQL.eof then
                        on error resume next
                        while not FormsResultadoSQL.eof
                            set CamposPacienteSQL = db.execute("SELECT COLUMN_NAME FROM information_schema.COLUMNS where TABLE_SCHEMA='"&session("Banco")&"' AND TABLE_NAME='_"&FormsSQL("id")&"' AND DATA_TYPE!='int'")
                            ColunaResultado=""
                            Resultado=""

                            while not CamposPacienteSQL.eof
                                Coluna = CamposPacienteSQL("COLUMN_NAME")
                                'response.write(Coluna)
                                if FormsResultadoSQL("_"&Coluna)="1" then
                                    ColunaResultado=CamposPacienteSQL("COLUMN_NAME")
                                    set NomeColuna = db.execute("SELECT RotuloCampo FROM buicamposforms WHERE id="&ColunaResultado)
                                    ColunaResultado=NomeColuna("RotuloCampo")
                                    Resultado = FormsResultadoSQL(Coluna)
                                    Resultado = replace(Resultado,q,"<em>"&q&"</em>")
                                end if
                            CamposPacienteSQL.movenext
                            wend
                            CamposPacienteSQL.close
                            set CamposPacienteSQL=nothing

                            set PacienteSQL = db.execute("SELECT id,NomePaciente FROM pacientes WHERE id="&FormsResultadoSQL("PacienteID"))

                            %>
                            <tr>
                                <td>
                                    <a href="?P=pacientes&I=<%=PacienteSQL("id")%>&Pers=1"><%=PacienteSQL("NomePaciente")%></a>
                                </td>
                                <td>
                                    <%=FormsSQL("Nome")%>
                                </td>
                            <td>
                                <%=FormsResultadoSQL("DataHora")%>
                            </td>
                                <td>
                                    <%=ColunaResultado&": "&Resultado%>
                                </td>
                            </tr>
                            <%

                        FormsResultadoSQL.movenext
                        wend
                        FormsResultadoSQL.close
                        set FormsResultadoSQL=nothing
                        set tabelaExiste=nothing
                        
                    end if
                end if

                        FormsSQL.movenext
                        wend
                        FormsSQL.close
                        set FormsSQL=nothing
            end if

    end if

    end if
%>
</table>
</div>
<%
else
    %>
    <br>
<div class="alert alert-default">
    Preencha pelo menos 2 caracteres para buscar.
</div>
    <%
end if
%>
    </div>
</div>
<form id="formExcel" method="POST">
    <input type="hidden" name="html" id="htmlTable">
</form>
<script type="text/javascript">

function downloadExcel(){
    $("#htmlTable").val($("#BuscaProntuarioConteudo").html());
    var tk = localStorage.getItem("tk");

    $("#formExcel").attr("action", domain+"reports/download-excel?title=BuscaProntuarioConteudo&tk="+tk).submit();
}

$(".crumb-active a").html("Resultados da Busca");
$(".crumb-link").removeClass("hidden");
$(".crumb-link").html("termo buscado: <em><%=q%></em>");
$(".crumb-icon").html("<i class='far fa-search'></i>");
$("#sidebar-search").val("<%=q%>");
</script>