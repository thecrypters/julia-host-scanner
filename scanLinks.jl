import HTTP
import EzXML
using Suppressor

function get_complete_link(root_url, current_url, link)
    # Complete link, good to go
    if occursin(root_url, link)
        return link
    end
    # Relative link
    if startswith(link, "/")
        return "$current_url$link"
    end
    # External link, discard
    return nothing
end

function grab_links(root_url, current_url, current_depth, max_depth)
    if current_depth > max_depth
        return true
    end
    request = nothing
    try
        request = HTTP.request("GET", "$root_url$current_url")
    catch e
        # Skip, link not acessible
        return true
    end
    body = request.body
    html_obj = EzXML.parsehtml(body)
    nodes = EzXML.findall("//a/@href", html_obj)
    if length(nodes) === 0
        return true
    end
    for node in nodes
        link = EzXML.nodecontent(node)
        complete_link = get_complete_link(root_url, current_url, link)
        if complete_link !== nothing
            if (current_depth > 1)
                pad = repeat(' ', current_depth * 2)
                print("$pad └ ")
            end
            print("$link\n")
            grab_links(root_url, complete_link, current_depth + 1, max_depth)
        end
    end
end

function scan_links(url, max_depth=2)
    print("\nGetting links from $url, with depth $max_depth:\n")
    @suppress_err grab_links(url, "", 1, max_depth)
end
