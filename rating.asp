
    
    <div class="row lead">
        Avaliação da execução <span id="stars-existing" class="starrr" data-rating='3'></span>
    </div>


<script src="assets/js/estrela.js" type="text/javascript"></script>
<script type='text/javascript'>


$( document ).ready(function() {
      
  $('#stars').on('starrr:change', function(e, value){
    $('#count').html(value);
  });
  
  $('#stars-existing').on('starrr:change', function(e, value){
    $('#count-existing').html(value);
  });

  
});</script>