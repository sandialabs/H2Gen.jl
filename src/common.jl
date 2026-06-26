function _time_weighted_sum(values::AbstractVector{<:Real}, weights::AbstractVector{<:Real})
    T = promote_type(eltype(values), eltype(weights))
    total = zero(T)
    for i in eachindex(values, weights)
        total += values[i] * weights[i]
    end
    return total
end

function _time_weighted_average(values::AbstractVector{<:Real}, weights::AbstractVector{<:Real})
    T = promote_type(eltype(values), eltype(weights))
    total_w = zero(T)
    for i in eachindex(weights)
        total_w += weights[i]
    end
    total_w <= zero(total_w) && return zero(total_w)
    return _time_weighted_sum(values, weights) / total_w
end
