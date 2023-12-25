**************************************************
*-- Class:        heap 
*-- ParentClass:  custom
*-- BaseClass:    custom
*
*  Another in the family of relatively undocumented sample classes I've inflicted on others
*  Warning - there's no error handling in here, so be careful to check for null returns and
*  invalid pointers.  Unless you get frisky, or you're resource-tight, it should work well.
*
*	Please read the code and comments carefully.  I've tried not to assume much knowledge about
*	just how pointers work, or how memory allocation works, and have tried to explain some of the
*	basic concepts behing memory allocation in the Win32 environment, without having gone into
*	any real details on x86 memory management or the Win32 memory model.  If you want to explore
*	these things (and you should), start by reading Jeff Richter's _Advanced Windows_, especially
*	Chapters 4-6, which deal with the Win32 memory model and virtual memory -really- well.
*
*	Another good source iss Walter Oney's _Systems Programming for Windows 95_.  Be warned that 
*	both of these books are targeted at the C programmer;  to someone who has only worked with
*	languages like VFP or VB, it's tough going the first couple of dozen reads.
*
*	Online resources - http://www.x86.org is the Intel Secrets Homepage.  Lots of deep, dark
*	stuff about the x86 architecture.  Not for the faint of heart.  Lots of pointers to articles
*	from DDJ (Doctor Dobbs Journal, one of the oldest and best magazines on microcomputing.)
*
*   You also might want to take a look at the transcripts from my "Pointers on Pointers" chat
*   sessions, which are available in the WednesdayNightLectureSeries topic on the Fox Wiki,
*   http://fox.wikis.com - the Wiki is a great Web site;  it provides a vast store of information
*   on VFP and related topics, and is probably the best tool available now to develop topics in
*   a collaborative environment.  Well worth checking out - it's a very different mechanism for
*   ongoing discussion of a subject.  It's an on-line message base or chat;  I find
*   myself hitting it when I have a question to see if an answer already exists.  It's
*   much like using a FAQ, except that most things on the Wiki are editable...
*
*	Post-DevCon 2000 revisions:
*
*	After some bizarre errors at DevCon, I reworked some of the methods to
*	consistently return a NULL whenever a bad pointer/inactive pointer in the
*	iaAllocs member array was encountered.  I also implemented NumToLong
*	using RtlMoveMemory(), relying on a BITOR() to recast what would otherwise
*	be a value with the high-order bit set.  The result is it's faster, and
*  an anomaly reported with values between 0xFFFFFFF1-0xFFFFFFFF goes away,
*	at the expense of representing these as negative numbers.  Pointer math
*	still works.
*
*****
*	How HEAP works:
*
*	Overwhelming guilt hit early this morning;  maybe I should explain the 
*	concept of the Heap class	and give an example of how to use it, in 
*	conjunction with the add-on functions that follow in this proc library.
*
*	Windows allocates memory from several places;  it also provides a 
*	way to define your own small corner of the universe where you can 
*	allocate and deallocate blocks of memory for your own purposes.  These
*	public or private memory areas are referred to commonly as heaps.
*
*	VFP is great in most cases;  it provides flexible allocation and 
*	alteration of variables on the fly in a program.  You don't need to 
*	know much about how things are represented internally. This makes 
*	most programming tasks easy.  However, in exchange for VFP's flexibility 
*	in memory variable allocation, we give up several things, the most 
*	annoying of which are not knowing the exact location of a VFP 
*	variable in memory, and not knowing exactly how things are constructed 
*	inside a variable, both of which make it hard to define new kinds of 
*	memory structures within VFP to manipulate as a C-style structure.
*
*	Enter Heap.  Heap creates a growable, private heap, from which you 
*	can allocate blocks of memory that have a known location and size 
*	in your memory address space.  It also provides a way of transferring
*	data to and from these allocated blocks.  You build structures in VFP 
*	strings, and parse the content of what is returned in those blocks by 
*	extracting substrings from VFP strings.
*
*	Heap does its work using a number of Win32 API functions;  HeapCreate(), 
*	which sets up a private heap and assigns it a handle, is invoked in 
*	the Init method.  This sets up the 'heap', where block allocations
*	for the object will be constructed.  I set up the heap to use a base 
*	allocation size of twice the size of a swap file 'page' in the x86 
*	world (8K), and made the heap able to grow;  it adds 8K chunks of memory
*	to itself as it grows.  There's no fixed limit (other than available 
*	-virtual- memory) on the size of the heap constructed;  just realize 
*	that huge allocations are likely to bump heads with VFP's own desire
*	for mondo RAM.
*
*	Once the Heap is established, we can allocate blocks of any size we 
*	want in Heap, outside of VFP's memory, but within the virtual 
*	address space owned by VFP.  Blocks are allocated by HeapAlloc(), and a
*	pointer to the block is returned as an integer.  
*
*	KEEP THE POINTER RETURNED BY ANY Alloc method, it's the key to 
*	doing things with the block in the future.  In addition to being a
*	valid pinter, it's the key to finding allocations tracked in iaAllocs[]
*
*	Periodically, we need to load things into the block we've created.  
*	Thanks to work done by Christof Lange, George Tasker and others, 
*	we found a Win32API call that will do transfers between memory 
*	locations, called RtlMoveMemory().  RtlMoveMemory() acts like the 
*	Win32API MoveMemory() call;  it takes two pointers (destination 
*	and source) and a length.  In order to make life easy, at times 
*	we DECLARE the pointers as INTEGER (we pass a number, which is 
*	treated as a DWORD (32 bit unsigned integer) whose content is the
*	address to use), and at other times as STRING @, which passes the 
*	physical address of a VFP string variable's contents, allowing 
*	RtlMoveMemory() to read and write VFP strings without knowing how 
*	to manipulate VFP's internal variable structures.  RtlMoveMemory() 
*	is used by both the CopyFrom and CopyTo methods, and the enhanced
*	Alloc methods.
*
*	At some point, we're finished with a block of memory.  We can free up 
*	that memory via HeapFree(), which releases a previously-allocated 
*	block on the heap.  It does not compact or rearrange the heap allocations
*	but simply makes the memory allocated no longer valid, and the 
*	address could be reused by another Alloc operation.  We track the 
*	active state of allocations in a member array iaAllocs[] which has 
*	3 members per row;  the pointer, which is used as a key, the actual 
*	size of the allocation (sometimes HeapAlloc() gives you a larger block 
*	than requested;  we can see it here.  This is the property returned 
*	by the SizeOfBlock method) and whether or not it's active and available.
*
*	When we're done with a Heap, we need to release the allocations and 
*	the heap itself.  HeapDestroy() releases the entire heap back to the 
*	Windows memory pool.  This is invoked in the Destroy method of the 
*	class to ensure that it gets explcitly released, since it remains alive 
*	until it is explicitly released or the owning process is released.  I 
*	put this in the Destroy method to ensure that the heap went away when 
*	the Heap object went out of scope.
*
*	The original class methods are:
*
*		Init					Creates the heap for use
*		Alloc(nSize)		Allocates a block of nSize bytes, returns an nPtr 
*								to it.  nPtr is NULL if fail
*		DeAlloc(nPtr)		Releases the block whose base address is nPtr.  
*								Returns .T./.F.
*		CopyTo(nPtr,cSrc)	Copies the Content of cSrc to the buffer at nPtr, 
*								up to the smaller of LEN(cSrc) or the length of 
*								the block (we look in the iaAllocs[] array).  
*								Returns .T./.F.
*		CopyFrom(nPtr)		Copies the content of the block at nPtr (size is 
*								from iaAllocs[]) and returns it as a VFP string.  
*								Returns a string, or NULL if fail
*		SizeOfBlock(nPtr)	Returns the actual allocated size of the block 
*								pointed to by nPtr.  Returns NULL if fail 
*		Destroy()			DeAllocs anything still active, and then frees 
*								the heap.
*****
*  New methods added 2/12/99 EMR -	Attack of the Creeping Feature Creature, 
*												part I
*
*	There are too many times when you know what you want to put in 
*	a buffer when you allocate it, so why not pass what you want in 
*	the buffer when you allocate it?  And we may as well add an option to
*	init the memory to a known value easily, too:
*
*		AllocBLOB(cSrc)	Allocate a block of SizeOf(cSrc) bytes and 
*								copy cSrc content to it
*		AllocString(cSrc)	Allocate a block of SizeOf(cSrc) + 1 bytes and 
*								copy cSrc content to it, adding a null (CHR(0)) 
*								to the end to make it a standard C-style string
*		AllocInitAs(nSize,nVal)
*								Allocate a block of nSize bytes, preinitialized 
*								with CHR(nVal).  If no nVal is passed, or nVal 
*								is illegal (not a number 0-255), init with nulls
*
*****
*	Property changes 9/29/2000
*
*	iaAllocs[] is now protected
*
*****
*	Method modifications 9/29/2000:
*
*	All lookups in iaAllocs[] are now done using the new FindAllocID()
*	method, which returns a NULL for the ID if not found active in the
*	iaAllocs[] entries.  Result is less code and more consistent error
*	handling, based on checking ISNULL() for pointers.
*
*****
*	The ancillary goodies in the procedure library are there to make life 
*	easier for people working with structures; they are not optimal 
*	and infinitely complete, but they do the things that are commonly 
*	needed when dealing with stuff in structures.  The functions are of 
*	two types;  converters, which convert standard C structures to an
*	equivalent VFP numeric, or make a string whose value is equivalent 
*	to a C data type from a number, so that you can embed integers, 
*	pointers, etc. in the strings used to assemble a structure which you 
*	load up with CopyTo, or pull out pointers and integers that come back 
*	embedded in a structure you've grabbed with CopyFrom.
*
*	The second type of functions provided are memory copiers.  The 
*	CopyFrom and CopyTo methods are set up to work with our heap, 
*	and nPtrs must take on the values of block addresses grabbed 
*	from our heap.  There will be lots of times where you need to 
*	get the content of memory not necessarily on our heap, so 
*	SetMem, GetMem and GetMemString go to work for us here.  SetMem 
*	copies the content of a string into the absolute memory block
*	at nPtr, for the length of the string, using RtlMoveMemory(). 
*	BE AWARE THAT MISUSE CAN (and most likely will) RESULT IN 
*	0xC0000005 ERRORS, memory access violations, or similar OPERATING 
*	SYSTEM level errors that will smash VFP like an empty beer can in 
*	a trash compactor.
*
*	There are two functions to copy things from a known address back 
*	to the VFP world.  If you know the size of the block to grab, 
*	GetMem(nPtr,nSize) will copy nSize bytes from the address nPtr 
*	and return it as a VFP string.  See the caveat above.  
*	GetMemString(nPtr) uses a different API call, lstrcpyn(), to 
*	copy a null terminated string from the address specified by nPtr. 
*	You can hurt yourself with this one, too.
*
*	Functions in the procedure library not a part of the class:
*
*	GetMem(nPtr,nSize)	Copy nSize bytes at address nPtr into a VFP string
*	SetMem(nPtr,cSource)	Copy the string in cSource to the block beginning 
*								at nPtr
*	GetMemString(nPtr)	Get the null-terminated string (up to 512 bytes) 
*								from the address at nPtr
*
*	DWORDToNum(cString)	Convert the first 4 bytes of cString as a DWORD 
*								to a VFP numeric (0 to 2^32)
*	SHORTToNum(cString)	Convert the first 2 bytes of cString as a SHORT 
*								to a VFP numeric (-32768 to 32767)
*	WORDToNum(cString)	Convert the first 2 bytes of cString as a WORD 
*								to a VFP numeric  (0 to 65535)
*	NumToDWORD(nInteger)	Converts nInteger into a string equivalent to a 
*								C DWORD (4 byte unsigned)
*	NumToWORD(nInteger)	Converts nInteger into a string equivalent to a 
*								C WORD (2 byte unsigned)
*	NumToSHORT(nInteger)	Converts nInteger into a string equivalent to a 
*								C SHORT ( 2 byte signed)
*
******
*	New external functions added 2/13/99
*
*	I see a need to handle NetAPIBuffers, which are used to transfer 
*	structures for some of the Net family of API calls;  their memory 
*	isn't on a user-controlled heap, but is mapped into the current 
*	application address space in a special way.  I've added two 
*	functions to manage them, but you're responsible for releasing 
*	them yourself.  I could implement a class, but in many cases, a 
*	call to the API actually performs the allocation for you.  The 
*	two new calls are:
*
*	AllocNetAPIBuffer(nSize)	Allocates a NetAPIBuffer of at least 
*										nBytes, and returns a pointer
*										to it as an integer.  A NULL is returned 
*										if allocation fails.
*	DeAllocNetAPIBuffer(nPtr)	Frees the NetAPIBuffer allocated at the 
*										address specified by nPtr.  It returns 
*										.T./.F. for success and failure
*
*	These functions are only available under NT, and will return 
*	NULL or .F. under Win9x
*
*****
*	Function changes 9/29/2000
*
*	NumToDWORD(tnNum)		Redirected to NumToLONG()
*	NumToLONG(tnNum)		Generates a 32 bit LONG from the VFP number, recast
*								using BITOR() as needed
*	LONGToNum(tcLong)		Extracts a signed VFP INTEGER from a 4 byte string
*
*****
*	That's it for the docs to date;  more stuff to come.  The code below 
*	is copyright Ed Rauh, 1999;  you may use it without royalties in 
*	your own code as you see fit, as long as the code is attributed to me.
*
*	This is provided as-is, with no implied warranty.  Be aware that you 
*	can hurt yourself with this code, most *	easily when using the 
*	SetMem(), GetMem() and GetMemString() functions.  I will continue to 
*	add features and functions to this periodically.  If you find a bug, 
*	please notify me.  It does no good to tell me that "It doesn't work 
*	the way I think it should..WAAAAH!"  I need to know exactly how things 
*	fail to work with the code I supplied.  A small code snippet that can 
*	be used to test the failure would be most helpful in trying
*	to track down miscues.  I'm not going to run through hundreds or 
*	thousands of lines of code to try to track down where exactly 
*	something broke.  
*
*	Please post questions regarding this code on Universal Thread;  I go out 
*	there regularly and will generally respond to questions posed in the
*	message base promptly (not the Chat).  http://www.universalthread.com
*	In addition to me, there are other API experts who frequent UT, and 
*	they may well be able to help, in many cases better than I could.  
*	Posting questions on UT helps not only with getting support
*	from the VFP community at large, it also makes the information about 
*	the problem and its solution available to others who might have the 
*	same or similar problems.
*
*	Other than by UT, especially if you have to send files to help 
*	diagnose the problem, send them to me at edrauh@earthlink.net or 
*	erauh@snet.net, preferably the earthlink.net account.
*
*	If you have questions about this code, you can ask.  If you have 
*	questions about using it with API calls and the like, you can ask.  
*	If you have enhancements that you'd like to see added to the code, 
*	you can ask, but you have the source, and ought to add them yourself.
*	Flames will be ignored.  I'll try to answer promptly, but realize 
*	that support and enhancements for this are done in my own spare time.  
*	If you need specific support that goes beyond what I feel is 
*	reasonable, I'll tell you.
*
*	Do not call me at home or work for support.  Period. 
*	<Mumble><something about ripping out internal organs><Grr>
*
*	Feel free to modify this code to fit your specific needs.  Since 
*	I'm not providing any warranty with this in any case, if you change 
*	it and it breaks, you own both pieces.
*
DEFINE CLASS heap AS custom


	PROTECTED inHandle, inNumAllocsActive,iaAllocs[1,3]
	inHandle = NULL
	inNumAllocsActive = 0
	iaAllocs = NULL
	Name = "heap"

	PROCEDURE Alloc
		*  Allocate a block, returning a pointer to it
		LPARAMETER nSize
		DECLARE INTEGER HeapAlloc IN WIN32API AS HAlloc;
			INTEGER hHeap, ;
			INTEGER dwFlags, ;
			INTEGER dwBytes
		DECLARE INTEGER HeapSize IN WIN32API AS HSize ;
			INTEGER hHeap, ;
			INTEGER dwFlags, ;
			INTEGER lpcMem
		LOCAL nPtr
		WITH this
			nPtr = HAlloc(.inHandle, 0, @nSize)
			IF nPtr # 0
				*  Bump the allocation array
				.inNumAllocsActive = .inNumAllocsActive + 1
				DIMENSION .iaAllocs[.inNumAllocsActive,3]
				*  Pointer
				.iaAllocs[.inNumAllocsActive,1] = nPtr
				*  Size actually allocated - get with HeapSize()
				.iaAllocs[.inNumAllocsActive,2] = HSize(.inHandle, 0, nPtr)
				*  It's alive...alive I tell you!
				.iaAllocs[.inNumAllocsActive,3] = .T.
			ELSE
				*  HeapAlloc() failed - return a NULL for the pointer
				nPtr = NULL
			ENDIF
		ENDWITH
		RETURN nPtr
	ENDPROC

