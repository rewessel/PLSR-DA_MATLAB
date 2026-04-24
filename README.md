# PLSR-DA_MATLAB

Note to self:  update README to include description of optional preprocessing steps available (multilevel scaling, orthogonalization, LASSO feature selection), quirks about orthogonalization tolerance parameter, number of cross-validation reps, how to implement independent cross validation (and why you really should cross validate separately outside of this script if you perform feature selection).

A package to implement partial least squares regression (PLSR) and discriminant analysis (PLSDA) in MATLAB. Functions are included for model orthogonalization, multilevel preprocessing, feature selection with LASSO/elastic net, and cross validation.

A note on optional pre-processing steps:
- Orthogonalization:
- LASSO feature selection:
- Multilevel scaling (PLSDA only):

A note on cross validation when you are also performing feature selection:

Scripts included in this package:

sample_PLS.m: A sample call to PLSR and PLSDA using toy data.

PLSR_main.m: Performs PLSR on an nxm array with m variables and n observations (X) and an nx1 array of Y values (output). The output variable (Y) is continuous valued. Data are centered and scaled within the model, but any additional transformations (e.g. log scaling) should be performed outside of the function. Outputs a data structure containing all model statistics, coefficients, and cross validation scores for downstream processing and visualization.

PLSDA_main.m: Performs PLSDA on an nxm array with m variables and n observations (X) and an nxp array of Y values where p is the number of discriminant groups. Every observation in Y should have a value of "1" if it is a member of the group designated to that column, and "0" in all other columns. Outputs a data structure containing all model statistics for downstream processing and visualization.

OPLS.m: Orthogonalizes X data so that direction of maximum variance in Y is in the direction of latent variable 1. Removes orthogonal components. Outputs a filtered X matrix which is passed into 'plsregress'. Note:  there is a tolerance parameter that sometimes needs to be tuned to get a perfectly orthogonal model (i.e. Y variance on LV2 = 0%). 

loadings_plot.m: Plot bar plots of LV1 and LV2 loadings.

scores_plot.m: Plot scatter plot of X scores on LV1 and LV2, and reports the percent variance captured in both X.

VIP.m: Computes Variable importance in projection (VIP) scores and plots them as a bar graph with VIP scores artifically directioned and colored according to feature loadings on LV1.

univar_plot.m: Plots the univariate comparisons between model features as violin plots. P-value is reported from a Wilcoxon rank sum test using the Benjamini-Hochberg false discovery rate controlled at alpha = 0.05.

FDR.m: Computes the adjusted p-values from the Wilcoxon rank sum pairwise comparisons using the Benjamini-Hochberg method controlling the false discovery rate at alpha = 0.05.

PLSR_plot.m: Calls functions loadings_plot.m, scores_plot.m, and VIP.m to produce a loadings bar plot, X scores plot, and VIP scores bar plot.

PLSDA_plot.m: Calls functions loadings_plot.m, scores_plot.m, VIP.m, and univar_plot.m to produce a loadings bar plot, X scores plot, univariate comparisons between discriminant groups shown as a violin plot and swarmchart, and VIP scores bar plot. 

permtest.m: Runs a permutation test using 'nperm' permutations. Randomly permutes the Y data to generate 'nperm' null models, then compares the true model against the null distribution and computes an empirical p value. For PLSR, true model mean squared error (MSE) is compared against null model MSE. For PLSDA, true model cross validation (CV) accuracy is compared against null model CV accuracy. Plots a histogram of null distribution against true model (*).

biplot.m:

crossValidate.m:

cv_accuracy.m:

run_elastic_net.m:

Violin (there are 3 violin plot scripts, figure out which one to keep and which to toss):



