package org.research.smartcityeco.samples;

import java.util.Set;

import javax.ws.rs.core.Application;

import org.research.smartcityeco.samples.chat.ChatResource;
import org.research.smartcityeco.samples.chat.ChatResourceTopic;
import org.research.smartcityeco.samples.map.atmosphere.MapResource;
import org.research.smartcityeco.samples.rest.jersey.EventRest;

public class ApplicationConfig extends Application {

	@Override
	public Set<Class<?>> getClasses() {
		Set<Class<?>> resources = new java.util.HashSet<Class<?>>();
		resources.add(MapResource.class);
		resources.add(EventRest.class);
		resources.add(ChatResource.class);
		resources.add(ChatResourceTopic.class);
		return resources;
	}
}
