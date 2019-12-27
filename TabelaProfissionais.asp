<!--#include file="connect.asp"-->
<!--#include file="Classes\Json.asp"-->
<%
Codigo = request.QueryString("Codigo")
Insert = request.QueryString("Insert")

IF ref("Nome") <> "" THEN

    sql = "INSERT INTO profissionalexterno(NomeProfissional,UFConselho,DocumentoConselho,Conselho,EspecialidadeID,sysActive) VALUES ('"&ref("Nome")&"','"&ref("Estado")&"','"&ref("Conselho")&"',1,'"&ref("EspecialidadeID")&"',1)"
    db.execute(sql)
    set profissionais = db.execute("SELECT * FROM profissionalexterno WHERE id = last_insert_id()")

    response.write(recordToJSON(profissionais))
    response.end
END IF

if Codigo<>"" then
    Response.AddHeader "Content-Type", "text/html;charset=UTF-8"

    Codigo = replace(Codigo," ","%")

    sql = " SELECT distinct Nome,Registro as Conselho,UF as Estado,                                                                                                                                                                 "&chr(13)&_
          "                 (SELECT id FROM profissionalexterno WHERE (profissionalexterno.UFConselho = UF AND profissionalexterno.DocumentoConselho = Conselho) OR UPPER(Nome) = UPPER(NomeProfissional) limit 1) as idProfissional"&chr(13)&_
          "                 ,COALESCE(profissionais_conselho.codigoTISS, especialidade.codigoTISS, especialidades.codigoTISS) codigoTISS, especialidades.id as EspecialidadeID                                                                                                                                 "&chr(13)&_
          " FROM cliniccentral.profissionais_conselho                                                                                                                                                                             "&chr(13)&_
          " LEFT JOIN cliniccentral.especialidade ON especialidade.id = profissionais_conselho.EspecialidadeID                                                                                                                      "&chr(13)&_
          " LEFT JOIN especialidades ON especialidades.codigo = especialidade.codigo                                                                                                                                                "&chr(13)&_
          " WHERE Nome like '%"&Codigo&"%' OR Registro like '%"&Codigo&"%' LIMIT 10;                                                                                                                                                "

    response.write(recordToJSON(db.execute(sql)))
    response.end
end if

%>
<!--#include file="disconnect.asp"-->