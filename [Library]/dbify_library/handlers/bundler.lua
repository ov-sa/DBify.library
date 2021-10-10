----------------------------------------------------------------
--[[ Resource: DBify Library
     Script: handlers: bundler.lua
     Server: -
     Author: OvileAmriam
     Developer: Aviril
     DOC: 09/10/2021 (OvileAmriam)
     Desc: Bundler Handler ]]--
----------------------------------------------------------------


-----------------
--[[ Imports ]]--
-----------------

local imports = {
    tostring = tostring,
    resourceName = getResourceName(getThisResource()),
    addEventHandler = addEventHandler,
    fetchFileData = fetchFileData,
    dbConnect = dbConnect,
    table = {
        insert = table.insert
    }
}


-------------------
--[[ Variables ]]--
-------------------

local bundlerData = false


---------------------------------------------
--[[ Functions: Fetches Imports/Database ]]--
---------------------------------------------

function fetchImports(recieveData)

    if not bundlerData then return false end

    if recieveData == true then
        return bundlerData
    else
        return [[
        for i, j in ipairs(call(getResourceFromName("]]..imports.resourceName..[["), "fetchImports", true)) do
            loadstring(j)()
        end
        ]]
    end

end

function fetchDatabase()

    return dbSettings.instance
    
end


-----------------------------------------
--[[ Event: On Client Resource Start ]]--
-----------------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function(resourceSource)

    dbSettings.instance = imports.dbConnect("mysql", "dbname="..dbSettings.database..";host="..dbSettings.host..";port="..dbSettings.port..";charset=utf8;", dbSettings.username, dbSettings.password, dbSettings.options) or false

    local importedModules = {
        bundler = [[
            dbify = {}
        ]],
        modules = {
            mysql = imports.fetchFileData("files/modules/mysql.lua")..[[
                imports.resource = getResourceFromName("]]..imports.resourceName..[[")
                dbify.mysql.__connection__.databaseName = "]]..dbSettings.database..[["
                dbify.mysql.__connection__.instance()
            ]],
            account = imports.fetchFileData("files/modules/account.lua")..[[
                dbify.account.__connection__.autoSync = ]]..imports.tostring(syncSettings.syncAccounts)..[[
            ]]
        }
    }

    bundlerData = {}
    imports.table.insert(bundlerData, importedModules.bundler)
    imports.table.insert(bundlerData, importedModules.modules.mysql)
    imports.table.insert(bundlerData, importedModules.modules.account)

end)