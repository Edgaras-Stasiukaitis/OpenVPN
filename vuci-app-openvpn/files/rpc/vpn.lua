local os = require "os"
local uci = require "uci"

local M = {}

function M.delete_files(params)
    local c = uci.cursor()
    for _, v in pairs(params) do
        if v.secret ~= nil then os.remove(v.secret) end
        c:delete("openvpn", v._name, "secret")
        if v.ca ~= nil then os.remove(v.ca) end
        c:delete("openvpn", v._name, "ca")
        if v.cert ~= nil then os.remove(v.cert) end
        c:delete("openvpn", v._name, "cert")
        if v.key ~= nil then os.remove(v.key) end
        c:delete("openvpn", v._name, "key")
        if v.dh ~= nil then os.remove(v.dh) end
        c:delete("openvpn", v._name, "dh")
    end
    c:commit("openvpn")
    return { status = true, message = "Certificates removed" }
end

return M
