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
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.delete(int: characterID)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        if not characterID or (imports.type(characterID) ~= "number") then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.character.getData(characterID, {dbify.character.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.character.connection.table, dbify.character.connection.key, characterID), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    setData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.setData(int: characterID, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local characterID, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not characterID or (imports.type(characterID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.character.getData(characterID, {dbify.character.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(dbify.mysql.data.set(dbify.character.connection.table, dataColumns, { {dbify.character.connection.key, characterID} }), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    getData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.getData(int: characterID, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local characterID, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not characterID or (imports.type(characterID) ~= "number") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        resolve(dbify.mysql.data.get(dbify.character.connection.table, dataColumns, { {dbify.character.connection.key, characterID} }, true), cArgs)                        
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
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` INT AUTO_INCREMENT PRIMARY KEY)", dbify.character.connection.table, dbify.character.connection.key)
end)