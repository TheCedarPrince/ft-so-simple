+++
title = "**Testing**"
short = "> An open experiment into creating performant graphics for neuroinformatics!"
published = Date(2020, 12, 21)
+++

\center{*NeuriViz - an open experiment into creating performant graphics for neuroinformatics!*}

I am quite excited to introduce a new side-project of mine called [`NeuriViz`](https://github.com/TheCedarPrince/NeuriViz)!
`NeuriViz` is a proof of concept application of the [`Javis.jl`](https://github.com/Wikunia/Javis.jl) package to create performant animated graphics and visualizations for the domain of neuroinformatics!

If you find this blog post useful, please consider citing it:

> Jacob Zelko. _NeuriViz (Part 1) - Performant Graphics for Neuroinformatics_. November 1st, 2020. http://jacobzelko.com

# How Did `NeuriViz` Come to Be?

[`NeuriViz`](https://github.com/TheCedarPrince/NeuriViz) started as an offshoot of my work on [`Javis.jl`](https://github.com/Wikunia/Javis.jl) that my friend, [Ole Kröger](https://opensourc.es/about/), and I created.
The `Javis` package acts as a general purpose library to easily construct informative, performant, and winsome animated graphics using the [Julia programming language](https://julialang.org/).
While working on `Javis`, I realized it had potential to be applied to domain specific graphics that can be difficult to make.
Given [my background in health sciences and cognitive disabilities](/) I used `Javis` to create an animation of a 10-20 EEG Electrode Array:

\center{![](/assets/simple_10_20_array.gif)}

After I had created this, I reached out to a neuroscientist that I knew.
From there, I was connected with my collaborator on the project, Zachary Christensen, the creator of the [JuliaNeuroscience](https://github.com/JuliaNeuroscience) organization and an MD/PhD student at the University of Rochester.
Finally, after a few different conversations, `NeuriViz` was created.

# Creating EEG Topoplots with Julia

Obviously, the 10-20 EEG electrode array animation is not particularly useful to a neuroinformaticist. 
However, what it was useful for was to illustrate an important aspect of NeuriViz: every single component of that animation was original.
I created the "template" for this array by using `Luxor` objects which `Javis` exports and was able to, after defining constants and package imports, [draw the EEG within 40 lines of code](https://wikunia.github.io/Javis.jl/stable/tutorials/tutorial_2/#Full-Code).

The first animation goal of NeuriViz is to produce a performant EEG topoplot.
The following image is taken from documentation of the popular MATLAB EEG toolbox, [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php), to illustrate exactly what is envisioned:

\center{![](/assets/eeglab_topoplot.jpg)}

Currently, with help from the creator of `Luxor`, [Cormullion](http://github.com/cormullion), I have been able to produce the following topoplot example using signal noise and my template:

\center{![](/assets/proto_eeg_topo.jpg)}

The data here is nonsensical but creating this entire prototype of a 10-20 EEG electrode array only took about [20 lines more than my original example](https://gist.github.com/TheCedarPrince/592ec8112302af4230ccc27614303a6f).

There is still much to do with making a fully functioning topoplot using `Javis`.
For starters, the poor subject is missing a nose and ears!
As shown in the example from EEGLAB, there are no boundaries between different activity gradients. 
Finally, taking actual channel data and interpolating it across the contour of the skull to create the actual topoplot is a non-trivial process.

However, I am confident that not only is this surmountable but that we can make animations for brain activity across epochs in a fast and performant way.
Why do I think that? 
Let's get to that in the next section where we talk about data to visualization pipelines!

# NeuriViz Data-to-Visualization Pipelines

For this project, I have been working with [_Go-nogo categorization and detection task_](https://openneuro.org/datasets/ds002680/versions/1.0.0) dataset submitted by Delorme et. al. to the open science neuroinformatics dataset service, [OpenNEURO](https://openneuro.org/). [1]
The entire dataset is roughly 10GB worth of EEG data following the BIDS standard, the standard format for managing EEG data. [2] 
Further, this dataset has been used in a variety of studies already and its validity as a strong dataset has been proven in literature. [3 - 5]

An initial challenge with handling this data was determining how best to represent the data in terms of a file format and data structure.
To address the issue of the file format, I turned to [`Arrow.jl`](https://github.com/JuliaData/Arrow.jl), which is maintained by the [JuliaData organization](https://github.com/JuliaData), to use the Apache Arrow format.
The Arrow format was created in 2016 by Wes McKinney, the creator of the extremely popular [`pandas`](https://pandas.pydata.org/) Python package, to produce language-independent open standards and libraries to accelerate and simplify in-memory computing. [6]
Of note, it is ideal for columnar data, cache-efficiency on CPUs and GPUs, leverages parallel processing, and optimized for scan and random access.
`Arrow.jl` brilliantly used memory mapping to implement the standard in an immensely efficient way.

Here are light benchmarks from my usage of `Arrow.jl` on a single ~25MB data file:

\center{![](/assets/arrow_benchmarks.png)}

I thought this was immensely impressive and performant for processing my entire dataset which, in this case, would be "larger than memory" in regards to my computer's memory.
Further, the minimal allocations is fantastic - I am sure some of my methodology could be improved, but I am already very pleased for the NeuriViz project.

Having tentatively solved the problem of data formats to enable high speeds and efficiency for data manipulation, came the problem of actually creating a structure to hold this data.
The BIDS format enforces an architecture that does enhance reproducibility of science, but it results in having data split across multiple files and formats. 
Thankfully, I found a solution by using the following packages: 

- [`BIDSTools.jl`](https://github.com/TRIImaging/BIDSTools.jl) - I used this to easily parse out relevant data files from the dataset.
- [`AxisIndices.jl`](https://github.com/Tokazama/AxisIndices.jl) - This was created by my collaborator, Zachary Christensen, and I utilized it to load in all the disparate files into one data structure.

After the loading was complete, I ended up with the following intuitive syntax:

\center{![](/assets/load_eeg_data.jpeg)}

Currently, this is the idea for a user interface and is being actively worked on in [v0.1.0 of NeuriViz](https://github.com/TheCedarPrince/NeuriViz).
The goal then becomes piping this data to generate the topoplot and interfacing it with the array layout I created with `Javis`.

# Conclusion

All the pieces that I need to accomplish the goal of making a performant visualization using `Javis` and raw EEG data are here.
I am quite excited to see what a prototype will produce with NeuriViz but, based on my prior work, I am quite optimistic about what will come!
Feel free to watch or star the [project on GitHub](https://github.com/TheCedarPrince/NeuriViz) as developments are soon to come!

Take care and all the best! ~ jz

_If you spot any errors or have any questions, feel free to [contact me](/contact/) about them!_

# References 

[1] A. Delorme and M. Fabre-Thorpe, Go-nogo categorization and detection task. 2020.

[2] K. J. Gorgolewski et al., “The brain imaging data structure, a format for organizing and describing outputs of neuroimaging experiments,” Sci Data, vol. 3, no. 1, p. 160044, Dec. 2016, doi: 10.1038/sdata.2016.44.

[3] Fabre-Thorpe, M., Delorme, A., Marlot, C., & Thorpe, S. (2001). A limit to the speed of processing in ultra-rapid visual categorization of novel natural scenes. Journal of cognitive neuroscience, 13(2), 171–180. https://doi.org/10.1162/089892901564234 

[4] Delorme, A., Rousselet, G. A., Macé, M. J., & Fabre-Thorpe, M. (2004). Interaction of top-down and bottom-up processing in the fast visual analysis of natural scenes. Brain research. Cognitive brain research, 19(2), 103–113. https://doi.org/10.1016/j.cogbrainres.2003.11.010 

[5] Delorme, A., Makeig, S., Fabre-Thorpe, M., & Sejnowski, T. (2002). From single-trial EEG to brain area dynamics. Neurocomputing, 44–46, 1057–1064. https://doi.org/10.1016/S0925-2312(02)00415-0

[6] Wes McKinney, Apache Arrow and the Future of Data Frames. 2020.


