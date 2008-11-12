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

class ConnectHeaders extends Headers
{
	/**
	 * Specifies the JMS Client ID which is used in combination with the activemq.subcriptionName 
	 * to denote a durable subscriber.
	 **/
	public static var CLIENT_ID : String = "client-id";
	public static var LOGIN : String = "login";
	public static var PASSCODE : String = "passcode";

	public var clientID(null, set_clientID) : String;
	public var login(null, set_login) : String;
	public var passcode(null, set_passcode) : String;	
	
	public function set_clientID (id : String) : String {
		addHeader(CLIENT_ID, id);
		return id;
	}
	
	public function set_login(username: String) : String {
		addHeader(LOGIN, username);
		return username;
	}
	
	public function set_passcode(password: String) : String {
		addHeader(PASSCODE, password);
		return password;
	}
	
}
