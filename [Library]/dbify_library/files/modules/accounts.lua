----------------------------------------------------------------
--[[ Resource: DBify Library
     Files: modules: accounts.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Accounts Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    ipairs = ipairs,
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerAccount = getPlayerAccount,
    isGuestAccount = isGuestAccount,
    getAccountName = getAccountName,
    dbExec = dbExec
}


-------------------
--[[ Variables ]]--
-------------------

dbify["accounts"] = {
    __connection__ = {
        table = "user_accounts",
        keyColumn = "name"
    },

    addUser = function(accountName, callback, ...)
        if not dbify.db.__connection__.instance then return false end
        if not accountName then return false end
        return dbify.accounts.getUserData(accountName, {dbify.accounts.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if not result then
                result = imports.dbExec(dbify.db.__connection__.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.accounts.__connection__.table, dbify.accounts.__connection__.keyColumn, accountName)
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

    delUser = function(accountName, callback, ...)
        if not dbify.db.__connection__.instance then return false end
        if not accountName then return false end
        return dbify.accounts.getUserData(accountName, {dbify.accounts.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if result then
                result = imports.dbExec(dbify.db.__connection__.instance, "DELETE FROM `??` WHERE `??`=?", dbify.accounts.__connection__.table, dbify.accounts.__connection__.keyColumn, accountName)
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

    setUserData = function(accountName, dataColumns, callback, ...)
        if not dbify.db.__connection__.instance then return false end
        if not accountName or (imports.type(accountName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.db.data.set(dbify.accounts.__connection__.table, dataColumns, {
            {dbify.accounts.__connection__.keyColumn, accountName},
        }, callback, ...)
    end,

    getUserData = function(accountName, dataColumns, callback, ...)
        if not dbify.db.__connection__.instance then return false end
        if not accountName or (imports.type(accountName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.db.data.get(dbify.accounts.__connection__.table, dataColumns, {
            {dbify.accounts.__connection__.keyColumn, accountName},
        }, true, callback, ...)
    end
}


------------------------------------------------
--[[ Events: On Resource-Start/Player-Login ]]--
------------------------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    if not dbify.db.__connection__.instance then return false end
    imports.dbExec(dbify.db.__connection__.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.accounts.__connection__.table, dbify.accounts.__connection__.keyColumn)
    if dbify.accounts.__connection__.autoSync then
        for i, j in imports.ipairs(imports.getElementsByType("player")) do
            local playerAccount = imports.getPlayerAccount(j)
            if playerAccount and not imports.isGuestAccount(playerAccount) then
                dbify.accounts.addUser(imports.getAccountName(currAccount))
            end
        end
    end

end)

imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)

    if not dbify.db.__connection__.instance then return false end
    if dbify.accounts.__connection__.autoSync then
        dbify.accounts.addUser(imports.getAccountName(currAccount))
    end

end)

--[[
    function getAllUserAccounts()

    local query = connection.database:query("SELECT * FROM `??`", connection.tableName)
    if not query then return false end
    local result = query:poll(-1)
    if query then
        query:free()
    end
    return result

end
]]