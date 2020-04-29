<!--#include file="connect.asp"-->
<%
licencaID = replace(session("Licencas"),"|","")
userID = session("user")
pageURL = req("refURL")
videoID = req("v")
avaliacao = req("avaliacao")

form_comentario = request.form("comentario")

For Each item in Session.Contents
  'Response.Write "<pre>"&item & " = " & Session.Contents(item) & "</pre>"
Next 

if avaliacao <> "" or form_comentario<> "" then

  if avaliacao <> "" then
    valorUpdateSQL = "`avaliacao`='"&avaliacao&"'"
    colunaInsertSQL = "`avaliacao`"
    colunaValorInsertSQL = "'"&avaliacao&"'"
  end if
  if form_comentario<>"" then
    valorUpdateSQL = "`comentario`='"&form_comentario&"'"
    colunaInsertSQL = "`comentario`"
    colunaValorInsertSQL = "'"&form_comentario&"'"
  end if

  'COMENTÁRIOS FOI DESMEMBRADO DA AVALIAÇÃO (LIKE vs DISLIKE)
  if avaliacao <> "" then

    set vAvaliacao = db.execute("select id from cliniccentral.vt_avaliacoes where LicencaID like '"&licencaID&"' AND usuarioID LIKE '"&userID&"' AND vt_video_id like '"&videoID&"' order by id DESC limit 0,1")
    if vAvaliacao.eof then

      acaoSQL = "INSERT INTO `cliniccentral`.`vt_avaliacoes`"_
      &" (`vt_video_id`, "&colunaInsertSQL&", `LicencaID`, `usuarioID`, `ref_url`, `sysDate`)"_
      &" VALUES"_
      &" ('"&videoID&"', "&colunaValorInsertSQL&", '"&licencaID&"', '"&userID&"', from_base64('"&pageURL&"'), NOW() );"

      msgAcao = "Avaliação foi registrada com sucesso"
    else

      vt_avaliacoes_id = vAvaliacao("id")

      acaoSQL = "UPDATE `cliniccentral`.`vt_avaliacoes`"_
      &" SET "&valorUpdateSQL&",ref_url=from_base64('"&pageURL&"'),sysDate=NOW() WHERE `id`='"&vt_avaliacoes_id&"';"
      


      msgAcao = "Avaliação modificada com sucesso!"
    end if
  end if
  'NÃO EXISTE MAIS LIMITE DE COMENTÁRIOS
  if form_comentario<>"" then
    set vAvaliacao = db.execute("select avaliacao from cliniccentral.vt_avaliacoes where LicencaID like '"&licencaID&"' AND usuarioID LIKE '"&userID&"' AND vt_video_id like '"&videoID&"' order by id DESC limit 0,1")
    avaliacaoUltima = vAvaliacao("avaliacao")


    acaoSQL = "INSERT INTO `cliniccentral`.`vt_avaliacoes`"_
      &" (`vt_video_id`, avaliacao, "&colunaInsertSQL&", `LicencaID`, `usuarioID`, `ref_url`, `sysDate`)"_
      &" VALUES"_
      &" ('"&videoID&"','"&avaliacaoUltima&"', "&colunaValorInsertSQL&", '"&licencaID&"', '"&userID&"', from_base64('"&pageURL&"'), NOW() );"
  end if
  'response.write(acaoSQL)
  db.execute(acaoSQL)
  
  response.write(msgAcao)

end if
%>