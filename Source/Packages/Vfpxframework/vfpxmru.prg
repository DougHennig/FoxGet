* This class provides an MRU list of items saved in the Windows Registry.

define class VFPXMRU as Custom
	dimension aMRUList[1, 2]
		&& a list of MRU objects
	cRegistryKey = ''
		&& the Registry key where the items are saved
	cItemName    = 'MRUItem'
		&& the value name in the Registry
	nMaxItems    = 10
		&& the number of items in the MRU list

* Load the MRU list from the Registry into our array.

	function LoadMRUs
		local loRegistry, ;
			lnItems, ;
			lnI, ;
			lcValue, ;
			lnPos, ;
			lcLastUsed, ;
			lcItem
		loRegistry = newobject('VFPXRegistry', 'VFPXRegistry.vcx')
		lnItems    = 0
		for lnI = 1 to This.nMaxItems
			lcValue = loRegistry.GetKey(This.cRegistryKey, This.cItemName + transform(lnI))
			if not empty(lcValue)
				lnPos      = at('|', lcValue)
				lcLastUsed = left(lcValue, lnPos - 1)
				lcItem     = substr(lcValue, lnPos + 1)
				if This.IsItemValid(lcItem)
					lnItems = lnItems + 1
					dimension This.aMRUList[lnItems, 2]
					This.aMRUList[lnItems, 1] = lcItem
					This.aMRUList[lnItems, 2] = lcLastUsed
				endif This.IsItemValid(lcItem)
			endif not empty(lcValue)
		next lnI
		asort(This.aMRUList, 2, -1, 1)
	endfunc

* See if the item is valid. Returns .T. in this class but a subclass can check
* for validity (e.g. see VFPXMRUFile).

	function IsItemValid(tcItem)
		return .T.
	endfunc

* Add or update the timestamp for an item in the list.

	function Add(tcItem)
		local lnRow, ;
			lnRows, ;
			loRegistry, ;
			lnI

* If the array is empty, put the item in the first row.

		if empty(This.aMRUList[1])
			This.aMRUList[1, 1] = tcItem
			lnRow = 1
		else

* See if the item exists. If not, add it to the array.

			lnRow = ascan(This.aMRUList, tcItem, -1, -1, 1, 15)
			if lnRow = 0
				lnRow = alen(This.aMRUList, 1) + 1
				dimension This.aMRUList[lnRow, 2]
				This.aMRUList[lnRow, 1] = tcItem
			endif lnRow = 0
		endif empty(This.aMRUList[1])

* Update the timestamp and sort by last used.

		This.aMRUList[lnRow, 2] = ttoc(datetime(), 1)
		asort(This.aMRUList, 2, -1, 1)

* Only keep This.nMaxItems in the array.

		lnRows = alen(This.aMRUList, 1)
		if lnRows > This.nMaxItems
			dimension This.aMRUList[This.nMaxItems, 2]
			lnRows = This.nMaxItems
		endif lnRows > This.nMaxItems

* Save the items to the Registry.

		loRegistry = newobject('VFPXRegistry', 'VFPXRegistry.vcx')
		for lnI = 1 to lnRows
			loRegistry.SetKey(This.cRegistryKey, This.cItemName + transform(lnI), ;
				This.aMRUList[lnI, 2] + '|' + This.aMRUList[lnI, 1])
		next lnI
	endfunc

* Fill an array with the items.

	function GetItems(taItems)
		local lnRows
		lnRows = alen(This.aMRUList, 1)
		dimension taItems[lnRows, 2]
		acopy(This.aMRUList, taItems)
		return lnRows
	endfunc
enddefine

* A subclass of VFPXMRU for files.

define class VFPXMRUFile as VFPXMRU
	function IsItemValid(tcItem)
		local llReturn
		llReturn = file(tcItem)
		return llReturn
	endfunc
enddefine
