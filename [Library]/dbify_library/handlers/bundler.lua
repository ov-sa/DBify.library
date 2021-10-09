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
    addEventHandler = addEventHandler,
    getResourceName = getResourceName,
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

function fetchImports()

    if not bundlerData then return false end

    return bundlerData

end

function fetchDatabase()

    return dbSettings.instance
    
end


-----------------------------------------
--[[ Event: On Client Resource Start ]]--
-----------------------------------------

imports.addEventHandler("onResourceStart", resourceRoot, function(resourceSource)

    dbSettings.instance = imports.dbConnect("mysql", "dbname="..dbSettings.database..";host="..dbSettings.host..";port="..dbSettings.port..";charset=utf8;", dbSettings.username, dbSettings.password, dbSettings.options) or false
    
    local resourceName = imports.getResourceName(resourceSource)
    local importedModules = {
        bundler = [[
            local imports = {
                call = call
            }

            dbify = {}
        ]],
        modules = {
            mysql = imports.fetchFileData("files/modules/mysql.lua")..[[
                dbify.db.instance = {
                    instance = function()
                        dbify.db.instance = exports.]]..resourceName..[[:fetchDatabase()
                    end
                end
                dbify.db.instance()
            ]]
        }
    }

    bundlerData = {}
    imports.table.insert(bundlerData, importedModules.bundler)
    imports.table.insert(bundlerData, importedModules.modules.mysql)

end)