package org.rxr.utils;

import flash.utils.ByteArray;
import flash.utils.IDataInput;

class ByteArrayReader extends ByteArray
{
	
	public function readLine(): String
	{
		return readUntilChar("\n");
	}

	public function readUntilChar(char: String): String
	{
		var ba: ByteArray = readUntilByte(char.charCodeAt(0));
		ba.position = 0;
		return ba.readUTFBytes(ba.length);			
	}

	public function readUntilString(string: String): String
	{
		var ba: ByteArray = readUntilBytes(stringToBytes(string));
		ba.position = 0;
		return ba.readUTFBytes(ba.length);			
	}
	
	public function readUntilByte(byte: Int): ByteArray
	{
		var bytes:ByteArray;
		var byteIndex: Int = scan(byte);
		if( byteIndex != -1 )
		{
			bytes = new ByteArray();
			readBytes(bytes, 0, byteIndex);
			position++;				
		}

		return bytes;
	}

	public function readUntilBytes(bytes: ByteArray): ByteArray
	{
		var ba:ByteArray;
		var byteIndex: Int = indexOf(bytes);
		if(byteIndex != -1)
		{
			ba = new ByteArray();
			readBytes(ba, 0, byteIndex);
			position++;				
		}

		return ba;
	}
	
	public function readFor(length: UInt): ByteArray
	{
		var bytes:ByteArray = new ByteArray();
		readBytes(bytes, 0, length);
		return bytes;
	}
	
	
	public function splitByte(byte: Int) : Array<ByteArray>
	{
		var items: Array<ByteArray> = [];
		var byteIndex: Int = scan( byte );
		while( byteIndex != -1 ) {
			items.push( readFor( byteIndex ) );
			position++;
			byteIndex = scan( byte );
		}
		   
		if (bytesAvailable > 0) items.push(readFor(bytesAvailable));
		
		return items;		
	}
	
	
	public function scan(byte: Int, ?offset: Int): Int
	{
		if( offset == null) { offset = 0; }
		var index: Int = -1;
		for (i in offset...length){
			if (peek(i) == byte){
				index = i; 
				break;
			}
		}
		
		return index;
	}


	public function scanBack(byte: Int, ?offset: Int): Int
	{
		if( offset == null ) { offset = 0; }

		var index: Int = -1;
		var i:Int = length - offset;
		while (i > position) {
			if (peek(i) == byte){
				index = i; 
				break;
			}
			--i;
		}
		
		return index - position;
	}

	public function peek(offset: Int): Int
	{
		return this[position + offset];
	}
	
	public function forward(): Void
	{
		position++;
	}
	
	public function forwardBy(num: UInt): Void
	{
		position+=num;
	}
	
	public function indexOf(bytes: ByteArray): Int
	{
		var index: Int = -1;
		var firstByte: Int = bytes[0];
		var len : Int = bytes.length;		
		
		var start: Int = scan(firstByte); 
		
		while( start != -1 && (start + len) < bytesAvailable ) {
		    	
			if (matchBytes(start, bytes)) {
				index = start;
				break;
			}	

		    start = scan(firstByte, start+1);
		}
		
		return index;
	}

	private function matchBytes(start:Int, bytes: ByteArray): Bool {
		var len : Int = bytes.length;		
		var match: Bool = true;				
		var halfLen: Int = Std.int(len/2 + 1);
		for (i in 1...halfLen) {
			if(bytes[i] != peek(start + i) ||  bytes[len - i] != peek((start + len) - i)){
				match = false;
				break;
			}							
		}	
		return match;
	}
	
	public function indexOfString(string: String): Int
	{
		return indexOf(stringToBytes(string));
	}
	
	public function stringToBytes(string: String) : ByteArray
	{
		var bytes: ByteArray = new ByteArray();
		bytes.writeUTFBytes(string);
		return bytes;
	}
	
	public function new(?source: IDataInput)
	{
		super();
		if (source != null){ source.readBytes(this, 0, source.bytesAvailable); position=0;}
	}
	
}

