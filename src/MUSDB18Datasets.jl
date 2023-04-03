module MUSDB18Datasets

using DataDeps
using MD5: md5
using MLDatasets
using MLUtils
using Random
using SignalAnalysis

const SAMPLINGRATE = 44100
const NUMCHANNELS = 2
const CLASSNAMES = ["bass","drums","other","vocals"]

function __init__()

    register(DataDep("MUSDB18-HQ",
            """
            Dataset: MUSDB18-HQ - an uncompressed version of MUSDB18
            Authors: Rafii, Zafar; Liutkus, Antoine; Fabian-Robert Stöter; Mimilakis, Stylianos Ioannis; Bittner, Rachel
            Website: https://zenodo.org/record/3338373#.ZCKqUNJBwuU
            Rafii, Zafar, Liutkus, Antoine, Stöter, Fabian-Robert, Mimilakis, Stylianos Ioannis, & Bittner, Rachel. (2019). 
                MUSDB18-HQ - an uncompressed version of MUSDB18 (1.0.0) [Data set]. Zenodo. 
                https://doi.org/10.5281/zenodo.3338373
            """,
            "https://zenodo.org/record/3338373/files/musdb18hq.zip?download=1",
            (md5, "12d4f2ecd55245a4688754dd76363103");
            post_fetch_method = unpack
            )
   )

    # register(DataDep("MUSDB18",
    #                  """
    #                  Dataset: MUSDB18 - a corpus for music separation
    #                  Authors: Rafii, Zafar; Liutkus, Antoine; Fabian-Robert Stöter; Mimilakis, Stylianos Ioannis; Bittner, Rachel
    #                  Website: https://zenodo.org/record/1117372#.ZCJNpdJBwuU
    #                  Rafii, Zafar, Liutkus, Antoine, Fabian-Robert Stöter, Mimilakis, Stylianos Ioannis, & Bittner, Rachel. (2017). 
    #                     MUSDB18 - a corpus for music separation (1.0.0) [Data set]. Zenodo. 
    #                     https://doi.org/10.5281/zenodo.1117372
    #                  """,
    #                  "https://zenodo.org/record/1117372/files/musdb18.zip?download=1",
    #                  (md5, "af06762477334799bfc5abf237648207");
    #                  post_fetch_method = unpack
    #                  )
    #         )

end

include("musdb18.jl")

end # module MUSDB18Datasets
