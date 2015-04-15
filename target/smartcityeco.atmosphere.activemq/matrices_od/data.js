  var svg;

//  var matrix = [
//        [  291,    57,    8,   61, 108,  13,  22,  14,  64],
//        [   25,    57,   18,    4,  28,   8,   1,   5,  18],
//        [    3,    17,   19,    0,   3,  10,   0,   2,   8],
//        [   46,     1,    1,  141,  38,   6,  21,   5,   9],
//        [   38,    21,    6,   34, 321,  26,   2,  26,  69],
//        [    2,     4,   14,    8,  16, 122,   0,   5,  23],
//        [    3,     1,    0,   15,   2,   2,  37,  18,   8],
//        [    2,     1,    2,    5,  12,   7,  15, 105,  16],
//        [    4,     3,    2,    0,  33,  15,   3,   9,  83]
//     ];

  var matrix = [
        [   88,   101,   24,  127, 294,  64,  65,  49, 211],
        [   22,    35,   23,   19,  30,  12,  10,   8,  39],
        [    7,     8,   16,   10,   4,  21,   3,   8,  24],
        [   24,    14,    4,   41,  36,   6,  12,  16,  29],
        [   35,    26,    9,   40, 118,  16,  12,  20,  68],
        [   10,    10,    2,   21,  25,  70,   8,  12,  41],
        [    8,     4,    2,    7,  11,   8,  14,  35,  26],
        [    8,     5,    4,    5,   9,  16,   8,  35,  25],
        [    6,     4,    2,    7,   8,  11,   2,   9,  44]
      ];

  var names = ["Luis Montoto","San Julián","Ctra Carmona","Plaza del Duque",
                "La Alfalfa","Santa Justa","Teatro de la Maestranza","San Bernardo","Eduardo Dato"];

  var colors=["#FF0000", 
              "#FF3300", 
              "#FF0066", 
              "#FF3366",
              "#FF6666",
              "#FF9966",
              "#FFCC66",
              "#FFFF66",
              "#FF66FF" ];
  var colors2 =[  
              "#170104","#300208",
              "#48040C","#610510",
              "#780613","#910717",
              "#AA081B","#C20A1F",
              "#D90B23",
              "#F20C27",
              "#F30D2D","#F4243C",
              "#F53D52","#F75367",
              "#F86C7D","#F98593",
              "#FA9EA9","#FBB5BD",
              "#FDCDD3","#FEE6E9"
             ];
  var colors3 = [
              "#F20C27",
              "#F30D2D","#F4243C",
              "#F53D52","#F75367",
              "#F86C7D","#F98593",
              "#FA9EA9","#FBB5BD",
              "#FDCDD3","#FEE6E9"
             ];
 
 
  var width  = 350,
      height = 350,
      innerRadius = Math.min(width, height) * .21,
      outerRadius = innerRadius * 1.1;


  var mapOptions = {
    zoom: 15,
    center: new google.maps.LatLng(37.39, -5.985),
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  var NUM_ZONES_PER_SIDE = 3;
  var NUM_ZONES = NUM_ZONES_PER_SIDE*NUM_ZONES_PER_SIDE;

  var LIMIT_LON_1=-5.998
  var LIMIT_LON_2=-5.990
  var LIMIT_LON_3=-5.981
  var LIMIT_LON_4=-5.976
  var LIMIT_LAT_A=37.4004075
  var LIMIT_LAT_B=37.394985
  var LIMIT_LAT_C=37.38885
  var LIMIT_LAT_D=37.38309
  var pointCoords=[new google.maps.LatLng(LIMIT_LAT_A,LIMIT_LON_1),
                   new google.maps.LatLng(LIMIT_LAT_A,LIMIT_LON_2),
                   new google.maps.LatLng(LIMIT_LAT_A,LIMIT_LON_3),
                   new google.maps.LatLng(LIMIT_LAT_A,LIMIT_LON_4),

                   new google.maps.LatLng(LIMIT_LAT_B,LIMIT_LON_1),
                   new google.maps.LatLng(LIMIT_LAT_B,LIMIT_LON_2),
                   new google.maps.LatLng(LIMIT_LAT_B,LIMIT_LON_3),
                   new google.maps.LatLng(LIMIT_LAT_B,LIMIT_LON_4),

                   new google.maps.LatLng(LIMIT_LAT_C,LIMIT_LON_1),
                   new google.maps.LatLng(LIMIT_LAT_C,LIMIT_LON_2),
                   new google.maps.LatLng(LIMIT_LAT_C,LIMIT_LON_3),
                   new google.maps.LatLng(LIMIT_LAT_C,LIMIT_LON_4),

                   new google.maps.LatLng(LIMIT_LAT_D,LIMIT_LON_1),
                   new google.maps.LatLng(LIMIT_LAT_D,LIMIT_LON_2),
                   new google.maps.LatLng(LIMIT_LAT_D,LIMIT_LON_3),
                   new google.maps.LatLng(LIMIT_LAT_D,LIMIT_LON_4) ];

  var lineCoords=[];
  for (var j=0;j<(NUM_ZONES_PER_SIDE+1);j++){
        lineCoords[j]=[pointCoords[(NUM_ZONES_PER_SIDE+1)*j], pointCoords[(NUM_ZONES_PER_SIDE+1)*j+NUM_ZONES_PER_SIDE]];
  }
  for (var j=0;j<(NUM_ZONES_PER_SIDE+1);j++){
        lineCoords[j+NUM_ZONES_PER_SIDE+1]=[pointCoords[j], pointCoords[(NUM_ZONES_PER_SIDE+1)*NUM_ZONES_PER_SIDE+j]];
  }

  var centerCoords=[[(LIMIT_LAT_A+LIMIT_LAT_B)/2,(LIMIT_LON_1+LIMIT_LON_2)/2],
                    [(LIMIT_LAT_A+LIMIT_LAT_B)/2,(LIMIT_LON_2+LIMIT_LON_3)/2],
                    [(LIMIT_LAT_A+LIMIT_LAT_B)/2,(LIMIT_LON_3+LIMIT_LON_4)/2],

                    [(LIMIT_LAT_B+LIMIT_LAT_C)/2,(LIMIT_LON_1+LIMIT_LON_2)/2],
                    [(LIMIT_LAT_B+LIMIT_LAT_C)/2,(LIMIT_LON_2+LIMIT_LON_3)/2],
                    [(LIMIT_LAT_B+LIMIT_LAT_C)/2,(LIMIT_LON_3+LIMIT_LON_4)/2],

                    [(LIMIT_LAT_C+LIMIT_LAT_D)/2,(LIMIT_LON_1+LIMIT_LON_2)/2],
                    [(LIMIT_LAT_C+LIMIT_LAT_D)/2,(LIMIT_LON_2+LIMIT_LON_3)/2],
                    [(LIMIT_LAT_C+LIMIT_LAT_D)/2,(LIMIT_LON_3+LIMIT_LON_4)/2]
                   ];

var arrowCoords=[];
var k = 0;
for (var i=0;i<9;i++){
      for (var j=0;j<9;j++){
          if ( i!=j ){
                var lati, loni;
                if ( i == 0 ) { lati =  0.0015; loni =-0.002; }
                if ( i == 1 ) { lati =  0.002;  loni = 0.0;   }
                if ( i == 2 ) { lati =  0.0015; loni = 0.002; }
                if ( i == 3 ) { lati =  0.0;    loni =-0.003; }
                if ( i == 4 ) { lati =  0.0;    loni =-0.0;   }
                if ( i == 5 ) { lati =  0.0;    loni = 0.003; }
                if ( i == 6 ) { lati = -0.0015; loni =-0.002; }
                if ( i == 7 ) { lati = -0.002;  loni = 0.0;   }
                if ( i == 8 ) { lati = -0.0015; loni = 0.002; }

                var latf, lonf;
                if ( i == 0 ) { latf =  0.0015; lonf =-0.002; }
                if ( i == 1 ) { latf =  0.002;  lonf = 0.0;   }
                if ( i == 2 ) { latf =  0.0015; lonf = 0.002; }
                if ( i == 3 ) { latf =  0.0;    lonf =-0.003; }
                if ( i == 4 ) { latf =  0.0;    lonf = 0.0;   }
                if ( i == 5 ) { latf =  0.0;    lonf = 0.003; }
                if ( i == 6 ) { latf = -0.0015; lonf =-0.002; }
                if ( i == 7 ) { latf = -0.002;  lonf = 0.0;   }
                if ( i == 8 ) { latf = -0.0015; lonf = 0.002; }
                var iniCoords = [];
                var lonxtra = 0.0;
                if ( i == 3 ) { lonxtra = -0.001; }
                if ( i == 5 ) { lonxtra =  0.001; }
                iniCoords[0] = centerCoords[i][0]+lati;
                iniCoords[1] = centerCoords[i][1]+loni+lonxtra;
                var endCoords = [];
                var lonxtra = 0.0;
                if ( j == 3 ) { lonxtra = -0.001; }
                if ( j == 5 ) { lonxtra =  0.001; }
                endCoords[0] = centerCoords[j][0]+latf;
                endCoords[1] = centerCoords[j][1]+lonf+lonxtra;
                arrowCoords[k] = [iniCoords, endCoords]; 
                k++;
       }
   }
}
    var map;
    var arrow=[];
