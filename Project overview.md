# np-and-wild-bootstrap
The purpose of this mini-project is to show and remark the results obtained by the non parametric bootstrap
compared to the wild boostrap when trying to estimate the standard error of OLS coefficients.

The dataset used is one of the dataset that are available from the PoEdata package, a package intended as an integration to 
Principle of econometrics by Hill, Griffiths. It is therefore a simple dataset, yet ideal when considering theoretical examples put into practice.

More specifically, as one can see from the "Linear regression" file, the 2 variables clearly show heteroskedasticity, as "Heteroskedasticity test linear model"
rigorously proves. It is therefore legit to ask whether non parametric bootstrap would be consistent or not.
The literature about this topic showed that the answer to this question is the latter, and another bootstrapping method is required.

The problem lies in the inability of non parametric bootstrap to replicate heteroskedasticity when resampling from the original dataset.
A consistent way of bootstrapping is the one proposed by Wu (1986), which has been named Wild bootstrapping.

A wild bootstrap is a form of residual bootstrap, and works as follows:
- Consider the linear model Y = bX, where Y is the response variable, X is the predictor and b is the coefficients vector
- Resample X R times with replacement (Normal non parametric bootstrap)
- Construct a Y variable Y* = Yhat + ehat * v, where Yhat is the predicted values vector, 
  ehat is the residuals vector, and v is a random variable such that E(v)=0 and E(v^2)=0
- Fit Y* ~ X R times and extract the distribution of the statistics

A lot of the discussion has been about the choice of the v variable. 3 of the most adopted solutions are:
- Mammen's suggested distribution
- Rademacher distribution: https://en.wikipedia.org/wiki/Rademacher_distribution
- Standard normal distribution

After printing the results obtained from the different methods, the project ends with an attempt to show the difference between a non parametric bootstrap sample
and from a wild bootstrap sample, even though the difference is not clearly visible by analysing only one resample.
The reason may be the structure of the dataset and/or the sample size.
Nonetheless, the difference is quite remarkable in the estimates poposed
