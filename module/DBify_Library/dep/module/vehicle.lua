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


-------------------------
--[[ Module: Vehicle ]]--
-------------------------

local moduleInfo = dbify.createModule({
    moduleName = "vehicle",
    tableName = "dbify_vehicles",
    structure = {
        {"id", "BIGINT AUTO_INCREMENT PRIMARY KEY"}
    }
})