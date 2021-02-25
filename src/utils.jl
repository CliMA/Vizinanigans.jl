"""
histogram(array; bins = 100)
# Description
return arrays for plotting histogram
"""
function histogram(
    array;
    bins = minimum([100, length(array)]),
    normalize = true,
)
    tmp = zeros(bins)
    down, up = extrema(array)
    down, up = down == up ? (down - 1, up + 1) : (down, up) # edge case
    bucket = collect(range(down, up, length = bins + 1))
    normalization = normalize ? length(array) : 1
    for i in eachindex(array)
        # normalize then multiply by bins
        val = (array[i] - down) / (up - down) * bins
        ind = ceil(Int, val)
        # handle edge cases
        ind = maximum([ind, 1])
        ind = minimum([ind, bins])
        tmp[ind] += 1 / normalization
    end
    return (bucket[2:end] + bucket[1:(end - 1)]) .* 0.5, tmp
end