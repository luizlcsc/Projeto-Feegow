<!--#include file="connect.asp"-->

<%
if request.form()<>"" then

    spl = split(req("C"), "_")
    FormID = replace(spl(0), "cd", "")
    CampoID = spl(1)
    Val2 = ref("V")

    PacienteID = ref("I")

    sql = "select id, ModeloID from buiformspreenchidos where ModeloID="& FormID &" AND PacienteID="& PacienteID &" order by id desc limit 1"
    ' response.write( sql )
    set vcaFP = db.execute( sql )
    if vcaFP.eof then
        db.execute("insert into buiformspreenchidos set ModeloID="& FormID &", PacienteID="& PacienteID &", sysUser="& session("User") &", sysActive=1")
        set vcaFP = db.execute( sql )
        db.execute("insert into `_"& vcaFP("ModeloID") &"` set PacienteID="& PacienteID &", sysUser="& session("User") &", `"& CampoID &"`='"& Val2 &"', id="& vcaFP("id"))
    else
        db.execute("update `_"& vcaFP("ModeloID") &"` set `"& CampoID &"`='"& Val2 &"' where id="& vcaFP("id"))
    end if

    response.end
end if

on error resume next

set formCD = db.execute("select * from buiforms where Tipo=5 and sysActive=1")
while not formCD.eof
    set reg = db.execute("select * from `_"& formCD("id") &"` where PacienteID="& req("I"))
    if autForm(formCD("id"), "IN", "") = true then
    %>
    <div class="panel">
        <div class="panel-heading">
            <span class="panel-title"><%= formCD("Nome") %></span>
        </div>
        <div class="panel-body">
            <div class="row">
            <%
            cCD = 0
            set camposCD = db.execute("select * from buicamposforms where FormID="& formCD("id"))
            while not camposCD.eof
                cCD = cCD + 1

                sql = ""
                if camposCD("TipoCampoID")=1 then
                    Tipo = "text"
                elseif camposCD("TipoCampoID")=2 then
                    Tipo = "datepicker"
                elseif camposCD("TipoCampoID")=6 then
                    Tipo = "simpleSelect"
                    sql = "select * from buiopcoescampos where CampoID="& camposCD("id")
                elseif camposCD("TipoCampoID")=8 then
                    Tipo = "memo"
                else
                    Tipo = "n"
                end if

                if not reg.eof then
                    val2 = reg(""& camposCD("id") &"")
                else
                    val2 = ""
                end if
                
                'response.write("{"& sql &"}<br>")
                if Tipo<>"n" then
                    call quickfield(Tipo, "cd"& formCD("id")&"_"& camposCD("id"), camposCD("RotuloCampo"), 4, val2, sql, "Nome", "")
                end if

                if cCD=3 then
                    cCD = 0
                    %>
                    </div>
                    <div class="row">
                    <%
                end if
                
            camposCD.movenext
            wend
            camposCD.close
            set camposCD = nothing
            %>
            </div>
        </div>
    </div>
    <%
    end if
formCD.movenext
wend
formCD.close
set formCD = nothing
%>
<script type="text/javascript">
    $("[id^='cd']").change(function(){
        $.post("pacientesDadosComplementares.asp?C="+ $(this).attr("id"), { V: $(this).val(), I:$("#PacienteID").val() }, function(data){
            eval(data);
        });
    });
</script>
