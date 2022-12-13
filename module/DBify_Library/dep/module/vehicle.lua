-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tonumber = tonumber,
    addEventHandler = addEventHandler,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    table = table,
    assetify = assetify
}


-------------------------
--[[ Module: Vehicle ]]--
-------------------------

dbify.vehicle = {
    connection = {
        table = "dbify_vehicles",
        key = "id"
    },

    fetchAll = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.vehicle.fetchAll(table: keyColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local keyColumns = dbify.mysql.util.fetchArg(_, cArgs)
                        resolve(dbify.mysql.table.fetchContents(dbify.vehicle.connection.table, keyColumns), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    create = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.vehicle.create()"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        imports.dbQuery(function(queryHandler, cArgs)
                            local _, _, vehicleID = imports.dbPoll(queryHandler, 0)
                            local result = imports.tonumber((vehicleID)) or false
                            resolve(result, cArgs)
                        end, dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(NULL)", dbify.vehicle.connection.table, dbify.vehicle.connection.key)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    delete = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.vehicle.delete(int: vehicleID)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        if not vehicleID or (imports.type(vehicleID) ~= "number") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.vehicle.getData(vehicleID, {dbify.vehicle.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.vehicle.connection.table, dbify.vehicle.connection.key, vehicleID), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    setData = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.vehicle.setData(int: vehicleID, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local vehicleID, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                        if not vehicleID or (imports.type(vehicleID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.vehicle.getData(vehicleID, {dbify.vehicle.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(dbify.mysql.data.set(dbify.vehicle.connection.table, dataColumns, { {dbify.vehicle.connection.key, vehicleID} }), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    getData = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.vehicle.getData(int: vehicleID, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local vehicleID, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                        if not vehicleID or (imports.type(vehicleID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        resolve(dbify.mysql.data.get(dbify.vehicle.connection.table, dataColumns, { {dbify.vehicle.connection.key, vehicleID} }, true), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end
}


-----------------------
--[[ Module Booter ]]--
-----------------------

imports.assetify.scheduler.execOnModuleLoad(function()
    if not dbify.mysql.connection.instance then return false end
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` INT AUTO_INCREMENT PRIMARY KEY)", dbify.vehicle.connection.table, dbify.vehicle.connection.key)
end)