/**
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
 /*
 	Version 0.1 : R Jewson (rjewson at gmail dot com).  First release, only for reciept of messages.
 	Version 0.4 : Derek Wischusen (dwischus at flexonrails dot net).  
 */

package org.codehaus.stomp;
	
import flash.events.EventDispatcher;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.net.Socket;
import flash.utils.ByteArray;
import flash.utils.Timer;
	
import org.codehaus.stomp.event.ConnectedEvent;
import org.codehaus.stomp.event.MessageEvent;
import org.codehaus.stomp.event.ReceiptEvent;
import org.codehaus.stomp.event.STOMPErrorEvent;

import org.codehaus.stomp.frame.ErrorFrame;
import org.codehaus.stomp.frame.MessageFrame;

import org.codehaus.stomp.headers.AckHeaders;
import org.codehaus.stomp.headers.AbortHeaders;
import org.codehaus.stomp.headers.BeginHeaders;
import org.codehaus.stomp.headers.CommitHeaders;
import org.codehaus.stomp.headers.ConnectHeaders;
import org.codehaus.stomp.headers.SendHeaders;
import org.codehaus.stomp.headers.SubscribeHeaders;
import org.codehaus.stomp.headers.UnsubscribeHeaders;
import org.rxr.utils.ByteArrayReader;
	

/*
[Event(name="connected", type="org.codehaus.stomp.event.ConnectedEvent")]

[Event(name="message", type="org.codehaus.stomp.event.MessageEvent")]

[Event(name="receipt", type="org.codehaus.stomp.event.ReceiptEvent")]

[Event(name="fault", type="org.codehaus.stomp.event.STOMPErrorEvent")]

*/

class Stomp extends EventDispatcher {
  
	private inline static var NEWLINE : String = "\n";
	private inline static var BODY_START : String = "\n\n";
	private inline static var NULL_BYTE : Int = 0x00;
	
   	private var socket : Socket;
 		
	private var server : String;
	private var port : Int;
	private var connectHeaders : ConnectHeaders;			
  	private var socketConnected : Bool;
	private var protocolPending : Bool;
	private var protocolConnected : Bool;
	private var expectDisconnect : Bool;
	private var connectTimer : Timer;
	private var subscriptions : Array<Dynamic>;
	
	public var errorMessages : Array<Dynamic>;
	public var sessionID : String;
	public var connectTime : Date;
	public var disconnectTime : Date;
	public var autoReconnect : Bool;
			
  	public function new() 
  	{
		super();
		socket = new Socket();
		socketConnected = false;
		protocolPending = false;
		protocolConnected = false;
		expectDisconnect = false;
		subscriptions = new Array<Dynamic>();

		errorMessages = new Array<Dynamic>();
		autoReconnect = true;

		socket.addEventListener( Event.CONNECT, onConnect );
  		socket.addEventListener( Event.CLOSE, onClose );
   		socket.addEventListener( ProgressEvent.SOCKET_DATA, onData );
		socket.addEventListener( IOErrorEvent.IO_ERROR, onError );
	}
	
	public function connect( ?server : String, ?port : Int, ?connectHeaders : ConnectHeaders) : Void 
	{
		if( server == null ) {
			server = "localhost";
		}
		if( port == null ) {
			port = 61613;
		}
		
		this.server = server;
		this.port = port;
		this.connectHeaders = connectHeaders;
		doConnect();
	}

	public function exit() : Void 
	{
		expectDisconnect = true;
		socket.close();
	}
		
	private function doConnect() : Void 
	{
		if (socketConnected==true)
			return;
		socket.connect( server, port );
		socketConnected = false;
		protocolConnected = false;
		protocolPending = true;
		expectDisconnect = false;
	}

   	private function onConnect( event:Event ) : Void 
   	{
		//trace("connected");
		if (connectTimer != null && connectTimer.running) connectTimer.stop();
		
		var h : Hash<Dynamic> = connectHeaders != null ? connectHeaders.getHeaders() : new Hash<Dynamic>();
		transmit("CONNECT", h);
		socketConnected = true;
   	}
	
	private function onClose( event:Event ) : Void 
	{
		//trace("closed");
		socketConnected = false;
		protocolConnected = false;
		protocolPending = false;
		disconnectTime = Date.now();

		if (!expectDisconnect && autoReconnect) 
		{
			connectTimer = new Timer(2000, 5);
			connectTimer.addEventListener(TimerEvent.TIMER, doConnectTimer);
			connectTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			connectTimer.start();
		}
	}

