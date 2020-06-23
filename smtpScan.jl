using Sockets

users = eachline("./smtp-users.txt")

function smtp_timeout()
    sleep(1.5)
    return nothing
end

function connect_smtp(target, port)
    try
        c = Channel(2)
        @async put!(c, connect(target, port))
        @async put!(c, smtp_timeout())
        socket = take!(c)
        if socket !== nothing
            # Read until carriage return
            connection_banner = String(readuntil(socket, 0x0d))
            # SMTP Connected
            if occursin("220", connection_banner)
                return socket
            end
            return nothing
        end
        return nothing
    catch e
        return nothing
    end
end

function vrfy(socket, name)
    write(socket, "VRFY $name \r\n")
    response = String(readuntil(socket, 0x0d))
    return occursin("252", response) && occursin(name, response)
end

function scan_smtp_target(target, port)
    connection = connect_smtp(target, port)
    if connection !== nothing
        print("Users found on $target SMTP server on port $port:\n")
        for user in users
            try
                if vrfy(connection, user)
                    println(user)
                end
            catch e
                if isa(e, Base.IOError)
                    # Connection reset by peer, retry...
                    if occursin("ECONNRESET", e.msg)
                        connection = connect_smtp(target, port)
                        if vrfy(connection, user)
                            println(user)
                        end
                    end
                end
            end
        end
        close(connection)
        return true
    end
    return false
end

function smtp_scan(target, openPorts)
    got_smtp_server = false
    if !got_smtp_server && openPorts[25] !== nothing
        got_smtp_server = scan_smtp_target(target, 25)
    end
    if !got_smtp_server && openPorts[465] !== nothing
        got_smtp_server = scan_smtp_target(target, 465)
    end
    if !got_smtp_server && openPorts[587] !== nothing
        got_smtp_server = scan_smtp_target(target, 587)
    end
    if !got_smtp_server
        print("\nNo SMTP server, skipping VRFY scan...\n")
    end
end
