<!--#include file="connect.asp"-->
<!--#include file="Classes/Base64.asp"-->
<%
if req("refURL")<>"" then
  vRef = Base64Decode(req("refURL"))
end if

'***** GERA CONDIÇÕES PARA O FILTRO DOS VIDEOS POR PAGINA E/OU PARAMETRO
'Response.write(vRef&"<hr>")

vStringFull=Split(vRef,"&")
for each stringFull in vStringFull
  parametroValor = split(stringFull,"=")
    parametro = parametroValor(0)
    valor = parametroValor(1)

    if parametro = "P" then
      wherePagina = "pagina like '"&valor&"'"
      whereVariavel = "variavel = '' OR variavel IS NULL"
    else
      '****VALIDA SE EXISTE VARIAVEIS INICIO
      variavelCheckQ = " SELECT vid.variavel "&Chr(13)_
      & " FROM cliniccentral.vt_videos AS vid"&Chr(13)_
      & " Where ("& wherePagina&")"&Chr(13)_
      & " AND (variavel LIKE '"&parametro&"' OR variavel LIKE '"&parametro&"="&valor&"')"      
      'response.write("<pre>"&variavelCheckQ&"</pre>")
      set variavelCheckSQL = db.execute(variavelCheckQ)
      if not variavelCheckSQL.eof then
        whereVariavel = "variavel LIKE '"&parametro&"' OR variavel LIKE '"&parametro&"="&valor&"'"
      end if
      variavelCheckSQL.close
      set variavelCheckSQL = nothing
    end if
    '****VALIDA SE EXISTE VARIAVEIS FIM
    'response.write( "<pre>Parametro: "&parametro&" Valor: "&valor&"</pre>")
next
'response.write(whereVariavel)
'response.write("<hr>")

sDev = 0

videoIdDefault = 0
licencaID = replace(session("Banco"), "clinic", "")
userID = session("user")

if req("refURL") <> "" then
  validaURL = Base64Decode(req("refURL"))
end if

refURL = req("refURL")&""

if req("vID")<>"" then

  videoQ = ""_
  &" SELECT"&Chr(13)_
  &" vid.*"&Chr(13)_
  &" ,ser.url,ser.servidor"&Chr(13)_
  &" FROM cliniccentral.vt_videos AS vid"&Chr(13)_
  &" LEFT JOIN cliniccentral.vt_servidores AS ser ON ser.vt_video_id = vid.id"&Chr(13)_
  &" WHERE vid.id="& req("vID")
else
  videoQ = ""_
  &" SELECT"&Chr(13)_
  &" vid.*"&Chr(13)_
  &" ,ser.url,ser.servidor"&Chr(13)_
  &" FROM cliniccentral.vt_videos AS vid"&Chr(13)_
  &" LEFT JOIN cliniccentral.vt_servidores AS ser ON ser.vt_video_id = vid.id"&Chr(13)_
  &" WHERE ("&wherePagina&")"&Chr(13)_
  &" AND ("&whereVariavel&")"
end if

 ' response.write("<pre>"&videoQ&"</pre>")
set videoSQL = db.execute(videoQ)
if videoSQL.eof then
  erro = 1

  vt_id = videoIdDefault
  vt_video         = "Ops, vídeo não encontrado."
  vt_assunto       = ""
  vt_previa        = "<span style='font-size:18px' id='notFound'>Nossos produtores de conteúdo estão trabalhando na criação de novos vídeos.<br>Escolha um vídeo em nossa playlist ao lado. <script>$('#ytplayer').css('display', 'none');</script></span>"

  'vt_url      = "9wBNQ5euOu8"

  logsVideoID = 0
else
  erro = 0
  
  vt_id            = videoSQL("id")
  vt_video         = videoSQL("video")
  vt_assunto       = videoSQL("assunto")
  vt_previa        = videoSQL("previa")

  vt_url      = videoSQL("url")
  vt_servidor = videoSQL("servidor")


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

avaliacaoAtualQ = " select avaliacao,comentario from cliniccentral.vt_avaliacoes"&chr(13)_
&" where vt_video_id like '"&vt_id&"' AND ref_url like from_base64('"&refURL&"') AND LicencaID like '"&licencaID&"' AND usuarioID LIKE '"&userID&"'"&chr(13)_
&" order by id DESC"

'  response.write("<pre>"&avaliacaoAtualQ&"</pre>")

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
&" WHERE vt_video_id='"& vt_id &"' AND ava.LicencaID LIKE '"&licencaID&"' AND ava.usuarioID LIKE '"&userID&"'"&chr(13)_
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

<div class="panel">
  <div class="panel-heading">
    <span class="panel-title" id="titulo"><%=vt_video%></span>
    <span class="panel-controls" onclick="javascript:$('#videoaula').css('display', 'none')">
        <i class="far fa-remove"></i> Fechar
    </span>
  </div>
</div>



<div class="row">
  <div class="col-md-8" style="height:500px;overflow:auto;">
    <div class="panel">
      <div class="panel-body">
        <%
        if erro = 1 then
          response.write(vt_previa)
          response.write("<br><center><div id='ytplayer'></div></center>")
        else
        'CARREGA PLAYER
          response.write("<center><div id='ytplayer'></div></center>")
        end if
        %>
      </div>
      <%if erro=0 then%>
      <div class="panel-footer">
        <div class="row">
          <div class="col-md-12 text-center">
            
            <strong>Este vídeo foi útil para você</strong>
            <br>
            <%
            refURLAtual = req("refURL")
            %>
            <div class="avaliacoes">
              <a id="avaliacaoBom" data-toggle="tooltip" data-placement="top" data-original-title="Gostei do vídeo! ;-)"><i class="far fa-thumbs-o-up vt_avaliacao <%=avaliacaoBom%>"></i></a>
              <a id="avaliacaoRuim" data-toggle="tooltip" data-placement="top" data-original-title="Não gostei do vídeo! :-("><i class="far fa-thumbs-o-down vt_avaliacao <%=avaliacaoRuim%>"></i></a>
            </div> 
          </div>
          <div class="col-md-12">
            <strong>Deixe seu comentário</strong>
            <br>
            <textarea class="form-control" name="comentario" id="comentario" maxlength="200" minlength="10"></textarea>
            <button type="button" class="btn btn-sm btn-block btn-success" id="btnSalvarComentario">
                 Enviar comentário <i class="far fa-send"></i>
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
      <!--#include file="VideoTutorialMenu.asp"-->
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


$(".atualizaVideo").click(function(){
    $('#ytplayer').css('display', 'block');
    $('#notFound').css('display', 'none');
    $('#titulo').html( $(this).attr('data-titulo') );
    $("#refURLAtual").val( $(this).attr('id') );
    console.log(acaoSQL)
});

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
          url: 'VideoTutorialComentario.asp?refURL=<%=refURL%>',
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
          url: 'VideoTutorialComentario.asp?refURL=<%=refURL%>',
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
          url: 'VideoTutorialComentario.asp?refURL=<%=refURL%>&v=<%=vt_id%>',
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

$("#videosRecomendados").scrollTop( $("#video_<%= vt_id %>").position().top )

</script>
