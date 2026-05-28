using YAXArrays
using Zarr
using ArchGDAL
using DimensionalData
using Statistics
using DiskArrayEngine

ds = open_dataset("data/GlobalForcingSubset.zarr/")
elev = Cube("../../Daten/WorldClim/Elevation/wc2.1_30s_elev.tif")# Aggregate data to one-degree:

t2m = ds.t2m
t2m_onedegdata = aggregate_diskarray(t2m.data, mean, (1 => 4, 2 => 4))
t2m_onedeg = Xmap.aggregate(mean, t2m, (:latitude =>4, :longitude =>4))
aggregate(mean, t2m, (X=4, Y=4))
aggregate(mean, t2m, (4,4))
# Fine to coarse
elev_t2m_grid = aggregate_diskarray(mean, t2m.data, (X => t2m.longitude, Y=>t2m.latitude)) 
# Coarse to fine, this could be selected automatically in the future
t2m_elev_grid = xresample(t2m, to=(:longitude=>elev.X, :latitude=>elev.Y))

aggregate(t2m, (Ti=>yearmonth,)) do ts
    mean(ts)
end
