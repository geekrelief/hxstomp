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

class UnsubscribeHeaders extends Headers
{
	public static var DESTINATION : String = "destination";
	public static var ID : String = "id";

	public var receipt(null, set_receipt) : String;
	public var desitination(null, set_destination) : String;
	public var id(null, set_id) : String;
		
	public function set_receipt (id : String) : String
	{
		addHeader(SharedHeaders.RECEIPT, id);
		return id;
	}
		
	public function set_destination (destination : String) : String
	{
		addHeader(DESTINATION, destination);
		return destination;
	}
		
	public function set_id (id : String) : String
	{
		addHeader(ID, id);
		return id;
	}
}
