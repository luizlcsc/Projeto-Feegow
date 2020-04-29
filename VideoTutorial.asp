<!--#include file="connect.asp"-->
<!--#include file="Classes/Base64.asp"-->

<%
sDev = 0

videoIdDefault = 0
licencaID = replace(session("Licencas"),"|","")
userID = session("user")

if req("refURL") <> "" then
  validaURL = Base64Decode(req("refURL"))
end if

refURL = req("refURL")&""

videoQ = ""_
&" SELECT"&Chr(13)_
&" vid.*"&Chr(13)_
&" ,ser.url,ser.servidor"&Chr(13)_
&" FROM cliniccentral.vt_videos AS vid"&Chr(13)_
&" LEFT JOIN cliniccentral.vt_servidores AS ser ON ser.vt_video_id = vid.id"&Chr(13)_
&" WHERE url_interna LIKE FROM_BASE64('"&refURL&"')"

'response.write("<pre>"&videoQ&"</pre>")
if sDev = 1 then
  response.write("<pre>"&videoQ&"</pre>")
end if
set videoSQL = db.execute(videoQ)
if videoSQL.eof then
  erro = 1

  vt_id = videoIdDefault
  vt_video         = "Ops, vídeo não encontrado."
  vt_assunto       = ""
  vt_previa        = "Nossos produtores de conteúdo estão trabalhando na criação de novos vídeos.<br>Escolha um vídeo em nossa playlist ao lado."

  'vt_url      = "9wBNQ5euOu8"

  logsVideoID = 0
else
  erro = 0
  
  vt_id            = videoSQL("id")
  vt_video         = videoSQL("video")
  vt_assunto       = videoSQL("assunto")
  vt_previa        = videoSQL("previa")
  vt_url_ignorar   = videoSQL("url_ignorar")&""

  vt_url      = videoSQL("url")
  vt_servidor = videoSQL("servidor")

  if vt_url_ignorar<>"" then

    'VERIFICA SE EXISTE PARAMETROS QUE DEVEM SER IGNORADOS
    urlFull = refURL
    varIgnoreSplit=Split(urlFull,"|")
    varIgnoreCount = 0
    for each varIgnore in varIgnoreSplit
      if varIgnoreCount = 0 then
        refURL = replace(urlFull,varIgnore&"="&req(varIgnore),varIgnore&"=X")
      else
        refURL = replace(refURL,varIgnore&"="&req(varIgnore),varIgnore&"=X")
      end if
      
      varIgnoreCount = varIgnoreCount+1
    next

  end if

  'response.write(refURL)

  logsVideoID = vt_id
  videoSQL.close
  set videoSQL = nothing
end if

'response.end
'RESGISTRA LOGS DOS VIDEOS PARA FILTRAR VIDEOS NÃO ENCONTRADOS

acaoSQL = "INSERT INTO `cliniccentral`.`vt_logs`"_
&" (`vt_video_id`, `LicencaID`, `usuarioID`, `ref_url`, `sysDate`)"_
&" VALUES"_
&" ('"&logsVideoID&"', '"&licencaID&"', '"&userID&"', from_base64('"&refURL&"'), NOW() );"

db.execute(acaoSQL)

url_interna   = req("P")

tipoAvaliacaoCSS = ""
vt_avaliacoes_comentario = ""

avaliacaoAtualQ = "select avaliacao,comentario from cliniccentral.vt_avaliacoes where vt_video_id like '"&vt_id&"' AND ref_url like '"&refURL&"' AND LicencaID like '"&licencaID&"' AND usuarioID LIKE '"&userID&"' order by id DESC"
if sDev=1 then
  response.write("<pre>"&avaliacaoAtualQ&"</pre>")
end if
set avaliacaoAtualSQL = db.execute(avaliacaoAtualQ)
if not avaliacaoAtualSQL.eof then
  vt_avaliacoes_comentario = avaliacaoAtualSQL("comentario")

  if avaliacaoAtualSQL("avaliacao") = 1 then
    avaliacaoBom = "vt_avaliacaoBom"
    avaliacaoRuim = ""
    
    vt_avaliacoes_comentario = ""
  elseif avaliacaoAtualSQL("avaliacao") = 2 then
    avaliacaoBom = ""
    avaliacaoRuim = "vt_avaliacaoRuim"

  end if
end if
avaliacaoAtualSQL.close
set avaliacaoAtualSQL = nothing

comentariosHTML = "<strong>Últimos comentários</strong><br>"

comentariosQ = "SELECT * FROM cliniccentral.vt_avaliacoes AS ava"&chr(13)_
&"  WHERE ava.ref_url LIKE '"&refURL&"' AND ava.LicencaID LIKE '"&licencaID&"' AND ava.usuarioID LIKE '"&userID&"'"&chr(13)_
&" ORDER BY ava.id DESC limit 0,5"

