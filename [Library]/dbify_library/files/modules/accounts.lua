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
        keyColumn = "name",
    },

    addUser = function(accountName)
        if not dbify.db.__connection__.instance then return false end
        if accountName then

        end
        return false
        if not accountName or dbify["accounts"].getUserData(accountName, dbify["accounts"].__connection__.keyColumn) then return false end
        return connection.database:exec("INSERT INTO `??` (`??`) VALUES(?)", dbify["accounts"].__connection__.table, dbify["accounts"].__connection__.keyColumn, accountName)
    end,

    delUser = function(accountName)
        if not dbify.db.__connection__.instance then return false end
        if not accountName or not dbify["accounts"].getUserData(accountName, dbify["accounts"].__connection__.keyColumn) then return false end
        return connection.database:exec("DELETE FROM `??` WHERE `??`=?", dbify["accounts"].__connection__.table, dbify["accounts"].__connection__.keyColumn, accountName)
    end,

    getUserData = function(accountName, dataColumn)
        return exports.mysql_library:getRowData(dbify["accounts"].__connection__.table, accountName, dbify["accounts"].__connection__.keyColumn, dataColumn)
    end,

    setUserData = function(accountName, dataColumn, dataValue)
        return exports.mysql_library:setRowData(dbify["accounts"].__connection__.table, accountName, dbify["accounts"].__connection__.keyColumn, dataColumn, dataValue)
    end
}


------------------------------------------------
--[[ Events: On Resource-Start/Player-Login ]]--
------------------------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    if not dbSettings.instance then return false end
    imports.dbExec(dbSettings.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.accounts.__connection__.table, dbify.accounts.__connection__.keyColumn)
    if syncSettings.syncAccounts then
        for i, j in imports.ipairs(imports.getElementsByType("player")) do
            local playerAccount = imports.getPlayerAccount(j)
            if playerAccount and not imports.isGuestAccount(playerAccount) then
                dbify["accounts"].addUser(imports.getAccountName(currAccount))
            end
        end
    end

end)

imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)

    if not dbSettings.instance then return false end
    if syncSettings.syncAccounts and currAccount then
        dbify["accounts"].addUser(imports.getAccountName(currAccount))
    end

end)