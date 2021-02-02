mutable struct Variable
    data
    function Variable(data)
        new(data)
    end
end

mutable struct add
    inputs
    outputs
    function add(x0,x1)
        self = new()
        inputs = [x0,x1] #need fixing to generally take Variable 2/2
        outputs = call(self,x0,x1)
    end
end

function call(func,inputs :: Variable ...)
    xs = [input.data for input in inputs]
    println(xs)
    output =  [Variable(output) for output in forward(func,xs...)]
    return output[1]
end

function forward(func :: add,x0 :: Float64,x1::Float64)
    y = x0 + x1
    return y
end


x = Variable(1.0)
y = Variable(2.0)
z = add(x,y)
println(z.data)
