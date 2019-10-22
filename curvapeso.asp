<%
if 1=2 then
%>
<script>
<% End If %>

function display_growth_chart(patient, el, chartType, dims) {

  // Create the background lines
  //
  // json includes "meta" (to tag+name the lines, specify measurement type)
  //  and "data" (containing age in months vs measurement)
  function createLines(json) {
    var meta = json.meta;
    var data = json.data;

    var newLines = [];

    for (var i=0; i < meta.lines.length; i++) {
      // Get the tag
      var lineTag = meta.lines[i].tag;

      newLines.push([]);
      // Generate the list of data (month, measurement)
      for (var j=0; j < data.length; j++) {
        // Assumes data has a "Month" tag in each element
        newLines[i].push([data[j]["Month"], data[j][lineTag]]);
      }
    }
    return newLines;
  }

  // Get data to build chart's 'background lines' depending on chartType
  var data;
  var metaData;
  var chartTypes = {
    'wfa_boys_0_to_5' : wfa_boys_0_to_5
  };

  var chartTypeKeys = [];
  for (k in chartTypes) {
    if (chartTypes.hasOwnProperty(k)) {
      chartTypeKeys.push(k);
    }
  }

  if (chartTypes.hasOwnProperty(chartType)) {
    data = createLines(chartTypes[chartType]);
    metaData = chartTypes[chartType].meta;
  } else {
    console.log('Error choosing chart type. Your input was "' + chartType + '". Valid options are:', chartTypeKeys);
    return;
  }

  // Save the last tuple so that I can label it
  lastTuples = [];

  // Boundaries for graph, based on growth chart bounds
  var yMax = 0; // weight, in kg
  var xMax = 0; // age, in months
  for (var i = 0; i < data.length; i++) {
    var lineData = data[i];
    var lastTuple = lineData[lineData.length-1];
    lastTuples.push(lastTuple);
    xMax = Math.max(lastTuple[0], xMax);
    yMax = Math.max(lastTuple[1], yMax);
  }

  // Graph formatting, in pixels
  var width = 800;
  var height = 450;
  var padding = 50;
  var extraRightPadding = 40; // For line labels ... "severely malnourished" goes offscreen

  // Graph scale; domain and range
  var xScale = d3.scale.linear()
    .domain([0, xMax])
    .range([padding, width - padding]);

  var yScale = d3.scale.linear()
    .domain([1, yMax])
    .range([height - padding, padding]);

  // Line generating function
  var line = d3.svg.line()
    .interpolate("basis")
    .x(function(d, i) {
    return xScale(d[0]);
  })
    .y(function(d) {
    return yScale(d[1]);
  });

  // Area under the curve, for highlighting regions
  var area = d3.svg.area()
    .interpolate("basis")
    .x(line.x())
    .y1(line.y())
    .y0(yScale(0));

  // clear exiting growth chart svg .. allows to reset graph with new background
  d3.select(el).select(".growth_chart_main_svg").remove();

  var svg = d3.select(el).append("svg")
    .attr("width", width + extraRightPadding)
    .attr("height", height)
    .attr("class", "growth_chart_main_svg");

  // add a monocolor background
  var backgroundRect = svg.append("g");
  backgroundRect.append("rect")
    .attr("width", width + extraRightPadding)
    .attr("height", height)
    .attr("class", "backgroundRect");

  // Baseline growth curves
  var lines = svg.selectAll(".lines")
    .data(data)
    .enter();

  lines.append("path")
    .attr("class", "area")
    .attr("d", area);

  lines.append("path")
    .attr("class", "line")
    .attr("d", line);

  var linesToAxis = svg.append("g");

  // Patient's data

  // Add line for the patient's growth
  var linesP = svg.selectAll("pG")
    .data([patient])
    .attr("class", "pG")
    .enter();
  linesP.append("path")
    .attr("class", "pLine")
    .attr("d", line.interpolate("")); // interpolate("") removes the smoothing

  // Dots at each data point
  var dots = svg.selectAll(".dot")
    .data(patient)
    .enter()
    .append("circle")
    .attr("class", "dot")
  .call(dotHandler(function(d, i) {
    return getTooltipText(d);
  }))
  // .on("mouseout", mouseoutDot)
  .attr("cx", function(d, i) {
    return xScale(d[0]);
  })
    .attr("cy", function(d, i) {
    return yScale(d[1]);
  })
    .attr("r", 3);

  // Add axes
  // TODO: Improve axes to have years and months, like http://www.who.int/childgrowth/standards/cht_wfa_boys_p_0_5.pdf

  // x-axis
  var xAxis = d3.svg.axis();
  xAxis.scale(xScale);
  xAxis.orient("bottom")
    .ticks(10);

  svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(" + 0 + "," + (height - padding) + ")")
    .call(xAxis);

  // y-axis
  var yAxis = d3.svg.axis();
  yAxis.scale(yScale);
  yAxis.orient("left")
    .ticks(10);

  svg.append("g")
    .attr("class", "axis")
    .attr("transform", "translate(" + padding + ",0)")
    .call(yAxis);

  // svg.selectAll(".xaxis text")  // select all the text elements for the xaxis
  //         .attr("transform", function(d) {
  //            return "translate(" + this.getBBox().height*-2 + "," + this.getBBox().height + ")rotate(-45)";
  //        });

  // Axes text
  svg.append("text")
    .attr("text-anchor", "middle")
    .attr("transform", "translate("+ (padding/3) +","+(height-padding)/2+")rotate(-90)")
    .text("Peso (kg)");

  svg.append("text")
    .attr("text-anchor", "middle")
    .attr("transform", "translate("+ (width/2) +","+(height-(padding/3))+")")
    .text("Idade (meses)");

  // Line labels (Normal, Malnourished, and Severely Malnourished)
  for (var i=0; i<metaData.lines.length; i++) {
    xOffset = xScale(lastTuples[i][0]);
    xOffset += 2; // a little space better graph and text
    yOffset = yScale(lastTuples[i][1]);
    yOffset += 4; // center text on line

    svg.append("text")
      .attr("class","line-label")
      .attr("transform", "translate("+ xOffset +","+ yOffset +")")
      // .attr("text-anchor", "middle")
      .text(metaData.lines[i].name);
  }

  var tooltipOffset = padding + 10;
  var tooltipGroup = svg.append("g");

  var tooltipBackground = tooltipGroup.append("rect")
    // .attr("class","tooltip")
    .attr("x", tooltipOffset)
    .attr("y", tooltipOffset)
    .attr("width", 0)
    .attr("height", 0)
    .attr("class","tooltipTextBackground")
    // .style("font-size","14px")
    // .style("background-color","gray")
    // .text("(Move mouse over a data point to see details)");
    // .text("");

  var tooltipText = tooltipGroup.append("text")
    // .attr("class","tooltip")
    .attr("x", tooltipOffset)
    .attr("y", tooltipOffset)
    .attr("class","tooltipText")
    .style("font-size","14px")
    // .style("background-color","gray")
    // .text("(Move mouse over a data point to see details)");
    .text("");

  // Draw a rectangle background behind the text
  // var bbox = textElement.getBBox();
  // var width = bbox.width;
  // var height = bbox.height;


  // Button to toggle chart type
  /*
  var rectButton = svg.append("rect")
    .attr("rx", 6)
    .attr("ry", 6)
    .attr("x", (width / 2) - 3 - 46)
    .attr("y", 0 + (padding / 2) - 14 - 3 + 24)
    // .attr("x", padding*10-3)
    // .attr("y", padding-14-3)
    .attr("width", 101)  // 106
    .attr("height", 25)
    .style("stroke","gray")
    .style("fill", d3.scale.category20c())
    .on("click", function() {
      changeGraphType();
    });

  var rectButtonText = svg.append("text")
    .attr("x", (width / 2))
    .attr("y", 0 + (padding / 2) + 24)
    .attr("text-anchor", "middle")
    // .attr("transform", "translate("+ (padding*10) +","+(padding)+")")
    .style("font-size","14px")
    .style("fill","white")
    .text("Change Graph")
    .on("click", function() {
      changeGraphType();
    });
*/
  //     var width = 800;
  // var height = 450;
  // var padding = 44;


  svg.append("text")
        .attr("x", (width / 2))
        .attr("y", 0 + (padding / 2))
        .attr("text-anchor", "middle")
        .style("font-size", "16px")
        .style("text-decoration", "underline")
        .text(metaData.title);

  function changeGraphType() {
    var whichChart = chartTypeKeys.indexOf(chartType);
    whichChart += 1;
    whichChart %= chartTypeKeys.length;

    var growthChart = display_growth_chart(patient, el , chartTypeKeys[whichChart]);
  }

  function dotHandler(accessor) {
    return function(selection) {
      selection.on("mouseover", function(d, i) {
        // Select current dot, unselect others
        d3.selectAll("circle.dotSelected").attr("class", "dot");
        d3.select(this).attr("class", "dotSelected");

        // Update text using the accessor function
        var ttAccessor = accessor(d, i) || '';
        tooltipText.text(ttAccessor);

        // Update text background
        var dottedSegmentLength = 3;  // used below, too, for linesToAxis
        var tooltipHeightPadding = 5;
        var tooltipWidthPadding = 4;
        var bbox = svg.select(".tooltipText")[0][0].getBBox();
        svg.selectAll(".tooltipTextBackground")
          .attr("width", bbox.width + tooltipWidthPadding * 2)
          .attr("height", bbox.height + tooltipHeightPadding )
          .attr("y", tooltipOffset - bbox.height )
          .attr("x", tooltipOffset - tooltipWidthPadding );
          // .style("stroke-dasharray",
          //   dottedSegmentLength.toString()
          // );

        // create a rectangle that stretches to the axes, so it's easy to see if the axis is right..
        // Remove old
        linesToAxis.selectAll(".rect-to-axis")
          .data([])
        .exit().remove();

        // Add new
        var linesToAxisWidth = xScale(d[0]) - padding;
        var linesToAxisHeight = height - yScale(d[1]) - padding;
        var halfRectLength = linesToAxisWidth + linesToAxisHeight;
        halfRect = halfRectLength.toString();

        // Draw top and right sides of rectangle as dotted. Hide bottom and left sides
        var dottedSegments = Math.floor(halfRectLength / dottedSegmentLength);
        var nonDottedLength = halfRectLength*2; // + (dottedSegments % dottedSegmentLength);

        var dashArrayStroke = [];

        for (var i=0; i < dottedSegments; i++) {
          dashArrayStroke.push(dottedSegmentLength);
        }
        // if even number, add extra filler segment to make sure 2nd half of rectangle is hidden
        if ( (dottedSegments % 2) === 0) {
          extraSegmentLength = halfRectLength - (dottedSegments*dottedSegmentLength);
          dashArrayStroke.push(extraSegmentLength);
          dashArrayStroke.push(nonDottedLength);
        } else {
          // extraSegmentLength = halfRectLength - (dottedSegments*dottedSegmentLength);
          dashArrayStroke.push(nonDottedLength);
        }

        linesToAxis.selectAll(".rect-to-axis")
          .data([d])
         .enter().append("rect")
          .attr("class", "rect-to-axis")
          .style("stroke-dasharray",
            dashArrayStroke.toString()
          )
          .attr("x", padding)
          .attr("y", yScale(d[1]))
          .attr("width", linesToAxisWidth)
          .attr("height", linesToAxisHeight);

      });
    };
  }

  function getTooltipText(d) {
    var age_in_months = parseFloat(d[0]);
    var weight_in_kg = parseFloat(d[1]).toFixed(1);
    var textAge = 'Idade: ' + getAgeText(age_in_months);
    var textweight = 'Peso: ' + weight_in_kg + 'kg';
    var text = textAge + '; ' + textweight;

    return text;
  }

  // @param months - age in months (float)
  // @return - age (<years>y, <months>m) (string)

  function getAgeText(months){
    var y = Math.floor(months / 12);
    var m = months - (y * 12);
    m = m.toFixed(1);

    if (y > 0) {
      return y + 'y, ' + m + 'm';
    } else {
      return m + 'm';
    }
  }

  // callable methods
  return this;
}
<%
if 1=2 then
%>
</script>
<% End If %>
