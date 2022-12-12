-----------------
--[[ Imports ]]--
-----------------

loadstring(exports.assetify:import("threader"))()
local imports = {
    type = type,
    tostring = tostring,
    tonumber = tonumber,
    dbConnect = dbConnect,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    table = table,
    math = math,
    assetify = assetify
}

dbify.util = {
    isConnected = function(reject)
        if not dbify.mysql.connection.instance then
            dbify.util.throwError(reject, "Connection Dead")
            return false
        end
        return true
    end,

    fetchArg = function(index, pool)
        index = imports.tonumber(index) or 1
        index = (((index - imports.math.floor(index)) == 0) and index) or 1
        if not pool or (imports.type(pool) ~= "table") then return false end
        local argValue = pool[index]
        imports.table.remove(pool, index)
        return argValue
    end,

    parseArgs = function(...)
        local cThread = imports.assetify.thread:getThread()
        if not cThread then return false end
        return imports.assetify.thread:createPromise(), imports.table.pack(...)
    end,

    throwError = function(reject, errorMsg)
        if not errorMsg or (imports.type(errorMsg) ~= "string") then return false end
        return execFunction(reject, "DBify: Error ━│  "..errorMsg)
    end
}


-----------------------
--[[ Module: MySQL ]]--
-----------------------

