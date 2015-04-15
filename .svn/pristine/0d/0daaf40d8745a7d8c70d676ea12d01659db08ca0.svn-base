function initMap() {

    // Centered in London
    var map = SMC.map('map');
    //map.setView([-0.2298500, -78.5249500], 8)
    map.setView([37.378736, -6.000823], 6);



    var base = L.tileLayer('http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
        maxZoom: 18
    }).addTo(map);

    var satelite = L.tileLayer.wms("http://maps.opengeo.org/geowebcache/service/wms", {
        layers: "bluemarble",
        format: 'image/png',
        transparent: true,
        attribution: "Weather data © 2012 IEM Nexrad"
    });



    map.loadLayers([{
        type: "URLMarkerLayer",
        params: [{
            url: "js/wfs2.json",
            dataType: "json"
        }]
    }]);

    var baseLayer = {
        "Street Map": base,
        "Satelite": satelite
    };


    var leyenda = L.control.layers(baseLayer, null, {
        collapsed: false
    }).addTo(map);



}



L.Icon.Default.imagePath = "dist/images";

window.onload = initMap;
