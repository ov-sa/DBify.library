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
    type = type,
    ipairs = ipairs,
    tostring = tostring,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    string = {
        lower = string.lower,
        upper = string.upper
    }
}


-------------------
--[[ Variables ]]--
-------------------

dbify["db"] = {
    table = {
        isValid = function(tableName, callback, ...)
            if not dbify.db.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not callback or (imports.type(callback) ~= "function") then return false end
            imports.dbQuery(function(query, tableName, arguments)
                local callbackReference = callback
                local result = imports.dbPoll(query, 0)
                if result and #result > 0 then
                    for i, j in imports.ipairs(result) do
                        if (tableName == j[imports.string.lower("TABLE_NAME")]) or (tableName == j[imports.string.upper("TABLE_NAME")]) then
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
            end, {tableName, {...}}, dbify.db.instance, "SELECT `table_name` FROM information_schema.tables WHERE `table_schema`=?", dbSettings.database)
            return true
        end
    },

    column = {
        isValid = function(tableName, columnName, callback, ...)
            if not dbify.db.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not columnName or (imports.type(columnName) ~= "string") or not callback or (imports.type(callback) ~= "function") then return false end
            dbify.table.isValid(tableName, function(isValid, arguments)
                if isValid then
                    imports.dbQuery(function(query, columnName, arguments)
                        local callbackReference = callback
                        local result = imports.dbPoll(query, 0)
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
                    end, {columnName, arguments}, dbify.db.instance, "DESCRIBE `??`", tableName)
                end
            end, ...)
            return true
        end        
    },

    data = {
        set = function(tableName, dataColumns, keyColumns, callback, ...)
            if not dbify.db.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) then return false end
            local dataColumnQuery, keyColumnQuery = "", ""
            for i, j in imports.ipairs(keyColumns) do
                keyColumnQuery = keyColumnQuery..(((i <= 1) and "`") or " AND `")..imports.tostring(j[1]).."`="..imports.tostring(j[2])
            end
            for i, j in imports.ipairs(dataColumns) do
                j[1] = imports.tostring(j[1])
                dataColumnQuery = dataColumnQuery..(((i <= 1) and "`") or " AND `")..j[1].."`="..imports.tostring(j[2])
                dbify.column.isValid(tableName, j[1], function(isValid, arguments)
                    local callbackReference = callback
                    if not isValid then
                        imports.dbExec(dbify.db.instance, "ALTER TABLE `??` ADD COLUMN `??` TEXT", arguments[1], arguments[2])
                    end
                    if arguments[3] then
                        local result = imports.dbExec(dbify.db.instance, "UPDATE `??` SET ?? WHERE ??", tableName, arguments[3].dataColumnQuery, arguments[3].keyColumnQuery)
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
            if not dbify.db.instance then return false end
            if not tableName or (imports.type(tableName) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) or not keyColumns or (imports.type(keyColumns) ~= "table") or (#keyColumns <= 0) or not callback or (imports.type(callback) ~= "function") then return false end
            soloFetch = (soloFetch and true) or false
            local dataColumnQuery, keyColumnQuery = "", ""
            for i, j in imports.ipairs(dataColumns) do
                dataColumnQuery = dataColumnQuery.."`"..imports.tostring(j)..(((i < #dataColumns) and "`, ") or "`")
            end
            for i, j in imports.ipairs(keyColumns) do
                keyColumnQuery = keyColumnQuery..(((i <= 1) and "`") or " AND `")..imports.tostring(j[1]).."`="..imports.tostring(j[2])
            end
            imports.dbQuery(function(query, soloFetch, arguments)
                local callbackReference = callback
                local result = imports.dbPoll(query, 0)
                if result and #result > 0 then
                    if callbackReference and (imports.type(callbackReference) == "function") then
                        callbackReference((soloFetch and result[1]) or result, arguments)
                    end
                    return true
                end
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(false, arguments)
                end
            end, {soloFetch, {...}}, dbify.db.instance, "SELECT ?? FROM `??` WHERE ??", dataColumnQuery, tableName, keyColumnQuery)
            return true
        end
    }
}