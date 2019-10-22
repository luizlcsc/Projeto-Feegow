<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=UTF-8">
  <meta name="robots" content="noindex, nofollow">
  <meta name="googlebot" content="noindex, nofollow">

  
  

  
  
  

  

	    <script type="text/javascript" src="assets/js/jquery.min.js"></script>

  
  

  

  <style type="text/css">
    
  </style>

  <title></title>

  
    




<script type='text/javascript'>//<![CDATA[

$(function () {


    // Build the chart
    $('#container').highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            type: 'pie'
        },
        title: {
            text: 'Browser market shares. January, 2015 to May, 2015'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    },
                    connectorColor: 'silver'
                }
            }
        },
        series: [{
            name: 'Brands',
            data: [
                { name: 'Microsoft Internet Explorer', y: 56.33 },
                {
                    name: 'Chrome',
                    y: 24.03,
                    sliced: true,
                    selected: true
                },
                { name: 'Firefox', y: 10.38 },
                { name: 'Safari', y: 4.77 }, { name: 'Opera', y: 0.91 },
                { name: 'Proprietary or Undetectable', y: 0.2 }
            ]
        }]
    });


    // Radialize the colors
    Highcharts.getOptions().colors = Highcharts.map(Highcharts.getOptions().colors, function (color) {
        return {
            radialGradient: {
                cx: 0.5,
                cy: 0.3,
                r: 0.7
            },
            stops: [
                [0, color],
                [1, Highcharts.Color(color).brighten(-0.3).get('rgb')] // darken
            ]
        };
    });

    // Build the chart
    $('#container2').highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            type: 'pie'
        },
        title: {
            text: 'Browser market shares. January, 2015 to May, 2015'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    },
                    connectorColor: 'silver'
                }
            }
        },
        series: [{
            name: 'Brands',
            data: [
                { name: 'Microsoft Internet Explorer', y: 56.33 },
                {
                    name: 'Chrome',
                    y: 24.03,
                    sliced: true,
                    selected: true
                },
                { name: 'ffdfd', y: 10.38 },
                { name: 'Safari', y: 4.77 }, { name: 'Opera', y: 0.91 },
                { name: 'Proprietary or Undetectable', y: 0.2 }
            ]
        }]
    });
});
//]]> 

</script>

  
</head>

<body>
<script src="js/highcharts.js"></script>
<script src="js/exporting.js"></script>

<div id="container" style="min-width: 310px; height: 400px; max-width: 600px; margin: 0 auto"></div>
<div id="container2" style="min-width: 310px; height: 400px; max-width: 600px; margin: 0 auto"></div>

  
</body>

</html>

