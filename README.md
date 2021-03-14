# Financial-Econometrics-Exploratory-Research-Project

The U.S. experienced a financial crisis from 2008 to 2009. After that, Dodd-Frank Act was implemented to improve the stabilization and transparency of large banks.

The goal of this project is to investigate how the volatilities of three different volatility models are affected for large banks and after the implementation of stress tests from the Dodd-Frank Act. Additionally, the interaction effect between the two will be included in further models.

The data consisted of 95 bank holding companies (BHCs) that each had at least $10 billion in average total assets from the time period of 1/1/2006 to 12/31/2015. After reviewing the data, it was shown that several of the BHCs had been acquired or had merged with another bank. As a result, the data used consisted of 65 valid BHCs. The stock prices for these BHCs were downloaded using the R programming language and its “quantmod” package. These prices were then transformed into their respective log daily return.

## Methodology: 
Initially, three banks were randomly chosen: CIT, MTB and BOH to build three volatility models: ARCH, GARCH and AR-GARCH, and then applied three models to all the rest banks to generate daily volatility based on the best specifications we found. 

The models were built in two steps: firstly, basic volatility models were built for each of the three banks, and then cross checked to see which order effects of ARCH, GARCH and AR-GARCH could produce acceptable results for all the three models;secondly, with the confirmed three volatility models in first step, I randomly chose a fourth bank and apply the three models on it to see if the results are acceptable too. If they were, then the three models would be applied to all the rest banks and to obtain daily volatility.

- ARCH:
To build the ARCH model, firstly I plot the time series daily return, ACF and PACF to get the initial impression.

![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/acf-cit%20copy.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/acf-mtb%20copy.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/acf-boh%20copy.png)

All three ACF plots of the three banks showed low autocorrelation, so a test was run to see if these three daily returns are white noise. 
The test results prove that at 5% level, all the three daily returns are not white noise. 
For example, the result of the Ljung-Box test for CIT is shown below:
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/box_test-CIT%20copy.png)

For the ARCH model, I need to test the ARCH effect first. For this model, I assume the mean equation is a constant. To test the ARCH effect, I calculated the residuals by subtracting the mean of daily returns and then use “Ljung-Box” to test. For all the three banks, the Box test rejects the null hypothesis, so the square of residuals are not white noise, and there are ARCH effects at 5% level.

For example, the result of Ljung-Box test for square of residuals for CIT is shown below:
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/box_test-CIT%5E2%20copy.png)

The next step was to determine the order of the ARCH model. ACF and PACF plots were made for the squares of residuals calculated in the previous step. From the plots, I found different banks have different optimal orders but all of them have long term autocorrelation. Take bank BOH as example, the ACF and PACF of its square residual are as below:

![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/acf-boh-v%20copy.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/pacf-boh-v%20copy.png)


So, first an ARCH model was fit for each bank with its own optimal order, then cross checked to see which order could produce acceptable results for all three banks.
After checking the AIC, significance of each coefficient and White Ljung-Box Test of the residual and square residual, I found the order 10 produced acceptable results for all three banks. And then I tested ARCH(10) on the random chosen bank: CFR, I also got good results.

- GARCH:

For the GARCH model, I use the standard GARCH(1,1) model since this model is normally sufficient to capture the volatility cluster in the data.

- AR+GARCH:

To create an AR+GARCH model, the first step is to determine the order of the ARMA model for the mean equation. For this step, I used r function: auto.arima to find out the optimal AR and MA orders. Then I combine the ARMA(p,q) model with a standard GARCH(1,1) model. In this step, I will carefully check the significance of the coefficient of the mean equation, because once I create an integrated AR+GARCH model, the optimal (p,q) order for the ARMA model only might not be reasonable anymore. Take bank: MTB as an example, the optimal order of ARMA is (2,2):
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/auto-arima-mtb%20copy.png)

however, after combining the ARCH(2,2) and GARCH(1,1) together, I found the coefficient of AR1 and MA1 are not significant:
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-8.png)

Eventually, I decided to use the model AR(1)+GARCH(1,1).

And again, I fit an AR+GARCH model for each of the three banks with its own optimal order and then cross check which order can produce acceptable results in all the three banks. At last, I found AR(1)+GARCH(1,1) had the best performance for all the three banks. And then test this model on the forth random chosen bank:CFR, I got acceptable results too.

Using the volatilities from the ARCH(10), GARCH(1,1), and AR(1)+GARCH(1,1) models, a set of panel data was created to find quarterly volatilities (annualized) for all the banks. Additional dummy variables for large banks and for years 2011 on (for the Dodd-Frank Act) were also added for use in further analysis, along with an interaction variable between the two. Large banks were considered large if they had more than $50 billion in bank mean assets. Bank mean assets were used, due to the low resolution of the bank assets data over time.

A set of sample data for the ARCH(10) model conditional volatility panel data is shown below.
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-7.png)

After the panel data was compiled, two different models were built: one that included a dummy variable for bank size, and another that added a dummy variable for the Dodd-Frank Act and included interaction effects.

For the first model, a time fixed effects model was used. A fixed effects model was not used to avoid issues of multicollinearity between the large bank dummy variables and the fixed effects for the banks. The model regressed the volatility on the large bank variable and included dummy variables for time fixed effects. The results of the three models are shown below. The time fixed effects variables are not included in the results for ease of analysis.

In the second model, a variable was added for time periods after 2011 to represent the introduction of the Dodd-Frank Act. Additionally an interaction variable between the large dummy and the Dodd-Frank dummies was added to account for interaction effects. Time fixed effects were removed from this regression to account for potential multicollinearity between the time fixed effect dummies and the Dodd-Frank dummy variable. The results for the three different models/conditional volatilities are as follows.


## Results and implications:
### Return Volatility:
- ARCH(10) Volatility Models:

![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-6.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-5.png)

- GARCH(1,1) Volatility Models:

![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-4.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-3.png)

- AR(1) + GARCH(1,1) Volatility Models:

![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed-2.png)
![image](https://github.com/alice-heqi/Financial-Econometrics-Exploratory-Research-Project/blob/main/image/unnamed.png)

In the results for the first model, I find that in the first model the coefficient for the large dummy is significant and positive for each of the three volatilities. Evidence was found that large banks had significantly higher conditional volatilities, with 95% confidence intervals for the magnitude of the effect being around  1.5% to 3.8%.
In the results for the second model, the coefficients for each of the models were all significant. Evidence was again found that large banks (that had to perform additional stress tests due to regulations) had greater predicted volatility. Additionally, evidence is shown that banks after the Dodd-Frank Act had considerably lower volatilities (estimated to be around 15.4% lower) and that there is an interaction between the size of the bank and the effect of the Dodd-Frank Act. The negative significant coefficient for the dummy variable reflecting the Dodd-Frank Act means that the impact of the act on volatility for large banks is estimated to be greater in magnitude (greater estimated decrease in volatility).

