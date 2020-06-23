import HTTP

function scan_http_target(target, port)
    try
        protocol = "http"
        if port == 443
            protocol = "https"
        end
        url = "$protocol://$target:$port"
        request = HTTP.request("GET", url)
        return request, url
    catch e
        return nothing, nothing
    end
end

function http_scan(target, openPorts)
    http_connection = nothing
    url = nothing
    if http_connection === nothing && openPorts[80] !== nothing
        http_connection, url = scan_http_target(target, 80)
        print("\nFound HTTP server on $target\n")
    end
    if http_connection === nothing && openPorts[443] !== nothing
        http_connection, url = scan_http_target(target, 443)
        print("\nFound HTTPS server on $target\n")
    end
    if http_connection === nothing
        print("\nNo HTTP or HTTPS server found, skipping HTTP scan...\n")
    end
    return http_connection, url
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
