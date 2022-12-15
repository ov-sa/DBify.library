-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tostring = tostring,
    loadstring = loadstring,
    dbExec = dbExec,
    table = table,
    string = string
}


-----------------------
--[[ ORM: Template ]]--
-----------------------

local templateKeys = {
    ["TINYINT"] = "number",
    ["SMALLINT"] = "number",
    ["MEDIUMINT"] = "number",
    ["INT"] = "number",
    ["BIGINT"] = "number",
    ["VARCHAR"] = "string",
    ["CHAR"] = "string",
    ["BINARY"] = "string",
    ["VARBINARY"] = "string",
    ["TINYBLOB"] = "string",
    ["TINYTEXT"] = "string",
    ["BLOB"] = "string",
    ["TEXT"] = "string",
    ["MEDIUMBLOB"] = "string",
    ["MEDIUMTEXT"] = "string",
    ["LONGBLOB"] = "string",
    ["LONGTEXT"] = "string"
}

local template = [[
    local imports = {
        type = type,
        tonumber = tonumber,
        dbQuery = dbQuery,
        dbPoll = dbPoll,
        dbExec = dbExec,
        table = table,
        assetify = assetify
    }

    return {
        fetchAll = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].fetchAll(table: keyColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local keyColumns = dbify.mysql.util.fetchArg(_, cArgs)
                            resolve(dbify.mysql.table.fetchContents(dbify.module["<moduleName>"].__TMP.tableName, keyColumns), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
        
        create = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local queryStrings, queryArguments, querySubArguments = {"INSERT INTO `??` (", " VALUES("}, {dbify.module["<moduleName>"].__TMP.tableName}, {}
                            for i = 1, imports.table.length(dbify.module["<moduleName>"].__TMP.structure), 1 do
                                local j = dbify.module["<moduleName>"].__TMP.structure[i]
                                local isPrimaryKey = i == dbify.module["<moduleName>"].__TMP.structure.key
                                if not isPrimaryKey or not j.__TMP.isAutoIncrement then
                                    local queryArg = dbify.mysql.util.fetchArg(_, cArgs)
                                    local isNonLastIndex = ((i < imports.table.length(dbify.module["<moduleName>"].__TMP.structure)) and ((dbify.module["<moduleName>"].__TMP.structure.key < imports.table.length(dbify.module["<moduleName>"].__TMP.structure)) or ((i + 1) ~= dbify.module["<moduleName>"].__TMP.structure.key) or not dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.isAutoIncrement) and true) or false
                                    queryStrings[1], queryStrings[2] = queryStrings[1].."`??`"..((isNonLastIndex and ", ") or ""), queryStrings[2].."?"..((isNonLastIndex and ", ") or "")
                                    imports.table.insert(queryArguments, j[1])
                                    imports.table.insert(querySubArguments, queryArg)
                                    if j.__TMP.hasDefaultValue or (j.__TMP.isNotNull and (not queryArg or (imports.type(queryArg) ~= j.__TMP.type))) then
                                        local syntaxMsg = "dbify.module[\"<moduleName>\"].create("
                                        for k = 1, imports.table.length(dbify.module["<moduleName>"].__TMP.structure), 1 do
                                            local v = dbify.module["<moduleName>"].__TMP.structure[k]
                                            if (k ~= dbify.module["<moduleName>"].__TMP.structure.key) or not v.__TMP.isAutoIncrement then
                                                local isNonLastIndex = ((k < imports.table.length(dbify.module["<moduleName>"].__TMP.structure)) and ((dbify.module["<moduleName>"].__TMP.structure.key < imports.table.length(dbify.module["<moduleName>"].__TMP.structure)) or ((k + 1) ~= dbify.module["<moduleName>"].__TMP.structure.key) or not dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.isAutoIncrement) and true) or false
                                                syntaxMsg = syntaxMsg..(v.__TMP.type)..": "..v[1]..((isNonLastIndex and ", ") or "")
                                            end
                                        end
                                        syntaxMsg = syntaxMsg..")"
                                        return dbify.mysql.util.throwError(reject, syntaxMsg)
                                    end
                                    if isPrimaryKey then
                                        local isExisting = dbify.module["<moduleName>"].getData(queryArg, {j[1]})
                                        if isExisting then return resolve(not isExisting, cArgs) end
                                    end
                                end
                            end
                            for i = 1, querySubArguments.__T.length, 1 do
                                local j = querySubArguments[i]
                                imports.table.insert(queryArguments, j)
                            end
                            queryStrings[1], queryStrings[2] = queryStrings[1]..")", queryStrings[2]..(((imports.table.length(queryArguments) <= 1) and "NULL") or "")..")"
                            if dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.isAutoIncrement then
                                imports.dbQuery(function(queryHandler, cArgs)
                                    local _, _, identifierID = imports.dbPoll(queryHandler, 0)
                                    local result = imports.tonumber(identifierID) or false
                                    resolve(result, cArgs)
                                end, dbify.mysql.instance, queryStrings[1]..queryStrings[2], imports.table.unpack(queryArguments))
                            else
                                resolve(imports.dbExec(dbify.mysql.instance, queryStrings[1]..queryStrings[2], imports.table.unpack(queryArguments)), cArgs) 
                            end
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        delete = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].delete("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1]..")"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1]})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.instance, "DELETE FROM `??` WHERE `??`=?", dbify.module["<moduleName>"].__TMP.tableName, dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1], identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        setData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].setData("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1]..", table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type) or not dataColumns or (imports.type(dataColumns) ~= "table") or (imports.table.length(dataColumns) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1]})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(dbify.mysql.data.set(dbify.module["<moduleName>"].__TMP.tableName, dataColumns, { {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1], identifer} }), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        getData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].getData("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1]..", table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)].__TMP.type) or not dataColumns or (imports.type(dataColumns) ~= "table") or (imports.table.length(dataColumns) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            resolve(dbify.mysql.data.get(dbify.module["<moduleName>"].__TMP.tableName, dataColumns, { {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.key)][1], identifer} }, true), cArgs)                        
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
    config.structure = (config.structure and (imports.type(config.structure) == "table") and (imports.table.length(config.structure) > 0) and config.structure) or false
    if not config.moduleName or not config.tableName or not config.structure then return false end
    local structure, redundantColumns = {}, {}
    for i = 1, imports.table.length(config.structure), 1 do
        local j = config.structure[i]
        j[1] = imports.tostring(j[1])
        if not redundantColumns[(j[1])] then
            redundantColumns[(j[1])] = true
            j[2] = imports.string.upper(imports.tostring(j[2]))
            local matchedIndex = (imports.string.find(j[2], ",") or (#j[2] + 1)) - 1
            j[2] = imports.string.sub(j[2], 0, matchedIndex)
            j.__TMP = {}
            for k, v in imports.pairs(templateKeys) do
                if imports.string.find(j[2], k) then
                    j.__TMP.type = v
                    j.__TMP.isAutoIncrement = (imports.string.find(j[2], "AUTO_INCREMENT") and true) or false
                    if j.__TMP.isAutoIncrement and (j.__TMP.type ~= "number") then return false end
                    j.__TMP.isNotNull = (imports.string.find(j[2], "NOT NULL") and true) or false
                    j.__TMP.hasDefaultValue = ((j.__TMP.isAutoIncrement or imports.string.find(j[2], "DEFAULT")) and true) or false
                    break
                end
            end
            j.__TMP.type = j.__TMP.type or "string"
            j.__TMP.isAutoIncrement = j.__TMP.isAutoIncrement or false
            imports.table.insert(structure, j)
            if imports.string.find(j[2], "PRIMARY KEY") then
                if structure.key then return false end
                j.__TMP.isNotNull = true
                structure.key = imports.table.length(structure)
            end
        end
    end
    config.structure = structure
    if not config.structure.key or (imports.table.length(config.structure) <= 0) then return false end
    local queryString, queryArguments = "CREATE TABLE IF NOT EXISTS `??` (", {config.tableName, config.structure[(config.structure.key)][1]}
    for i = 1, imports.table.length(config.structure), 1 do
        local j = config.structure[i]
        queryString = queryString.."`??` "..j[2]..(((i < imports.table.length(config.structure)) and ", ") or "")
        imports.table.insert(queryArguments, j[1])
    end
    queryString = queryString..")"
    if not imports.dbExec(dbify.mysql.instance, queryString, imports.table.unpack(queryArguments)) then return false end
    dbify.module[(config.moduleName)] = imports.loadstring(imports.string.gsub(template, "<moduleName>", config.moduleName))()
    dbify.module[(config.moduleName)].__TMP = config
    return config
end