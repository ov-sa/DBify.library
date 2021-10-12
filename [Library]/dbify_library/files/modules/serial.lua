----------------------------------------------------------------
--[[ Resource: DBify Library
     Files: modules: serial.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Serial Module ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    type = type,
    ipairs = ipairs,
    getElementsByType = getElementsByType,
    addEventHandler = addEventHandler,
    getPlayerSerial = getPlayerSerial,
    dbExec = dbExec
}


-------------------
--[[ Variables ]]--
-------------------

dbify["serial"] = {
    __connection__ = {
        table = "user_serials",
        keyColumn = "serial"
    },

    fetchAll = function(keyColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        return dbify.mysql.table.fetchContents(dbify.serial.__connection__.table, keyColumns, callback, ...)
    end,

    add = function(serial, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not serial or (imports.type(serial) ~= "string") then return false end
        return dbify.serial.getData(serial, {dbify.serial.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if not result then
                result = imports.dbExec(dbify.mysql.__connection__.instance, "INSERT INTO `??` (`??`) VALUES(?)", dbify.serial.__connection__.table, dbify.serial.__connection__.keyColumn, serial)
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(result, arguments)
                end
                return true
            end
            if callbackReference and (imports.type(callbackReference) == "function") then
                callbackReference(false, arguments)
            end
        end, ...)
    end,

    delete = function(serial, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not serial or (imports.type(serial) ~= "string") then return false end
        return dbify.serial.getData(serial, {dbify.serial.__connection__.keyColumn}, function(result, arguments)
            local callbackReference = callback
            if result then
                result = imports.dbExec(dbify.mysql.__connection__.instance, "DELETE FROM `??` WHERE `??`=?", dbify.serial.__connection__.table, dbify.serial.__connection__.keyColumn, serial)
                if callbackReference and (imports.type(callbackReference) == "function") then
                    callbackReference(result, arguments)
                end
                return true
            end
            if callbackReference and (imports.type(callbackReference) == "function") then
                callbackReference(false, arguments)
            end
        end, ...)
    end,

    setData = function(serial, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not serial or (imports.type(serial) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.set(dbify.serial.__connection__.table, dataColumns, {
            {dbify.serial.__connection__.keyColumn, serial}
        }, callback, ...)
    end,

    getData = function(serial, dataColumns, callback, ...)
        if not dbify.mysql.__connection__.instance then return false end
        if not serial or (imports.type(serial) ~= "string") or not dataColumns or (imports.type(dataColumns) ~= "table") or (#dataColumns <= 0) then return false end
        return dbify.mysql.data.get(dbify.serial.__connection__.table, dataColumns, {
            {dbify.serial.__connection__.keyColumn, serial}
        }, true, callback, ...)
    end
}


-----------------------------------------------
--[[ Events: On Resource-Start/Player-Join ]]--
-----------------------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function()

    if not dbify.mysql.__connection__.instance then return false end
    imports.dbExec(dbify.mysql.__connection__.instance, "CREATE TABLE IF NOT EXISTS `??` (`??` VARCHAR(100) PRIMARY KEY)", dbify.serial.__connection__.table, dbify.serial.__connection__.keyColumn)
    if dbify.serial.__connection__.autoSync then
        for i, j in imports.ipairs(imports.getElementsByType("player")) do
            local playerSerial = imports.getPlayerSerial(j)
            dbify.serial.add(playerSerial)
        end
    end

end)

imports.addEventHandler("onPlayerJoin", root, function(_, playerSerial)

    if not dbify.mysql.__connection__.instance then return false end
    if dbify.serial.__connection__.autoSync then
        local playerSerial = imports.getPlayerSerial(source)
        dbify.serial.add(playerSerial)
    end

end)