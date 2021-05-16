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
		Pkg.add("PlotlyJS")
		Pkg.add("Plots")
	end
	
	# Import packages
	using PlutoUI
	using NIfTI
	using PlotlyJS
	using Plots
end

# ╔═╡ 2c7269ee-4b2c-47c9-86ef-b28ffbbc86ab
md"""
## Set up
"""

# ╔═╡ 137df9f6-3452-4941-b056-73a17fac2f36
import CSV, DataFrames

# ╔═╡ 4501e0c4-bbd5-4e3c-9a29-062176af7f92
plotlyjs()

# ╔═╡ 77f7946d-f5c5-4850-9880-f00dae3269f0
TableOfContents()

# ╔═╡ 20786a05-b378-4766-9b14-c838bc995ad4
md"""
## Load files
"""

# ╔═╡ ca349927-6f00-4ea0-9b43-b2b716f1f0ab
image_filepath = "/Users/daleblack/Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Volumes/128.200.49.44 – FTP-1/NeptuneData/Datasets/Rotterdam_new/training/dataset00/image00.nii";

# ╔═╡ 4bc46e5a-1251-4b52-b956-68681ef707ab
label_filepath = "/Users/daleblack/Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Volumes/128.200.49.44 – FTP-1/NeptuneData/Datasets/Rotterdam_new/training/dataset00/label.nii";

# ╔═╡ ead8952b-38b0-45a7-80bf-a77419163516
pt0_path = "/Users/daleblack/Library/Group Containers/G69SCX94XU.duck/Library/Application Support/duck/Volumes/128.200.49.44 – FTP-1/NeptuneData/Datasets/Rotterdam_new/training/dataset00/vessel0/reference_voxel.csv";

# ╔═╡ 44ae1342-3ca9-4725-8705-7806daa896a1
md"""
When you read a nifti file (.nii), you will load the image (3D or 2D) plus the header data. The header data is similar to a dictionary with patient information like CT scanner parameters, patient age, etc.

Since we are only interested in the image right now, we will extract the 3D images using `NIfTI.raw`
"""

# ╔═╡ ddba891c-7e1f-45a1-9ded-f527da76f984
img = NIfTI.niread(image_filepath);

# ╔═╡ f546d8c7-397f-4dc2-a15f-a1f6ff0e7768
label = NIfTI.niread(label_filepath);

# ╔═╡ 3aaa0b20-7c5d-4b5f-ae4f-a320b051a2bf
img_raw = img.raw;

# ╔═╡ 8b852c94-3efd-4b07-8cf4-203f220693a2
label_raw = label.raw;

# ╔═╡ e9423808-8f30-43c9-bf4c-5c6f8c7bef89
md"""
Double check that the lable contains only 0s, 1s, 2s, 3s, and 4s
"""

# ╔═╡ 42301409-ae95-4cd8-9d78-c8528a8d8b7c
unique(label_raw)

# ╔═╡ 60d55ef4-d989-48b6-ac5c-9533f19f813c
md"""
We might want to make sure the label pixels of Integer values, instead of Float values for better training and faster load times. We can address this later though
"""

# ╔═╡ 8ae9bebe-44f9-4871-8ef3-07ee50d5b1b4
typeof(img_raw)

# ╔═╡ 1afa19f4-a785-47a0-9c34-1493c6540053
typeof(label_raw)

# ╔═╡ f91d4761-0342-4894-adc0-f7cf09495ab5
md"""
Load CSV file of the first centerline
"""

# ╔═╡ f1018191-3036-454e-980a-0b6517540f3e
begin
	df0 = DataFrames.DataFrame(CSV.File(pt0_path))
	df0[!, :X] = convert.(Int, df0[:, :X])
	df0[!, :Y] = convert.(Int, df0[:, :Y])
	df0[!, :Z] = convert.(Int, df0[:, :Z])
end;

# ╔═╡ f0056050-e61a-4a8a-84b2-38c8038a596c
centerline1 = convert(Array, df0[:, 2:4]);

# ╔═╡ 712a464a-3250-4e16-b05c-48b84ba02a60
md"""
## Plot images
"""

# ╔═╡ 648335ef-16e3-4387-a7fb-ab7706a4d840
@bind a Slider(1:272, default=188, show_value=true)

# ╔═╡ 80dd6c51-e082-4b8b-913c-b173e2c2afb0
begin
	l = @layout (1,2)
	p1 = Plots.heatmap(img_raw[:,:,a]; color=:grays)
	p2 = Plots.heatmap(label_raw[:,:,a]; color=:grays)
	Plots.plot(p1, p2, layout=l)
end

# ╔═╡ ea5cadd5-6163-47ea-adef-b6e6a97c22c1
md"""
## Superimpose centerlines
"""