*	new methods added 2/11-2/12;  pretty simple, actually, but they make 
*	coding using the heap object much cleaner.  In case it isn't clear, 
*	what I refer to as a BString is just the normal view of a VFP string 
*	variable;  it's any array of char with an explicit length, as opposed 
*	to the normal CString view of the world, which has an explicit
*	terminator (the null char at the end.)

	FUNCTION AllocBLOB
		*	Allocate a block of memory the size of the BString passed.  The 
		*	allocation will be at least LEN(cBStringToCopy) off the heap.
		LPARAMETER cBStringToCopy
		LOCAL nAllocPtr
		WITH this
			nAllocPtr = .Alloc(LEN(cBStringToCopy))
			IF ! ISNULL(nAllocPtr)
				.CopyTo(nAllocPtr,cBStringToCopy)
			ENDIF
		ENDWITH
		RETURN nAllocPtr
	ENDFUNC
	
	FUNCTION AllocString
		*	Allocate a block of memory to fill with a null-terminated string
		*	make a null-terminated string by appending CHR(0) to the end
		*	Note - I don't check if a null character precedes the end of the
		*	inbound string, so if there's an embedded null and whatever is
		*	using the block works with CStrings, it might bite you.
		LPARAMETER cString
		RETURN this.AllocBLOB(cString + CHR(0))
	ENDFUNC
	
	FUNCTION AllocInitAs
		*  Allocate a block of memory preinitialized to CHR(nByteValue)
		LPARAMETER nSizeOfBuffer, nByteValue
		IF TYPE('nByteValue') # 'N' OR ! BETWEEN(nByteValue,0,255)
			*	Default to initialize with nulls
			nByteValue = 0
		ENDIF
		RETURN this.AllocBLOB(REPLICATE(CHR(nByteValue),nSizeOfBuffer))
	ENDFUNC

