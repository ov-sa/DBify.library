----------------------------------------------------------------
--[[ Resource: Mysql Library
     Script: exports: server.lua
     Server: -
     Author: Tron
     Developer: -
     Last Edit: 06/09/2019 (Tron)
     Desc: Server Sided Exports ]]--
----------------------------------------------------------------


--------------------------------------
--[[ Function: Retrieves Database ]]--
--------------------------------------

function getDatabase()

	return connectedDB
	
end


----------------------------------------------
--[[ Function: Verifies Table's Existence ]]--
----------------------------------------------

function doesTableExist(tableName)

    if not connectedDB or not tableName then return false end
	local query = connectedDB:query("SELECT table_name FROM information_schema.tables where table_schema='"..(connection.database).."'")
	if not query then return false end
	local result = query:poll(-1)
    if query then
		query:free()
    end
	if result and type(result) == "table" and #result > 0 then
       for i, j in ipairs(result) do
		   if tableName == j.TABLE_NAME then
		      return true
		   end
	   end
	   return false
	else
	   return false
	end
	
end


-----------------------------------------------
--[[ Function: Verifies Column's Existence ]]--
-----------------------------------------------

function doesColumnExist(tableName, columnName)

    if not connectedDB or not tableName or not columnName then return false end
	local isTable = doesTableExist(tableName)
	if not isTable then return false end
	local query = connectedDB:query("DESCRIBE "..tableName)
	if not query then return false end
	local result = query:poll(-1)
    if query then
		query:free()
    end
	if result and type(result) == "table" and #result > 0 then
	   for i, j in ipairs(result) do
		   if columnName == j.Field then 
		      return true
		   end
	   end
	   return false
	else
	   return false
	end
	
end


--------------------------------------
--[[ Function: Retrieves Row Data ]]--
--------------------------------------

function getRowData(tableName, key, keyColumnName, dataColumnName)

    if not connectedDB or not tableName or not key or not keyColumnName or not dataColumnName then return false end
	local isKeyColumn = doesColumnExist(tableName, keyColumnName)
	if not isKeyColumn then return false end
	local isDataColumn = doesColumnExist(tableName, dataColumnName)
	if not isDataColumn then return false end
	local query = connectedDB:query("SELECT "..dataColumnName.." FROM "..tableName.." WHERE "..keyColumnName.."='"..key.."'")
	if not query then return false end
	local result = query:poll(-1)
	if query 
		query:free()
    end
	if result and type(result) == "table" and #result > 0 then
	   local value = result[1]
       return value[dataColumnName];
	else
	   return false;
	end
	
end


---------------------------------
--[[ Function: Sets Row Data ]]--
---------------------------------

function setRowData(tableName, key, keyColumnName, dataColumnName, data)

    if not connectedDB or not tableName or not key or not keyColumnName or not dataColumnName or not data then return false end
	local isKeyColumn = doesColumnExist(tableName, keyColumnName)
	if not isKeyColumn then return false end
	local isDataColumn = doesColumnExist(tableName, dataColumnName)
	if not isDataColumn then
	   connectedDB:exec("ALTER TABLE "..tableName.." ADD COLUMN "..dataColumnName.." TEXT");
	   connectedDB:exec("UPDATE "..tableName.." SET "..dataColumnName.."='"..data.."' WHERE "..keyColumnName.."='"..key.."'")
	else
		connectedDB:exec("UPDATE "..tableName.." SET "..dataColumnName.."='"..data.."' WHERE "..keyColumnName.."='"..key.."'")
	end
	return true
	
end