# ╔═╡ e04f8de0-8541-465b-8255-be20bcad7afb
zs = unique(centerline1[:,3]);

# ╔═╡ 9fd75a46-7cd3-4273-b521-47befd4bf736
@bind b Slider(1:length(zs), default=1, show_value=true)

# ╔═╡ 22b1723a-436f-4783-84dd-dd2406bd753c
indices = findall(x -> x == zs[b], centerline1[:,3])

# ╔═╡ f4067d5c-9086-44f8-b2a3-8745545a2861
begin
	plt2 = Plots.scatter(centerline1[:,1][indices], centerline1[:,2][indices], color="blue", markersize=2)
	heatmap!(plt2, transpose(img_raw[:,:,zs[b]]), alpha=0.5, color=:grays)
end

# ╔═╡ 822dbc31-8c7a-460c-bf07-0c2d0a30f8bd
md"""
## Plot csv points vs label image
"""

# ╔═╡ 3432d8a2-4dac-4c5d-b111-882cc976f77d
unique(label_raw)

# ╔═╡ c8735694-a99e-44b5-8515-953fbbba8559
cartesian_pts = findall(x -> x == 1.0, label_raw);

# ╔═╡ 7b8300f8-d778-487f-a55a-ef6e6a0b8769
Plots.scatter(centerline1[:,1], centerline1[:,2], centerline1[:,3], markersize=2)

# ╔═╡ 5e54c1ac-ac92-4229-8db6-97158e37dd8d
Plots.scatter(getindex.(cartesian_pts, 1), getindex.(cartesian_pts, 2), getindex.(cartesian_pts, 3), markersize=2)

# ╔═╡ e7edf7d3-f20c-4197-aa81-3ae87de7fb20
# begin
# 	binary_array = zeros(size(img_raw))
# 	for (x,y,z) in eachrow(centerline1)
# 		binary_array[x,y,z] = 1
# 	end
# end

# ╔═╡ Cell order:
# ╟─2c7269ee-4b2c-47c9-86ef-b28ffbbc86ab
# ╠═71a1c8ac-b1bf-11eb-2dff-d991c8ba6387
# ╠═137df9f6-3452-4941-b056-73a17fac2f36
# ╠═4501e0c4-bbd5-4e3c-9a29-062176af7f92
# ╠═77f7946d-f5c5-4850-9880-f00dae3269f0
# ╟─20786a05-b378-4766-9b14-c838bc995ad4
# ╠═ca349927-6f00-4ea0-9b43-b2b716f1f0ab
# ╠═4bc46e5a-1251-4b52-b956-68681ef707ab
# ╠═ead8952b-38b0-45a7-80bf-a77419163516
# ╟─44ae1342-3ca9-4725-8705-7806daa896a1
# ╠═ddba891c-7e1f-45a1-9ded-f527da76f984
# ╠═f546d8c7-397f-4dc2-a15f-a1f6ff0e7768
# ╠═3aaa0b20-7c5d-4b5f-ae4f-a320b051a2bf
# ╠═8b852c94-3efd-4b07-8cf4-203f220693a2
# ╟─e9423808-8f30-43c9-bf4c-5c6f8c7bef89
# ╠═42301409-ae95-4cd8-9d78-c8528a8d8b7c
# ╟─60d55ef4-d989-48b6-ac5c-9533f19f813c
# ╠═8ae9bebe-44f9-4871-8ef3-07ee50d5b1b4
# ╠═1afa19f4-a785-47a0-9c34-1493c6540053
# ╟─f91d4761-0342-4894-adc0-f7cf09495ab5
# ╠═f1018191-3036-454e-980a-0b6517540f3e
# ╠═f0056050-e61a-4a8a-84b2-38c8038a596c
# ╟─712a464a-3250-4e16-b05c-48b84ba02a60
# ╠═648335ef-16e3-4387-a7fb-ab7706a4d840
# ╠═80dd6c51-e082-4b8b-913c-b173e2c2afb0
# ╟─ea5cadd5-6163-47ea-adef-b6e6a97c22c1
# ╠═e04f8de0-8541-465b-8255-be20bcad7afb
# ╠═22b1723a-436f-4783-84dd-dd2406bd753c
# ╟─9fd75a46-7cd3-4273-b521-47befd4bf736
# ╠═f4067d5c-9086-44f8-b2a3-8745545a2861
# ╟─822dbc31-8c7a-460c-bf07-0c2d0a30f8bd
# ╠═3432d8a2-4dac-4c5d-b111-882cc976f77d
# ╠═c8735694-a99e-44b5-8515-953fbbba8559
# ╠═7b8300f8-d778-487f-a55a-ef6e6a0b8769
# ╠═5e54c1ac-ac92-4229-8db6-97158e37dd8d
# ╠═e7edf7d3-f20c-4197-aa81-3ae87de7fb20
