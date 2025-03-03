function state2binary(x, n)
    return BitVector(digits(x, base=2, pad=n))
end

function binary2state(b::BitVector)
    v = 1
    val = 0
    for i in view(b, length(b):-1:1)
        val += v * i
        v <<= 1
    end
    return val
end