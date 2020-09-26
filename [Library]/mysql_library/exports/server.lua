----------------------------------------------------------------
--[[ Resource: Mysql Library
     Script: exports: server.lua
     Server: -
     Author: OvileAmriam
     Developer: -
     DOC: 06/09/2019 (OvileAmriam)
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

    local query = connectedDB:query("SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=?", connection.database) 
    if not query then return false end
    local result = query:poll(-1)
    if query then
        query:free()
    end
    if result and type(result) == "table" and #result > 0 then
        for i, j in ipairs(result) do
            if tableName == j[string.lower("TABLE_NAME")] or tableName == j[string.upper("TABLE_NAME")] then
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
    local query = connectedDB:query("DESCRIBE `??`", tableName)
    if not query then return false end
    local result = query:poll(-1)
    if query then
        query:free()
    end
    if result and type(result) == "table" and #result > 0 then
        for i, j in ipairs(result) do
            if string.lower(columnName) == string.lower(j.Field) then 
                return true
            end
        end
        return false
    else
        return false
    end
    
end


----------------------------------------
--[[ Function: Retrieves Row's Data ]]--
----------------------------------------

function getRowData(tableName, key, keyColumnName, dataColumnName)

    if not connectedDB or not tableName or not key or not keyColumnName or not dataColumnName then return false end

    local isKeyColumn = doesColumnExist(tableName, keyColumnName)
    if not isKeyColumn then return false end
    local isDataColumn = doesColumnExist(tableName, dataColumnName)
    if not isDataColumn then return false end
    local query = connectedDB:query("SELECT `??` FROM `??` WHERE `??`=?", dataColumnName, tableName, keyColumnName, key)
    if not query then return false end
    local result = query:poll(-1)
    if query then
        query:free()
    end
    if result and type(result) == "table" and #result > 0 then
        return result[1][dataColumnName]
    else
        return false
    end
    
end


-----------------------------------
--[[ Function: Sets Row's Data ]]--
-----------------------------------

function setRowData(tableName, key, keyColumnName, dataColumnName, data)

    if not connectedDB or not tableName or not key or not keyColumnName or not dataColumnName then return false end

    local isKeyColumn = doesColumnExist(tableName, keyColumnName)
    if not isKeyColumn then return false end
    local isDataColumn = doesColumnExist(tableName, dataColumnName)
    if not isDataColumn then
        connectedDB:exec("ALTER TABLE `??` ADD COLUMN `??` TEXT", tableName, dataColumnName)
    end
    connectedDB:exec("UPDATE `??` SET `??`=? WHERE `??`=?", tableName, dataColumnName, data, keyColumnName, key)
    return true

end
