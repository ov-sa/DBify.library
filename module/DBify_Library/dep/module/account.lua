-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerAccount = getPlayerAccount,
    isGuestAccount = isGuestAccount,
    getAccountName = getAccountName,
    dbExec = dbExec,
    table = table,
    assetify = assetify
}


-------------------------
--[[ Module: Account ]]--
-------------------------

dbify.account = {
    connection = {
        table = "dbify_accounts",
        key = "name"
    },

    fetchAll = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.account.fetchAll(table: keyColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local keyColumns = dbify.util.fetchArg(_, cArgs)
                        resolve(dbify.mysql.table.fetchContents(dbify.account.connection.table, keyColumns), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    create = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.account.create(string: accountName)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local accountName = dbify.util.fetchArg(_, cArgs)
                        if not accountName or (imports.type(accountName) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.account.getData(accountName, {dbify.account.connection.key})
                        if isExisting then return resolve(not isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.account.connection.table, dbify.account.connection.key, accountName), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    delete = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.account.delete(string: accountName)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local accountName = dbify.util.fetchArg(_, cArgs)
                        if not accountName or (imports.type(accountName) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.account.getData(accountName, {dbify.account.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.account.connection.table, dbify.account.connection.key, accountName), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    setData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.account.setData(string: accountName, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local accountName, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not accountName or (imports.type(accountName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify.account.getData(accountName, {dbify.account.connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(dbify.mysql.data.set(dbify.account.connection.table, dataColumns, { {dbify.account.connection.key, accountName} }), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    getData = function(...)
        local cPromise, cArgs = dbify.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.account.getData(string: accountName, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local accountName, dataColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                        if not accountName or (imports.type(accountName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                        resolve(dbify.mysql.data.get(dbify.account.connection.table, dataColumns, { {dbify.account.connection.key, accountName} }, true), cArgs)                        
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
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.account.connection.table, dbify.account.connection.key)
    if dbify.settings.syncAccount then
        local playerList = imports.getElementsByType("player")
        for i = 1, #playerList, 1 do
            local playerAccount = imports.getPlayerAccount(playerList[i])
            if playerAccount and not imports.isGuestAccount(playerAccount) then
                dbify.account.create(imports.getAccountName(playerAccount))
            end
        end
        imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)
            dbify.account.create(imports.getAccountName(currAccount))
        end)
    end
end)