-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    pairs = pairs,
    tonumber = tonumber,
    tostring = tostring,
    addEventHandler = addEventHandler,
    dbQuery = dbQuery,
    dbPoll = dbPoll,
    dbExec = dbExec,
    table = table,
    string = string,
    table = table,
    math = math,
    assetify = assetify
}


---------------------------
--[[ Module: Inventory ]]--
---------------------------

local cModule = dbify.createModule({
    moduleName = "inventory",
    tableName = "dbify_inventories",
    structure = {
        {"id", "BIGINT AUTO_INCREMENT PRIMARY KEY"}
    }
})

local cItem = nil
cItem = {
    __TMP = {
        property = { amount = 0 },
        data = {}
    }
    
    modifyItemCount = function(syntaxMsg, action, ...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifier, items = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
                        if not identifer or (imports.type(identifer) ~= cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type) or not items or (imports.type(items) ~= "table") or (imports.table.length(items) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        items = imports.table.clone(items, true)
                        local itemDatas = {}
                        for i = 1, imports.table.length(items), 1 do
                            local j = items[i]
                            j[1] = "item_"..imports.tostring(j)
                            j[2] = imports.math.max(0, imports.tonumber(j[2]) or 0)
                            imports.table.insert(itemDatas, j[1])
                        end
                        itemDatas = cModule.getData(identifier, itemDatas)
                        if not itemDatas then return resolve(itemDatas, cArgs) end
                        for i = 1, imports.table.length(items) do
                            local j = items[i]
                            local itemData = (itemDatas[(j[1])] and imports.table.decode(itemDatas[(j[1])])) or false
                            itemData = (itemData and itemData.data and (imports.type(itemData.data) == "table") and itemData.item and (imports.type(itemData.item) == "table") and itemData) or false
                            itemData = itemData or imports.table.clone(cItem.__TMP, true)
                            itemData.property.amount = (imports.math.max(0, imports.tonumber(itemData.property.amount) or 0)*((action == "push" and 1) or -1)) + j[2]
                            itemData = imports.table.encode(itemData)
                            j[2] = itemData
                        end
                        resolve(cModule.setData(identifer, items), cArgs)
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    modifyItemProperty = function(syntaxMsg, action, ...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifier, items, properties = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
                        if not identifier or (imports.type(identifier) ~= cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type) or not items or (imports.type(items) ~= "table") or (imports.table.length(items) <= 0) or not properties or (imports.type(properties) ~= "table") or (imports.table.length(properties) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        items = imports.table.clone(items, true)
                        for i = 1, imports.table.length(items), 1 do
                            items[i] = "item_"..imports.tostring(items[i])
                        end
                        local itemDatas = cModule.getData(identifier, items)
                        if not itemDatas then return resolve(itemDatas, cArgs) end
                        local __itemDatas = {}
                        for i, j in imports.pairs(itemDatas) do
                            j = (j and imports.table.decode(j)) or false
                            j = (j and j.data and (imports.type(j.data) == "table") and j.property and (imports.type(j.property) == "table") and j) or false
                            j = j or imports.table.clone(cItem.__TMP, true)
                            if action == "set" then
                                for k = 1, imports.table.length(properties), 1 do
                                    local v = properties[k]
                                    v[1] = imports.tostring(v[1])
                                    if v[1] == "amount" then v[2] = imports.math.max(0, imports.tonumber(v[2]) or j.property[(v[1])]) end
                                    j.property[(v[1])] = v[2]
                                end
                                imports.table.insert(__itemDatas, {i, imports.table.encode(j)})
                            else
                                i = imports.string.gsub(i, "item_", "", 1)
                                __itemDatas[i] = {}
                                for k = 1, imports.table.length(properties), 1 do
                                    properties[k] = imports.tostring(properties[k])
                                    local v = properties[k]
                                    __itemDatas[i][v] = j.property[v]
                                end
                            end
                        end
                        if action == "set" then resolve(cModule.setData(identifier, __itemDatas), cArgs)
                        else resolve(__itemDatas, cArgs) end
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end,

    modifyItemData = function(syntaxMsg, action, ...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end
        return try({
            exec = function(self)
                return self:await(
                    imports.assetify.thread:createPromise(function(resolve, reject)
                        local identifier, items, datas = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
                        if not identifier or (imports.type(identifier) ~= cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type) or not items or (imports.type(items) ~= "table") or (imports.table.length(items) <= 0) or not datas or (imports.type(datas) ~= "table") or (imports.table.length(datas) <= 0) then return dbify.mysql.util.throwError(reject, syntaxMsg) end
                        items = imports.table.clone(items, true)
                        for i = 1, imports.table.length(items), 1 do
                            items[i] = "item_"..imports.tostring(items[i])
                        end
                        local itemDatas = cModule.getData(identifier, items)
                        if not itemDatas then return resolve(itemDatas, cArgs) end
                        local __itemDatas = {}
                        for i, j in imports.pairs(itemDatas) do
                            j = (j and imports.table.decode(j)) or false
                            j = (j and j.data and (imports.type(j.data) == "table") and j.property and (imports.type(j.property) == "table") and j) or false
                            j = j or imports.table.clone(cItem.__TMP, true)
                            if action == "set" then
                                for k = 1, imports.table.length(datas), 1 do
                                    local v = datas[k]
                                    v[1] = imports.tostring(v[1])
                                    j.data[(v[1])] = v[2]
                                end
                                imports.table.insert(__itemDatas, {i, imports.table.encode(j)})
                            else
                                i = imports.string.gsub(i, "item_", "", 1)
                                __itemDatas[i] = {}
                                for k = 1, imports.table.length(datas), 1 do
                                    datas[k] = imports.tostring(datas[k])
                                    local v = datas[k]
                                    __itemDatas[i][v] = j.data[v]
                                end
                            end
                        end
                        if action == "set" then resolve(cModule.setData(identifier, __itemDatas), cArgs)
                        else resolve(__itemDatas, cArgs) end
                    end)
                )
            end,
            catch = cPromise.reject
        })
    end    
}


-----------------
--[[ Utility ]]--
-----------------


    cModule.ensureItems = function(...)
        local cPromise, cArgs = dbify.mysql.util.parseArgs(...)
        if not cPromise then return false end

        local promise = function()
            if not dbify.mysql.instance then return false end
            local items, callback = dbify.fetchArg(_, cArgs), dbify.fetchArg(_, cArgs)
            if not items or (imports.type(items) ~= "table") then return false end
            imports.dbQuery(function(queryHandler, cArgs)
                local result = imports.dbPoll(queryHandler, 0)
                local itemsToBeAdded, itemsToBeDeleted = {}, {}
                if result and (imports.table.length(result) > 0) then
                    for i = 1, imports.table.length(result), 1 do
                        local j = result[i]
                        local columnName = j["column_name"] or j[(string.upper("column_name"))]
                        local itemIndex = imports.string.gsub(columnName, "item_", "", 1)
                        if not cArgs[1].items[itemIndex] then
                            imports.table.insert(itemsToBeDeleted, columnName)
                        end
                    end
                end
                for i, j in imports.pairs(cArgs[1].items) do
                    imports.table.insert(itemsToBeAdded, "item_"..i)
                end
                cArgs[1].items = itemsToBeAdded
                if imports.table.length(itemsToBeDeleted) > 0 then
                    dbify.mysql.column.delete(cModule.__TMP.tableName, itemsToBeDeleted, function(result, cArgs)
                        if result then
                            for i = 1, imports.table.length(cArgs[1].items), 1 do
                                local j = cArgs[1].items[i]
                                dbify.mysql.column.isValid(cModule.__TMP.tableName, j, function(isValid, cArgs)
                                    if not isValid then
                                        imports.dbExec(dbify.mysql.instance, "ALTER TABLE `??` ADD COLUMN `??` TEXT", cModule.__TMP.tableName, cArgs[1])
                                    end
                                    if cArgs[2] then
                                        execFunction(callback, true, cArgs[2])
                                    end
                                end, j, ((i >= imports.table.length(cArgs[1].items)) and cArgs[2]) or false)
                            end
                        else
                            execFunction(callback, result, cArgs[2])
                        end
                    end, cArgs[1], cArgs[2])
                else
                    for i = 1, imports.table.length(cArgs[1].items), 1 do
                        local j = cArgs[1].items[i]
                        dbify.mysql.column.isValid(cModule.__TMP.tableName, j, function(isValid, cArgs)
                            if not isValid then
                                imports.dbExec(dbify.mysql.instance, "ALTER TABLE `??` ADD COLUMN `??` TEXT", cModule.__TMP.tableName, cArgs[1])
                            end
                            if cArgs[2] then
                                execFunction(callback, true, cArgs[2])
                            end
                        end, j, ((i >= imports.table.length(cArgs[1].items)) and cArgs[2]) or false)
                    end
                end
            end, {{{
                items = items
            }, cArgs}}, dbify.mysql.instance, "SELECT `column_name` FROM information_schema.columns WHERE `table_schema`=? AND `table_name`=? AND `column_name` LIKE 'item_%'", dbify.settings.credentials.database, cModule.__TMP.tableName)
            return true
        end
        if isAsync then promise(); return isAsync
        else return promise() end
    end

    cModule.item = {
        add = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.add("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..")"
            return cItem.modifyItemCount(syntaxMsg, "push", ...)
        end

        remove = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.remove("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..")"
            return cItem.modifyItemCount(syntaxMsg, "pop", ...)
        end,

        setProperty = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.setProperty("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..", table: items, table: properties)"
            return cItem.modifyItemProperty(syntaxMsg, "set", ...)
        end,

        getProperty = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.getProperty("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..", table: items, table: properties)"
            return cItem.modifyItemProperty(syntaxMsg, "get", ...)
        end,

        setData = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.setData("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..", table: items, table: datas)"
            return cItem.modifyItemProperty(syntaxMsg, "set", ...)
        end,

        getData = function(...)
            local syntaxMsg = "dbify.module[\""..(cModule.__TMP.moduleName).."\"].item.getData("..(cModule.__TMP.structure[(cModule.__TMP.structure.key)].__TMP.type)..": "..(cModule.__TMP.structure[(cModule.__TMP.structure.key)][1])..", table: items, table: datas)"
            return cItem.modifyItemProperty(syntaxMsg, "get", ...)
        end
    }