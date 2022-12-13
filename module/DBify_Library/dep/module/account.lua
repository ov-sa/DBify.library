-----------------
--[[ Imports ]]--
-----------------

local imports = {
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

dbify.createModule({
    moduleName = "account",
    tableName = "dbify_accounts",
    keyName = "name",
    keyType = "string"
})


-----------------------
--[[ Module Booter ]]--
-----------------------

imports.assetify.scheduler.execOnModuleLoad(function()
    if not dbify.mysql.connection.instance then return false end
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.module.account.connection.table, dbify.module.account.connection.key)
    if dbify.settings.syncAccount then
        local playerList = imports.getElementsByType("player")
        for i = 1, #playerList, 1 do
            local playerAccount = imports.getPlayerAccount(playerList[i])
            if playerAccount and not imports.isGuestAccount(playerAccount) then
                dbify.module.account.create(imports.getAccountName(playerAccount))
            end
        end
        imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)
            dbify.module.account.create(imports.getAccountName(currAccount))
        end)
    end
end)