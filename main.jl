mutable struct Variable
    data
    creator
    function Variable(data)
        new(data,nothing)
    end
end

mutable struct Add
    inputs
    outputs
end

function add(x0,x1)
    self = Add(nothing,nothing)
    call(self,x0,x1)
end

function forward(func :: Add,x0 :: Array{Float64},x1::Array{Float64})
    y = x0 + x1
    return y
end

function call(func,inputs :: Variable ...)
    xs = [input.data for input in inputs]
    ys = forward(func,xs...)
    if (!isa(ys,Array{Any}))
        ys = (ys)
    end
    outputs = [Variable(y) for y in ys]
    println(outputs)
    func.inputs = inputs
    func.outputs = [output for output in outputs]
    for output in outputs
        output.creator = func
    end
    if (length(outputs) > 1)
        return outputs
    else 
        return outputs[1]
    end
end


x = Variable([1.0])
y = Variable([2.0])
z = add(x,y)
println(z.data)
println(z.creator)
