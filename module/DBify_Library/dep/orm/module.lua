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
            local syntaxMsg = "dbify.module[\"<moduleName>\"].create("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]..")"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local isPrimaryKeyMatched = false
                            local queryStrings, queryArguments, querySubArguments = {"INSERT INTO `??` (", " VALUES("}, {dbify.module["<moduleName>"].__TMP.tableName}, {}
                            for i = 1, #dbify.module["<moduleName>"].__TMP.structure, 1 do
                                local j = dbify.module["<moduleName>"].__TMP.structure[i]
                                isPrimaryKeyMatched = isPrimaryKeyMatched or (j[1] == dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1])
                                local isToBeIndexed = (j[1] ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]) or not dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.isAutoIncrement
                                if isToBeIndexed then
                                    local isLastIndex = ((i < #dbify.module["<moduleName>"].__TMP.structure) and (isPrimaryKeyMatched or (i ~= (#dbify.module["<moduleName>"].__TMP.structure - 1))) and true) or false
                                    queryStrings[1], queryStrings[2] = queryStrings[1].."`??`"..((isLastIndex and ", ") or ""), queryStrings[2].."?"..((isLastIndex and ", ") or "")
                                    imports.table.insert(queryArguments, j[1])
                                    imports.table.insert(querySubArguments, dbify.mysql.util.fetchArg(_, cArgs))
                                    if not dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.isAutoIncrement then
                                        local identifier = querySubArguments[(#querySubArguments)]
                                        if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type) then

                                            --TODO:... REPLACE AND CHECK FOR ALL ARGS
                                            --for k, v in imports.pairs(templateKeys) do
                                              --  if imports.string.find(j[2], k) then
                                                --    structure.keyName, structure.keyType = j[1], v
                                                  --  structure.isKeyAutoIncrement = (imports.string.find(j[2], "AUTO_INCREMENT") and true) or false
                                                    --break
                                                --end
                                            --end

                                            return dbify.mysql.util.throwError(reject, syntaxMsg)
                                        end
                                        local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]})
                                        if isExisting then return resolve(not isExisting, cArgs) end
                                    end
                                end
                            end
                            for i = 1, #querySubArguments, 1 do
                                local j = querySubArguments[i]
                                imports.table.insert(queryArguments, j)
                            end
                            queryStrings[1], queryStrings[2] = queryStrings[1]..")", queryStrings[2]..(((#queryArguments <= 1) and "NULL") or "")..")"
                            if dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.isAutoIncrement then
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
            local syntaxMsg = "dbify.module[\"<moduleName>\"].delete("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]..")"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer = dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(imports.dbExec(dbify.mysql.instance, "DELETE FROM `??` WHERE `??`=?", dbify.module["<moduleName>"].__TMP.tableName, dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1], identifer), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        setData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].setData("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]..", table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type) or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            local isExisting = dbify.module["<moduleName>"].getData(identifer, {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]})
                            if not isExisting then return resolve(isExisting, cArgs) end
                            resolve(dbify.mysql.data.set(dbify.module["<moduleName>"].__TMP.tableName, dataColumns, { {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1], identifer} }), cArgs)                        
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        getData = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.module[\"<moduleName>\"].getData("..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type..": "..dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1]..", table: dataColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            local identifer, dataColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not identifer or (imports.type(identifer) ~= dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)].__TMP.type) or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            resolve(dbify.mysql.data.get(dbify.module["<moduleName>"].__TMP.tableName, dataColumns, { {dbify.module["<moduleName>"].__TMP.structure[(dbify.module["<moduleName>"].__TMP.structure.keyIndex)][1], identifer} }, true), cArgs)                        
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
    config.structure = (config.structure and (imports.type(config.structure) == "table") and (#config.structure > 0) and config.structure) or false
    if not config.moduleName or not config.tableName or not config.structure then return false end
    local isPrimaryKeyMatched = false
    local structure, redundantColumns = {}, {}
    for i = 1, #config.structure, 1 do
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
                    j.__TMP.isNotNull = (imports.string.find(j[2], "NOT NULL") and true) or false
                    break
                end
            end
            j.__TMP.type = j.__TMP.type or "string"
            j.__TMP.isAutoIncrement = j.__TMP.isAutoIncrement or false
            if imports.string.find(j[2], "PRIMARY KEY") then
                if isPrimaryKeyMatched then return false end
                isPrimaryKeyMatched = true
                structure.keyIndex = #structure
            end
            imports.table.insert(structure, j)
        end
    end
    config.structure = structure
    if not config.structure.keyIndex or (#config.structure <= 0) then return false end
    local queryString, queryArguments = "CREATE TABLE IF NOT EXISTS `??` (", {config.tableName, config.structure[(config.structure.keyIndex)][1]}
    for i = 1, #config.structure, 1 do
        local j = config.structure[i]
        queryString = queryString.."`??` "..j[2]..(((i < #config.structure) and ", ") or "")
        imports.table.insert(queryArguments, j[1])
    end
    queryString = queryString..")"
    if not imports.dbExec(dbify.mysql.instance, queryString, imports.table.unpack(queryArguments)) then return false end
    dbify.module[(config.moduleName)] = imports.loadstring(imports.string.gsub(template, "<moduleName>", config.moduleName))()
    dbify.module[(config.moduleName)].__TMP = config
    return config
end