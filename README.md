# Reproducing results

In this repository we show how to reproduce the results in the paper
<em>"Spatio-temporal modeling of catch-at-length and age-at-length for index estimation, and incorporation of observation uncertainty in stock assessment"</em>


To estimate the index model and run the assessment you need to:

  1) Install the spatio-temporal index-at-length model available here: https://github.com/NorskRegnesentral/spatioTemporalIndices
  2) Install the spatio-temporal length-at-age model available here:
  https://github.com/NorskRegnesentral/spatioTemporalALK
  3) Install the state space assessment model SAM available here: https://github.com/fishfollower/SAM


Then the results can be reproduced with the following recipe:

  1) Run the script "scriptPaper/run.R" to estimate the index model and to produce the time series of abundance indices and covariance structures.
  2) Run the script "scriptPaper/runAssessment.R" to run the NEA haddock assessment with use of the indices and time series of covariance structures created in the previous step. 
  3) Run the script "scriptPaper/figuresGivenRun.R" to construct all tables and figures illustrating the index model.
  4) Run the script "scriptPaper/retroSTIM.R" and then the script "scriptpaper/retroSAM.R" to perform the retrospecitve analysis in the supplementary.
  5) Run the script "scriptPapaer/validation.R" to conduct the simulation study and the jitter analysis.
  6) Run the script "scriptPaper/residuals.R" do construct the OSA residuals.
  7) Run the script "scriptPaper/variableSelectionLenght.R" and "scriptpaper/variableSelectionAge.R" to set up the AIC tables for combinations of covariates.
  8) Run the script "scriptPaper/sensitivityRunw.R" to run alternative models, e.g., finer latent resolutions, discussed in the paper
  9) Run the script "scriptPaper/runAssessmentAllSurveys.R" to generate the assessment results with all surveys provided in the supplementary.