*	This is the end of the new methods added 2/12/99

	PROCEDURE DeAlloc
		*  Discard a previous Allocated block
		LPARAMETER nPtr
		DECLARE INTEGER HeapFree IN WIN32API AS HFree ;
			INTEGER hHeap, ;
			INTEGER dwFlags, ;
			INTEGER lpMem
		LOCAL nCtr
		* Change to use .FindAllocID() and return !ISNULL() 9/29/2000 EMR
		nCtr = NULL
		WITH this
			nCtr = .FindAllocID(nPtr)
			IF ! ISNULL(nCtr)
				=HFree(.inHandle, 0, nPtr)
				.iaAllocs[nCtr,3] = .F.
			ENDIF
		ENDWITH
		RETURN ! ISNULL(nCtr)
	ENDPROC


	PROCEDURE CopyTo
		*  Copy a VFP string into a block
		LPARAMETER nPtr, cSource
		*  ReDECLARE RtlMoveMemory to make copy parameters easy
		DECLARE RtlMoveMemory IN WIN32API AS RtlCopy ;
			INTEGER nDestBuffer, ;
			STRING @pVoidSource, ;
			INTEGER nLength
		LOCAL nCtr
		nCtr = NULL
		* Change to use .FindAllocID() and return ! ISNULL() 9/29/2000 EMR
		IF TYPE('nPtr') = 'N' AND TYPE('cSource') $ 'CM' ;
		   AND ! (ISNULL(nPtr) OR ISNULL(cSource))
			WITH this
				*  Find the Allocation pointed to by nPtr
				nCtr = .FindAllocID(nPtr)
				IF ! ISNULL(nCtr)
					*  Copy the smaller of the buffer size or the source string
					=RtlCopy((.iaAllocs[nCtr,1]), ;
							cSource, ;
							MIN(LEN(cSource),.iaAllocs[nCtr,2]))
				ENDIF
			ENDWITH
		ENDIF
		RETURN ! ISNULL(nCtr)
	ENDPROC


	PROCEDURE CopyFrom
		*  Copy the content of a buffer back to the VFP world
		LPARAMETER nPtr
		*  Note that we reDECLARE RtlMoveMemory to make passing things easier
		DECLARE RtlMoveMemory IN WIN32API AS RtlCopy ;
			STRING @DestBuffer, ;
			INTEGER pVoidSource, ;
			INTEGER nLength
		LOCAL nCtr, uBuffer
		uBuffer = NULL
		nCtr = NULL
		* Change to use .FindAllocID() and return NULL 9/29/2000 EMR
		IF TYPE('nPtr') = 'N' AND ! ISNULL(nPtr)
			WITH this
				*  Find the allocation whose address is nPtr
				nCtr = .FindAllocID(nPtr)
				IF ! ISNULL(nCtr)
					* Allocate a buffer in VFP big enough to receive the block
					uBuffer = REPL(CHR(0),.iaAllocs[nCtr,2])
					=RtlCopy(@uBuffer, ;
							(.iaAllocs[nCtr,1]), ;
							(.iaAllocs[nCtr,2]))
				ENDIF
			ENDWITH
		ENDIF
		RETURN uBuffer
	ENDPROC
	
	PROTECTED FUNCTION FindAllocID
	 	*   Search for iaAllocs entry matching the pointer
	 	*   passed to the function.  If found, it returns the 
	 	*   element ID;  returns NULL if not found
	 	LPARAMETER nPtr
	 	LOCAL nCtr
	 	WITH this
			FOR nCtr = 1 TO .inNumAllocsActive
				IF .iaAllocs[nCtr,1] = nPtr AND .iaAllocs[nCtr,3]
					EXIT
				ENDIF
			ENDFOR
			RETURN IIF(nCtr <= .inNumAllocsActive,nCtr,NULL)
		ENDWITH
	ENDPROC

	PROCEDURE SizeOfBlock
		*  Retrieve the actual memory size of an allocated block
		LPARAMETERS nPtr
		LOCAL nCtr, nSizeOfBlock
		nSizeOfBlock = NULL
		* Change to use .FindAllocID() and return NULL 9/29/2000 EMR
		WITH this
			*  Find the allocation whose address is nPtr
			nCtr = .FindAllocID(nPtr)
			RETURN IIF(ISNULL(nCtr),NULL,.iaAllocs[nCtr,2])
		ENDWITH
	ENDPROC

	PROCEDURE Destroy
		DECLARE HeapDestroy IN WIN32API AS HDestroy ;
		  INTEGER hHeap

		LOCAL nCtr
		WITH this
			FOR nCtr = 1 TO .inNumAllocsActive
				IF .iaAllocs[nCtr,3]
					.Dealloc(.iaAllocs[nCtr,1])
				ENDIF
			ENDFOR
			HDestroy[.inHandle]
		ENDWITH
		DODEFAULT()
	ENDPROC


	PROCEDURE Init
		DECLARE INTEGER HeapCreate IN WIN32API AS HCreate ;
			INTEGER dwOptions, ;
			INTEGER dwInitialSize, ;
			INTEGER dwMaxSize
		#DEFINE SwapFilePageSize  4096
		#DEFINE BlockAllocSize    2 * SwapFilePageSize
		WITH this
			.inHandle = HCreate(0, BlockAllocSize, 0)
			DIMENSION .iaAllocs[1,3]
			.iaAllocs[1,1] = 0
			.iaAllocs[1,2] = 0
			.iaAllocs[1,3] = .F.
			.inNumAllocsActive = 0
		ENDWITH
		RETURN (this.inHandle # 0)
	ENDPROC


*
*  Additional functions for working with structures and pointers and stuff
*
	FUNCTION SetMem
	LPARAMETERS nPtr, cSource
	*  Copy cSource to the memory location specified by nPtr
	*  ReDECLARE RtlMoveMemory to make copy parameters easy
	*  nPtr is not validated against legal allocations on the heap
	DECLARE RtlMoveMemory IN WIN32API AS RtlCopy ;
		INTEGER nDestBuffer, ;
		STRING @pVoidSource, ;
		INTEGER nLength

	RtlCopy(nPtr, ;
			cSource, ;
			LEN(cSource))
	RETURN .T.

	FUNCTION GetMem
	LPARAMETERS nPtr, nLen
	*  Copy the content of a memory block at nPtr for nLen bytes back to a VFP string
	*  Note that we ReDECLARE RtlMoveMemory to make passing things easier
	*  nPtr is not validated against legal allocations on the heap
	DECLARE RtlMoveMemory IN WIN32API AS RtlCopy ;
		STRING @DestBuffer, ;
		INTEGER pVoidSource, ;
		INTEGER nLength
	LOCAL uBuffer
	* Allocate a buffer in VFP big enough to receive the block
	uBuffer = REPL(CHR(0),nLen)
	=RtlCopy(@uBuffer, ;
			 nPtr, ;
			 nLen)
	RETURN uBuffer

	FUNCTION GetMemString
	LPARAMETERS nPtr, nSize
	*  Copy the string at location nPtr into a VFP string
	*  We're going to use lstrcpyn rather than RtlMoveMemory to copy up to a terminating null
	*  nPtr is not validated against legal allocations on the heap
	*
	*	Change 9/29/2000 - second optional parameter nSize added to allow an override
	*	of the string length;  no major expense, but probably an open invitation
	*	to cliff-diving, since variant CStrings longer than 511 bytes, or less
	*	often, 254 bytes, will generally fall down go Boom!
	*
	DECLARE INTEGER lstrcpyn IN WIN32API AS StrCpyN ;
		STRING @ lpDestString, ;
		INTEGER lpSource, ;
		INTEGER nMaxLength
	LOCAL uBuffer
	IF TYPE('nSize') # 'N' OR ISNULL(nSize)
		nSize = 512
	ENDIF
	*  Allocate a buffer big enough to receive the data
	uBuffer = REPL(CHR(0), nSize)
	IF StrCpyN(@uBuffer, nPtr, nSize-1) # 0
		uBuffer = LEFT(uBuffer, MAX(0,AT(CHR(0),uBuffer) - 1))
	ELSE
		uBuffer = NULL
	ENDIF
	RETURN uBuffer

	FUNCTION SHORTToNum
		* Converts a 16 bit signed integer in a structure to a VFP Numeric
	 	LPARAMETER tcInt
		LOCAL b0,b1,nRetVal
		b0=asc(tcInt)
		b1=asc(subs(tcInt,2,1))
		if b1<128
			*
			*  positive - do a straight conversion
			*
			nRetVal=b1 * 256 + b0
		else
			*
			*  negative value - take twos complement and negate
			*
			b1=255-b1
			b0=256-b0
			nRetVal= -( (b1 * 256) + b0)
		endif
		return nRetVal

	FUNCTION NumToSHORT
	*
	*  Creates a C SHORT as a string from a number
	*
	*  Parameters:
	*
	*	tnNum			(R)  Number to convert
	*
		LPARAMETER tnNum
		*
		*  b0, b1, x hold small ints
		*
		LOCAL b0,b1,x
		IF tnNum>=0
			x=INT(tnNum)
			b1=INT(x/256)
			b0=MOD(x,256)
		ELSE
			x=INT(-tnNum)
			b1=255-INT(x/256)
			b0=256-MOD(x,256)
			IF b0=256
				b0=0
				b1=b1+1
			ENDIF
		ENDIF
		RETURN CHR(b0)+CHR(b1)

	FUNCTION DWORDToNum
		* Take a binary DWORD and convert it to a VFP Numeric
		* use this to extract an embedded pointer in a structure in a string to an nPtr
		LPARAMETER tcDWORD
		LOCAL b0,b1,b2,b3
		b0=asc(tcDWORD)
		b1=asc(subs(tcDWORD,2,1))
		b2=asc(subs(tcDWORD,3,1))
		b3=asc(subs(tcDWORD,4,1))
		RETURN ( ( (b3 * 256 + b2) * 256 + b1) * 256 + b0)

	FUNCTION NumToDWORD
		LPARAMETER tnNum
		RETURN This.NumToLong(tnNum)
	*			End redirection

	FUNCTION WORDToNum
		*	Take a binary WORD (16 bit USHORT) and convert it to a VFP Numeric
		LPARAMETER tcWORD
		RETURN (256 *  ASC(SUBST(tcWORD,2,1)) ) + ASC(tcWORD)

	FUNCTION NumToWORD
	*
	*  Creates a C USHORT (WORD) from a number
	*
	*  Parameters:
	*
	*	tnNum			(R)  Number to convert
	*
		LPARAMETER tnNum
		*
		*  x holds an int
		*
		LOCAL x
		x=INT(tnNum)
		RETURN CHR(MOD(x,256))+CHR(INT(x/256))
	
	FUNCTION NumToLong
	*
	*  Creates a C LONG (signed 32-bit) 4 byte string from a number
	*  NB:  this works faster than the original NumToDWORD(), which could have
	*	problems with trunaction of values > 2^31 under some versions of VFP with
	*	#DEFINEd or converted constant values in excess of 2^31-1 (0x7FFFFFFF).
	*	I've redirected NumToDWORD() and commented it out; NumToLong()
	*	expects to work with signed values and uses BITOR() to recast values
	*  in the range of -(2^31) to (2^31-1), 0xFFFFFFFF is not the same
	*  as -1 when represented in an N-type field.  If you don't need to
	*  use constants with the high-order bit set, or are willing to let
	*  the UDF cast the value consistently, especially using pointer math 
	*	on the system's part of the address space, this and its counterpart 
	*	LONGToNum() are the better choice for speed, or to save to an I-field.
	*
	*  To properly cast a constant/value with the high-order bit set, you
	*  can BITOR(nVal,0);  0xFFFFFFFF # -1 but BITOR(0xFFFFFFFF,0) = BITOR(-1,0)
	*  is true, and converts the N-type in the range 2^31 - (2^32-1) to a
	*  twos-complement negative integer value.  You can disable BITOR() casting
	*  in this function by commenting the proper line in this UDF();  this 
	*	results in a slight speed increase.
	*
	*  Parameters:
	*
	*  tnNum			(R)	Number to convert
	*
		LPARAMETER tnNum
		DECLARE RtlMoveMemory IN WIN32API AS RtlCopyLong ;
			STRING @pDestString, ;
			INTEGER @pVoidSource, ;
			INTEGER nLength
		LOCAL cString
		cString = SPACE(4)
	*	Function call not using BITOR()
	*	=RtlCopyLong(@cString, tnNum, 4)
	*  Function call using BITOR() to cast numerics
	   =RtlCopyLong(@cString, BITOR(tnNum,0), 4)
		RETURN cString
	
	FUNCTION LongToNum
	*
	*	Converts a 32 bit LONG to a VFP numeric;  it treats the result as a
	*	signed value, with a range -2^31 - (2^31-1).  This is faster than
	*	DWORDToNum().  There is no one-function call that causes negative
	*	values to recast as positive values from 2^31 - (2^32-1) that I've
	*	found that doesn't take a speed hit.
	*
	*  Parameters:
	*
	*  tcLong			(R)	4 byte string containing the LONG
	*
		LPARAMETER tcLong
		DECLARE RtlMoveMemory IN WIN32API AS RtlCopyLong ;
			INTEGER @ DestNum, ;
			STRING @ pVoidSource, ;
			INTEGER nLength
		LOCAL nNum
		nNum = 0
		=RtlCopyLong(@nNum, tcLong, 4)
		RETURN nNum
	
	FUNCTION AllocNetAPIBuffer
	*
	*	Allocates a NetAPIBuffer at least nBtes in Size, and returns a pointer
	*	to it as an integer.  A NULL is returned if allocation fails.
	*	The API call is not supported under Win9x
	*
	*	Parameters:
	*
	*		nSize			(R)	Number of bytes to allocate
	*
	LPARAMETER nSize
	IF TYPE('nSize') # 'N' OR nSize <= 0
		*	Invalid argument passed, so return a null
		RETURN NULL
	ENDIF
*** DH 2021-02-19: this is supported in modern OS
*	IF ! 'NT' $ OS()
*		*	API call only supported under NT, so return failure
*		RETURN NULL
*	ENDIF
	DECLARE INTEGER NetApiBufferAllocate IN NETAPI32.DLL ;
		INTEGER dwByteCount, ;
		INTEGER lpBuffer
	LOCAL  nBufferPointer
	nBufferPointer = 0
	IF NetApiBufferAllocate(INT(nSize), @nBufferPointer) # 0
		*  The call failed, so return a NULL value
		nBufferPointer = NULL
	ENDIF
	RETURN nBufferPointer

	FUNCTION DeAllocNetAPIBuffer
	*
	*	Frees the NetAPIBuffer allocated at the address specified by nPtr.
	*	The API call is not supported under Win9x
	*
	*	Parameters:
	*
	*		nPtr			(R) Address of buffer to free
	*
	*	Returns:			.T./.F.
	*
	LPARAMETER nPtr
	IF TYPE('nPtr') # 'N'
		*	Invalid argument passed, so return failure
		RETURN .F.
	ENDIF
*** DH 2021-02-19: this is supported in modern OS
*	IF ! 'NT' $ OS()
*		*	API call only supported under NT, so return failure
*		RETURN .F.
*	ENDIF
	DECLARE INTEGER NetApiBufferFree IN NETAPI32.DLL ;
		INTEGER lpBuffer
	RETURN (NetApiBufferFree(INT(nPtr)) = 0)

	Function CopyDoubleToString
	LPARAMETER nDoubleToCopy
	*  ReDECLARE RtlMoveMemory to make copy parameters easy
	DECLARE RtlMoveMemory IN WIN32API AS RtlCopyDbl ;
		STRING @DestString, ;
		DOUBLE @pVoidSource, ;
		INTEGER nLength
	LOCAL cString
	cString = SPACE(8)
	=RtlCopyDbl(@cString, nDoubleToCopy, 8)
	RETURN cString

	FUNCTION DoubleToNum
	LPARAMETER cDoubleInString
	DECLARE RtlMoveMemory IN WIN32API AS RtlCopyDbl ;
		DOUBLE @DestNumeric, ;
		STRING @pVoidSource, ;
		INTEGER nLength
	LOCAL nNum
	*	Christof Lange pointed out that there's a feature of VFP that results
	*	in the entry in the NTI retaining its precision after updating the value
	*	directly;  force the resulting precision to a large value before moving
	*	data into the temp variable
	nNum = 0.000000000000000000
	=RtlCopyDbl(@nNum, cDoubleInString, 8)
	RETURN nNum

ENDDEFINE
