/**
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

package org.codehaus.stomp.headers;

class SendHeaders extends Headers {

	// The following headers are for mapping to JMS Brokers.
	// The header descriptions are from: http://activemq.apache.org/stomp.html
		
	/**
	 * Maps To: JMSCorrelationID 	 
	 * Good consumers will add this header to any responses they send
	 **/
	public static var CORRELATION_ID : String =  "correlation-id";
		 	
	/**
	 * JMSExpiration 	
	 * Expiration time of the message
	 **/
	public static var EXPIRES : String =  "expires";
		
	/**
	 * Maps To: JMSDeliveryMode 	
	 * Whether or not the message is persistent
	 */
	public static var PERSISTENT : String = "persistent";
		
	/**
	 * Maps To: JMSPriority 	
	 * Priority on the message
	 **/
	public static var PRIORITY : String =  "priority"; 	
		
	/**
	 * Maps To: JMSReplyTo 	
	 * Destination you should send replies to
	 **/
	public static var REPLY_TO : String = "reply-to";
		
	/** 
	 * Maps To: JMSType 	
	 * Type of the message
	 **/
	public static var TYPE : String = "type";
		
	/** 
	 * Maps To: JMSXGroupID 	
	 * Specifies the Message Groups
	 **/
	public static var JMSX_GROUP_ID : String = "JMSXGroupID";
		
	/**
	 * Maps To: JMSXGroupSeq 	
	 * Optional header that specifies the sequence number in the Message Groups
	 **/
	public static var JMSX_GROUP_SEQ  : String = "JMSXGroupSeq";
		
	/**
	 * Used to bind a message to a named transaction.
	 **/		
	public static var TRANSACTION : String = 'transaction';

	public var receipt(null, set_receipt) : String;
	public var correlationID(null, set_correlationID) : String;
	public var expires(null, set_expires) : String;
	public var persistent(null, set_persistent) : String;
	public var priority(null, set_priority) : String;
	public var replyTo(null, set_replyTo) : String;
	public var type(null, set_type) : String;
	public var jsmxGroupID(null, set_jsmxGroupID) : String;
	public var transaction(null, set_transaction) : String;
		
	public function set_receipt (id : String) : String {
		addHeader(SharedHeaders.RECEIPT, id);
		return id;
	}
		
	public function set_correlationID (id : String) : String {
		addHeader(CORRELATION_ID, id);
		return id;
	}
		
	public function set_expires (time : String) : String {
		addHeader(EXPIRES, time);
		return time;
	}
		
	public function set_persistent (isPersistent : String) : String {
		addHeader(PERSISTENT, isPersistent);
		return isPersistent;
	}		
		
	public function set_priority (priority : String) : String {
		addHeader(PRIORITY, priority);
		return priority;
	}
		
	public function set_replyTo (destination : String) : String {
		addHeader(REPLY_TO, destination);
		return destination;
	}
		
	public function set_type (type : String) : String {
		addHeader(TYPE, type);
		return type;
	}
		
	public function set_jsmxGroupID (id : String) : String {
		addHeader(JMSX_GROUP_ID, id);
		return id;
	}
		
	public function set_jsmxGroupSeq (number : String) : String {
		addHeader(JMSX_GROUP_SEQ, number);
		return number;
	}
		
	public function set_transaction (id : String) : String {
		addHeader(TRANSACTION, id);
		return id;
	}
}
