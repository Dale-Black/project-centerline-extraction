# Roadmap

- [x] Prepare Rotterdam dataset for deep learning
  * ~~Convert .raw/.mhd images to .nii images~~
  * ~~Convert centerline coordinates to binary .nii images~~
  * ~~Set up training directory like MSD dataset~~
- [ ] Test simple Unet + DT loss function on Rotterdam data
  * Prepare Rotterdam data for training
    * Include random augmentations to account for limited data size
  * Use [DistanceTransforms.jl](https://github.com/Dale-Black/DistanceTransforms.jl) loss functions (`hd_loss` + `squared_euclidean_distance_transform`)
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
