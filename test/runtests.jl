using Test
using MUSDB18Datasets

@testset "musdb18" begin
    
    # [Tx, downsample, numchannels, split]
    ftype = Float16
    tests = ((ftype, 1, 2, :train), 
             (ftype, 1, 2, :test),
             (ftype, 2, 2, :train),
             (ftype, 2, 2, :test),
             (ftype, 1, 1, :train), 
             (ftype, 1, 1, :test),
             (ftype, 2, 1, :train),
             (ftype, 2, 1, :test))
    for (Tx, downsample, numchannels, split) ∈ tests
        musdb18 = MUSDB18(; Tx = Tx, downsample = downsample, numchannels = numchannels, split = split)
        @test musdb18.split == split
        @test musdb18.metadata["samplingrate"] == MUSDB18Datasets.SAMPLINGRATE / downsample
        for sources1 ∈ musdb18.sources
            @test eltype(sources1) == Tx
            @test ndims(sources1) == 3
            @test size(sources1, 2) == numchannels #musdb18.metadata["numchannels"]
        end

        n = musdb18.metadata["numobservations"]
        at = 0.9
        split = :valid
        n1 = clamp(round(Int, at * n), 0, n)
        train_indices, valid_indices = 1:n1, n1+1:n
        train_musdb18, valid_musdb18 = splitobs(musdb18; at = at, split = split, shuffle = false)

        @test train_musdb18.metadata["samplingrate"] == valid_musdb18.metadata["samplingrate"] == musdb18.metadata["samplingrate"]
        
        @test train_musdb18.metadata["numchannels"] == valid_musdb18.metadata["numchannels"] ==
            musdb18.metadata["numchannels"]

        @test train_musdb18.metadata["numobservations"] == length(train_musdb18.sources) == 
            length(train_musdb18.metadata["filepaths"]) == length(train_indices)
        @test train_musdb18.split == musdb18.split
        @test train_musdb18.sources == musdb18.sources[train_indices]

        @test valid_musdb18.metadata["numobservations"] == length(valid_musdb18.sources) == 
            length(valid_musdb18.metadata["filepaths"]) == length(valid_indices)
        @test valid_musdb18.split == :valid
        @test valid_musdb18.sources == musdb18.sources[valid_indices]
    end

end