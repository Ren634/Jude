include("..\\main.jl")

x = Variable([1.0,2])
y = Variable([3.0,4])

z = x^2 / y
g = 2 / x
a = x / y

println("z:",z.data)
println("g:",g.data)
println("a:",a.data)

backward(z)
println("dz/dx", x.grad.data)
println("dz/dy", y.grad.data)
clear_grad(x,y)
backward(g)
println("dg/dx",x.grad.data)
clear_grad(x)
backward(a)
println("da/dy",y.grad.data)
