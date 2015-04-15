
function print_matrix() {

  var map2 = new google.maps.Map(document.getElementById('matrix-canvas'), mapOptions);
  //google.maps.event.addDomListener(window, 'load', print_matrix);


var limits   = [
                 [[LIMIT_LAT_A,LIMIT_LON_1], [LIMIT_LAT_B,LIMIT_LON_2]],
                 [[LIMIT_LAT_A,LIMIT_LON_2], [LIMIT_LAT_B,LIMIT_LON_3]],
                 [[LIMIT_LAT_A,LIMIT_LON_3], [LIMIT_LAT_B,LIMIT_LON_4]],
                 [[LIMIT_LAT_B,LIMIT_LON_1], [LIMIT_LAT_C,LIMIT_LON_2]],
                 [[LIMIT_LAT_B,LIMIT_LON_2], [LIMIT_LAT_C,LIMIT_LON_3]],
                 [[LIMIT_LAT_B,LIMIT_LON_3], [LIMIT_LAT_C,LIMIT_LON_4]],
                 [[LIMIT_LAT_C,LIMIT_LON_1], [LIMIT_LAT_D,LIMIT_LON_2]],
                 [[LIMIT_LAT_C,LIMIT_LON_2], [LIMIT_LAT_D,LIMIT_LON_3]],
                 [[LIMIT_LAT_C,LIMIT_LON_3], [LIMIT_LAT_D,LIMIT_LON_4]]
              ];

  var lineCoords=[];
  for (var j=0;j<(NUM_ZONES_PER_SIDE+1);j++){
        lineCoords[j]=[pointCoords[(NUM_ZONES_PER_SIDE+1)*j], pointCoords[(NUM_ZONES_PER_SIDE+1)*j+NUM_ZONES_PER_SIDE]];
  }
  for (var j=0;j<(NUM_ZONES_PER_SIDE+1);j++){
        lineCoords[j+NUM_ZONES_PER_SIDE+1]=[pointCoords[j], pointCoords[(NUM_ZONES_PER_SIDE+1)*NUM_ZONES_PER_SIDE+j]];
  }
  var line=[];
  for (var i=0;i<(2*(NUM_ZONES_PER_SIDE+1));i++){
    line[i] = new google.maps.Polyline({path: lineCoords[i], map: map2});
  }

  var k = 0;
  for(var i=0;i<9;i++){
     for(var j=0;j<9;j++){
                 //indx = 11-(Math.round(matrix[i][j]/321*11));
                 indx = 11-(Math.round(matrix[i][j]/108*11));
                 if ( indx > 10 ) indx = 10;
                 if ( indx < 0 ) indx = 0;
                 console.log("("+i+","+j+")="+indx+"--"+matrix[i][j]);
                 var rectangle = new google.maps.Rectangle({
			             strokeColor: colors3[indx],
                                     strokeOpacity: 0.8,
                                     strokeWeight: 2,
                                     fillColor: colors3[indx],
                                     fillOpacity: 0.35,
                                     map: map2,
                                     bounds: new google.maps.LatLngBounds(
                                     new google.maps.LatLng(limits[i][0][0] + (Math.floor(j/3))  *(limits[i][1][0]-limits[i][0][0])/3, 
                                                            limits[i][0][1] + (j%3)              *(limits[i][1][1]-limits[i][0][1])/3),
                                     new google.maps.LatLng(limits[i][0][0] + (Math.floor(j/3)+1)*(limits[i][1][0]-limits[i][0][0])/3,
                                                            limits[i][0][1] + ((j%3)+1)          *(limits[i][1][1]-limits[i][0][1])/3)
                                     )  
                                   });
                 k++;
     }
  }
}
