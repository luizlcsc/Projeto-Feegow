
<style>
.btn-recording{
    display: block!important;
    animation-name: pulse;
    animation-duration: 1.5s;
    animation-iteration-count: infinite;
    animation-timing-function: linear;
}

.btn-record{
    right: 15px;
    bottom: 5px;
}

@keyframes pulse{
	0%{
		box-shadow: 0px 0px 5px 0px rgba(173,0,0,.3);
	}
	65%{
		box-shadow: 0px 0px 5px 3px rgba(173,0,0,.3);
	}
	90%{
		box-shadow: 0px 0px 5px 5px rgba(173,0,0,0);
	}
}
</style>
      <div class="reconhecimento hidden" style="position:fixed; right:0; bottom:0">
        <div id="info">
          <p id="info_speak_now" style="display:none">
            Por favor, fale...
          </p>
          <p id="info_no_speech" style="display:none">
            Nenhum som detectado. Verifique as configurações do seu microfone.
          </p>
          <p id="info_no_microphone" style="display:none">
            Nenhum microfone encontrado. Verifique as configurações do seu microfone.
          </p>
          <p id="info_allow" style="display:none">
            Clique em PERMITIR para autorizar o uso do seu microfone.
          </p>
          <p id="info_denied" style="display:none">
            Permission to use microphone was denied.
          </p>
          <p id="info_blocked" style="display:none">
            Sua permissão de uso do microfone está bloqueada. Ajuste em
            chrome://settings/contentExceptions#media-stream
          </p>
          <p id="info_upgrade" style="display:none">

          </p>
        </div>
        <div id="div_start">
          <button id="start_button" onclick="startButton(event)"><img alt="Start" id="start_img"
          src="assets/img/microphone.png"></button>
        </div>
        <div id="results">
          <input type="hidden" class="final" id="final_span"> <span class="interim hidden" id="interim_span"></span>
        </div>
        <div class="compact marquee" id="div_language">
          <select class="hidden" id="select_language" onchange="updateCountry()">
            </select>
            <select class="hidden" id="select_dialect">
            </select>
        </div>
      </div>
      <script type="text/javascript">
          function mdSpee(cid) {
              if(recognizing){
                if($("#speeFLD").val() != cid){
                  alert("gravação em curso, finalize para iniciar outra");
                  return;
                }
                paraEscuta(cid);
              }else{
                  iniciaEscuta(cid);
              }
          }

          function paraEscuta(cid){
                  let $speeBtn = $("#spee"+cid);
                  recognition.stop();
                  recognizing = false;
                  $speeBtn.removeClass("btn-recording");
                  $speeBtn.find("i").removeClass("fa-stop").addClass("fa-microphone");
          }

          function iniciaEscuta(cid){
                   $("#speeFLD").val(cid);

                  recognition.start();
                  recognizing = true;

                  let $speeBtn = $("#spee"+cid);
                  $speeBtn.find("i").removeClass("fa-microphone").addClass("fa-stop");
                  $speeBtn.addClass("btn-recording");
          }



var langs =
[['Português',       ['pt-BR', 'Brasil']]];

for (var i = 0; i < langs.length; i++) {
  select_language.options[i] = new Option(langs[i][0], i);
}
select_language.selectedIndex = 0;
updateCountry();
select_dialect.selectedIndex = 0;
showInfo('info_start');

function updateCountry() {
  for (var i = select_dialect.options.length - 1; i >= 0; i--) {
    select_dialect.remove(i);
  }
  var list = langs[select_language.selectedIndex];
  for (var i = 1; i < list.length; i++) {
    select_dialect.options.add(new Option(list[i][1], list[i][0]));
  }
  select_dialect.style.visibility = list[1].length == 1 ? 'hidden' : 'visible';
}

