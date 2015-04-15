package org.research.smartcityeco.samples.rest.jersey;

import org.codehaus.jackson.map.DeserializationConfig.Feature;
import org.codehaus.jackson.map.ObjectMapper;


public class Test {

	public static void main(String[] args) throws Exception {
		EventVO eventVO = new EventVO();
		eventVO.setEventID(23L);
		eventVO.setCode("SFCHDSK");
		eventVO.setLocation("37.378736;-6.000823");
		ObjectMapper mapper = new ObjectMapper();
		mapper.configure(Feature.FAIL_ON_UNKNOWN_PROPERTIES, false);
		System.out.println();
		mapper.writeValue(System.out, eventVO);
	}

}
