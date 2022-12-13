-----------------
--[[ Imports ]]--
-----------------

local imports = {
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerSerial = getPlayerSerial,
    dbExec = dbExec,
    assetify = assetify
}


----------------
--[[ Module ]]--
----------------

local moduleInfo = dbify.createModule({
    moduleName = "serial",
    tableName = "dbify_serials",
    structure = {
        {"serial", "VARCHAR(100) PRIMARY KEY"}
    }
})

imports.assetify.scheduler.execOnModuleLoad(function()
    if not dbify.settings.syncNativeSerials then return false end
    local serverPlayers = imports.getElementsByType("player")
    for i = 1, #serverPlayers, 1 do
        local playerSerial = imports.getPlayerSerial(serverPlayers[i])
        dbify.module[(moduleInfo.moduleName)].create(playerSerial)
    end
    imports.addEventHandler("onPlayerJoin", root, function()
        dbify.module[(moduleInfo.moduleName)].create(imports.getPlayerSerial(source))
    end)
end)