using DataStructures 

mutable struct Variable
    data
    creator
    grad
    generation
    function Variable(data)
        new(data, nothing, nothing, 0)
    end
end

function Base.println(variable::Variable)
    println(variable.data)
end

function backward(variable::Variable)
    if (variable.grad === nothing)
        variable.grad = Variable(ones(size(variable.data)))
    end
    funcs = BinaryMinMaxHeap{Tuple{Int,Any}}()
    func_set = Set()
    function add_func(f)
        if (!(f in func_set))
            push!(funcs, (f.generation, f))
            push!(func_set, f)
        end
    end
    add_func(variable.creator)
    while (!isempty(funcs))
        _, f = popmax!(funcs)
        gys = [output.value.grad for output in f.outputs]
        gxs = backward(f, gys...)
        if (isa(gxs, Tuple{Any}))
            gxs = (gxs,)
        end
        for (x, gx) in zip(f.inputs, gxs)
            if (x.grad === nothing)
                x.grad = gx
            else
                x.grad = x.grad + gx
            end
            if (x.creator !== nothing)
                add_func(x.creator)
            end
        end
    end
end

function set_creator(output::Variable, func::Any)
    output.generation = output.generation + 1
    output.creator = func
end

function call(func, inputs::Variable ...)
    xs = [input.data for input in inputs]
    ys = [forward(func, xs...)]
    if (!isa(ys, Array{Any}))
        ys = (ys)
    end
    outputs = [Variable(y) for y in ys]
    func.inputs = inputs
    func.outputs = [WeakRef(output) for output in outputs]
    func.generation = maximum([input.generation for input in inputs])
    for output in outputs
        set_creator(output, func)
    end 
    if (length(outputs) > 1)   
        return outputs
    else 
        return outputs[1]
    end    
end

function clear_grad(variables::Variable ...)
    for variable in variables
        variable.grad = nothing
    end
end

mutable struct Add
    inputs
    outputs
    generation
end

mutable struct Sub
    inputs
    outputs
    generation
end

mutable struct Mul
    inputs
    outputs
    generation
end

mutable struct Div
    inputs
    outputs
    generation
end

mutable struct Neg
    inputs
    outputs
    generation
end

mutable struct Pow
    inputs
    outputs
    generation
    exponent 
end



function as_variable(x::Number)
    Variable([Float64(x)])
end    


function forward(func::Add, x0::Array{Float64}, x1::Array{Float64})
    y = x0 .+ x1
    return y
end    

function backward(func::Add, gy)
    return gy, gy
end    


function forward(func::Mul, x0::Array{Float64}, x1::Array{Float64})
    y = x0 .* x1
    return y
end    

function backward(func::Mul, gy)
    x0, x1 = func.inputs
    return x1 * gy, x0 * gy
end    

function forward(func::Sub, x0::Array{Float64}, x1::Array{Float64})
    y = x0 .- x1
    return y
end

function backward(func::Sub, gy)
    return gy, -gy
end

function forward(func::Div, x0::Array{Float64}, x1::Array{Float64})
    y = x0 ./ x1
    return y
end

function backward(func::Div, gy)
    x0, x1 = func.inputs
    gx0 = (1 / x1) * gy
    gx1 = (-x0 / x1^2) * gy
    return gx0, gx1
end

function forward(func::Pow, x0::Array{Float64})
    exponent = func.exponent
    return x0.^exponent
end

function backward(func::Pow, gy)
    x0 = func.inputs
    exponent = func.exponent
    gx = exponent * (x0^(exponent - 1)) * gy
    return gx
end

function forward(func::Neg, x0::Array{Float64})
    return -x0
end

function backward(func::Neg, gy)
    return -gy
end

function Base.:+(x0::Variable, x1::Variable)
    self = Add(nothing, nothing, nothing)
    call(self, x0, x1)
end    

function Base.:+(x0::Number, x1::Variable)
    x0 = as_variable(x0)
    self = Add(nothing, nothing, nothing)
    call(self, x0, x1)
end    

function Base.:+(x0::Variable, x1::Number)
    x1 = as_variable(x1)
    self = Add(nothing, nothing, nothing)
    call(self, x0, x1)
end  

function Base.:-(x0::Variable, x1::Variable)
    self = Sub(nothing, nothing, nothing)
    call(self, x0, x1)
end

function Base.:-(x0::Variable, x1::Number)
    x1 = as_variable(x1)
    self = Sub(nothing, nothing, nothing)
    call(self, x0, x1)
end

function Base.:-(x0::Number, x1::Variable)
    x0 = as_variable(x0)
    self = Sub(nothing, nothing, nothing)
    call(self, x0, x1)
end

function Base.:-(x0::Variable)
    self = Neg(nothing, nothing, nothing)
    call(self, x0)
end

function Base.:*(x0::Variable, x1::Variable)
    self = Mul(nothing, nothing, nothing)
    return call(self, x0, x1)
end        

function Base.:*(x0::Number, x1::Variable)
    x0 = as_variable(x0)
    self = Mul(nothing, nothing, nothing)
    return call(self, x0, x1)
end  

function Base.:*(x0::Variable, x1::Number)
    x1 = as_variable(x1)
    self = Mul(nothing, nothing, nothing)
    return call(self, x0, x1)
end            

function Base.:/(x0::Variable, x1::Variable)
    self = Div(nothing, nothing, nothing)
    return call(self, x0, x1)
end

function Base.:/(x0::Variable, x1::Number)
    x1 = as_variable(x1)
    self = Div(nothing, nothing, nothing)
    return call(self, x0, x1)
end

function Base.:/(x0::Number, x1::Variable)
    x0 = as_variable(x0)
    self = Div(nothing, nothing, nothing)
    return call(self, x0, x1)
end

function Base.:^(x0::Variable, x1::Number)
    self = Pow(nothing, nothing, nothing, x1)
    return call(self, x0)
end

