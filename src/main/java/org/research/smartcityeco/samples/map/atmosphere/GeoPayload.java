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

import java.io.Serializable;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class GeoPayload implements Serializable {

    private String author;
    private RTAction action;
    private int featureId;
    private double latitude;
    private double longitude;

    public GeoPayload() {
        
    }

    /**
     * @return the author
     */
    public String getAuthor() {
        return author;
    }

    /**
     * @param author the author to set
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * @return the latitude
     */
    public double getLatitude() {
        return latitude;
    }

    /**
     * @param latitude the latitude to set
     */
    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    /**
     * @return the longitude
     */
    public double getLongitude() {
        return longitude;
    }

    /**
     * @param longitude the longitude to set
     */
    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    /**
     * @return the action
     */
    public RTAction getAction() {
        return action;
    }

    /**
     * @param action the action to set
     */
    public void setAction(RTAction action) {
        this.action = action;
    }

    /**
     * @return the featureId
     */
    public int getFeatureId() {
        return featureId;
    }

    /**
     * @param featureId the featureId to set
     */
    public void setFeatureId(int featureId) {
        this.featureId = featureId;
    }

   
}
