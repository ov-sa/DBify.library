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
    pairs = pairs,
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

    create = function(callback, ...)
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
            else
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(false, arguments)
                end
            end
        end, ...)
    end,

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
    end,

    item = {
        __utilities__ = {
            pushnpop = function(inventoryID, items, processType, callback, ...)
                if not dbify.mysql.__connection__.instance then return false end
                if not inventoryID or (imports.type(inventoryID) ~= "number") or not items or (imports.type(items) ~= "table") or (#items <= 0) or not processType or (imports.type(processType) ~= "string") or ((processType ~= "push") and (processType ~= "pop")) then return false end
                return dbify.inventory.fetchAll({
                    {dbify.inventory.__connection__.keyColumn, inventoryID},
                }, function(result, arguments)
                    if result then
                        result = result[1]
                        for i, j in imports.ipairs(arguments[1].items) do
                            j[1] = "item_"..imports.tostring(j[1])
                            j[2] = imports.math.max(0, imports.tonumber(j[2]) or 0)
                            local prevItemData = result[(j[1])]
                            prevItemData = (prevItemData and imports.fromJSON(prevItemData)) or false
                            prevItemData = (prevItemData and prevItemData.data and (imports.type(prevItemData.data) == "table") and prevItemData.item and (imports.type(prevItemData.item) == "table") and prevItemData) or false
                            if prevItemData then
                                prevItemData.item.amount = j[2] + (imports.math.max(0, imports.tonumber(prevItemData.item.amount) or 0)*((arguments[1].processType == "push" and 1) or -1))
                                arguments[1].items[i][2] = prevItemData
                            else
                                arguments[1].items[i][2] = {
                                    data = {},
                                    item = {
                                        amount = j[2]
                                    }
                                }
                            end
                            arguments[1].items[i][2] = imports.toJSON(j[2])
                        end
                        dbify.inventory.setData(arguments[1].inventoryID, arguments[1].items, function(result, arguments)
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
                    items = items,
                    processType = processType
                }, {...})
            end
        },
    
        add = function(inventoryID, items, callback, ...)
            return dbify.inventory.item__utilities__.pushnpop(inventoryID, items, "push", callback, ...)
        end,

        remove = function(inventoryID, items, callback, ...)
            return dbify.inventory.item__utilities__.pushnpop(inventoryID, items, "pop", callback, ...)
        end,

        setData = function(inventoryID, items, dataColumns, callback, ...)
            if not dbify.mysql.__connection__.instance then return false end
            if not inventoryID or (imports.type(inventoryID) ~= "number") or not items or (imports.type(items) ~= "table") or (#items <= 0) or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
            for i, j in imports.ipairs(items) do
                items[i] = "item_"..imports.tostring(j)
            end
            return dbify.inventory.getData(inventoryID, items, function(result, arguments)
                local callbackReference = callback
                if result then
                    local dataColumns = {}
                    for i, j in imports.pairs(result) do
                        j = (j and imports.fromJSON(j)) or false
                        j = (j and j.data and (imports.type(j.data) == "table") and j.item and (imports.type(j.item) == "table") and j) or false
                        if not j then
                            j = {
                                data = {},
                                item = {
                                    amount = 0
                                }
                            }
                        end
                        for k, v in imports.ipairs(arguments[1].dataColumns) do
                            j.data[imports.tostring(v[1])] = v[2]
                        end
                        imports.table.insert(dataColumns, {i, imports.toJSON(j)})
                    end
                    return dbify.inventory.setData(arguments[1].inventoryID, dataColumns, function(result, arguments)
                        local callbackReference = callback
                        if callbackReference and (imports.type(callbackReference) == "function") then
                            callbackReference(result, arguments)
                        end
                    end, arguments[2])
                else
                    if callbackReference and (imports.type(callbackReference) == "function") then
                        callbackReference(false, arguments[2])
                    end
                end
            end, {
                inventoryID = inventoryID,
                dataColumns = dataColumns
            }, {...})
        end
    }
}


----------------------------------
--[[ Event: On Resource-Start ]]--
----------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    if not dbify.mysql.__connection__.instance then return false end
    imports.dbExec(dbify.mysql.__connection__.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` INT AUTO_INCREMENT PRIMARY KEY)", dbify.inventory.__connection__.table, dbify.inventory.__connection__.keyColumn)

end)