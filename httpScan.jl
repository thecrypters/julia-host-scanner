import HTTP

function scan_http_target(target, port)
    try
        protocol = "http"
        if port == 443
            protocol = "https"
        end
        request = HTTP.request("GET", "$protocol://$target:$port")
        return request
    catch e
        return nothing
    end
end

function http_scan(target, openPorts)
    http_connection = nothing
    if http_connection === nothing && openPorts[80] !== nothing
        http_connection = scan_http_target(target, 80)
        print("\nFound HTTP server on $target\n")
    end
    if http_connection === nothing && openPorts[443] !== nothing
        http_connection = scan_http_target(target, 443)
        print("\nFound HTTPS server on $target\n")
    end
    if http_connection === nothing
        print("\nNo HTTP or HTTPS server found, skipping HTTP scan...\n")
    end
    return http_connection
end

function get_server(http_connection)
    if http_connection !== nothing
        try
            return Dict(http_connection.headers)["Server"]
        catch e
            return "None"
        end
    end
    return "None"
end
