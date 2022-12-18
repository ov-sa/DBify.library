-----------------
--[[ Imports ]]--
-----------------

loadstring(exports.assetify:import("threader"))()
local imports = {
    type = type,
    pairs = pairs,
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
    keyTypes = {
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
    },

    errorTypes = {
        ["table_existent"] = "Table: '%s' already exists",
        ["table_non-existent"] = "Table: '%s' non-existent",
        ["tables_non-existent"] = "Database: '%s' doesn't contain enough specified tables(s) to process the query",
        ["columns_non-existent"] = "Table: '%s' doesn't contain enough specified column(s) to process the query"
    },
    
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
        return cThread, imports.table.pack(...)
    end,

    parseStructure = function(structure)
        if not structure or (imports.type(structure) ~= "table") or (imports.table.length(structure) <= 0) then return false end
        local __structure, redundantColumns = {}, {}
        for i = 1, imports.table.length(structure), 1 do
            local j = structure[i]
            j[1] = imports.tostring(j[1])
            if not redundantColumns[(j[1])] then
                redundantColumns[(j[1])] = true
                j[2] = imports.string.upper(imports.tostring(j[2]))
                local matchedIndex = (imports.string.find(j[2], ",") or (#j[2] + 1)) - 1
                j[2] = imports.string.sub(j[2], 0, matchedIndex)
                j.__TMP = {}
                for k, v in imports.pairs(dbify.mysql.util.keyTypes) do
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
                imports.table.insert(__structure, j)
                if imports.string.find(j[2], "PRIMARY KEY") then
                    if __structure.key then return false end
                    j.__TMP.isNotNull = true
                    __structure.key = imports.table.length(__structure)
                end
            end
        end
        structure = __structure
        return (structure and structure.key and (imports.table.length(structure) > 0) and structure) or false
    end,

    throwError = function(reject, errorMsg)
        if not errorMsg or (imports.type(errorMsg) ~= "string") then return false end
        return execFunction(reject, "DBify: Error ━│  "..errorMsg)
    end
}
