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


-------------------------
--[[ Module: Account ]]--
-------------------------

local moduleInfo = dbify.createModule({
    moduleName = "account",
    tableName = "dbify_accounts",
    structure = {
        {"name", "VARCHAR(100) PRIMARY KEY"}
    }
})

imports.assetify.scheduler.execOnModuleLoad(function()
    if not dbify.settings.syncNativeAccounts then return false end
    local serverPlayers = imports.getElementsByType("player")
    for i = 1, #serverPlayers, 1 do
        local playerAccount = imports.getPlayerAccount(serverPlayers[i])
        if playerAccount and not imports.isGuestAccount(playerAccount) then
            dbify.module[(moduleInfo.moduleName)].create(imports.getAccountName(playerAccount))
        end
    end
    imports.addEventHandler("onPlayerLogin", root, function(_, currAccount)
        dbify.module[(moduleInfo.moduleName)].create(imports.getAccountName(currAccount))
    end)
end)