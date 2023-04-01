# MUSDB18Datasets.jl
This package provides an interface for assessing the MUSDB18 datasets.  

## Usage
```
using MUSDB18Datasets

musdb18 = MUSDB18(; Tx = Float32, downsample = 1, numchannels = 1, split = :test) # first channel
musdb18 = MUSDB18(; Tx = Float32, downsample = 1, numchannels = 2, split = :test) # first 2 channels
```

## Reference
Rafii, Zafar, Liutkus, Antoine, Stöter, Fabian-Robert, Mimilakis, Stylianos Ioannis, & Bittner, Rachel. (2019). MUSDB18-HQ - an uncompressed version of MUSDB18 (1.0.0) [Data set]. Zenodo. https://doi.org/10.5281/zenodo.3338373