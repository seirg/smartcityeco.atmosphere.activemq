package org.research.smartcityeco.samples.rest.jersey;

import java.util.Date;

import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;

import org.atmosphere.cpr.BroadcasterFactory;
import org.geojson.Feature;
import org.geojson.FeatureCollection;
import org.geojson.Point;
import org.research.smartcityeco.samples.map.atmosphere.GeoResponse;
import org.research.smartcityeco.samples.map.atmosphere.RTAction;

@Path("/event")
public class EventRest {
	
	@Context 
	BroadcasterFactory broadcasterFactory;

	@GET
	@Produces({ "application/xml", "application/json" })
	public EventVO getEvent() throws Exception {
		EventVO eventVO = new EventVO();
		eventVO.setEventID(23L);
		eventVO.setCode("SFCHDSK");
		eventVO.setStartTimestamp(new Date().toString());
		return eventVO;
	}

	@POST
	@Consumes({"application/xml","application/json"})
	public Response receiveEvent(EventVO eventVO)
			throws Exception {
		FeatureCollection collection = new FeatureCollection();
		
        Feature feature = new Feature();
        feature.setProperty("eventID", eventVO.eventID);
        feature.setProperty("code", "emergency");
        feature.setGeometry(getLocationPoint(eventVO));
        collection.add(feature);
        GeoResponse response = new GeoResponse("Active MQ", RTAction.ADD, collection);
        broadcasterFactory.lookup("/*").broadcast(response);
        //BroadcasterFactory.getDefault().lookup("/*").broadcast(response);
		
		return Response.ok(eventVO.getCode()).build();
	}
	
	private Point getLocationPoint(EventVO eventVO) {
		if (eventVO.getLocation()!=null) {
			String[] geometry = eventVO.getLocation().trim().split(";");
			//String aux = geometry[0].substring(0, Math.min(6, geometry[0].length()));
			String aux = geometry[0].replaceAll(",", ".");
			double longitude = Double.valueOf(aux);
			aux = geometry[1].replaceAll(",", ".");			
			double latitude = Double.valueOf(aux);
			return new Point(longitude, latitude);			
		} else {
			return null;
		}
		
	}

}
