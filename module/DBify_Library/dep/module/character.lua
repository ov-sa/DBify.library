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


---------------------------
--[[ Module: Character ]]--
---------------------------

dbify.character = {
    connection = {
        table = "dbify_characters",
        key = "id"
    },

    fetchAll = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.fetchAll(table: keyColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local keyColumns = dbify.util.fetchArg(_, cArgs)
                        resolve(dbify.mysql.table.fetchContents(dbify.character.connection.table, keyColumns), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    create = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.create()"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        imports.dbQuery(function(queryHandler, cArgs)
                            local _, _, characterID = imports.dbPoll(queryHandler, 0)
                            local result = imports.tonumber((characterID)) or false
                            resolve(result, cArgs)
                        end, dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(NULL)", dbify.character.connection.table, dbify.character.connection.key)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    delete = function(...)
        local isAsync, cArgs = dbify.parseArgs(2, ...)
        local promise = function()
            local characterID, callback = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
            if not characterID or (imports.type(characterID) ~= "number") then return false end
            return dbify.character.getData(characterID, {dbify.character.connection.key}, function(result, cArgs)
                if result then
                    result = imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.character.connection.table, dbify.character.connection.key, characterID)
                    execFunction(callback, result, cArgs)
                else
                    execFunction(callback, false, cArgs)
                end
            end, imports.table.unpack(cArgs))
        end
        if isAsync then promise(); return isAsync
        else return promise() end
    end,

    setData = function(...)
        local isAsync, cArgs = dbify.parseArgs(3, ...)
        local promise = function()
            local characterID, dataColumns, callback = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
            if not characterID or (imports.type(characterID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
            return dbify.mysql.data.set(dbify.character.connection.table, dataColumns, {
                {dbify.character.connection.key, characterID}
            }, callback, imports.table.unpack(cArgs))
        end
        if isAsync then promise(); return isAsync
        else return promise() end
    end,

    getData = function(...)
        local isAsync, cArgs = dbify.parseArgs(3, ...)
        local promise = function()
            local characterID, dataColumns, callback = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
            if not characterID or (imports.type(characterID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
            return dbify.mysql.data.get(dbify.character.connection.table, dataColumns, {
                {dbify.character.connection.key, characterID}
            }, true, callback, imports.table.unpack(cArgs))
        end
        if isAsync then promise(); return isAsync
        else return promise() end
    end
}


-----------------------
--[[ Module Booter ]]--
-----------------------

imports.assetify.scheduler.execOnModuleLoad(function()
    if not dbify.mysql.connection.instance then return false end
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` INT AUTO_INCREMENT PRIMARY KEY)", dbify.character.connection.table, dbify.character.connection.key)
end)