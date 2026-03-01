local net = require("@lune/net")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

-- HTTP Method Enums
local Methods = {
    POST = "POST",
    GET = "GET",
    PUT = "PUT",
    UPDATE = "UPDATE",
    DELETE = "DELETE"
}

export type Headers = {
    ["Content-Type"]: "application/json" | "application/x-www-form-urlencoded" | "text/plain" | string,
}

-- Params Types
export type AuraRequest = {
    url: string?,
    method: string?,
    body: any?,
    headers: Headers?,
    query: { [string]: string }?,
    options: { [string]: any }?
}

export type AuraResponse = {
    ok: boolean,
    status: number,
    statusMessage: string,
    headers: { [string]: string },
    body: any,
    time: number
}

local Aura = {}

function Aura.get(config: AuraRequest): AuraResponse
    assert(config.url, "Url not found")
    assert(typeof(config.url) == "string", "Url must be string")
    
    local displayUrl = config.url
    
    if config.headers and config.headers["Content-Type"] and not (typeof(config.headers["Content-Type"]) == "string") then
        error("Content-Type of Headers has to be string", 2)
    end

    local finalConfig = { 
        url = string.gsub(config.url, "://localhost", "://127.0.0.1"),
        method = config.method or Methods.GET,
        headers = config.headers or { ["Content-Type"] = "application/json" },
        body = if config.body and typeof(config.body) == "table" then serde.encode("json", config.body) else config.body or "",
        query = config.query,
        options = config.options
    } :: AuraRequest

    local startTime = os.clock()
    local response = net.request(finalConfig)
    local endTime = os.clock()
    
    local duration = endTime - startTime

    local success, decodedBody = pcall(function()
        return serde.decode("json", response.body)
    end)

    local finalResponse: AuraResponse = {
        ok = response.ok,
        status = response.statusCode,
        statusMessage = response.statusMessage,
        headers = response.headers,
        body = if success then decodedBody else response.body,
        time = duration
    }

    if not finalResponse.ok then
        local color = stdio.color(if finalResponse.status >= 400 then "red" elseif finalResponse.status >= 300 then "blue" else "green")
        local reset = stdio.color("reset")
        
        local beautyError = string.format(
            "%s" ..
            " Aura Request got an issue:\n" ..
            "\n" ..
            " Status : %d (%s)\n" ..
            " Method : %s\n" ..
            " URL    : %s\n" ..
            " Time   : %.4f seconds\n" ..
            "\n" ..
            "%s",
            color,
            finalResponse.status, 
            finalResponse.statusMessage or "Unknown", 
            finalConfig.method or "GET", 
            displayUrl, 
            duration,
            reset
        )

        warn(beautyError)
    end

    return finalResponse
end

function Aura.post(config: AuraRequest): AuraResponse
    config.method = Methods.POST
    return Aura.get(config)
end

function Aura.put(config: AuraRequest): AuraResponse
    config.method = Methods.PUT
    return Aura.get(config)
end

function Aura.update(config: AuraRequest): AuraResponse
    config.method = Methods.UPDATE
    return Aura.get(config)
end

function Aura.delete(config: AuraRequest): AuraResponse
    config.method = Methods.DELETE
    return Aura.get(config)
end

return Aura