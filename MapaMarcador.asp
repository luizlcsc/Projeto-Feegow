<!DOCTYPE html>
<html>
  <head>
    <!-- This stylesheet contains specific styles for displaying the map
         on this page. Replace it with your own styles as described in the
         documentation:
         https://developers.google.com/maps/documentation/javascript/tutorial -->
    <link rel="stylesheet" href="https://developers.google.com/maps/documentation/javascript/demos/demos.css">
  </head>
  <body>
    <div id="map"></div>
    <script>
      function initMap() {
        var myLatLng = {lat: -23.014764400000004, lng: -43.485230099999995};

        // Create a map object and specify the DOM element for display.
        var map = new google.maps.Map(document.getElementById('map'), {
          center: myLatLng,
          scrollwheel: true,
          zoom: 18
        });

        // Create a marker and set its position.
        var marker = new google.maps.Marker({
          map: map,
          position: myLatLng,
          title: "<%=session("nameUser") %>"
        });
      }

    </script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDEA6dJjruCFdGFhecS31KMyLVdu02X1wI&callback=initMap"
        async defer></script>
  </body>
</html>


