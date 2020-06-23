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

struct Prefix
    symbol::String
    color
end

PREFIXES = Dict(
    "OPEN" => Prefix("[+]", :green),
    "CLOSED" => Prefix("[x]", :red),
    "FILTERED" => Prefix("[-]", :yellow)
)

function get_banner(socket)
    try
        @async (sleep(0.5); close(socket))
        banner = String(readuntil(socket, 0x0d))
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
    sleep(1.5)
    return PortResult("FILTERED", nothing)
end

function scan_ports(target::Host, start::Int, finish::Int, only_open::Bool)
    openPorts = Dict{Int64,PortResult}()
    open_count = 0
    closed_count = 0
    filtered_count = 0
    start_time = time()
    @printf("PORT   STATUS          BANNER\n")
    for port = start:finish
        c = Channel(2)
        @async put!(c, connect_and_grab_banner(target, port))
        @async put!(c, timeout())
        result = take!(c)
        if result.status == "OPEN"
            open_count += 1
            push!(openPorts, port => result)
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
        prefix_buffer = IOBuffer();
        prefix = PREFIXES[result.status]
        printstyled(IOContext(prefix_buffer, :color => true), prefix.symbol, color=prefix.color)
        @printf("%-5d  %s %-8s    %s\n", port, String(take!(prefix_buffer)), result.status, result.banner)
    end
    elapsed_time = time() - start_time
    if (open_count + closed_count + filtered_count) == 0
        print("Looks like the host is down :(\n\n")
        exit(0)
    end
    print("\nTCP port scanning complete!\n")
    print("$open_count open ports, $closed_count closed and $filtered_count filtered\n")
    println("\nFinished in $elapsed_time seconds")
    return openPorts
end