'response.write("<pre>"&comentariosQ&"</pre>")
set comentariosSQL = db.execute(comentariosQ)
if comentariosSQL.eof then
  comentariosHTML = comentariosHTML&"<i>Nenhum comentário sobre este vídeo</i>"
else
  while not comentariosSQL.eof
    vt_avaliacoes_sysDate = comentariosSQL("sysDate")
    vt_avaliacoes_comentario = comentariosSQL("comentario")
  comentariosHTML = comentariosHTML&"<div class='text-right'><small><i>"&vt_avaliacoes_sysDate&"</i></small></div> <div>"&vt_avaliacoes_comentario&"</div><hr class='short alt'>"
  '&"<div class='col-md-6'>"_
  
  '&"</div>"

  comentariosSQL.movenext
  wend
end if

comentariosSQL.close
set comentariosSQL = nothing
%>


<style type="text/CSS">
.vt_avaliacao {font-size:20px;padding:0px 5px;color:#ccc}
.vt_avaliacao:hover {color:#000;cursor:pointer}
.vt_espacamento{margin:10px 0;}

.vt_avaliacaoBom {color:blue;}
.vt_avaliacaoRuim {color:red;}
<%'=tipoAvaliacaoCSS%>

</style>
<div class="row">
  <div class="col-md-8">
    <h2 style="margin-left:15px">Central de vídeos</h2>
  </div>
  <div class="col-md-4 text-right">
      <a href="javascript:$('#videoaula').css('display', 'none')" class="btn btn-sm btn-danger">
        <i class="fa fa-remove"></i>
      </a>
  </div>
</div>

<div class="row">
  <div class="col-md-8" style="height:450px;">
    <div class="panel">
      <div class="panel-heading">
        <span class="panel-title"><%=vt_video%></span>
      </div>
      <div class="panel-body">
        <%
        if erro = 1 then
          response.write(vt_previa)
          response.write("<br><div id='ytplayer'></div>")
        else
        'CARREGA PLAYER
          response.write("<div id='ytplayer'></div>")
        end if
        %>
      </div>
      <%if erro=0 then%>
      <div class="panel-footer">
        <div class="row">
          <div class="col-md-12 text-center">
            
            <strong>Faça a sua avaliação</strong>
            <br>
            <div class="avaliacoes">
              <a id="avaliacaoBom" data-toggle="tooltip" data-placement="top" data-original-title="Gostei do vídeo! ;-)"><i class="fa fa-thumbs-o-up vt_avaliacao <%=avaliacaoBom%>"></i></a>
              <a id="avaliacaoRuim" data-toggle="tooltip" data-placement="top" data-original-title="Não gostei do vídeo! :-("><i class="fa fa-thumbs-o-down vt_avaliacao <%=avaliacaoRuim%>"></i></a>
            </div> 
          </div>
          <div class="col-md-12">
            <strong>Deixe seu comentário</strong>
            <br>
            <textarea class="form-control" name="comentario" id="comentario"></textarea>
            <button type="button" class="btn btn-sm btn-block btn-success" id="btnSalvarComentario">
                 Enviar comentário <i class="fa fa-send"></i>
            </button>
          </div>
          
          
          <div class="col-md-12">
            <hr style="margin:5px 0">
            <%=comentariosHTML%>
          </div>
          
        </div>
        

      </div>
      <%end if%>
    </div>

  </div>
  <div class="col-md-4">
    <div class="panel">
      <div class="panel-heading">
        <span class="panel-title">Vídeos recomendados</span>
      </div>
      <div class="panel-body" style="height:450px;overflow:auto;">
        <!--#include file="VideoTutorialMenu.asp"-->
      </div>
    </div>
  </div>
</div>

<script>

//ALTERA O VIDEO
$(document).ready(function(){
    $(".atualizaVideo").click(function(e) {
        e.preventDefault();
        
        $("#ytplayer").attr("src", $(this).attr("href"));
    })
});

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

      new PNotify({
			title: 'Obrigado pela sua avaliação!',
			sticky: true,
			type: 'success',
            delay: 3000
		  });
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

      new PNotify({
			title: 'Obrigado pela sua avaliação! <br> Comente como podemos melhorar.',
			sticky: true,
			type: 'success',
            delay: 3000
		  });

    });

    $('#btnSalvarComentario').on('click', function () {
        var Status = $(this).val();
        
        $.ajax({
          url: 'VideoTutorialComentario.asp?refURL=<%=Base64Encode(refURL)%>&v=<%=vt_id%>',
          type: 'post',
          data: $("textarea[name='comentario']")
        });
        $("#btnSalvarComentario").addClass("disabled");
        
        new PNotify({
        title: 'Obrigado pelo seu comentário.',
        sticky: true,
        type: 'success',
              delay: 3000
        });
      });

});


//showMessageDialog("Salvou com sucesso!!!!", 5000);
</script>