module SetupIterator

export iterator, @setup_iterate

function iterator end

macro setup_iterate(_T)
    T = esc(_T)
    quote
        @inline function Base.iterate(x::$T)
            iterable = iterator(x)
            res = iterate(iterable)
            isnothing(res) && return res
            x, s = res
            x, (iterable, s)

        end
        @inline function Base.iterate(::$T, state::Tuple{I, S}) where {I, S}
            iterable = state[1]
            s = state[2]
            res = iterate(iterable, s)
            isnothing(res) && return res
            x, s′ = res
            x, (iterable, s′)
        end
    end
end

end
