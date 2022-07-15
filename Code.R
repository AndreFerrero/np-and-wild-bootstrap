library(lmtest)
library(PoEdata) #for PoE4 datasets
library("skedastic")
library(boot)
library(lmboot)
library(sandwich)
library(ggplot2)
library(xtable)
library(knitr)

# importing dataset from PoEdata package and fitting a simple linear regression
data("food", package = "PoEdata")
mod1 <- lm(food_exp ~ income, data = food)
ggplot(food, aes(x = income, y = food_exp)) +
  geom_point() +
  ggtitle("Linear regression") +
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab("Income") + ylab("Food expenditure")+
  stat_smooth(method = "lm", formula = y ~ x, col = "red")

# residual analysis
library(broom)
# extracting data from regression in a dataframe
df <- augment(mod1)
res <- residuals(mod1)
ggplot(df, aes(x = .fitted, y = .resid)) +
  geom_point() + ggtitle("Residual analysis") +
  theme(plot.title = element_text(hjust = 0.5)) +
  xlab("Fitted values") + ylab("Residuals") +
  geom_hline(yintercept = 0, color = "red")

# testing for heteroskedasticity
# breusch-pagan test
bptest(mod1)
# white test
white_lm(mod1)
# goldfeldt quandt test (hsk across groups)
gqtest(mod1, order.by = food$income, point = 0.2)
# all of the tests confirm our assumption of hsk

# the GOAL is comparing non parametric bootstrap and wild bootstrap when estimating se(income)
#We do that using White robust standard error as a reference point
# we use the coeftest function from the sandwich package
hc <- coeftest(mod1, vcov = vcovHC(mod1, type = "HC0"))[[4]]

# extracting the OLS se(income)
se_ols <- sqrt(vcov(mod1)[[4]])
se_ols


# creating a bootstrap function that returns the income coefficient
# that will be applied while bootstrapping
boot_fn <- function(d, index) {
  c <- coef(lm(food_exp ~ income, data = d, subset = index))[2]
  return(c)
}

# NON PARAMETRIC BOOTSTRAPPING
set.seed(1)
npboot <- boot(food, statistic = boot_fn, R = 400)
npboot
plot(npboot)
# np bootstrap confirms the ols estimate (as expected)
# exracting the bootstrapped replicates of the income coefficients from boot$t
npboot_income <- npboot$t
# obtaining the se(income) from the bootstrapped replicates
se_npb <- sd(npboot_income)

# WILD BOOTSTRAP
wboot <- wild.boot(food_exp ~ income, data = food, B = 400, seed = 1)
# extracting the bootstrapped replicates
wbootdata <- data.frame(wboot$bootEstParam)
wboot_income <- wbootdata$income
# obtaining se(income) from the replicates
se_wb <- sd(wboot_income)

# final vector with all the se(income)
# the wild bootstrap performs better because of heteroskedasticity
se <- data.frame(c(se_ols, hc, se_npb, se_wb), 
                 c("OLS", "HC1", "NP Bootstrap", "Wild bootstrap"))
colnames(se) <- c("SE(Income)", "Estimation type")
kable(se)

# this shows that 1 np bootstrap sample doesn't replicate hsk, therefore it is unaccurate
# manually sampling with replacement from the original vectors
boot_income_data <- sample(food$income, length(food$income), replace = TRUE)
boot_food_data <- sample(food$food_exp, length(food$food_exp), replace = TRUE)
boot_data <- data.frame(boot_income_data, boot_food_data)
# the scatterplot evidently tells us that hsk has vanished
attach(boot_data)
plot(boot_income_data, boot_food_data, main = "Non parametric bootstrap sample")
detach(boot_data)

# check with statistical tests
mod <- lm(boot_food_data ~ boot_income_data, data = boot_data)
bptest(mod)
white_lm(mod)
abline(mod, col = "green")
# they confirm our intuition

# showing the same with the wild bootstrap
# note: in wild bootstrap, the x value is sampled in the same way as with np bootstrap
# Instead, y* = y_hat + e_hat * vi, where vi is a random variable with E(vi) = 0, V(vi) = 1
# we'll need the predicted y = y_hat and the associated residual

yhat <- predict(mod1, food)

# we can obtain different types of wild bootstrap residuals = res*vi
library("fda.usc")
mammen_res <- rwild(res, type = "golden")
rademacher_res <- rwild(res, type = "Rademacher")
normal_res <- rwild(res, type = "normal") 

# let's choose one and try to recreate one bootstrap sample
wild_food <- yhat + normal_res
# let's create our dataframe
wild_boot_data <- data.frame(boot_income_data, wild_food)
# let's plot it
attach(wild_boot_data)
plot(boot_income_data, wild_food, main = "Wild bootstrap sample")
# checking hsk, but it appears to be missing
wild_mod <- lm(wild_food ~ boot_income_data, data = wild_boot_data)
abline(wild_mod, col = "orange")
detach(wild_boot_data)

bptest(wild_mod)
white_lm(wild_mod)
gqtest(wild_mod)


