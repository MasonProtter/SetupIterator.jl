# SetupIterator.jl

Sometimes, you have a data structure where `iterate` is complicated to express for that structure, 
but `Base.Iterators` has already gone through the trouble of making an appropriate iterator for you.

For example, consider
```julia
struct VectorOfVectors{T}
   v::Vector{Vector{T}}
end
Base.IteratorEltype(::VectorOfVectors{T}) where {T} = T
Base.IteratorSize(::VectorOfVectors) = Base.HasLength()
Base.length(vov::VectorOfVectors) = isempty(vov.v) ? 0 : sum(length, vov.v)
```
and supose we want to treat this thing semantically like a flat vector, i.e. concatenate their contents. Writing
a method for `Base.iterate` on this type is actually somewhat difficult, since you'll need to juggle the state
of all the constituent vectors and check which sub-vector the current iteration state corresponds to.

Wouldn't it be great if we could just do something akin to 
```
Base.iterator(vov::VectorOfVectors) = Iterators.flatten(vov.v)
```
and be done with it? 

Enter SetupIterator.jl:
``` julia
using SetupIterator
SetupIterator.iterator(vov::VectorOfVectors) = Iterators.flatten(vov.v)
@setup_iterate VectorOfVectors
```

``` julia
julia> let vov = VectorOfVectors([[1, 2, 3], [4, 5]])
           for x ∈ vov
               @show x
           end
       end
x = 1
x = 2
x = 3
x = 4
x = 5
```

Normally, when you write

``` julia
for x ∈ xs
    #do stuff
end
```
this gets lowered to the code
``` julia
next = iterate(xs)
while next !== nothing
  x, state = next
  #do stuff
  next = iterate(xs, state)
end
```
but when we use `SetupIterator.jl`, it becomes more equivalent to

``` julia
itr = SetupIterator.iterator(xs)
next = iterate(itr)
while next !== nothing
  x, state = next
  #do stuff
  next = iterate(itr, state)
end
```
This way, there are no remaining references to `xs` inside the loop, and if we wish to implement something
like a destructive iterator to reclaim memory from `xs` while the loop runs, then that is now possible.

___ 

Inspiration for this comes from [Iterate on it](https://mikeinnes.io/2020/06/04/iterate) by Mike Innes, and from [this issue](https://github.com/JuliaLang/julia/issues/46802)

Credit to Jameson Nash for pointing out that this can be done [in this issue](https://github.com/JuliaLang/julia/issues/46802#issuecomment-1249707763).
