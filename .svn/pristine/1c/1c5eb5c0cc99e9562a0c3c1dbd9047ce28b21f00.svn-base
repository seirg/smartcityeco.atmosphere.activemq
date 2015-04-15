package org.research.smartcityeco.samples.rest.jersey;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlTransient;

import org.codehaus.jackson.annotate.JsonProperty;

@XmlRootElement(name = "Event")
public class EventVO {
	
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy:MM:dd:HH:mm:ss");
	
	@XmlElement
	Long eventID;
	
	//code
    @XmlElement(name = "code")
    @JsonProperty("code")
    public String code;

    //createTimestamp
    @XmlElement(name = "createTimestamp")
    public String createTimestamp;
    
    //startTimestamp
    @XmlElement(name = "startTimestamp")
    public String startTimestamp;

    //endTimestamp
    @XmlElement(name = "endTimestamp")
    public String endTimestamp;

    //source
    @XmlElement(name = "source")
    public String source;

    //description
    @XmlElement(name = "description")
    public String description;

    //isDescEdited
    @XmlElement(name = "isDescEdited")
    public String isDescEdited;

    //updateTimestamp
    @XmlElement(name = "updateTimestamp")
    public String updateTimestamp;

    //location
    @XmlElement(name = "location")
    public String location;

    //eventType
    @XmlElement(name = "eventType")
    public String eventType;
	
	@XmlTransient
	public Long getEventID() {
		return eventID;
	}

	public void setEventID(Long eventID) {
		this.eventID = eventID;
	}

	@XmlTransient
	public String getCode() {
		return code;
	}

	public void setCode(String eventKey) {
		this.code = eventKey;
	}

	@XmlTransient
	public Date getCreateTimestamp() throws ParseException {
		if (createTimestamp!=null && !createTimestamp.isEmpty()) {
			return sdf.parse(createTimestamp);
		} else {
			return null;
		}
	}

	public void setCreateTimestamp(String createTimestamp) {
		this.createTimestamp = createTimestamp;
	}

	@XmlTransient
	public Date getStartTimestamp() throws ParseException {
		if (startTimestamp!=null && !startTimestamp.isEmpty()) {
			return sdf.parse(startTimestamp);
		} else {
			return null;
		}
	}

	public void setStartTimestamp(String startTimestamp) {
		this.startTimestamp = startTimestamp;
	}

	@XmlTransient
	public Date getEndTimestamp() throws ParseException {
		if (endTimestamp!=null && !endTimestamp.isEmpty()) {
			return sdf.parse(endTimestamp);
		} else {
			return null;
		}
	}

	public void setEndTimestamp(String endTimestamp) {
		this.endTimestamp = endTimestamp;
	}
	
	@XmlTransient
	public Date getUpdateTimestamp() throws ParseException {
		if (updateTimestamp!=null && !updateTimestamp.isEmpty()) {
			return sdf.parse(updateTimestamp);
		} else {
			return null;
		}
	}

	public void setUpdateTimestamp(String updateTimestamp) {
		this.updateTimestamp = updateTimestamp;
	}

	@XmlTransient
	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	@XmlTransient
	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	@XmlTransient
	public String getIsDescEdited() {
		return isDescEdited;
	}
	
	@XmlTransient
	public Boolean getIsDescEditedBool() {
		return Boolean.valueOf(isDescEdited);
	}

	public void setIsDescEdited(String isDescEdited) {
		this.isDescEdited = isDescEdited;
	}

	@XmlTransient
	public String getLocation() {
		return location;
	}
	
	public void setLocation(String location) {
		this.location = location;
	}

	@XmlTransient
	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}
	
//	Date startDate;
//	
//	@XmlElement(name = "startDateForm")
//	String startDateFormatted;
//
//	@XmlTransient
//	public Date getStartDate() {
//		return startDate;
//	}
//
//	public void setStartDate(Date startDate) {
//		this.startDate = startDate;
//		SimpleDateFormat sdf = new SimpleDateFormat("YYYYMMddHHmmss");
//		this.startDateFormatted = sdf.format(startDate);
//	}
//	
//	@XmlTransient
//	public String getStartDateFormatted() {
//		return startDateFormatted;
//	}


//	@XmlTransient
//	public String getAirTimeServiceFormatted() {
//		SimpleDateFormat sdf = new SimpleDateFormat("YYYYMMddHHmmss");
//		return sdf.format(airTimeService);
//	}

}
