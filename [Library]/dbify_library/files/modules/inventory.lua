----------------------------------------------------------------
--[[ Resource: DBify Library
     Files: modules: inventory.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Inventory Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    ipairs = ipairs,
    tonumber = tonumber,
    tostring = tostring,
    toJSON = toJSON,
    fromJSON = fromJSON,
    addEventHandler = addEventHandler,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    table = {
        insert = table.insert
    },
    math = {
        max = math.max
    }
}


-------------------
--[[ Variables ]]--
-------------------

dbify["inventory"] = {
    __connection__ = {
        table = "server_inventories",
        keyColumn = "id"
    },

    fetchAll = function(keyColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        return dbify.mysql.table.fetchContents(dbify.inventory.__connection__.table, keyColumns, callback, ...)
    end,

    add = function(callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not callback or (imports.type(callback) ~= "function") then return false end
        imports.dbQuery(function(queryHandler, arguments)
            local callbackReference = callback
            local _, _, inventoryID = imports.dbPoll(queryHandler, 0)
            local result = inventoryID or false
            if callbackReference and (imports.type(callbackReference) == "function") then
                callbackReference(result, arguments)
            end
        end, {{...}}, dbify.mysql.__connection__.instance, "INSERT INTO `??` (`??`) VALUES(NULL)", dbify.inventory.__connection__.table, dbify.inventory.__connection__.keyColumn)
        return true
    end,

    delete = function(inventoryID, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not inventoryID or (imports.type(inventoryID) ~= "number") then return false end
        return dbify.inventory.getData(inventoryID, {dbify.inventory.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if result then
                result = imports.dbExec(dbify.mysql.__connection__.instance, "DELETE FROM `??` WHERE `??`=?", dbify.inventory.__connection__.table, dbify.inventory.__connection__.keyColumn, inventoryID)
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(result, arguments)
                end
                return true
            end
            if callbackReference and (imports.type(callbackReference) == "function") then
                callbackReference(false, arguments)
            end
        end, ...)
    end,

    item = {
        add = function(inventoryID, items, callback, ...)
            if not dbify.mysql.__connection__.instance then return false end
            if not inventoryID or (imports.type(inventoryID) ~= "number") or not items or (imports.type(items) ~= "table") or (#items <= 0) then return false end
            return dbify.inventory.fetchAll({
                {dbify.inventory.__connection__.keyColumn, inventoryID},
            }, function(result, arguments)
                if result then
                    result = result[1]
                    for i, j in imports.ipairs(arguments[1].items) do
                        j[1] = imports.tostring(j[1])
                        j[2] = imports.math.max(0, imports.tonumber(j[2]) or 0)
                        local prevItemData = result[(j[1])]
                        prevItemData = (prevItemData and imports.fromJSON(prevItemData)) or false
                        if prevItemData then
                            prevItemData.amount = j[2] + imports.math.max(0, imports.tonumber(prevItemData.amount) or 0)
                            arguments[1].items[i][2] = prevItemData
                        else
                            arguments[1].items[i][2] = {
                                amount = j[2]
                            }
                        end
                        arguments[1].items[i][2] = imports.toJSON(j[2])
                    end
                    dbify.mysql.data.set(dbify.inventory.__connection__.table, arguments[1].items, {
                        {dbify.inventory.__connection__.keyColumn, arguments[1].inventoryID}
                    }, function(result, arguments)
                        local callbackReference = callback
                        if callbackReference and (imports.type(callbackReference) == "function") then
                            callbackReference(result, arguments)
                        end
                    end, arguments[2])
                else
                    local callbackReference = callback
                    if callbackReference and (imports.type(callbackReference) == "function") then
                        callbackReference(false, arguments[2])
                    end
                end
            end, {
                inventoryID = inventoryID,
                items = items
            }, {...})
        end
    },

    setData = function(inventoryID, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not inventoryID or (imports.type(inventoryID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.set(dbify.inventory.__connection__.table, dataColumns, {
            {dbify.inventory.__connection__.keyColumn, inventoryID}
        }, callback, ...)
    end,

    getData = function(inventoryID, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not inventoryID or (imports.type(inventoryID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.get(dbify.inventory.__connection__.table, dataColumns, {
            {dbify.inventory.__connection__.keyColumn, inventoryID}
        }, true, callback, ...)
    end
}


----------------------------------
--[[ Event: On Resource-Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    if not dbify.mysql.__connection__.instance then return false end
    imports.dbExec(dbify.mysql.__connection__.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` INT AUTO_INCREMENT PRIMARY KEY)", dbify.inventory.__connection__.table, dbify.inventory.__connection__.keyColumn)

end)