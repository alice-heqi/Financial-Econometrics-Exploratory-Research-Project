require(quantmod)

## Step1: function to get each bank's daily log return
get_daily_rtn3<-function(tic) {
  first_data<-getSymbols(Symbols = tic,from="2005-12-31",to="2015-12-31", periodicity = "daily",env = NULL,reload.Symbols = TRUE)
  daily_rtn <- data.frame(diff(log(as.numeric(first_data[,6]))))
  rtn_date <- data.frame(time(first_data))
  rtn_date <- data.frame(rtn_date[2:nrow(first_data),1])
  #tic_n<-rep(tic,nrow(rtn_date))
  second_data <- data.frame(daily_rtn, rtn_date)
  colnames(second_data)[1]="daily_rtn"
  colnames(second_data)[2]="date"
  #colnames(second_data)[3]="ticker"
  third_data = xts(second_data[,1], order.by=second_data$date)
  colnames(third_data)<-paste0(tic,'.daily_rtn')
  third_data
}


## Step2: geneate daily return for 65 public bank
library(magrittr)
ticker_v3<-as.data.frame(read_csv(file.choose()))
head(ticker_v3)
ticker_v3_all<-ticker_v3$ticker
length(ticker_v3_all)
ticker_v3_all[65]

daily_rtn_tbl3<-lapply(ticker_v3_all, get_daily_rtn3) %>% do.call(merge, .)
head(daily_rtn_tbl3)
dim(daily_rtn_tbl3)

#write.csv(daily_rtn_tbl3,'daily_rtn_tbl3.csv')

## Step3: Create three models for three random bank

### first, picked a Large bank:CIT to create three models.

# 1. ARCH model
library(tidyverse)
install.packages("fGarch")
require(fGarch)
cit<-get_daily_rtn3("CIT")
head(cit)
dim(cit)
# check the basic plot and trend of log rtn of cit
plot(cit)
acf(cit)
pacf(cit)
# # the acf plot of cit looks like a white noise, so test it with Box test
Box.test(cit, lag=15, type="Ljung")# result indicate cit daily rtn is not white noise
t.test(cit)# result indicate the mean value of cit is equal to zero
# a^2=R^-miu^2, becasue miu is equal to zero, a^2 equal to r^2

# since we assume the mean of cit daily return is a constant which eqaul to zero,
# we can calculate the residual and test the ARCH effect now
cit_v<- cit - mean(cit)
Box.test(cit_v^2, lag=15, type="Ljung")# it's not a white noise, so ARCH effect exists
acf(cit_v^2)
pacf(cit_v^2) # check pacf to determine order of ARCH, seems 3 is a good one

a3<-garchFit(~1+garch(3,0),data=cit,trace=F)
a5<-garchFit(~1+garch(10,0),data=cit,trace=F) # cross check AR(10)

summary(a3) 
summary(a5)

# 2. GARCH model
g1 <- garchFit(~ 1 + garch(1,1), data=cit, trace=FALSE)
summary(g1)

# 3. AR+GARCH model
library(forecast)
library(rugarch)

m2<-auto.arima(cit)
summary(m2)# auto-ARMA model select the order(2,3) as the optimal ARMA order

cit_spec = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                      mean.model=list(armaOrder=c(2,3), include.mean=TRUE), 
                      distribution.model="norm")    
cit_fit = ugarchfit(spec = cit_spec, data = cit)
cit_fit

# cross check if AR(1,1)+GARCH(1,1) acceptable in this case
cit_spec2 = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,1), include.mean=TRUE), 
                       distribution.model="norm")    
cit_fit2 = ugarchfit(spec = cit_spec2, data = cit)
cit_fit2


### Second, choose m&t bk corp to create three models
# 1. ARCH model
mtb<-get_daily_rtn3("MTB")
head(mtb)
dim(mtb)
# check the basic plot and trend of log rtn of MTB
acf(mtb)
pacf(mtb)
# test if MTB daily return is white noise
Box.test(mtb, lag=10, type="Ljung")#reject the null, mtb is not a white noise
# test if the mean of MTB is equal to zero
t.test(mtb)# mean is equal to zero

# test the ARCH effect of the square of residual 
mtb_v<- mtb - mean(mtb)
Box.test(mtb_v^2, lag=10, type="Ljung")# reject the null, so ARCH effect exists
acf(mtb_v^2)
pacf(mtb_v^2) # check pacf to determine order of ARCH, seems 10 is a good one

