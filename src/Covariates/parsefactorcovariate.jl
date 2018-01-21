struct ParseFactorCovariate{S<:Unsigned, T<:AbstractFloat} <: AbstractCovariate{T}
    name::String
    basefactor::AbstractFactor{S}
    transform::Function
end

Base.length(var::ParseFactorCovariate) = length(var.basefactor)

function ParseFactorCovariate(name::String, basefactor::AbstractFactor{S}, transform::Function) where {S<:Unsigned}
    ParseFactorCovariate{S, Float32}(name, basefactor, transform)
end

function ParseFactorCovariate(name::String, basefactor::AbstractFactor{S}, transform::Function, ::Type{T}) where {S<:Unsigned} where {T<:AbstractFloat}
    ParseFactorCovariate{S, T}(name, basefactor, transform)
end

function slice(cov::ParseFactorCovariate{S, T}, fromobs::Integer, toobs::Integer, slicelength::Integer) where {S<:Unsigned} where {T<:AbstractFloat}
    levels = getlevels(cov.basefactor)
    parsed = Vector{T}(length(levels) + 1)
    for (index, level) in enumerate(levels)
        parsed[index + 1] = convert(T, cov.transform(level))
    end
    parsed[1] = convert(T, cov.transform(MISSINGLEVEL))
    f = (i -> parsed[i + 1])
    slices = slice(cov.basefactor, fromobs, toobs, slicelength)
    mapslice(f, slices, slicelength, T)  
end