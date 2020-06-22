using DataStructures
using Sockets
using Printf

CLOSED_MSG = "ECONNREFUSED"
RESET_MSG = "ECONNRESET"

Host = Union{IPAddr,String}

Banner = Union{String,Nothing}

struct PortResult
    status::String
    banner::Banner
end

function print_results(start::Int, finish::Int, output::Dict{Int64,PortResult}, only_open::Bool)
    for i in start:finish
        value = output[i]
        if only_open && value.status != "OPEN"
            continue
        end
        @printf("Port %5d - %s\n", i, value.status)
    end
end

function get_banner(socket)
    try
        first = String(read(socket, 1))
        size = Int(socket.buffer.size)
        rest = String(read(socket, size - 1))
        banner = "$first$rest"
        replace(banner, "\r\n" => "")
        if banner === ""
            banner = "None"
        end
        return banner
    catch e
        return "None"
    end
end

function connect_and_grab_banner(target, port)
    try
        socket = Sockets.connect(target, port)
        banner = get_banner(socket)
        close(socket)
        return PortResult("OPEN", banner)
    catch e
        if isa(e, Base.IOError)
            # Closed port
            if occursin(CLOSED_MSG, e.msg)
                return PortResult("CLOSED", nothing)
            end
            # Filtered port
            if occursin(RESET_MSG, e.msg)
                return PortResult("FILTERED", nothing)
            end
        end
    end
end

function timeout()
    sleep(1)
    return PortResult("FILTERED", nothing)
end

function scan_ports(target::Host, start::Int, finish::Int, only_open::Bool)
    ports = Dict{Int64,PortResult}()
    open_count = 0
    closed_count = 0
    filtered_count = 0
    print("Running port scanning for $target\n\n")
    start_time = time()
    for port = start:finish
        c = Channel(2)
        @async put!(c, connect_and_grab_banner(target, port))
        @async put!(c, timeout())
        result = take!(c)
        if result.status == "OPEN"
            open_count += 1
        end
        if result.status == "CLOSED"
            closed_count += 1
        end
        if result.status == "FILTERED"
            filtered_count += 1
        end
        if only_open && result.status != "OPEN"
            continue
        end
        @printf("Port %5d - %s - BANNER: %s\n", port, result.status, result.banner)
    end
    elapsed_time = time() - start_time
    # if (open_count + closed_count + filtered_count) == 0
    #     print("Looks like the host is down :(\n\n")
    #     exit(0)
    # end
    print("TCP port scanning complete!\n")
    print("$open_count open ports, $closed_count closed and $filtered_count filtered\n")
    # print_results(start, finish, ports, only_open)
    println("\nFinished in $elapsed_time seconds")
end

connect_and_grab_banner("10.0.0.100", 25)
