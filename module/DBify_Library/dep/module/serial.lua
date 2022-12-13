-----------------
--[[ Imports ]]--
-----------------

local imports = {
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

dbify.createModule({
    moduleName = "serial",
    tableName = "dbify_serials",
    keyName = "serial",
    keyType = "string"
})


-----------------------
--[[ Module Booter ]]--
-----------------------

imports.assetify.scheduler.execOnModuleLoad(function()
    imports.dbExec(dbify.mysql.connection.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.module.serial.connection.table, dbify.module.serial.connection.key)
    if dbify.settings.syncSerial then
        local playerList = imports.getElementsByType("player")
        for i = 1, #playerList, 1 do
            local playerSerial = imports.getPlayerSerial(playerList[i])
            dbify.module.serial.create(playerSerial)
        end
        imports.addEventHandler("onPlayerJoin", root, function()
            dbify.module.serial.create(imports.getPlayerSerial(source))
        end)
    end
end)