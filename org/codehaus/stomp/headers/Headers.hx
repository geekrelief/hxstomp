package org.codehaus.stomp.headers;

class Headers
{
		
	var headers : Hash<Dynamic>;

	public function new() {
		headers = new Hash<Dynamic>();
	}
		
	public function addHeader (header : String, value : Dynamic) : Void
	{
		headers.set(header, value);
	}
	
	public function getHeaders () : Hash<Dynamic>
	{
		return headers;
	}
}
