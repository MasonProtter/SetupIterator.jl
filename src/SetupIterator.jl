
module SetupIterator

export iterator, @setup_iterate

function iterator end
function _itr(iterable, s...)
    res = iterate(iterable, s...)
    isnothing(res) && return res
    x, s = res
    x, (iterable, s)
end

macro setup_iterate(_T)
    T = esc(_T)
    quote
        @inline function Base.iterate(x::$T)
            iterable = iterator(x)
            _itr(iterable)
        end
        @inline function Base.iterate(::$T, (iterable, s))
            _itr(iterable, s)
        end
    end
end

end
