-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerSerial = getPlayerSerial,
    dbExec = dbExec,
    table = table,
    assetify = assetify
}


------------------------
--[[ Module: Serial ]]--
------------------------

dbify.serial = {
    connection = {
        table = "dbify_serials",
        key = "serial"
    },

    fetchAll = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.serial.fetchAll(table: keyColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local keyColumns = dbify.util.fetchArg(_, cArgs)
                        resolve(dbify.mysql.table.fetchContents(dbify.serial.connection.table, keyColumns), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    create = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.serial.create(string: serial)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local serial = dbify.util.fetchArg(_, cArgs)
                        if not serial or (imports.type(serial) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.serial.getData(serial, {dbify.serial.connection.key})
                        if isExisting then return resolve(not isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.serial.connection.table, dbify.serial.connection.key, serial), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    delete = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.serial.delete(string: serial)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local serial = dbify.util.fetchArg(_, cArgs)
                        if not serial or (imports.type(serial) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.serial.getData(serial, {dbify.serial.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.serial.connection.table, dbify.serial.connection.key, serial), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    setData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.serial.setData(string: serial, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local serial, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not serial or (imports.type(serial) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.serial.getData(serial, {dbify.serial.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(dbify.mysql.data.set(dbify.serial.connection.table, dataColumns, { {dbify.serial.connection.key, serial} }), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    getData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.serial.getData(string: serial, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local serial, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not serial or (imports.type(serial) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        resolve(dbify.mysql.data.get(dbify.serial.connection.table, dataColumns, { {dbify.serial.connection.key, serial} }, true), cArgs)                        
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
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.serial.connection.table, dbify.serial.connection.key)
    if dbify.settings.syncSerial then
        local playerList = imports.getElementsByType("player")
        for i = 1, #playerList, 1 do
            local playerSerial = imports.getPlayerSerial(playerList[i])
            dbify.serial.create(playerSerial)
        end
        imports.addEventHandler("onPlayerJoin", root, function()
            dbify.serial.create(imports.getPlayerSerial(source))
        end)
    end
end)