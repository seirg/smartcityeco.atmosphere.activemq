/*
 * Copyright 2014 Jeanfrancois Arcand
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package org.research.smartcityeco.samples.map.atmosphere;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import org.atmosphere.annotation.Broadcast;
import org.atmosphere.annotation.Suspend;
import org.atmosphere.config.service.AtmosphereService;
import org.atmosphere.cpr.AtmosphereResourceEvent;
import org.atmosphere.cpr.AtmosphereResourceEventListenerAdapter;
import org.atmosphere.jersey.JerseyBroadcaster;
import org.geojson.Feature;
import org.geojson.FeatureCollection;
import org.geojson.Point;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Simple chat resource demonstrating the power of Atmosphere. This resource supports transport like WebSocket, Streaming, JSONP and Long-Polling.
 *
 * @author SmartCity.eco
 */
@Path("/map/")
@AtmosphereService (broadcaster = JerseyBroadcaster.class)
public class MapResource {

    static int maxId = 0;

    /**
     * Suspend the response without writing anything back to the client.
     *
     * @return a white space
     */
    @Suspend(contentType = "application/json", listeners = {OnDisconnect.class})
    @GET
    public String suspend() {
        return "";
    }

    /**
     * Broadcast the received message object to all suspended response. Do not write back the message to the calling connection.
     *
     * @param message a {@link GeoPayload}
     * @return a {@link GeoResponse}
     */
    @Broadcast(writeEntity = false)
    @POST
    @Produces("application/json")
    public GeoResponse broadcast(GeoPayload message) {

        FeatureCollection collection = new FeatureCollection();

        Feature feature = new Feature();
        switch (message.getAction()) {
            case ADD:
                feature.setGeometry(new Point(message.getLongitude(), message.getLatitude()));
                feature.setId((++maxId) + "");
                feature.getProperties().put("id", maxId);
                break;
            case DELETE:
                feature.setId(message.getFeatureId() + "");
                break;
            case MODIFY:
                feature.setGeometry(new Point(message.getLongitude(), message.getLatitude()));
                feature.setId(message.getFeatureId() + "");
                feature.getProperties().put("id", maxId);
                break;
            default:
                throw new IllegalArgumentException("Not supported RTAction value " + message.getAction().name());
        }

        collection.add(feature);
        
        return new GeoResponse(message.getAuthor(), message.getAction(), collection);
    }

    public static final class OnDisconnect extends AtmosphereResourceEventListenerAdapter {
        private final Logger logger = LoggerFactory.getLogger(MapResource.class);

        /**
         * {@inheritDoc}
         */
        @Override
        public void onDisconnect(AtmosphereResourceEvent event) {
            if (event.isCancelled()) {
                logger.info("Browser {} unexpectedly disconnected", event.getResource().uuid());
            } else if (event.isClosedByClient()) {
                logger.info("Browser {} closed the connection", event.getResource().uuid());
            }
        }
    }

}
