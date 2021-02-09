a = [1 2;3 4]
b = [1 2;3 4]
println(a * b)
println(a .+ 1)
println(size(a))
println(reshape(permutedims(a), (4, 1)))
println(zeros((2, 2)))
