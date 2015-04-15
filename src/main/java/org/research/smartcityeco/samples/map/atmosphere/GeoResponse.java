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

import java.util.Date;
import javax.xml.bind.annotation.XmlRootElement;
import org.geojson.FeatureCollection;

@XmlRootElement
public class GeoResponse {

    private final String author;

    private final RTAction action;

    private final FeatureCollection featureCollection;
    private final long time;

    public GeoResponse(String author, RTAction action, FeatureCollection collection) {
        this.author = author;
        this.featureCollection = collection;
        this.time = new Date().getTime();
        this.action = action;
    }

    /**
     * @return the author
     */
    public String getAuthor() {
        return author;
    }

    /**
     * @return the action
     */
    public RTAction getAction() {
        return action;
    }

    /**
     * @return the featureCollection
     */
    public FeatureCollection getFeatureCollection() {
        return featureCollection;
    }

    /**
     * @return the time
     */
    public long getTime() {
        return time;
    }
}
