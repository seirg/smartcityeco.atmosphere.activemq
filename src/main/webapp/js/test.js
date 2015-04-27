function initMap() {

    // Centered in London
    var map = SMC.map('map');
    map.setView([37.378736, -6.000823], 15);
    //map.setView([53.4666677, -2.2333333], 9);



    var base = SMC.tileLayer({
        url: 'http://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>',
        maxZoom: 18
    }).addTo(map);

    var satelite = SMC.tileLayer({
        url: "http://maps.opengeo.org/geowebcache/service/wms",
        layers: "bluemarble",
        format: 'image/png',
        transparent: true,
        attribution: "Weather data © 2012 IEM Nexrad"
    });

    var baseLayer = {
        "Street Map": base,
        "Satelite": satelite
    };


    var leyenda = SMC.layerTreeControl(baseLayer, {
        collapsed: false
    }).addTo(map);


    $.ajax({
        dataType: "json",
        url: "dist/resources/traffic_cams_seville.geojson",
        success: function (data) {
            L.Icon.Default.imagePath = "../images";
            var stylesheet = '* {markerWidth: 25; markerHeight: 25; anchorTop: 14; anchorLeft: 14; popUpOffsetTop:-10; popUpTemplate: "<div>C&aacute;mara <b>{{codigo}}</b><br><b>{{descripcion}}</b><br><img id={{codigo}} src=http://trafico.sevilla.org/camaras/cam{{codigo}}.jpg height=220 width=300></img></div>";} [filtrada=N]{iconUrl: "http://trafico.sevilla.org/img/CameraGreen.png";} [filtrada=S]{iconUrl: "http://trafico.sevilla.org/img/CameraBlack.png";}';
            var marcador = new SMC.layers.markers.MarkerLayer({
                stylesheet: stylesheet,
                label: "Cruces de Tráfico"
            });
            marcador.load = function () {
                marcador.addMarkerFromFeature(data.features);
            };
            marcador.onFeatureClicked = function (feature) {
                var images = $('img[id=' + feature.feature.properties.codigo + ']');
                if (images.length > 0) {
                    images[0].src += "?" + new Date().getTime();
                }
            };
            marcador.addTo(map);
        }
    });

    $.ajax({
        dataType: "json",
        url: "dist/resources/traffic_junctions_seville.geojson",
        success: function (data) {
            L.Icon.Default.imagePath = "../dist/images";
            //var stylesheet = '* {markerWidth: 25; markerHeight: 25;}';
            var stylesheet = '* {markerWidth: 25; markerHeight: 25; anchorTop: 14; anchorLeft: 14; popUpOffsetTop:-10; popUpTemplate: "<div>Cruce <b>{{descripcion}}</b><br><object type=text/html data=../smart_je/SmartJE.html?fileName={{codigo}} height=570 width=800></object></div>"; iconUrl: "junction.gif";}';
            var marcador = new SMC.layers.markers.MarkerLayer({
                stylesheet: stylesheet,
                label: "Cámaras de Tráfico"
            });
            marcador.load = function () {
                marcador.addMarkerFromFeature(data.features);
            };
            marcador.addTo(map);
        }
    });

    map.loadLayers([
        {
            id: "eventMarkerLayer",
            type: "URLMarkerLayer",
            params: [{
                    label: "Primera capa",
                    //url: "http://172.28.99.70:8081/sc.eco/rest/event/geojsonp",
                    url: "http://195.77.82.75:8888/rest/event/geojsonp",
                    dataType: "jsonp"
                }]
        }, {
            id: "realTimeLayer",
            type: "SMC.layers.markers.AtmosphereRTMarkerLayer",
            params: [{
                    label: "Segunda capa",
                    url: "atmosphere/map",
                    topic: "",
                    stylesheetURL: "styles/style.markercss"
                }],
            listeners: {
                socketOpened: function (data) {
//                console.debug("RealTime Socket opened");
//
//                window.socket = data.target.socket;
//                map.on("click", function(e) {
//                    socket.push(JSON.stringify({
//                        author: "web browser",
//                        action: "ADD",
//                        latitude: e.latlng.lat,
//                        longitude: e.latlng.lng
//                    }));
//                });
                }
            }
        }, {
            id: "trafficLiveLayer",
            type: "SMC.layers.WMSLayer",
            params: [{
                    label: "Tercera capa",
                    //url: "http://172.28.99.44:8080/geoserver/icm/wms",
                    url: "http://195.77.82.75:8888/geoserver/icm/wms",
                    layers: "icm:oip_link"
                }]

        }, {
            id: "trafficHistoryLayer",
            type: "SMC.layers.geometry.SolrGeometryHistoryLayer",
            params: [{
                    //serverURL: "http://172.28.99.70:8983/solr/traffic/select",
                    serverURL: "http://195.77.82.75:8888/solr/traffic/select",
                    timeField: 'time',
                    label: "Histórico Tráfico",
                    time: 1000,
                    stylesheet: '*[density=12.0]{color: "red";} *[density=11.0]{color: "#FACC2E";} *[density=10.0]{color: "#088A08";} '
                }]
        }]);

    window._markersLayer = map.loadedLayers.realTimeLayer;




}
;


L.Icon.Default.imagePath = "dist/images";

window.onload = initMap;
