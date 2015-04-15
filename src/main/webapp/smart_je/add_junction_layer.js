function initMap() {
	var map = SMC.map('map');
	map.setView([37.383333, -5.983333], 13);
	var base = SMC.tileLayer({
        url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', 
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
        maxZoom: 18
    }).addTo(map);

    $.ajax({
        dataType: "json",
        url: "../dist/resources/traffic_junctions_seville.geojson",
        success: function(data) {
            L.Icon.Default.imagePath = "../dist/images";
            //var stylesheet = '* {markerWidth: 25; markerHeight: 25;}'; 
            var stylesheet = '* {markerWidth: 25; markerHeight: 25; anchorTop: 14; anchorLeft: 14; popUpOffsetTop:-10; popUpTemplate: "<div>Cruce <b>{{descripcion}}</b><br><object type=text/html data=SmartJE.html?fileName={{codigo}} height=570 width=800></object></div>"; iconUrl: "junction.gif";}';
            var marcador = new SMC.layers.markers.MarkerLayer({
                stylesheet: stylesheet
            });
            marcador.load = function() {
                marcador.addMarkerFromFeature(data.features);
            };
            marcador.addTo(map);
        }
    });
}
window.onload = initMap;