dbify.mysql = {
    connection = {
        instance = imports.dbConnect("mysql", "dbname="..(dbify.settings.credentials.database)..";host="..(dbify.settings.credentials.host)..";port="..(dbify.settings.credentials.port)..";charset=utf8;", dbify.settings.credentials.username, dbify.settings.credentials.password, dbify.settings.credentials.options) or false
    },

    table = {
        isValid = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.table.isValid(string: tableName)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.util.isConnected(reject) then return end
                            local tableName = dbify.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (#result > 0)) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.connection.instance, "SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=? AND `table_name`=?", dbify.settings.credentials.database, tableName)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        fetchContents = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.table.fetchContents(string: tableName, table: keyColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.util.isConnected(reject) then return end
                            local tableName, keyColumns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                            keyColumns = ((keyColumns and (imports.type(keyColumns) == "table") and (#keyColumns > 0)) and keyColumns) or false
                            if not tableName or (imports.type(tableName) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                            local queryString, queryArguments = "SELECT * FROM `??`", {tableName}
                            if not keyColumns then
                                local isValid = dbify.mysql.table.isValid(tableName)
                                if not isValid then return resolve(isValid, cArgs) end
                            else
                                local __keyColumns, validateColumns = {}, {}
                                for i = 1, #keyColumns, 1 do
                                    local j = keyColumns[i]
                                    j[1] = imports.tostring(j[1])
                                    if not validateColumns[(j[1])] then
                                        validateColumns[(j[1])] = true
                                        imports.table.insert(__keyColumns, j)
                                        imports.table.insert(validateColumns, j[1])
                                    end
                                end
                                local areValid = dbify.mysql.column.areValid(tableName, validateColumns)
                                if not areValid then return resolve(areValid, cArgs) end
                                queryString = queryString.." WHERE"
                                for i = 1, #__keyColumns, 1 do
                                    local j = __keyColumns[i]
                                    imports.table.insert(queryArguments, j[1])
                                    imports.table.insert(queryArguments, imports.tostring(j[2]))
                                    queryString = queryString.." `??`=?"..(((i < #__keyColumns) and " AND") or "")
                                end
                            end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = (result and (#result > 0) and result) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.connection.instance, queryString, imports.table.unpack(queryArguments))
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    },

    column = {
        isValid = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.isValid(string: tableName, string: columnName)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.util.isConnected(reject) then return end
                            local tableName, columnName = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columnName or (imports.type(columnName) ~= "string") then return dbify.util.throwError(reject, syntaxMsg) end
                            local isValid = dbify.mysql.table.isValid(tableName)
                            if not isValid then return resolve(isValid, cArgs) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (#result > 0)) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.connection.instance, "SELECT `table_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=? AND `column_name`=?", dbify.settings.credentials.database, tableName, columnName)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        areValid = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.areValid(string: tableName, table: columns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.util.isConnected(reject) then return end
                            local tableName, columns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columns or (imports.type(columns) ~= "table") or (#columns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                            local isValid = dbify.mysql.table.isValid(tableName)
                            if not isValid then return resolve(isValid, cArgs) end
                            local queryString, queryArguments = "SELECT `table_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=? AND (", {dbify.settings.credentials.database, tableName}
                            local validateColumns, redundantColumns = {}, {}
                            for i = 1, #columns, 1 do
                                local j = imports.tostring(columns[i])
                                if not redundantColumns[j] then
                                    redundantColumns[j] = true
                                    imports.table.insert(validateColumns, j)
                                    imports.table.insert(queryArguments, j)
                                    queryString = queryString..(((i > 1) and " ") or "").."`column_name`=?"..(((i < #columns) and " OR") or "")
                                end
                            end
                            queryString = queryString..")"
                            local areValid = dbify.mysql.column.areValid(tableName, validateColumns)
                            if not areValid then return resolve(areValid, cArgs) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (#result >= #columns)) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.connection.instance, queryString, imports.table.unpack(queryArguments))
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        delete = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.delete(string: tableName, table: columns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.util.isConnected(reject) then return end
                            local tableName, columns = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columns or (imports.type(columns) ~= "table") or (#columns <= 0) then return dbify.util.throwError(reject, syntaxMsg) end
                            local isValid = dbify.mysql.table.isValid(tableName)
                            if not isValid then return resolve(isValid, cArgs) end
                            local queryString, queryArguments = "ALTER TABLE `??`", {tableName}
                            local redundantColumns = {}
                            for i = 1, #columns, 1 do
                                local j = imports.tostring(columns[i])
                                if not redundantColumns[j] then
                                    redundantColumns[j] = true
                                    imports.table.insert(queryArguments, j)
                                    queryString = queryString.." DROP COLUMN `??`"..(((i < #columns) and ", ") or "")
                                end
                            end
                            local result = imports.dbExec(dbify.mysql.connection.instance, queryString, imports.table.unpack(queryArguments))
                            resolve(result, cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    },

    data = {
        set = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(4, ...)
            local promise = function()
                if not dbify.mysql.connection.instance then return false end
                local tableName, dataColumns, keyColumns, callback = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) then return false end
                local __validateKeys, validateKeys = {}, {}
                for i = 1, #keyColumns, 1 do
                    local j = keyColumns[i]
                    if not __validateKeys[(j[1])] then
                        imports.table.insert(validateKeys, j[1])
                    end
                end
                return dbify.mysql.column.areValid(tableName, validateKeys, function(areValid, cArgs)
                    if areValid then
                        local queryStrings, queryArguments = {"UPDATE `??` SET", " WHERE"}, {subLength = 0, cArgs = {}}
                        for i = 1, #cArgs[1].keyColumns, 1 do
                            local j = cArgs[1].keyColumns[i]
                            j[1] = imports.tostring(j[1])
                            imports.table.insert(queryArguments.cArgs, j[1])
                            imports.table.insert(queryArguments.cArgs, imports.tostring(j[2]))
                            queryStrings[2] = queryStrings[2].." `??`=?"..(((i < #cArgs[1].keyColumns) and " AND") or "")
                        end
                        queryArguments.subLength = #queryArguments.cArgs
                        imports.table.insert(queryArguments.cArgs, (#queryArguments.cArgs - queryArguments.subLength) + 1, cArgs[1].tableName)
                        for i = 1, #cArgs[1].dataColumns, 1 do
                            local j = cArgs[1].dataColumns[i]
                            j[1] = imports.tostring(j[1])
                            imports.table.insert(queryArguments.cArgs, (#queryArguments.cArgs - queryArguments.subLength) + 1, j[1])
                            imports.table.insert(queryArguments.cArgs, (#queryArguments.cArgs - queryArguments.subLength) + 1, imports.tostring(j[2]))
                            queryStrings[1] = queryStrings[1].." `??`=?"..(((i < #cArgs[1].dataColumns) and ",") or "")
                            dbify.mysql.column.isValid(cArgs[1].tableName, j[1], function(isValid, cArgs)
                                if not isValid then
                                    imports.dbExec(dbify.mysql.connection.instance, "ALTER TABLE `??` ADD COLUMN `??` TEXT", cArgs[1], cArgs[2])
                                end
                                if cArgs[3] then
                                    local result = imports.dbExec(dbify.mysql.connection.instance, cArgs[3].queryString, imports.table.unpack(cArgs[3].queryArguments))
                                    execFunction(callback, result, cArgs[4])
                                end
                            end, cArgs[1].tableName, j[1], ((i >= #cArgs[1].dataColumns) and {
                                queryString = queryStrings[1]..queryStrings[2],
                                queryArguments = queryArguments.cArgs
                            }) or false, ((i >= #cArgs[1].dataColumns) and cArgs[2]) or false)
                        end
                    else
                        execFunction(callback, false, cArgs[2])
                    end
                end, {
                    tableName = tableName,
                    dataColumns = dataColumns,
                    keyColumns = keyColumns
                }, cArgs)
            end
            if cPromise then promise(); return cPromise
            else return promise() end
        end,

        get = function(...)
            local cPromise, cArgs = dbify.util.parseArgs(5, ...)
            local promise = function()
                if not dbify.mysql.connection.instance then return false end
                local tableName, dataColumns, keyColumns, soloFetch, callback = dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs), dbify.util.fetchArg(_, cArgs)
                if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) or not callback or (imports.type(callback) ~= "function") then return false end
                soloFetch = (soloFetch and true) or false
                local _validateColumns, validateColumns = {}, {}
                for i = 1, #dataColumns, 1 do
                    local j = dataColumns[i]
                    _validateColumns[j] = true
                    imports.table.insert(validateColumns, j)
                end
                for i = 1, #keyColumns, 1 do
                    local j = keyColumns[i]
                    if not _validateColumns[(j[1])] then
                        _validateColumns[(j[1])] = true
                        imports.table.insert(validateColumns, j[1])
                    end
                end
                return dbify.mysql.column.areValid(tableName, validateColumns, function(areValid, cArgs)
                    if areValid then
                        local queryString, queryArguments = "SELECT", {}
                        for i = 1, #cArgs[1].dataColumns, 1 do
                            local j = cArgs[1].dataColumns[i]
                            imports.table.insert(queryArguments, imports.tostring(j))
                            queryString = queryString.." `??`"..(((i < #cArgs[1].dataColumns) and ",") or "")
                        end
                        imports.table.insert(queryArguments, cArgs[1].tableName)
                        queryString = queryString.." FROM `??` WHERE"
                        for i = 1, #cArgs[1].keyColumns, 1 do
                            local j = cArgs[1].keyColumns[i]
                            imports.table.insert(queryArguments, imports.tostring(j[1]))
                            imports.table.insert(queryArguments, imports.tostring(j[2]))
                            queryString = queryString.." `??`=?"..(((i < #cArgs[1].keyColumns) and " AND") or "")
                        end
                        imports.dbQuery(function(queryHandler, soloFetch, cArgs)
                            local result = imports.dbPoll(queryHandler, 0)
                            result = (result and (#result > 0) and result) or false
                            execFunction(callback, (result and soloFetch and result[1]) or result, cArgs)
                        end, {cArgs[1].soloFetch, cArgs[2]}, dbify.mysql.connection.instance, queryString, imports.table.unpack(queryArguments))
                    else
                        execFunction(callback, false, cArgs[2])
                    end
                end, {
                    tableName = tableName,
                    dataColumns = dataColumns,
                    keyColumns = keyColumns,
                    soloFetch = soloFetch
                }, cArgs)
            end
            if cPromise then promise(); return cPromise
            else return promise() end
        end
    }
}
