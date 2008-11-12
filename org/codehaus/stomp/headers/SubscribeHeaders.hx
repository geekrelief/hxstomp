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

package org.codehaus.stomp.headers;

class SubscribeHeaders extends Headers {
	
	public static var ACK : String = "ack";
	public static var ID : String = "id";
		
		
	// The following headers are extensions that are added by ActiveMQ.
	// The header descriptions are from: http://activemq.apache.org/stomp.html
		
	/**
	 * Specifies a JMS Selector using SQL 92 syntax as specified in the JMS 1.1 specificiation. 
	 * This allows a filter to be applied to each message as part of the subscription.
	 **/
	public static var AMQ_SELECTOR : String = "selector";
		
	/**
	 * Should messages be dispatched synchronously or asynchronously from the producer thread for non-durable 
	 * topics in the broker? For fast consumers set this to false. For slow consumers set it to true so that 
	 * dispatching will not block fast consumers.
	 **/	
	public static var AMQ_DISPATCH_ASYNC : String = "activemq.dispatchAsync";
		
	/**
	 * I would like to be an Exclusive Consumer on the queue.
	 **/		
	public static var AMQ_EXCLUSIVE : String = "activemq.exclusive";
		
	/**
	 * For Slow Consumer Handling on non-durable topics by dropping old messages - we can set a maximum-pending 
	 * limit, such that once a slow consumer backs up to this high water mark we begin to discard old messages.
	 **/		
	public static var AMQ_MAXIMUM_PENDING_MESSAGE_LIMIT : String = "activemq.maximumPendingMessageLimit";
		
	/**
	 * Specifies whether or not locally sent messages should be ignored for subscriptions. Set to true to 
	 * filter out locally sent messages.
	 **/		
	public static var AMQ_NO_LOCAL : String = "activemq.noLocal";
		
	/**
	 * Specifies the maximum number of pending messages that will be dispatched to the client. Once this maximum 
	 * is reached no more messages are dispatched until the client acknowledges a message. Set to 1 for very 
	 * fair distribution of messages across consumers where processing messages can be slow.
	 **/		
	public static var AMQ_PREFETCH_SIZE : String = "activemq.prefetchSize";
		
	/**
	 * Sets the priority of the consumer so that dispatching can be weighted in priority order.
	 **/		
	public static var AMQ_PRIORITY : String = "activemq.priority";
		
	/**
	 * For non-durable topics make this subscription retroactive.
	 **/		
	public static var AMQ_RETROACTIVE : String = "activemq.retroactive";
		
	/**
	 * For durable topic subscriptions you must specify the same clientId on the connection and 
	 * subcriptionName on the subscribe. Note the spelling: subcriptionName NOT subscriptionName. 
	 * This is not intuitive, but it is how it is implemented for now.
	 **/		
	public static var AMQ_SUBSCRIPTION_NAME : String = "activemq.subcriptionName";

	public var receipt(null, set_receipt) : String;
	public var ack(null, set_ack) : String;
	public var id(null, set_id) : String;
	public var amqSelector(null, set_amqSelector) : String;
	public var amqDisptchAsync(null, set_amqDispatchAsync) : String;
	public var amqExclusive(null, set_amqExclusive) : String;
	public var amqMaximumPendingMessageLimit(null, set_amqMaximumPendingMessageLimit) : String;
	public var amqNoLocal(null, set_amqNoLocal) : String;
	public var amqPrefetchSize(null, set_amqPrefetchSize) : String;
	public var amqPriority(null, set_amqPriority) : String;
	public var amqRetroactive(null, set_amqRetroactive) : String;
	public var amqSubscriptionName(null, set_amqSubscriptionName) : String;
		
	public function set_receipt (id : String) : String {
		addHeader(SharedHeaders.RECEIPT, id);
		return id;
	}
				
	public function set_ack (mode : String) : String {
		addHeader(ACK, mode);
		return mode;
	}
		
	public function set_id (id : String) : String {
		addHeader(ID, id);
		return id;
	}
		
	public function set_amqSelector (sql : String) : String {
		addHeader(AMQ_SELECTOR, sql);
		return sql;
	}
		
	public function set_amqDispatchAsync (isAsync : String) : String {
		addHeader(AMQ_DISPATCH_ASYNC, isAsync);
		return isAsync;
	}
		
	public function set_amqExclusive (isExclusive : String) : String {
		addHeader(AMQ_EXCLUSIVE, isExclusive);
		return isExclusive;
	}
	
	public function set_amqMaximumPendingMessageLimit (limit : String) : String {
		addHeader(AMQ_MAXIMUM_PENDING_MESSAGE_LIMIT, limit);
		return limit;
	}
	
	public function set_amqNoLocal (ignoreLocal : String) : String {
		addHeader(AMQ_NO_LOCAL, ignoreLocal);
		return ignoreLocal;
	}
	
	public function set_amqPrefetchSize (size : String) : String {
		addHeader(AMQ_PREFETCH_SIZE, size);
		return size;
	}
	
	public function set_amqPriority (priority : String) : String {
		addHeader(AMQ_PRIORITY, priority);
		return priority;
	}
	
	public function set_amqRetroactive (isRetroactive : String) : String {
		addHeader(AMQ_RETROACTIVE, isRetroactive);
		return isRetroactive;
	}
	
	public function set_amqSubscriptionName (name : String) : String {
		addHeader(AMQ_SUBSCRIPTION_NAME, name);
		return name;
	}
}
