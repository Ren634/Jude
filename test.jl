mutable struct A
    function b()
        println("aaa")
    end
end

a = A
a.b()
