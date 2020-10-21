# als-amp-est
MATLAB Code for the paper "Blind Amplitude Estimation of Early Room Reflections Using Alternating Least Squares", submitted to ICASSP 2021.

The algorithm itself is implemented in `als.m`.
For spherical microphone arrays, `als_wrapper.m` provides a more convenient interface.

Run `generate_figures()` (with no inputs) to see an example of usage, and to regenerate the figures presented in the paper.
It takes a while due to the many Monte Carlo repetitions.
You can reduce the number of repetitions by lowering the value of `M`.

`setup()` (already called at the beginning of `generate_figures`), configures MATLAB's path.

The code was written in MATLAB 2020a.

The speech signal in the file `female_speech.wav` was taken from the [TSP speech dataset](http://www-mmsp.ece.mcgill.ca/Documents/Data/).

[Tom Shlomo](https://www.linkedin.com/in/tom-shlomo-060679182/),
[Acoustics Lab](https://sites.google.com/view/acousticslab), Ben Gurion University.
October 2020
