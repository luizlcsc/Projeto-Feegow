<!--#include file="connect.asp"-->
<!--#include file="Classes/Base64.asp"-->


<%
sDev = 0

videoIdDefault = 1
licencaID = replace(session("Licencas"),"|","")
userID = session("user")


refURL = req("refURL")&""

if refURL<>"" then
  whereRef = " url_interna LIKE FROM_BASE64('"&refURL&"') "
else
  whereRef = " vid.id LIKE '"&videoIdDefault&"'" 'VÍDEO DE DEMONSTRAÇÃO
  
  
end if

videoQ = ""_
&" SELECT"&Chr(13)_
&" vid.*"&Chr(13)_
&" ,ser.url,ser.servidor"&Chr(13)_
&" FROM cliniccentral.vt_videos AS vid"&Chr(13)_
&" LEFT JOIN cliniccentral.vt_servidores AS ser ON ser.vt_video_id = vid.id"&Chr(13)_
&" WHERE "&whereRef

if sDev = 1 then
  response.write("<pre>"&videoQ&"</pre>")
end if
set videoSQL = db.execute(videoQ)
if videoSQL.eof then
  erro = 1

  vt_id = videoIdDefault
  vt_video         = "Introdução Feegow "
  vt_assunto       = ""
  vt_previa        = "Conheça o Feegow Clinic e veja como ele pode ajudar nas rotinas diárias."

  vt_url      = "9wBNQ5euOu8"

  
  logsVideoID = 0
else
  erro = 0
  
  vt_id         = videoSQL("id")
  vt_video         = videoSQL("video")
  vt_assunto       = videoSQL("assunto")
  vt_previa        = videoSQL("previa")

  vt_url      = videoSQL("url")
  vt_servidor = videoSQL("servidor")

  logsVideoID = vt_id
  videoSQL.close
  set videoSQL = nothing
end if

'RESGISTRA LOGS DOS VIDEOS PARA FILTRAR VIDEOS NÃO ENCONTRADOS

acaoSQL = "INSERT INTO `cliniccentral`.`vt_logs`"_
&" (`vt_video_id`, `LicencaID`, `usuarioID`, `ref_url`, `sysDate`)"_
&" VALUES"_
&" ('"&logsVideoID&"', '"&licencaID&"', '"&userID&"', from_base64('"&refURL&"'), NOW() );"

db.execute(acaoSQL)

url_interna   = req("P")

tipoAvaliacaoCSS = ""
vt_avaliacoes_comentario = ""

avaliacaoAtualQ = "select avaliacao,comentario from cliniccentral.vt_avaliacoes where vt_video_id like '"&vt_id&"' AND ref_url like '"&refURL&"' AND LicencaID like '"&licencaID&"' AND usuarioID LIKE '"&userID&"'"
if sDev=1 then
  response.write("<pre>"&avaliacaoAtualQ&"<pre>")
end if
set avaliacaoAtualSQL = db.execute(avaliacaoAtualQ)
if not avaliacaoAtualSQL.eof then
  vt_avaliacoes_comentario = avaliacaoAtualSQL("comentario")

  if avaliacaoAtualSQL("avaliacao") = 1 then
    avaliacaoBom = "vt_avaliacaoBom"
    avaliacaoRuim = ""
    
    vt_avaliacoes_comentario = "x"
  elseif avaliacaoAtualSQL("avaliacao") = 2 then
    avaliacaoBom = ""
    avaliacaoRuim = "vt_avaliacaoRuim"

  end if
end if
avaliacaoAtualSQL.close
set avaliacaoAtualSQL = nothing
%>


<style type="text/CSS">
.vt_avaliacao {font-size:16px;padding:0px 5px;color:#ccc}
.vt_avaliacao:hover {color:#000;cursor:pointer}
.vt_espacamento{margin:10px 0;}

.vt_avaliacaoBom {color:blue;}
.vt_avaliacaoRuim {color:red;}
<%'=tipoAvaliacaoCSS%>

</style>

<div class="row vt_espacamento">
  <div class="col-md-12">
    <div class="panel panel-tile text-center br-a br-grey">
      <h2><%=vt_video%></h2>
      <div class="panel-body">
        <div id="ytplayer"></div>
      </div>
      <div class="panel-footer br-t p12 text-left">
          <div class="avaliacoes">
            <a id="avaliacaoBom"><i class="fa fa-thumbs-o-up vt_avaliacao <%=avaliacaoBom%>"></i></a>
            <a id="avaliacaoRuim"><i class="fa fa-thumbs-o-down vt_avaliacao <%=avaliacaoRuim%>"></i></a>
            
            <input class="input-sm" type="text" name="comentario" id="comentario" placeholder="o que achou deste vídeo?" value="<%=vt_avaliacoes_comentario%>">
            <button type="button" class="btn btn-sm btn-success" id="btnSalvarComentario">
                <i class="fa fa-save"></i> Salvar
            </button>
          </div>
      </div>
      <h2>Outros vídeos</h2>
      <!--#include file="VideoTutorialMenu.asp"-->
    </div>
  </div>
  
</div>



<script>

// Load the IFrame Player API code asynchronously.
if (tag) onYouTubePlayerAPIReady();

var tag = document.createElement('script');
tag.src = "https://www.youtube.com/player_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);


var player;
function onYouTubePlayerAPIReady() {
  
  player = new YT.Player('ytplayer', {
    height: '360',
    width: '640',
    videoId: '<%=vt_url%>',
    events: {
      'onStateChange': onPlayerStateChange
    },
    playerVars: {
      rel: 0,       // não exibir videos relacionados ao final
      showinfo: 1,  // ocultar informações do video
      autoplay: 0   // play automático
    }
  });
}

//TEMPO ASSISTIDO
function onPlayerStateChange(event) {
    switch(event.data) {
        case 0:
            //alert('vídeo acabou');
            break;
        case 1:
            //alert('começou em '+player.getCurrentTime());
            break;
        case 2:
            //alert('pausado em '+player.getCurrentTime());
            break;
    }
}

  
//AVALIAÇÕES
$(function () {
    $('#avaliacaoBom').on('click', function () {
      var Status = $(this).val();
      $.ajax({
          url: 'VideoTutorialComentario.asp?refURL=<%=Base64Encode(refURL)%>',
          data: 'avaliacao=1&v=<%=vt_id%>',
          dataType : 'html'
      });
      $("#avaliacaoRuim > i").removeClass("vt_avaliacaoRuim");
      $("#avaliacaoBom > i").addClass("vt_avaliacaoBom");
    });
    $('#avaliacaoRuim').on('click', function () {
      var Status = $(this).val();
      $.ajax({
          url: 'VideoTutorialComentario.asp?refURL=<%=Base64Encode(refURL)%>',
          data: 'avaliacao=2&v=<%=vt_id%>',
          dataType : 'html'
      });
      $("#avaliacaoBom > i").removeClass("vt_avaliacaoBom");
      $("#avaliacaoRuim > i").addClass("vt_avaliacaoRuim");
    });

    $('#btnSalvarComentario').on('click', function () {
        var Status = $(this).val();
        
        $.ajax({
          url: 'VideoTutorialComentario.asp?refURL=<%=Base64Encode(refURL)%>&v=<%=vt_id%>',
          type: 'post',
          data: $("input[name='comentario']")
            
        });
      });

});




//showMessageDialog("Salvou com sucesso!!!!", 5000);
</script>