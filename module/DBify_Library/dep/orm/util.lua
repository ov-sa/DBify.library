-----------------
--[[ Imports ]]--
-----------------

loadstring(exports.assetify:import("threader"))()
local imports = {
    type = type,
    tonumber = tonumber,
    table = table,
    string = string,
    math = math,
    assetify = assetify
}


-------------------
--[[ ORM: Util ]]--
-------------------

dbify.mysql.util = {
    isConnected = function(reject)
        if not dbify.mysql.instance then
            dbify.mysql.util.throwError(reject, "Connection Dead")
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


--------------------
--[[ ORM: Error ]]--
--------------------

dbify.mysql.error = {
    ["table_non-existent"] = "Table: '%s' non-existent",
    ["columns_non-existent"] = "Table: '%s' doesn't contain enough specified column(s) to process the query"
}