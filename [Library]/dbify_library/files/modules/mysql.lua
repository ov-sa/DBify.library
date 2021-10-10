----------------------------------------------------------------
--[[ Resource: DBify Library
     Files: modules: mysql.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Mysql Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    call = call,
    type = type,
    unpack = unpack,
    ipairs = ipairs,
    tostring = tostring,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    table = {
        insert = table.insert
    },
    string = {
        lower = string.lower,
        upper = string.upper
    }
}


-------------------
--[[ Variables ]]--
-------------------

dbify["db"] = {
    __connection__ = {
        instance = function()
            dbify.db.__connection__.instance = imports.call(imports.resource, "fetchDatabase")
        end
    },

    table = {
        isValid = function(tableName, callback, ...)
            if not dbify.db.__connection__.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not callback or (imports.type(callback) ~= "function") then return false end
            imports.dbQuery(function(queryHandler, tableName, arguments)
                local callbackReference = callback
                local result = imports.dbPoll(queryHandler, 0)
                if result and #result > 0 then
                    callbackReference(true, arguments)
                    return true
                end
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(false, arguments)
                end
            end, {tableName, {...}}, dbify.db.__connection__.instance, "SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=? AND `table_name`=?", dbify.db.__connection__.databaseName, tableName)
            return true
        end
    },

    column = {
        isValid = function(tableName, columnName, callback, ...)
            if not dbify.db.__connection__.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not columnName or (imports.type(columnName) ~= "string") or not callback or (imports.type(callback) ~= "function") then return false end
            dbify.db.table.isValid(tableName, function(isValid, arguments)
                if isValid then
                    imports.dbQuery(function(queryHandler, columnName, arguments)
                        local callbackReference = callback
                        local result = imports.dbPoll(queryHandler, 0)
                        if result and #result > 0 then
                            for i, j in imports.ipairs(result) do
                                if j.Field and (imports.string.lower(columnName) == imports.string.lower(j.Field)) then
                                    if callbackReference and (imports.type(callbackReference) == "function") then
                                        callbackReference(true, arguments)
                                    end
                                    return true
                                end
                            end
                        end
                        if callbackReference and (imports.type(callbackReference) == "function") then
                            callbackReference(false, arguments)
                        end
                    end, {columnName, arguments}, dbify.db.__connection__.instance, "DESCRIBE `??`", tableName)
                end
            end, ...)
            return true
        end        
    },

    data = {
        set = function(tableName, dataColumns, keyColumns, callback, ...)
            if not dbify.db.__connection__.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) then return false end
            local dataColumnQuery, keyColumnQuery = "", ""
            for i, j in imports.ipairs(keyColumns) do
                keyColumnQuery = keyColumnQuery..(((i <= 1) and "`") or " AND `")..imports.tostring(j[1]).."`="..imports.tostring(j[2])
            end
            for i, j in imports.ipairs(dataColumns) do
                j[1] = imports.tostring(j[1])
                dataColumnQuery = dataColumnQuery..(((i <= 1) and "`") or " AND `")..j[1].."`="..imports.tostring(j[2])
                dbify.db.column.isValid(tableName, j[1], function(isValid, arguments)
                    local callbackReference = callback
                    if not isValid then
                        imports.dbExec(dbify.db.__connection__.instance, "ALTER TABLE `??` ADD COLUMN `??` TEXT", arguments[1], arguments[2])
                    end
                    if arguments[3] then
                        local result = imports.dbExec(dbify.db.__connection__.instance, "UPDATE `??` SET ?? WHERE ??", arguments[1], arguments[3].dataColumnQuery, arguments[3].keyColumnQuery)
                        if callbackReference and (imports.type(callbackReference) == "function") then
                            callbackReference(result, arguments[4])
                        end
                    end
                end, tableName, j[1], ((i >= #dataColumns) and {
                    dataColumnQuery = dataColumnQuery,
                    keyColumnQuery = keyColumnQuery
                }) or false, ((i >= #dataColumns) and {...}) or false)
            end
            return true
        end,

        get = function(tableName, dataColumns, keyColumns, soloFetch, callback, ...)
            if not dbify.db.__connection__.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) or not callback or (imports.type(callback) ~= "function") then return false end
            soloFetch = (soloFetch and true) or false
            local queryString, queryArguments = "SELECT", {}
            for i, j in imports.ipairs(dataColumns) do
                imports.table.insert(queryArguments, imports.tostring(j))
                queryString = queryString.." `??`"..(((i < #dataColumns) and ",") or "")
            end
            queryString = queryString.." FROM `??` WHERE"
            imports.table.insert(queryArguments, tableName)
            for i, j in imports.ipairs(keyColumns) do
                imports.table.insert(queryArguments, tostring(j[1]))
                imports.table.insert(queryArguments, tostring(j[2]))
                queryString = queryString.." `??`=?"..(((i < #keyColumns) and " AND") or "")
            end
            imports.dbQuery(function(queryHandler, soloFetch, arguments)
                local callbackReference = callback
                local result = imports.dbPoll(queryHandler, 0)
                if result and #result > 0 then
                    if callbackReference and (imports.type(callbackReference) == "function") then
                        callbackReference((soloFetch and result[1]) or result, arguments)
                    end
                    return true
                end
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(false, arguments)
                end
            end, {soloFetch, {...}}, dbify.db.__connection__.instance, queryString, imports.unpack(queryArguments))
            return true
        end
    }
}