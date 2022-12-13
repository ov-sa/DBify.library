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
    local extension = {}
    extension.connection = {
        table = "<tableName>",
        key = "<keyName>"
    }
    
    extension.fetchAll = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify[\"<extension>\"].fetchAll(table: keyColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local keyColumns = dbify.mysql.util.fetchArg(_, cArgs)
                        resolve(dbify.mysql.table.fetchContents(dbify["<extension>"].connection.table, keyColumns), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end
    
    extension.create = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify[\"<extension>\"].create(string: identifer)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                        if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify["<extension>"].getData(identifer, {dbify["<extension>"].connection.key})
                        if isExisting then return resolve(not isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify["<extension>"].connection.table, dbify["<extension>"].connection.key, identifer), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end

    extension.delete = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify[\"<extension>\"].delete(string: identifer)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                        if not identifer or (imports.type(identifer) ~= "<keyType>") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify["<extension>"].getData(identifer, {dbify["<extension>"].connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(imports.dbExec(dbify.mysql.connection.instance, "DELETE FROM `??` WHERE `??`=?", dbify["<extension>"].connection.table, dbify["<extension>"].connection.key, identifer), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end

    extension.setData = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify[\"<extension>\"].setData(string: identifer, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                        if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        local isExisting = dbify["<extension>"].getData(identifer, {dbify["<extension>"].connection.key})
                        if not isExisting then return resolve(isExisting, cArgs) end
                        resolve(dbify.mysql.data.set(dbify["<extension>"].connection.table, dataColumns, { {dbify["<extension>"].connection.key, identifer} }), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end

    extension.getData = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        local syntaxMsg = "dbify[\"<extension>\"].getData(string: identifer, table: dataColumns)"
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                        if not identifer or (imports.type(identifer) ~= "<keyType>") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        resolve(dbify.mysql.data.get(dbify["<extension>"].connection.table, dataColumns, { {dbify["<extension>"].connection.key, identifer} }, true), cArgs)                        
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end
    return extension
]]

dbify.createExtension = function(config)
    if not config or (imports.type(config) ~= "table") then return false end
    config.extension = (config.extension and (imports.type(config.extension) == "string") and config.extension) or false
    config.tableName = (config.tableName and (imports.type(config.tableName) == "string") and config.tableName) or false
    config.keyName = (config.keyName and (imports.type(config.keyName) == "string") and config.keyName) or false
    config.keyType = (config.keyType and (imports.type(config.keyType) == "string") and config.keyType) or false
    if not config.extension or not config.tableName or not config.keyName or not config.keyType then return false end
    local cTemplate = template
    cTemplate = imports.string.gsub(cTemplate, "<extension>", config.extension)
    cTemplate = imports.string.gsub(cTemplate, "<tableName>", config.tableName)
    cTemplate = imports.string.gsub(cTemplate, "<keyName>", config.keyName)
    cTemplate = imports.string.gsub(cTemplate, "<keyType>", config.keyType)
    return imports.loadstring(cTemplate)()
end


local test = dbify.createExtension({
    extension = "myExtension",
    tableName = "test",
    keyName = "testID",
    keyType = "string"
})
iprint(test)