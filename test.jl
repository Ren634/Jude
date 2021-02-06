mutable struct Variable
    data
    creator
    grad
    generation
    function Variable(data)
        new(data, nothing, nothing, 0)
    end
end

a = [1,2,3]

b = Variable(ones(size(a)))
println(b.data)