	private function doConnectTimer( event:TimerEvent ):Void 
	{
		doConnect();
	}
	
	private function onTimerComplete( event:TimerEvent ):Void
	{
		//trace("timer completed");
		if (!socket.connected) throw "Unable to reconnect to socket";
	} 
	

	private function onError( event:Event ) : Void 
	{
		trace("error occured " + event);
		var now:Date = Date.now();
		if (!socket.connected) {
			socketConnected = false;
			protocolConnected = false;
			protocolPending = false;
			disconnectTime = now;
		}
		errorMessages.push(now + " " + event.type);
	}
	
	public function subscribe (destination : String, ?headers : SubscribeHeaders) : Void 
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : null;
			
		if (socketConnected)
		{
			if (h == null){ h = new Hash<Dynamic>(); }
			
			h.set('destination', destination);
			transmit("SUBSCRIBE", h);
		}
		
		var s: Dynamic = { destination: destination, headers: headers, connected: socketConnected };
		s.connected = socketConnected;
		subscriptions.push(s);
	}

	
	public function send (destination : String, message : Dynamic, ?headers : SendHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
		h.set('destination', destination);
		
		var messageBytes : ByteArray = new ByteArray();					
		if(Std.is(message, ByteArray)) {
			messageBytes.writeBytes(message, 0, message.length);
		} else if(Std.is(message, String)) {
			messageBytes.writeUTFBytes(message);
		} else if(Std.is(message, Int)) {
			messageBytes.writeInt(message);
		} else if(Std.is(message, Float)) {
			messageBytes.writeDouble(message);
		} else if(Std.is(message, Bool)) {
			messageBytes.writeBoolean(message);
		} else if(Std.is(message, Array)) {
			messageBytes.writeObject(cast(message, Array<Dynamic>));
		} else if(Reflect.isObject(message)) {
			messageBytes.writeObject(message);
		}

		h.set('content-length', messageBytes.length);

		transmit("SEND", h,  messageBytes);
	}

	// use this to guarantee you get floats on the receiving end
	public function sendFloat (destination : String, message : Float, ?headers : SendHeaders) {
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
		h.set('destination', destination);
		
		var messageBytes : ByteArray = new ByteArray();					
		messageBytes.writeDouble(message);

		h.set('content-length', messageBytes.length);
		transmit("SEND", h,  messageBytes);
	}

	public function sendTextMessage(destination : String, message : String, ?headers : SendHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
		h.set('destination', destination);
		
		var messageBytes : ByteArray = new ByteArray();
		messageBytes.writeUTFBytes(message);
		
		h.set('content-length', messageBytes.length);
		transmit("SEND", h,  messageBytes);
	}
	
	public function begin (transaction : String, ?headers : BeginHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
			
		h.set('transaction', transaction);
		transmit("BEGIN", h);
	}

	public function commit (transaction : String, ?headers : CommitHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
			
		h.set('transaction', transaction);
		transmit("COMMIT", h);
	}
	
	public function ack (messageID : String, ?headers : AckHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
			
		h.set('message-id', messageID);
		transmit("ACK", h);
	}
	
	public function abort (transaction : String, ?headers : AbortHeaders) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
			
		h.set('transaction', transaction);
		transmit("ABORT", h);
	}		
	
	public function unsubscribe (destination : String, ?headers : UnsubscribeHeaders ) : Void
	{
		var h : Hash<Dynamic> = headers != null ? headers.getHeaders() : new Hash<Dynamic>();
			
		h.set('destination', destination);
		transmit("UNSUBSCRIBE", h);
	}
	
	public function disconnect () : Void
	{
		transmit("DISCONNECT", new Hash<Dynamic>());
	}	
	
	private function transmit (command : String, headers : Hash<Dynamic>, ?body : ByteArray) : Void
	{
		var transmission : ByteArray = new ByteArray();
		transmission.writeUTFBytes(command);

		for (header in headers.keys())
			transmission.writeUTFBytes( NEWLINE + header + ":" + headers.get(header));	       
        
        transmission.writeUTFBytes( BODY_START );
		if (body != null){ transmission.writeBytes( body, 0, body.length ); }
        transmission.writeByte( NULL_BYTE );
        
        socket.writeBytes( transmission, 0, transmission.length );
        socket.flush();
	
	}
	
	private function processSubscriptions() : Void 
	{
		for (sub in subscriptions)
		{
			if (sub.connected == false){
				this.subscribe(sub.destination, sub.headers);
			}
		}
	}

	private var frameReader : FrameReader;
	
    private function onData(event : ProgressEvent):Void {
		if (frameReader == null)
			frameReader = new FrameReader(new ByteArrayReader(socket));
		else if(!frameReader.isComplete)
			frameReader.readBytes(socket);
		
		if (frameReader.isComplete) {
			dispatchFrame(frameReader.command, frameReader.headers, frameReader.body);
			frameReader = null;
		}
				
	}


	private function dispatchFrame(command: String, headers: Hash<Dynamic>, body: ByteArray): Void
	{
		switch (command) 
		{				
			case "CONNECTED":
				protocolConnected = true;
				protocolPending = false;
				expectDisconnect = false;
				connectTime = Date.now();
				sessionID = headers.get('session');
				processSubscriptions();
				dispatchEvent(new ConnectedEvent(ConnectedEvent.CONNECTED));				
			
			case "MESSAGE":
				var messageEvent : MessageEvent = new MessageEvent(MessageEvent.MESSAGE);
				messageEvent.message = new MessageFrame(body, headers);
				dispatchEvent(messageEvent);
			
			case "RECEIPT":
				var receiptEvent : ReceiptEvent = new ReceiptEvent(ReceiptEvent.RECEIPT);
				receiptEvent.receiptID = headers.get('receipt-id');
				dispatchEvent(receiptEvent);
			
			case "ERROR":
				var errorEvent : STOMPErrorEvent = new STOMPErrorEvent(STOMPErrorEvent.ERROR);
				errorEvent.error = new ErrorFrame(body, headers);
				dispatchEvent(errorEvent);					
			
			default:
				throw "UNKNOWN STOMP FRAME";
		}			
	}
}



