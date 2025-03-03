using SparseArrays, LazySets

abstract type DiscreteTransitionKernel{M} end

struct SparseTransitionKernel{M, T <: AbstractSparseMatrix} <: DiscreteTransitionKernel{M}
    transition_matrix::T

    function SparseTransitionKernel(transition_matrix::T) where {T <: AbstractSparseMatrix}
        n = LinearAlgebra.checksquare!(transition_matrix)
        return new{n, T}(transition_matrix)
    end
end

struct DenseTransitionKernel{M, T <: AbstractMatrix} <: DiscreteTransitionKernel{M}
    transition_matrix::T

    function DenseTransitionKernel(transition_matrix::T) where {T <: AbstractMatrix}
        n = LinearAlgebra.checksquare!(transition_matrix)
        return new{n, T}(transition_matrix)
    end
end

struct RegionDependentSparseTransitionKernel{M, T <: AbstractSparseMatrix, S <: LazySet} <: DiscreteTransitionKernel{M}
    transition_matrices::Vector{Tuple{S, T}}

    # TODO: Check non-overlap of regions

    function RegionDependentSparseTransitionKernel(transition_matrices::Vector{Tuple{S, T}}) where {T <: AbstractSparseMatrix, S <: LazySet}
        first_region = transition_matrices[1]
        d = LazySets.dim(first_region[1])
        n = LinearAlgebra.checksquare!(first_region[2])

        for (i, (A, _)) in enumerate(transition_matrices)
            LinearAlgebra.checksquare!(A)
            
            if size(A, 1) != n
                throw(ArgumentError("All transition matrices must have the same dimensionality"))
            end

            if LazySets.dim(A) != d
                throw(ArgumentError("All regions must reside in the same space"))
            end
        end

        return new{n, T, S}(transition_matrices)
    end
end

struct RegionDependentDenseTransitionKernel{M, T <: AbstractMatrix, S <: LazySet} <: DiscreteTransitionKernel{M}
    transition_matrix::Vector{Tuple{T, S}}

    # TODO: Check non-overlap of regions

    function RegionDependentDenseTransitionKernel(transition_matrices::Vector{Tuple{T, S}}) where {T <: AbstractMatrix, S <: LazySet}
        first_region = transition_matrices[1]
        d = LazySets.dim(first_region[2])
        n = LinearAlgebra.checksquare!(first_region[1])

        for (i, (A, _)) in enumerate(transition_matrices)
            LinearAlgebra.checksquare!(A)
            
            if size(A, 1) != n
                throw(ArgumentError("All transition matrices must have the same dimensionality"))
            end

            if LazySets.dim(A) != d
                throw(ArgumentError("All regions must reside in the same space"))
            end
        end

        return new{n, T, S}(transition_matrices)
    end
end