mtb_a1<-garchFit(~1+garch(3,0),data=mtb,trace=F) # cross check AR(3)

mtb_a3<-garchFit(~1+garch(10,0),data=mtb,trace=F)

summary(mtb_a1)
summary(mtb_a3)


# 2.GARCH model
mtb_g1 <- garchFit(~ 1 + garch(1,1), data=mtb, trace=FALSE)
summary(mtb_g1)

# 3. AR+GARCH model

mtb_m2<-auto.arima(mtb)
summary(mtb_m2)# auto-ARMA model select (2,2)

mtb_spec = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                      mean.model=list(armaOrder=c(2,2), include.mean=TRUE), 
                      distribution.model="norm")    
mtb_fit = ugarchfit(spec = mtb_spec, data = mtb)
mtb_fit
sink("mtb_spec.txt")
Table <- xtable(mtb_fit@fit$matcoef)
print(Table, type = "latex", comment = FALSE)

# AR(2,2)+GARCH(1,1) seems have insignificant coefficents for AR1 and MA1
# test AR(1,1)+GARCH(1,1)
mtb_spec2 = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,1), include.mean=TRUE), 
                       distribution.model="norm")    
mtb_fit2 = ugarchfit(spec = mtb_spec2, data = mtb)
mtb_fit2

# Third, choose "bank of hi corp" to create three models
boh<-get_daily_rtn3("BOH")
head(boh)
dim(boh)
# 1. ARCH model
# check the basic plot and trend of log rtn of cit
acf(boh)
pacf(boh)
Box.test(boh, lag=15, type="Ljung")#reject the null, boh is not a white noise
t.test(boh)# mean is equal to zero

boh_v<- boh - mean(boh)
Box.test(boh^2, lag=15, type="Ljung")# reject the null too, ARCH effec exists
acf(boh_v^2)
pacf(boh_v^2) # seems order 2 or 10 order are good ones

boh_a1<-garchFit(~1+garch(3,0),data=boh,trace=F) # cross chec AR(3)
boh_a3<-garchFit(~1+garch(5,0),data=boh,trace=F)
boh_a4<-garchFit(~1+garch(10,0),data=boh,trace=F) # cross chec AR(10)

summary(boh_a1)
summary(boh_a3)
summary(boh_a4)


# 2. GARCH model
boh_g1 <- garchFit(~ 1 + garch(1,1), data=boh, trace=FALSE)
summary(boh_g1)

# 3. AR+GARCH model

boh_m2<-auto.arima(boh)
summary(boh_m2)#auto-ARMA select ARMA(1,1)

boh_spec = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                      mean.model=list(armaOrder=c(1,1), include.mean=TRUE), 
                      distribution.model="norm")    
boh_fit = ugarchfit(spec = boh_spec, data = boh)
boh_fit

### Conclusion: Accorcing to the cross test for these three banks, ARCH(10) produced acceptable result for 
### all three banks, GARCH(1,1) has better performance for all three
### and for AR+GARCH, the AR(1,1)+GARCH(1,1) produced acceptable result for all three

## Forth, try one more regional bank:cullen/frost bkr to cross check the order effect
cfr<-get_daily_rtn3("CFR")
dim(cfr)
head(cfr)
# 1. ARCH model
# basic plots for CFR
acf(cfr)
pacf(cfr)
Box.test(cfr, lag=15, type="Ljung")#reject the null, mtb is not a white noise
t.test(cfr)# mean is equal to zero

cfr_v<- cfr - mean(cfr)
Box.test(cfr^2, lag=15, type="Ljung")# reject the null too

## Apply the confirmed three models on CFR
# 1. ARCH(10) + "std"
cfr_a5<-garchFit(~1+garch(10,0),data=cfr,trace=F, cond.dist = "std")
summary(cfr_a5)

# 2. GARCH(1,1)
cfr_g1 <- garchFit(~ 1 + garch(1,1), data=cfr, trace=FALSE)
summary(cfr_g1)
# 3. AR(1,1)+GARCH(1,1) +"snorm" model

cfr_spec2 = ugarchspec(variance.model=list(model="sGARCH", garchOrder=c(1,1)),
                       mean.model=list(armaOrder=c(1,1), include.mean=TRUE), 
                       distribution.model="norm")    
cfr_fit2 = ugarchfit(spec = cfr_spec2, data = cfr)
cfr_fit2

### Conculsion: the three models still produce acceptable results on "CFR", so they are valid

## Step5: Apply three models to generate volatility




