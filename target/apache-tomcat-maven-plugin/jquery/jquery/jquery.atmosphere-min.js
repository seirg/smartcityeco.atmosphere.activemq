(function(a){if(typeof define==="function"&&define.amd){define(["jquery"],a)
}else{a(jQuery)
}}(function(c){c(window).bind("unload.atmosphere",function(){c.atmosphere.unsubscribe()
});
c(window).bind("offline",function(){c.atmosphere.offline=true;
var d=[].concat(c.atmosphere.requests);
for(var f=0;
f<d.length;
f++){var e=d[f];
e.close();
clearTimeout(e.response.request.id);
if(e.heartbeatTimer){clearTimeout(e.heartbeatTimer)
}}});
c(window).bind("online",function(){c.atmosphere.offline=false;
if(c.atmosphere.requests.length>0){for(var d=0;
d<c.atmosphere.requests.length;
d++){c.atmosphere.requests[d].init();
c.atmosphere.requests[d].execute()
}}});
c(window).keypress(function(d){if(d.keyCode===27){d.preventDefault()
}});
var a=function(e){var d,g=/^(.*?):[ \t]*([^\r\n]*)\r?$/mg,f={};
while(d=g.exec(e)){f[d[1]]=d[2]
}return f
};
c.atmosphere={version:"2.2.6-jquery",uuid:0,offline:false,requests:[],callbacks:[],onError:function(d){},onClose:function(d){},onOpen:function(d){},onMessage:function(d){},onReconnect:function(e,d){},onMessagePublished:function(d){},onTransportFailure:function(e,d){},onLocalMessage:function(d){},onClientTimeout:function(d){},onFailureToReconnect:function(e,d){},WebsocketApiAdapter:function(e){var d,f;
e.onMessage=function(g){f.onmessage({data:g.responseBody})
};
e.onMessagePublished=function(g){f.onmessage({data:g.responseBody})
};
e.onOpen=function(g){f.onopen(g)
};
f={close:function(){d.close()
},send:function(g){d.push(g)
},onmessage:function(g){},onopen:function(g){},onclose:function(g){},onerror:function(g){}};
d=new $.atmosphere.subscribe(e);
return f
},AtmosphereRequest:function(Y){var l={timeout:300000,method:"GET",headers:{},contentType:"",callback:null,url:"",data:"",suspend:true,maxRequest:-1,reconnect:true,maxStreamingLength:10000000,lastIndex:0,logLevel:"info",requestCount:0,fallbackMethod:"GET",fallbackTransport:"streaming",transport:"long-polling",webSocketImpl:null,webSocketBinaryType:null,dispatchUrl:null,webSocketPathDelimiter:"@@",enableXDR:false,rewriteURL:false,attachHeadersAsQueryString:true,executeCallbackBeforeReconnect:false,readyState:0,withCredentials:false,trackMessageLength:false,messageDelimiter:"|",connectTimeout:-1,reconnectInterval:0,dropHeaders:true,uuid:0,shared:false,readResponsesHeaders:false,maxReconnectOnClose:5,enableProtocol:true,pollingInterval:0,heartbeat:{client:null,server:null},ackInterval:0,closeAsync:false,reconnectOnServerError:true,onError:function(aB){},onClose:function(aB){},onOpen:function(aB){},onMessage:function(aB){},onReopen:function(aC,aB){},onReconnect:function(aC,aB){},onMessagePublished:function(aB){},onTransportFailure:function(aC,aB){},onLocalMessage:function(aB){},onFailureToReconnect:function(aC,aB){},onClientTimeout:function(aB){}};
var al={status:200,reasonPhrase:"OK",responseBody:"",messages:[],headers:[],state:"messageReceived",transport:"polling",error:null,request:null,partialMessage:"",errorHandled:false,closedByClientTimeout:false,ffTryingReconnect:false};
var ap=null;
var ab=null;
var v=null;
var j=null;
var T=null;
var q=true;
var ar=0;
var F=0;
var af=" ";
var aj=false;
var M=null;
var d;
var aq=null;
var N=c.now();
var u;
var aA;
ai(Y);
function ae(){q=true;
aj=false;
ar=0;
ap=null;
ab=null;
v=null;
j=null
}function Q(){g();
ae()
}function s(aB){if(aB=="debug"){return l.logLevel==="debug"
}else{if(aB=="info"){return l.logLevel==="info"||l.logLevel==="debug"
}else{if(aB=="warn"){return l.logLevel==="warn"||l.logLevel==="info"||l.logLevel==="debug"
}else{if(aB=="error"){return l.logLevel==="error"||l.logLevel==="warn"||l.logLevel==="info"||l.logLevel==="debug"
}else{return false
}}}}}function ai(aB){Q();
l=c.extend(l,aB);
l.mrequest=l.reconnect;
if(!l.reconnect){l.reconnect=true
}}function an(){return l.webSocketImpl!=null||window.WebSocket||window.MozWebSocket
}function am(){return window.EventSource
}function V(){if(l.shared){aq=ay(l);
if(aq!=null){if(s("debug")){c.atmosphere.debug("Storage service available. All communication will be local")
}if(aq.open(l)){return
}}if(s("debug")){c.atmosphere.debug("No Storage service available.")
}aq=null
}l.firstMessage=c.atmosphere.uuid==0?true:false;
l.isOpen=false;
l.ctime=c.now();
if(l.uuid===0){l.uuid=c.atmosphere.uuid
}l.closedByClientTimeout=false;
if(l.transport!=="websocket"&&l.transport!=="sse"){H(l)
}else{if(l.transport==="websocket"){if(!an()){at("Websocket is not supported, using request.fallbackTransport ("+l.fallbackTransport+")")
}else{aa(false)
}}else{if(l.transport==="sse"){if(!am()){at("Server Side Events(SSE) is not supported, using request.fallbackTransport ("+l.fallbackTransport+")")
}else{z(false)
}}}}}function ay(aF){var aI,aC,aE,aD="atmosphere-"+aF.url,aB={storage:function(){if(!c.atmosphere.supportStorage()){return
}var aL=window.localStorage,aJ=function(aM){return c.parseJSON(aL.getItem(aD+"-"+aM))
},aK=function(aM,aN){aL.setItem(aD+"-"+aM,c.stringifyJSON(aN))
};
return{init:function(){aK("children",aJ("children").concat([N]));
c(window).on("storage.socket",function(aM){aM=aM.originalEvent;
if(aM.key===aD&&aM.newValue){aH(aM.newValue)
}});
return aJ("opened")
},signal:function(aM,aN){aL.setItem(aD,c.stringifyJSON({target:"p",type:aM,data:aN}))
},close:function(){var aM,aN=aJ("children");
c(window).off("storage.socket");
if(aN){aM=c.inArray(aF.id,aN);
if(aM>-1){aN.splice(aM,1);
aK("children",aN)
}}}}
},windowref:function(){var aJ=window.open("",aD.replace(/\W/g,""));
if(!aJ||aJ.closed||!aJ.callbacks){return
}return{init:function(){aJ.callbacks.push(aH);
aJ.children.push(N);
return aJ.opened
},signal:function(aK,aL){if(!aJ.closed&&aJ.fire){aJ.fire(c.stringifyJSON({target:"p",type:aK,data:aL}))
}},close:function(){function aK(aN,aM){var aL=c.inArray(aM,aN);
if(aL>-1){aN.splice(aL,1)
}}if(!aE){aK(aJ.callbacks,aH);
aK(aJ.children,N)
}}}
}};
function aH(aJ){var aL=c.parseJSON(aJ),aK=aL.data;
if(aL.target==="c"){switch(aL.type){case"open":R("opening","local",l);
break;
case"close":if(!aE){aE=true;
if(aK.reason==="aborted"){D()
}else{if(aK.heir===N){V()
}else{setTimeout(function(){V()
},100)
}}}break;
case"message":h(aK,"messageReceived",200,aF.transport);
break;
case"localMessage":B(aK);
break
}}}function aG(){var aJ=new RegExp("(?:^|; )("+encodeURIComponent(aD)+")=([^;]*)").exec(document.cookie);
if(aJ){return c.parseJSON(decodeURIComponent(aJ[2]))
}}aI=aG();
if(!aI||c.now()-aI.ts>1000){return
}aC=aB.storage()||aB.windowref();
if(!aC){return
}return{open:function(){var aJ;
u=setInterval(function(){var aK=aI;
aI=aG();
if(!aI||aK.ts===aI.ts){aH(c.stringifyJSON({target:"c",type:"close",data:{reason:"error",heir:aK.heir}}))
}},1000);
aJ=aC.init();
if(aJ){setTimeout(function(){R("opening","local",aF)
},50)
}return aJ
},send:function(aJ){aC.signal("send",aJ)
},localSend:function(aJ){aC.signal("localSend",c.stringifyJSON({id:N,event:aJ}))
},close:function(){if(!aj){clearInterval(u);
aC.signal("close");
aC.close()
}}}
}function az(){var aC,aB="atmosphere-"+l.url,aG={storage:function(){if(!c.atmosphere.supportStorage()){return
}var aH=window.localStorage;
return{init:function(){c(window).on("storage.socket",function(aI){aI=aI.originalEvent;
if(aI.key===aB&&aI.newValue){aD(aI.newValue)
}})
},signal:function(aI,aJ){aH.setItem(aB,c.stringifyJSON({target:"c",type:aI,data:aJ}))
},get:function(aI){return c.parseJSON(aH.getItem(aB+"-"+aI))
},set:function(aI,aJ){aH.setItem(aB+"-"+aI,c.stringifyJSON(aJ))
},close:function(){c(window).off("storage.socket");
aH.removeItem(aB);
aH.removeItem(aB+"-opened");
aH.removeItem(aB+"-children")
}}
},windowref:function(){var aH=aB.replace(/\W/g,""),aI=(c('iframe[name="'+aH+'"]')[0]||c('<iframe name="'+aH+'" />').hide().appendTo("body")[0]).contentWindow;
return{init:function(){aI.callbacks=[aD];
aI.fire=function(aJ){var aK;
for(aK=0;
aK<aI.callbacks.length;
aK++){aI.callbacks[aK](aJ)
}}
},signal:function(aJ,aK){if(!aI.closed&&aI.fire){aI.fire(c.stringifyJSON({target:"c",type:aJ,data:aK}))
}},get:function(aJ){return !aI.closed?aI[aJ]:null
},set:function(aJ,aK){if(!aI.closed){aI[aJ]=aK
}},close:function(){}}
}};
function aD(aH){var aJ=c.parseJSON(aH),aI=aJ.data;
if(aJ.target==="p"){switch(aJ.type){case"send":p(aI);
break;
case"localSend":B(aI);
break;
case"close":D();
break
}}}M=function aF(aH){aC.signal("message",aH)
};
function aE(){document.cookie=aA+"="+encodeURIComponent(c.stringifyJSON({ts:c.now()+1,heir:(aC.get("children")||[])[0]}))+"; path=/"
}aC=aG.storage()||aG.windowref();
aC.init();
if(s("debug")){c.atmosphere.debug("Installed StorageService "+aC)
}aC.set("children",[]);
if(aC.get("opened")!=null&&!aC.get("opened")){aC.set("opened",false)
}aA=encodeURIComponent(aB);
aE();
u=setInterval(aE,1000);
d=aC
}function R(aD,aG,aC){if(l.shared&&aG!=="local"){az()
}if(d!=null){d.set("opened",true)
}aC.close=function(){D()
};
if(ar>0&&aD==="re-connecting"){aC.isReopen=true;
m(al)
}else{if(al.error==null){al.request=aC;
var aE=al.state;
al.state=aD;
var aB=al.transport;
al.transport=aG;
var aF=al.responseBody;
ad();
al.responseBody=aF;
al.state=aE;
al.transport=aB
}}}function av(aD){aD.transport="jsonp";
var aC=l;
if((aD!=null)&&(typeof(aD)!=="undefined")){aC=aD
}var aB=aC.url;
if(aC.dispatchUrl!=null){aB+=aC.dispatchUrl
}var aE=aC.data;
if(aC.attachHeadersAsQueryString){aB=k(aC);
if(aE!==""){aB+="&X-Atmosphere-Post-Body="+encodeURIComponent(aE)
}aE=""
}T=c.ajax({url:aB,type:aC.method,dataType:"jsonp",error:function(aF,aH,aG){al.error=true;
if(aC.openId){clearTimeout(aC.openId)
}if(aC.heartbeatTimer){clearTimeout(aC.heartbeatTimer)
}if(aC.reconnect&&ar++<aC.maxReconnectOnClose){R("re-connecting",aC.transport,aC);
ah(T,aC,aC.reconnectInterval);
aC.openId=setTimeout(function(){U(aC)
},aC.reconnectInterval+1000)
}else{P(aF.status,aG)
}},jsonp:"jsonpTransport",success:function(aG){if(aC.reconnect){if(aC.maxRequest===-1||aC.requestCount++<aC.maxRequest){C(T,aC);
if(!aC.executeCallbackBeforeReconnect){ah(T,aC,aC.pollingInterval)
}var aI=aG.message;
if(aI!=null&&typeof aI!=="string"){try{aI=c.stringifyJSON(aI)
}catch(aH){}}var aF=n(aI,aC,al);
if(!aF){h(al.responseBody,"messageReceived",200,aC.transport)
}if(aC.executeCallbackBeforeReconnect){ah(T,aC,aC.pollingInterval)
}f(aC)
}else{c.atmosphere.log(l.logLevel,["JSONP reconnect maximum try reached "+l.requestCount]);
P(0,"maxRequest reached")
}}},data:aC.data,beforeSend:function(aF){I(aF,aC,false)
}})
}function ax(aE){var aC=l;
if((aE!=null)&&(typeof(aE)!=="undefined")){aC=aE
}var aB=aC.url;
if(aC.dispatchUrl!=null){aB+=aC.dispatchUrl
}var aF=aC.data;
if(aC.attachHeadersAsQueryString){aB=k(aC);
if(aF!==""){aB+="&X-Atmosphere-Post-Body="+encodeURIComponent(aF)
}aF=""
}var aD=typeof(aC.async)!=="undefined"?aC.async:true;
T=c.ajax({url:aB,type:aC.method,error:function(aG,aI,aH){al.error=true;
if(aG.status<300){ah(T,aC)
}else{P(aG.status,aH)
}},success:function(aI,aJ,aH){if(aC.reconnect){if(aC.maxRequest===-1||aC.requestCount++<aC.maxRequest){if(!aC.executeCallbackBeforeReconnect){ah(T,aC,aC.pollingInterval)
}var aG=n(aI,aC,al);
if(!aG){h(al.responseBody,"messageReceived",200,aC.transport)
}if(aC.executeCallbackBeforeReconnect){ah(T,aC,aC.pollingInterval)
}}else{c.atmosphere.log(l.logLevel,["AJAX reconnect maximum try reached "+l.requestCount]);
P(0,"maxRequest reached")
}}},beforeSend:function(aG){I(aG,aC,false)
},crossDomain:aC.enableXDR,async:aD})
}function ao(aB){if(l.webSocketImpl!=null){return l.webSocketImpl
}else{if(window.WebSocket){return new WebSocket(aB)
}else{return new MozWebSocket(aB)
}}}function r(){var aB=k(l);
return decodeURI(c('<a href="'+aB+'"/>')[0].href.replace(/^http/,"ws"))
}function O(){var aB=k(l);
return aB
}function z(aC){al.transport="sse";
var aB=O(l.url);
if(s("debug")){c.atmosphere.debug("Invoking executeSSE");
c.atmosphere.debug("Using URL: "+aB)
}if(aC&&!l.reconnect){if(ab!=null){g()
}return
}try{ab=new EventSource(aB,{withCredentials:l.withCredentials})
}catch(aD){P(0,aD);
at("SSE failed. Downgrading to fallback transport and resending");
return
}if(l.connectTimeout>0){l.id=setTimeout(function(){if(!aC){g()
}},l.connectTimeout)
}ab.onopen=function(aE){f(l);
if(s("debug")){c.atmosphere.debug("SSE successfully opened")
}if(!l.enableProtocol){if(!aC){R("opening","sse",l)
}else{R("re-opening","sse",l)
}}else{if(l.isReopen){l.isReopen=false;
R("re-opening",l.transport,l)
}}aC=true;
if(l.method==="POST"){al.state="messageReceived";
ab.send(l.data)
}};
ab.onmessage=function(aF){f(l);
if(!l.enableXDR&&aF.origin!==window.location.protocol+"//"+window.location.host){c.atmosphere.log(l.logLevel,["Origin was not "+window.location.protocol+"//"+window.location.host]);
return
}al.state="messageReceived";
al.status=200;
aF=aF.data;
var aE=n(aF,l,al);
if(!aE){ad();
al.responseBody="";
al.messages=[]
}};
ab.onerror=function(aE){clearTimeout(l.id);
if(l.heartbeatTimer){clearTimeout(l.heartbeatTimer)
}if(al.closedByClientTimeout){return
}Z(aC);
g();
if(aj){c.atmosphere.log(l.logLevel,["SSE closed normally"])
}else{if(!aC){at("SSE failed. Downgrading to fallback transport and resending")
}else{if(l.reconnect&&(al.transport==="sse")){if(ar++<l.maxReconnectOnClose){R("re-connecting",l.transport,l);
if(l.reconnectInterval>0){l.reconnectId=setTimeout(function(){z(true)
},l.reconnectInterval)
}else{z(true)
}al.responseBody="";
al.messages=[]
}else{c.atmosphere.log(l.logLevel,["SSE reconnect maximum try reached "+ar]);
P(0,"maxReconnectOnClose reached")
}}}}}
}function aa(aC){al.transport="websocket";
var aB=r(l.url);
if(s("debug")){c.atmosphere.debug("Invoking executeWebSocket");
c.atmosphere.debug("Using URL: "+aB)
}if(aC&&!l.reconnect){if(ap!=null){g()
}return
}ap=ao(aB);
if(l.webSocketBinaryType!=null){ap.binaryType=l.webSocketBinaryType
}if(l.connectTimeout>0){l.id=setTimeout(function(){if(!aC){var aF={code:1002,reason:"",wasClean:false};
ap.onclose(aF);
try{g()
}catch(aG){}return
}},l.connectTimeout)
}ap.onopen=function(aG){f(l);
if(s("debug")){c.atmosphere.debug("Websocket successfully opened")
}c.atmosphere.offline=false;
var aF=aC;
if(ap!=null){ap.canSendMessage=true
}if(!l.enableProtocol){aC=true;
if(aF){R("re-opening","websocket",l)
}else{R("opening","websocket",l)
}}if(ap!=null){if(l.method==="POST"){al.state="messageReceived";
ap.send(l.data)
}}};
ap.onmessage=function(aH){f(l);
if(l.enableProtocol){aC=true
}al.state="messageReceived";
al.status=200;
aH=aH.data;
var aF=typeof(aH)==="string";
if(aF){var aG=n(aH,l,al);
if(!aG){ad();
al.responseBody="";
al.messages=[]
}}else{aH=o(l,aH);
if(aH===""){return
}al.responseBody=aH;
ad();
al.responseBody=null
}};
ap.onerror=function(aF){clearTimeout(l.id);
if(l.heartbeatTimer){clearTimeout(l.heartbeatTimer)
}};
ap.onclose=function(aF){if(al.state==="closed"){return
}clearTimeout(l.id);
var aG=aF.reason;
if(aG===""){switch(aF.code){case 1000:aG="Normal closure; the connection successfully completed whatever purpose for which it was created.";
break;
case 1001:aG="The endpoint is going away, either because of a server failure or because the browser is navigating away from the page that opened the connection.";
break;
case 1002:aG="The endpoint is terminating the connection due to a protocol error.";
break;
case 1003:aG="The connection is being terminated because the endpoint received data of a type it cannot accept (for example, a text-only endpoint received binary data).";
break;
case 1004:aG="The endpoint is terminating the connection because a data frame was received that is too large.";
break;
case 1005:aG="Unknown: no status code was provided even though one was expected.";
break;
case 1006:aG="Connection was closed abnormally (that is, with no close frame being sent).";
break
}}if(s("warn")){c.atmosphere.warn("Websocket closed, reason: "+aG);
c.atmosphere.warn("Websocket closed, wasClean: "+aF.wasClean)
}if(al.closedByClientTimeout||c.atmosphere.offline){if(l.reconnectId){clearTimeout(l.reconnectId);
delete l.reconnectId
}return
}Z(aC);
al.state="closed";
if(aj){c.atmosphere.log(l.logLevel,["Websocket closed normally"])
}else{if(!aC){at("Websocket failed. Downgrading to Comet and resending")
}else{if(l.reconnect&&al.transport==="websocket"&&aF.code!==1001){g();
if(ar++<l.maxReconnectOnClose){R("re-connecting",l.transport,l);
if(l.reconnectInterval>0){l.reconnectId=setTimeout(function(){al.responseBody="";
al.messages=[];
aa(true)
},l.reconnectInterval)
}else{al.responseBody="";
al.messages=[];
aa(true)
}}else{c.atmosphere.log(l.logLevel,["Websocket reconnect maximum try reached "+l.requestCount]);
if(s("warn")){c.atmosphere.warn("Websocket error, reason: "+aF.reason)
}P(0,"maxReconnectOnClose reached")
}}}}};
var aD=navigator.userAgent.toLowerCase();
var aE=aD.indexOf("android")>-1;
if(aE&&ap.url===undefined){ap.onclose({reason:"Android 4.1 does not support websockets.",wasClean:false})
}}function o(aF,aE){var aD=aE;
if(aF.transport==="polling"){return aD
}if(c.trim(aE).length!==0&&aF.enableProtocol&&aF.firstMessage){var aG=aF.trackMessageLength?1:0;
var aC=aE.split(aF.messageDelimiter);
if(aC.length<=aG+1){return aD
}aF.firstMessage=false;
aF.uuid=c.trim(aC[aG]);
if(aC.length<=aG+2){c.atmosphere.log("error",["Protocol data not sent by the server. If you enable protocol on client side, be sure to install JavascriptProtocol interceptor on server side.Also note that atmosphere-runtime 2.2+ should be used."])
}F=parseInt(c.trim(aC[aG+1]),10);
af=aC[aG+2];
b=false;
if(aF.transport!=="long-polling"){U(aF)
}c.atmosphere.uuid=aF.uuid;
aD="";
aG=aF.trackMessageLength?4:3;
if(aC.length>aG+1){for(var aB=aG;
aB<aC.length;
aB++){aD+=aC[aB];
if(aB+1!==aC.length){aD+=aF.messageDelimiter
}}}if(aF.ackInterval!==0){setTimeout(function(){p("...ACK...")
},aF.ackInterval)
}}else{if(aF.enableProtocol&&aF.firstMessage&&c.browser.msie&&+c.browser.version.split(".")[0]<10){c.atmosphere.log(l.logLevel,["Receiving unexpected data from IE"])
}else{U(aF)
}}return aD
}function f(aB){clearTimeout(aB.id);
if(aB.timeout>0&&aB.transport!=="polling"){aB.id=setTimeout(function(){aw(aB);
y();
g()
},aB.timeout)
}}function aw(aB){al.closedByClientTimeout=true;
al.state="closedByClient";
al.responseBody="";
al.status=408;
al.messages=[];
ad()
}function P(aB,aC){g();
clearTimeout(l.id);
al.state="error";
al.reasonPhrase=aC;
al.responseBody="";
al.status=aB;
al.messages=[];
ad()
}function n(aF,aE,aB){aF=o(aE,aF);
if(aF.length===0){return true
}aB.responseBody=aF;
if(aE.trackMessageLength){aF=aB.partialMessage+aF;
var aD=[];
var aC=aF.indexOf(aE.messageDelimiter);
if(aC!=-1){while(aC!==-1){var aH=aF.substring(0,aC);
var aG=parseInt(aH,10);
if(isNaN(aG)){throw'message length "'+aH+'" is not a number'
}aC+=aE.messageDelimiter.length;
if(aC+aG>aF.length){aC=-1
}else{aD.push(aF.substring(aC,aC+aG));
aF=aF.substring(aC+aG,aF.length);
aC=aF.indexOf(aE.messageDelimiter)
}}aB.partialMessage=aF;
if(aD.length!==0){aB.responseBody=aD.join(aE.messageDelimiter);
aB.messages=aD;
return false
}else{aB.responseBody="";
aB.messages=[];
return true
}}}aB.responseBody=aF;
aB.messages=[aF];
return false
}function at(aB){c.atmosphere.log(l.logLevel,[aB]);
if(typeof(l.onTransportFailure)!=="undefined"){l.onTransportFailure(aB,l)
}else{if(typeof(c.atmosphere.onTransportFailure)!=="undefined"){c.atmosphere.onTransportFailure(aB,l)
}}l.transport=l.fallbackTransport;
var aC=l.connectTimeout===-1?0:l.connectTimeout;
if(l.reconnect&&l.transport!=="none"||l.transport==null){l.method=l.fallbackMethod;
al.transport=l.fallbackTransport;
l.fallbackTransport="none";
if(aC>0){l.reconnectId=setTimeout(function(){V()
},aC)
}else{V()
}}else{P(500,"Unable to reconnect with fallback transport")
}}function k(aD,aB){var aC=l;
if((aD!=null)&&(typeof(aD)!=="undefined")){aC=aD
}if(aB==null){aB=aC.url
}if(!aC.attachHeadersAsQueryString){return aB
}if(aB.indexOf("X-Atmosphere-Framework")!==-1){return aB
}aB+=(aB.indexOf("?")!==-1)?"&":"?";
aB+="X-Atmosphere-tracking-id="+aC.uuid;
aB+="&X-Atmosphere-Framework="+c.atmosphere.version;
aB+="&X-Atmosphere-Transport="+aC.transport;
if(aC.trackMessageLength){aB+="&X-Atmosphere-TrackMessageSize=true"
}if(aC.heartbeat!==null&&aC.heartbeat.server!==null){aB+="&X-Heartbeat-Server="+aC.heartbeat.server
}if(aC.contentType!==""){aB+="&Content-Type="+(aC.transport==="websocket"?aC.contentType:encodeURIComponent(aC.contentType))
}if(aC.enableProtocol){aB+="&X-atmo-protocol=true"
}c.each(aC.headers,function(aE,aG){var aF=c.isFunction(aG)?aG.call(this,aC,aD,al):aG;
if(aF!=null){aB+="&"+encodeURIComponent(aE)+"="+encodeURIComponent(aF)
}});
return aB
}function U(aB){if(!aB.isOpen){aB.isOpen=true;
R("opening",aB.transport,aB)
}else{if(aB.isReopen){aB.isReopen=false;
R("re-opening",aB.transport,aB)
}else{return
}}x(aB)
}function x(aC){if(aC.heartbeatTimer!=null){clearTimeout(aC.heartbeatTimer)
}if(!isNaN(F)&&F>0){var aB=function(){if(s("debug")){atmosphere.util.debug("Sending heartbeat")
}p(af);
aC.heartbeatTimer=setTimeout(aB,F)
};
aC.heartbeatTimer=setTimeout(aB,F)
}}function H(aE){var aC=l;
if((aE!=null)||(typeof(aE)!=="undefined")){aC=aE
}aC.lastIndex=0;
aC.readyState=0;
if((aC.transport==="jsonp")||((aC.enableXDR)&&(c.atmosphere.checkCORSSupport()))){av(aC);
return
}if(aC.transport==="ajax"){ax(aE);
return
}if(c.browser.msie&&+c.browser.version.split(".")[0]<10){if((aC.transport==="streaming")){if(aC.enableXDR&&window.XDomainRequest){L(aC)
}else{au(aC)
}return
}if((aC.enableXDR)&&(window.XDomainRequest)){L(aC);
return
}}var aF=function(){aC.lastIndex=0;
if(aC.reconnect&&ar++<aC.maxReconnectOnClose){al.ffTryingReconnect=true;
R("re-connecting",aE.transport,aE);
ah(aD,aC,aE.reconnectInterval)
}else{P(0,"maxReconnectOnClose reached")
}};
var aB=function(){al.errorHandled=true;
g();
aF()
};
if(aC.reconnect&&(aC.maxRequest===-1||aC.requestCount++<aC.maxRequest)){var aD=c.ajaxSettings.xhr();
aD.hasData=false;
I(aD,aC,true);
if(aC.suspend){v=aD
}if(aC.transport!=="polling"){al.transport=aC.transport;
aD.onabort=function(){Z(true)
};
aD.onerror=function(){al.error=true;
al.ffTryingReconnect=true;
try{al.status=XMLHttpRequest.status
}catch(aG){al.status=500
}if(!al.status){al.status=500
}if(!al.errorHandled){g();
aF()
}}
}aD.onreadystatechange=function(){if(aj){return
}al.error=null;
var aH=false;
var aN=false;
if(aC.transport==="streaming"&&aC.readyState>2&&aD.readyState===4){g();
aF();
return
}aC.readyState=aD.readyState;
if(aC.transport==="streaming"&&aD.readyState>=3){aN=true
}else{if(aC.transport==="long-polling"&&aD.readyState===4){aN=true
}}f(l);
if(aC.transport!=="polling"){var aG=200;
if(aD.readyState===4){aG=aD.status>1000?0:aD.status
}if(!aC.reconnectOnServerError&&(aG>=300&&aG<600)){P(aG,aD.statusText);
return
}if(aG>=300||aG===0){aB();
return
}if((!aC.enableProtocol||!aE.firstMessage)&&aD.readyState===2){if(c.browser.mozilla&&al.ffTryingReconnect){al.ffTryingReconnect=false;
setTimeout(function(){if(!al.ffTryingReconnect){U(aC)
}},500)
}else{U(aC)
}}}else{if(aD.readyState===4){aN=true
}}if(aN){var aK=aD.responseText;
if(c.trim(aK).length===0&&aC.transport==="long-polling"){if(!aD.hasData){ah(aD,aC,aC.pollingInterval)
}else{aD.hasData=false
}return
}aD.hasData=true;
C(aD,l);
if(aC.transport==="streaming"){if(!c.browser.opera){var aJ=aK.substring(aC.lastIndex,aK.length);
aH=n(aJ,aC,al);
aC.lastIndex=aK.length;
if(aH){return
}}else{c.atmosphere.iterate(function(){if(al.status!==500&&aD.responseText.length>aC.lastIndex){try{al.status=aD.status;
al.headers=a(aD.getAllResponseHeaders());
C(aD,l)
}catch(aP){al.status=404
}f(l);
al.state="messageReceived";
var aO=aD.responseText.substring(aC.lastIndex);
aC.lastIndex=aD.responseText.length;
aH=n(aO,aC,al);
if(!aH){ad()
}if(E(aD,aC)){G(aD,aC);
return
}}else{if(al.status>400){aC.lastIndex=aD.responseText.length;
return false
}}},0)
}}else{aH=n(aK,aC,al)
}var aM=E(aD,aC);
try{al.status=aD.status;
al.headers=a(aD.getAllResponseHeaders());
C(aD,aC)
}catch(aL){al.status=404
}if(aC.suspend){al.state=al.status===0?"closed":"messageReceived"
}else{al.state="messagePublished"
}var aI=!aM&&aE.transport!=="streaming"&&aE.transport!=="polling";
if(aI&&!aC.executeCallbackBeforeReconnect){ah(aD,aC,aC.pollingInterval)
}if(al.responseBody.length!==0&&!aH){ad()
}if(aI&&aC.executeCallbackBeforeReconnect){ah(aD,aC,aC.pollingInterval)
}if(aM){G(aD,aC)
}}};
aD.send(aC.data);
q=true
}else{if(aC.logLevel==="debug"){c.atmosphere.log(aC.logLevel,["Max re-connection reached."])
}P(0,"maxRequest reached")
}}function G(aC,aB){al.messages=[];
aB.isReopen=true;
D();
aj=false;
ah(aC,aB,500)
}function I(aD,aE,aC){var aB=aE.url;
if(aE.dispatchUrl!=null&&aE.method==="POST"){aB+=aE.dispatchUrl
}aB=k(aE,aB);
aB=c.atmosphere.prepareURL(aB);
if(aC){aD.open(aE.method,aB,true);
if(aE.connectTimeout>0){aE.id=setTimeout(function(){if(aE.requestCount===0){g();
h("Connect timeout","closed",200,aE.transport)
}},aE.connectTimeout)
}}if(l.withCredentials&&l.transport!=="websocket"){if("withCredentials" in aD){aD.withCredentials=true
}}if(!l.dropHeaders){aD.setRequestHeader("X-Atmosphere-Framework",c.atmosphere.version);
aD.setRequestHeader("X-Atmosphere-Transport",aE.transport);
if(aE.heartbeat!==null&&aE.heartbeat.server!==null){aD.setRequestHeader("X-Heartbeat-Server",aD.heartbeat.server)
}if(aE.trackMessageLength){aD.setRequestHeader("X-Atmosphere-TrackMessageSize","true")
}aD.setRequestHeader("X-Atmosphere-tracking-id",aE.uuid);
c.each(aE.headers,function(aF,aH){var aG=c.isFunction(aH)?aH.call(this,aD,aE,aC,al):aH;
if(aG!=null){aD.setRequestHeader(aF,aG)
}})
}if(aE.contentType!==""){aD.setRequestHeader("Content-Type",aE.contentType)
}}function ah(aC,aD,aE){if(al.closedByClientTimeout){return
}if(aD.reconnect||(aD.suspend&&q)){var aB=0;
if(aC.readyState>1){aB=aC.status>1000?0:aC.status
}al.status=aB===0?204:aB;
al.reason=aB===0?"Server resumed the connection or down.":"OK";
clearTimeout(aD.id);
if(aD.reconnectId){clearTimeout(aD.reconnectId);
delete aD.reconnectId
}if(aE>0){setTimeout(function(){l.reconnectId=H(aD)
},aE)
}else{H(aD)
}}}function m(aB){aB.state="re-connecting";
ag(aB)
}function L(aB){if(aB.transport!=="polling"){j=X(aB);
j.open()
}else{X(aB).open()
}}function X(aD){var aC=l;
if((aD!=null)&&(typeof(aD)!=="undefined")){aC=aD
}var aI=aC.transport;
var aH=0;
var aB=new window.XDomainRequest();
var aF=function(){if(aC.transport==="long-polling"&&(aC.reconnect&&(aC.maxRequest===-1||aC.requestCount++<aC.maxRequest))){aB.status=200;
R("re-connecting",aD.transport,aD);
L(aC)
}};
var aG=aC.rewriteURL||function(aK){var aJ=/(?:^|;\s*)(JSESSIONID|PHPSESSID)=([^;]*)/.exec(document.cookie);
switch(aJ&&aJ[1]){case"JSESSIONID":return aK.replace(/;jsessionid=[^\?]*|(\?)|$/,";jsessionid="+aJ[2]+"$1");
case"PHPSESSID":return aK.replace(/\?PHPSESSID=[^&]*&?|\?|$/,"?PHPSESSID="+aJ[2]+"&").replace(/&$/,"")
}return aK
};
aB.onprogress=function(){aE(aB)
};
aB.onerror=function(){if(aC.transport!=="polling"){g();
if(ar++<aC.maxReconnectOnClose){if(aC.reconnectInterval>0){aC.reconnectId=setTimeout(function(){R("re-connecting",aD.transport,aD);
L(aC)
},aC.reconnectInterval)
}else{R("re-connecting",aD.transport,aD);
L(aC)
}}else{P(0,"maxReconnectOnClose reached")
}}};
aB.onload=function(){};
var aE=function(aJ){clearTimeout(aC.id);
var aL=aJ.responseText;
aL=aL.substring(aH);
aH+=aL.length;
if(aI!=="polling"){f(aC);
var aK=n(aL,aC,al);
if(aI==="long-polling"&&c.trim(aL).length===0){return
}if(aC.executeCallbackBeforeReconnect){aF()
}if(!aK){h(al.responseBody,"messageReceived",200,aI)
}if(!aC.executeCallbackBeforeReconnect){aF()
}}};
return{open:function(){var aJ=aC.url;
if(aC.dispatchUrl!=null){aJ+=aC.dispatchUrl
}aJ=k(aC,aJ);
aB.open(aC.method,aG(aJ));
if(aC.method==="GET"){aB.send()
}else{aB.send(aC.data)
}if(aC.connectTimeout>0){aC.id=setTimeout(function(){if(aC.requestCount===0){g();
h("Connect timeout","closed",200,aC.transport)
}},aC.connectTimeout)
}},close:function(){aB.abort()
}}
}function au(aB){j=W(aB);
j.open()
}function W(aE){var aD=l;
if((aE!=null)&&(typeof(aE)!=="undefined")){aD=aE
}var aC;
var aF=new window.ActiveXObject("htmlfile");
aF.open();
aF.close();
var aB=aD.url;
if(aD.dispatchUrl!=null){aB+=aD.dispatchUrl
}if(aD.transport!=="polling"){al.transport=aD.transport
}return{open:function(){var aG=aF.createElement("iframe");
aB=k(aD);
if(aD.data!==""){aB+="&X-Atmosphere-Post-Body="+encodeURIComponent(aD.data)
}aB=c.atmosphere.prepareURL(aB);
aG.src=aB;
aF.body.appendChild(aG);
var aH=aG.contentDocument||aG.contentWindow.document;
aC=c.atmosphere.iterate(function(){try{if(!aH.firstChild){return
}if(aH.readyState==="complete"){try{c.noop(aH.fileSize)
}catch(aN){h("Connection Failure","error",500,aD.transport);
return false
}}var aK=aH.body?aH.body.lastChild:aH;
var aM=function(){var aP=aK.cloneNode(true);
aP.appendChild(aH.createTextNode("."));
var aO=aP.innerText;
aO=aO.substring(0,aO.length-1);
return aO
};
if(!c.nodeName(aK,"pre")){var aJ=aH.head||aH.getElementsByTagName("head")[0]||aH.documentElement||aH;
var aI=aH.createElement("script");
aI.text="document.write('<plaintext>')";
aJ.insertBefore(aI,aJ.firstChild);
aJ.removeChild(aI);
aK=aH.body.lastChild
}if(aD.closed){aD.isReopen=true
}aC=c.atmosphere.iterate(function(){var aP=aM();
if(aP.length>aD.lastIndex){f(l);
al.status=200;
al.error=null;
aK.innerText="";
var aO=n(aP,aD,al);
if(aO){return""
}h(al.responseBody,"messageReceived",200,aD.transport)
}aD.lastIndex=0;
if(aH.readyState==="complete"){Z(true);
R("re-connecting",aD.transport,aD);
if(aD.reconnectInterval>0){aD.reconnectId=setTimeout(function(){au(aD)
},aD.reconnectInterval)
}else{au(aD)
}return false
}},null);
return false
}catch(aL){al.error=true;
R("re-connecting",aD.transport,aD);
if(ar++<aD.maxReconnectOnClose){if(aD.reconnectInterval>0){aD.reconnectId=setTimeout(function(){au(aD)
},aD.reconnectInterval)
}else{au(aD)
}}else{P(0,"maxReconnectOnClose reached")
}aF.execCommand("Stop");
aF.close();
return false
}})
},close:function(){if(aC){aC()
}aF.execCommand("Stop");
Z(true)
}}
}function p(aB){if(aq!=null){A(aB)
}else{if(v!=null||ab!=null){K(aB)
}else{if(j!=null){e(aB)
}else{if(T!=null){w(aB)
}else{if(ap!=null){S(aB)
}else{P(0,"No suspended connection available");
c.atmosphere.error("No suspended connection available. Make sure atmosphere.subscribe has been called and request.onOpen invoked before invoking this method")
}}}}}}function A(aB){aq.send(aB)
}function ak(aC){if(aC.length===0){return
}try{if(aq){aq.localSend(aC)
}else{if(d){d.signal("localMessage",c.stringifyJSON({id:N,event:aC}))
}}}catch(aB){c.atmosphere.error(aB)
}}function K(aC){var aB=t(aC);
H(aB)
}function e(aC){if(l.enableXDR&&c.atmosphere.checkCORSSupport()){var aB=t(aC);
aB.reconnect=false;
av(aB)
}else{K(aC)
}}function w(aB){K(aB)
}function J(aB){var aC=aB;
if(typeof(aC)==="object"){aC=aB.data
}return aC
}function t(aC){var aD=J(aC);
var aB={connected:false,timeout:60000,method:"POST",url:l.url,contentType:l.contentType,headers:l.headers,reconnect:true,callback:null,data:aD,suspend:false,maxRequest:-1,logLevel:"info",requestCount:0,withCredentials:l.withCredentials,transport:"polling",isOpen:true,attachHeadersAsQueryString:true,enableXDR:l.enableXDR,uuid:l.uuid,dispatchUrl:l.dispatchUrl,enableProtocol:false,messageDelimiter:"|",trackMessageLength:l.trackMessageLength,maxReconnectOnClose:l.maxReconnectOnClose,heartbeatTimer:l.heartbeatTimer,heartbeat:l.heartbeat};
if(typeof(aC)==="object"){aB=c.extend(aB,aC)
}return aB
}function S(aB){var aE=c.atmosphere.isBinary(aB)?aB:J(aB);
var aC;
try{if(l.dispatchUrl!=null){aC=l.webSocketPathDelimiter+l.dispatchUrl+l.webSocketPathDelimiter+aE
}else{aC=aE
}if(!ap.canSendMessage){c.atmosphere.error("WebSocket not connected.");
return
}ap.send(aC)
}catch(aD){ap.onclose=function(aF){};
g();
at("Websocket failed. Downgrading to Comet and resending "+aB);
K(aB)
}}function B(aC){var aB=c.parseJSON(aC);
if(aB.id!==N){if(typeof(l.onLocalMessage)!=="undefined"){l.onLocalMessage(aB.event)
}else{if(typeof(c.atmosphere.onLocalMessage)!=="undefined"){c.atmosphere.onLocalMessage(aB.event)
}}}}function h(aE,aB,aC,aD){al.responseBody=aE;
al.transport=aD;
al.status=aC;
al.state=aB;
ad()
}function C(aB,aD){if(!aD.readResponsesHeaders){if(!aD.enableProtocol){aD.uuid=c.atmosphere.guid()
}}else{try{var aC=aB.getResponseHeader("X-Atmosphere-tracking-id");
if(aC&&aC!=null){aD.uuid=aC.split(" ").pop()
}}catch(aE){}}}function ag(aB){i(aB,l);
i(aB,c.atmosphere)
}function i(aC,aD){switch(aC.state){case"messageReceived":ar=0;
if(typeof(aD.onMessage)!=="undefined"){aD.onMessage(aC)
}break;
case"error":if(typeof(aD.onError)!=="undefined"){aD.onError(aC)
}break;
case"opening":delete l.closed;
if(typeof(aD.onOpen)!=="undefined"){aD.onOpen(aC)
}break;
case"messagePublished":if(typeof(aD.onMessagePublished)!=="undefined"){aD.onMessagePublished(aC)
}break;
case"re-connecting":if(typeof(aD.onReconnect)!=="undefined"){aD.onReconnect(l,aC)
}break;
case"closedByClient":if(typeof(aD.onClientTimeout)!=="undefined"){aD.onClientTimeout(l)
}break;
case"re-opening":delete l.closed;
if(typeof(aD.onReopen)!=="undefined"){aD.onReopen(l,aC)
}break;
case"fail-to-reconnect":if(typeof(aD.onFailureToReconnect)!=="undefined"){aD.onFailureToReconnect(l,aC)
}break;
case"unsubscribe":case"closed":var aB=typeof(l.closed)!=="undefined"?l.closed:false;
if(!aB){if(typeof(aD.onClose)!=="undefined"){aD.onClose(aC)
}}l.closed=true;
break
}}function Z(aB){if(al.state!=="closed"){al.state="closed";
al.responseBody="";
al.messages=[];
al.status=!aB?501:200;
ad()
}}function ad(){var aD=function(aG,aH){aH(al)
};
if(aq==null&&M!=null){M(al.responseBody)
}l.reconnect=l.mrequest;
var aB=typeof(al.responseBody)==="string";
var aE=(aB&&l.trackMessageLength)?(al.messages.length>0?al.messages:[""]):new Array(al.responseBody);
for(var aC=0;
aC<aE.length;
aC++){if(aE.length>1&&aE[aC].length===0){continue
}al.responseBody=(aB)?c.trim(aE[aC]):aE[aC];
if(aq==null&&M!=null){M(al.responseBody)
}if((al.responseBody.length===0||(aB&&af===al.responseBody))&&al.state==="messageReceived"){continue
}ag(al);
if(c.atmosphere.callbacks.length>0){if(s("debug")){c.atmosphere.debug("Invoking "+c.atmosphere.callbacks.length+" global callbacks: "+al.state)
}try{c.each(c.atmosphere.callbacks,aD)
}catch(aF){c.atmosphere.log(l.logLevel,["Callback exception"+aF])
}}if(typeof(l.callback)==="function"){if(s("debug")){c.atmosphere.debug("Invoking request callbacks")
}try{l.callback(al)
}catch(aF){c.atmosphere.log(l.logLevel,["Callback exception"+aF])
}}}}function E(aC,aB){if(al.partialMessage===""&&(aB.transport==="streaming")&&(aC.responseText.length>aB.maxStreamingLength)){return true
}return false
}function y(){if(l.enableProtocol&&!l.firstMessage){var aC="X-Atmosphere-Transport=close&X-Atmosphere-tracking-id="+l.uuid;
c.each(l.headers,function(aD,aF){var aE=c.isFunction(aF)?aF.call(this,l,l,al):aF;
if(aE!=null){aC+="&"+encodeURIComponent(aD)+"="+encodeURIComponent(aE)
}});
var aB=l.url.replace(/([?&])_=[^&]*/,aC);
aB=aB+(aB===l.url?(/\?/.test(l.url)?"&":"?")+aC:"");
if(l.connectTimeout>0){c.ajax({url:aB,async:l.closeAsync,timeout:l.connectTimeout,cache:false,crossDomain:l.enableXDR})
}else{c.ajax({url:aB,async:l.closeAsync,cache:false,crossDomain:l.enableXDR})
}}}function D(){if(l.reconnectId){clearTimeout(l.reconnectId);
delete l.reconnectId
}if(l.heartbeatTimer){clearTimeout(l.heartbeatTimer)
}l.reconnect=false;
aj=true;
al.request=l;
al.state="unsubscribe";
al.responseBody="";
al.status=408;
ad();
y();
g()
}function g(){al.partialMessage="";
if(l.id){clearTimeout(l.id)
}if(l.heartbeatTimer){clearTimeout(l.heartbeatTimer)
}if(j!=null){j.close();
j=null
}if(T!=null){T.abort();
T=null
}if(v!=null){v.abort();
v=null
}if(ap!=null){if(ap.canSendMessage){ap.close()
}ap=null
}if(ab!=null){ab.close();
ab=null
}ac()
}function ac(){if(d!=null){clearInterval(u);
document.cookie=aA+"=; expires=Thu, 01 Jan 1970 00:00:00 GMT; path=/";
d.signal("close",{reason:"",heir:!aj?N:(d.get("children")||[])[0]});
d.close()
}if(aq!=null){aq.close()
}}this.subscribe=function(aB){ai(aB);
V()
};
this.execute=function(){V()
};
this.invokeCallback=function(){ad()
};
this.close=function(){D()
};
this.disconnect=function(){y()
};
this.getUrl=function(){return l.url
};
this.push=function(aD,aC){if(aC!=null){var aB=l.dispatchUrl;
l.dispatchUrl=aC;
p(aD);
l.dispatchUrl=aB
}else{p(aD)
}};
this.getUUID=function(){return l.uuid
};
this.pushLocal=function(aB){ak(aB)
};
this.enableProtocol=function(aB){return l.enableProtocol
};
this.init=function(){ae()
};
this.request=l;
this.response=al
},subscribe:function(d,g,f){if(typeof(g)==="function"){c.atmosphere.addCallback(g)
}if(typeof(d)!=="string"){f=d
}else{f.url=d
}c.atmosphere.uuid=((typeof(f)!=="undefined")&&typeof(f.uuid)!=="undefined")?f.uuid:0;
var e=new c.atmosphere.AtmosphereRequest(f);
e.execute();
c.atmosphere.requests[c.atmosphere.requests.length]=e;
return e
},addCallback:function(d){if(c.inArray(d,c.atmosphere.callbacks)===-1){c.atmosphere.callbacks.push(d)
}},removeCallback:function(e){var d=c.inArray(e,c.atmosphere.callbacks);
if(d!==-1){c.atmosphere.callbacks.splice(d,1)
}},unsubscribe:function(){if(c.atmosphere.requests.length>0){var d=[].concat(c.atmosphere.requests);
for(var f=0;
f<d.length;
f++){var e=d[f];
e.close();
clearTimeout(e.response.request.id);
if(e.heartbeatTimer){clearTimeout(e.heartbeatTimer)
}}}c.atmosphere.requests=[];
c.atmosphere.callbacks=[]
},unsubscribeUrl:function(e){var d=-1;
if(c.atmosphere.requests.length>0){for(var g=0;
g<c.atmosphere.requests.length;
g++){var f=c.atmosphere.requests[g];
if(f.getUrl()===e){f.close();
clearTimeout(f.response.request.id);
if(f.heartbeatTimer){clearTimeout(f.heartbeatTimer)
}d=g;
break
}}}if(d>=0){c.atmosphere.requests.splice(d,1)
}},publish:function(e){if(typeof(e.callback)==="function"){c.atmosphere.addCallback(e.callback)
}e.transport="polling";
var d=new c.atmosphere.AtmosphereRequest(e);
c.atmosphere.requests[c.atmosphere.requests.length]=d;
return d
},checkCORSSupport:function(){if(c.browser.msie&&!window.XDomainRequest&&+c.browser.version.split(".")[0]<11){return true
}else{if(c.browser.opera&&+c.browser.version.split(".")[0]<12){return true
}else{if(c.trim(navigator.userAgent).slice(0,16)==="KreaTVWebKit/531"){return true
}else{if(c.trim(navigator.userAgent).slice(-7).toLowerCase()==="kreatel"){return true
}}}}var d=navigator.userAgent.toLowerCase();
var e=d.indexOf("android")>-1;
if(e){return true
}return false
},S4:function(){return(((1+Math.random())*65536)|0).toString(16).substring(1)
},guid:function(){return(c.atmosphere.S4()+c.atmosphere.S4()+"-"+c.atmosphere.S4()+"-"+c.atmosphere.S4()+"-"+c.atmosphere.S4()+"-"+c.atmosphere.S4()+c.atmosphere.S4()+c.atmosphere.S4())
},prepareURL:function(e){var f=c.now();
var d=e.replace(/([?&])_=[^&]*/,"$1_="+f);
return d+(d===e?(/\?/.test(e)?"&":"?")+"_="+f:"")
},param:function(d){return c.param(d,c.ajaxSettings.traditional)
},supportStorage:function(){var f=window.localStorage;
if(f){try{f.setItem("t","t");
f.removeItem("t");
return window.StorageEvent&&!c.browser.msie&&!(c.browser.mozilla&&c.browser.version.split(".")[0]==="1")
}catch(d){}}return false
},iterate:function(f,e){var g;
e=e||0;
(function d(){g=setTimeout(function(){if(f()===false){return
}d()
},e)
})();
return function(){clearTimeout(g)
}
},log:function(f,e){if(window.console){var d=window.console[f];
if(typeof d==="function"){d.apply(window.console,e)
}}},warn:function(){c.atmosphere.log("warn",arguments)
},info:function(){c.atmosphere.log("info",arguments)
},debug:function(){c.atmosphere.log("debug",arguments)
},error:function(){c.atmosphere.log("error",arguments)
},isBinary:function(d){return/^\[object\s(?:Blob|ArrayBuffer|.+Array)\]$/.test(Object.prototype.toString.call(d))
}};
(function(){var d,e;
c.uaMatch=function(g){g=g.toLowerCase();
var f=/(chrome)[ \/]([\w.]+)/.exec(g)||/(webkit)[ \/]([\w.]+)/.exec(g)||/(opera)(?:.*version|)[ \/]([\w.]+)/.exec(g)||/(msie) ([\w.]+)/.exec(g)||/(trident)(?:.*? rv:([\w.]+)|)/.exec(g)||g.indexOf("compatible")<0&&/(mozilla)(?:.*? rv:([\w.]+)|)/.exec(g)||[];
return{browser:f[1]||"",version:f[2]||"0"}
};
d=c.uaMatch(navigator.userAgent);
e={};
if(d.browser){e[d.browser]=true;
e.version=d.version
}if(e.chrome){e.webkit=true
}else{if(e.webkit){e.safari=true
}}if(e.trident){e.msie=true
}c.browser=e;
c.sub=function(){function f(i,j){return new f.fn.init(i,j)
}c.extend(true,f,this);
f.superclass=this;
f.fn=f.prototype=this();
f.fn.constructor=f;
f.sub=this.sub;
f.fn.init=function h(i,j){if(j&&j instanceof c&&!(j instanceof f)){j=f(j)
}return c.fn.init.call(this,i,j,g)
};
f.fn.init.prototype=f.fn;
var g=f(document);
return f
}
})();
(function(h){var j=/[\\\"\x00-\x1f\x7f-\x9f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,g={"\b":"\\b","\t":"\\t","\n":"\\n","\f":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};
function d(f){return'"'+f.replace(j,function(k){var l=g[k];
return typeof l==="string"?l:"\\u"+("0000"+k.charCodeAt(0).toString(16)).slice(-4)
})+'"'
}function e(f){return f<10?"0"+f:f
}function i(o,n){var m,l,f,k,q=n[o],p=typeof q;
if(q&&typeof q==="object"&&typeof q.toJSON==="function"){q=q.toJSON(o);
p=typeof q
}switch(p){case"string":return d(q);
case"number":return isFinite(q)?String(q):"null";
case"boolean":return String(q);
case"object":if(!q){return"null"
}switch(Object.prototype.toString.call(q)){case"[object Date]":return isFinite(q.valueOf())?'"'+q.getUTCFullYear()+"-"+e(q.getUTCMonth()+1)+"-"+e(q.getUTCDate())+"T"+e(q.getUTCHours())+":"+e(q.getUTCMinutes())+":"+e(q.getUTCSeconds())+'Z"':"null";
case"[object Array]":f=q.length;
k=[];
for(m=0;
m<f;
m++){k.push(i(m,q)||"null")
}return"["+k.join(",")+"]";
default:k=[];
for(m in q){if(Object.prototype.hasOwnProperty.call(q,m)){l=i(m,q);
if(l){k.push(d(m)+":"+l)
}}}return"{"+k.join(",")+"}"
}}}h.stringifyJSON=function(f){if(window.JSON&&window.JSON.stringify){return window.JSON.stringify(f)
}return i("",{"":f})
}
}(c))
}));