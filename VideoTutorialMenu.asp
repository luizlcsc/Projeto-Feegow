<!--#include file="connect.asp"-->
<%
playListsHTML = ""
videoHTML = ""
url_interna = replace(request.querystring(),"'","''")

playlistsQ = "SELECT vtPla.*,vtVid.url_interna from cliniccentral.vt_playlists AS vtPla"_
&" LEFT JOIN cliniccentral.vt_videos AS vtVid ON vtVid.vt_playlists_id = vtPla.id"_
&" WHERE vtVid.url_interna LIKE '"&url_interna&"'"_
&" GROUP BY vtPla.id"

set playlistsSQL = db.execute(playlistsQ)
if not playlistsSQL.eof then
  while not playlistsSQL.eof

    vt_playlists_id = playlistsSQL("id")
    vt_playlists_playlist = playlistsSQL("playlist")

    videosQ = ""_
    &" SELECT"_
    &" vid.*"_
    &" ,ser.url,ser.servidor"_
    &" FROM cliniccentral.vt_videos AS vid"_
    &" LEFT JOIN cliniccentral.vt_servidores AS ser ON ser.vt_video_id = vid.id"_    
    &" WHERE vid.vt_playlists_id LIKE '"&vt_playlists_id&"'"
    
    'response.write(videosQ&"<br>")
    set videosSQL = db.execute(videosQ)
    if videosSQL.eof then
      videoHTML = ""_
      &"<tr>"_
      &"  <td colspan='2'> <i>Ops!<br>Não existem vídeos nesta categoria</i> </td>"_
      &"</tr>"
    else
      
      while not videosSQL.eof
        vt_video_videos = videosSQL("video")
        vt_video_previa = videosSQL("previa")
        vt_video_url_interna = videosSQL("url_interna")
        vt_servidores = videosSQL("url")

        videoURL = "/?P=VideoTutorial&Pers=1&v=3"

        if vt_video_url_interna <> url_interna then
          videoHTML = videoHTML&""_
          &"            <tr>"_
          &"              <td width='120'>"_
          &"                <a href='./"&videoURL&"'>"_
          &"                  <img src='https://i.ytimg.com/vi/"&vt_servidores&"/hqdefault.jpg' width='120'>"_
          &"                </a>"_

          &"              </td>"_
          &"              <td valign='top'>"_
          &                 "<h3 class='text-left' style='padding:0;margin:0'>"&vt_video_videos&"</h3>"_
          &                 "<p class='text-left'>"&vt_video_previa&"</p>"_        
          &"                <div class='progress mt10'>"_
          &"                  <div class='progress-bar progress-bar-primary progress-bar-striped' role='progressbar' aria-valuenow='90' aria-valuemin='0' aria-valuemax='100' style='width: 90%;'>"_
          &"                    90%"_
          &"                  </div>"_
          &"                </div>"_
          &"              </td>"_
          &"            </tr>"
        end if


      videosSQL.movenext
      wend
      videosSQL.close
      set videosSQL = nothing
    end if


    playListsHTML = playListsHTML&""_
    &"  <div class='panel'>"_
    &"    <div class='panel-heading'>"_
    &"      <a class='accordion-toggle accordion-icon link-unstyled collapsed' data-toggle='collapse' data-parent='#accordion' href='#accordPlay"&vt_playlists_id&"' aria-expanded='false'>"_
    &       vt_playlists_playlist&""_
    &"      </a>"_
    &"    </div>"_
    &"    <div id='accordPlay"&vt_playlists_id&"' class='panel-collapse collapse' style='height: 0px;' aria-expanded='false'>"_
    &"      <div class='panel-body'>"_
    &"        <table class='table'>"_
    &           videoHTML&""_
    &"        </table>"_
    &"      </div>"_
    &"    </div>"_
    &"  </div>"

  videoHTML = ""
  
  playlistsSQL.movenext
  wend
end if
playlistsSQL.close
set playlistsSQL = nothing
%>

<div class="panel-group accordion" id="accordion">
  <%=playListsHTML%>
</div>