var final_transcript = '';
var recognizing = false;
var ignore_onend;
var start_timestamp;
var interim_span
var original_innerText;
if (!('webkitSpeechRecognition' in window)) {
  upgrade();
} else {

  start_button.style.display = 'inline-block';
  var recognition = new webkitSpeechRecognition();
  recognition.continuous = true;
  recognition.interimResults = true;

  recognition.onstart = function() {
    //recognizing = true;
    //showInfo('info_speak_now');
    //start_img.src = 'assets/img/speak.gif';
    let $input  = $("#"+$("#speeFLD").val());
    original_innerText = $input.val().trim() == ""? "" : $input.val() +" ";

  };

  recognition.onerror = function(event) {
    /*if (event.error == 'no-speech') {
      start_img.src = 'assets/img/microphone.png';
      showInfo('info_no_speech');
      ignore_onend = true;
    }
    if (event.error == 'audio-capture') {
      start_img.src = 'assets/img/microphone.png';
      showInfo('info_no_microphone');
      ignore_onend = true;
    }
    if (event.error == 'not-allowed') {
      if (event.timeStamp - start_timestamp < 100) {
        showInfo('info_blocked');
      } else {
        showInfo('info_denied');
      }
      ignore_onend = true;
    }*/
  };

  recognition.onend = function() {
    /*recognizing = false;
    if (ignore_onend) {
      return;
    }
    start_img.src = 'assets/img/microphone.png';
    if (!final_transcript) {
      showInfo('info_start');
      return;
    }
    showInfo('');
    if (window.getSelection) {
      window.getSelection().removeAllRanges();
      var range = document.createRange();
      range.selectNode(document.getElementById('final_span'));
      window.getSelection().addRange(range);
    }
*/
    paraEscuta($("#speeFLD").val());
  };

  recognition.onresult = function(event) {
    let $input  = $("#"+$("#speeFLD").val());
    // let inputmen  = document.getElementById($("#speeFLD").val() +"mem");
    var final = "";
    let interim = "";
    for (var i = event.resultIndex; i < event.results.length; ++i) {

      if (event.results[i].isFinal) {
          final += event.results[i][0].transcript;
        // inputmen.innerText = original_innerText + final;
        // original_innerText = inputmen.innerText;
        $input.val(original_innerText + final);
      }else{
        interim += event.results[i][0].transcript;
        $input.val(original_innerText + interim);
      }
    }
    /*
    var interim_transcript = '';
    if (typeof(event.results) == 'undefined') {
      recognition.onend = null;
      recognition.stop();
      upgrade();
      return;
    }
    for (var i = event.resultIndex; i < event.results.length; ++i) {
      if (event.results[i].isFinal) {
          final_transcript += event.results[i][0].transcript;
          if ($("#speeFLD").val() == "") {
              $.post("recSpeech.asp", { t: final_transcript, p: '<%=req("P")%>', id: '<%=req("I")%>', recognitionPront: 'S' }, function (data) { eval(data) });
          } else {
              $("#speeFLD").val("");
              recognition.stop();
          }
      } else {
          interim_transcript += event.results[i][0].transcript;
          $("#" + $("#speeFLD").val()).val(interim_transcript);
          $("#" + $("#speeFLD").val() +"mem").html(interim_transcript);

      }
    }
    final_transcript = capitalize(final_transcript);
    final_span.innerHTML = linebreak(final_transcript);
    interim_span.innerHTML = linebreak(interim_transcript);
    if (final_transcript || interim_transcript) {
      showButtons('inline-block');
    }*/
  };
}

function upgrade() {
  start_button.style.visibility = 'hidden';
  showInfo('info_upgrade');
}

var two_line = /\n\n/g;
var one_line = /\n/g;
function linebreak(s) {
  return s.replace(two_line, '<p></p>').replace(one_line, '<br>');
}

var first_char = /\S/;
function capitalize(s) {
  return s.replace(first_char, function(m) { return m.toUpperCase(); });
}

var campoValorPadrao="";
function startButton(event) {
  /*console.log("startButton")
  campoValorPadrao=$("#" + $("#speeFLD").val() +"mem").html();

  if(typeof campoValorPadrao === "undefined"){
    campoValorPadrao= $("#" + $("#speeFLD").val()).val();
  }

  if (recognizing) {
    recognition.stop();
    return;
  }



  final_transcript = '';
  recognition.lang = select_dialect.value;
  recognition.start();
  recognizing=true;
  ignore_onend = false;
  final_span.innerHTML = '';
  interim_span.innerHTML = '';
  start_img.src = 'assets/img/microphone.png';
  showInfo('info_allow');
  showButtons('none');
  start_timestamp = event.timeStamp;*/
}

function showInfo(s) {
  if (s) {
    for (var child = info.firstChild; child; child = child.nextSibling) {
      if (child.style) {
        child.style.display = child.id == s ? 'inline' : 'none';
      }
    }
    info.style.visibility = 'visible';
  } else {
    info.style.visibility = 'hidden';
  }
}

var current_style;
function showButtons(style) {
  if (style == current_style) {
    return;
  }
}

</script>
