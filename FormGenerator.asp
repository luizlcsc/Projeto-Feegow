    <link href="css/toolbox.css" rel="stylesheet">
    <link href="css/editor.css" rel="stylesheet">
    <link href="css/docs.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/font-awesome.min.css">
    <!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
    <!--[if lt IE 9]>
    <script src="js/html5shiv.js"></script>
    <![endif]-->
    <!-- Fav and touch icons -->
    <link rel="shortcut icon" href="img/favicon.png">

    <script type="text/javascript" src="js/jquery-2.0.0.min.js"></script>
    <!--[if lt IE 9]>
    <script type="text/javascript" src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
    <![endif]-->
    <script type="text/javascript" src="js/bootstrap.min.js"></script>
    <script type="text/javascript" src="js/jquery-ui.js"></script>
    <script type="text/javascript" src="js/jquery.ui.touch-punch.min.js"></script>
    <script type="text/javascript" src="js/jquery.htmlClean.js"></script>
    <script type="text/javascript" src="ckeditor/ckeditor.js"></script>
    <script type="text/javascript" src="ckeditor/config.js"></script>
    <script type="text/javascript" src="js/scripts.js"></script>
    <script type="text/javascript" src="js/FileSaver.js"></script>
    <script type="text/javascript" src="js/blob.js"></script>
    <script src="js/docs.min.js"></script>
    <style>
	.container-fluid{
	    *zoom:1;margin-left: 0px;
	    margin-top: 10px;
	    padding: 30px 15px 15px;
	    border: 1px solid #DDDDDD;
	    border-radius: 4px;
	    position: relative;
	    word-wrap: break-word;
	}
	body.devpreview {
	    margin-top: 60px;
	    margin-left:5px !important;
	}

    .remove {
        position:absolute;
        right:0;
        z-index:100;
    }

    .drag {
        position:absolute;
        right:50px;
        z-index:100;
    }

    .ui-sortable {
        border:1px dotted #f00;
        min-height:100px;
    }

	</style>

  <body style="cursor: auto;" class="edit toolbox-reset">


    <div class="container-fluid">
      <div class="changeDimension">
        <div class="row-fluid">
          <div class="">
            <span></span>
            <div class="sidebar-nav">
              <ul class="nav nav-list accordion-group">
                <li class="nav-header">
                  <div class="pull-right popover-info">
                    <i class="icon-question-sign "></i>
                    <div class="popover fade right">
                      <div class="arrow"></div>
                      <h3 class="popover-title">Help</h3>
                      <div class="popover-content">TO CHANGE THE COLUMN CONFIGURATION YOU CAN EDIT THE DIFFERENT VALUES IN THE INPUT (THEY SHOULD ADD 12). IF YOU NEED MORE INFO PLEASE VISIT <a target="_blank" href="http://twitter.github.io/bootstrap/scaffolding.html#gridSystem"> BOOTSTRAP GRID SYSTEM</a></div>
                    </div>
                  </div>
                  <i class="icon-plus icon-white"></i> GRID SYSTEM
                </li>
                <li style="display: list-item;" class="rows" id="estRows">
                  <div class="lyrow ui-draggable">
                    <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span>
                    <div class="preview">
                      <input value="12" type="text">
                    </div>
                    <div class="view">
                      <div class="row-fluid clearfix">
                        <div class="col-xs-12 column"></div>
                      </div>
                    </div>
                  </div>

                  <div class="lyrow ui-draggable">
                    <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span>
                    <div class="preview">
                      <input value="4 4 4" type="text">
                    </div>
                    <div class="view">
                      <div class="row-fluid clearfix">
                        <div class="col-xs-4 column"></div>
                        <div class="col-xs-4 column"></div>
                        <div class="col-xs-4 column"></div>
                      </div>
                    </div>
                  </div>


                  <div class="lyrow ui-draggable">
                    <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span>
                    <div class="preview">
                      <input value="4 8" type="text">
                    </div>
                    <div class="view">
                      <div class="row-fluid clearfix">
                        <div class="col-xs-4 column"></div>
                        <div class="col-xs-8 column" ></div>
                      </div>
                    </div>
                  </div>

                  <div class="lyrow ui-draggable">
                   <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span>
                   <div class="preview">
                     <input value="6 6" type="text">
                   </div>
                   <div class="view">
                     <div class="row-fluid clearfix">
                       <div class="col-xs-6 column"></div>
                       <div class="col-xs-6 column"></div>
                     </div>
                   </div>
                 </div>


                  <div class="lyrow ui-draggable">
                    <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span>
                    <div class="preview">
                      <input value="8 4" type="text">
                    </div>
                    <div class="view">
                      <div class="row-fluid clearfix">
                        <div class="col-xs-8 column" ></div>
                        <div class="col-xs-4 column"></div>
                      </div>
                    </div>
                  </div>

                </li>
              </ul>
              
              
            </div>
          </div>
          <!--/span-->
          <div class="demo ui-sortable" style="min-height: 304px; ">
            <div class="lyrow">
              <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>remove</a>
              <span class="drag label"><i class="icon-move"></i>drag</span>
              <div class="preview">9 3</div>
              <div class="view">
                <div class="row-fluid clearfix">
                  <div class="span12 column ui-sortable">
                    <div class="box box-element ui-draggable" style="display: block; ">
                      <a href="#close" class="remove label label-important"><i class="icon-remove icon-white"></i>Remove</a> <span class="drag label"><i class="icon-move"></i>Drag</span> <span class="configuration"><button type="button" class="btn btn-mini" data-target="#editorModal" role="button" data-toggle="modal">Editor</button> <a class="btn btn-mini" href="#" rel="well">Well</a> </span>
                      <div class="preview">Jumbotron</div>
                      <div class="view">
                        <div class="hero-unit" contenteditable="true">
                          <h1>Texto </h1>
                          <p>Este é o texto.</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- end demo -->
          <!--/span-->
          <div id="download-layout">
            <div class="container-fluid"></div>
          </div>
        </div>
        <!--/row-->
      </div>
      <!--/.fluid-container-->
      <div class="modal hide fade" role="dialog" id="editorModal">
        <div class="modal-header">
          <a class="close" data-dismiss="modal">Ã—</a>
          <h3>Save your Layout</h3>
        </div>
        <div class="modal-body">
          <p>
            <textarea id="contenteditor"></textarea>
          </p>
        </div>
        <div class="modal-footer"> <a id="savecontent" class="btn btn-primary" data-dismiss="modal">Save</a> <a class="btn" data-dismiss="modal">Cancel</a> </div>
      </div>
      <div class="modal hide fade" role="dialog" id="downloadModal">
        <div class="modal-header">
          <a class="close" data-dismiss="modal">Ã—</a>
          <h3>Save</h3>
        </div>
        <div class="modal-body">
          <p>Choose how to save your layout</p>
          <div class="btn-group">
            <button type="button" id="fluidPage" class="active btn btn-info"><i class="icon-fullscreen icon-white"></i> Fluid Page</button>
            <button type="button" class="btn btn-info" id="fixedPage"><i class="icon-screenshot icon-white"></i> Fixed page</button>
          </div>
          <br>
          <br>
          <p>
            <textarea></textarea>
          </p>
        </div>
        <div class="modal-footer"> <a class="btn btn-primary navbar-btn" data-dismiss="modal" onclick="javascript:saveHtml();">Save</a> </div>
      </div>
    </div>
    <script>
      function resizeCanvas(size)
      {

      var containerID = document.getElementsByClassName("changeDimension");
      var containerDownload = document.getElementById("download-layout").getElementsByClassName("container-fluid")[0];
      var row = document.getElementsByClassName("demo ui-sortable");
      var container1 = document.getElementsByClassName("container1");
      if (size == "md")
      {
      $(containerID).width('id', "MD");
      $(row).attr('id', "MD");
      $(container1).attr('id', "MD");
      $(containerDownload).attr('id', "MD");
      }
      if (size == "lg")
      {
      $(containerID).attr('id', "LG");
      $(row).attr('id', "LG");
      $(container1).attr('id', "LG");
      $(containerDownload).attr('id', "LG");
      }
      if (size == "sm")
      {
      $(containerID).attr('id', "SM");
      $(row).attr('id', "SM");
      $(container1).attr('id', "SM");
      $(containerDownload).attr('id', "SM");
      }
      if (size == "xs")
      {
      $(containerID).attr('id', "XS");
      $(row).attr('id', "XS");
      $(container1).attr('id', "XS");
      $(containerDownload).attr('id', "XS");

      }


      }
    </script>
  </body>
