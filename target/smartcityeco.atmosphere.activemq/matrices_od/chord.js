
  var chord = d3.layout.chord()
       .padding(.05)
       //.sortSubgroups(d3.descending)
       .matrix(matrix);

  var fill = d3.scale.ordinal()
       .domain(d3.range(9))
       .range(colors);

function print_chord(){
   svg = d3.select("#chord-canvas").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + 350 / 2 + "," + 350 / 2 + ")")
    .attr("font-size","10px");
   
   svg.append("g").selectAll("path")
       .data(chord.groups)
     .enter().append("path")
       .style("fill", function(d) { return fill(d.index); })
       .style("stroke", function(d) { return fill(d.index); })
       .attr("d", d3.svg.arc().innerRadius(innerRadius).outerRadius(outerRadius))
       .on("mouseover", fade(.1))
       .on("mouseout", fade(1));

   var ticks = svg.append("g").selectAll("g")
       .data(chord.groups)
     .enter().append("g").selectAll("g")
       .data(groupTicks)
     .enter().append("g")
       .attr("transform", function(d) {
         return "rotate(" + (d.angle * 180 / Math.PI - 90) + ")"
             + "translate(" + outerRadius + ",0)";
       });

   ticks.append("text")
       .attr("x", 8)
       .attr("dy", ".35em")
       .attr("transform", function(d) { return d.angle > Math.PI ? "rotate(180)translate(-16)" : null; })
       .style("text-anchor", function(d) { return d.angle > Math.PI ? "end" : null; })
       .text(function(d) { return d.label; });

   svg.append("g")
       .attr("class", "chord")
     .selectAll("path")
       .data(chord.chords)
     .enter().append("path")
       .attr("d", d3.svg.chord().radius(innerRadius))
       .style("fill", function(d) { return fill(d.target.index); })
       .style("opacity", 1);
}

// Returns labels, given a group.
function groupTicks(d) {
  return d3.range(0,d.value,d.value).map(function(v,i){
         return{angle: (d.endAngle-d.startAngle)/2 + d.startAngle, 
                label: names[d.index]};
   });
}

// Returns an event handler for fading a given chord group.
function fade(opacity) {
  return function(g, i) {
    svg.selectAll(".chord path")
        .filter(function(d) { return d.source.index != i && d.target.index != i; })
      .transition()
        .style("opacity", opacity);
  };
}

