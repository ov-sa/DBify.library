---------------------------
--[[ Module: Character ]]--
---------------------------

local moduleInfo = dbify.createModule({
    moduleName = "character",
    tableName = "dbify_characters",
    structure = {
        {"id", "BIGINT AUTO_INCREMENT PRIMARY KEY"}
    }
})