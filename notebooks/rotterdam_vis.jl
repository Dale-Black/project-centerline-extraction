### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 71a1c8ac-b1bf-11eb-2dff-d991c8ba6387
begin
	let
		# Set up temporary environment
		env = mktempdir()
		import Pkg
		Pkg.activate(env)
		Pkg.Registry.update()
		
		# Download packages
		Pkg.add("PlutoUI")
		Pkg.add("NIfTI")
		Pkg.add("Plots")
	end
	
	# Import packages
	using PlutoUI
	using NIfTI
	using Plots
end

# ╔═╡ 2c7269ee-4b2c-47c9-86ef-b28ffbbc86ab
md"""
## Set up
"""

# ╔═╡ 77f7946d-f5c5-4850-9880-f00dae3269f0
TableOfContents()

# ╔═╡ 20786a05-b378-4766-9b14-c838bc995ad4
md"""
## Load files
"""

# ╔═╡ ca349927-6f00-4ea0-9b43-b2b716f1f0ab
image_filepath = "/Volumes/NeptuneData/Datasets/Rotterdam_new/training/dataset00/image00.nii";

# ╔═╡ 4bc46e5a-1251-4b52-b956-68681ef707ab
label_filepath = "/Volumes/NeptuneData/Datasets/Rotterdam_new/training/dataset00/label.nii";

# ╔═╡ 44ae1342-3ca9-4725-8705-7806daa896a1
md"""
When you read a nifti file (.nii), you will load the image (3D or 2D) plus the header data. The header data is similar to a dictionary with patient information like CT scanner parameters, patient age, etc.

Since we are only interested in the image right now, we will extract the 3D images using `NIfTI.raw`
"""

# ╔═╡ ddba891c-7e1f-45a1-9ded-f527da76f984
img = NIfTI.niread(image_filepath)

# ╔═╡ f546d8c7-397f-4dc2-a15f-a1f6ff0e7768
label = NIfTI.niread(label_filepath)

# ╔═╡ 3aaa0b20-7c5d-4b5f-ae4f-a320b051a2bf
img_raw = img.raw;

# ╔═╡ 8b852c94-3efd-4b07-8cf4-203f220693a2
label_raw = label.raw;

# ╔═╡ 42301409-ae95-4cd8-9d78-c8528a8d8b7c
unique(label_raw)

# ╔═╡ 60d55ef4-d989-48b6-ac5c-9533f19f813c
md"""
We might want to make sure the label pixels of Integer values, instead of Float values for better training. We can address this later though
"""

# ╔═╡ 8ae9bebe-44f9-4871-8ef3-07ee50d5b1b4
typeof(img_raw)

# ╔═╡ 1afa19f4-a785-47a0-9c34-1493c6540053
typeof(label_raw)

# ╔═╡ 712a464a-3250-4e16-b05c-48b84ba02a60
md"""
## Plot images
"""

# ╔═╡ 648335ef-16e3-4387-a7fb-ab7706a4d840
@bind a Slider(1:272, default=150, show_value=true)

# ╔═╡ 80dd6c51-e082-4b8b-913c-b173e2c2afb0
Plots.heatmap(img_raw[:,:,a], c=:grays)

# ╔═╡ 39e4a9ce-f9e0-41f6-93ce-beec43e97b7c
Plots.heatmap(label_raw[:,:,a], c=:grays)

# ╔═╡ 822dbc31-8c7a-460c-bf07-0c2d0a30f8bd
md"""
## Plot points vs raw image
"""

# ╔═╡ ead8952b-38b0-45a7-80bf-a77419163516
pt0_path = "/Volumes/NeptuneData/Datasets/Rotterdam_new/training/dataset00/vessel0/reference_voxel.csv";

# ╔═╡ 137df9f6-3452-4941-b056-73a17fac2f36
import CSV, DataFrames

# ╔═╡ f1018191-3036-454e-980a-0b6517540f3e
begin
	df0 = DataFrames.DataFrame(CSV.File(pt0_path))
	df0[!, :X] = convert.(Int, df0[:, :X])
	df0[!, :Y] = convert.(Int, df0[:, :Y])
	df0[!, :Z] = convert.(Int, df0[:, :Z])
end;

# ╔═╡ b70ecb15-bac9-4c8d-ae18-3ad11887c429
df0

# ╔═╡ f0056050-e61a-4a8a-84b2-38c8038a596c
centerline1 = convert(Array, df0[:, 2:4])

# ╔═╡ 7b8300f8-d778-487f-a55a-ef6e6a0b8769
Plots.scatter(centerline1[:,1], centerline1[:,2], centerline1[:,3], markersize=2)

# ╔═╡ 4605bac6-a588-4b8d-a338-5360a33a5c4c
label_raw

# ╔═╡ 692fc9d6-1c55-4df1-9c65-7f3e37c27acb
mask = map(x->x=0, label_raw)

# ╔═╡ 51419bea-c333-41b8-8620-aa5007643ba7
label_raw[mask]

# ╔═╡ Cell order:
# ╟─2c7269ee-4b2c-47c9-86ef-b28ffbbc86ab
# ╠═71a1c8ac-b1bf-11eb-2dff-d991c8ba6387
# ╠═77f7946d-f5c5-4850-9880-f00dae3269f0
# ╟─20786a05-b378-4766-9b14-c838bc995ad4
# ╠═ca349927-6f00-4ea0-9b43-b2b716f1f0ab
# ╠═4bc46e5a-1251-4b52-b956-68681ef707ab
# ╟─44ae1342-3ca9-4725-8705-7806daa896a1
# ╠═ddba891c-7e1f-45a1-9ded-f527da76f984
# ╠═f546d8c7-397f-4dc2-a15f-a1f6ff0e7768
# ╠═3aaa0b20-7c5d-4b5f-ae4f-a320b051a2bf
# ╠═8b852c94-3efd-4b07-8cf4-203f220693a2
# ╠═42301409-ae95-4cd8-9d78-c8528a8d8b7c
# ╟─60d55ef4-d989-48b6-ac5c-9533f19f813c
# ╠═8ae9bebe-44f9-4871-8ef3-07ee50d5b1b4
# ╠═1afa19f4-a785-47a0-9c34-1493c6540053
# ╟─712a464a-3250-4e16-b05c-48b84ba02a60
# ╟─648335ef-16e3-4387-a7fb-ab7706a4d840
# ╠═80dd6c51-e082-4b8b-913c-b173e2c2afb0
# ╠═39e4a9ce-f9e0-41f6-93ce-beec43e97b7c
# ╟─822dbc31-8c7a-460c-bf07-0c2d0a30f8bd
# ╠═ead8952b-38b0-45a7-80bf-a77419163516
# ╠═137df9f6-3452-4941-b056-73a17fac2f36
# ╠═f1018191-3036-454e-980a-0b6517540f3e
# ╠═b70ecb15-bac9-4c8d-ae18-3ad11887c429
# ╠═f0056050-e61a-4a8a-84b2-38c8038a596c
# ╠═7b8300f8-d778-487f-a55a-ef6e6a0b8769
# ╠═4605bac6-a588-4b8d-a338-5360a33a5c4c
# ╠═692fc9d6-1c55-4df1-9c65-7f3e37c27acb
# ╠═51419bea-c333-41b8-8620-aa5007643ba7
