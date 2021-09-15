<!--#include file="connect.asp"-->
<!--#include file="Classes/Base64.asp"-->
<%
playListsHTML = ""
if req("refURL")<>"" then
  url_interna = base64Decode(req("refURL"))
  
  vStringFull=Split(url_interna,"&")
  for each stringFull in vStringFull
    parametroValor = split(stringFull,"=")
      parametro = parametroValor(0)
      valor = parametroValor(1)

      if parametro = "P" then
        pgPlaylist = valor        
      end if
      
  next
'response.write(pgPlaylist)
end if

if pgPlaylist = "" then
  playlistAtualWhere = "vid.id LIKE '"&req("vID")&"'"
else
  playlistAtualWhere = "vid.pagina LIKE '"&pgPlaylist&"'"
end if

playlistsQ = " SELECT vid.vt_playlists_id,pla.playlist"&chr(13)_
&" FROM cliniccentral.vt_videos AS vid"&chr(13)_
&" LEFT JOIN cliniccentral.vt_playlists AS pla ON pla.id = vid.vt_playlists_id"&chr(13)_
&" WHERE "&playlistAtualWhere
'response.write("<pre>"&playlistsQ&"</pre>")

set playlistsSQL = db.execute(playlistsQ)
if not playlistsSQL.eof then
  vt_playlists_id = playlistsSQL("vt_playlists_id")
  vt_playlists_playlist = playlistsSQL("playlist")

  playlistsSugestaoQ = " SELECT vid.id,vid.vt_playlists_id,pla.playlist FROM cliniccentral.vt_videos AS vid"&chr(13)_
  &" LEFT JOIN cliniccentral.vt_playlists AS pla ON pla.id = vid.vt_playlists_id"&chr(13)_
  &" WHERE vid.vt_playlists_id <> '"&vt_playlists_id&"'"&chr(13)_
  &" GROUP BY vid.vt_playlists_id"&chr(13)_
  &" ORDER BY pla.playlist, vid.ordem ASC"
  'response.write("<pre>"&playlistsSugestaoQ&"</pre>")

  set playlistsSugestaoSQL = db.execute(playlistsSugestaoQ)
  sugestaoPlaylistHTML = ""
  while not playlistsSugestaoSQL.eof
    sugestao_playlists_id = playlistsSugestaoSQL("vt_playlists_id")
    sugestao_playlists_playlist = playlistsSugestaoSQL("playlist")
    sugestao_video_id = playlistsSugestaoSQL("id")

    sugestaoPlaylist = ""_
    &"<div class='col-xs-6'>"_
    &"  <div class='bs-component'>"_
    &"    <a href='#' onclick='vidau(`VideoTutorial.asp?vID="&sugestao_video_id&"`, true, `Central de Vídeos`,``,`xl`,``)' class='btn btn-default btn-gradient dark btn-block'>"&sugestao_playlists_playlist&"</a>"_
    &"  </div>"_
    &"</div>"

    if sugestaoPlaylistHTML = "" then
      sugestaoPlaylistHTML = sugestaoPlaylist
    else
      sugestaoPlaylistHTML = sugestaoPlaylistHTML&sugestaoPlaylist
    end if

  playlistsSugestaoSQL.movenext
  wend
  playlistsSugestaoSQL.close
  set playlistsSugestaoSQL = nothing


  videosQ = " SELECT l.id AS logs_id, vtPla.*, vtVid.id as video_id, vtVid.vt_playlists_id "_
  &" ,to_base64(vtVid.pagina) AS pagina, vtVid.video, vtVid.previa"&chr(13)_
  &" ,vtSer.url"&chr(13)_
  &" from cliniccentral.vt_playlists AS vtPla"&chr(13)_
  &" LEFT JOIN cliniccentral.vt_videos AS vtVid ON vtVid.vt_playlists_id = vtPla.id"&chr(13)_
  &" LEFT JOIN cliniccentral.vt_servidores AS vtSer ON vtSer.vt_video_id = vtVid.id"&chr(13)_
  &" LEFT JOIN cliniccentral.vt_logs l ON l.vt_video_id=vtVid.id"&chr(13)_
  &" WHERE vtVid.sys_active like 1 AND vtPla.id LIKE '"&vt_playlists_id&"'"&chr(13)_
  & "AND (l.usuarioID='"&session("user")&"' OR ISNULL(l.usuarioID))"&chr(13)_
  &" GROUP BY vtVid.id"&chr(13)_
  &" ORDER BY vtPla.id"    

  'response.write("<pre>"&videosQ&"</pre>")

  set videosSQL = db.execute(videosQ)
  while not videosSQL.eof

    vt_videos_id = videosSQL("video_id")
    vt_videos_video = videosSQL("video")
    vt_videos_previa = videosSQL("previa")
    vt_videos_pagina = videosSQL("pagina")
    
    vt_videos_vt_playlists_id = videosSQL("vt_playlists_id")

    vt_servidores_url = videosSQL("url") 'PADRÃO YOUTUBE

    vt_logs_id = videosSQL("logs_id")
    if IsNull(vt_logs_id) then
      classCheck = ""
    else
      classCheck = "<i class='far fa-check-circle text-success'></i>"
    end if

    videoURL = "https://www.youtube.com/embed/"&vt_servidores_url&"?rel=0&amp;showinfo=1&amp;autoplay=0&amp;enablejsapi=1&amp;widgetid=2"

    videoContentHTML = videoContentHTML&""_
    &"<div>"_
    &"<a id='video_"&vt_videos_id&"' href='#' onclick='vidau(`VideoTutorial.asp?vID="&  vt_videos_id &"`, true, `Central de Vídeos`,``,`xl`,``)' style='text-decoration:none' data-titulo='"&vt_videos_video&"'>"_
    &"  <img style='margin-right:10px' class='pull-left thumbnail' width='90' src='https://i.ytimg.com/vi/"&vt_servidores_url&"/hqdefault.jpg'/>"_
    &"  <h2 style='color:#606c7d;font-size:16px'> "&classCheck&" " &vt_videos_video&"</h2>"_
    &"  <p style='color:#7C8CA2'>"&vt_videos_previa&"</p>"_
    &"</a>"_
    &"</div><div class='clearfix'></div>"

  videosSQL.movenext
  wend
  videosSQL.close
  set videosSQL = nothing

  playlistsSQL.close
  set playlistsSQL = nothing
end if

videoHeaderHTML = ""_
&" <div class='panel-heading'>"&chr(13)_
&"   <span class='panel-title'>"&vt_playlists_playlist&"</span>"&chr(13)_
&" </div>"&chr(13)_
&" <div class='panel-body' style='height:270px;overflow:auto;' id='videosRecomendados'>"

videoFooterHTML = "</div>"

videoHTML = videoHeaderHTML&videoContentHTML&videoFooterHTML

response.write(videoHTML)
%>
<br>
<div class='panel-heading'>
  <span class='panel-title'>Assista vídeos sobre</span>
</div>
<div class='panel-body' style='height:170px;overflow:auto;'>
  <div class="row" style>
  <%=sugestaoPlaylistHTML%>
  </div>
</div>