import org.rxr.utils.ByteArrayReader;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import org.codehaus.stomp.Stomp;
	
private class FrameReader {
	
	private var reader : ByteArrayReader;
	private var frameComplete: Bool;
	private var contentLength: Int;
	
	public var command : String;
	public var headers : Hash<Dynamic>;
	public var body : ByteArray;

	public var isComplete(get_isComplete, null) : Bool;
	
	public function get_isComplete(): Bool
	{
		return frameComplete;
	}
	
	public function readBytes(data: IDataInput): Void
	{
		data.readBytes(reader, reader.length, data.bytesAvailable);
		processBytes();
	}
	
	private function processBytes(): Void {
		if (command == null && reader.scan(0x0A) != -1)
			processCommand();
		
		if (command != null && headers == null && reader.indexOfString("\n\n") != -1)
			processHeaders();
		
		if (command != null && headers != null && bodyComplete())
			processBody();
		
		if (command != null && headers != null && body != null)
			frameComplete = true;
	}

	private function processCommand(): Void
	{
		command = reader.readLine();
	}
	
	private function processHeaders(): Void
	{
		headers = new Hash<Dynamic>();
					
		var headerString : String = reader.readUntilString("\n\n");
		var headerValuePairs : Array<String> = headerString.split("\n");
		
		for (pair in headerValuePairs) {
			var separator : Int = pair.indexOf(":");
			headers.set(pair.substr(0, separator), pair.substr(separator+1));
		}
		
		if(headers.get("content-length") != null)
			contentLength = Std.int(headers.get("content-length"));
		
		reader.forward();		
	}
	
	private function processBody(): Void
	{
	 	body = reader.readFor(contentLength);	
	}
	
	private function bodyComplete() : Bool
	{
		if(contentLength != -1) {
			if(contentLength > reader.bytesAvailable)
				return false;
		}
		else {
			var nullByteIndex: Int = reader.scanBack(0x00);
			if(nullByteIndex != -1)
				contentLength = nullByteIndex;	
			else
				return false;
		}

		return true;
	}
	
	public function new(reader: ByteArrayReader): Void
	{
		frameComplete = false;
		contentLength = -1;

		this.reader = reader;
		processBytes();
	}
}
	
