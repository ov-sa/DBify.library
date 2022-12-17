-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    tostring = tostring,
    dbConnect = dbConnect,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    string = string,
    table = table,
    assetify = assetify
}


--------------------
--[[ ORM: MySQL ]]--
--------------------

dbify.mysql = {
    instance = imports.dbConnect("mysql", "dbname="..(dbify.settings.credentials.database)..";host="..(dbify.settings.credentials.host)..";port="..(dbify.settings.credentials.port)..";charset=utf8;", dbify.settings.credentials.username, dbify.settings.credentials.password, dbify.settings.credentials.options) or false,

    table = {
        fetchList = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.table.fetchList()"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = result or false
                                local __result = (result and {}) or result
                                if __result then
                                    local identifier = "table_name"
                                    for i = 1, #result, 1 do
                                        imports.table.insert(__result, result[i][identifier] or result[i][(imports.string.upper(identifier))])
                                    end
                                end
                                resolve(__result, cArgs)
                            end, dbify.mysql.instance, "SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=?", dbify.settings.credentials.database)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,
    
        isValid = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.table.isValid(string: tableName)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName = dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (imports.table.length(result) > 0)) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.instance, "SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=? AND `table_name`=?", dbify.settings.credentials.database, tableName)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        fetchContents = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.table.fetchContents(string: tableName, table: keyColumns, bool: isSoloFetch)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, keyColumns, isSoloFetch = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or (keyColumns and (imports.type(keyColumns) ~= "table")) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            keyColumns = (keyColumns and (imports.table.length(keyColumns) > 0) and keyColumns) or false
                            isSoloFetch = (isSoloFetch and true) or false
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            local queryString, queryArguments = "SELECT * FROM `??`", {tableName}
                            if keyColumns then
                                queryString = queryString.." WHERE"
                                local __keyColumns, validateColumns, redundantColumns = {}, {}, {}
                                for i = 1, imports.table.length(keyColumns), 1 do
                                    local j = keyColumns[i]
                                    j[1] = imports.tostring(j[1])
                                    if not redundantColumns[(j[1])] then
                                        redundantColumns[(j[1])] = true
                                        imports.table.insert(__keyColumns, j)
                                        imports.table.insert(validateColumns, j[1])
                                    end
                                end
                                keyColumns = __keyColumns
                                if not dbify.mysql.column.areValid(tableName, validateColumns) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["columns_non-existent"], tableName)) end
                                for i = 1, imports.table.length(keyColumns), 1 do
                                    local j = keyColumns[i]
                                    imports.table.insert(queryArguments, j[1])
                                    imports.table.insert(queryArguments, imports.tostring(j[2]))
                                    queryString = queryString.." `??`=?"..(((i < imports.table.length(keyColumns)) and " AND") or "")
                                end
                            end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = result or false
                                resolve((result and isSoloFetch and result[1]) or result, cArgs)
                            end, dbify.mysql.instance, queryString, imports.table.unpack(queryArguments))
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    },

    column = {
        fetchList = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.fetchList(string: tableName)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName = dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = result or false
                                local __result = (result and {}) or result
                                if __result then
                                    local identifier = "column_name"
                                    for i = 1, #result, 1 do
                                        imports.table.insert(__result, result[i][identifier] or result[i][(imports.string.upper(identifier))])
                                    end
                                end
                                resolve(__result, cArgs)
                            end, dbify.mysql.instance, "SELECT `column_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=?", dbify.settings.credentials.database, tableName)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        isValid = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.isValid(string: tableName, string: columnName)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, columnName = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columnName or (imports.type(columnName) ~= "string") then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (imports.table.length(result) > 0)) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.instance, "SELECT `table_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=? AND `column_name`=?", dbify.settings.credentials.database, tableName, columnName)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        areValid = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.areValid(string: tableName, table: columns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, columns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columns or (imports.type(columns) ~= "table") or (imports.table.length(columns) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            local queryString, queryArguments = "SELECT `table_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=? AND (", {dbify.settings.credentials.database, tableName}
                            local __columns, redundantColumns = {}, {}
                            for i = 1, imports.table.length(columns), 1 do
                                columns[i] = imports.tostring(columns[i])
                                local j = columns[i]
                                if not redundantColumns[j] then
                                    redundantColumns[j] = true
                                    imports.table.insert(__columns, j)
                                end
                            end
                            columns = __columns
                            for i = 1, imports.table.length(columns), 1 do
                                local j = columns[i]
                                imports.table.insert(queryArguments, j)
                                queryString = queryString..(((i > 1) and " ") or "").."`column_name`=?"..(((i < imports.table.length(columns)) and " OR") or "")
                            end
                            queryString = queryString..")"
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = ((result and (imports.table.length(result) >= imports.table.length(columns))) and true) or false
                                resolve(result, cArgs)
                            end, dbify.mysql.instance, queryString, imports.table.unpack(queryArguments))
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        delete = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.column.delete(string: tableName, table: columns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, columns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not columns or (imports.type(columns) ~= "table") or (imports.table.length(columns) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            if not dbify.mysql.column.areValid(tableName, columns) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["columns_non-existent"], tableName)) end
                            local queryString, queryArguments = "ALTER TABLE `??`", {tableName}
                            local redundantColumns = {}
                            local __columns, redundantColumns = {}, {}
                            for i = 1, imports.table.length(columns), 1 do
                                columns[i] = imports.tostring(columns[i])
                                local j = columns[i]
                                if not redundantColumns[j] then
                                    redundantColumns[j] = true
                                    imports.table.insert(__columns, j)
                                end
                            end
                            columns = __columns
                            for i = 1, imports.table.length(columns), 1 do
                                local j = columns[i]
                                imports.table.insert(queryArguments, j)
                                queryString = queryString.." DROP COLUMN `??`"..(((i < imports.table.length(columns)) and ", ") or "")
                            end
                            resolve(imports.dbExec(dbify.mysql.instance, queryString, imports.table.unpack(queryArguments)), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    },

    data = {
        set = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.data.set(string: tableName, table: dataColumns, table: keyColumns)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, dataColumns, keyColumns = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (imports.table.length(dataColumns) <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (imports.table.length(keyColumns) <= 0) then return false end
                            local queryStrings, queryArguments = {"UPDATE `??` SET", " WHERE"}, {tableName}
                            local __keyColumns, validateColumns, redundantColumns = {}, {}, {}
                            for i = 1, imports.table.length(keyColumns), 1 do
                                local j = keyColumns[i]
                                j[1] = imports.tostring(j[1])
                                if not redundantColumns[(j[1])] then
                                    redundantColumns[(j[1])] = true
                                    imports.table.insert(__keyColumns, j)
                                    imports.table.insert(validateColumns, j[1])
                                end
                            end
                            keyColumns = __keyColumns
                            if not dbify.mysql.column.areValid(tableName, validateColumns) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["columns_non-existent"], tableName)) end
                            for i = 1, imports.table.length(keyColumns), 1 do
                                local j = keyColumns[i]
                                imports.table.insert(queryArguments, j[1])
                                imports.table.insert(queryArguments, imports.tostring(j[2]))
                                queryStrings[2] = queryStrings[2].." `??`=?"..(((i < imports.table.length(keyColumns)) and " AND") or "")
                            end
                            local queryLength = imports.table.length(queryArguments) - 1
                            for i = 1, imports.table.length(dataColumns), 1 do
                                local j = dataColumns[i]
                                j[1] = imports.tostring(j[1])
                                imports.table.insert(queryArguments, imports.table.length(queryArguments) - queryLength + 1, j[1])
                                imports.table.insert(queryArguments, imports.table.length(queryArguments) - queryLength + 1, imports.tostring(j[2]))
                                queryStrings[1] = queryStrings[1].." `??`=?"..(((i < imports.table.length(dataColumns)) and ",") or "")
                                local isValid = dbify.mysql.column.isValid(tableName, j[1])
                                if not isValid then
                                    imports.dbExec(dbify.mysql.instance, "ALTER TABLE `??` ADD COLUMN `??` MEDIUMTEXT", tableName, j[1])
                                end
                            end
                            resolve(imports.dbExec(dbify.mysql.instance, queryStrings[1]..queryStrings[2], imports.table.unpack(queryArguments)), cArgs)
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end,

        get = function(...)
            local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
            if not cPromise then return false end
            local syntaxMsg = "dbify.mysql.data.get(string: tableName, table: dataColumns, table: keyColumns, bool: isSoloFetch)"
            return try({
                exec = function(self)
                    return self:await(
                        imports.assetify.thread:createPromise(function(resolve, reject)
                            if not dbify.mysql.util.isConnected(reject) then return end
                            local tableName, dataColumns, keyColumns, isSoloFetch = dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs), dbify.mysql.util.fetchArg(_, cArgs)
                            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (imports.table.length(dataColumns) <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (imports.table.length(keyColumns) <= 0) then return false end
                            isSoloFetch = (isSoloFetch and true) or false
                            if not dbify.mysql.table.isValid(tableName) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["table_non-existent"], tableName)) end
                            local queryString, queryArguments = "SELECT", {}
                            local __keyColumns, __dataColumns, validateColumns, redundantColumns = {}, {}, {}, {}
                            for i = 1, imports.table.length(keyColumns), 1 do
                                local j = keyColumns[i]
                                j[1] = imports.tostring(j[1])
                                if not redundantColumns[(j[1])] then
                                    redundantColumns[(j[1])] = true
                                    imports.table.insert(__keyColumns, j)
                                    imports.table.insert(validateColumns, j[1])
                                end
                            end
                            keyColumns, redundantColumns = __keyColumns, {}
                            for i = 1, imports.table.length(dataColumns), 1 do
                                dataColumns[i] = imports.tostring(dataColumns[i])
                                local j = dataColumns[i]
                                if not redundantColumns[j] then
                                    redundantColumns[j] = true
                                    imports.table.insert(__dataColumns, j)
                                    imports.table.insert(validateColumns, j)
                                end
                            end
                            dataColumns = __dataColumns
                            if not dbify.mysql.column.areValid(tableName, validateColumns) then return dbify.mysql.util.throwError(reject, imports.string.format(dbify.mysql.error["columns_non-existent"], tableName)) end
                            for i = 1, imports.table.length(dataColumns), 1 do
                                local j = dataColumns[i]
                                imports.table.insert(queryArguments, j)
                                queryString = queryString.." `??`"..(((i < imports.table.length(dataColumns)) and ",") or "")
                            end
                            imports.table.insert(queryArguments, tableName)
                            queryString = queryString.." FROM `??` WHERE"
                            for i = 1, imports.table.length(keyColumns), 1 do
                                local j = keyColumns[i]
                                imports.table.insert(queryArguments, imports.tostring(j[1]))
                                imports.table.insert(queryArguments, imports.tostring(j[2]))
                                queryString = queryString.." `??`=?"..(((i < imports.table.length(keyColumns)) and " AND") or "")
                            end
                            imports.dbQuery(function(queryHandler)
                                local result = imports.dbPoll(queryHandler, 0)
                                result = result or false
                                resolve((result and isSoloFetch and result[1]) or false, cArgs)
                            end, dbify.mysql.instance, queryString, imports.table.unpack(queryArguments))
                        end)
                    )
                end,
                catch = cPromise.reject
            })
        end
    }
}
