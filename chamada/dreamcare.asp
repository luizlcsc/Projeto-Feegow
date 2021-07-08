<%
'if session("Banco")="" then
'	session("Banco")="clinic"&req("I")
'end if
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Chamada de Voz</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/css/bootstrap-theme.min.css">
<link href="css/carrossel.css" rel="stylesheet" type="text/css" />
<link href="css/custom1.css" rel="stylesheet" type="text/css" />

<!-- Latest compiled and minified JavaScript -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>

</head>

<body> 
   <div class="container-fluid">


       
  
      <div class="row">
        <div class="col-md-8" id="listaChamadas">
        
        </div>
        <div class="col-md-4"><!-- carrossel -->
        
      <div class="page-header" style="background-color:#f9ffe3"  >
        <h1><img src="images/logo_ieps.png" /></h1>
       
      </div>
        <div id="myCarousel" class="carousel slide carousel-fade" data-ride="carousel">
      <!-- Indicators -->
      <ol class="carousel-indicators">
        <li data-target="#myCarousel" data-slide-to="0" class="active"></li>
        <li data-target="#myCarousel" data-slide-to="1" class=""></li>
        <li data-target="#myCarousel" data-slide-to="2" class=""></li>
         <li data-target="#myCarousel" data-slide-to="3" class=""></li>
        <li data-target="#myCarousel" data-slide-to="4" class=""></li>
      </ol>
      <div class="carousel-inner" role="listbox">
       <div class="item active" style="background-image:url(images/child.png); background-size:cover;" >
        <div class="container">
            <div class="carousel-caption">

          
              
         
            </div>
          </div>
        
       </div>
       
       
        <div class="item" style="background-image:url(images/sono.png); background-size:cover; ">
          
          <div class="container">
            <div class="carousel-caption" >
         
              <h2>Dormir bem pode significar muito.</h2>
              
         
            </div>
          </div>
        </div>
        <div class="item item2" style="background-image:url(images/bassleep.png); background-size:cover; ">
        <div class="container">
            <div class="carousel-caption"  >
         
              <h3> A cada três pessoas, uma sofre de algum distúrbio do sono. </h3>
              
         
            </div>
          </div>
       
        <!-- fim carrossel --></div>
        
             <div class="item" style="background-image:url(images/waking.png); background-size:cover;" >
        <div class="container">
            <div class="carousel-caption">
         
          
              
         
            </div>
          </div>
        
       </div>
       
       <div class="item" style="background-image:url(images/couple.png); background-size:cover;" >
        <div class="container">
            <div class="carousel-caption">
        
              
         
            </div>
          </div>
        
       </div>
       
       
         <!-- fim carrossel -->
        </div></div>
      </div>
      </div></div>
      
      
</body>
<script>
	setInterval(function(){ $.post("./../listaChamadas.asp", '', function(data,status){ $("#listaChamadas").html(data) }) }, 10000);
	
//	    $(document).ready(function() {
        var audioElement = document.createElement('audio');
        audioElement.setAttribute('src', 'sons/som2.wav');
        audioElement.setAttribute('autoplay', 'autoplay');
        audioElement.load()

        $.get();

        audioElement.addEventListener("load", function() {
            audioElement.play();
        }, true);

        /*$('.play').click(function() {
            audioElement.play();
        });*/

        $('.pause').click(function() {
            audioElement.pause();
        });
		function tocar(){
			audioElement.play();
		}
//    });

</script>
</html>
