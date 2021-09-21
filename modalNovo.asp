<!--#include file="modalAgenda.asp"-->


<a href="javascript:mfp('#modal-form');" class="btn">VAI POPUP</a>



<div id="modal-form" class=" popup-basic popup-full admin-form mfp-with-anim mfp-hide">
    <div class="panel">
    <div class="panel-heading">
        <h4 class="panel-title">
        <i class="far fa-rocket"></i>Leave a comment
        </h4>
    </div>
        <div class="panel-body p25">
            <i class="far fa-circle-o-notch fa-spin"></i>
        </div>

        <div class="panel-footer">
        <button type="submit" class="button btn-primary">Post Comment</button>
        </div>
    </div>
</div>


  <script type="text/javascript">
 function mfp(im){
      $.magnificPopup.open({
        removalDelay: 500,
        items: {
            src: im
    },
        // overflowY: 'hidden', // 
        callbacks: {
          beforeOpen: function(e) {
              this.st.mainClass = "mfp-zoomIn";
          }
        }
      });

    }
  </script>
  <!-- END: PAGE SCRIPTS -->
