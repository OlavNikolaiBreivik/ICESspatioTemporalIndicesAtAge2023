library(stockassessment)
load("data/NEAhaddockAssessment/NEA_haddock_2023_officiall.Rds")
fitWeb<-stockassessment:::refit(fitWeb) #need local version

cn<-read.ices("data/NEAhaddockAssessmentAllSurveys/cn.dat")
cw<-read.ices("data/NEAhaddockAssessmentAllSurveys/cw.dat")
dw<-read.ices("data/NEAhaddockAssessmentAllSurveys/dw.dat")
lf<-read.ices("data/NEAhaddockAssessmentAllSurveys/lf.dat")
lw<-read.ices("data/NEAhaddockAssessmentAllSurveys/lw.dat")
mo<-read.ices("data/NEAhaddockAssessmentAllSurveys/mo.dat")
nm<-read.ices("data/NEAhaddockAssessmentAllSurveys/nm.dat")
pf<-read.ices("data/NEAhaddockAssessmentAllSurveys/pf.dat")
pm<-read.ices("data/NEAhaddockAssessmentAllSurveys/pm.dat")
sw<-read.ices("data/NEAhaddockAssessmentAllSurveys/sw.dat")
surveys<-read.ices("data/NEAhaddockAssessmentAllSurveys/survey.dat")

#Read joint index
indexJoint= as.matrix(read.table("data/NEAhaddockAssessment/indexJoint.txt", sep = " "))[,-1]
varJoint=  as.matrix(read.table("data/NEAhaddockAssessment/sdindexJoint.txt", sep = " ",header = T))[,-1]^2
load("data/NEAhaddockAssessment/cov_indexJoint.Rda")

covJoint = lapply(covYears,function(f){
  cov = f[-1,]
  cov = cov[,-1]
  cov
} )

indexSep=  as.matrix(read.table("data/NEAhaddockAssessment/indexJointMAPalk.txt", sep = " "))[,-1]
varSep=  as.matrix(read.table("data/NEAhaddockAssessment/sdindexJointMAPalk.txt", sep = " ",header = T))[,-1]^2
load("data/NEAhaddockAssessment/cov_indexJointMAPalk.Rda")
covSep = lapply(covYears,function(f){
  cov = f[-1,]
  cov = cov[,-1]
  cov
} )

dim = dim(surveys$`BS-NoRu-Q1(BTr)`)
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn,
                    prop.mature=mo,
                    stock.mean.weight=sw,
                    catch.mean.weight=cw,
                    dis.mean.weight=dw,
                    land.mean.weight=lw,
                    prop.f=pf,
                    prop.m=pm,
                    natural.mortality=nm,
                    land.frac=lf)

conf = loadConf(dat, "data/NEAhaddockAssessmentAllSurveys/conf.cfg")
par<-defpar(dat,conf)
fit<-sam.fit(dat,conf,par)

#############Fit joint
surveys<-read.ices("data/NEAhaddockAssessmentAllSurveys/survey.dat")
surveys$`BS-NoRu-Q1(BTr)`[1:dim[1],1:dim[2]] = indexJoint
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn,
                    prop.mature=mo,
                    stock.mean.weight=sw,
                    catch.mean.weight=cw,
                    dis.mean.weight=dw,
                    land.mean.weight=lw,
                    prop.f=pf,
                    prop.m=pm,
                    natural.mortality=nm,
                    land.frac=lf)
fitJoint<-sam.fit(dat,conf,par)

#Fit joint with provided covariance structure
surveys<-read.ices("data/NEAhaddockAssessmentAllSurveys/survey.dat")
surveys$`BS-NoRu-Q1(BTr)`[1:dim[1],1:dim[2]] = indexJoint
attr(surveys$`BS-NoRu-Q1(BTr)`, "cov-weight") <- covJoint
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn,
                    prop.mature=mo,
                    stock.mean.weight=sw,
                    catch.mean.weight=cw,
                    dis.mean.weight=dw,
                    land.mean.weight=lw,
                    prop.f=pf,
                    prop.m=pm,
                    natural.mortality=nm,
                    land.frac=lf)

par<-defpar(dat,conf)
fitJointCov<-sam.fit(dat,conf,par)

#Fit separate with provided covariance
surveys<-read.ices("data/NEAhaddockAssessmentAllSurveys/survey.dat")
surveys$`BS-NoRu-Q1(BTr)`[1:dim[1],1:dim[2]] = indexSep
attr(surveys$`BS-NoRu-Q1(BTr)`, "cov-weight") <- covSep
dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn,
                    prop.mature=mo,
                    stock.mean.weight=sw,
                    catch.mean.weight=cw,
                    dis.mean.weight=dw,
                    land.mean.weight=lw,
                    prop.f=pf,
                    prop.m=pm,
                    natural.mortality=nm,
                    land.frac=lf)

