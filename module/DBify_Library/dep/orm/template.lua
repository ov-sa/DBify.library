-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    loadstring = loadstring,
    string = string
}


-----------------------
--[[ ORM: Template ]]--
-----------------------

local template = [[
    local imports = {
        type = type,
        dbExec = dbExec,
        table = table,
        assetify = assetify
    }

    return {
        connection = {
            table = "<tableName>",
            key = "<keyName>"
        },

        fetchAll = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].fetchAll(table: keyColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local keyColumns = dbify.mysql.util.fetchArg(_, cArgs)
                            resolve(dbify.mysql.table.fetchContents(dbify.module["<moduleName>"].connection.table, keyColumns), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
        
        create = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].create(<keyType>: <keyName>)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if isExisting then return resolve(not isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.module["<moduleName>"].connection.table, dbify.module["<moduleName>"].connection.key, identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        delete = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].delete(<keyType>: <keyName>)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify.module["<moduleName>"].connection.table, dbify.module["<moduleName>"].connection.key, identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        setData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].setData(<keyType>: <keyName>, table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].connection.key})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(dbify.mysql.data.set(dbify.module["<moduleName>"].connection.table, dataColumns, { {dbify.module["<moduleName>"].connection.key, identifer} }), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        getData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].getData(<keyType>: <keyName>, table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            resolve(dbify.mysql.data.get(dbify.module["<moduleName>"].connection.table, dataColumns, { {dbify.module["<moduleName>"].connection.key, identifer} }, true), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    }
]]

dbify.module = {}
dbify.createModule = function(config)
    if not config or (imports.type(config) ~= "table") then return false end
    config.moduleName = (config.moduleName and (imports.type(config.moduleName) == "string") and config.moduleName) or false
    config.tableName = (config.tableName and (imports.type(config.tableName) == "string") and config.tableName) or false
    config.keyName = (config.keyName and (imports.type(config.keyName) == "string") and config.keyName) or false
    config.keyType = (config.keyType and (imports.type(config.keyType) == "string") and config.keyType) or false
    if not config.moduleName or not config.tableName or not config.keyName or not config.keyType then return false end
    local cTemplate = template
    cTemplate = imports.string.gsub(cTemplate, "<moduleName>", config.moduleName)
    cTemplate = imports.string.gsub(cTemplate, "<tableName>", config.tableName)
    cTemplate = imports.string.gsub(cTemplate, "<keyName>", config.keyName)
    cTemplate = imports.string.gsub(cTemplate, "<keyType>", config.keyType)
    dbify.module[(config.moduleName)] = imports.loadstring(cTemplate)()
    return true
end