<!--#include file="connect.asp"-->
<%
ProfissionalID = req("I")

if req("A")="I" then
    db.execute("insert into profissionaisespecialidades (ProfissionalID) values ("&ProfissionalID&")")
end if
if req("A")="X" then
    db.execute("delete from profissionaisespecialidades where id="&req("E"))
end if

set esp = db.execute("select * from profissionaisespecialidades where ProfissionalID="&ProfissionalID)
while not esp.eof
    response.Write("<div class='col-md-12 row'>")
    response.write("<div class='col-md-3'>")
    response.write( selectInsert("Especialidade", "EspecialidadeID"&esp("id"), esp("EspecialidadeID"), "especialidades", "especialidade", "", "", "") )
    response.write("</div>")
    call quickField("text", "RQE"&esp("id"), "RQE", 2, esp("RQE"), "", "", "")
'    call quickField("simpleSelect", "EspecialidadeID"&esp("id"), "Especialidade", 3, esp("EspecialidadeID"), "select * from especialidades order by Especialidade", "Especialidade", "")
    call quickField("simpleSelect", "Conselho"&esp("id"), "Conselho", 2, esp("Conselho"), "select * from conselhosprofissionais order by codigo", "codigo", "")
    call quickField("text", "DocumentoConselho"&esp("id"), "Registro", 2, esp("DocumentoConselho"), "", "", "")
    call quickField("text", "UFConselho"&esp("id"), "UF", 2, esp("UFConselho"), "", "", " maxlength=2")
    response.Write("<div class='col-xs-1'><label>&nbsp;</label><br /><button onclick=""esps('X', "&esp("id")&")"" class=""btn btn-sm btn-default"" type=""button""><i class='far fa-minus'></i></button></div>")
    response.Write("<input type='hidden' name='Especialidades' value='"&esp("id")&"'>")
    response.Write("</div>")
esp.movenext
wend
esp.close
set esp=nothing
%>


