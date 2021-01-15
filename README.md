# Interpolation
In this repository, we provide hardware implementations of a set of algorithms proposed as alternatives to bi-cubic interpolation. The architecture of each algorithm is detailed in [1]. 

If you find these implementations useful, please cite the reference [1]. Also, make sure to adhere to the licensing terms of the authors.
## Results 
The obtained results of down-scaling then up-scaling a reference image by a factor of 3.25 using the proposed algorithms in [1]

|Reference image  | ![](Error_maps/im_ref.png)  |Down-scaled image   | ![](Error_maps/im_down.png)  |
|:----------:|:---------------------------------------------:|:----------:|:---------------------------------------------:|
|Up-scaled image (bi-cubic)   | ![](Error_maps/im_bicubic.png) |Error (Bi-cubic), PSNR = 24.057  | ![](Error_maps/err_bicubic.png)  |
|Error (2-piecewise), PSNR = 21.426  | ![](Error_maps/err_2piecewise.png)  |Error (4-piecewise), PSNR = 22.501  | ![](Error_maps/err_4piecewise.png)  |
|Error (6-piecewise), PSNR = 23.533  | ![](Error_maps/err_6piecewise.png)  | Error (Cubic-4linear), PSNR = 24.284  | ![](Error_maps/err_cubic_4linear.png)  |
|Error (2cubic-linear), PSNR = 24.295  | ![](Error_maps/err_2cubic_linear.png)  | Error (3cubic-2linear, PSNR = 24.055  | ![](Error_maps/err_3cubic_2linear.png)  |
|Error (3cubic-2modified-linear), PSNR = 24.055  | ![](Error_maps/err_3cubic_2mlinear.png)  |


## Reference 
[1] S. Boukhtache, B. Blaysat, M. Grédiac, and F. Berry. *"Alternatives to bi-cubic interpolation considering FPGA hardware resource consumption"*, *IEEE Transactions on VLSI Systems*, 2020. 