par<-defpar(dat,conf)
fitSepCov<-sam.fit(dat,conf,par)

#Joint desnity of SSB_Y and F_{Y-1}
yy = which(rev(fitWeb$data$year==2020))
ssbIndexFull = rev(which(names(fitWeb$sdrep$value)=="logssb"))[yy]
fbarIndexFull = rev(which(names(fitWeb$sdrep$value)=="logfbar"))[yy-1]
ssbIndex = rev(which(names(fit$sdrep$value)=="logssb"))[1]
fbarIndex = rev(which(names(fit$sdrep$value)=="logfbar"))[2]

##########################################################################
#Make table with variance and scaling parameter###########################
sdIndex = unique(fit$conf$keyVarObs[4,])+1
sdIndex = sdIndex[sdIndex>0]
logSdStox = c(fit$pl$logSdLogObs[sdIndex],fit$pl$logSdLogObs[sdIndex]-2*fit$plsd$logSdLogObs[sdIndex], fit$pl$logSdLogObs[sdIndex]+2*fit$plsd$logSdLogObs[sdIndex])
logSdJoint = c(fitJoint$pl$logSdLogObs[sdIndex],fitJoint$pl$logSdLogObs[sdIndex]-2*fitJoint$plsd$logSdLogObs[sdIndex], fitJoint$pl$logSdLogObs[sdIndex]+2*fitJoint$plsd$logSdLogObs[sdIndex])

varTab = exp(logSdStox)
varTab = rbind(varTab,exp(logSdJoint))
rownames(varTab) = c("Official index","Proposed index")
colnames(varTab) = c("$\\sigma_{SAM}$", "Q025", "Q0975")
varTab = round(varTab,2)
varTab

logJointCovScale = c(fitJointCov$pl$logSdLogObs[sdIndex],fitJointCov$pl$logSdLogObs[sdIndex]-2*fitJointCov$plsd$logSdLogObs[sdIndex], fitJointCov$pl$logSdLogObs[sdIndex]+2*fitJointCov$plsd$logSdLogObs[sdIndex])
logSepCovScale = c(fitSepCov$pl$logSdLogObs[sdIndex],fitSepCov$pl$logSdLogObs[sdIndex]-2*fitSepCov$plsd$logSdLogObs[sdIndex], fitSepCov$pl$logSdLogObs[sdIndex]+2*fitSepCov$plsd$logSdLogObs[sdIndex])

varScalingTab = exp(logJointCovScale)
varScalingTab = rbind(varScalingTab,exp(logSepCovScale))
rownames(varScalingTab) = c("Proposed index","Proposed index with fixed ALK")
colnames(varScalingTab) = c("$k$", "Q025", "Q0975")
varScalingTab

combinedTab = as.data.frame(matrix(0,4,3))
colnames(combinedTab) = c( "$\\sigma_{SAM}$", "$k_{SAM}$", "$k_{SAM}*mean(\\sqrt{diag(\\Phi)})$")

rownames(combinedTab) = c("Official index", "$\\bf{I}_y$",
                          "$\\bf{I}_y$ with cov$({\\bf I}_y)$",
                          "$\\bf{I}_y$ with cov$({\\bf I}^{fixedALK}_y)$")

varScalingTab = round(varScalingTab,2)
combinedTab[1,1] = paste0( varTab[1,1] , " (",varTab[1,2],",",varTab[1,3], ")")
combinedTab[2,1] = paste0( varTab[2,1] , " (",varTab[2,2],",",varTab[2,3], ")")
combinedTab[1,2] = "-"
combinedTab[2,2] = "-"
combinedTab[1,3] = "-"
combinedTab[2,3] = "-"
combinedTab[3,2] = paste0( varScalingTab[1,1] , " (",varScalingTab[1,2],",",varScalingTab[1,3], ")")
combinedTab[4,2] = paste0( varScalingTab[2,1] , " (",varScalingTab[2,2],",",varScalingTab[2,3], ")")
combinedTab[3,3] = round(mean(varScalingTab[1,1]*sqrt(varJoint)),2)
combinedTab[4,3] = round(mean(varScalingTab[2,1]*sqrt(varSep)),2)
combinedTab[3,1] = "-"
combinedTab[4,1] = "-"

matQ = xtable::xtable(combinedTab, type = "latex")
print(matQ, sanitize.text.function = function(x) {x},
      file = "tables/varSAMTabAllSurveys.tex",
      floating = FALSE)


