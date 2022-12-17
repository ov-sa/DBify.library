-------------------------
--[[ Module: Vehicle ]]--
-------------------------

local cModule = dbify.createModule({
    moduleName = "vehicle",
    tableName = "dbify_vehicles",
    structure = {
        {"id", "BIGINT AUTO_INCREMENT PRIMARY KEY"}
    }
})