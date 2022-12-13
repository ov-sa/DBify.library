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

iprint(moduleInfo)

dbify.character = {
    create = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify.character.create()"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        imports.dbQuery(function(queryHandler, cArgs)
                            local _, _, characterID = imports.dbPoll(queryHandler, 0)
                            local result = imports.tonumber((characterID)) or false
                            resolve(result, cArgs)
                        end, dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(NULL)", dbify.character.connection.table, dbify.character.connection.key)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end
}