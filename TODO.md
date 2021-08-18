# Roadmap

- [x] Prepare Rotterdam dataset for deep learning
  * ~~Convert .raw/.mhd images to .nii images~~
  * ~~Convert centerline coordinates to binary .nii images~~
  * ~~Set up training directory like MSD dataset~~
- [ ] Set up Pluto notebook for training using distance transforms
  * ~~Prepare Rotterdam data for training~~
  * Use [this notebook](https://github.com/Dale-Black/MedicalTutorials.jl/blob/master/src/3D_Segmentation/Heart/explicit_heart.jl) from [MedicalTutorials.jl](https://github.com/Dale-Black/MedicalTutorials.jl) as a starting point and use the same MSD heart dataset first, since it's public and easy to work with
    * The notebook above uses the modified data loading steps that Zhijian implemented, so this will (should) load both the public MSD dataset and the Rotterdam dataset in the same way
    * Include random augmentations to account for limited data size
  * Adjust training loop to include the `dice` and `hausdorff` from [Losers.jl](https://github.com/Dale-Black/Losers.jl)
    * e.g. `loss_total = dice + (α * hausdorff)`
    * `hausdorff` requires both the input arrays (`y`, `ŷ`) and the distance transform of those arrays (`y_dtm`, `ŷ_dtm`). To compute the distance transform use [DistanceTransforms.jl](https://github.com/Dale-Black/DistanceTransforms.jl), specifically the `SquaredEuclidean` `transform`
    * All this can be done on the CPU while we are getting started and once we validate that the training loop runs, I will move it onto my personal GPU computer
- [ ] Test simple Unet + DT loss function on Rotterdam data
  * Test for convergence
- [ ] Prepare CREDENCE dataset for deep learning
  * Convert DICOM (.dcm) images to NIfTI (.nii) images
  * Convert centerline coordinates to binary .nii images
- [ ] Prepare CONFIRM dataset for deep learning
  * Convert DICOM (.dcm) images to NIfTI (.nii) images
  * Convert centerline coordinates to binary .nii images
- [ ] Test simple Unet + DT loss function on CREDENCE/CONFIRM data
  * Prepare CREDENCE/CONFIRM data for training
    * Include random augmentations to account for limited data size
  * Use DistanceTransforms.jl for loss functions `hd_loss`, `squared_euclidean_distance_distance_transform`, etc.
  * Test for convergence
    * If successful, fine tune model on Rotterdam dataset
