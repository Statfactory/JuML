using Compat, Compat.Test
using JuML
traintest_df = DataFrame("C:\\Users\\adamm_000\\Documents\\Julia\\airlinetrainairlinetest") 
distance = traintest_df["Distance"]
deptime = traintest_df["DepTime"]
label = covariate(traintest_df["dep_delayed_15min"], level -> level == "Y" ? 1.0 : 0.0)
deptime = factor(traintest_df["DepTime"], 1:2930)
distance = factor(traintest_df["Distance"], 11:4962)

factors = [traintest_df.factors; [deptime, distance]]

trainsel = (1:10100000) .<= 10000000
testsel = (1:10100000) .> 10000000

model = xgblogit(label, factors; selector = BoolVariate("", trainsel), η = 0.1, λ = 1.0, γ = 0.0, minchildweight = 1.0, nrounds = 10, maxdepth = 10, ordstumps = false, pruning = true, caching = true, usefloat64 = false, singlethread = false, slicelength = 0);
testauc = getauc(model.pred, label; selector = testsel)
@test testauc ≈ 0.7284 atol = 0.0001

# XGBoost R script to compare:
# suppressMessages({
# library(data.table)
# library(ROCR)
# library(xgboost)
# library(MLmetrics)
# library(Matrix)
# })
# d_train <- fread("airlinetrain.csv", showProgress=FALSE, stringsAsFactors=TRUE)
# d_test <- fread("airlinetest.csv", showProgress=FALSE, stringsAsFactors=TRUE)
# X_train_test <- sparse.model.matrix(dep_delayed_15min ~ .-1, data = rbind(d_train, d_test))
# n1 <- nrow(d_train)
# n2 <- nrow(d_test)
# X_train <- X_train_test[1:n1,]
# X_test <- X_train_test[(n1+1):(n1+n2),]
# dxgb_train <- xgb.DMatrix(data = X_train, label = ifelse(d_train$dep_delayed_15min=='Y',1,0))
# md <- xgb.train(data = dxgb_train, objective = "binary:logistic", nround = 10, max_depth = 10, eta = 0.1, tree_method='exact')
# phat <- predict(md, newdata = X_test)
# testlabel = ifelse(d_test$dep_delayed_15min=='Y',1,0)
# AUC(phat, testlabel)