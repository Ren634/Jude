import main
mutable struct Sin
    outputs
    inputs
    function Sin(x)
        self = new()
        call(self,x)
        return 
    end
