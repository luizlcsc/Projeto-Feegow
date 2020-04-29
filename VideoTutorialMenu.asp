<!--#include file="connect.asp"-->
<!--#include file="Classes/Base64.asp"-->
<%
playListsHTML = ""
if req("refURL")<>"" then
  url_interna = base64Decode(req("refURL"))
end if

playlistsQ = " SELECT DISTINCT vid.vt_playlists_id,pla.playlist FROM cliniccentral.vt_videos AS  vid"&chr(13)_
&" LEFT JOIN cliniccentral.vt_playlists AS pla ON pla.id = vid.vt_playlists_id"&chr(13)_
&" WHERE vid.url_interna IS NOT NULL"&chr(13)_
&" ORDER BY vid.vt_playlists_id ASC"&chr(13)
'response.write("<pre>"&playlistsQ&"</pre>")

set playlistsSQL = db.execute(playlistsQ)
if not playlistsSQL.eof then
  while not playlistsSQL.eof

    vt_playlists_id = playlistsSQL("vt_playlists_id")
    vt_playlists_playlist = playlistsSQL("playlist")

    videosQ = " SELECT vtPla.*"_
    &" ,to_base64(vtVid.url_interna) AS url_interna, vtVid.video, vtVid.previa"&chr(13)_
    &" ,vtSer.url"&chr(13)_
    &" from cliniccentral.vt_playlists AS vtPla"&chr(13)_
    &" LEFT JOIN cliniccentral.vt_videos AS vtVid ON vtVid.vt_playlists_id = vtPla.id"&chr(13)_
    &" LEFT JOIN cliniccentral.vt_servidores AS vtSer ON vtSer.vt_video_id = vtVid.id"&chr(13)_
    &" WHERE vtPla.id LIKE '"&vt_playlists_id&"'"&chr(13)_
    &" ORDER BY vtPla.id"    
    'response.write("<pre>"&videosQ&"</pre>")

    playListHTML = ""_
    &"          <div class='panel-heading'>"&chr(13)_
    &"            <a class='' data-toggle='collapse' data-parent='#accordion' href='#accord"&vt_playlists_id&"' aria-expanded='true'>"&chr(13)_
    &               vt_playlists_playlist&chr(13)_
    &"            </a>"&chr(13)_
    &"          </div>"&chr(13)

    set videosSQL = db.execute(videosQ)
    while not videosSQL.eof

      vt_videos_video = videosSQL("video")
      vt_videos_previa = videosSQL("previa")
      vt_videos_url_interna = videosSQL("url_interna")

      vt_servidores_url = videosSQL("url") 'PADRÃO YOUTUBE

      videoURL = "http://www.youtube.com/embed/"&vt_servidores_url

      videoContent = videoContent&""_
      &"<div>"_
      &"<a href='"&videoURL&"' class='atualizaVideo' style='text-decoration:none'>"_
      &"  <img style='margin-right:10px' class='pull-left thumbnail' width='90' src='https://i.ytimg.com/vi/"&vt_servidores_url&"/hqdefault.jpg'/>"_
      &"  <h2 style='color:#606c7d;font-size:16px'>"&vt_videos_video&"</h2>"_
      &"  <p style='color:#7C8CA2'>"&vt_videos_previa&"</p>"_
      &"</a>"_
      &"</div><div class='clearfix'></div>"

    videosSQL.movenext
    wend
    videosSQL.close
    set videosSQL = nothing

    set vClass = db.execute("SELECT vid.vt_playlists_id FROM cliniccentral.vt_videos AS vid WHERE vid.url_interna LIKE FROM_BASE64('"&req("refURL")&"') ")
      if vClass.eof then
        classColapse = "out"
      else
        playListAtual = vClass("vt_playlists_id")
        if playListAtual = vt_playlists_id then
          classColapse = "in"
        else
          classColapse = "out"  
        end if
      end if
      

      
    
    videoHeader = playListHTML&""_
    &"  <div id='accord"&vt_playlists_id&"' class='panel-collapse collapse "&classColapse&"' style='' aria-expanded='true'>"&chr(13)_
    &"    <div class='panel-body'>"&chr(13)

    videoFooter = ""_
    &"    </div>"&chr(13)_
    &"  </div>"&chr(13) 
    
    if videoContentHTML = "" then
    
      videoContentHTML = videoHeader&videoContent&videoFooter
    else
      videoContentHTML = videoContentHTML&videoHeader&videoContent&videoFooter
    end if
    'response.write(videoHeader&videoContent&videoFooter)

    videoHeader   = ""
    videoFooter   = ""  
    videoContent  = ""

    'videoContentHTML = playListHTML&videoHTML

  playlistsSQL.movenext
  wend
  playlistsSQL.close
  set playlistsSQL = nothing
end if

videoHeaderHTML = ""_
&"  <div class='row'>"&chr(13)_
&"      <div class='panel-group accordion' id='accordion'>"&chr(13)_
&"        <div class='panel'>"&chr(13)

videoFooterHTML = ""_
&"        </div>"&chr(13)_
&"      </div>"&chr(13)_
&"    </div>"

videoHTML = videoHeaderHTML&videoContentHTML&videoHeaderHTML

response.write(videoHTML)
%>