import ProgressMeter: @showprogress
import SignalAnalysis: sfiltfilt, sresample, fir

export MUSDB18
export splitobs

struct MUSDB18{S}
    metadata::Dict{String, Any}
    split::Symbol
    sources::S
end

"""
The MUSDB18 dataset of multi-track musics for music source separation.

# Reference
Rafii, Zafar, Liutkus, Antoine, Stöter, Fabian-Robert, Mimilakis, Stylianos Ioannis, & Bittner, Rachel. 
(2019). MUSDB18-HQ - an uncompressed version of MUSDB18 (1.0.0) [Data set]. 
Zenodo. https://doi.org/10.5281/zenodo.3338373
"""
function MUSDB18(; split=:train, Tx = Float32, downsample = 1, numchannels = NUMCHANNELS, dir = nothing)
    downsample < 1 && throw(ArgumentError("`downsample` is a positive number greater or equal to 1."))
    numchannels ∉ 1:NUMCHANNELS && throw(ArgumentError("`numchannels` has to be an integer in the range of [1,$(NUMCHANNELS)]"))
    depname = "MUSDB18-HQ" 
    foldername = split == :train ? "train" :
                 split == :test  ? "test"  :
                 error("split must be :train or :test")
    datapath = joinpath(MLDatasets.datadir(depname, dir), foldername)
    !isdir(datapath) && (datapath = MLDatasets.datafile(depname, foldername, dir))
    sources = Array{Tx,3}[]
    filepaths = readdir(datapath; join = true)
    downsample > 1 && (lpf = fir(127, 0, SAMPLINGRATE / 2 / downsample; fs = SAMPLINGRATE))
    @showprogress desc="Loading MUSDB18..." for filepath ∈ filepaths
        sources1 = Array{Tx,2}[]
        for wavname ∈ CLASSNAMES 
            s = signal(joinpath(filepath, "$(wavname).wav"))[:,1:numchannels]
            if downsample > 1
                s = sfiltfilt(lpf, s)
                s = sresample(s, 1 // Rational(downsample))
            end
            push!(sources1, convert.(Tx, samples(s)))
        end
        push!(sources, batch(sources1)) 
    end

    metadata = Dict{String, Any}()
    metadata["numobservations"] = length(sources)
    metadata["datapath"] = datapath
    metadata["filepaths"] = filepaths
    metadata["samplingrate"] = SAMPLINGRATE / downsample
    metadata["numchannels"] = numchannels
    metadata["classnames"] = CLASSNAMES

    MUSDB18(metadata, split, sources)
end

"""
Split the `data` into two subsets proportional to `at`.
"""
function MLUtils.splitobs(data::MUSDB18; at::Real, split, shuffle = false)
    n = data.metadata["numobservations"]
    @views filepaths = data.metadata["filepaths"]
    @views sources = data.sources
    if shuffle
        randindices = randperm(n)
        filepaths = filepaths[randindices]
        sources = sources[randindices]
    end

    train_filepaths, valid_filepaths = map(idx -> obsview(filepaths, idx), splitobs(n; at))
    train_sources, valid_sources = map(idx -> obsview(sources, idx), splitobs(n; at))

    train_metadata = Dict{String, Any}()
    train_metadata["numobservations"] = length(train_sources)
    train_metadata["datapath"] = data.metadata["datapath"]
    train_metadata["filepaths"] = train_filepaths 
    train_metadata["samplingrate"] = data.metadata["samplingrate"]
    train_metadata["numchannels"] = data.metadata["numchannels"]
    train_metadata["classnames"] = CLASSNAMES
    train_data = MUSDB18(train_metadata, data.split, train_sources)

    valid_metadata = Dict{String, Any}()
    valid_metadata["numobservations"] = length(valid_sources)
    valid_metadata["datapath"] = data.metadata["datapath"]
    valid_metadata["filepaths"] = valid_filepaths 
    valid_metadata["samplingrate"] = data.metadata["samplingrate"]
    valid_metadata["numchannels"] = data.metadata["numchannels"]
    valid_metadata["classnames"] = CLASSNAMES
    valid_data = MUSDB18(valid_metadata, split, valid_sources)

    train_data, valid_data
end
