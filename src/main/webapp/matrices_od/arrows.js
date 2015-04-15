
function initialize_map() {
    map  = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
    google.maps.event.addDomListener(window, 'load', initialize_map);
    var line=[];
    for (var i=0;i<(2*(NUM_ZONES_PER_SIDE+1));i++){
      line[i] = new google.maps.Polyline({path: lineCoords[i], map: map });
    }
  var k = 0;
  for (var i=0;i<9;i++){
     for(var j=0;j<9;j++){
       if ( i != j ){
                var circleOptions = {
                    strokeColor: colors[i],
                    strokeOpacity: 0.3,
                    strokeWeight: 1,
                    fillColor: colors[i],
                    fillOpacity: 0.2,
                    map: map,
                    center: new google.maps.LatLng(((arrowCoords[k])[1])[0], ((arrowCoords[k])[1])[1]),
                    radius: 50.0
                };
                circle = new google.maps.Circle(circleOptions);
                k++;
          }
       }
  }
    plot_arrows(10);
}

function plot_arrows(m){
  var k=0;
  var lineSymbol = { path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW };
  for (var i=0;i<9;i++){
     for(var j=0;j<9;j++){
       value = matrix[i][j]*15/294;
       if ( i != j ){
         if ((i == m || j == m) || m==10) {
             arrow[k] = curved_line_generate({
                latStart:          ((arrowCoords[k])[0])[0],
                lngStart:          ((arrowCoords[k])[0])[1],
                latEnd:            ((arrowCoords[k])[1])[0],
                lngEnd:            ((arrowCoords[k])[1])[1],
                strokeColor:       colors[i],
                Map:               map,
                strokeWeight:      value,
                strokeOpacity:     1,
                multiplier:        2,
                resolution:        0.01
            });
         }
         else {
             arrow[k] = curved_line_generate({
                latStart:          ((arrowCoords[k])[0])[0],
                lngStart:          ((arrowCoords[k])[0])[1],
                latEnd:            ((arrowCoords[k])[1])[0],
                lngEnd:            ((arrowCoords[k])[1])[1],
                strokeColor:       colors[i],
                Map:               map,
                strokeWeight:      value,
                strokeOpacity:     0,
                multiplier:        2,
                resolution:        0.01
            });
         }  
        k++;
       }
    }
  }
}


