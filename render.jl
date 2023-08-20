module Render
using Test

function remove_before_render(; shift=true)
    src_file = "figure.qmd"
    out_file = "figure_proc.qmd"

    remove_before_render(src_file, out_file)
end

function remove_before_render(src_file::AbstractString, out_file::AbstractString; shift=true)
    open(src_file, "r") do src; open(out_file, "w") do out
        remove_before_render(src, out; shift=shift)
    end; end
end

"""
    remove_before_render(src::IO, out::IO; shift=true)

Remove the following from `qmd` files.
```default
:::
REMOVE BEFORE RENDER
:::
```

If `shift=false`, three empty lines replace the above three lines.
"""
function remove_before_render(src::IO, out::IO; shift=true)
    for line in eachline(src)
        if line == ":::"
            line2 = readline(src)
            if line2 == "REMOVE BEFORE RENDER"
                readline(src) # read and ignore 3rd line
                if !shift
                    println(out)
                    println(out)
                    println(out)
                end
                continue
            else
                println(out, line)
                println(out, line2)
                continue
            end
        end
      
        println(out, line)
    end
end


function render()
    #cerr = devnull #IOBuffer()
    #cout = devnull #IOBuffer()
    cmd = `quarto render`
    proc = run(pipeline(cmd, stdout=stdout, stderr=stderr), wait=true)
end

function test()
    ## no remove
    src_text = """
    Text ...
    :::
    :::
    """
    out_text = src_text
    src = Base.BufferStream(); write(src, src_text); closewrite(src); 
    out = IOBuffer()
    remove_before_render(src,out)
    @test String(take!(out)) == out_text
    
    ## remove
    src_text = """
    Text ...
    :::
    REMOVE BEFORE RENDER
    :::
    """
    out_text = """
    Text ...
    """
    src = Base.BufferStream(); write(src, src_text); closewrite(src); 
    out = IOBuffer()
    remove_before_render(src,out)
    @test String(take!(out)) == out_text

    ## remove
    src_text = """
    Text ...
    
    :::
    REMOVE BEFORE RENDER
    :::

    """
    out_text = """
    Text ...


    """
    src = Base.BufferStream(); write(src, src_text); closewrite(src); 
    out = IOBuffer()
    remove_before_render(src,out)
    @test String(take!(out)) == out_text

    ## remove with shift=true
    src_text = """
    Text ...
    :::
    REMOVE BEFORE RENDER
    :::

    """
    out_text = """
    Text ...




    """
    src = Base.BufferStream(); write(src, src_text); closewrite(src); 
    out = IOBuffer()
    remove_before_render(src,out; shift=false)
    @test String(take!(out)) == out_text

    ## no remove due to extra space after :::
    src_text = """
    Text ...
    
    ::: 
    REMOVE BEFORE RENDER
    :::

    """
    out_text = """
    Text ...
    
    ::: 
    REMOVE BEFORE RENDER
    :::

    """
    src = Base.BufferStream(); write(src, src_text); closewrite(src); 
    out = IOBuffer()
    remove_before_render(src,out)
    @test String(take!(out)) == out_text

    nothing
end

# include("render.jl"); Render.remove_before_render(); Render.render()
# include("render.jl"); Render.test()
# include("render.jl"); Render.remove_before_render()

end