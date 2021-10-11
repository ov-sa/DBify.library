----------------------------------------------------------------
--[[ Resource: DBify Library
     Files: modules: vehicle.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Vehicle Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec
}


-------------------
--[[ Variables ]]--
-------------------

dbify["vehicle"] = {
    __connection__ = {
        table = "server_vehicles",
        keyColumn = "id"
    },

    fetchAll = function(callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        return dbify.mysql.table.fetchContents(dbify.vehicle.__connection__.table, callback, ...)
    end,

    add = function(callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not callback or (imports.type(callback) ~= "function") then return false end
        imports.dbQuery(function(queryHandler, arguments)
            local callbackReference = callback
            local _, _, vehicleID = imports.dbPoll(queryHandler, 0)
            local result = vehicleID or false
            if callbackReference and (imports.type(callbackReference) == "function") then
                callbackReference(result, arguments)
            end
        end, {{...}}, dbify.mysql.__connection__.instance, "INSERT INTO `??`", dbify.vehicle.__connection__.table)
        return true
    end,

    delete = function(vehicleID, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not vehicleID or (imports.type(vehicleID) ~= "number") then return false end
        return dbify.vehicle.getData(vehicleID, {dbify.vehicle.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if result then
                result = imports.dbExec(dbify.mysql.__connection__.instance, "DELETE FROM `??` WHERE `??`=?", dbify.vehicle.__connection__.table, dbify.vehicle.__connection__.keyColumn, vehicleID)
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

    setData = function(vehicleID, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not vehicleID or (imports.type(vehicleID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.set(dbify.vehicle.__connection__.table, dataColumns, {
            {dbify.vehicle.__connection__.keyColumn, vehicleID},
        }, callback, ...)
    end,

    getData = function(vehicleID, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not vehicleID or (imports.type(vehicleID) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.get(dbify.vehicle.__connection__.table, dataColumns, {
            {dbify.vehicle.__connection__.keyColumn, vehicleID},
        }, true, callback, ...)
    end
}