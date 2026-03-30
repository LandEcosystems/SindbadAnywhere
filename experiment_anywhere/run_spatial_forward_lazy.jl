
# ================================== using tools ==================================================
# some of the things that will be using... Julia tools, SINDBAD tools, local codes...
import Pkg
Pkg.activate(".")
using Revise
using Sindbad
using Dates
using Plots
using Sindbad.Visualization
using CMAEvolutionStrategy
toggle_type_abbrev_in_stacktrace()

# ================================== get data / set paths ========================================= 
# data to be used can be found here: https://nextcloud.bgc-jena.mpg.de/s/w2mbH59W4nF3Tcd
# organizing the paths of data sources and outputs for this experiment
path_input_dir      = "data/" # for convenience, the data file is set within the SINDBAD-Tutorials path; this needs to be changed otherwise.
path_input          = joinpath("$(path_input_dir)","FLUXNET_v2023_12_1D.zarr"); # zarr data source containing all the data necessary for the exercise
path_observation    = path_input; # observations (synthetic or otherwise) are included in the same file
path_output         = "data/output";


# ================================== setting up the experiment ====================================
# experiment is all set up according to a (collection of) json file(s)
experiment_json     = joinpath(@__DIR__,"settings_LUE","experiment_lazy.json");
experiment_name     = "LUE_spatial_lazy_xmap";
begin_year          = 1979;
end_year            = 2017;

path_zarr = "https://s3.bgc-jena.mpg.de:9000/sindbad/FLUXNET_v2023_12_1D.zarr"

# setting up the model spinup sequence : can change according to the site...
#spinup_sequence = getSpinupSequenceSite(y_dist, begin_year);

# default setting in experiment_json will be replaced by the "replace_info"
replace_info = Dict("experiment.basics.time.date_begin" => "$(begin_year)-01-01",
   # "experiment.basics.domain" => domain,
    "experiment.basics.name" => experiment_name,
    "experiment.basics.time.date_end" => "$(end_year)-12-31",
    #"experiment.model_spinup.sequence" => spinup_sequence,
    "forcing.default_forcing.data_path" => path_zarr,
    "experiment.model_output.path" => path_output,
    "optimization.observations.default_observation.data_path" => path_zarr,
    );

# ================================== forward run ================================================== 
# before running the optimization, check a forward run 



@time info = getExperimentInfo(experiment_json; replace_info=replace_info); # note that this will modify information from json with the replace_info
forcing = getForcing(info);
@time outcubes = runTEMYax(info.models.forward, forcing, info)


output_vars = last.(info.output.variables);
ds = forcing.data[1];
plotdat = outcubes;
domain="globe"
plots_default(titlefont=(20, "times"), legendfontsize=18, tickfont=(15, :blue))
for i ∈ eachindex(output_vars)
    v = output_vars[i]
    # vinfo = getVariableInfo(v, info.experiment.basics.temporal_resolution)
    vname = v
    # vname = vinfo["standard_name"]
    println("plot output-model => domain: $domain, variable: $vname")
    pd = plotdat[i]
    if size(pd, 2) == 1
        Plots.heatmap(pd[:, 1, :]; title="$(vname)" , size=(2000, 1000))
        # Colorbar(fig[1, 2], obj)
        plots_savefig(joinpath(info.output.dirs.figure, "$(domain)_$(vname).png"))
    else
        foreach(axes(pd, 2)) do ll
            Plots.heatmap(pd[:, ll, :]; title="$(vname)" , size=(2000, 1000))
            # Colorbar(fig[1, 2], obj)
            plots_savefig(joinpath(info.output.dirs.figure, "$(domain)_$(vname)_$(ll).png"))
        end
    end
end
