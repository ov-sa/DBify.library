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
    assetify = assetify
}


----------------
--[[ Module ]]--
----------------

local moduleInfo = {
    moduleName = "account",
    tableName = "dbify_accounts",
    keyName = "name",
    keyType = "string"
}
dbify.createModule(moduleInfo)

imports.assetify.scheduler.execOnModuleLoad(function()
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.module[(moduleInfo.moduleName)].connection.table, dbify.module[(moduleInfo.moduleName)].connection.key)
    if not dbify.settings.syncNativeAccounts then return false end
    local playerList = imports.getElementsByType("player")
    for i = 1, #playerList, 1 do
        local playerAccount = imports.getPlayerAccount(playerList[i])
        if playerAccount and not imports.isGuestAccount(playerAccount) then
            dbify.module[(moduleInfo.moduleName)].create(imports.getAccountName(playerAccount))
        end
    end
    imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)
        dbify.module[(moduleInfo.moduleName)].create(imports.getAccountName(currAccount))
    end)
end)
