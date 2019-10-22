<html>
 
<head>   
 
<!-- 1 -->
<link href="css/dropzone.css" type="text/css" rel="stylesheet" />
 
<!-- 2 -->
<script src="dropzone.js"></script>
 
</head>
 
<body>
 
<!-- 3 -->
<form action="upload.php" class="dropzone"></form>
   
</body>
 
</html>
<script>
Dropzone.options.myAwesomeDropzone = {
  paramName: "file", // The name that will be used to transfer the file
  maxFilesize: 2, // MB
  accept: function(file, done) {
    if (file.name == "justinbieber.jpg") {
      done("Naha, you don't.");
    }
    else { done(); }
  }
};
</script>