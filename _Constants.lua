local THIS_ADDON_NAME="CatRotationHelper";
local g_Module = getfenv(0)[THIS_ADDON_NAME];

function MakeConstTable(a_Table)
	local metaTable =
	{
		__index = function(a_Table, a_Key)
			error("Error: ConstTable: attempt to access nonexistent key " .. a_Key, 2);
		end,
		
		__newindex = function(a_Table, a_Key, a_NewValue)
			error("Error: ConstTable: attempt to modify key " .. a_Key, 2);
		end,
	}
	
	setmetatable(a_Table, metaTable);
	return a_Table;
end

g_Module.Constants = MakeConstTable
{
	GCD_LENGTH			= 1.6,
};
